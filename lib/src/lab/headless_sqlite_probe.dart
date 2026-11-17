import 'dart:ui' show DartPluginRegistrant;

import 'debug_checkpoint_transport.dart';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

/// A DEBUG-ONLY Android lifecycle experiment. Never a taxi-trip writer.
///
/// Only the debug-manifest HeadlessSqliteProbeService invokes this entrypoint.
/// Its isolated DB has no trip, tariff, location, or receipt table.
const headlessProbeDbName = 'navitaximeter_HEADLESS_PROBE_ONLY.db';
const headlessProbeChannel = 'vn.navitaximeter/headless_sqlite_probe';

bool isDedicatedHeadlessProbePath(String databasePath) =>
    path.basename(databasePath) == headlessProbeDbName;

/// Test one real sqflite transaction, close the connection, and read it back.
///
/// This is NOT an ACK for passenger metering, and a success return does NOT
/// prove fsync/power-cut durability or background lifecycle behavior.
/// The only allowed table is a probe counter in a disposable named database.
Future<Map<String, Object?>> writeAndVerifyHeadlessProbe({
  String? databasePath,
}) async {
  final dbPath = databasePath ??
      path.join(await getDatabasesPath(), headlessProbeDbName);
  if (!isDedicatedHeadlessProbePath(dbPath)) {
    throw StateError('Headless probe refuses an application trip database');
  }
  final db = await openDatabase(
    dbPath,
    version: 1,
    onCreate: (database, _) async {
      await database.execute(
        'CREATE TABLE headless_probe ('
        'id INTEGER PRIMARY KEY CHECK(id=1), '
        'count INTEGER NOT NULL)',
      );
      await database.insert('headless_probe', {'id': 1, 'count': 0});
    },
  );
  try {
    await db.transaction((txn) async {
      final old = Sqflite.firstIntValue(await txn.rawQuery(
            'SELECT count FROM headless_probe WHERE id=1',
          )) ??
          0;
      await txn.update('headless_probe', {'count': old + 1},
          where: 'id=?', whereArgs: [1]);
    });
  } finally {
    await db.close();
  }

  final reopened = await openDatabase(dbPath, readOnly: true);
  try {
    final persisted = Sqflite.firstIntValue(await reopened.rawQuery(
      'SELECT count FROM headless_probe WHERE id=1',
    ));
    if (persisted == null || persisted < 1) {
      throw StateError('Probe row missing after reopen');
    }
    return {
      'probeOnly': true,
      'databaseName': headlessProbeDbName,
      'reopened': true,
      'rowCount': persisted,
      'passengerFareEnabled': false,
    };
  } finally {
    await reopened.close();
  }
}

/// One logical writer/queue for this *disposable probe*, not the trip DB.
/// Serializing Dart method calls prevents overlapping SQLite probe mutations
/// even when native sends multiple requests before earlier ACK callbacks.
class SerializedHeadlessProbeWriter {
  Future<void> _tail = Future<void>.value();

  Future<Map<String, Object?>> writeAndVerify({String? databasePath}) {
    final next = _tail.then((_) =>
        writeAndVerifyHeadlessProbe(databasePath: databasePath));
    // An erroneous request must fail its caller, but not poison the queue.
    _tail = next.then<void>((_) {}, onError: (Object _, StackTrace __) {});
    return next;
  }
}

/// Entrypoint is referenced by name only from the *debug-only* Android service.
/// No GPS subscriptions, routes, billing APIs, or commercial fare calculations.
@pragma('vm:entry-point')
Future<void> runHeadlessSqliteProbe() async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  const channel = MethodChannel(headlessProbeChannel);
  final writer = SerializedHeadlessProbeWriter();
  final debugCheckpoint = DebugCheckpointTransport();
  channel.setMethodCallHandler((call) async {
    if (call.method == 'writeAndRead') {
      return writer.writeAndVerify();
    }
    if (call.method == 'debugCheckpoint') {
      final wire = call.arguments;
      if (wire is! Map) {
        throw const FormatException('Expected DEBUG proposal map');
      }
      return debugCheckpoint.submit(wire);
    }
    throw MissingPluginException('Unsupported headless probe method');
  });
  await channel.invokeMethod<void>('ready');
}
