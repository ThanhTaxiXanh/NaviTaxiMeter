// Issue #3 P4 follow-up: pure Dart regression tests for the test-only fork.
// Technical tariff values below are NOT confirmed driver fares.
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:navitaximeter/src/core/taximeter_engine.dart';

void main() {
  final t0 = DateTime.utc(2026, 11, 15, 9);
  const technicalTariff = TariffConfig(
    name: 'TEST ONLY - NOT A REAL FARE',
    baseFare: 12000,
    baseDistanceKm: 0,
    perKmRate: 10000,
    longDistanceThresholdKm: 30,
    longDistancePerKmRate: 8000,
    waitingFeePerHour: 3600,
    waitingGraceMinutes: 0.05, // Exactly three technical test seconds.
    roundToThousands: false,
  );

  GpsFix fix(int seconds, {double lat = 0, double speed = 0}) => GpsFix(
    latitude: lat, longitude: 0, accuracyMeters: 1, speedKmh: speed,
    timestamp: t0.add(Duration(seconds: seconds)),
  );

  test('fork preserves waiting grace across threshold without changing source',
      () {
    final published = TaximeterEngine(tariff: technicalTariff)
      ..start(at: t0);
    expect(published.acceptGps(fix(0)), isTrue);
    published.tick(t0.add(const Duration(seconds: 2)));
    expect(published.waitingSeconds, 0);
    final originalSnapshot = jsonEncode(published.exportSnapshot());

    final candidate = published.forkForCheckpoint();
    expect(candidate.acceptGps(fix(5)), isTrue);
    candidate.tick(t0.add(const Duration(seconds: 5)));
    expect(candidate.waitingSeconds, 2);
    expect(candidate.waitingFare, 2);
    expect(candidate.elapsedSeconds, 5);
    expect(published.waitingSeconds, 0);
    expect(published.elapsedSeconds, 2);
    expect(jsonEncode(published.exportSnapshot()), originalSnapshot);
  });

  test('fork preserves pending same-place stop grace after a missing fix',
      () {
    final published = TaximeterEngine(tariff: technicalTariff)
      ..start(at: t0);
    expect(published.acceptGps(fix(0)), isTrue);
    published.tick(t0.add(const Duration(seconds: 2)));
    published.skipUntrustedInterval(t0.add(const Duration(seconds: 4)));
    final candidate = published.forkForCheckpoint();
    final next = fix(6);

    // Compare the fork against the old engine receiving the exact same
    // subsequent technical observations; do NOT infer physical GPS safety.
    expect(candidate.acceptGps(next), isTrue);
    expect(published.acceptGps(next), isTrue);
    candidate.tick(t0.add(const Duration(seconds: 6)));
    published.tick(t0.add(const Duration(seconds: 6)));
    expect(candidate.waitingSeconds, published.waitingSeconds);
    expect(candidate.elapsedSeconds, published.elapsedSeconds);
    expect(candidate.totalFare, published.totalFare);
  });

  test('fork retains moving-versus-stationary state and tick parity', () {
    final published = TaximeterEngine(tariff: technicalTariff)
      ..start(at: t0);
    expect(published.acceptGps(fix(0, speed: 0)), isTrue);
    published.tick(t0.add(const Duration(seconds: 2)));
    final candidate = published.forkForCheckpoint();

    for (final meter in [published, candidate]) {
      expect(meter.acceptGps(fix(5, lat: 0.0003, speed: 25)), isTrue);
      meter.tick(t0.add(const Duration(seconds: 5)));
      expect(meter.acceptGps(fix(10, lat: 0.0006, speed: 0)), isTrue);
      meter.tick(t0.add(const Duration(seconds: 10)));
    }
    expect(candidate.waitingSeconds, published.waitingSeconds);
    expect(candidate.distanceMeters, published.distanceMeters);
    expect(candidate.totalFare, published.totalFare);
  });

  test('flat fare fork suppresses distance, wait and thousand rounding', () {
    final published = TaximeterEngine(
        tariff: technicalTariff.copyWith(roundToThousands: true))
      ..start(at: t0, fixedFare: 25450);
    published.addToll(30000);
    published.setAdjustments(surchargeFee: 5000, discountFee: 1000);
    final before = jsonEncode(published.exportSnapshot());

    final candidate = published.forkForCheckpoint()
      ..distanceMeters = 12000
      ..waitingSeconds = 3600;
    expect(candidate.distanceFare, 0);
    expect(candidate.waitingFare, 0);
    expect(candidate.totalFare, 59450);
    expect(published.totalFare, 59450);
    expect(published.distanceMeters, 0);
    expect(published.waitingSeconds, 0);
    expect(jsonEncode(published.exportSnapshot()), before);
  });

  test('fork freezes mutable tariff tier list separately from source', () {
    final sourceBands = <FareTier>[
      const FareTier(upToKm: 1, ratePerKm: 10000),
      const FareTier(upToKm: null, ratePerKm: 20000),
    ];
    final config = technicalTariff.copyWith(fareTiers: sourceBands);
    final published = TaximeterEngine(tariff: config)..start(at: t0);
    published.distanceMeters = 1500;
    final candidate = published.forkForCheckpoint();
    final before = candidate.totalFare;
    sourceBands[0] = const FareTier(upToKm: 1, ratePerKm: 90000);
    expect(candidate.tariff.fareTiers!.first.ratePerKm, 10000);
    expect(candidate.totalFare, before);
    expect(published.totalFare, isNot(before));
    expect(() => candidate.tariff.fareTiers!.add(
        const FareTier(upToKm: null, ratePerKm: 1)), throwsUnsupportedError);
  });

  test('cumulative progressive tiers in fork are not retroactive', () {
    final config = technicalTariff.copyWith(fareTiers: [
      const FareTier(upToKm: 1, ratePerKm: 10000),
      const FareTier(upToKm: 2, ratePerKm: 20000),
      const FareTier(upToKm: null, ratePerKm: 5000),
    ]);
    final published = TaximeterEngine(tariff: config)..start(at: t0);
    published.distanceMeters = 1500;
    expect(published.distanceFare, 20000);
    final candidate = published.forkForCheckpoint()..distanceMeters = 2500;
    expect(candidate.distanceFare, 32500);
    expect(candidate.totalFare, 44500);
    expect(published.distanceFare, 20000);
  });

  test('rounding to 1000 is computed on staged candidate only', () {
    final published = TaximeterEngine(tariff: technicalTariff.copyWith(
      baseFare: 12499, roundToThousands: true,
    ))..start(at: t0);
    expect(published.totalFare, 12000);
    final candidate = published.forkForCheckpoint()..addToll(1);
    expect(candidate.rawFare, 12500);
    expect(candidate.totalFare, 13000);
    expect(published.totalFare, 12000);
  });

  test('fork preserves interruption and forbids retroactive gap charges', () {
    final published = TaximeterEngine(tariff: technicalTariff)
      ..start(at: t0);
    expect(published.acceptGps(fix(0, speed: 20)), isTrue);
    published.tick(t0.add(const Duration(seconds: 5)));
    published.suspendForInterruption(
        at: t0.add(const Duration(seconds: 5)));
    final originalFare = published.totalFare;
    final originalSeconds = published.elapsedSeconds;
    final candidate = published.forkForCheckpoint();
    final fresh = t0.add(const Duration(hours: 4));
    candidate.tick(fresh);
    expect(candidate.requiresManualResume, isTrue);
    expect(candidate.elapsedSeconds, originalSeconds);
    expect(candidate.totalFare, originalFare);

    candidate.resume(at: fresh);
    expect(candidate.acceptGps(GpsFix(
      latitude: 0.01, longitude: 0, accuracyMeters: 1, speedKmh: 20,
      timestamp: fresh)), isTrue);
    expect(candidate.distanceMeters, 0); // Fresh baseline, not a gap bridge.
    final next = fresh.add(const Duration(seconds: 5));
    expect(candidate.acceptGps(GpsFix(
      latitude: 0.0103, longitude: 0, accuracyMeters: 1, speedKmh: 20,
      timestamp: next)), isTrue);
    candidate.tick(next);
    expect(candidate.elapsedSeconds, originalSeconds + 5);
    expect(candidate.distanceMeters, greaterThan(30));
    expect(published.status, MeterStatus.paused);
    expect(published.distanceMeters, 0);
    expect(published.totalFare, originalFare);
  });

  test('large discount cannot create negative fare on clone or original',
      () {
    final published = TaximeterEngine(tariff: technicalTariff)..start(at: t0);
    final candidate = published.forkForCheckpoint()
      ..setAdjustments(discountFee: 99000);
    expect(candidate.rawFare, 0);
    expect(candidate.totalFare, 0);
    expect(published.rawFare, 12000);
  });

  test('persisted candidate can only recover PAUSED without extra time', () {
    final published = TaximeterEngine(tariff: technicalTariff)
      ..start(at: t0);
    expect(published.acceptGps(fix(0, speed: 20)), isTrue);
    final candidate = published.forkForCheckpoint();
    expect(candidate.acceptGps(fix(5, lat: 0.0003, speed: 20)), isTrue);
    candidate.tick(t0.add(const Duration(seconds: 5)));
    final snapshot = candidate.exportSnapshot();
    final recovered = TaximeterEngine.fromSnapshot(
      tariff: candidate.tariff, snapshot: snapshot,
      recoveredAt: t0.add(const Duration(days: 1)),
    );
    expect(recovered.status, MeterStatus.paused);
    expect(recovered.requiresManualResume, isTrue);
    expect(recovered.totalFare, candidate.totalFare);
    expect(recovered.elapsedSeconds, 5);
    recovered.tick(t0.add(const Duration(days: 2)));
    expect(recovered.elapsedSeconds, 5);
    expect(published.elapsedSeconds, 0);
  });
}
