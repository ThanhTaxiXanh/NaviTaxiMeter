// Issue #3: simulated native-to-Dart serialized IPC handoff.
// NO Android MethodChannel, no physical GNSS, no passenger fares.
import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:navitaximeter/src/lab/trip_ipc_contract.dart';

import 'support/issue3_service_ack_wire_bridge.dart';
import 'support/issue3_sqflite_clone_writer.dart';
import 'support/issue3_unified_checkpoint_writer.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  final start = DateTime.utc(2026, 11, 15, 9);
  late Directory sandbox;
  late Database db;
  late List<CloneFix> fixes;
  late UnifiedTestOnlyWorker worker;
  late TestOnlyServiceAckBridge bridge;

  Future<int> count(String table) async =>
      Sqflite.firstIntValue(await db.rawQuery(
        'SELECT COUNT(*) FROM $table'))!;

  Future<Map<String, Object>> deliver(int i) => bridge.deliver(
      UnifiedTestOnlyWorker.proposal(fixes[i]).toWire());

  setUp(() async {
    sandbox = await Directory.systemTemp.createTemp('navi-sqflite-appclone-');
    final original = await createV3Fixture(sandbox);
    await original.close();
    db = await dryRunCloneV4(sandbox);
    fixes = List.generate(9, (i) => CloneFix(
      sequence: i, gnssNanos: 10000000000 + i * 5000000000,
      latitude: i * 0.0003, longitude: 0,
      accuracy: 1, speed: 20,
    ));
    worker = await UnifiedTestOnlyWorker.begin(
      db: db, at: start, immutableFixtures: fixes,
    );
    bridge = TestOnlyServiceAckBridge(db: db, gate: worker.gate);
  });

  tearDown(() async {
    if (db.isOpen) await db.close();
    if (await sandbox.exists()) await sandbox.delete(recursive: true);
  });

  test('wire proposal earns ACK only after durable SQLite readback', () async {
    expect(await count('checkpoint_ack'), 0);
    final reply = await deliver(0);
    expect(reply['type'], 'trip.ack.v1');
    expect(reply['sessionId'], 'TEST_SESSION_ONLY');
    expect(reply['generation'], 7);
    expect(reply['sequence'], 0);
    expect(reply['payloadHash'], fixes[0].digest);
    final saved = (await db.query('checkpoint_ack')).single;
    expect(reply['checkpointId'], saved['checkpoint_id']);
    expect(await count('active_trip_route'), 1);
    expect(await count('unified_checkpoint_history_test_only'), 1);
    expect((await db.query('checkpoint_fence')).single['last_sequence'], 0);
    expect(worker.gate.phase, IpcGatePhase.accepting);
  });

  test('8 native-like concurrent calls serialize until each ACK is verified',
      () async {
    final replies = await Future.wait(List.generate(8, deliver));
    expect(replies.map((m) => m['sequence']).toList(),
        [0, 1, 2, 3, 4, 5, 6, 7]);
    expect(replies.map((m) => m['checkpointId']).toSet().length, 8);
    expect(await count('active_trip_route'), 8);
    expect(await count('checkpoint_ack'), 8);
    expect(await count('unified_checkpoint_history_test_only'), 8);
    expect((await db.query('checkpoint_fence')).single['last_sequence'], 7);
    final original = await openDatabase(
        path.join(sandbox.path, v3FixtureName),
        readOnly: true, singleInstance: false);
    try {
      expect(Sqflite.firstIntValue(
          await original.rawQuery('PRAGMA user_version')), 3);
      expect(await original.rawQuery(
          "SELECT name FROM sqlite_master WHERE name='checkpoint_ack'"),
          isEmpty);
    } finally {
      await original.close();
    }
  });

  test('8 byte-identical concurrent wire retries return one durable ACK',
      () async {
    final replies = await Future.wait(
        List.generate(8, (_) => deliver(0)));
    expect(replies.map((x) => x['checkpointId']).toSet().length, 1);
    expect(await count('checkpoint_ack'), 1);
    expect(await count('active_trip_route'), 1);
    expect(await count('unified_checkpoint_history_test_only'), 1);
    expect(worker.gate.lastSequence, 0);
  });

  test('stale native generation fails without suspending live test session',
      () async {
    final foreign = UnifiedTestOnlyWorker.proposal(fixes[0],
        fence: IpcFence('TEST_SESSION_ONLY', 6)).toWire();
    await expectLater(bridge.deliver(foreign), throwsStateError);
    expect(await count('checkpoint_ack'), 0);
    expect(worker.gate.phase, IpcGatePhase.accepting);
    expect((await deliver(0))['sequence'], 0);
  });

  test('conflicting same-sequence wire payload fails closed', () async {
    final committed = await deliver(0);
    final conflicting = {...UnifiedTestOnlyWorker.proposal(fixes[0]).toWire(),
      'speedKmh': 21.0};
    await expectLater(bridge.deliver(conflicting), throwsStateError);
    expect(worker.gate.phase, IpcGatePhase.paused);
    expect((await db.query('checkpoint_ack')).single['checkpoint_id'],
        committed['checkpointId']);
    expect(await count('active_trip_route'), 1);
  });

  test('forged persisted ACK is rejected on independent wire readback',
      () async {
    await deliver(0);
    await db.update('checkpoint_ack',
        {'checkpoint_id': 'forged-ack-after-commit'},
        where: 'sequence=?', whereArgs: [0]);
    await expectLater(deliver(0), throwsStateError);
    expect(worker.gate.phase, IpcGatePhase.paused);
    expect(worker.gate.reason, 'ack_delivery_unknown');
    expect(await count('active_trip_route'), 1);
  });

  test('delivery callback is withheld until durable readback succeeds',
      () async {
    final entered = Completer<void>();
    final release = Completer<void>();
    bridge = TestOnlyServiceAckBridge(
      db: db, gate: worker.gate,
      afterDurableReadback: () async {
        entered.complete();
        await release.future;
      },
    );
    var delivered = false;
    final pending = deliver(0).then((value) {
      delivered = true;
      return value;
    });
    await entered.future;
    expect(delivered, false);
    expect(await count('checkpoint_ack'), 1);
    expect(await count('active_trip_route'), 1);
    release.complete();
    expect((await pending)['sequence'], 0);
    expect(delivered, true);
  });

  test('lost native ACK AFTER COMMIT forces PAUSED recovery without replay',
      () async {
    bridge = TestOnlyServiceAckBridge(
      db: db, gate: worker.gate,
      afterDurableReadback: () async {
        throw StateError('TEST_ONLY native transport lost');
      },
    );
    await expectLater(deliver(0), throwsStateError);
    expect(worker.gate.phase, IpcGatePhase.paused);
    expect(worker.gate.reason, 'ack_delivery_unknown');
    expect(await count('checkpoint_ack'), 1);
    expect(await count('active_trip_route'), 1);
    await expectLater(deliver(0), throwsStateError);
    expect(await count('checkpoint_ack'), 1); // No double distance.
    await db.close();
    db = await openDatabase(path.join(sandbox.path, v4FixtureName),
        singleInstance: false);
    final recovered = await UnifiedTestOnlyWorker.recoverPaused(db);
    expect(recovered.routePoints, isEmpty); // v3 route stored separately.
    expect((await db.query('checkpoint_fence')).single['phase'], 'PAUSED');
    await expectLater(UnifiedTestOnlyWorker.begin(
      db: db, at: start, immutableFixtures: fixes,
    ), throwsStateError);
  });

  test('malformed wire is rejected before writer is invoked', () async {
    final invalid = {...UnifiedTestOnlyWorker.proposal(fixes[0]).toWire(),
      'type': 'trip.noop.v1'};
    await expectLater(bridge.deliver(invalid), throwsFormatException);
    expect(await count('checkpoint_ack'), 0);
    expect(await count('active_trip_route'), 0);
  });
}
