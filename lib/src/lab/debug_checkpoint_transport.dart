// Issue #3 P1: real Android MethodChannel -> service-owned Dart sqflite.
// DEBUG/INSTRUMENTATION ONLY. No GNSS observations, coordinates, fare,
// tariff, trip DB, or passenger charging. This is NOT a production writer.
import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

/// Separate, disposable DEBUG DB per bounded test session. A killed worker
/// cannot silently reopen and resume an earlier session.
const debugIpcDatabasePrefix = 'navitaximeter_DEBUG_IPC_';

/// Exactly one serialized Dart writer for this DEBUG checkpoint DB.
/// A transport failure/uncertain COMMIT pauses the worker; no auto-recovery.
class DebugCheckpointTransport {
  Future<void> _tail = Future<void>.value();
  String? _ownedFence;
  bool _paused = false;

  Future<Map<String, Object>> submit(Map<dynamic, dynamic> wire) {
    final next = _tail.then((_) => _submitOne(wire));
    _tail = next.then<void>((_) {}, onError: (Object _, StackTrace __) {});
    return next;
  }

  Future<Map<String, Object>> _submitOne(Map<dynamic, dynamic> wire) async {
    if (wire['type'] != 'debug.checkpoint.proposal.v1' ||
        wire['sessionId'] is! String ||
        wire['generation'] is! int ||
        wire['sequence'] is! int ||
        wire['payloadHash'] is! String) {
      throw const FormatException('Invalid DEBUG IPC proposal');
    }
    final sessionId = wire['sessionId'] as String;
    final generation = wire['generation'] as int;
    final sequence = wire['sequence'] as int;
    final digest = wire['payloadHash'] as String;
    if (!RegExp(r'^DBG_[A-Za-z0-9_-]{1,72}$').hasMatch(sessionId) ||
        generation <= 0 || sequence < 0 ||
        !RegExp(r'^[0-9a-f]{64}$').hasMatch(digest)) {
      throw const FormatException('Invalid DEBUG checkpoint identity');
    }
    final fence = '$sessionId/$generation';
    if (_ownedFence != null && _ownedFence != fence) {
      throw StateError('STALE_DEBUG_FENCE');
    }
    if (_paused) throw StateError('PAUSED_DEBUG_WORKER');

    final dbPath = path.join(
      await getDatabasesPath(), '$debugIpcDatabasePrefix$sessionId.db',
    );
    if (_ownedFence == null) {
      // A surviving database from an engine/process death is NOT evidence
      // that it is safe to resume. A new worker always starts PAUSED.
      if (await File(dbPath).exists()) {
        _paused = true;
        throw StateError('PAUSED_RESTART_EXISTING_DEBUG_DB');
      }
      _ownedFence = fence;
    }

    try {
      final db = await openDatabase(
        dbPath,
        version: 1,
        singleInstance: false,
        onCreate: (database, _) async {
          await database.execute(
            'CREATE TABLE debug_fence ('
            'id INTEGER PRIMARY KEY CHECK(id=1),'
            'session_id TEXT NOT NULL, generation INTEGER NOT NULL,'
            'last_sequence INTEGER NOT NULL)',
          );
          await database.execute(
            'CREATE TABLE debug_checkpoint ('
            'sequence INTEGER PRIMARY KEY,'
            'session_id TEXT NOT NULL, generation INTEGER NOT NULL,'
            'payload_hash TEXT NOT NULL, checkpoint_id TEXT NOT NULL)',
          );
        },
      );
      String? checkpointId;
      try {
        await db.transaction((txn) async {
          var rows = await txn.query('debug_fence', where: 'id=?',
              whereArgs: [1]);
          if (rows.isEmpty) {
            if (sequence != 0) throw StateError('DEBUG_SEQUENCE_GAP');
            await txn.insert('debug_fence', {
              'id': 1, 'session_id': sessionId,
              'generation': generation, 'last_sequence': -1,
            });
            rows = await txn.query('debug_fence',
                where: 'id=?', whereArgs: [1]);
          }
          if (rows.length != 1 ||
              rows.single['session_id'] != sessionId ||
              rows.single['generation'] != generation) {
            throw StateError('DEBUG_FENCE_MISMATCH');
          }
          final last = rows.single['last_sequence'] as int;
          if (sequence == last) {
            final stored = await txn.query('debug_checkpoint',
                where: 'sequence=?', whereArgs: [sequence]);
            if (stored.length != 1 ||
                stored.single['payload_hash'] != digest ||
                stored.single['session_id'] != sessionId ||
                stored.single['generation'] != generation) {
              throw StateError('CONFLICTING_DEBUG_REPLAY');
            }
            checkpointId = stored.single['checkpoint_id'] as String;
            return;
          }
          if (sequence != last + 1) {
            throw StateError('DEBUG_SEQUENCE_GAP');
          }
          checkpointId =
              '$sessionId-$generation-$sequence-${digest.substring(0, 16)}';
          await txn.insert('debug_checkpoint', {
            'sequence': sequence, 'session_id': sessionId,
            'generation': generation, 'payload_hash': digest,
            'checkpoint_id': checkpointId,
          });
          await txn.update('debug_fence', {'last_sequence': sequence},
              where: 'id=?', whereArgs: [1]);
        });
      } finally {
        await db.close();
      }

      // Not merely an awaited SQL Future: reopen read-only AFTER COMMIT and
      // independently verify the persisted fence and ACK identity.
      final readback = await openDatabase(
          dbPath, readOnly: true, singleInstance: false);
      try {
        final fences = await readback.query('debug_fence',
            where: 'id=?', whereArgs: [1]);
        final checkpoints = await readback.query('debug_checkpoint',
            where: 'sequence=?', whereArgs: [sequence]);
        if (fences.length != 1 || checkpoints.length != 1 ||
            fences.single['session_id'] != sessionId ||
            fences.single['generation'] != generation ||
            (fences.single['last_sequence'] as int) < sequence ||
            checkpoints.single['session_id'] != sessionId ||
            checkpoints.single['generation'] != generation ||
            checkpoints.single['payload_hash'] != digest ||
            checkpoints.single['checkpoint_id'] != checkpointId ||
            checkpointId == null) {
          throw StateError('DEBUG_POST_COMMIT_READBACK_MISMATCH');
        }
      } finally {
        await readback.close();
      }
      return {
        'type': 'debug.checkpoint.ack.v1',
        'sessionId': sessionId,
        'generation': generation,
        'sequence': sequence,
        'payloadHash': digest,
        'checkpointId': checkpointId!,
        'probeOnly': true,
        'passengerFareEnabled': false,
      };
    } catch (_) {
      // The COMMIT may already have happened. Never guess or replay.
      _paused = true;
      rethrow;
    }
  }
}
