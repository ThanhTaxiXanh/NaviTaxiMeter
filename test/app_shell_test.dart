import 'package:flutter_test/flutter_test.dart';
import 'package:navitaximeter/main.dart';
void main() {
 testWidgets('no dummy fare or location is shown', (tester) async {
   await tester.pumpWidget(const NaviTaxiMeterApp());
   expect(find.text('CHƯA SẴN SÀNG THU CƯỚC'), findsOneWidget);
 });
}
