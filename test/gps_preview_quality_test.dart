import 'package:flutter_test/flutter_test.dart';
import 'package:navitaximeter/src/ui/gps_preview_page.dart';

void main() {
  test('never accept simulated, stale, inaccurate or impossible GPS', () {
    bool valid({double accuracy = 5, double speed = 35,
        Duration age = const Duration(seconds: 3), bool mock = false}) =>
      PreviewGpsQuality.trusted(
        latitude: 21.028, longitude: 105.835,
        accuracyMeters: accuracy, speedKmh: speed,
        age: age, isMocked: mock);
    expect(valid(), isTrue);
    expect(valid(accuracy: 95), isFalse);
    expect(valid(speed: 230), isFalse);
    expect(valid(age: const Duration(seconds: 18)), isFalse);
    expect(valid(mock: true), isFalse);
  });
}
