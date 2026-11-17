import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:navitaximeter/src/core/taximeter_engine.dart';
import 'package:navitaximeter/src/data/trip_repository.dart';

import 'support/issue3_staged_fare_checkpoint.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });
  final t0 = DateTime.utc(2026, 11, 15, 9, 0);
  late Directory sandbox;
  late TestOnlyFareStage stage;

  setUp(() async {
    sandbox = await Directory.systemTemp.createTemp('navi-fare-stage-');
    stage = await TestOnlyFareStage.begin(sandbox: sandbox, at: t0);
  });

  tearDown(() async {
    await stage.repository.dispose();
    if (await sandbox.exists()) await sandbox.delete(recursive: true);
  });

  GpsFix fix(int sequence, {
    double? latitude, double accuracy = 1, double speed = 20,
  }) => GpsFix(
    latitude: latitude ?? sequence * 0.0003, longitude: 0,
    accuracyMeters: accuracy, speedKmh: speed,
    timestamp: t0.add(Duration(seconds: sequence * 5)),
  );

  Future<int> durableCount() async =>
      (await stage.readDurable()).routePoints.length;

  test('meter fork preserves private GNSS anchor and isolates uncommitted fare',
      () {
    final original = TaximeterEngine(tariff: syntheticStageTariff)
      ..start(at: t0);
    expect(original.acceptGps(fix(0)), isTrue);
    original.tick(t0.add(const Duration(seconds: 3)));
    final beforeJson = jsonEncode(original.exportSnapshot());
    final candidate = original.forkForCheckpoint();
    expect(candidate.acceptGps(fix(1)), isTrue);
    candidate.tick(t0.add(const Duration(seconds: 5)));
    candidate.addToll(7000); // Synthetic test-only mutation.
    expect(candidate.distanceMeters, greaterThan(30));
    expect(candidate.elapsedSeconds, 5);
    expect(original.distanceMeters, 0);
    expect(original.elapsedSeconds, 3);
    expect(original.totalFare, 10000);
    expect(jsonEncode(original.exportSnapshot()), beforeJson);
  });

  test('candidate is invisible until sqflite transaction Future completes',
      () async {
    final entered = Completer<void>();
    final release = Completer<void>();
    final before = stage.publishedFare;
    final operation = stage.stageAndCommit(
      fix: fix(1), receivedAt: fix(1).timestamp,
      beforeWrite: () async {
        entered.complete();
        await release.future;
      },
    );
    await entered.future;
    expect(stage.publishedFare, before);
    expect(stage.publishedDistanceMeters, 0);
    expect(stage.publishedElapsed, 0);
    expect(await durableCount(), 1);
    release.complete();
    expect(await operation, isTrue);
    expect(stage.publishedFare, greaterThan(before));
    final durable = await stage.readDurable();
    expect(durable.routePoints.length, 2);
    expect(durable.meter['distanceMeters'], stage.publishedDistanceMeters);
    expect(durable.meter['elapsedSeconds'], stage.publishedElapsed);
  });

  test('successful checkpoint publishes exactly the committed fare/time/km',
      () async {
    expect(await stage.stageAndCommit(
        fix: fix(1), receivedAt: fix(1).timestamp), isTrue);
    final stored = await stage.readDurable();
    expect(stored.routePoints.length, 2);
    expect(stored.meter['distanceMeters'], closeTo(33.35, 1));
    expect(stored.meter['elapsedSeconds'], 5);
    final reconstructedFare = TaximeterEngine.fromSnapshot(
        tariff: stored.tariff, snapshot: stored.meter, recoveredAt: t0)
        .totalFare;
    expect(stage.publishedFare, reconstructedFare);
    expect(stored.tariff.name, syntheticStageTariff.name);
  });

  test('route insert failure rolls back candidate, meter, and checkpoint',
      () async {
    final originalFare = stage.publishedFare;
    final original = await stage.readDurable();
    final admin = await openDatabase(path.join(sandbox.path, stageFixtureName),
        singleInstance: false);
    try {
      await admin.execute('''CREATE TRIGGER fail_test_route
        BEFORE INSERT ON active_trip_route WHEN NEW.sequence=1
        BEGIN SELECT RAISE(ABORT, 'injected route error'); END''');
    } finally {
      await admin.close();
    }
    await expectLater(stage.stageAndCommit(
        fix: fix(1), receivedAt: fix(1).timestamp),
        throwsA(isA<DatabaseException>()));
    expect(stage.faulted, isTrue);
    expect(stage.publishedFare, originalFare);
    expect(stage.publishedDistanceMeters, 0);
    expect(stage.publishedElapsed, 0);
    final saved = await stage.readDurable();
    expect(saved.meter, original.meter);
    expect(saved.routePoints.length, 1);
    await expectLater(stage.stageAndCommit(
        fix: fix(2), receivedAt: fix(2).timestamp), throwsStateError);
  });

  test('header update failure also restores inserted route and old fare',
      () async {
    final before = await stage.readDurable();
    final admin = await openDatabase(path.join(sandbox.path, stageFixtureName),
        singleInstance: false);
    try {
      // TripRepository uses INSERT OR REPLACE for active_trip, NOT UPDATE.
      // Trigger the actual header write after route insert.
      await admin.execute('''CREATE TRIGGER fail_test_header
        BEFORE INSERT ON active_trip WHEN NEW.id=1
        BEGIN SELECT RAISE(ABORT, 'injected header replace error'); END''');
    } finally {
      await admin.close();
    }
    await expectLater(stage.stageAndCommit(
        fix: fix(1), receivedAt: fix(1).timestamp),
        throwsA(isA<DatabaseException>()));
    expect(stage.faulted, isTrue);
    expect(stage.publishedFare, syntheticStageTariff.baseFare);
    final durable = await stage.readDurable();
    expect(durable.meter, before.meter);
    expect(durable.routePoints.length, 1);
  });

  test('synthetic failure before writing never publishes candidate',
      () async {
    final old = stage.publishedSnapshot;
    await expectLater(stage.stageAndCommit(
      fix: fix(1), receivedAt: fix(1).timestamp,
      beforeWrite: () async => throw StateError('injected prewrite failure'),
    ), throwsStateError);
    expect(stage.faulted, isTrue);
    expect(stage.publishedSnapshot, old);
    expect(await durableCount(), 1);
  });

  test('eight queued requests do not publish out of order', () async {
    final accepted = await Future.wait(List.generate(8, (i) =>
        stage.stageAndCommit(fix: fix(i + 1),
            receivedAt: fix(i + 1).timestamp)));
    expect(accepted, everyElement(isTrue));
    expect(await durableCount(), 9);
    expect(stage.publishedElapsed, 40);
    final stored = await stage.readDurable();
    expect(stored.meter['distanceMeters'], stage.publishedDistanceMeters);
    expect(stored.meter['elapsedSeconds'], stage.publishedElapsed);
    expect(stage.publishedFare, greaterThan(syntheticStageTariff.baseFare));
  });

  test('stale fix and implausible location never change published state',
      () async {
    final before = stage.publishedSnapshot;
    expect(await stage.stageAndCommit(
        fix: fix(0), receivedAt: t0), isFalse);
    expect(await stage.stageAndCommit(
        fix: fix(1, latitude: 95), receivedAt: fix(1).timestamp), isFalse);
    expect(stage.publishedSnapshot, before);
    expect(await durableCount(), 1);
    expect(stage.faulted, isFalse);
    expect(await stage.stageAndCommit(
        fix: fix(1), receivedAt: fix(1).timestamp), isTrue);
  });

  test('restarted meter reloads only committed state as PAUSED; no gap fee',
      () async {
    await stage.stageAndCommit(fix: fix(1), receivedAt: fix(1).timestamp);
    final before = stage.publishedFare;
    final repository = TripRepository(
        databasePath: path.join(sandbox.path, stageFixtureName));
    try {
      final loaded = await repository.loadActive();
      expect(loaded, isNotNull);
      final snapshot = await stage.readDurable();
      final recovered = snapshot.restore(
          at: t0.add(const Duration(hours: 6)));
      expect(recovered.status, MeterStatus.paused);
      expect(recovered.requiresManualResume, isTrue);
      expect(recovered.totalFare, before);
      expect(recovered.elapsedSeconds, 5);
      expect(snapshot.routePoints.length, 2);
    } finally {
      await repository.dispose();
    }
  });

  test('wrong sandbox directory cannot open any actual app DB',
      () async {
    final wrong = await Directory.systemTemp.createTemp('other-fare-test-');
    try {
      await expectLater(TestOnlyFareStage.begin(sandbox: wrong, at: t0),
          throwsStateError);
      expect(await File(path.join(wrong.path, 'navitaximeter_v1.db')).exists(),
          isFalse);
    } finally {
      await wrong.delete(recursive: true);
    }
  });
}
