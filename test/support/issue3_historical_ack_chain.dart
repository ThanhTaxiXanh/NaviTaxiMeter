// Issue #3 P1 historical checkpoint integrity, TEST ONLY.
// The extra table exists only in a disposable sqflite v4-shaped clone.
// Hash chains detect accidental/injected modifications, not adversaries who
// can rewrite the entire SQLite file. NOT production security or migration.
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:navitaximeter/src/data/tariff_codec.dart';
import 'package:navitaximeter/src/data/trip_session_snapshot.dart';
import 'package:sqflite/sqflite.dart';

import 'issue3_sqflite_clone_writer.dart';
import 'issue3_staged_fare_checkpoint.dart';

const unifiedHistoryGenesis = 'TEST_ONLY_GENESIS_V1';

String unifiedHistoryLink(String previous, String checkpointId) =>
    sha256.convert(utf8.encode('$previous:$checkpointId')).toString();

Future<void> createUnifiedHistoryTable(DatabaseExecutor txn) async {
  await txn.execute('CREATE TABLE unified_checkpoint_history_test_only ('
      'sequence INTEGER PRIMARY KEY, '
      'session_id TEXT NOT NULL, generation INTEGER NOT NULL, '
      'gnss_nanos INTEGER NOT NULL, recorded_at TEXT NOT NULL, '
      'header_text TEXT NOT NULL, prior_history_id TEXT NOT NULL, '
      'history_id TEXT NOT NULL)');
}

/// Identity of the last durable chain element after checking EVERY row.
/// Requires live immutable fare snapshots at each checkpoint, so this table
/// would be too bulky for production; it only exercises the correctness gate.
Future<String> verifyUnifiedHistory({
  required DatabaseExecutor txn,
  required List<Map<String, Object?>> routes,
  required List<Map<String, Object?>> acks,
  required String finalHeader,
  required int lastSequence,
  required int lastGnssNanos,
}) async {
  final history = await txn.query('unified_checkpoint_history_test_only',
      orderBy: 'sequence ASC');
  if (routes.length != acks.length || routes.length != history.length ||
      routes.length != lastSequence + 1) {
    throw StateError('History route/ACK/fence count mismatch');
  }
  var previous = unifiedHistoryGenesis;
  var previousNanos = -1;
  var previousMeters = 0.0;
  var previousElapsed = 0;
  for (var i = 0; i < history.length; i++) {
    final route = routes[i], ack = acks[i], h = history[i];
    final nanos = h['gnss_nanos'];
    final checkpointId = ack['checkpoint_id'];
    final historicalHeader = h['header_text'];
    final recordedAt = h['recorded_at'];
    final rawDate = route['recorded_at'];
    if (route['sequence'] != i || ack['sequence'] != i ||
        h['sequence'] != i || h['session_id'] != 'TEST_SESSION_ONLY' ||
        h['generation'] != 7 ||
        ack['session_id'] != 'TEST_SESSION_ONLY' ||
        ack['generation'] != 7 ||
        nanos is! int || nanos <= 0 ||
        (previousNanos >= 0 &&
            (nanos <= previousNanos || nanos - previousNanos > 12000000000)) ||
        checkpointId is! String ||
        historicalHeader is! String ||
        recordedAt is! String ||
        rawDate is! String || recordedAt != rawDate ||
        DateTime.tryParse(recordedAt) == null ||
        h['prior_history_id'] != previous) {
      throw StateError('Historical route/session/sequence identity mismatch');
    }
    // Rebuild the exact synthetic test sample digest from durable route and
    // the per-point monotonic GNSS nanos, not from the proposed IPC payload.
    final sample = CloneFix(
      sequence: i, gnssNanos: nanos,
      latitude: (route['latitude'] as num).toDouble(),
      longitude: (route['longitude'] as num).toDouble(),
      accuracy: (route['accuracy_meters'] as num).toDouble(),
      speed: (route['speed_kmh'] as num).toDouble(),
      segment: route['segment'] as int,
    );
    sample.validate();
    final encoded = jsonDecode(historicalHeader);
    if (encoded is! Map || encoded['routeCount'] != i + 1 ||
        encoded['routeStorage'] != 'sqlite-v3' ||
        encoded['tariffHash'] != frozenTestTariffHash ||
        ack['sample_digest'] != sample.digest ||
        checkpointId != unifiedTestCheckpointId(sample.digest, historicalHeader)) {
      throw StateError('Historical sample, tariff or checkpoint hash mismatch');
    }
    final snapshot = TripSessionSnapshot.decode(historicalHeader);
    if (TariffCodec.encode(snapshot.tariff) !=
        TariffCodec.encode(syntheticStageTariff)) {
      throw StateError('Historical frozen tariff mismatch');
    }
    final distance = snapshot.meter['distanceMeters'];
    final elapsed = snapshot.meter['elapsedSeconds'];
    if (distance is! num || elapsed is! int ||
        !distance.toDouble().isFinite ||
        distance.toDouble() < previousMeters || elapsed < previousElapsed) {
      throw StateError('Historical money/time progression invalid');
    }
    previousMeters = distance.toDouble();
    previousElapsed = elapsed;
    previousNanos = nanos;
    final current = unifiedHistoryLink(previous, checkpointId);
    if (h['history_id'] != current) {
      throw StateError('Historical chained ledger identity mismatch');
    }
    previous = current;
  }
  if (history.isEmpty) {
    if (lastGnssNanos != -1) throw StateError('Empty history GNSS fence');
  } else if (history.last['header_text'] != finalHeader ||
      lastGnssNanos != previousNanos) {
    throw StateError('Last durable header or GNSS fence mismatch');
  }
  return previous;
}

// Defined here to avoid a circular dependency on the unified worker itself.
String unifiedTestCheckpointId(String sampleDigest, String headerText) {
  final headerDigest = sha256.convert(utf8.encode(headerText)).toString();
  return sha256.convert(utf8.encode('$sampleDigest:$headerDigest')).toString();
}
