import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';

/// Read-only service health; no passenger fare or physical coordinates.
class SafetyServiceStatus {
  const SafetyServiceStatus({
    required this.active, required this.fresh,
    required this.acceptedCount, required this.lastTrustedAgeMs,
    required this.state, required this.acknowledged,
    required this.owner, required this.leaseId,
    required this.heartbeatAgeMs,
  });
  final bool active;
  final bool fresh;
  final int acceptedCount;
  final int lastTrustedAgeMs;
  final String state;
  final bool acknowledged;
  final String owner;
  final int leaseId;
  final int heartbeatAgeMs;

  factory SafetyServiceStatus.parse(Map<dynamic, dynamic> fields) {
    if (fields['billingEnabled'] != false ||
        fields['coordinatesExported'] != false) {
      throw const FormatException('Trạng thái GPS không an toàn');
    }
    final active = fields['active'];
    final fresh = fields['fresh'];
    final count = fields['acceptedCount'];
    final age = fields['lastTrustedAgeMs'];
    final state = fields['state'];
    final ack = fields['acknowledged'];
    final owner = fields['owner'];
    final lease = fields['leaseId'];
    final heartbeat = fields['heartbeatAgeMs'];
    if (active is! bool || fresh is! bool || count is! int || count < 0 ||
        age is! int || age < -1 || state is! String ||
        ack is! bool || owner is! String ||
        !const {'none', 'preview', 'lab', 'native_safety'}.contains(owner) ||
        lease is! int || heartbeat is! int || heartbeat < -1) {
      throw const FormatException('Dữ liệu trạng thái GPS không hợp lệ');
    }
    if (ack && (!active || owner != 'native_safety' ||
        lease <= 0 || heartbeat < 0 || heartbeat > 7000)) {
      throw const FormatException('Android GPS ACK không hợp lệ');
    }
    final live = active && ack && owner == 'native_safety' &&
        lease > 0 && heartbeat >= 0 && heartbeat <= 7000;
    return SafetyServiceStatus(
      active: live,
      fresh: live && fresh && age >= 0 && age <= 12000,
      acceptedCount: count, lastTrustedAgeMs: age, state: state,
      acknowledged: live, owner: owner,
      leaseId: lease, heartbeatAgeMs: heartbeat,
    );
  }
}

/// Service starts only when the Android Activity is resumed. It continues
/// after this diagnostic screen is disposed, but never drives the fare engine.
/// The persistent OS notification provides a stop action at any time.
class SafetyServicePage extends StatefulWidget {
  const SafetyServicePage({super.key});

  @override
  State<SafetyServicePage> createState() => _SafetyServicePageState();
}

class _SafetyServicePageState extends State<SafetyServicePage>
    with WidgetsBindingObserver {
  static const _channel = MethodChannel(
      'vn.navitaximeter/safety_location_service');
  Timer? _poller;
  SafetyServiceStatus? _status;
  bool _busy = false;
  bool _visible = true;
  String _message = 'Đang kiểm tra dịch vụ GPS Android...';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _poller = Timer.periodic(const Duration(seconds: 3), (_) {
      if (_visible && !_busy) unawaited(_refresh());
    });
    unawaited(_refresh());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _visible = state == AppLifecycleState.resumed;
    if (_visible) unawaited(_refresh());
  }

  Future<void> _refresh() async {
    try {
      final raw = await _channel.invokeMethod<Map<dynamic, dynamic>>('status');
      if (raw == null) throw const FormatException('Android không phản hồi');
      final parsed = SafetyServiceStatus.parse(raw);
      if (mounted) setState(() {
        _status = parsed;
        _message = parsed.active
            ? (parsed.fresh ? 'GPS đủ mới' : 'Chưa nhận GPS đủ tin cậy')
            : 'Dịch vụ đã dừng';
      });
    } catch (error) {
      if (mounted) setState(() {
        // A failed health read must never leave an old live ACK on screen.
        _status = null;
        _message = 'Không đọc được dịch vụ: ' + error.toString();
      });
    }
  }

  Future<void> _start() async {
    if (_busy || !_visible) return;
    setState(() => _busy = true);
    int? pendingLease;
    var confirmed = false;
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        throw StateError('Cần bật Vị trí của Android');
      }
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        throw StateError('Cần cấp quyền vị trí');
      }
      if (!mounted || !_visible) return;
      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Bật dịch vụ GPS an toàn?'),
          content: const Text(
            'Dịch vụ Kotlin có thể tiếp tục khi rời màn hình. '
            'Chỉ ghi nhận số lượng và tuổi mẫu GPS, không lưu tọa độ, '
            'không tính tiền hoặc phát hành hóa đơn. Dừng trong '
            'thông báo của Android bất cứ lúc nào.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Hủy')),
            FilledButton(onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Bật dịch vụ thử')),
          ],
        ),
      );
      if (confirm != true || !mounted || !_visible) return;
      final dispatch = await _channel.invokeMapMethod<String, dynamic>('start');
      if (dispatch?['requestAccepted'] != true ||
          dispatch?['leaseId'] is! int) {
        throw const FormatException('Android chưa chấp nhận lệnh khởi động');
      }
      pendingLease = dispatch!['leaseId'] as int;
      // Dispatch does not mean the service is alive. Match token + heartbeat.
      for (var attempt = 0; attempt < 10 && mounted && _visible; attempt++) {
        await Future<void>.delayed(const Duration(milliseconds: 300));
        final raw = await _channel.invokeMethod<Map<dynamic, dynamic>>('status');
        if (raw == null) continue;
        final status = SafetyServiceStatus.parse(raw);
        if (status.acknowledged && status.leaseId == pendingLease) {
          confirmed = true;
          if (mounted) setState(() {
            _status = status;
            _message = 'Đã xác nhận GPS Android; chỉ dùng để chẩn đoán.';
          });
          break;
        }
      }
      if (!confirmed) {
        throw StateError('Không nhận được ACK/heartbeat; yêu cầu dừng');
      }
    } on PlatformException catch (error) {
      if (mounted) setState(() {
        _message = error.code == 'NOTIFICATION_PERMISSION'
            ? 'Cho phép thông báo Android, sau đó bấm Bật lần nữa.'
            : 'Không thể bật: ' + error.code + ' ' + (error.message ?? '');
      });
    } catch (error) {
      if (mounted) setState(
          () => _message = 'Không thể bật dịch vụ: ' + error.toString());
    } finally {
      if (!confirmed && pendingLease != null) {
        try {
          await _channel.invokeMethod<bool>('stop', {'leaseId': pendingLease});
        } catch (_) {
          // A failed stop must never give a different owner permission.
        }
      }
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _stop() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await _channel.invokeMethod<bool>('stop');
      await _refresh();
      if (mounted) setState(() => _message = 'Đã gửi lệnh dừng.');
    } catch (error) {
      if (mounted) setState(() => _message = error.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  void dispose() {
    _poller?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    // Deliberately no implicit stop; OS notification remains a stop control.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final status = _status;
    return Scaffold(
      appBar: AppBar(title: const Text('GPS nền Android')),
      body: ListView(padding: const EdgeInsets.all(18), children: [
        const Text('CHỈ CHẨN ĐOÁN · KHÔNG TÍNH CƯỚC',
            style: TextStyle(fontSize: 18,
                color: Color(0xFFFFB020), fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        const Text('Native LocationManager đo chất lượng GPS ngay cả '
            'khi chuyển màn hình. Không truyền tọa độ sang Flutter '
            'hoặc kết nối với dữ liệu thu cước. '
            'Ứng dụng không tự khởi động lại dịch vụ khi bị đóng tiến trình.'),
        const SizedBox(height: 20),
        Text(_message),
        const SizedBox(height: 12),
        Text('Dịch vụ: ' + (status?.active == true ? 'Đang chạy' : 'Đã dừng')),
        Text('GPS mới: ' + (status?.fresh == true ? 'Có' : 'Không')),
        Text('Số mẫu GPS chấp nhận: ' + (status?.acceptedCount ?? 0).toString()),
        Text('Trạng thái: ' + (status?.state ?? 'Chưa xác định')),
        Text('Chủ GPS: ' + (status?.owner ?? 'Chưa xác định')),
        Text('ACK/heartbeat: ' +
            (status?.acknowledged == true ? 'Đã xác nhận' : 'Chưa xác nhận')),
        if (status != null && status.lastTrustedAgeMs >= 0)
          Text('Tuổi mẫu GPS: ' + status.lastTrustedAgeMs.toString() + ' ms'),
        const SizedBox(height: 22),
        FilledButton.icon(
          onPressed: _busy || !_visible ? null : _start,
          icon: const Icon(Icons.play_arrow),
          label: const Text('Bật GPS nền thử'),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: _busy ? null : _stop,
          icon: const Icon(Icons.stop),
          label: const Text('Dừng GPS nền thử'),
        ),
        TextButton(onPressed: _busy ? null : _refresh,
            child: const Text('Đọc lại trạng thái')),
        const SizedBox(height: 16),
        const Text('Chưa kiểm thử trên điện thoại thật hoặc bảo đảm '
            'hoạt động qua khởi động lại, thu hồi quyền và giới hạn pin OEM.'),
      ]),
    );
  }
}
