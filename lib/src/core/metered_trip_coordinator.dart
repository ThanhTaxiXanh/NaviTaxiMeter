import 'dart:async';

import '../core/location_tracking_policy.dart';
import '../core/taximeter_engine.dart';
import '../data/trip_repository.dart';
import '../data/trip_session_snapshot.dart';
import '../domain/confirmed_tariffs.dart';
import '../domain/trip_record.dart';
import '../domain/trip_route_point.dart';

/// Android adapter must supply an actual geolocator observation and proof that
/// a subscribed location stream is running. This flag alone is not OS proof.
/// No smoothed camera pose may be passed to the fare engine.
class MeterGpsObservation {
  const MeterGpsObservation({
    required this.fix,
    required this.receivedAt,
    required this.isMocked,
    required this.foregroundStreamActive,
  });

  final GpsFix fix;
  final DateTime receivedAt;
  final bool isMocked;
  final bool foregroundStreamActive;

  bool isTrustedFor(TaximeterEngine meter) {
    final age = receivedAt.difference(fix.timestamp);
    return foregroundStreamActive && !isMocked &&
        !age.isNegative && age <= const Duration(seconds: 12) &&
        meter.isValidGpsObservation(fix);
  }
}

/// Safety-first fare/session coordinator. No screen may expose this as a
/// passenger-ready meter until device/lifecycle tests and approvals pass.
///
/// Every accepted GPS observation is persisted in a SQLite transaction along
/// with the meter checkpoint. On persistence error all further operations
/// are blocked until a fresh coordinator reloads the last committed snapshot.
/// No clock-only timer ever advances fare/waiting time.
class MeteredTripCoordinator {
  MeteredTripCoordinator({required TripRepository repository})
      : _repository = repository;

  final TripRepository _repository;
  final LocationTrackingPolicy _locationPolicy = LocationTrackingPolicy();
  Future<void> _lastOperation = Future<void>.value();

  TaximeterEngine? _meter;
  DateTime? _lastTrustedAt;
  DateTime? _lastFixTimestamp;
  final List<TripRoutePoint> _route = <TripRoutePoint>[];
  int _savedPoints = 0;
  int _segment = 0;
  String _pickup = '';
  String _dropoff = '';
  String _fareProfile = '';
  bool _faulted = false;

  MeterStatus? get status => _meter?.status;
  bool get requiresManualResume => _meter?.requiresManualResume ?? false;
  bool get hasSession => _meter != null;
  bool get storageFaulted => _faulted;
  double get fareForTesting => _meter?.totalFare ?? 0;
  double get distanceKmForTesting => _meter?.distanceKm ?? 0;
  int get elapsedSecondsForTesting => _meter?.elapsedSeconds ?? 0;
  List<TripRoutePoint> get recordedRoute => List.unmodifiable(_route);

  Future<T> _serial<T>(Future<T> Function() operation) {
    final future = _lastOperation.then((_) => operation());
    // Keep later operations queued even if the current operation fails.
    _lastOperation = future.then<void>((_) {}, onError: (Object _, StackTrace __) {});
    return future;
  }

  void _checkWritable() {
    if (_faulted) {
      throw StateError('Lưu dữ liệu bị lỗi: cần tải lại checkpoint trước');
    }
  }

  void _markStorageFault() {
    _faulted = true;
    final meter = _meter;
    if (meter != null && meter.status == MeterStatus.running) {
      meter.suspendForInterruption(at: _lastTrustedAt ?? meter.startedAt);
    }
    _locationPolicy.clear();
  }

  TripSessionSnapshot _snapshot(TaximeterEngine meter) =>
      TripSessionSnapshot.fromEngine(
        meter,
        pickup: _pickup,
        dropoff: _dropoff,
        fareProfileName: _fareProfile,
      );

  /// Stage an immutable-to-read meter candidate. The published meter and
  /// route MUST stay at the last known COMMITTED checkpoint until sqflite
  /// confirms the transaction. On uncertain commit, fail closed and reload.
  Future<void> _checkpoint(
    TaximeterEngine candidate,
    List<TripRoutePoint> newlyAccepted,
  ) async {
    if (_meter == null) throw StateError('Không có chuyến đang theo dõi');
    try {
      await _repository.saveActiveIncremental(
        snapshot: _snapshot(candidate),
        routeStartIndex: _savedPoints,
        appendedPoints: newlyAccepted,
      );
      // All writes are committed before any candidate becomes visible.
      _meter = candidate;
      _savedPoints += newlyAccepted.length;
      _route.addAll(newlyAccepted);
    } catch (_) {
      _markStorageFault();
      rethrow;
    }
  }

  /// Start is rejected without a real, confirmed tariff, fresh GPS, and a
  /// currently subscribed foreground location stream. No data is overwritten.
  Future<void> begin({
    required ConfirmedTariff tariff,
    required MeterGpsObservation initial,
    String pickup = '',
    String dropoff = '',
  }) => _serial(() async {
    _checkWritable();
    if (_meter != null) throw StateError('Đã có chuyến chưa hoàn tất');
    tariff.validate();
    final meter = TaximeterEngine(tariff: tariff.tariff);
    if (!initial.isTrustedFor(meter)) {
      throw StateError('Chưa có GPS thực đủ tin cậy và dịch vụ vị trí');
    }
    if (await _repository.loadActive() != null) {
      throw StateError('Có chuyến chưa hoàn tất: phải khôi phục trước');
    }

    meter.start(at: initial.receivedAt);
    if (!meter.acceptGps(initial.fix)) {
      throw StateError('Không chấp nhận GPS khởi tạo');
    }
    _pickup = pickup;
    _dropoff = dropoff;
    _fareProfile = tariff.tariff.name;
    final first = TripRoutePoint(
      latitude: initial.fix.latitude,
      longitude: initial.fix.longitude,
      recordedAt: initial.fix.timestamp,
      accuracyMeters: initial.fix.accuracyMeters,
      speedKmh: initial.fix.speedKmh,
    );
    // Reserve the trip and its initial GNSS baseline in ONE v3 SQLite
    // transaction. If COMMIT/ACK is uncertain, expose neither the candidate
    // fare nor route; the next coordinator must inspect durable recovery.
    try {
      await _repository.beginActiveWithInitialFix(
        snapshot: _snapshot(meter),
        initialPoint: first,
      );
    } catch (_) {
      _faulted = true;
      _locationPolicy.clear();
      rethrow;
    }
    _meter = meter;
    _route
      ..clear()
      ..add(first);
    _savedPoints = 1;
    _segment = 0;
    _lastTrustedAt = initial.receivedAt;
    _lastFixTimestamp = initial.fix.timestamp;
    _locationPolicy.begin(initial.receivedAt);
    _locationPolicy.acceptedFix(initial.receivedAt);
  });

  /// Load persisted original tariff and route. Always PAUSED; an Android
  /// process restart never resumes distance or waiting fees automatically.
  Future<bool> recover({required DateTime at}) => _serial(() async {
    if (_meter != null) throw StateError('Đã tải chuyến vào bộ nhớ');
    _checkWritable();
    final raw = await _repository.loadActive();
    if (raw == null) return false;
    final snapshot = TripSessionSnapshot.decode(raw);
    final meter = snapshot.restore(at: at);
    _meter = meter;
    _route
      ..clear()
      ..addAll(snapshot.routePoints);
    _savedPoints = _route.length;
    _segment = _route.isEmpty ? 0 : _route.last.segment;
    _pickup = snapshot.pickup;
    _dropoff = snapshot.dropoff;
    _fareProfile = snapshot.fareProfileName;
    _lastTrustedAt = null;
    _lastFixTimestamp = null;
    _locationPolicy.clear();
    return true;
  });

  /// Consume one fresh physical GPS position. A large unobserved interval
  /// forces suspension; the new point cannot bridge that gap or create km.
  Future<bool> accept(MeterGpsObservation observation) => _serial(() async {
    _checkWritable();
    final meter = _meter;
    if (meter == null || meter.status != MeterStatus.running) return false;
    if (!observation.foregroundStreamActive || observation.isMocked) {
      await _suspend();
      return false;
    }
    if (_locationPolicy.shouldSuspend(observation.receivedAt)) {
      await _suspend();
      return false;
    }
    if (!observation.isTrustedFor(meter) ||
        !_locationPolicy.hasRecentFix(observation.receivedAt)) {
      return false;
    }
    final lastAt = _lastTrustedAt;
    final lastFix = _lastFixTimestamp;
    if ((lastAt != null && !observation.receivedAt.isAfter(lastAt)) ||
        (lastFix != null && !observation.fix.timestamp.isAfter(lastFix))) {
      return false;
    }
    final candidate = meter.forkForCheckpoint();
    if (!candidate.acceptGps(observation.fix)) return false;
    candidate.tick(observation.receivedAt);
    final next = TripRoutePoint(
      latitude: observation.fix.latitude,
      longitude: observation.fix.longitude,
      recordedAt: observation.fix.timestamp,
      accuracyMeters: observation.fix.accuracyMeters,
      speedKmh: observation.fix.speedKmh,
      segment: _segment,
    );
    await _checkpoint(candidate, [next]);
    _lastTrustedAt = observation.receivedAt;
    _lastFixTimestamp = observation.fix.timestamp;
    _locationPolicy.acceptedFix(observation.receivedAt);
    return true;
  });

  /// Timer/OS lifecycle may only suspend, never increment monetary counters.
  Future<bool> watchdog({
    required DateTime at,
    required bool foregroundStreamActive,
  }) => _serial(() async {
    _checkWritable();
    final meter = _meter;
    if (meter == null || meter.status != MeterStatus.running) return false;
    if (!foregroundStreamActive || _locationPolicy.shouldSuspend(at)) {
      await _suspend();
      return true;
    }
    return false;
  });

  Future<void> _suspend() async {
    final meter = _meter;
    if (meter == null || meter.status != MeterStatus.running) return;
    // Count only through the last *received trusted fix*, NOT wall time.
    // A failed PAUSED save must never expose an uncommitted metering tick.
    final candidate = meter.forkForCheckpoint();
    candidate.suspendForInterruption(
        at: _lastTrustedAt ?? candidate.startedAt);
    await _checkpoint(candidate, const []);
    _locationPolicy.clear();
  }

  /// Driver must manually request resume with an independently fresh fix.
  /// The resumed GPS trace always starts a new polyline segment.
  Future<void> resume(MeterGpsObservation initial) => _serial(() async {
    _checkWritable();
    final meter = _meter;
    if (meter == null || meter.status != MeterStatus.paused ||
        !meter.requiresManualResume) {
      throw StateError('Không có chuyến cần tiếp tục thủ công');
    }
    if (!initial.isTrustedFor(meter)) {
      throw StateError('Chưa có GPS đủ tin cậy để tiếp tục');
    }
    final candidate = meter.forkForCheckpoint();
    candidate.resume(at: initial.receivedAt);
    if (!candidate.acceptGps(initial.fix)) {
      // Published PAUSED meter is untouched, with no inferred gap charge.
      throw StateError('GPS tiếp tục không hợp lệ');
    }
    final nextSegment = _route.isEmpty ? 0 : _segment + 1;
    final first = TripRoutePoint(
      latitude: initial.fix.latitude,
      longitude: initial.fix.longitude,
      recordedAt: initial.fix.timestamp,
      accuracyMeters: initial.fix.accuracyMeters,
      speedKmh: initial.fix.speedKmh,
      segment: nextSegment,
    );
    await _checkpoint(candidate, [first]);
    _segment = nextSegment;
    _lastTrustedAt = initial.receivedAt;
    _lastFixTimestamp = initial.fix.timestamp;
    _locationPolicy.begin(initial.receivedAt);
    _locationPolicy.acceptedFix(initial.receivedAt);
  });

  /// Driver confirmation is mandatory. A final clock timestamp is saved, but
  /// no unobserved seconds are billed while finishing an interrupted trip.
  Future<TripRecord> finish({
    required DateTime at,
    required bool driverConfirmed,
  }) => _serial(() async {
    _checkWritable();
    if (!driverConfirmed) throw StateError('Cần xác nhận kết thúc chuyến');
    final meter = _meter;
    if (meter == null || at.isBefore(meter.startedAt!)) {
      throw StateError('Không có chuyến hợp lệ để kết thúc');
    }
    if (meter.status == MeterStatus.running) await _suspend();
    final committed = _meter;
    if (committed == null || committed.status != MeterStatus.paused) {
      throw StateError('Chuyến chưa ở trạng thái an toàn');
    }
    // Receipt is assembled on a candidate; a failed completeActive() cannot
    // turn the last durable PAUSED trip into a phantom finished trip.
    final candidate = committed.forkForCheckpoint();
    final receipt = candidate.finish(at: at);
    final record = TripRecord.fromReceipt(
      receipt,
      pickup: _pickup,
      dropoff: _dropoff,
      fareProfileName: _fareProfile,
      tariffSnapshot: candidate.tariff,
      routePoints: _route,
    );
    try {
      await _repository.completeActive(record);
    } catch (_) {
      _markStorageFault();
      rethrow;
    }
    _meter = null;
    _route.clear();
    _savedPoints = 0;
    _lastTrustedAt = null;
    _lastFixTimestamp = null;
    _locationPolicy.clear();
    return record;
  });
}
