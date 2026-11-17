import 'package:flutter_test/flutter_test.dart';
import 'package:navitaximeter/src/core/taximeter_engine.dart';
import 'package:navitaximeter/src/domain/confirmed_tariffs.dart';

void main() {
  final at = DateTime.utc(2026, 11, 15);
  TariffConfig fare(String name) => TariffConfig(
    name: name,
    baseFare: 12000,
    baseDistanceKm: 1.5,
    perKmRate: 14000,
    longDistanceThresholdKm: 30,
    longDistancePerKmRate: 11000,
    waitingFeePerHour: 36000,
    fareTiers: const [
      FareTier(upToKm: 30, ratePerKm: 14000),
      FareTier(upToKm: null, ratePerKm: 11000),
    ],
  );
  ConfirmedTariff checked(String id) =>
      ConfirmedTariff(id: id, tariff: fare(id), confirmedAtUtc: at);

  test('new installation contains no chargeable default tariff', () {
    const empty = ConfirmedTariffBook.empty();
    expect(empty.active, isNull);
    expect(empty.profiles, isEmpty);
    expect(ConfirmedTariffBook.decode(empty.encode()).active, isNull);
  });

  test('only driver-confirmed tiered tariffs can be saved and switched', () {
    var b = const ConfirmedTariffBook.empty().save(checked('four'));
    b = b.save(checked('seven'));
    expect(b.active!.id, 'four');
    expect(b.select('seven').active!.id, 'seven');
    expect(ConfirmedTariffBook.decode(b.encode()).profiles.length, 2);
    expect(b.active!.tariff.distanceChargeForKm(31),
        closeTo(28.5 * 14000 + 11000, 0.001));
  });

  test('deleting active tariff never invents a replacement', () {
    final b = const ConfirmedTariffBook.empty().save(checked('only'));
    expect(b.remove('only').active, isNull);
    expect(b.remove('only').profiles, isEmpty);
  });

  test('forbid a zero-priced tariff from being marked confirmed', () {
    final invalid = ConfirmedTariff(
      id: 'zero',
      confirmedAtUtc: at,
      tariff: fare('zero').copyWith(baseFare: 0),
    );
    expect(() => const ConfirmedTariffBook.empty().save(invalid),
        throwsFormatException);
  });

  test('corrupted or half-written tariffs fail closed', () {
    expect(() => ConfirmedTariffBook.decode('{}'), throwsFormatException);
    expect(() => ConfirmedTariffBook.decode(
        '{"schema":1,"activeId":"missing","profiles":[]}'),
        throwsFormatException);
    expect(() => ConfirmedTariffBook.decode(
        '{"schema":1,"activeId":"x","profiles":[{"id":"x","tariff":{}}]}'),
        throwsFormatException);
  });
}
