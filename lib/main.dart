import 'package:flutter/material.dart';

void main() => runApp(const NaviTaxiMeterApp());

/// Accurate readiness screen: no fake location, tariff, journey or receipt.
class NaviTaxiMeterApp extends StatelessWidget {
  const NaviTaxiMeterApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'NaviTaxiMeter',
    theme: ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF071827),
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF00D8F0), brightness: Brightness.dark),
    ),
    home: const Scaffold(
      body: SafeArea(child: Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('NaviTaxiMeter', textAlign: TextAlign.center,
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold,
                    color: Color(0xFF00D8F0))),
            SizedBox(height: 22),
            Text('Nền tảng nghiệp vụ đang được kiểm thử',
                 textAlign: TextAlign.center),
            SizedBox(height: 12),
            Text('CHƯA SẴN SÀNG THU CƯỚC', textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold,
                    color: Color(0xFFFFB020))),
            SizedBox(height: 16),
            Text('GPS nền, bảng giá xác nhận và khôi phục chuyến đang tích hợp. '
                 'Không tự tạo vị trí hoặc tiền cước giả.',
                 textAlign: TextAlign.center,
                 style: TextStyle(color: Color(0xFFA9C5D3))),
          ],
        )),
      )),
    ),
  );
}
