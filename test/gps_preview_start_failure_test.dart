import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:navitaximeter/src/ui/gps_preview_page.dart';

void main() {
  test('GPS_BUSY is visible only after asynchronous cleanup finishes', () async {
    final stopped = Completer<void>();
    var completed = false;
    final result = gpsPreviewStartFailureAfterCleanup(
      PlatformException(code: 'GPS_BUSY', message: 'Location service already owned'),
      () => stopped.future,
    );
    result.then((_) => completed = true);
    await Future<void>.delayed(Duration.zero);
    expect(completed, isFalse, reason: 'Do not publish before stop barrier');
    stopped.complete();
    final message = await result;
    expect(message, contains('GPS_BUSY'));
    expect(message, contains('GPS nền thử'));
    expect(message, isNot(contains('Đã dừng xem GPS')));
  });

  test('other start failures remain visible after cleanup', () async {
    var stopped = false;
    final message = await gpsPreviewStartFailureAfterCleanup(
      StateError('Location permission revoked'),
      () async { stopped = true; },
    );
    expect(stopped, isTrue);
    expect(message, contains('Location permission revoked'));
    expect(message, contains('Không thể bật GPS thử'));
  });

  test('cleanup failure takes precedence over start failure', () async {
    final message = await gpsPreviewStartFailureAfterCleanup(
      PlatformException(code: 'GPS_BUSY'),
      () async { throw StateError('lease still held'); },
    );
    expect(message, contains('Không thể dừng GPS an toàn'));
    expect(message, contains('lease still held'));
    expect(message, contains('GPS_BUSY'));
  });
}
