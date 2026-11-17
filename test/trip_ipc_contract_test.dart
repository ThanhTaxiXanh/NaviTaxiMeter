import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:navitaximeter/src/lab/trip_ipc_contract.dart';

void main() {
  final tariffHash = 'a'.padRight(64, 'a');
  final payloadHash = 'b'.padRight(64, 'b');
  final fence = IpcFence('fixture_session', 3);
  IpcProposal make(int seq, {
    IpcFence? otherFence, bool mocked = false, double accuracy = 5.0,
    double speed = 10.0, int? elapsed, String? digest, String? tariff,
  }) => IpcProposal(
    fence: otherFence ?? fence, sequence: seq,
    gnssElapsedRealtimeNanos: elapsed ?? 10000000000 + seq * 1000000000,
    accuracyMeters: accuracy, speedKmh: speed, mocked: mocked,
    tariffHash: tariff ?? tariffHash, payloadHash: digest ?? payloadHash,
  );
  IpcCommitProof proof(IpcProposal p, {String? digest, String? id}) =>
      IpcCommitProof(p.fence, p.sequence, digest ?? p.payloadHash,
          id ?? 'test-checkpoint-' + p.sequence.toString());
  IpcCheckpointGate gate(CheckpointWriter writer) => IpcCheckpointGate(
      fence: fence, frozenTariffHash: tariffHash, writer: writer);

  test('typed IPC roundtrip rejects wrong version, type and SHA', () {
    final p = make(0);
    expect(IpcProposal.fromWire(p.toWire()).identicalTo(p), isTrue);
    expect(p.toWire().containsKey('latitude'), isFalse);
    expect(p.toWire().containsKey('fare'), isFalse);
    expect(() => IpcProposal.fromWire({...p.toWire(), 'generation': '3'}),
        throwsFormatException);
    expect(() => IpcProposal.fromWire({...p.toWire(), 'type': 'wrong'}),
        throwsFormatException);
    expect(() => make(0, digest: 'not-a-hash'), throwsFormatException);
  });

  test('no ACK until writer Future returns matching commit claim', () async {
    final pending = Completer<IpcCommitProof>();
    final g = gate((_) => pending.future);
    final p = make(0);
    final future = g.submit(p);
    await Future<void>.delayed(Duration.zero);
    expect(g.lastSequence, -1);
    pending.complete(proof(p));
    expect((await future).toWire()['checkpointId'], 'test-checkpoint-0');
    expect(g.lastSequence, 0);
  });

  test('8 concurrent sequential samples go through one writer', () async {
    var writes = 0;
    var active = 0;
    var maxActive = 0;
    final g = gate((p) async {
      writes++;
      active++;
      if (active > maxActive) maxActive = active;
      await Future<void>.delayed(const Duration(milliseconds: 1));
      active--;
      return proof(p);
    });
    final acks = await Future.wait(List.generate(8, (i) => g.submit(make(i))));
    expect(acks.map((a) => a.sequence).toList(), [0,1,2,3,4,5,6,7]);
    expect(writes, 8);
    expect(maxActive, 1);
    await g.submit(make(7)); // exact replay, no new mutation
    expect(writes, 8);
  });

  test('8 exact duplicates ACK once without duplicate write', () async {
    var writes = 0;
    final g = gate((p) async { writes++; return proof(p); });
    final acks = await Future.wait(List.generate(8, (_) => g.submit(make(0))));
    expect(acks.length, 8);
    expect(writes, 1);
  });

  test('conflicting duplicate fails closed', () async {
    var writes = 0;
    final g = gate((p) async { writes++; return proof(p); });
    await g.submit(make(0));
    await expectLater(g.submit(make(0, digest: 'c'.padRight(64,'c'))),
        throwsStateError);
    expect(g.phase, IpcGatePhase.paused);
    expect(g.reason, 'conflicting_replay');
    expect(writes, 1);
  });

  test('old session generation rejected without poisoning new one', () async {
    final g = gate((p) async => proof(p));
    await expectLater(g.submit(make(0,
        otherFence: IpcFence('fixture_session', 2))), throwsStateError);
    expect(g.phase, IpcGatePhase.accepting);
    await g.submit(make(0));
    expect(g.lastSequence, 0);
  });

  test('sequence gap and elapsedRealtime jump suspend, no backfill', () async {
    final missing = gate((p) async => proof(p));
    await expectLater(missing.submit(make(1)), throwsStateError);
    expect(missing.lastSequence, -1);
    expect(missing.phase, IpcGatePhase.paused);

    final discontinuity = gate((p) async => proof(p));
    await discontinuity.submit(make(0));
    await expectLater(discontinuity.submit(make(1, elapsed: 23000000000)),
        throwsStateError);
    expect(discontinuity.lastSequence, 0);
    expect(discontinuity.phase, IpcGatePhase.paused);
  });

  test('mock, poor accuracy, invalid speed, tariff mismatch reject write',
      () async {
    for (final p in [
      make(0, mocked: true),
      make(0, accuracy: 31.0),
      make(0, speed: double.nan),
      make(0, tariff: 'd'.padRight(64, 'd')),
    ]) {
      var calls = 0;
      final g = gate((q) async { calls++; return proof(q); });
      await expectLater(g.submit(p), throwsStateError);
      expect(g.phase, IpcGatePhase.paused);
      expect(calls, 0);
    }
  });

  test('faulty writer or mismatched commit never produces ACK', () async {
    final faulty = gate((_) async => throw StateError('test failure'));
    await expectLater(faulty.submit(make(0)), throwsStateError);
    expect(faulty.lastSequence, -1);
    expect(faulty.reason, 'commit_unknown');

    final mismatched = gate((p) async =>
        proof(p, digest: 'e'.padRight(64, 'e')));
    await expectLater(mismatched.submit(make(0)), throwsStateError);
    expect(mismatched.lastSequence, -1);
    expect(mismatched.reason, 'commit_identity_mismatch');
  });

  test('lost callback after commit candidate forces PAUSED', () async {
    final g = gate((p) async => proof(p));
    await g.submit(make(0));
    g.markAckUnknown();
    await expectLater(g.submit(make(1)), throwsStateError);
    expect(g.lastSequence, 0);
    expect(g.reason, 'ack_delivery_unknown');
  });

  test('inflight callback uncertainty suppresses pending ACK', () async {
    final pending = Completer<IpcCommitProof>();
    final g = gate((_) => pending.future);
    final p = make(0);
    final future = g.submit(p);
    await Future<void>.delayed(Duration.zero);
    g.markAckUnknown();
    pending.complete(proof(p));
    await expectLater(future, throwsStateError);
    expect(g.lastSequence, -1);
  });
}
