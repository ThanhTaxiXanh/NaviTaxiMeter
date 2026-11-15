// Issue #3 P1 unified TEST-ONLY proof. This file is under test/support only.
// No Android IPC, genuine GNSS, customer fare, production DB or v4 migration.
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:navitaximeter/src/core/taximeter_engine.dart';
import 'package:navitaximeter/src/data/trip_session_snapshot.dart';
import 'package:navitaximeter/src/data/tariff_codec.dart';
import 'package:navitaximeter/src/lab/trip_ipc_contract.dart';
import 'package:sqflite/sqflite.dart';

import 'issue3_sqflite_clone_writer.dart';
import 'issue3_staged_fare_checkpoint.dart';

enum UnifiedFailAt {
  none, beforeRoute, afterRoute, afterHeader, afterFence, afterLedger,
}

/// Binds the ledger identity to BOTH the trusted sample digest and the exact
/// committed meter/header bytes; recovery must recompute this on the CLONE.
String unifiedTestCheckpointId(String sampleDigest, String headerText) {
  final headerDigest = sha256.convert(utf8.encode(headerText)).toString();
  return sha256.convert(
      utf8.encode('$sampleDigest:$headerDigest')).toString();
}

/// One queued IPC gate, one Dart meter owner and one sqflite connection on a
/// DISPOSABLE v3-shaped -> v4 CLONE. Unlike older independent proofs, a single
/// transaction now contains REAL Dart candidate fare, route, fence and ACK.
/// It deliberately never opens navitaximeter_v1.db or driver preferences.
class UnifiedTestOnlyWorker {
  UnifiedTestOnlyWorker._(
    this.db, this.at, this._published, this._fixtures,
    this.beforeWrite, this.afterCommit,
  ) {
    gate = IpcCheckpointGate(
      fence: IpcFence('TEST_SESSION_ONLY', 7),
      frozenTariffHash: frozenTestTariffHash,
      writer: _commit,
    );
  }

  final Database db;
  final DateTime at;
  TaximeterEngine _published;
  final Map<String, CloneFix> _fixtures;
  final Future<void> Function()? beforeWrite;
  final Future<void> Function()? afterCommit;
  late final IpcCheckpointGate gate;
  bool _faulted = false;

  bool get faulted => _faulted;
  double get publishedFare => _published.totalFare;
  double get publishedMeters => _published.distanceMeters;
  int get publishedElapsed => _published.elapsedSeconds;
  Map<String, dynamic> get publishedMeter =>
      Map<String, dynamic>.unmodifiable(_published.exportSnapshot());

  static Future<UnifiedTestOnlyWorker> begin({
    required Database db,
    required DateTime at,
    required Iterable<CloneFix> immutableFixtures,
    Future<void> Function()? beforeWrite,
    Future<void> Function()? afterCommit,
  }) async {
    final engine = TaximeterEngine(tariff: syntheticStageTariff)
      ..start(at: at);
    final frozen = Map<String, CloneFix>.unmodifiable({
      for (final fix in immutableFixtures) fix.digest: fix,
    });
    // This initialization touches only an already-created disposable v4
    // clone. There is deliberately no app schema upgrade path here.
    await db.transaction((txn) async {
      final f = (await txn.query('checkpoint_fence')).single;
      final n = Sqflite.firstIntValue(
          await txn.rawQuery('SELECT COUNT(*) FROM active_trip_route'))!;
      if (f['session_id'] != 'TEST_SESSION_ONLY' ||
          f['generation'] != 7 || f['last_sequence'] != -1 ||
          f['phase'] != 'TEST_ACTIVE' || n != 0) {
        throw StateError('Refusing nonempty or foreign disposable clone');
      }
      final base = jsonDecode(TripSessionSnapshot.fromEngine(engine)
          .encodeSqliteHeader(routeCount: 0)) as Map<String, dynamic>;
      base['tariffHash'] = frozenTestTariffHash;
      final changed = await txn.update('active_trip', {
        'payload': jsonEncode(base),
        'updated_at': 'TEST_ONLY_INITIAL',
      }, where: 'id=?', whereArgs: [1]);
      if (changed != 1) throw StateError('Missing test header');
    });
    return UnifiedTestOnlyWorker._(
        db, at, engine, frozen, beforeWrite, afterCommit);
  }

  static IpcProposal proposal(CloneFix fix, {IpcFence? fence}) =>
      IpcProposal(
        fence: fence ?? IpcFence('TEST_SESSION_ONLY', 7),
        sequence: fix.sequence,
        gnssElapsedRealtimeNanos: fix.gnssNanos,
        accuracyMeters: fix.accuracy,
        speedKmh: fix.speed,
        mocked: fix.mocked,
        tariffHash: fix.tariffHash,
        payloadHash: fix.digest,
      );

  GpsFix _gps(CloneFix f) => GpsFix(
        latitude: f.latitude, longitude: f.longitude,
        accuracyMeters: f.accuracy, speedKmh: f.speed,
        timestamp: at.add(Duration(seconds: f.sequence * 5)),
      );

  Future<IpcCommitProof> _commit(IpcProposal p) async {
    if (_faulted) throw StateError('TEST writer already faulted');
    try {
      final fix = _fixtures[p.payloadHash];
      if (fix == null || p.fence != gate.fence ||
          p.sequence != fix.sequence ||
          p.gnssElapsedRealtimeNanos != fix.gnssNanos ||
          p.accuracyMeters != fix.accuracy ||
          p.speedKmh != fix.speed || p.mocked != fix.mocked ||
          p.tariffHash != fix.tariffHash) {
        throw StateError('IPC metadata does not bind immutable fixture');
      }
      fix.validate();
      final gps = _gps(fix);
      if (!_published.isValidGpsObservation(gps)) {
        throw StateError('Untrusted test observation');
      }

      // A separate engine copy retains private distance anchors and waiting
      // grace. Never mutate the published object before SQL COMMIT.
      final candidate = _published.forkForCheckpoint();
      if (!candidate.acceptGps(gps)) {
        throw StateError('Fare engine rejected synthetic sample');
      }
      candidate.tick(gps.timestamp);
      final staged = jsonDecode(TripSessionSnapshot.fromEngine(candidate)
          .encodeSqliteHeader(routeCount: fix.sequence + 1))
          as Map<String, dynamic>;
      staged['tariffHash'] = frozenTestTariffHash;
      final nextHeader = jsonEncode(staged);
      if (beforeWrite != null) await beforeWrite!();

      final checkpointId = await db.transaction((txn) async {
        final f = (await txn.query('checkpoint_fence',
            where: 'id=?', whereArgs: [1])).single;
        final last = f['last_sequence'] as int;
        final lastNanos = f['last_gnss_nanos'] as int;
        if (f['session_id'] != p.fence.sessionId ||
            f['generation'] != p.fence.generation ||
            f['phase'] != 'TEST_ACTIVE' || p.sequence != last + 1 ||
            (lastNanos >= 0 && (fix.gnssNanos <= lastNanos ||
                fix.gnssNanos - lastNanos > 12000000000))) {
          throw StateError('Durable fence, generation, sequence or GPS gap');
        }
        final rows = await txn.query('active_trip_route',
            orderBy: 'sequence ASC');
        final acks = await txn.query('checkpoint_ack',
            orderBy: 'sequence ASC');
        final oldText = (await txn.query('active_trip',
            where: 'id=?', whereArgs: [1])).single['payload'] as String;
        final old = jsonDecode(oldText) as Map;
        final oldSnapshot = TripSessionSnapshot.decode(oldText);
        if (rows.length != last + 1 || acks.length != rows.length ||
            old['routeCount'] != rows.length ||
            old['routeStorage'] != 'sqlite-v3' ||
            old['tariffHash'] != frozenTestTariffHash ||
            oldSnapshot.tariff.name != syntheticStageTariff.name ||
            jsonEncode(old['meter']) !=
                jsonEncode(_published.exportSnapshot())) {
          throw StateError('Current fare, tariff, header or journal mismatch');
        }
        for (var i = 0; i < rows.length; i++) {
          if (rows[i]['sequence'] != i ||
              acks[i]['sequence'] != i ||
              acks[i]['session_id'] != p.fence.sessionId ||
              acks[i]['generation'] != p.fence.generation) {
            throw StateError('Durable route/ACK journal gap');
          }
        }

        if (_failAt == UnifiedFailAt.beforeRoute) {
          throw StateError('Injected before route');
        }
        await txn.insert('active_trip_route', {
          ...fix.routeRow,
          'recorded_at': gps.timestamp.toIso8601String(),
        }, conflictAlgorithm: ConflictAlgorithm.abort);
        if (_failAt == UnifiedFailAt.afterRoute) {
          throw StateError('Injected after route');
        }
        final updated = await txn.update('active_trip', {
          'payload': nextHeader, 'updated_at': 'TEST_ONLY_COMMITTED',
        }, where: 'id=?', whereArgs: [1]);
        if (updated != 1) throw StateError('Missing active trip header');
        if (_failAt == UnifiedFailAt.afterHeader) {
          throw StateError('Injected after header');
        }
        final fenceUpdated = await txn.update('checkpoint_fence', {
          'last_sequence': p.sequence, 'last_gnss_nanos': fix.gnssNanos,
        }, where: 'id=?', whereArgs: [1]);
        if (fenceUpdated != 1) throw StateError('Missing session fence');
        if (_failAt == UnifiedFailAt.afterFence) {
          throw StateError('Injected after fence');
        }
        final id = unifiedTestCheckpointId(fix.digest, nextHeader);
        await txn.insert('checkpoint_ack', {
          'session_id': p.fence.sessionId,
          'generation': p.fence.generation,
          'sequence': p.sequence,
          'sample_digest': p.payloadHash,
          'checkpoint_id': id,
        }, conflictAlgorithm: ConflictAlgorithm.abort);
        if (_failAt == UnifiedFailAt.afterLedger) {
          throw StateError('Injected after ledger');
        }
        return id;
      });

      // The transaction Future has COMPLETED here, not merely dispatched.
      // A lost callback leaves durable money in SQLite but no new visible
      // money/ACK. Recovery must read it and go PAUSED.
      if (afterCommit != null) await afterCommit!();
      if (gate.phase != IpcGatePhase.accepting) {
        throw StateError('ACK revoked during transaction');
      }
      _published = candidate;
      return IpcCommitProof(gate.fence, p.sequence, p.payloadHash, checkpointId);
    } catch (_) {
      _faulted = true;
      rethrow;
    }
  }

  UnifiedFailAt _failAt = UnifiedFailAt.none;
  void injectFault(UnifiedFailAt failAt) => _failAt = failAt;

  /// A NEW session cannot simply reattach and bill after a restart. Verify
  /// durable fare/route/ACK rows and persist PAUSED without changing money.
  static Future<TripSessionSnapshot> recoverPaused(Database db) async =>
      db.transaction((txn) async {
        final f = (await txn.query('checkpoint_fence',
            where: 'id=?', whereArgs: [1])).single;
        final last = f['last_sequence'] as int;
        final routes = await txn.query('active_trip_route',
            orderBy: 'sequence ASC');
        final acks = await txn.query('checkpoint_ack',
            orderBy: 'sequence ASC');
        final text = (await txn.query('active_trip',
            where: 'id=?', whereArgs: [1])).single['payload'] as String;
        final header = jsonDecode(text) as Map;
        final snapshot = TripSessionSnapshot.decode(text);
        if (f['session_id'] != 'TEST_SESSION_ONLY' ||
            f['generation'] != 7 ||
            (f['phase'] != 'TEST_ACTIVE' && f['phase'] != 'PAUSED') ||
            last + 1 != routes.length || routes.length != acks.length ||
            header['routeCount'] != routes.length ||
            header['tariffHash'] != frozenTestTariffHash ||
            TariffCodec.encode(snapshot.tariff) !=
                TariffCodec.encode(syntheticStageTariff) ||
            header['routeStorage'] != 'sqlite-v3') {
          throw StateError('Invalid durable unified checkpoint');
        }
        // No previously committed point exists to authenticate an edited
        // initial meter. Require the untouched test baseline instead.
        if (last == -1 && (snapshot.meter['distanceMeters'] != 0 ||
            snapshot.meter['elapsedSeconds'] != 0 ||
            snapshot.meter['waitingSeconds'] != 0 ||
            snapshot.meter['tollFee'] != 0 ||
            snapshot.meter['surcharge'] != 0 ||
            snapshot.meter['discount'] != 0)) {
          throw StateError('Uncommitted meter baseline at recovery');
        }
        for (var i = 0; i < routes.length; i++) {
          if (routes[i]['sequence'] != i ||
              acks[i]['sequence'] != i ||
              acks[i]['session_id'] != 'TEST_SESSION_ONLY' ||
              acks[i]['generation'] != 7 ||
              acks[i]['checkpoint_id'] is! String ||
              (acks[i]['checkpoint_id'] as String).isEmpty ||
              acks[i]['sample_digest'] is! String ||
              !RegExp(r'^[0-9a-f]{64}
        // independently of the persisted pre-crash running meter.
        final restored = snapshot.restore(at: DateTime.utc(2026, 11, 16));
        if (restored.status != MeterStatus.paused ||
            !restored.requiresManualResume) {
          throw StateError('Recovery did not fail closed');
        }
        await txn.update('checkpoint_fence', {'phase': 'PAUSED'},
            where: 'id=?', whereArgs: [1]);
        return snapshot;
      });
}
).hasMatch(
                  acks[i]['sample_digest'] as String)) {
            throw StateError('Corrupt route/ACK fence');
          }
        }
        // The last durable ACK is a hash of the exact *last committed*
        // header and sample. Authenticate its persisted route and GNSS
        // nanos, instead of trusting a well-formed but altered money value.
        // Old checkpoint IDs cannot be verified against the CURRENT header;
        // full historical hash chaining remains a future proof gate.
        if (last >= 0) {
          final nanos = f['last_gnss_nanos'];
          final row = routes.last;
          if (nanos is! int || nanos <= 0 ||
              row['recorded_at'] is! String ||
              DateTime.tryParse(row['recorded_at'] as String) == null) {
            throw StateError('Invalid last durable GNSS fence');
          }
          final lastFix = CloneFix(
            sequence: last,
            gnssNanos: nanos,
            latitude: (row['latitude'] as num).toDouble(),
            longitude: (row['longitude'] as num).toDouble(),
            accuracy: (row['accuracy_meters'] as num).toDouble(),
            speed: (row['speed_kmh'] as num).toDouble(),
            segment: row['segment'] as int,
          );
          lastFix.validate();
          if (acks.last['sample_digest'] != lastFix.digest ||
              acks.last['checkpoint_id'] !=
                  unifiedTestCheckpointId(lastFix.digest, text)) {
            throw StateError('Last fare/route/ACK digest mismatch');
          }
        }
        // Snapshot restoration always creates PAUSED/interrupted state,
        // independently of the persisted pre-crash running meter.
        final restored = snapshot.restore(at: DateTime.utc(2026, 11, 16));
        if (restored.status != MeterStatus.paused ||
            !restored.requiresManualResume) {
          throw StateError('Recovery did not fail closed');
        }
        await txn.update('checkpoint_fence', {'phase': 'PAUSED'},
            where: 'id=?', whereArgs: [1]);
        return snapshot;
      });
}
