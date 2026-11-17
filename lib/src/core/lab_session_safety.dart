import 'metered_trip_coordinator.dart';
import 'taximeter_engine.dart';
import '../domain/confirmed_tariffs.dart';

/// Admission gate for a supervised lab session. No passenger fares.
abstract final class LabSessionSafety {
  static bool canBegin({
    required ConfirmedTariff? tariff,
    required MeterGpsObservation? observation,
    required DateTime now,
    required bool activityVisible,
    required bool locationStreamSubscribed,
  }) {
    if (!activityVisible || !locationStreamSubscribed ||
        tariff == null || observation == null) return false;
    final receivedAge = now.difference(observation.receivedAt);
    if (receivedAge.isNegative ||
        receivedAge > const Duration(seconds: 7)) return false;
    try {
      tariff.validate();
      final engine = TaximeterEngine(tariff: tariff.tariff);
      return observation.isTrustedFor(engine);
    } catch (_) {
      return false;
    }
  }
}
