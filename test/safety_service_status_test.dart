import 'package:flutter_test/flutter_test.dart';
import 'package:navitaximeter/src/ui/safety_service_page.dart';

void main() {
  Map<Object?, Object?> reply({
    bool active = true, bool fresh = true,
    int count = 5, int age = 1000,
    bool billing = false, bool exports = false,
    bool acknowledged = true, String owner = 'native_safety',
    int leaseId = 17, int heartbeatAge = 100,
  }) => {
    'active': active, 'fresh': fresh,
    'acceptedCount': count, 'lastTrustedAgeMs': age,
    'state': 'trusted_gps', 'billingEnabled': billing,
    'coordinatesExported': exports,
    'acknowledged': acknowledged, 'owner': owner,
    'leaseId': leaseId, 'heartbeatAgeMs': heartbeatAge,
  };

  test('native service health is read only and fail closed', () {
    final data = SafetyServiceStatus.parse(reply());
    expect(data.active, true);
    expect(data.fresh, true);
    expect(data.acceptedCount, 5);
    expect(data.acknowledged, true);
    expect(data.leaseId, 17);
    expect(SafetyServiceStatus.parse(reply(
        active: false, acknowledged: false)).fresh, false);
    expect(SafetyServiceStatus.parse(reply(acknowledged: false)).active, false);
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
    expect(() => SafetyServiceStatus.parse(reply(owner: 'preview')),
        throwsFormatException);
    expect(() => SafetyServiceStatus.parse(reply(heartbeatAge: 9000)),
        throwsFormatException);
    expect(() => SafetyServiceStatus.parse(reply(leaseId: -1)),
        throwsFormatException);
    expect(() => SafetyServiceStatus.parse(reply(owner: 'unknown')),
        throwsFormatException);
  });
}
