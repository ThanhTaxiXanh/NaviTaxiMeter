import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:navitaximeter/src/core/location_owner_gate.dart';
import 'package:navitaximeter/src/core/serialized_gps_stop.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('vn.navitaximeter/safety_location_service');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  tearDown(() => messenger.setMockMethodCallHandler(channel, null));

  test('concurrent stop calls share one cancellation barrier', () async {
    final stopping = SerializedGpsStop();
    final cancelled = Completer<void>();
    var calls = 0;
    final first = stopping.run(() async {
      calls += 1;
      await cancelled.future;
    });
    final second = stopping.run(() async {
      calls += 1;
    });
    expect(identical(first, second), true);
    expect(stopping.stopping, true);
    expect(calls, 1);
    cancelled.complete();
    await Future.wait([first, second]);
    expect(calls, 1);
    expect(stopping.stopping, false);
  });

  test('Android lease is held until async stream cancellation finishes', () async {
    final calls = <String>[];
    messenger.setMockMethodCallHandler(channel, (call) async {
      calls.add(call.method);
      if (call.method == 'acquire') {
        return {'owner': 'preview', 'leaseId': 71};
      }
      return true;
    });
    final lease = await LocationOwnerLease.acquire('preview');
    final stopped = Completer<void>();
    final barrier = SerializedGpsStop();
    final first = barrier.run(() async {
      await stopped.future;
      await lease.release();
    });
    final second = barrier.run(() async {
      await lease.release(); // Must never execute.
    });
    await Future<void>.delayed(Duration.zero);
    expect(calls, ['acquire']);
    expect(identical(first, second), true);
    stopped.complete();
    await Future.wait([first, second]);
    expect(calls, ['acquire', 'release']);
  });

  test('failed teardown remains failed; a later explicit retry is allowed', () async {
    final gate = SerializedGpsStop();
    var attempts = 0;
    await expectLater(gate.run(() async {
      attempts++;
      throw StateError('SQLite unsafe');
    }), throwsStateError);
    expect(gate.stopping, false);
    await gate.run(() async { attempts++; });
    expect(attempts, 2);
  });
}
