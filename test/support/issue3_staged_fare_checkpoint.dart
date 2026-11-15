// Issue #3 P4 TEST-ONLY staging against an actual TripRepository sqflite
// v3 checkpoint in a strictly disposable database. Never use passenger data.
import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:navitaximeter/src/core/taximeter_engine.dart';
import 'package:navitaximeter/src/data/trip_repository.dart';
import 'package:navitaximeter/src/data/trip_session_snapshot.dart';
import 'package:navitaximeter/src/domain/trip_route_point.dart';

const stageFixtureName = 'DISPOSABLE_FARE_STAGE_ONLY.db';

/// No real fare config is read; use a visible synthetic test sentinel.
const syntheticStageTariff = TariffConfig(
  name: 'CHỈ KIỂM THỬ - KHÔNG THU CƯỚC',
  baseFare: 10000, baseDistanceKm: 0, perKmRate: 10000,
  longDistanceThresholdKm: 30, longDistancePerKmRate: 8000,
  waitingFeePerHour: 0, roundToThousands: false,
);

/// Mirrors the candidate-before-commit pattern, but is NOT used in app UI.
/// Snapshot and fare become observable ONLY after repository transaction Future.
class TestOnlyFareStage {
  TestOnlyFareStage._(this.repository, this._published, this._lastFix,
      this._lastReceivedAt);

  final TripRepository repository;
  TaximeterEngine _published;
  GpsFix _lastFix;
  DateTime _lastReceivedAt;
  int _savedPoints = 1;
  bool _faulted = false;
  Future<void> _tail = Future<void>.value();

  bool get faulted => _faulted;
  double get publishedFare => _published.totalFare;
  double get publishedDistanceMeters => _published.distanceMeters;
  int get publishedElapsed => _published.elapsedSeconds;
  Map<String, dynamic> get publishedSnapshot => _published.exportSnapshot();

  static Future<TestOnlyFareStage> begin({
    required Directory sandbox,
    required DateTime at,
  }) async {
    final folder = path.basename(sandbox.path);
    if (path.dirname(sandbox.path) != Directory.systemTemp.path ||
        !folder.startsWith('navi-fare-stage-') ||
        !sandbox.existsSync() || FileSystemEntity.isLinkSync(sandbox.path)) {
      throw StateError('Test-only fare writer refuses non-disposable path');
    }
    final dbFile = File(path.join(sandbox.path, stageFixtureName));
    if (await dbFile.exists()) throw StateError('Refuse to reuse existing DB');
    final repository = TripRepository(databasePath: dbFile.path);
    final meter = TaximeterEngine(tariff: syntheticStageTariff)..start(at: at);
    final firstFix = GpsFix(
      latitude: 0, longitude: 0, accuracyMeters: 1, speedKmh: 20,
      timestamp: at,
    );
    if (!meter.acceptGps(firstFix)) {
      throw StateError('Synthetic initial fix rejected');
    }
    final initialSnapshot = TripSessionSnapshot.fromEngine(meter);
    try {
      await repository.beginActive(initialSnapshot);
      await repository.saveActiveIncremental(
        snapshot: initialSnapshot,
        routeStartIndex: 0,
        appendedPoints: [_point(firstFix)],
      );
      return TestOnlyFareStage._(repository, meter, firstFix, at);
    } catch (_) {
      await repository.dispose();
      rethrow;
    }
  }

  static TripRoutePoint _point(GpsFix fix) => TripRoutePoint(
    latitude: fix.latitude, longitude: fix.longitude,
    recordedAt: fix.timestamp, accuracyMeters: fix.accuracyMeters,
    speedKmh: fix.speedKmh, segment: 0,
  );

  Future<T> _serial<T>(Future<T> Function() operation) {
    final op = _tail.then((_) => operation());
    _tail = op.then<void>((_) {}, onError: (Object _, StackTrace __) {});
    return op;
  }

  /// A storage fault blocks all further writes, even if the actual SQL
  /// transaction rolled back. A new object must recover from SQLite as PAUSED.
  Future<bool> stageAndCommit({
    required GpsFix fix,
    required DateTime receivedAt,
    Future<void> Function()? beforeWrite,
  }) => _serial(() async {
    if (_faulted) throw StateError('TEST storage fault: recover PAUSED');
    if (!fix.timestamp.isAfter(_lastFix.timestamp) ||
        !receivedAt.isAfter(_lastReceivedAt) ||
        receivedAt.difference(fix.timestamp).isNegative ||
        receivedAt.difference(fix.timestamp) > const Duration(seconds: 12) ||
        receivedAt.difference(_lastReceivedAt) > const Duration(seconds: 12) ||
        !_published.isValidGpsObservation(fix)) {
      return false; // No staging/publishing for invalid fixture.
    }

    // forkForCheckpoint preserves GNSS anchor, tick and waiting state.
    // The old _published meter is never passed into the SQLite write.
    final candidate = _published.forkForCheckpoint();
    if (!candidate.acceptGps(fix)) return false;
    candidate.tick(receivedAt);
    // Freeze the checkpoint value as well as isolating the live meter. Only
    // primitive meter snapshot fields are included; callers cannot edit it.
    final candidateSnapshot = TripSessionSnapshot(
      meter: Map<String, dynamic>.unmodifiable(candidate.exportSnapshot()),
      tariff: candidate.tariff,
      pickup: '',
      dropoff: '',
    );
    try {
      // Test hook holds the candidate between calculation and COMMIT.
      // UI-visible published values must remain unchanged during this wait.
      if (beforeWrite != null) await beforeWrite();
      await repository.saveActiveIncremental(
        snapshot: candidateSnapshot,
        routeStartIndex: _savedPoints,
        appendedPoints: [_point(fix)],
      );
      // Only here, after the transaction is complete, publish money/time/km.
      _published = candidate;
      _savedPoints += 1;
      _lastFix = fix;
      _lastReceivedAt = receivedAt;
      return true;
    } catch (_) {
      _faulted = true;
      rethrow;
    }
  });

  Future<TripSessionSnapshot> readDurable() async {
    final text = await repository.loadActive();
    if (text == null) throw StateError('Missing disposable checkpoint');
    return TripSessionSnapshot.decode(text);
  }
}
