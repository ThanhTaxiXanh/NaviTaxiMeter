/// Issue #3: typed IPC contract only. NOT wired to meter, GPS or SQLite.
/// An injected test writer is NOT evidence of a real database COMMIT.
typedef CheckpointWriter = Future<IpcCommitProof> Function(IpcProposal p);

void requireHash(String h) {
  if (!RegExp(r'^[0-9a-f]{64}$').hasMatch(h)) {
    throw const FormatException('Invalid SHA-256 digest');
  }
}

class IpcFence {
  IpcFence(this.sessionId, this.generation) {
    if (!RegExp(r'^[A-Za-z0-9_-]{1,128}$').hasMatch(sessionId) ||
        generation <= 0) {
      throw const FormatException('Invalid session fence');
    }
  }
  final String sessionId;
  final int generation;
  @override
  bool operator ==(Object other) => other is IpcFence &&
      other.sessionId == sessionId && other.generation == generation;
  @override
  int get hashCode => Object.hash(sessionId, generation);
}

/// Metadata and opaque digest only. No physical GNSS provenance or route.
class IpcProposal {
  IpcProposal({
    required this.fence, required this.sequence,
    required this.gnssElapsedRealtimeNanos, required this.accuracyMeters,
    required this.speedKmh, required this.mocked,
    required this.tariffHash, required this.payloadHash,
  }) {
    if (sequence < 0) throw const FormatException('Negative sequence');
    requireHash(tariffHash);
    requireHash(payloadHash);
  }
  final IpcFence fence;
  final int sequence;
  final int gnssElapsedRealtimeNanos;
  final double accuracyMeters;
  final double speedKmh;
  final bool mocked;
  final String tariffHash;
  final String payloadHash;

  Map<String, Object> toWire() => {
    'type': 'trip.proposal.v1',
    'sessionId': fence.sessionId, 'generation': fence.generation,
    'sequence': sequence, 'gnssElapsedRealtimeNanos': gnssElapsedRealtimeNanos,
    'accuracyMeters': accuracyMeters, 'speedKmh': speedKmh,
    'mocked': mocked, 'tariffHash': tariffHash, 'payloadHash': payloadHash,
  };

  factory IpcProposal.fromWire(Map<dynamic, dynamic> m) {
    if (m['type'] != 'trip.proposal.v1' || m['sessionId'] is! String ||
        m['generation'] is! int || m['sequence'] is! int ||
        m['gnssElapsedRealtimeNanos'] is! int ||
        m['accuracyMeters'] is! num || m['speedKmh'] is! num ||
        m['mocked'] is! bool || m['tariffHash'] is! String ||
        m['payloadHash'] is! String) {
      throw const FormatException('Invalid typed IPC proposal');
    }
    return IpcProposal(
      fence: IpcFence(m['sessionId'] as String, m['generation'] as int),
      sequence: m['sequence'] as int,
      gnssElapsedRealtimeNanos: m['gnssElapsedRealtimeNanos'] as int,
      accuracyMeters: (m['accuracyMeters'] as num).toDouble(),
      speedKmh: (m['speedKmh'] as num).toDouble(),
      mocked: m['mocked'] as bool,
      tariffHash: m['tariffHash'] as String,
      payloadHash: m['payloadHash'] as String,
    );
  }

  bool identicalTo(IpcProposal p) => fence == p.fence &&
      sequence == p.sequence && gnssElapsedRealtimeNanos == p.gnssElapsedRealtimeNanos &&
      accuracyMeters == p.accuracyMeters && speedKmh == p.speedKmh &&
      mocked == p.mocked && tariffHash == p.tariffHash && payloadHash == p.payloadHash;
}

/// A *claim* returned by the injected writer; real SQLite proof is pending.
class IpcCommitProof {
  const IpcCommitProof(this.fence, this.sequence, this.payloadHash, this.id);
  final IpcFence fence;
  final int sequence;
  final String payloadHash;
  final String id;
}

class IpcAck {
  const IpcAck._(this.fence, this.sequence, this.payloadHash, this.id);
  final IpcFence fence;
  final int sequence;
  final String payloadHash;
  final String id;
  Map<String, Object> toWire() => {
    'type': 'trip.ack.v1', 'sessionId': fence.sessionId,
    'generation': fence.generation, 'sequence': sequence,
    'payloadHash': payloadHash, 'checkpointId': id,
  };
}

enum IpcGatePhase { accepting, paused }

/// Contract-only serialized queue. No money can be mutated by this class.
/// Native must independently prove one location owner and trusted physical fix.
class IpcCheckpointGate {
  IpcCheckpointGate({
    required this.fence, required this.frozenTariffHash,
    required CheckpointWriter writer,
  }) : _writer = writer {
    requireHash(frozenTariffHash);
  }

  final IpcFence fence;
  final String frozenTariffHash;
  final CheckpointWriter _writer;
  Future<void> _tail = Future<void>.value();
  IpcGatePhase _phase = IpcGatePhase.accepting;
  String? _reason;
  int _lastSequence = -1;
  int _lastElapsed = -1;
  IpcProposal? _lastProposal;
  IpcAck? _lastAck;

  IpcGatePhase get phase => _phase;
  String? get reason => _reason;
  int get lastSequence => _lastSequence;
  void markAckUnknown() => _pause('ack_delivery_unknown');
  void _pause(String reason) {
    _phase = IpcGatePhase.paused;
    _reason = reason;
  }

  Future<IpcAck> submit(IpcProposal p) {
    final operation = _tail.then((_) => _submitOne(p));
    _tail = operation.then<void>((_) {}, onError: (Object _, StackTrace __) {});
    return operation;
  }

  Future<IpcAck> _submitOne(IpcProposal p) async {
    if (p.fence != fence) throw StateError('Stale or foreign generation');
    if (_phase != IpcGatePhase.accepting) {
      throw StateError('PAUSED: manual recovery required');
    }
    if (p.sequence == _lastSequence && _lastAck != null) {
      if (_lastProposal!.identicalTo(p)) return _lastAck!;
      _pause('conflicting_replay');
      throw StateError('Conflicting same-sequence replay');
    }
    if (p.sequence != _lastSequence + 1) {
      _pause('sequence_gap');
      throw StateError('Out-of-order or missing sequence');
    }
    final nanos = p.gnssElapsedRealtimeNanos;
    if (nanos <= 0 || (_lastElapsed >= 0 &&
        (nanos <= _lastElapsed || nanos - _lastElapsed > 12000000000))) {
      _pause('gnss_discontinuity');
      throw StateError('Unsafe monotonic GNSS interval');
    }
    if (p.mocked || !p.accuracyMeters.isFinite ||
        p.accuracyMeters < 0 || p.accuracyMeters > 30 ||
        !p.speedKmh.isFinite || p.speedKmh < 0 || p.speedKmh > 220 ||
        p.tariffHash != frozenTariffHash) {
      _pause('untrusted_metadata_or_tariff');
      throw StateError('Untrusted GPS metadata or tariff');
    }
    late final IpcCommitProof proof;
    try {
      // Future implementation must await *one* complete sqflite transaction.
      proof = await _writer(p);
    } catch (_) {
      _pause('commit_unknown');
      throw StateError('Commit unknown: recover persisted PAUSED');
    }
    if (_phase != IpcGatePhase.accepting) {
      throw StateError('ACK delivery invalidated during commit');
    }
    if (proof.fence != fence || proof.sequence != p.sequence ||
        proof.payloadHash != p.payloadHash || proof.id.trim().isEmpty) {
      _pause('commit_identity_mismatch');
      throw StateError('Mismatched commit evidence');
    }
    final ack = IpcAck._(fence, p.sequence, proof.payloadHash, proof.id);
    _lastSequence = p.sequence;
    _lastElapsed = nanos;
    _lastProposal = p;
    _lastAck = ack;
    return ack;
  }
}
