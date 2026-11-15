import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'support/issue3_sqflite_clone_writer.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  late Directory sandbox;
  late Database db;
  late CloneAckWriter writer;

  setUp(() async {
    sandbox = await Directory.systemTemp.createTemp('navi-sqflite-appclone-');
    final v3 = await createV3Fixture(sandbox);
    await v3.close(); // Never copy a live WAL-connected database.
    db = await dryRunCloneV4(sandbox);
    writer = CloneAckWriter(db);
  });

  tearDown(() async {
    if (db.isOpen) await db.close();
    if (await sandbox.exists()) await sandbox.delete(recursive: true);
  });

  CloneFix fix(int seq, {
    int? nanos, double speed = 0.0, bool mocked = false,
    String tariff = frozenTestTariffHash,
  }) => CloneFix(
    sequence: seq,
    gnssNanos: nanos ?? 10000000000 + seq * 1000000000,
    speed: speed,
    mocked: mocked,
    tariffHash: tariff,
  );

  Future<int> routeCount() async => Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM active_trip_route'))!;
  Future<int> ackCount() async => Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM checkpoint_ack'))!;
  Future<String> header() async =>
      (await db.query('active_trip', columns: ['payload'])).single['payload'] as String;
  Future<int> durableSeq() async =>
      (await db.query('checkpoint_fence')).single['last_sequence'] as int;

  test('v3 source unchanged by v4 dry-run; receipt preserved', () async {
    final v3 = await openDatabase(path.join(sandbox.path, v3FixtureName),
        readOnly: true, singleInstance: false);
    try {
      expect(Sqflite.firstIntValue(await v3.rawQuery('PRAGMA user_version')), 3);
      expect((await v3.query('trips')).single['id'], 'TEST_RECEIPT_ONLY');
      final names = (await v3.rawQuery(
          "SELECT name FROM sqlite_master WHERE type='table'"))
          .map((row) => row['name']).toSet();
      expect(names.contains('checkpoint_fence'), isFalse);
      expect(names.contains('checkpoint_ack'), isFalse);
    } finally {
      await v3.close();
    }
    expect(Sqflite.firstIntValue(await db.rawQuery('PRAGMA user_version')), 4);
    expect((await db.query('trips')).single['payload'],
        '{"fixtureOnly":true,"receipt":"preserve"}');
    expect(await routeCount(), 0);
  });

  test('injected v3->v4 upgrade error rolls back table and version', () async {
    await expectLater(dryRunCloneV4(sandbox, injectFailure: true),
        throwsStateError);
    final failed = await openDatabase(path.join(sandbox.path, v4FailureName),
        readOnly: true, singleInstance: false);
    try {
      expect(Sqflite.firstIntValue(await failed.rawQuery('PRAGMA user_version')), 3);
      final tables = (await failed.rawQuery(
          "SELECT name FROM sqlite_master WHERE type='table'"))
          .map((row) => row['name']).toSet();
      expect(tables.contains('checkpoint_fence'), isFalse);
      expect(tables.contains('checkpoint_ack'), isFalse);
      expect((await failed.query('trips')).single['id'], 'TEST_RECEIPT_ONLY');
    } finally {
      await failed.close();
    }
  });

  test('real sqflite ACK after transaction, persists after close/reopen',
      () async {
    final ack = await writer.append(fix(0));
    expect(ack.sequence, 0);
    expect(ack.id, isNotEmpty);
    expect(await routeCount(), 1);
    expect(await ackCount(), 1);
    expect(await durableSeq(), 0);
    await db.close();
    final reopened = await openDatabase(path.join(sandbox.path, v4FixtureName),
        readOnly: true, singleInstance: false);
    try {
      expect((await reopened.query('checkpoint_ack')).single['checkpoint_id'],
          ack.id);
      expect((await reopened.query('trips')).single['id'], 'TEST_RECEIPT_ONLY');
    } finally {
      await reopened.close();
    }
  });

  test('after-route error rolls back header, route, fence and ACK together',
      () async {
    final original = await header();
    await expectLater(writer.append(fix(0), failAt: CloneFailAt.afterRoute),
        throwsStateError);
    expect(await routeCount(), 0);
    expect(await ackCount(), 0);
    expect(await durableSeq(), -1);
    expect(await header(), original);
    expect(writer.suspended, isTrue);
    await expectLater(writer.append(fix(0)), throwsStateError);
  });

  test('before-ledger error rolls back staged header and all new rows',
      () async {
    final original = await header();
    await expectLater(writer.append(fix(0), failAt: CloneFailAt.beforeLedger),
        throwsStateError);
    expect(await header(), original);
    expect(await routeCount(), 0);
    expect(await ackCount(), 0);
    expect(await durableSeq(), -1);
    expect((await db.query('trips')).single['id'], 'TEST_RECEIPT_ONLY');
  });

  test('eight parallel submissions serialize and retain zero fixture fare',
      () async {
    final results = await Future.wait(
        List.generate(8, (i) => writer.append(fix(i))));
    expect(results.map((r) => r.sequence).toList(), [0,1,2,3,4,5,6,7]);
    expect(await routeCount(), 8);
    expect(await ackCount(), 8);
    expect(await durableSeq(), 7);
    final raw = await header();
    expect(raw.contains('"routeCount":8'), isTrue);
    expect(raw.contains('"totalFare":0'), isTrue);
    expect(raw.contains('"distanceMeters":0'), isTrue);
    expect((await db.query('trips')).length, 1);
  });

  test('eight exact replays yield one durable row and one ledger entry',
      () async {
    final acks = await Future.wait(
        List.generate(8, (_) => writer.append(fix(0))));
    expect(acks.map((a) => a.id).toSet().length, 1);
    expect(await routeCount(), 1);
    expect(await ackCount(), 1);
    expect(writer.suspended, isFalse);
  });

  test('conflicting duplicate cannot overwrite the last saved fix',
      () async {
    final original = await writer.append(fix(0));
    await expectLater(writer.append(fix(0, speed: 10)), throwsStateError);
    expect(await routeCount(), 1);
    expect(await ackCount(), 1);
    expect((await db.query('checkpoint_ack')).single['checkpoint_id'],
        original.id);
    expect(writer.suspended, isTrue);
  });

  test('old generation rejected without poisoning current fence', () async {
    await expectLater(writer.append(fix(0), generation: 6), throwsStateError);
    expect(writer.suspended, isFalse);
    await writer.append(fix(0));
    expect(await durableSeq(), 0);
  });

  test('GNSS discontinuity suspends without an extra row', () async {
    await writer.append(fix(0));
    await expectLater(writer.append(fix(1, nanos: 25000000000)),
        throwsStateError);
    expect(writer.suspended, isTrue);
    expect(await routeCount(), 1);
    expect(await ackCount(), 1);
  });

  test('mock and tariff mismatch never create a checkpoint', () async {
    await expectLater(writer.append(fix(0, mocked: true)), throwsStateError);
    expect(await routeCount(), 0);
    expect(await ackCount(), 0);
  });

  test('commit can succeed while ACK callback is lost; recovery PAUSED',
      () async {
    await expectLater(writer.append(fix(0), loseAckAfterCommit: true),
        throwsStateError);
    expect(await routeCount(), 1);
    expect(await ackCount(), 1);
    expect(writer.suspended, isTrue);
    await expectLater(writer.append(fix(1)), throwsStateError);
    final state = await writer.recoverPaused();
    expect(state['phase'], 'PAUSED');
    expect(state['sequence'], 0);
    expect((await db.query('checkpoint_fence')).single['phase'], 'PAUSED');
  });

  test('corrupted ledger stops recovery, never invents missing ACK',
      () async {
    await writer.append(fix(0));
    await db.delete('checkpoint_ack');
    await expectLater(writer.recoverPaused(), throwsStateError);
    expect(writer.suspended, isTrue);
    expect(await routeCount(), 1);
    expect(await ackCount(), 0);
  });

  test('only isolated temp names accepted; production path refused', () async {
    final wrong = await Directory.systemTemp.createTemp('other-test-folder-');
    try {
      await expectLater(createV3Fixture(wrong), throwsStateError);
      expect(await File(path.join(wrong.path, 'navitaximeter_v1.db')).exists(),
          isFalse);
    } finally {
      await wrong.delete(recursive: true);
    }
  });
}
