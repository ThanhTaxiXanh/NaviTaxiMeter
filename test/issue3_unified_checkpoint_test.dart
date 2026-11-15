// Issue #3 P1 unified test-only IPC -> staged fare -> one SQLite COMMIT.
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:navitaximeter/src/core/taximeter_engine.dart';
import 'package:navitaximeter/src/data/trip_session_snapshot.dart';
import 'package:navitaximeter/src/lab/trip_ipc_contract.dart';

import 'support/issue3_sqflite_clone_writer.dart';
import 'support/issue3_staged_fare_checkpoint.dart';
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
  Future<void> Function()? beforeWrite;
  Future<void> Function()? afterCommit;

  setUp(() async {
    beforeWrite = null;
    afterCommit = null;
    sandbox = await Directory.systemTemp.createTemp('navi-sqflite-appclone-');
    final v3 = await createV3Fixture(sandbox);
    await v3.close(); // No raw copy of an open/WAL-connected database.
    db = await dryRunCloneV4(sandbox);
    fixes = List.generate(9, (i) => CloneFix(
      sequence: i, gnssNanos: 10000000000 + i * 5000000000,
      latitude: i * 0.0003, longitude: 0,
      accuracy: 1, speed: 20,
    ));
    worker = await UnifiedTestOnlyWorker.begin(
      db: db, at: start, immutableFixtures: fixes,
      beforeWrite: () async {
        if (beforeWrite != null) await beforeWrite!();
      },
      afterCommit: () async {
        if (afterCommit != null) await afterCommit!();
      },
    );
  });

  tearDown(() async {
    if (db.isOpen) await db.close();
    if (await sandbox.exists()) await sandbox.delete(recursive: true);
  });

  Future<IpcAck> send(int i) => worker.gate.submit(
      UnifiedTestOnlyWorker.proposal(fixes[i]));
  Future<int> count(String table) async => Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM ' + table))!;
  Future<Map<String, dynamic>> header() async => Map<String, dynamic>.from(
      jsonDecode((await db.query('active_trip')).single['payload'] as String)
          as Map);
  Future<TripSessionSnapshot> saved() async => TripSessionSnapshot.decode(
      (await db.query('active_trip')).single['payload'] as String);

  test('8 parallel IPC samples commit fare+route+fence+ACK atomically', () async {
    final acks = await Future.wait(List.generate(8, send));
    expect(acks.map((a) => a.sequence).toList(), [0,1,2,3,4,5,6,7]);
    expect(acks.map((a) => a.id).toSet().length, 8);
    expect(await count('active_trip_route'), 8);
    expect(await count('checkpoint_ack'), 8);
    final f = (await db.query('checkpoint_fence')).single;
    expect(f['last_sequence'], 7);
    expect(f['last_gnss_nanos'], fixes[7].gnssNanos);
    final h = await header();
    expect(h['routeCount'], 8);
    expect(h['tariffHash'], frozenTestTariffHash);
    expect(h['meter'], worker.publishedMeter);
    expect(worker.publishedMeters, greaterThan(100));
    expect(worker.publishedFare, greaterThan(syntheticStageTariff.baseFare));
    expect(worker.publishedElapsed, 35);
    expect((await db.query('checkpoint_ack')).last['checkpoint_id'],
        acks.last.id);
    expect((await db.query('trips')).single['payload'],
        '{"fixtureOnly":true,"receipt":"preserve"}');

    // Existing source v3 database was not changed or migrated.
    final v3 = await openDatabase(path.join(sandbox.path, v3FixtureName),
        readOnly: true, singleInstance: false);
    try {
      expect(Sqflite.firstIntValue(await v3.rawQuery('PRAGMA user_version')), 3);
      expect((await v3.query('trips')).single['id'], 'TEST_RECEIPT_ONLY');
      expect((await v3.rawQuery(
          "SELECT name FROM sqlite_master WHERE name='checkpoint_ack'")),
          isEmpty);
    } finally {
      await v3.close();
    }
  });

  test('in-flight candidate cannot publish money before transaction', () async {
    await send(0);
    final entered = Completer<void>();
    final release = Completer<void>();
    beforeWrite = () async {
      entered.complete();
      await release.future;
    };
    final oldFare = worker.publishedFare;
    final oldMeters = worker.publishedMeters;
    final operation = send(1);
    await entered.future;
    expect(worker.publishedFare, oldFare);
    expect(worker.publishedMeters, oldMeters);
    expect(await count('active_trip_route'), 1);
    expect(await count('checkpoint_ack'), 1);
    release.complete();
    final ack = await operation;
    expect(ack.sequence, 1);
    expect(worker.publishedFare, greaterThan(oldFare));
    expect((await saved()).meter, worker.publishedMeter);
  });

  test('8 identical parallel replays produce one ACK and no double fare',
      () async {
    final acks = await Future.wait(List.generate(8, (_) => send(0)));
    expect(acks.map((a) => a.id).toSet().length, 1);
    expect(await count('active_trip_route'), 1);
    expect(await count('checkpoint_ack'), 1);
    expect(worker.publishedMeters, 0);
    expect(worker.publishedFare, syntheticStageTariff.baseFare);
    expect(worker.gate.phase, IpcGatePhase.accepting);
  });

  test('stale generation is rejected before writer, valid fix still accepted',
      () async {
    await expectLater(worker.gate.submit(
      UnifiedTestOnlyWorker.proposal(
          fixes[0], fence: IpcFence('TEST_SESSION_ONLY', 6))),
        throwsStateError);
    expect(worker.gate.phase, IpcGatePhase.accepting);
    expect(await count('checkpoint_ack'), 0);
    expect((await send(0)).sequence, 0);
  });

  test('mock metadata pauses gate without route, fare or ACK', () async {
    final before = worker.publishedMeter;
    final mocked = CloneFix(sequence: 0, gnssNanos: fixes[0].gnssNanos,
        mocked: true, accuracy: 1, speed: 20);
    await expectLater(worker.gate.submit(
        UnifiedTestOnlyWorker.proposal(mocked)), throwsStateError);
    expect(worker.gate.reason, 'untrusted_metadata_or_tariff');
    expect(await count('active_trip_route'), 0);
    expect(await count('checkpoint_ack'), 0);
    expect(worker.publishedMeter, before);
  });

  test('sequence gap pauses gate without spending money', () async {
    await expectLater(send(1), throwsStateError);
    expect(worker.gate.reason, 'sequence_gap');
    expect(await count('checkpoint_ack'), 0);
    expect(worker.publishedFare, syntheticStageTariff.baseFare);
  });

  test('conflicting same-sequence replay cannot overwrite fare or ACK',
      () async {
    final original = await send(0);
    final altered = CloneFix(
        sequence: 0, gnssNanos: fixes[0].gnssNanos,
        latitude: fixes[0].latitude, speed: 18, accuracy: 1);
    await expectLater(worker.gate.submit(
        UnifiedTestOnlyWorker.proposal(altered)), throwsStateError);
    expect(worker.gate.reason, 'conflicting_replay');
    expect((await db.query('checkpoint_ack')).single['checkpoint_id'],
        original.id);
    expect(await count('active_trip_route'), 1);
  });

  test('GNSS monotonic gap is fail-closed, no retrospective seconds', () async {
    await send(0);
    final invalid = CloneFix(sequence: 1,
        gnssNanos: fixes[0].gnssNanos + 13000000000,
        latitude: 0.0003, accuracy: 1, speed: 20);
    await expectLater(worker.gate.submit(
        UnifiedTestOnlyWorker.proposal(invalid)), throwsStateError);
    expect(worker.gate.reason, 'gnss_discontinuity');
    expect(worker.publishedElapsed, 0);
    expect(await count('checkpoint_ack'), 1);
  });

  for (final fault in UnifiedFailAt.values.where(
      (f) => f != UnifiedFailAt.none)) {
    test('injected SQLite $fault rolls back all 4 records and fare', () async {
      final before = await header();
      worker.injectFault(fault);
      await expectLater(send(0), throwsStateError);
      expect(worker.faulted, isTrue);
      expect(worker.gate.reason, 'commit_unknown');
      expect(await header(), before);
      expect(await count('active_trip_route'), 0);
      expect(await count('checkpoint_ack'), 0);
      expect((await db.query('checkpoint_fence')).single['last_sequence'], -1);
      expect(worker.publishedFare, syntheticStageTariff.baseFare);
      await expectLater(send(0), throwsStateError); // No automatic retry.
    });
  }

  test('lost ACK after COMMIT retains durable fare but never publishes it',
      () async {
    await send(0);
    final beforeFare = worker.publishedFare;
    afterCommit = () async => throw StateError('Transport lost after COMMIT');
    await expectLater(send(1), throwsStateError);
    expect(worker.gate.reason, 'commit_unknown');
    expect(worker.faulted, isTrue);
    expect(await count('checkpoint_ack'), 2);
    expect(await count('active_trip_route'), 2);
    expect(worker.publishedFare, beforeFare); // No phantom UI fare.
    expect((await saved()).meter['distanceMeters'],
        greaterThan(worker.publishedMeters));

    await db.close();
    db = await openDatabase(path.join(sandbox.path, v4FixtureName),
        singleInstance: false);
    final durable = await UnifiedTestOnlyWorker.recoverPaused(db);
    expect(durable.meter['distanceMeters'], greaterThan(30));
    expect((await db.query('checkpoint_fence')).single['phase'], 'PAUSED');
    expect(durable.restore(at: start.add(const Duration(hours: 1))).status,
        MeterStatus.paused);
    expect(await count('checkpoint_ack'), 2);
    await expectLater(UnifiedTestOnlyWorker.begin(
        db: db, at: start, immutableFixtures: fixes), throwsStateError);
  });

  test('ACK invalidated during completed COMMIT stays durable and PAUSED',
      () async {
    await send(0);
    final before = worker.publishedMeters;
    afterCommit = () async => worker.gate.markAckUnknown();
    await expectLater(send(1), throwsStateError);
    expect(worker.gate.phase, IpcGatePhase.paused);
    expect(worker.publishedMeters, before);
    expect(await count('checkpoint_ack'), 2);
    await UnifiedTestOnlyWorker.recoverPaused(db);
    expect((await db.query('checkpoint_fence')).single['phase'], 'PAUSED');
  });

  test('external header tampering aborts before route and ACK insert',
      () async {
    await send(0);
    await db.update('active_trip', {
      'payload': jsonEncode({...await header(), 'tariffHash': 'tampered'})
    }, where: 'id=?', whereArgs: [1]);
    final oldFare = worker.publishedFare;
    await expectLater(send(1), throwsStateError);
    expect(worker.gate.reason, 'commit_unknown');
    expect(await count('checkpoint_ack'), 1);
    expect(await count('active_trip_route'), 1);
    expect(worker.publishedFare, oldFare);
  });
}
