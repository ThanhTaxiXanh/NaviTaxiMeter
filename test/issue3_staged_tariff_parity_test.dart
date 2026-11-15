// Issue #3: pricing parity persisted by actual TripRepository, disposable DB.
// All GPS positions and tariffs are synthetic. Not a passenger metering test.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:navitaximeter/src/core/taximeter_engine.dart';

import 'support/issue3_staged_fare_checkpoint.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  final t0 = DateTime.utc(2026, 11, 15, 9);
  late Directory sandbox;
  TestOnlyFareStage? active;

  setUp(() async {
    sandbox = await Directory.systemTemp.createTemp('navi-fare-stage-');
    active = null;
  });

  tearDown(() async {
    if (active != null) await active!.repository.dispose();
    if (await sandbox.exists()) await sandbox.delete(recursive: true);
  });

  Future<TestOnlyFareStage> start(TariffConfig tariff,
      {double? fixedFare}) async {
    active = await TestOnlyFareStage.begin(
        sandbox: sandbox, at: t0, tariff: tariff, fixedFare: fixedFare);
    return active!;
  }

  GpsFix fix(int seq, {double speed = 20}) => GpsFix(
    latitude: seq * 0.0003, longitude: 0,
    accuracyMeters: 1, speedKmh: speed,
    timestamp: t0.add(Duration(seconds: seq * 5)),
  );

  Future<void> commit(TestOnlyFareStage s, int seq,
      {double speed = 20}) async {
    final gps = fix(seq, speed: speed);
    expect(await s.stageAndCommit(fix: gps, receivedAt: gps.timestamp),
        isTrue);
  }

  test('waiting grace from five to ten trusted seconds survives COMMIT',
      () async {
    final tariff = syntheticStageTariff.copyWith(
        waitingFeePerHour: 3600, waitingGraceMinutes: 5 / 60);
    final s = await start(tariff);
    await commit(s, 1, speed: 0); // First five seconds are still grace.
    var durable = await s.readDurable();
    expect(durable.meter['waitingSeconds'], 0);
    final fareBefore = s.publishedFare;

    await commit(s, 2, speed: 0); // Five subsequent trusted seconds billed.
    durable = await s.readDurable();
    expect(durable.meter['waitingSeconds'], 5);
    expect(durable.meter['elapsedSeconds'], 10);
    expect(s.publishedFare, greaterThan(fareBefore));
    expect(durable.restore(at: t0.add(const Duration(hours: 2))).totalFare,
        s.publishedFare);
    expect(durable.tariff.waitingGraceMinutes, closeTo(5 / 60, 0.000001));
  });

  test('flat fare remains fixed after distance/time COMMIT, no rounding',
      () async {
    final tariff = syntheticStageTariff.copyWith(
        waitingFeePerHour: 3600, waitingGraceMinutes: 0,
        roundToThousands: true);
    final s = await start(tariff, fixedFare: 43210);
    expect(s.publishedFare, 43210);
    await commit(s, 1, speed: 0);
    await commit(s, 2, speed: 0);
    final durable = await s.readDurable();
    expect(durable.meter['flatFare'], 43210);
    expect(durable.meter['waitingSeconds'], 10);
    expect(durable.meter['distanceMeters'], greaterThan(60));
    expect(s.publishedFare, 43210);
    final restored = durable.restore(
        at: t0.add(const Duration(days: 1)));
    expect(restored.totalFare, 43210);
    expect(restored.distanceFare, 0);
    expect(restored.waitingFare, 0);
  });

  test('two progressive tier bands and thousand-rounding match stored fare',
      () async {
    final tariff = syntheticStageTariff.copyWith(
      baseFare: 12100, roundToThousands: true,
      fareTiers: [
        const FareTier(upToKm: 0.05, ratePerKm: 10000),
        const FareTier(upToKm: null, ratePerKm: 20000),
      ],
    );
    final s = await start(tariff);
    expect(s.publishedFare, 12000);
    await commit(s, 1);
    expect(s.publishedFare, 12000); // 33 m still below 12,500 threshold.
    await commit(s, 2);
    expect(s.publishedFare, 13000); // 66 m crosses tier + rounding threshold.
    final durable = await s.readDurable();
    expect(durable.tariff.fareTiers!.length, 2);
    expect(durable.meter['distanceMeters'], greaterThan(60));
    final restored = durable.restore(at: t0.add(const Duration(hours: 3)));
    expect(restored.totalFare, s.publishedFare);
    expect(restored.requiresManualResume, isTrue);
  });

  test('route write error cannot expose a new rounded or tiered fare',
      () async {
    final tariff = syntheticStageTariff.copyWith(
      baseFare: 12100, roundToThousands: true,
      fareTiers: [
        const FareTier(upToKm: 0.05, ratePerKm: 10000),
        const FareTier(upToKm: null, ratePerKm: 20000),
      ],
    );
    final s = await start(tariff);
    final original = s.publishedFare;
    final admin = await openDatabase(path.join(sandbox.path, stageFixtureName),
        singleInstance: false);
    try {
      await admin.execute('''CREATE TRIGGER fail_tier_stage_route
        BEFORE INSERT ON active_trip_route WHEN NEW.sequence=1
        BEGIN SELECT RAISE(ABORT, 'simulated write fail'); END''');
    } finally {
      await admin.close();
    }
    final f = fix(1);
    await expectLater(s.stageAndCommit(fix: f, receivedAt: f.timestamp),
        throwsA(isA<DatabaseException>()));
    expect(s.faulted, isTrue);
    expect(s.publishedFare, original);
    final durable = await s.readDurable();
    expect(durable.routePoints.length, 1);
    expect(durable.meter['distanceMeters'], 0);
    expect(durable.restore().totalFare, original);
  });

  test('stale tick or large GPS gap never publishes a new tariff amount',
      () async {
    final tariff = syntheticStageTariff.copyWith(
        waitingFeePerHour: 3600, waitingGraceMinutes: 0);
    final s = await start(tariff);
    final before = s.publishedFare;
    final old = fix(0);
    expect(await s.stageAndCommit(fix: old, receivedAt: old.timestamp),
        isFalse);
    final late = GpsFix(
      latitude: 0.0003, longitude: 0, accuracyMeters: 1, speedKmh: 0,
      timestamp: t0.add(const Duration(minutes: 2)));
    expect(await s.stageAndCommit(
        fix: late, receivedAt: late.timestamp), isFalse);
    expect(s.publishedFare, before);
    expect((await s.readDurable()).routePoints.length, 1);
    expect(s.faulted, isFalse);
  });
}
