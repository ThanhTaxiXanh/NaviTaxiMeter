import 'package:flutter_test/flutter_test.dart';
import 'package:navitaximeter/src/data/tariff_codec.dart';
void main() {
 test('no sample rate is silently used for missing stored tariff', () {
   expect(() => TariffCodec.decode('{"name":"missing"}'), throwsFormatException);
 });
}
