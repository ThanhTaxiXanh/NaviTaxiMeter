// Issue #3 P2: tests only. Synthetic GPS, fake tariff and disposable SQLite v3.
// Production coordinator is still NOT approved for passenger fares.
import 'dart:async';
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
import 'package:navitaximeter/src/domain/trip_route_point.dart';

class _BlockingCheckpointRepository extends TripRepository {
  _BlockingCheckpointRepository({required super.databasePath});

  Future<void> Function()? beforeCheckpoint;

  @override
  Future<void> saveActiveIncremental({
    required TripSessionSnapshot snapshot,
    required int routeStartIndex,
    required List<TripRoutePoint> appendedPoints,
  }) async {
    if (beforeCheckpoint != null) await beforeCheckpoint!();
    await super.saveActiveIncremental(
      snapshot: snapshot, routeStartIndex: routeStartIndex,
      appendedPoints: appendedPoints,
    );
  }
}

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  final start = DateTime.utc(2026, 11, 15, 9);
  late Directory sandbox;
  late _BlockingCheckpointRepository repository;
  late MeteredTripCoordinator coordinator;
  late Database raw;

  ConfirmedTariff testTariff() => ConfirmedTariff(
    id: 'TEST_ONLY_CONFIRMED',
    confirmedAtUtc: start,
    tariff: const TariffConfig(
      name: 'Synthetic fixture; NOT a passenger tariff',
      baseFare: 12000, baseDistanceKm: 0.5,
      perKmRate: 15000, longDistanceThresholdKm: 30,
      longDistancePerKmRate: 12000, waitingFeePerHour: 36000,
    ),
  );

  MeterGpsObservation fix(int secs, {double latitude = 21.0}) {
    final at = start.add(Duration(seconds: secs));
    return MeterGpsObservation(
      fix: GpsFix(
        latitude: latitude, longitude: 105.8, accuracyMeters: 5,
        speedKmh: 25, timestamp: at,
      ),
      receivedAt: at, isMocked: false, foregroundStreamActive: true,
    );
  }

  Future<String> persisted() async => (await repository.loadActive())!;
  Future<void> begin() async {
    await coordinator.begin(tariff: testTariff(), initial: fix(0));
  }
  Future<void> blockNextRoute(int sequence) async {
    await raw.execute('''CREATE TRIGGER block_route_test_only
      BEFORE INSERT ON active_trip_route WHEN NEW.sequence=$sequence
      BEGIN SELECT RAISE(ABORT, 'TEST_ONLY route fail'); END''');
  }

  setUp(() async {
    sandbox = await Directory.systemTemp.createTemp('navi-coordinator-cow-');
    repository = _BlockingCheckpointRepository(
      databasePath: path.join(sandbox.path, 'DISPOSABLE_V3_ONLY.db'),
    );
    coordinator = MeteredTripCoordinator(repository: repository);
    expect(await repository.loadActive(), isNull); // Open a fresh v3 DB.
    raw = await openDatabase(
      path.join(sandbox.path, 'DISPOSABLE_V3_ONLY.db'),
      singleInstance: false,
    );
  });

  tearDown(() async {
    await raw.close();
    await repository.dispose();
    if (await sandbox.exists()) await sandbox.delete(recursive: true);
  });

  test('accept() never publishes staged distance while SQLite is pending',
      () async {
    await begin();
    final beforeHeader = await persisted();
    final beforeDistance = coordinator.distanceKmForTesting;
    final beforeTime = coordinator.elapsedSecondsForTesting;
    final entered = Completer<void>(), unblock = Completer<void>();
    repository.beforeCheckpoint = () async {
      entered.complete();
      await unblock.future;
    };
    final pending = coordinator.accept(fix(5, latitude: 21.0002));
    await entered.future;
    expect(coordinator.distanceKmForTesting, beforeDistance);
    expect(coordinator.elapsedSecondsForTesting, beforeTime);
    expect(coordinator.recordedRoute.length, 1);
    expect(await persisted(), beforeHeader);
    unblock.complete();
    expect(await pending, true);
    expect(coordinator.distanceKmForTesting, greaterThan(beforeDistance));
    expect(coordinator.elapsedSecondsForTesting, 5);
    expect(coordinator.recordedRoute.length, 2);
    expect(TripSessionSnapshot.decode(await persisted()).meter['distanceMeters'],
        greaterThan(15));
  });

  test('accept() route SQL failure preserves last durable money/route',
      () async {
    await begin();
    expect(await coordinator.accept(fix(5, latitude: 21.0002)), true);
    final before = await persisted();
    final money = coordinator.fareForTesting;
    final distance = coordinator.distanceKmForTesting;
    final time = coordinator.elapsedSecondsForTesting;
    await blockNextRoute(2);
    await expectLater(coordinator.accept(fix(10, latitude: 21.0004)),
        throwsStateError);
    expect(coordinator.storageFaulted, true);
    expect(coordinator.status, MeterStatus.paused);
    expect(coordinator.fareForTesting, money);
    expect(coordinator.distanceKmForTesting, distance);
    expect(coordinator.elapsedSecondsForTesting, time);
    expect(coordinator.recordedRoute.length, 2);
    expect(await persisted(), before);
    await expectLater(coordinator.accept(fix(15)), throwsStateError);

    final restarted = MeteredTripCoordinator(repository: repository);
    expect(await restarted.recover(at: start.add(const Duration(hours: 1))),
        true);
    expect(restarted.status, MeterStatus.paused);
    expect(restarted.requiresManualResume, true);
    expect(restarted.distanceKmForTesting, distance);
  });

  test('suspend() failed header INSERT cannot charge or alter durable state',
      () async {
    await begin();
    final before = await persisted();
    final money = coordinator.fareForTesting;
    final time = coordinator.elapsedSecondsForTesting;
    await raw.execute('''CREATE TRIGGER block_suspend_test_only
      BEFORE INSERT ON active_trip
      BEGIN SELECT RAISE(ABORT, 'TEST_ONLY suspend fail'); END''');
    await expectLater(coordinator.watchdog(
      at: start.add(const Duration(seconds: 40)),
      foregroundStreamActive: false,
    ), throwsStateError);
    expect(coordinator.storageFaulted, true);
    expect(coordinator.status, MeterStatus.paused);
    expect(coordinator.fareForTesting, money);
    expect(coordinator.elapsedSecondsForTesting, time);
    expect(await persisted(), before);
    expect(coordinator.recordedRoute.length, 1);
  });

  test('resume() rejected SQLite route leaves original PAUSED trip unchanged',
      () async {
    await begin();
    expect(await coordinator.watchdog(
      at: start.add(const Duration(seconds: 35)),
      foregroundStreamActive: false,
    ), true);
    expect(coordinator.status, MeterStatus.paused);
    final before = await persisted();
    final money = coordinator.fareForTesting;
    final route = coordinator.recordedRoute.toList();
    await blockNextRoute(1);
    await expectLater(coordinator.resume(fix(40, latitude: 21.05)),
        throwsStateError);
    expect(coordinator.storageFaulted, true);
    expect(coordinator.status, MeterStatus.paused);
    expect(coordinator.requiresManualResume, true);
    expect(coordinator.fareForTesting, money);
    expect(coordinator.recordedRoute, route);
    expect(await persisted(), before);
  });

  test('finish() receipt INSERT failure cannot expose phantom FINISHED fare',
      () async {
    await begin();
    expect(await coordinator.accept(fix(5, latitude: 21.0002)), true);
    expect(await coordinator.watchdog(
      at: start.add(const Duration(seconds: 40)),
      foregroundStreamActive: false,
    ), true);
    final before = await persisted();
    final money = coordinator.fareForTesting;
    final distance = coordinator.distanceKmForTesting;
    await raw.execute('''CREATE TRIGGER block_finish_test_only
      BEFORE INSERT ON trips
      BEGIN SELECT RAISE(ABORT, 'TEST_ONLY receipt fail'); END''');
    await expectLater(coordinator.finish(
      at: start.add(const Duration(seconds: 60)),
      driverConfirmed: true,
    ), throwsStateError);
    expect(coordinator.storageFaulted, true);
    expect(coordinator.status, MeterStatus.paused);
    expect(coordinator.fareForTesting, money);
    expect(coordinator.distanceKmForTesting, distance);
    expect(await persisted(), before);
    expect(await repository.listTrips(), isEmpty);
    expect(coordinator.recordedRoute.length, 2);
  });

  test('finished receipt publishes only after completeActive() returns',
      () async {
    await begin();
    final completed = await coordinator.finish(
      at: start.add(const Duration(seconds: 30)), driverConfirmed: true,
    );
    expect(coordinator.hasSession, false);
    expect(await repository.loadActive(), isNull);
    final records = await repository.listTrips();
    expect(records.length, 1);
    expect(records.single.id, completed.id);
  });
}
