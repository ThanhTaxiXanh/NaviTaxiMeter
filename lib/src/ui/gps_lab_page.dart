import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../core/lab_session_safety.dart';
import '../core/location_owner_gate.dart';
import '../core/serialized_gps_stop.dart';
import '../core/metered_trip_coordinator.dart';
import '../core/taximeter_engine.dart';
import '../data/trip_repository.dart';
import '../data/trip_session_snapshot.dart';
import '../domain/confirmed_tariffs.dart';
import 'gps_preview_page.dart';

/// Lab-only real GPS integration. This page deliberately NEVER displays fare,
/// never issues a passenger receipt and never creates business revenue.
/// Position stream owns the Geolocator notification while the screen is visible.
class GpsLabPage extends StatefulWidget {
  const GpsLabPage({super.key});

  @override
  State<GpsLabPage> createState() => _GpsLabPageState();
}

class _GpsLabPageState extends State<GpsLabPage>
    with WidgetsBindingObserver {
  static const _labMarker = 'NAVITAXIMETER_LAB_GPS_ONLY';

  final TripRepository _repository = TripRepository();
  final ConfirmedTariffStore _tariffStore = ConfirmedTariffStore();
  late MeteredTripCoordinator _session =
      MeteredTripCoordinator(repository: _repository);

  Future<void> _operations = Future<void>.value();
  final SerializedGpsStop _stopGate = SerializedGpsStop();
  StreamSubscription<Position>? _stream;
  LocationOwnerLease? _lease;
  Timer? _watchdog;
  MeterGpsObservation? _lastObservation;
  ConfirmedTariff? _confirmedTariff;

  bool _ready = false;
  bool _busy = false;
  bool _startingGps = false;
  bool _activityVisible = true;
  bool _labOwned = false;
  bool _closing = false;
  String _message = 'Đang kiểm tra SQLite và bảng giá...';

  bool get _tracking => _stream != null;
  bool get _freshPosition {
    final sample = _lastObservation;
    if (sample == null || !_activityVisible || !_tracking) return false;
    final age = DateTime.now().difference(sample.receivedAt);
    return !age.isNegative && age <= const Duration(seconds: 7);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    unawaited(_initialize());
  }

  Future<void> _initialize() async {
    try {
      final book = await _tariffStore.read();
      final stored = await _repository.loadActive();
      if (stored != null) {
        final snapshot = TripSessionSnapshot.decode(stored);
        _labOwned = snapshot.pickup == _labMarker;
        await _session.recover(at: DateTime.now());
      }
      if (!mounted || _closing) return;
      setState(() {
        _ready = true;
        _confirmedTariff = book.active;
        _message = _session.hasSession
            ? (_labOwned
                ? 'Phiên GPS thử đã được khôi phục ở trạng thái tạm dừng.'
                : 'Có checkpoint ngoài phòng thử; không được ghi đè hoặc xóa.')
            : 'Chưa có phiên thử; hãy bật GPS thật.';
      });
    } catch (error) {
      if (!mounted || _closing) return;
      setState(() {
        _message = 'Không thể mở dữ liệu an toàn: $error';
        _ready = false;
      });
    }
  }

  /// Queue serializes GPS updates, lifecycle suspension, start and cleanup.
  Future<void> _enqueue(Future<void> Function() work) {
    final pending = _operations.then((_) => work());
    _operations = pending.catchError((Object error, StackTrace trace) {
      if (mounted && !_closing) {
        setState(() => _message = 'Chặn thao tác do lỗi: $error');
      }
    });
    return _operations;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) {
      _activityVisible = false;
      // Conservative policy: do not bill when the activity becomes invisible.
      unawaited(_stopGps().catchError((Object error, StackTrace _) {
        if (mounted && !_closing) {
          setState(() => _message = 'Dừng GPS không an toàn: $error');
        }
      }));
    } else {
      _activityVisible = true;
      if (mounted && !_closing) {
        setState(() => _message = 'Mở lại ứng dụng; cần bật GPS và tiếp tục thủ công.');
      }
    }
  }

  Future<void> _startGps() async {
    if (_closing || _tracking || _startingGps || _stopGate.stopping ||
        _lease != null || !_ready) return;
    setState(() {
      _startingGps = true;
      _message = 'Đang kiểm tra vị trí và quyền của Android...';
    });
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        throw StateError('Hãy bật dịch vụ vị trí của điện thoại.');
      }
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        throw StateError('Chưa được cấp quyền vị trí.');
      }
      if (!mounted || _closing || !_activityVisible) return;
      _lease = await LocationOwnerLease.acquire('lab');
      if (!mounted || _closing || !_activityVisible) {
        await _stopGps();
        return;
      }
      const notification = ForegroundNotificationConfig(
        notificationTitle: 'NaviTaxiMeter · Thử GPS',
        notificationText: 'Chỉ thử ghi GPS cục bộ, không thu cước.',
        notificationChannelName: 'Kiểm thử vị trí NaviTaxiMeter',
        setOngoing: true,
        enableWakeLock: false,
      );
      final settings = AndroidSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 0,
        intervalDuration: const Duration(seconds: 3),
        foregroundNotificationConfig: notification,
      );
      _stream = Geolocator.getPositionStream(
        locationSettings: settings,
      ).listen(_onPosition, onError: (Object error) {
        if (mounted && !_closing) {
          setState(() => _message = 'Luồng vị trí lỗi: $error');
        }
        unawaited(_stopGps().catchError((Object error, StackTrace _) {
          if (mounted && !_closing) {
            setState(() => _message = 'Dừng GPS không an toàn: $error');
          }
        }));
      });
      _watchdog = Timer.periodic(const Duration(seconds: 3), (_) {
        if (!_tracking || !_activityVisible || _closing) return;
        if (_session.status == MeterStatus.running) {
          unawaited(_enqueue(() async {
            await _session.watchdog(
              at: DateTime.now(),
              foregroundStreamActive: _stream != null && _activityVisible,
            );
            if (mounted && !_closing) setState(() {});
          }));
        } else if (mounted) {
          setState(() {});
        }
      });
      setState(() => _message = 'Đang đợi vị trí GPS thực đủ tin cậy...');
    } catch (error) {
      if (mounted && !_closing) {
        setState(() => _message = 'Không thể bật GPS: $error');
      }
      await _stopGps();
    } finally {
      if (mounted && !_closing) setState(() => _startingGps = false);
    }
  }

  void _onPosition(Position position) {
    if (_closing || !mounted || !_tracking || !_activityVisible) return;
    final receivedAt = DateTime.now();
    final speedKmh = position.speed * 3.6;
    final good = PreviewGpsQuality.trusted(
      latitude: position.latitude,
      longitude: position.longitude,
      accuracyMeters: position.accuracy,
      speedKmh: speedKmh,
      age: receivedAt.difference(position.timestamp),
      isMocked: position.isMocked,
    );
    final observation = MeterGpsObservation(
      fix: GpsFix(
        latitude: position.latitude,
        longitude: position.longitude,
        accuracyMeters: position.accuracy,
        speedKmh: speedKmh,
        timestamp: position.timestamp,
      ),
      receivedAt: receivedAt,
      isMocked: position.isMocked,
      foregroundStreamActive: _stream != null && _activityVisible,
    );
    setState(() {
      _lastObservation = good ? observation : null;
      _message = good
          ? 'Đã nhận tọa độ thực; đang kiểm tra checkpoint.'
          : 'GPS không đáng tin cậy. Không cộng km hay thời gian.';
    });
    if (_session.status != MeterStatus.running) return;
    unawaited(_enqueue(() async {
      if (_closing) return;
      if (!good || !_activityVisible || !_tracking) {
        await _session.watchdog(
          at: receivedAt, foregroundStreamActive: false);
      } else {
        await _session.accept(observation);
      }
      if (mounted && !_closing) setState(() {});
    }));
  }

  Future<void> _stopGps() => _stopGate.run(_stopOwnedStream);

  Future<void> _stopOwnedStream() async {
    final current = _stream;
    _stream = null;
    _watchdog?.cancel();
    _watchdog = null;
    _lastObservation = null;
    await current?.cancel();
    await _enqueue(() async {
      if (_session.status == MeterStatus.running) {
        await _session.watchdog(
          at: DateTime.now(), foregroundStreamActive: false);
      }
    });
    if (_session.storageFaulted || _session.status == MeterStatus.running) {
      // Keep the exclusive lease on uncertain SQLite suspension.
      throw StateError('Checkpoint GPS chưa an toàn; khóa owner vẫn giữ');
    }
    final lease = _lease;
    if (lease != null) {
      await lease.release();
      _lease = null;
    }
    if (mounted && !_closing) {
      setState(() => _message = 'GPS đã dừng; phiên thử đã được tạm ngắt.');
    }
  }

  Future<void> _stopGpsFromButton() async {
    try {
      await _stopGps();
    } catch (error) {
      if (mounted && !_closing) {
        setState(() => _message = 'Khóa GPS chưa thể giải phóng: $error');
      }
    }
  }

  Future<bool> _ask(String title, String message, String action) async =>
      (await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Hủy'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(action),
            ),
          ],
        ),
      )) == true;

  Future<void> _beginLab() async {
    if (_busy || !_ready || _session.hasSession) return;
    final accepted = LabSessionSafety.canBegin(
      tariff: _confirmedTariff,
      observation: _lastObservation,
      now: DateTime.now(),
      activityVisible: _activityVisible,
      locationStreamSubscribed: _tracking,
    );
    if (!accepted) {
      setState(() => _message = 'Cần bảng giá xác nhận và GPS thật mới.');
      return;
    }
    final agreed = await _ask(
      'Bắt đầu phiên kỹ thuật?',
      'Chỉ lưu GPS và checkpoint trên máy. Không hiển thị tiền, không '
          'phát hành hóa đơn, không ghi doanh thu. Không dùng để chở khách.',
      'Bắt đầu kiểm thử',
    );
    if (!agreed || !mounted) return;
    setState(() => _busy = true);
    await _enqueue(() async {
      if (!LabSessionSafety.canBegin(
        tariff: _confirmedTariff,
        observation: _lastObservation,
        now: DateTime.now(),
        activityVisible: _activityVisible,
        locationStreamSubscribed: _tracking,
      )) {
        throw StateError('GPS hoặc quyền đã thay đổi trong lúc xác nhận');
      }
      await _session.begin(
        tariff: _confirmedTariff!,
        initial: _lastObservation!,
        pickup: _labMarker,
      );
      _labOwned = true;
      if (mounted) setState(() => _message = 'Phiên thử đang lưu GPS vào SQLite.');
    });
    if (mounted) setState(() => _busy = false);
  }

  Future<void> _resumeLab() async {
    if (_busy || !_ready || !_labOwned || !_session.hasSession ||
        !_session.requiresManualResume || !_freshPosition) return;
    final agreed = await _ask(
      'Tiếp tục phiên GPS thử?',
      'Chỉ dùng GPS thực mới và bắt đầu một đoạn hành trình riêng. '
          'Thời gian mất GPS không được cộng.',
      'Tiếp tục thủ công',
    );
    if (!agreed || !mounted) return;
    setState(() => _busy = true);
    await _enqueue(() async {
      final observation = _lastObservation;
      if (observation == null || !_freshPosition || !_activityVisible ||
          !_tracking) {
        throw StateError('GPS không còn mới, không tiếp tục');
      }
      await _session.resume(observation);
      if (mounted) setState(() => _message = 'Phiên thử đang chạy trở lại.');
    });
    if (mounted) setState(() => _busy = false);
  }

  Future<void> _discardLab() async {
    if (_busy || !_ready || !_labOwned || !_session.hasSession) return;
    final confirmed = await _ask(
      'Xóa phiên thử chưa hoàn tất?',
      'Thao tác này chỉ xóa checkpoint của phiên thử GPS được đánh dấu riêng. '
          'Không tạo hóa đơn và không xóa lịch sử chuyến đã hoàn tất.',
      'Xóa phiên thử',
    );
    if (!confirmed || !mounted) return;
    setState(() => _busy = true);
    await _stopGps();
    await _enqueue(() async {
      final raw = await _repository.loadActive();
      if (raw == null ||
          TripSessionSnapshot.decode(raw).pickup != _labMarker) {
        throw StateError('Checkpoint không thuộc phiên thử; từ chối xóa');
      }
      await _repository.clearActive();
      _session = MeteredTripCoordinator(repository: _repository);
      _labOwned = false;
      if (mounted) {
        setState(() => _message = 'Đã xóa checkpoint thử, không có hóa đơn.');
      }
    });
    if (mounted) setState(() => _busy = false);
  }

  Future<void> _shutdown() async {
    await _stopGps();
    await _operations;
    await _repository.dispose();
  }

  @override
  void dispose() {
    _closing = true;
    _activityVisible = false;
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_shutdown().catchError((Object error, StackTrace trace) {}));
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sample = _lastObservation?.fix;
    final running = _session.status == MeterStatus.running;
    return Scaffold(
      appBar: AppBar(title: const Text('Phòng thử GPS · SQLite')),
      body: ListView(padding: const EdgeInsets.all(18), children: [
        const Text('CHỈ KIỂM THỬ - KHÔNG THU CƯỚC',
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold,
              color: Color(0xFFFFB020), fontSize: 18)),
        const SizedBox(height: 12),
        const Text('Ứng dụng chỉ ghi các mẫu GPS được chấp nhận vào SQLite. '
            'Chưa có đồng hồ thu cước cho khách, chưa tạo doanh thu hoặc QR. '
            'Khi rời ứng dụng, quá trình thử bị tạm ngắt.'),
        const SizedBox(height: 16),
        Text(_message),
        const SizedBox(height: 16),
        Text('Bảng giá xác nhận: ' +
            (_confirmedTariff?.tariff.name ?? 'Chưa có; vào tab Bảng giá')),
        Text('GPS: ' + (_tracking
            ? (_freshPosition ? 'Có tín hiệu mới' : 'Chưa có tín hiệu đạt')
            : 'Đã tắt')),
        Text('Phiên: ' + (_session.hasSession
            ? (running ? 'Đang ghi GPS thử' : 'Tạm dừng')
            : 'Chưa khởi tạo')),
        Text('Điểm GPS đã lưu: ' + _session.recordedRoute.length.toString()),
        Text('Thời gian có dữ liệu: ' +
            _session.elapsedSecondsForTesting.toString() + ' giây'),
        if (sample != null && _freshPosition) ...[
          const SizedBox(height: 12),
          Text('Vĩ độ: ' + sample.latitude.toStringAsFixed(6)),
          Text('Kinh độ: ' + sample.longitude.toStringAsFixed(6)),
          Text('Sai số: ' + sample.accuracyMeters.toStringAsFixed(1) + ' m'),
        ],
        const SizedBox(height: 22),
        FilledButton.icon(
          onPressed: _busy || _startingGps || _stopGate.stopping ||
              !_ready ? null :
              (_tracking || _lease != null ? _stopGpsFromButton : _startGps),
          icon: Icon(_tracking ? Icons.stop : Icons.gps_fixed),
          label: Text(_tracking ? 'Dừng GPS thử' : 'Bật GPS thử'),
        ),
        const SizedBox(height: 8),
        FilledButton.tonal(
          onPressed: _busy || !_ready || _session.hasSession ? null : _beginLab,
          child: const Text('Bắt đầu lưu phiên GPS thử'),
        ),
        if (_session.hasSession && _labOwned) ...[
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: _busy || !_session.requiresManualResume ||
                !_freshPosition ? null : _resumeLab,
            child: const Text('Tiếp tục sau gián đoạn (thủ công)'),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: _busy ? null : _discardLab,
            child: const Text('Xóa checkpoint phiên thử'),
          ),
        ],
        if (_session.hasSession && !_labOwned)
          const Text('Checkpoint này không thuộc phòng thử. '
              'Chế độ thử sẽ không ghi đè hoặc xóa dữ liệu đó.',
              style: TextStyle(color: Color(0xFFFFB020))),
        const SizedBox(height: 32),
      ]),
    );
  }
}
