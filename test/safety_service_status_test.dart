import 'package:flutter_test/flutter_test.dart';
import 'package:navitaximeter/src/ui/safety_service_page.dart';

void main() {
  Map<Object?, Object?> reply({
    bool active = true, bool fresh = true,
    int count = 5, int age = 1000,
    bool billing = false, bool exports = false,
  }) => {
    'active': active, 'fresh': fresh,
    'acceptedCount': count, 'lastTrustedAgeMs': age,
    'state': 'trusted_gps', 'billingEnabled': billing,
    'coordinatesExported': exports,
  };

  test('native service health is read only and fail closed', () {
    final data = SafetyServiceStatus.parse(reply());
    expect(data.active, true);
    expect(data.fresh, true);
    expect(data.acceptedCount, 5);
    expect(SafetyServiceStatus.parse(reply(active: false)).fresh, false);
    expect(SafetyServiceStatus.parse(reply(age: 13000)).fresh, false);
    expect(SafetyServiceStatus.parse(reply(age: -1)).fresh, false);
    expect(() => SafetyServiceStatus.parse(reply(billing: true)),
        throwsFormatException);
    expect(() => SafetyServiceStatus.parse(reply(exports: true)),
        throwsFormatException);
  });

  test('reject malformed health data', () {
    expect(() => SafetyServiceStatus.parse({'active': true}),
        throwsFormatException);
    expect(() => SafetyServiceStatus.parse(reply(count: -1)),
        throwsFormatException);
  });
}
