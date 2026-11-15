import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:navitaximeter/src/lab/headless_sqlite_probe.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  test('headless probe refuses a production-like database filename', () async {
    final sandbox = await Directory.systemTemp.createTemp('navi-headless-test-');
    try {
      final wrongPath = path.join(sandbox.path, 'navitaximeter_v1.db');
      expect(isDedicatedHeadlessProbePath(wrongPath), isFalse);
      await expectLater(
        writeAndVerifyHeadlessProbe(databasePath: wrongPath),
        throwsStateError,
      );
      expect(await File(wrongPath).exists(), isFalse);
    } finally {
      await sandbox.delete(recursive: true);
    }
  });

  test('isolated SQLite probe commits and survives close/reopen', () async {
    final sandbox = await Directory.systemTemp.createTemp('navi-headless-test-');
    try {
      final dbPath = path.join(sandbox.path, headlessProbeDbName);
      expect(isDedicatedHeadlessProbePath(dbPath), isTrue);
      final first = await writeAndVerifyHeadlessProbe(databasePath: dbPath);
      final second = await writeAndVerifyHeadlessProbe(databasePath: dbPath);
      expect(first['probeOnly'], isTrue);
      expect(first['reopened'], isTrue);
      expect(first['passengerFareEnabled'], isFalse);
      expect(first['databaseName'], headlessProbeDbName);
      expect(first['rowCount'], 1);
      expect(second['rowCount'], 2);
      expect(await File(dbPath).exists(), isTrue);
    } finally {
      await sandbox.delete(recursive: true);
    }
  });
}
