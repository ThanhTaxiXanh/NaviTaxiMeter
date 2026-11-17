// Issue #3 P3. TEST SUPPORT ONLY, not compiled into the application runtime.
// Exercises sqflite against a disposable clone of app v3 table SHAPES.
// No genuine GPS, passenger meter, receipts, money or production DB paths.
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

const v3FixtureName = 'DISPOSABLE_APP_V3_ONLY.db';
const v4FixtureName = 'DISPOSABLE_APP_V4_ONLY.db';
const v4FailureName = 'DISPOSABLE_APP_V4_FAIL_ONLY.db';
const frozenTestTariffHash =
    'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa';

void _checkFixtureRoot(Directory root) {
  final name = path.basename(root.path);
  if (!name.startsWith('navi-sqflite-appclone-') ||
      path.dirname(root.path) != Directory.systemTemp.path ||
      !root.existsSync() ||
      FileSystemEntity.isLinkSync(root.path)) {
    throw StateError('Refusing non-disposable sqflite fixture directory');
  }
}

/// Schema matches actual TripRepository v3 columns, but payloads are intentionally
/// NOT valid customer trip objects: these are technical preservation sentinels.
Future<Database> createV3Fixture(Directory root) async {
  _checkFixtureRoot(root);
  final file = File(path.join(root.path, v3FixtureName));
  if (await file.exists()) throw StateError('Cannot overwrite v3 source fixture');
  final db = await openDatabase(file.path, version: 3, singleInstance: false,
      onCreate: (txn, _) async {
    await txn.execute('CREATE TABLE trips (id TEXT PRIMARY KEY, '
        'started_at TEXT NOT NULL, total_fare REAL NOT NULL, '
        'distance_km REAL NOT NULL, payload TEXT NOT NULL)');
    await txn.execute('CREATE INDEX trips_started_at_idx '
        'ON trips(started_at DESC)');
    await txn.execute('CREATE TABLE active_trip ('
        'id INTEGER PRIMARY KEY CHECK (id=1), '
        'payload TEXT NOT NULL, updated_at TEXT NOT NULL)');
    await txn.execute('CREATE TABLE active_trip_route ('
        'sequence INTEGER PRIMARY KEY, latitude REAL NOT NULL, '
        'longitude REAL NOT NULL, recorded_at TEXT NOT NULL, '
        'accuracy_meters REAL NOT NULL, speed_kmh REAL NOT NULL, '
        'segment INTEGER NOT NULL)');
  });
  await db.insert('trips', {
    'id': 'TEST_RECEIPT_ONLY',
    'started_at': '2026-01-01T00:00:00Z',
    'total_fare': 0.0,
    'distance_km': 0.0,
    'payload': '{"fixtureOnly":true,"receipt":"preserve"}',
  });
  await db.insert('active_trip', {
    'id': 1,
    'updated_at': 'test-only',
    'payload': jsonEncode({
      'fixtureOnly': true,
      'routeStorage': 'sqlite-v3',
      'routeCount': 0,
      'meter': {'totalFare': 0, 'distanceMeters': 0},
      'tariffHash': frozenTestTariffHash,
    }),
  });
  return db;
}

/// Mimics the future v3->v4 tables ON A CLOSED disposable source FILE COPY.
/// This is not the application's onUpgrade, real shared-preferences backup or
/// approved schema v4. SQLite rolls back a failed onUpgrade transaction.
Future<Database> dryRunCloneV4(Directory root, {bool injectFailure = false}) async {
  _checkFixtureRoot(root);
  final source = File(path.join(root.path, v3FixtureName));
  final name = injectFailure ? v4FailureName : v4FixtureName;
  final target = File(path.join(root.path, name));
  if (!await source.exists() || await target.exists()) {
    throw StateError('Missing source or destination already exists');
  }
  await source.copy(target.path); // Source MUST have been closed by caller.
  return openDatabase(target.path, version: 4, singleInstance: false,
      onUpgrade: (txn, oldVersion, newVersion) async {
    if (oldVersion != 3 || newVersion != 4) {
      throw StateError('Only disposable v3->v4 dry run is allowed');
    }
    await txn.execute('CREATE TABLE checkpoint_fence ('
        'id INTEGER PRIMARY KEY CHECK(id=1), '
        'session_id TEXT NOT NULL, generation INTEGER NOT NULL, '
        'last_sequence INTEGER NOT NULL, last_gnss_nanos INTEGER NOT NULL, '
        'phase TEXT NOT NULL)');
    if (injectFailure) throw StateError('Injected upgrade failure');
    await txn.execute('CREATE TABLE checkpoint_ack ('
        'session_id TEXT NOT NULL, generation INTEGER NOT NULL, '
        'sequence INTEGER NOT NULL, sample_digest TEXT NOT NULL, '
        'checkpoint_id TEXT NOT NULL, '
        'PRIMARY KEY(session_id,generation,sequence))');
    await txn.insert('checkpoint_fence', {
      'id': 1, 'session_id': 'TEST_SESSION_ONLY',
      'generation': 7, 'last_sequence': -1,
      'last_gnss_nanos': -1, 'phase': 'TEST_ACTIVE',
    });
  });
}

/// Immutable synthetic TEST input. No caller may treat this as physical GNSS.
class CloneFix {
  const CloneFix({
    required this.sequence,
    required this.gnssNanos,
    this.latitude = 0.0,
    this.longitude = 0.0,
    this.accuracy = 5.0,
    this.speed = 0.0,
    this.segment = 0,
    this.mocked = false,
    this.tariffHash = frozenTestTariffHash,
  });
  final int sequence;
  final int gnssNanos;
  final double latitude, longitude, accuracy, speed;
  final int segment;
  final bool mocked;
  final String tariffHash;

  String get digest => sha256.convert(utf8.encode(jsonEncode([
    sequence, gnssNanos, latitude, longitude,
    accuracy, speed, segment, mocked, tariffHash,
  ]))).toString();

  Map<String, Object> get routeRow => {
    'sequence': sequence,
    'latitude': latitude,
    'longitude': longitude,
    'recorded_at': 'TEST_ONLY_' + sequence.toString(),
    'accuracy_meters': accuracy,
    'speed_kmh': speed,
    'segment': segment,
  };

  void validate() {
    if (sequence < 0 || gnssNanos <= 0 || mocked ||
        !latitude.isFinite || latitude.abs() > 90 ||
        !longitude.isFinite || longitude.abs() > 180 ||
        !accuracy.isFinite || accuracy < 0 || accuracy > 30 ||
        !speed.isFinite || speed < 0 || speed > 220 ||
        segment < 0 || tariffHash != frozenTestTariffHash) {
      throw StateError('Untrusted test candidate or tariff mismatch');
    }
  }
}

class CloneAck {
  const CloneAck(this.sequence, this.id);
  final int sequence;
  final String id;
}

enum CloneFailAt { none, beforeRoute, afterRoute, afterHeader, beforeLedger }

/// Exactly one Dart queue and a single sqflite Database object for the CLONE.
/// This is NOT the production trip mutation authority or a live GPS service.
class CloneAckWriter {
  CloneAckWriter(this.db);
  final Database db;
  Future<void> _tail = Future<void>.value();
  bool _suspended = false;
  bool get suspended => _suspended;

  Future<CloneAck> append(CloneFix fix, {
    int generation = 7,
    CloneFailAt failAt = CloneFailAt.none,
    bool loseAckAfterCommit = false,
  }) {
    final call = _tail.then((_) => _appendOnce(
        fix, generation, failAt, loseAckAfterCommit));
    _tail = call.then<void>((_) {}, onError: (Object _, StackTrace __) {});
    return call;
  }

  Future<CloneAck> _appendOnce(CloneFix fix, int generation,
      CloneFailAt failAt, bool loseAckAfterCommit) async {
    if (_suspended) throw StateError('PAUSED: no further writes');
    // A stale request cannot poison a newer accepted generation.
    if (generation != 7) throw StateError('Stale session generation');
    try {
      fix.validate();
      final ack = await db.transaction((txn) async {
        final owner = (await txn.query('checkpoint_fence',
            where: 'id=?', whereArgs: [1])).single;
        if (owner['session_id'] != 'TEST_SESSION_ONLY' ||
            owner['generation'] != generation ||
            owner['phase'] != 'TEST_ACTIVE') {
          throw StateError('Durable owner mismatch or PAUSED');
        }
        final last = owner['last_sequence'] as int;
        final lastNanos = owner['last_gnss_nanos'] as int;
        final headerText = (await txn.query('active_trip',
            columns: ['payload'], where: 'id=?', whereArgs: [1])).single['payload'] as String;
        final header = Map<String, dynamic>.from(jsonDecode(headerText) as Map);
        final meter = Map<String, dynamic>.from(header['meter'] as Map);
        final rows = await txn.query('active_trip_route', orderBy: 'sequence ASC');
        if (header['fixtureOnly'] != true || header['tariffHash'] != frozenTestTariffHash ||
            header['routeStorage'] != 'sqlite-v3' ||
            header['routeCount'] != rows.length ||
            rows.length != last + 1 ||
            (meter['totalFare'] as num) != 0 ||
            (meter['distanceMeters'] as num) != 0) {
          throw StateError('Persisted header, tariff, money or route mismatch');
        }
        for (var i = 0; i < rows.length; i++) {
          if (rows[i]['sequence'] != i) throw StateError('Route ordering gap');
        }

        if (fix.sequence == last && last >= 0) {
          final receipts = await txn.query('checkpoint_ack',
              where: 'session_id=? AND generation=? AND sequence=?',
              whereArgs: ['TEST_SESSION_ONLY', generation, fix.sequence]);
          if (receipts.length != 1 || receipts.single['sample_digest'] != fix.digest ||
              rows[last]['latitude'] != fix.latitude ||
              rows[last]['longitude'] != fix.longitude ||
              rows[last]['accuracy_meters'] != fix.accuracy ||
              rows[last]['speed_kmh'] != fix.speed ||
              rows[last]['segment'] != fix.segment) {
            throw StateError('Conflicting durable replay');
          }
          return CloneAck(last, receipts.single['checkpoint_id'] as String);
        }
        if (fix.sequence != last + 1 ||
            (lastNanos >= 0 && (fix.gnssNanos <= lastNanos ||
                fix.gnssNanos - lastNanos > 12000000000))) {
          throw StateError('Missing sequence or GNSS gap');
        }

        // Immutable staged candidate: never mutate an in-memory TaximeterEngine.
        // Only the copy inside a successful transaction becomes visible.
        final candidateHeader = jsonEncode({
          ...header,
          'routeCount': fix.sequence + 1,
          'meter': Map<String, dynamic>.from(meter),
        });
        if (failAt == CloneFailAt.beforeRoute) throw StateError('before route');
        await txn.insert('active_trip_route', fix.routeRow);
        if (failAt == CloneFailAt.afterRoute) throw StateError('after route');
        await txn.update('active_trip', {
          'payload': candidateHeader, 'updated_at': 'test-only',
        }, where: 'id=?', whereArgs: [1]);
        if (failAt == CloneFailAt.afterHeader) throw StateError('after header');
        await txn.update('checkpoint_fence', {
          'last_sequence': fix.sequence,
          'last_gnss_nanos': fix.gnssNanos,
        }, where: 'id=?', whereArgs: [1]);
        if (failAt == CloneFailAt.beforeLedger) throw StateError('before ledger');
        final checkpointId = sha256.convert(utf8.encode(
            'TEST_SESSION_ONLY:7:' + fix.digest)).toString();
        await txn.insert('checkpoint_ack', {
          'session_id': 'TEST_SESSION_ONLY', 'generation': generation,
          'sequence': fix.sequence, 'sample_digest': fix.digest,
          'checkpoint_id': checkpointId,
        });
        return CloneAck(fix.sequence, checkpointId);
      });
      // This line is reached only AFTER sqflite transaction Future completes.
      if (loseAckAfterCommit) {
        _suspended = true;
        throw StateError('Synthetic lost transport ACK after COMMIT');
      }
      return ack;
    } catch (_) {
      _suspended = true; // Unknown completion must fail closed.
      rethrow;
    }
  }

  Future<Map<String, Object?>> recoverPaused() async {
    _suspended = true;
    return db.transaction((txn) async {
      final f = (await txn.query('checkpoint_fence', where: 'id=?',
          whereArgs: [1])).single;
      final last = f['last_sequence'] as int;
      final count = Sqflite.firstIntValue(await txn.rawQuery(
          'SELECT COUNT(*) FROM active_trip_route'))!;
      final ackCount = Sqflite.firstIntValue(await txn.rawQuery(
          'SELECT COUNT(*) FROM checkpoint_ack'))!;
      final headerText = (await txn.query('active_trip', where: 'id=?',
          whereArgs: [1])).single['payload'] as String;
      final header = jsonDecode(headerText) as Map;
      if (count != last + 1 || ackCount != count ||
          header['routeCount'] != count || header['fixtureOnly'] != true) {
        throw StateError('Cannot recover corrupted fixture');
      }
      await txn.update('checkpoint_fence', {'phase': 'PAUSED'},
          where: 'id=?', whereArgs: [1]);
      return {'phase': 'PAUSED', 'sequence': last, 'routeCount': count};
    });
  }
}
