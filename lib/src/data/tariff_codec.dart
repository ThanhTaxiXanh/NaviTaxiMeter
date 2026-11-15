import 'dart:convert';
import '../core/taximeter_engine.dart';

/// Configuration only. Completed fares live in SQLite.
class TariffCodec {
  static String encode(TariffConfig t) => jsonEncode({
    'version': 1,
    'name': t.name,
    'baseFare': t.baseFare,
    'baseDistanceKm': t.baseDistanceKm,
    'perKmRate': t.perKmRate,
    'longDistanceThresholdKm': t.longDistanceThresholdKm,
    'longDistancePerKmRate': t.longDistancePerKmRate,
    'waitingFeePerHour': t.waitingFeePerHour,
    'waitingSpeedThresholdKmh': t.waitingSpeedThresholdKmh,
    'waitingGraceMinutes': t.waitingGraceMinutes,
    'speedLimitKmh': t.speedLimitKmh,
    'gpsMaxAccuracyMeters': t.gpsMaxAccuracyMeters,
    'gpsCalibrationMultiplier': t.gpsCalibrationMultiplier,
    'roundToThousands': t.roundToThousands,
    'fareTiers': t.fareTiers?.map((t) => t.toJson()).toList(),
  });

  static TariffConfig decode(String raw) {
    final data = Map<String, dynamic>.from(jsonDecode(raw) as Map);
    // Missing tariff fields must NEVER resolve to illustrative prices.
    double requiredRate(String field) {
      final number = data[field];
      if (number is! num || !number.toDouble().isFinite) {
        throw FormatException('Invalid or missing tariff: $field');
      }
      return number.toDouble();
    }
    final config = TariffConfig(
      name: data['name']?.toString() ?? '',
      baseFare: requiredRate('baseFare'),
      baseDistanceKm: requiredRate('baseDistanceKm'),
      perKmRate: requiredRate('perKmRate'),
      longDistanceThresholdKm:
          requiredRate('longDistanceThresholdKm'),
      longDistancePerKmRate:
          requiredRate('longDistancePerKmRate'),
      waitingFeePerHour:
          requiredRate('waitingFeePerHour'),
      waitingSpeedThresholdKmh:
          requiredRate('waitingSpeedThresholdKmh'),
      waitingGraceMinutes:
          requiredRate('waitingGraceMinutes'),
      speedLimitKmh: requiredRate('speedLimitKmh'),
      gpsMaxAccuracyMeters:
          requiredRate('gpsMaxAccuracyMeters'),
      gpsCalibrationMultiplier: requiredRate('gpsCalibrationMultiplier'),
      roundToThousands:
          data['roundToThousands'] is bool
              ? data['roundToThousands'] as bool
              : false,
      fareTiers: data['fareTiers'] is List
          ? (data['fareTiers'] as List).map((v) =>
              FareTier.fromJson(Map<String, dynamic>.from(v as Map))).toList()
          : null,
    );
    config.validate();
    return config;
  }
}
