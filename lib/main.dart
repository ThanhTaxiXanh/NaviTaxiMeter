import 'package:flutter/material.dart';

import 'src/ui/gps_preview_page.dart';
import 'src/ui/tariff_management_page.dart';

void main() => runApp(const NaviTaxiMeterApp());

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
    home: const NaviFoundationHome(),
  );
}

class NaviFoundationHome extends StatefulWidget {
  const NaviFoundationHome({super.key});

  @override
  State<NaviFoundationHome> createState() => _NaviFoundationHomeState();
}

class _NaviFoundationHomeState extends State<NaviFoundationHome> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: switch (_tab) {
      1 => const TariffManagementPage(),
      2 => const GpsPreviewPage(),
      _ => const SafeArea(child: Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('NaviTaxiMeter', textAlign: TextAlign.center,
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold,
                    color: Color(0xFF00D8F0))),
            SizedBox(height: 22),
            Text('Bảng giá và GPS đang được kiểm thử',
                 textAlign: TextAlign.center),
            SizedBox(height: 12),
            Text('CHƯA SẴN SÀNG THU CƯỚC', textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold,
                    color: Color(0xFFFFB020))),
            SizedBox(height: 16),
            Text('Có thể nhập bảng giá thực và xem GPS thật. '
                 'Chưa có chuyến thu tiền, chưa hỗ trợ tự khôi phục GPS nền.',
                 textAlign: TextAlign.center,
                 style: TextStyle(color: Color(0xFFA9C5D3))),
          ],
        )),
      )),
    },
    bottomNavigationBar: NavigationBar(
      selectedIndex: _tab,
      onDestinationSelected: (value) => setState(() => _tab = value),
      destinations: const [
        NavigationDestination(icon: Icon(Icons.info_outline), label: 'Trạng thái'),
        NavigationDestination(icon: Icon(Icons.price_change), label: 'Bảng giá'),
        NavigationDestination(icon: Icon(Icons.gps_fixed), label: 'GPS thử'),
      ],
    ),
  );
}
