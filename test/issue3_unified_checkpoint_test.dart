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

import 'support/issue3_historical_ack_chain.dart';
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
    expect(await count('unified_checkpoint_history_test_only'), 8);
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
      expect(await count('unified_checkpoint_history_test_only'), 0);
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


  // The old recovery proof checked only row counts, session and a nonempty
  // checkpoint ID. These injected edits must now be rejected before changing
  // the durable phase to PAUSED, even when SQLite itself reports integrity OK.
  for (final change in [
    'money_header', 'route_position', 'ack_digest', 'checkpoint_id',
    'gnss_fence', 'frozen_tariff',
  ]) {
    test('recovery rejects tampered last checkpoint: $change', () async {
      await send(0);
      await send(1);
      final beforeRouteCount = await count('active_trip_route');
      final beforeAckCount = await count('checkpoint_ack');

      if (change == 'money_header') {
        final changed = await header();
        final meter = Map<String, dynamic>.from(changed['meter'] as Map);
        meter['distanceMeters'] = 9999.0;
        changed['meter'] = meter;
        await db.update('active_trip', {
          'payload': jsonEncode(changed),
        }, where: 'id=?', whereArgs: [1]);
      } else if (change == 'route_position') {
        await db.update('active_trip_route', {
          'latitude': 0.123,
        }, where: 'sequence=?', whereArgs: [1]);
      } else if (change == 'ack_digest') {
        await db.update('checkpoint_ack', {
          'sample_digest': List.filled(64, '0').join(),
        }, where: 'sequence=?', whereArgs: [1]);
      } else if (change == 'checkpoint_id') {
        await db.update('checkpoint_ack', {
          'checkpoint_id': 'forged-but-nonempty',
        }, where: 'sequence=?', whereArgs: [1]);
      } else if (change == 'gnss_fence') {
        await db.update('checkpoint_fence', {
          'last_gnss_nanos': fixes[1].gnssNanos + 1,
        }, where: 'id=?', whereArgs: [1]);
      } else if (change == 'frozen_tariff') {
        final changed = await header();
        final tariff = Map<String, dynamic>.from(changed['tariff'] as Map);
        tariff['perKmRate'] = 99999.0;
        changed['tariff'] = tariff;
        await db.update('active_trip', {
          'payload': jsonEncode(changed),
        }, where: 'id=?', whereArgs: [1]);
      }
      await expectLater(UnifiedTestOnlyWorker.recoverPaused(db),
          throwsStateError);
      expect((await db.query('checkpoint_fence')).single['phase'],
          'TEST_ACTIVE'); // Recovery transaction was not committed.
      expect(await count('active_trip_route'), beforeRouteCount);
      expect(await count('checkpoint_ack'), beforeAckCount);
    });
  }

  test('recovery rejects fabricated money before the first ACK', () async {
    final changed = await header();
    final meter = Map<String, dynamic>.from(changed['meter'] as Map);
    meter['distanceMeters'] = 7000.0;
    changed['meter'] = meter;
    await db.update('active_trip', {'payload': jsonEncode(changed)},
        where: 'id=?', whereArgs: [1]);
    await expectLater(UnifiedTestOnlyWorker.recoverPaused(db),
        throwsStateError);
    expect((await db.query('checkpoint_fence')).single['phase'],
        'TEST_ACTIVE');
    expect(await count('checkpoint_ack'), 0);
  });


  // An earlier row could previously be modified while the final checkpoint
  // stayed intact. Verify the entire *synthetic* history, not just the tail.
  for (final change in [
    'old_route', 'old_ack_digest', 'old_ack_id', 'old_gnss_nanos',
    'old_fare_header', 'old_recorded_at', 'broken_prior_link',
    'missing_history_row',
  ]) {
    test('history chain rejects earlier tampering: $change', () async {
      await send(0);
      await send(1);
      await send(2);
      final beforeLast = (await db.query('checkpoint_ack',
          where: 'sequence=?', whereArgs: [2])).single['checkpoint_id'];
      final beforeFare = worker.publishedFare;

      if (change == 'old_route') {
        await db.update('active_trip_route', {'latitude': 0.234},
            where: 'sequence=?', whereArgs: [0]);
      } else if (change == 'old_ack_digest') {
        await db.update('checkpoint_ack',
            {'sample_digest': List.filled(64, 'f').join()},
            where: 'sequence=?', whereArgs: [0]);
      } else if (change == 'old_ack_id') {
        await db.update('checkpoint_ack',
            {'checkpoint_id': 'old-checkpoint-tampered'},
            where: 'sequence=?', whereArgs: [0]);
      } else if (change == 'old_gnss_nanos') {
        await db.update('unified_checkpoint_history_test_only',
            {'gnss_nanos': fixes[0].gnssNanos + 1},
            where: 'sequence=?', whereArgs: [0]);
      } else if (change == 'old_fare_header') {
        final saved = (await db.query('unified_checkpoint_history_test_only',
            where: 'sequence=?', whereArgs: [0])).single;
        final header = Map<String, dynamic>.from(
            jsonDecode(saved['header_text'] as String) as Map);
        final meter = Map<String, dynamic>.from(header['meter'] as Map);
        meter['distanceMeters'] = 888.0;
        header['meter'] = meter;
        await db.update('unified_checkpoint_history_test_only',
            {'header_text': jsonEncode(header)},
            where: 'sequence=?', whereArgs: [0]);
      } else if (change == 'old_recorded_at') {
        await db.update('active_trip_route',
            {'recorded_at': '2026-11-15T09:00:08.000Z'},
            where: 'sequence=?', whereArgs: [0]);
      } else if (change == 'broken_prior_link') {
        await db.update('unified_checkpoint_history_test_only',
            {'prior_history_id': 'forged-prior'},
            where: 'sequence=?', whereArgs: [1]);
      } else if (change == 'missing_history_row') {
        await db.delete('unified_checkpoint_history_test_only',
            where: 'sequence=?', whereArgs: [0]);
      }

      await expectLater(UnifiedTestOnlyWorker.recoverPaused(db),
          throwsStateError);
      expect((await db.query('checkpoint_fence')).single['phase'],
          'TEST_ACTIVE'); // Recovery writes roll back on corruption.
      expect((await db.query('checkpoint_ack',
          where: 'sequence=?', whereArgs: [2])).single['checkpoint_id'],
          beforeLast);
      expect(worker.publishedFare, beforeFare);
      await expectLater(send(3), throwsStateError);
      expect(worker.gate.reason, 'commit_unknown');
      expect(await count('active_trip_route'), 3);
    });
  }

  test('history ledger SQL failure rolls back route+money+fence+ACK',
      () async {
    final originalHeader = await header();
    await db.execute('''CREATE TRIGGER fail_history_test
      BEFORE INSERT ON unified_checkpoint_history_test_only
      WHEN NEW.sequence=0
      BEGIN SELECT RAISE(ABORT, 'injected historical ledger fault'); END''');
    await expectLater(send(0), throwsStateError);
    expect(await header(), originalHeader);
    expect(await count('active_trip_route'), 0);
    expect(await count('checkpoint_ack'), 0);
    expect(await count('unified_checkpoint_history_test_only'), 0);
    expect((await db.query('checkpoint_fence')).single['last_sequence'], -1);
    expect(worker.publishedFare, syntheticStageTariff.baseFare);
  });

  test('recovery confirms chain across all checkpoints and PAUSES',
      () async {
    await Future.wait([send(0), send(1), send(2), send(3)]);
    expect(await count('unified_checkpoint_history_test_only'), 4);
    final linked = await db.query('unified_checkpoint_history_test_only',
        orderBy: 'sequence ASC');
    expect(linked.first['prior_history_id'], unifiedHistoryGenesis);
    for (var i = 1; i < linked.length; i++) {
      expect(linked[i]['prior_history_id'], linked[i - 1]['history_id']);
    }
    final previousFare = worker.publishedFare;
    final snapshot = await UnifiedTestOnlyWorker.recoverPaused(db);
    expect(snapshot.meter['distanceMeters'], worker.publishedMeters);
    expect(worker.publishedFare, previousFare);
    expect((await db.query('checkpoint_fence')).single['phase'], 'PAUSED');
    await expectLater(send(4), throwsStateError);
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
