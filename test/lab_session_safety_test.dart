import 'package:flutter_test/flutter_test.dart';

import 'package:navitaximeter/src/core/lab_session_safety.dart';
import 'package:navitaximeter/src/core/metered_trip_coordinator.dart';
import 'package:navitaximeter/src/core/taximeter_engine.dart';
import 'package:navitaximeter/src/domain/confirmed_tariffs.dart';

void main() {
  final now = DateTime.utc(2026, 11, 15, 10, 0);
  final fare = ConfirmedTariff(
    id: 'verified-lab',
    confirmedAtUtc: now,
    tariff: const TariffConfig(
      name: 'Giá xác nhận trong kiểm thử',
      baseFare: 10000,
      baseDistanceKm: 0.5,
      perKmRate: 15000,
      longDistanceThresholdKm: 30,
      longDistancePerKmRate: 12000,
      waitingFeePerHour: 30000,
    ),
  );
  MeterGpsObservation fix({
    Duration age = Duration.zero,
    bool mock = false,
    bool service = true,
    Duration gpsDelay = Duration.zero,
  }) => MeterGpsObservation(
    fix: GpsFix(
      latitude: 21.0,
      longitude: 105.8,
      accuracyMeters: 4,
      speedKmh: 12,
      timestamp: now.subtract(age).subtract(gpsDelay),
    ),
    receivedAt: now.subtract(age),
    isMocked: mock,
    foregroundStreamActive: service,
  );
  bool allowed({
    ConfirmedTariff? driverFare,
    MeterGpsObservation? observation,
    bool visible = true,
    bool subscribed = true,
  }) => LabSessionSafety.canBegin(
    tariff: driverFare ?? fare,
    observation: observation ?? fix(),
    now: now,
    activityVisible: visible,
    locationStreamSubscribed: subscribed,
  );

  test('only visible, subscribed, confirmed and fresh GPS is allowed', () {
    expect(allowed(), true);
    expect(allowed(visible: false), false);
    expect(allowed(subscribed: false), false);
    expect(allowed(observation: fix(service: false)), false);
    expect(allowed(observation: fix(mock: true)), false);
    expect(allowed(observation: fix(age: const Duration(seconds: 10))), false);
    expect(allowed(observation: fix(
      gpsDelay: const Duration(seconds: 20))), false);
    expect(LabSessionSafety.canBegin(
      tariff: null, observation: fix(), now: now,
      activityVisible: true, locationStreamSubscribed: true), false);
  });

  test('unsound tariff cannot unlock a laboratory trip', () {
    final invalid = ConfirmedTariff(
      id: 'broken',
      confirmedAtUtc: now,
      tariff: fare.tariff.copyWith(baseFare: 0),
    );
    expect(allowed(driverFare: invalid), false);
  });
}
