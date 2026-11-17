import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:navitaximeter/src/core/location_owner_gate.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('vn.navitaximeter/safety_location_service');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  tearDown(() => messenger.setMockMethodCallHandler(channel, null));

  test('native token is required and only released once', () async {
    final calls = <String>[];
    messenger.setMockMethodCallHandler(channel, (call) async {
      calls.add(call.method);
      if (call.method == 'acquire') {
        expect(call.arguments, {'owner': 'preview'});
        return {'owner': 'preview', 'leaseId': 42};
      }
      expect(call.arguments, {'owner': 'preview', 'leaseId': 42});
      return true;
    });
    final lease = await LocationOwnerLease.acquire('preview');
    await lease.release();
    await lease.release();
    expect(calls, ['acquire', 'release']);
  });

  test('busy, forged ACK and invalid owner fail closed', () async {
    messenger.setMockMethodCallHandler(channel, (_) async {
      throw PlatformException(code: 'GPS_BUSY');
    });
    await expectLater(LocationOwnerLease.acquire('lab'),
        throwsA(isA<PlatformException>()));
    messenger.setMockMethodCallHandler(channel, (_) async =>
        {'owner': 'lab', 'leaseId': 0});
    await expectLater(LocationOwnerLease.acquire('lab'), throwsFormatException);
    await expectLater(LocationOwnerLease.acquire('native_safety'),
        throwsArgumentError);
  });

  test('stale release cannot free somebody elses GPS lease', () async {
    messenger.setMockMethodCallHandler(channel, (call) async {
      if (call.method == 'acquire') {
        return {'owner': 'lab', 'leaseId': 19};
      }
      return false;
    });
    final lease = await LocationOwnerLease.acquire('lab');
    await expectLater(lease.release(), throwsStateError);
  });
}
