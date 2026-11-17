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
  test('single logical probe writer serializes eight concurrent requests',
      () async {
    final sandbox = await Directory.systemTemp.createTemp('navi-headless-test-');
    try {
      final dbPath = path.join(sandbox.path, headlessProbeDbName);
      final writer = SerializedHeadlessProbeWriter();
      final results = await Future.wait(List.generate(8, (_) =>
          writer.writeAndVerify(databasePath: dbPath)));
      final counts = results.map((result) => result['rowCount']).toList();
      expect(counts, [1, 2, 3, 4, 5, 6, 7, 8]);
      expect(results.every((result) =>
          result['probeOnly'] == true &&
          result['passengerFareEnabled'] == false), isTrue);
      final db = await openDatabase(dbPath, readOnly: true);
      try {
        expect(Sqflite.firstIntValue(await db.rawQuery(
          'SELECT count FROM headless_probe WHERE id=1',
        )), 8);
      } finally {
        await db.close();
      }
    } finally {
      await sandbox.delete(recursive: true);
    }
  });

  test('invalid request fails closed without poisoning serialized probe',
      () async {
    final sandbox = await Directory.systemTemp.createTemp('navi-headless-test-');
    try {
      final writer = SerializedHeadlessProbeWriter();
      final wrong = path.join(sandbox.path, 'navitaximeter_v1.db');
      final good = path.join(sandbox.path, headlessProbeDbName);
      await expectLater(writer.writeAndVerify(databasePath: wrong),
          throwsStateError);
      final result = await writer.writeAndVerify(databasePath: good);
      expect(result['rowCount'], 1);
      expect(await File(wrong).exists(), isFalse);
    } finally {
      await sandbox.delete(recursive: true);
    }
  });

}
