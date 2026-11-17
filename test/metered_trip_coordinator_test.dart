import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:navitaximeter/src/core/metered_trip_coordinator.dart';
import 'package:navitaximeter/src/core/taximeter_engine.dart';
import 'package:navitaximeter/src/data/trip_repository.dart';
import 'package:navitaximeter/src/data/trip_session_snapshot.dart';
import 'package:navitaximeter/src/domain/confirmed_tariffs.dart';
import 'package:navitaximeter/src/domain/trip_record.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  final start = DateTime.utc(2026, 11, 15, 9);
  late Directory dir;
  late TripRepository repository;
  late MeteredTripCoordinator meter;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('navi-meter-coordinator-');
    repository = TripRepository(
      databasePath: path.join(dir.path, 'session.db'),
    );
    meter = MeteredTripCoordinator(repository: repository);
  });

  tearDown(() async {
    await repository.dispose();
    await dir.delete(recursive: true);
  });

  ConfirmedTariff verifiedFare() => ConfirmedTariff(
    id: 'driver-verified',
    confirmedAtUtc: start,
    tariff: const TariffConfig(
      name: 'Bảng giá tài xế đã kiểm tra',
      baseFare: 12000,
      baseDistanceKm: 0.5,
      perKmRate: 15000,
      longDistanceThresholdKm: 30,
      longDistancePerKmRate: 12000,
      waitingFeePerHour: 36000,
      roundToThousands: false,
    ),
  );

  MeterGpsObservation reading(int seconds, {
    double lat = 21.0,
    bool mocked = false,
    bool service = true,
    int ageSeconds = 0,
  }) {
    final at = start.add(Duration(seconds: seconds));
    return MeterGpsObservation(
      fix: GpsFix(
        latitude: lat,
        longitude: 105.8,
        accuracyMeters: 5,
        speedKmh: 25,
        timestamp: at.subtract(Duration(seconds: ageSeconds)),
      ),
      receivedAt: at,
      isMocked: mocked,
      foregroundStreamActive: service,
    );
  }

  test('cannot start without foreground stream and fresh real GPS', () async {
    await expectLater(
      meter.begin(tariff: verifiedFare(), initial: reading(0, service: false)),
      throwsStateError,
    );
    await expectLater(
      meter.begin(tariff: verifiedFare(), initial: reading(0, mocked: true)),
      throwsStateError,
    );
    await expectLater(
      meter.begin(tariff: verifiedFare(), initial: reading(0, ageSeconds: 90)),
      throwsStateError,
    );
    expect(await repository.loadActive(), isNull);
    expect(meter.hasSession, false);
  });

  test('trusted fixes checkpoint both fare and ordered GPS route', () async {
    await meter.begin(tariff: verifiedFare(), initial: reading(0));
    expect(await meter.accept(reading(5, lat: 21.0001)), true);
    expect(await meter.accept(reading(10, lat: 21.0002)), true);
    final saved = TripSessionSnapshot.decode((await repository.loadActive())!);
    expect(saved.routePoints.length, 3);
    expect(saved.meter['elapsedSeconds'], 10);
    expect(saved.meter['distanceMeters'], greaterThan(15));
    expect(meter.recordedRoute.length, 3);
    expect(saved.routePoints.every((p) => p.segment == 0), true);
  });

  test('GPS blackout suspends without bridge, requires manual restart', () async {
    await meter.begin(tariff: verifiedFare(), initial: reading(0));
    await meter.accept(reading(5, lat: 21.0001));
    final distanceBefore = meter.distanceKmForTesting;
    final timeBefore = meter.elapsedSecondsForTesting;
    expect(await meter.accept(reading(40, lat: 21.03)), false);
    expect(meter.requiresManualResume, true);
    expect(meter.distanceKmForTesting, distanceBefore);
    expect(meter.elapsedSecondsForTesting, timeBefore);
    final paused = TripSessionSnapshot.decode((await repository.loadActive())!);
    expect(paused.routePoints.length, 2);
    expect(paused.meter['interrupted'], true);

    await meter.resume(reading(41, lat: 21.03));
    expect(meter.distanceKmForTesting, distanceBefore);
    expect(await meter.accept(reading(46, lat: 21.0301)), true);
    expect(meter.recordedRoute.map((p) => p.segment), [0, 0, 1, 1]);
    final completed = await meter.finish(
      at: start.add(const Duration(seconds: 60)), driverConfirmed: true);
    expect(completed.receipt.durationSeconds, 10);
    expect(await repository.loadActive(), isNull);
    expect((await repository.listTrips()).length, 1);
    expect((await repository.listTrips()).single.routePoints.length, 4);
  });

  test('watchdog only suspends and never earns clock-only waiting fee', () async {
    await meter.begin(tariff: verifiedFare(), initial: reading(0));
    final initial = meter.fareForTesting;
    expect(await meter.watchdog(
      at: start.add(const Duration(seconds: 32)),
      foregroundStreamActive: true), true);
    expect(meter.fareForTesting, initial);
    expect(meter.elapsedSecondsForTesting, 0);
    expect(meter.requiresManualResume, true);
    await expectLater(meter.resume(reading(50, mocked: true)), throwsStateError);
  });

  test('app restart restores original tariff and pauses without retroactive fees',
      () async {
    await meter.begin(tariff: verifiedFare(), initial: reading(0));
    await meter.accept(reading(6, lat: 21.0001));
    final fareBefore = meter.fareForTesting;
    await repository.dispose();

    repository = TripRepository(databasePath: path.join(dir.path, 'session.db'));
    meter = MeteredTripCoordinator(repository: repository);
    expect(await meter.recover(at: start.add(const Duration(hours: 2))), true);
    expect(meter.requiresManualResume, true);
    expect(meter.fareForTesting, fareBefore);
    expect(meter.elapsedSecondsForTesting, 6);
    expect(meter.recordedRoute.length, 2);
    final record = await meter.finish(
      at: start.add(const Duration(hours: 2, seconds: 1)),
      driverConfirmed: true,
    );
    expect(record.receipt.durationSeconds, 6);
    expect(record.tariffSnapshot?.name, 'Bảng giá tài xế đã kiểm tra');
    expect(await repository.loadActive(), isNull);
  });

  test('finish needs driver confirmation and receipt is immutable/idempotent',
      () async {
    await meter.begin(tariff: verifiedFare(), initial: reading(0));
    await expectLater(
      meter.finish(at: start.add(const Duration(seconds: 5)),
          driverConfirmed: false),
      throwsStateError,
    );
    final record = await meter.finish(
      at: start.add(const Duration(seconds: 5)), driverConfirmed: true);
    await repository.completeActive(record);
    expect((await repository.listTrips()).length, 1);
    final conflicting = TripRecord(
      id: record.id,
      receipt: record.receipt,
      pickup: 'Không được thay hóa đơn đã lưu',
      routePoints: record.routePoints,
    );
    await expectLater(repository.completeActive(conflicting), throwsStateError);
    expect((await repository.listTrips()).length, 1);
    await expectLater(
      meter.finish(at: start.add(const Duration(seconds: 7)),
          driverConfirmed: true),
      throwsStateError,
    );
  });

  test('wrong checkpoint identity never allows finalizing another trip',
      () async {
    await meter.begin(tariff: verifiedFare(), initial: reading(0));
    final foreignMeter = TaximeterEngine(tariff: verifiedFare().tariff)
      ..start(at: start.subtract(const Duration(days: 1)));
    final other = TripRecord.fromReceipt(foreignMeter.finish(
      at: start.subtract(const Duration(hours: 23))));
    await expectLater(repository.completeActive(other), throwsStateError);
    expect(await repository.loadActive(), isNotNull);
    expect(await repository.listTrips(), isEmpty);
  });
}
