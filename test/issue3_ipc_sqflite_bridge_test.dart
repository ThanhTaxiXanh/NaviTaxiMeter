import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:navitaximeter/src/lab/trip_ipc_contract.dart';

import 'support/issue3_ipc_sqflite_adapter.dart';
import 'support/issue3_sqflite_clone_writer.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  late Directory sandbox;
  late Database db;
  late CloneAckWriter cloneWriter;

  setUp(() async {
    sandbox = await Directory.systemTemp.createTemp('navi-sqflite-appclone-');
    final v3 = await createV3Fixture(sandbox);
    await v3.close();
    db = await dryRunCloneV4(sandbox);
    cloneWriter = CloneAckWriter(db);
  });

  tearDown(() async {
    if (db.isOpen) await db.close();
    if (await sandbox.exists()) await sandbox.delete(recursive: true);
  });

  CloneFix fixture(int sequence, {double speed = 0.0, int? nanos}) => CloneFix(
    sequence: sequence,
    speed: speed,
    gnssNanos: nanos ?? 10000000000 + sequence * 1000000000,
  );

  Future<int> count(String table) async => Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM ' + table))!;

  test('IPC gate -> real sqflite clone commits 8 ordered checkpoints',
      () async {
    final fixes = List.generate(8, fixture);
    final bridge = TestOnlyIpcSqliteBridge(
        cloneWriter: cloneWriter, immutableFixtures: fixes);
    final results = await Future.wait(
        fixes.map((f) => bridge.gate.submit(TestOnlyIpcSqliteBridge.proposal(f))));
    expect(results.map((a) => a.sequence).toList(), [0,1,2,3,4,5,6,7]);
    expect(bridge.gate.lastSequence, 7);
    expect(await count('active_trip_route'), 8);
    expect(await count('checkpoint_ack'), 8);
    final last = results.last;
    expect((await db.query('checkpoint_ack',
        where: 'sequence=?', whereArgs: [7])).single['checkpoint_id'], last.id);
    expect((await db.query('trips')).single['id'], 'TEST_RECEIPT_ONLY');
    final header = jsonDecode(
        (await db.query('active_trip')).single['payload'] as String) as Map;
    expect(header['routeCount'], 8);
    expect((header['meter'] as Map)['totalFare'], 0);
  });

  test('8 identical IPC submissions return one post-COMMIT ACK', () async {
    final f = fixture(0);
    final bridge = TestOnlyIpcSqliteBridge(
        cloneWriter: cloneWriter, immutableFixtures: [f]);
    final responses = await Future.wait(List.generate(8, (_) =>
        bridge.gate.submit(TestOnlyIpcSqliteBridge.proposal(f))));
    expect(responses.map((x) => x.id).toSet().length, 1);
    expect(await count('active_trip_route'), 1);
    expect(await count('checkpoint_ack'), 1);
    expect(bridge.gate.phase, IpcGatePhase.accepting);
  });

  test('wrong proposal digest never inserts route or ACK', () async {
    final original = fixture(0);
    final faked = fixture(0, speed: 42);
    final bridge = TestOnlyIpcSqliteBridge(
        cloneWriter: cloneWriter, immutableFixtures: [original]);
    final modified = TestOnlyIpcSqliteBridge.proposal(faked);
    await expectLater(bridge.gate.submit(modified), throwsStateError);
    expect(bridge.gate.phase, IpcGatePhase.paused);
    expect(bridge.gate.reason, 'commit_unknown');
    expect(await count('active_trip_route'), 0);
    expect(await count('checkpoint_ack'), 0);
  });

  test('old generation rejected without touching durable clone', () async {
    final f = fixture(0);
    final bridge = TestOnlyIpcSqliteBridge(
        cloneWriter: cloneWriter, immutableFixtures: [f]);
    await expectLater(bridge.gate.submit(TestOnlyIpcSqliteBridge.proposal(
        f, fence: IpcFence('TEST_SESSION_ONLY', 6))), throwsStateError);
    expect(bridge.gate.phase, IpcGatePhase.accepting);
    expect(await count('checkpoint_ack'), 0);
    await bridge.gate.submit(TestOnlyIpcSqliteBridge.proposal(f));
    expect(await count('checkpoint_ack'), 1);
  });

  test('conflicting retry pauses gate and never overwrites durable ACK',
      () async {
    final first = fixture(0);
    final changed = fixture(0, speed: 10);
    final bridge = TestOnlyIpcSqliteBridge(
        cloneWriter: cloneWriter, immutableFixtures: [first, changed]);
    final receipt = await bridge.gate.submit(
        TestOnlyIpcSqliteBridge.proposal(first));
    await expectLater(bridge.gate.submit(
        TestOnlyIpcSqliteBridge.proposal(changed)), throwsStateError);
    expect(bridge.gate.reason, 'conflicting_replay');
    expect((await db.query('checkpoint_ack')).single['checkpoint_id'],
        receipt.id);
    expect(await count('active_trip_route'), 1);
  });

  test('lost IPC ACK after COMMIT leaves committed row and PAUSED state',
      () async {
    final f = fixture(0);
    final bridge = TestOnlyIpcSqliteBridge(
        cloneWriter: cloneWriter, immutableFixtures: [f], loseAckAt: 0);
    await expectLater(bridge.gate.submit(
        TestOnlyIpcSqliteBridge.proposal(f)), throwsStateError);
    expect(bridge.gate.reason, 'commit_unknown');
    expect(await count('checkpoint_ack'), 1);
    expect(await count('active_trip_route'), 1);
    final recovered = await cloneWriter.recoverPaused();
    expect(recovered['phase'], 'PAUSED');
    expect((await db.query('checkpoint_fence')).single['phase'], 'PAUSED');
  });

  test('restart cannot invent in-memory ACK; durable recovery stays PAUSED',
      () async {
    final f0 = fixture(0);
    final first = TestOnlyIpcSqliteBridge(
        cloneWriter: cloneWriter, immutableFixtures: [f0]);
    await first.gate.submit(TestOnlyIpcSqliteBridge.proposal(f0));
    await db.close();
    db = await openDatabase(path.join(sandbox.path, v4FixtureName),
        singleInstance: false);
    cloneWriter = CloneAckWriter(db);
    final f1 = fixture(1);
    final second = TestOnlyIpcSqliteBridge(
        cloneWriter: cloneWriter, immutableFixtures: [f1]);
    await expectLater(second.gate.submit(
        TestOnlyIpcSqliteBridge.proposal(f1)), throwsStateError);
    expect(second.gate.reason, 'sequence_gap');
    expect(await count('checkpoint_ack'), 1);
    expect(await count('active_trip_route'), 1);
    final durable = await cloneWriter.recoverPaused();
    expect(durable['sequence'], 0);
    expect(durable['phase'], 'PAUSED');
  });
}
