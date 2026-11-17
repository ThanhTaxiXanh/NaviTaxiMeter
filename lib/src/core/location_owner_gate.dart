import 'package:flutter/services.dart';

/// The Android process owns GPS exclusivity; a Dart bool is not sufficient.
/// Leases are only for safety experiments, never passenger metering.
class LocationOwnerLease {
  LocationOwnerLease._(this.owner, this.leaseId);

  static const _channel =
      MethodChannel('vn.navitaximeter/safety_location_service');

  final String owner;
  final int leaseId;
  bool _released = false;

  static Future<LocationOwnerLease> acquire(String owner) async {
    if (owner != 'preview' && owner != 'lab') {
      throw ArgumentError.value(owner, 'owner', 'Only GPS test modes allowed');
    }
    final response = await _channel.invokeMapMethod<String, dynamic>(
      'acquire', <String, Object>{'owner': owner},
    );
    final leaseId = response?['leaseId'];
    if (response?['owner'] != owner || leaseId is! int || leaseId <= 0) {
      throw const FormatException('Android GPS lease not acknowledged');
    }
    return LocationOwnerLease._(owner, leaseId);
  }

  /// Only release after stream cancellation AND (in Lab) SQLite suspension.
  Future<void> release() async {
    if (_released) return;
    final accepted = await _channel.invokeMethod<bool>(
      'release', <String, Object>{'owner': owner, 'leaseId': leaseId},
    );
    if (accepted != true) {
      throw StateError('Android rejected stale GPS lease release');
    }
    _released = true;
  }
}
