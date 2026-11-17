// Test-only link: typed IPC proposal -> disposable sqflite clone transaction.
// This is NOT a wire protocol for transmitting a physical GPS fix, and the
// registry is NOT a source of genuine GNSS, approved fares, or authorization.
import 'package:navitaximeter/src/lab/trip_ipc_contract.dart';

import 'issue3_sqflite_clone_writer.dart';

/// The bridge uses ONLY immutable synthetic fixture objects, keyed by digest.
/// Production still needs an actual native GNSS -> worker transport with
/// verifiable identity, safe payload transfer, owner lifecycle and privacy.
class TestOnlyIpcSqliteBridge {
  TestOnlyIpcSqliteBridge({
    required this.cloneWriter,
    required Iterable<CloneFix> immutableFixtures,
    this.loseAckAt,
  }) : _fixtures = Map<String, CloneFix>.unmodifiable({
          for (final fix in immutableFixtures) fix.digest: fix,
        }) {
    gate = IpcCheckpointGate(
      fence: IpcFence('TEST_SESSION_ONLY', 7),
      frozenTariffHash: frozenTestTariffHash,
      writer: _commit,
    );
  }

  final CloneAckWriter cloneWriter;
  final Map<String, CloneFix> _fixtures;
  final int? loseAckAt;
  late final IpcCheckpointGate gate;

  static IpcProposal proposal(CloneFix fix, {IpcFence? fence}) => IpcProposal(
    fence: fence ?? IpcFence('TEST_SESSION_ONLY', 7),
    sequence: fix.sequence,
    gnssElapsedRealtimeNanos: fix.gnssNanos,
    accuracyMeters: fix.accuracy,
    speedKmh: fix.speed,
    mocked: fix.mocked,
    tariffHash: fix.tariffHash,
    payloadHash: fix.digest,
  );

  Future<IpcCommitProof> _commit(IpcProposal p) async {
    // Frozen fixture lookup is intentional: the v1 IPC message contains
    // only a digest, not coords or an authenticated GNSS payload. No route
    // can be reconstructed from an arbitrary remote digest.
    final fix = _fixtures[p.payloadHash];
    if (fix == null ||
        p.fence != gate.fence ||
        p.sequence != fix.sequence ||
        p.gnssElapsedRealtimeNanos != fix.gnssNanos ||
        p.accuracyMeters != fix.accuracy ||
        p.speedKmh != fix.speed ||
        p.mocked != fix.mocked ||
        p.tariffHash != fix.tariffHash) {
      throw StateError('Synthetic fixture and IPC metadata mismatch');
    }
    final durable = await cloneWriter.append(
      fix,
      generation: p.fence.generation,
      loseAckAfterCommit: loseAckAt == p.sequence,
    );
    // The clone writer only resolves AFTER its sqflite transaction Future.
    return IpcCommitProof(p.fence, durable.sequence, p.payloadHash, durable.id);
  }
}
