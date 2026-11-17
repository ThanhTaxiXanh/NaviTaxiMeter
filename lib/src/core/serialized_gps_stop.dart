import 'dart:async';

/// Coalesces overlapping teardown requests into one asynchronous operation.
/// In particular, a GPS owner cannot be released by the second stop caller
/// while the first caller still awaits stream cancellation / SQLite pause.
class SerializedGpsStop {
  Future<void>? _pending;

  bool get stopping => _pending != null;

  Future<void> run(Future<void> Function() stop) {
    final current = _pending;
    if (current != null) return current;

    final completer = Completer<void>();
    _pending = completer.future;
    Future<void>.sync(stop).then((_) {
      _pending = null;
      completer.complete();
    }, onError: (Object error, StackTrace trace) {
      _pending = null;
      completer.completeError(error, trace);
    });
    return completer.future;
  }
}
