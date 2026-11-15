// Issue #3, service/worker wire handshake TEST ONLY.
// NO Kotlin channel, real GNSS, production DB or passenger fares.
import 'dart:convert';

import 'package:navitaximeter/src/lab/trip_ipc_contract.dart';
import 'package:sqflite/sqflite.dart';

/// Simulates a native service sending a typed IPC proposal to the single
/// Dart sqflite test worker. ACK is sent only after the worker's transaction
/// Future finishes AND an independent readback sees the matching ledger.
///
/// This is a message-boundary proof, NOT actual Android MethodChannel/FGS.
class TestOnlyServiceAckBridge {
  TestOnlyServiceAckBridge({
    required this.db,
    required this.gate,
    this.afterDurableReadback,
  });

  final Database db;
  final IpcCheckpointGate gate;
  // Serialize the entire proposal -> COMMIT -> readback -> ACK sequence.
  // Serializing only the writer leaves a race between readback and next fix.
  Future<void> _tail = Future<void>.value();

  /// Simulates a transport ACK that may be dropped AFTER COMMIT/readback.
  /// The callback is awaited; errors force the gate PAUSED.
  final Future<void> Function()? afterDurableReadback;

  Future<Map<String, Object>> deliver(Map<dynamic, dynamic> wire) {
    final queued = _tail.then((_) => _deliverOne(wire));
    _tail = queued.then<void>((_) {}, onError: (Object _, StackTrace __) {});
    return queued;
  }

  Future<Map<String, Object>> _deliverOne(
      Map<dynamic, dynamic> wire) async {
    final proposal = IpcProposal.fromWire(wire);
    final ack = await gate.submit(proposal);
    try {
      // The test writer's ACK alone is a claim. Verify it against the exact
      // committed row, fence, historical record and SQLite route/header.
      await db.transaction((txn) async {
        final fences = await txn.query('checkpoint_fence',
            where: 'id=?', whereArgs: [1]);
        final committedAcks = await txn.query('checkpoint_ack',
            where: 'sequence=?', whereArgs: [proposal.sequence]);
        final route = await txn.query('active_trip_route',
            where: 'sequence=?', whereArgs: [proposal.sequence]);
        final historical = await txn.query(
            'unified_checkpoint_history_test_only',
            where: 'sequence=?', whereArgs: [proposal.sequence]);
        final headers = await txn.query('active_trip',
            where: 'id=?', whereArgs: [1]);
        if (fences.length != 1 || committedAcks.length != 1 ||
            route.length != 1 || historical.length != 1 ||
            headers.length != 1) {
          throw StateError('Durable native/worker ACK row missing');
        }
        final fence = fences.single;
        final saved = committedAcks.single;
        final history = historical.single;
        final raw = headers.single['payload'];
        if (raw is! String) throw StateError('Missing durable fare header');
        final header = jsonDecode(raw);
        if (header is! Map || header['routeCount'] != proposal.sequence + 1 ||
            fence['session_id'] != proposal.fence.sessionId ||
            fence['generation'] != proposal.fence.generation ||
            fence['last_sequence'] != proposal.sequence ||
            fence['last_gnss_nanos'] != proposal.gnssElapsedRealtimeNanos ||
            saved['session_id'] != ack.fence.sessionId ||
            saved['generation'] != ack.fence.generation ||
            saved['sequence'] != ack.sequence ||
            saved['sample_digest'] != ack.payloadHash ||
            saved['checkpoint_id'] != ack.id ||
            history['session_id'] != ack.fence.sessionId ||
            history['generation'] != ack.fence.generation ||
            history['sequence'] != ack.sequence ||
            history['gnss_nanos'] != proposal.gnssElapsedRealtimeNanos ||
            history['header_text'] != raw ||
            history['history_id'] is! String) {
          throw StateError('Durable native/worker ACK identity mismatch');
        }
      });

      // Delivery of this test wire response is deliberately last.
      if (afterDurableReadback != null) {
        await afterDurableReadback!();
      }
      if (gate.phase != IpcGatePhase.accepting) {
        throw StateError('Native ACK invalidated after readback');
      }
      return ack.toWire();
    } catch (_) {
      // SQLite may have COMMITTED. Do not replay or advance without a fresh
      // verified recovery, even when only transport delivery went missing.
      gate.markAckUnknown();
      rethrow;
    }
  }
}
