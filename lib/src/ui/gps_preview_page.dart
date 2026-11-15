import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../core/location_tracking_policy.dart';
import '../core/location_owner_gate.dart';

/// Preview-only validation. It never feeds a fare engine or stores coordinates.
abstract final class PreviewGpsQuality {
  static bool trusted({
    required double latitude,
    required double longitude,
    required double accuracyMeters,
    required double speedKmh,
    required Duration age,
    required bool isMocked,
  }) =>
      !isMocked &&
      latitude.isFinite && longitude.isFinite &&
      latitude.abs() <= 90 && longitude.abs() <= 180 &&
      accuracyMeters.isFinite && accuracyMeters >= 0 &&
      accuracyMeters <= 30 &&
      speedKmh.isFinite && speedKmh >= 0 && speedKmh <= 220 &&
      !age.isNegative && age <= const Duration(seconds: 15);
}

/// Geolocator supplies a plugin-managed Android location foreground service
/// while the user has started this preview in the visible activity.
/// It is NOT a continuous, recoverable taxi trip foreground service yet.
class GpsPreviewPage extends StatefulWidget {
  const GpsPreviewPage({super.key});

  @override
  State<GpsPreviewPage> createState() => _GpsPreviewPageState();
}

class _GpsPreviewPageState extends State<GpsPreviewPage>
    with WidgetsBindingObserver {
  final LocationTrackingPolicy _policy = LocationTrackingPolicy();
  LocationOwnerLease? _lease;
  bool _visible = true;
  StreamSubscription<Position>? _subscription;
  Timer? _watchdog;
  Position? _latest;
  DateTime? _receivedAt;
  String _state = 'Chưa bật theo dõi';
  bool _starting = false;

  bool get _tracking => _subscription != null;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _visible = state == AppLifecycleState.resumed;
    if (!_visible) unawaited(_stop());
  }

  Future<void> _start() async {
    if (_tracking || _starting || !_visible) return;
    setState(() { _starting = true; _state = 'Đang kiểm tra quyền GPS...'; });
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        throw StateError('Cần bật Vị trí (GPS) trên điện thoại');
      }
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        throw StateError('Chưa được cấp quyền vị trí chính xác');
      }
      if (!mounted || !_visible) return;
      _lease = await LocationOwnerLease.acquire('preview');
      if (!mounted || !_visible) {
        await _stop();
        return;
      }
      // Native lease precedes the Geolocator foreground stream.
      final now = DateTime.now();
      _policy.begin(now);
      final settings = AndroidSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 2,
        intervalDuration: const Duration(seconds: 3),
        foregroundNotificationConfig: const ForegroundNotificationConfig(
          notificationTitle: 'NaviTaxiMeter · Kiểm tra GPS',
          notificationText: 'Đang xem tín hiệu GPS, không tính cước.',
          notificationChannelName: 'GPS NaviTaxiMeter',
          setOngoing: true,
          enableWakeLock: false,
        ),
      );
      _subscription = Geolocator.getPositionStream(
        locationSettings: settings,
      ).listen(_onPosition, onError: (Object error) {
        if (mounted) {
          setState(() => _state = 'GPS lỗi: $error');
        }
        _stop();
      });
      _watchdog = Timer.periodic(const Duration(seconds: 3), (_) {
        if (!mounted || _subscription == null) return;
        final now = DateTime.now();
        if (_policy.shouldSuspend(now)) {
          setState(() => _state = 'GPS gián đoạn hoặc thiếu dữ liệu tin cậy');
        } else if (_receivedAt != null) {
          setState(() {});
        }
      });
      setState(() => _state = 'Đang tìm vị trí chính xác...');
    } catch (e) {
      if (mounted) setState(() => _state = '$e');
      await _stop();
    } finally {
      if (mounted) setState(() => _starting = false);
    }
  }

  void _onPosition(Position p) {
    if (!mounted) return;
    final received = DateTime.now();
    final age = received.difference(p.timestamp);
    final kmh = p.speed * 3.6;
    if (!PreviewGpsQuality.trusted(
      latitude: p.latitude,
      longitude: p.longitude,
      accuracyMeters: p.accuracy,
      speedKmh: kmh,
      age: age,
      isMocked: p.isMocked,
    )) {
      setState(() => _state = 'Mẫu GPS không đạt độ tin cậy');
      return;
    }
    _policy.acceptedFix(received);
    setState(() {
      _latest = p;
      _receivedAt = received;
      _state = 'GPS đang cập nhật · chỉ xem thử';
    });
  }

  Future<void> _stop() async {
    final existing = _subscription;
    _subscription = null;
    _watchdog?.cancel();
    _watchdog = null;
    _policy.clear();
    await existing?.cancel();
    final lease = _lease;
    if (lease != null) {
      await lease.release();
      _lease = null;
    }
    if (mounted) {
      setState(() {
        _latest = null;
        _receivedAt = null;
        _state = 'Đã dừng xem GPS';
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_stop());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = _latest;
    final fresh = _receivedAt != null &&
        _policy.hasRecentFix(DateTime.now());
    return Scaffold(
      appBar: AppBar(title: const Text('Kiểm tra GPS thật')),
      body: ListView(padding: const EdgeInsets.all(18), children: [
        const Text('CHƯA TÍNH CƯỚC',
          style: TextStyle(color: Color(0xFFFFB020),
            fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        const Text('Chế độ này chỉ đọc GPS của điện thoại. '
          'Không tính km hay tiền, không ghi lịch sử chuyến. '
          'Khi rời màn hình, theo dõi thử sẽ dừng.'),
        const SizedBox(height: 20),
        Text(_state, style: const TextStyle(fontSize: 16)),
        const SizedBox(height: 18),
        if (p != null && fresh) ...[
          Text('Vĩ độ: ${p.latitude.toStringAsFixed(6)}'),
          Text('Kinh độ: ${p.longitude.toStringAsFixed(6)}'),
          Text('Độ chính xác: ${p.accuracy.toStringAsFixed(1)} m'),
          Text('Tốc độ: ${(p.speed * 3.6).toStringAsFixed(1)} km/h'),
          Text('Lần nhận: ${_receivedAt!.toLocal()}'),
        ] else if (_tracking) ...[
          const Text('Chưa có bản ghi vị trí đáng tin cậy gần đây.'),
        ],
        const SizedBox(height: 24),
        FilledButton.icon(
          onPressed: _starting ? null : (_tracking ? _stop : _start),
          icon: Icon(_tracking ? Icons.stop : Icons.gps_fixed),
          label: Text(_tracking ? 'Dừng GPS thử' : 'Bắt đầu xem GPS'),
        ),
      ]),
    );
  }
}
