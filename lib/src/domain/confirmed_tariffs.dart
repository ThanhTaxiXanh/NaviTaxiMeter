import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../core/taximeter_engine.dart';
import '../data/tariff_codec.dart';

/// A tariff is not operational until the driver explicitly verifies its rates.
class ConfirmedTariff {
  const ConfirmedTariff({
    required this.id,
    required this.tariff,
    required this.confirmedAtUtc,
  });

  final String id;
  final TariffConfig tariff;
  final DateTime confirmedAtUtc;

  void validate() {
    if (id.trim().isEmpty || tariff.name.trim().isEmpty ||
        !confirmedAtUtc.isUtc || tariff.baseFare <= 0 ||
        tariff.effectiveFareTiers.any((b) => b.ratePerKm <= 0)) {
      throw const FormatException('Bảng giá chưa được xác nhận hợp lệ');
    }
    tariff.validate();
  }

  Map<String, Object?> toJson() => {
    'id': id,
    'confirmedAtUtc': confirmedAtUtc.toIso8601String(),
    'tariff': jsonDecode(TariffCodec.encode(tariff)),
  };

  factory ConfirmedTariff.fromJson(Map<String, dynamic> data) {
    final raw = data['tariff'];
    final date = DateTime.tryParse(data['confirmedAtUtc']?.toString() ?? '');
    if (raw is! Map || date == null ||
        !data.containsKey('id')) {
      throw const FormatException('Bảng giá lưu trữ không hợp lệ');
    }
    final profile = ConfirmedTariff(
      id: data['id'] as String,
      confirmedAtUtc: date.toUtc(),
      tariff: TariffCodec.decode(jsonEncode(raw)),
    );
    profile.validate();
    return profile;
  }
}

/// No default, sample, inferred or pre-confirmed tariff.
class ConfirmedTariffBook {
  const ConfirmedTariffBook({
    required this.profiles,
    required this.activeId,
  });

  const ConfirmedTariffBook.empty()
      : profiles = const [],
        activeId = null;

  final List<ConfirmedTariff> profiles;
  final String? activeId;

  ConfirmedTariff? get active {
    for (final p in profiles) {
      if (p.id == activeId) return p;
    }
    return null;
  }

  void validate() {
    if (profiles.length > 16 || (profiles.isEmpty != (activeId == null))) {
      throw const FormatException('Danh mục bảng giá không hợp lệ');
    }
    final ids = <String>{};
    for (final p in profiles) {
      p.validate();
      if (!ids.add(p.id)) throw const FormatException('Mã bảng giá bị trùng');
    }
    if (profiles.isNotEmpty && active == null) {
      throw const FormatException('Bảng giá đang chọn không tồn tại');
    }
  }

  ConfirmedTariffBook save(ConfirmedTariff entry) {
    entry.validate();
    final isNew = profiles.every((p) => p.id != entry.id);
    if (isNew && profiles.length >= 16) {
      throw StateError('Chỉ được lưu tối đa 16 bảng giá');
    }
    final next = ConfirmedTariffBook(
      profiles: [
        for (final p in profiles)
          if (p.id == entry.id) entry else p,
        if (isNew) entry,
      ],
      activeId: activeId ?? entry.id,
    );
    next.validate();
    return next;
  }

  ConfirmedTariffBook select(String id) {
    if (profiles.every((p) => p.id != id)) {
      throw StateError('Bảng giá không tồn tại');
    }
    return ConfirmedTariffBook(profiles: profiles, activeId: id);
  }

  ConfirmedTariffBook remove(String id) {
    if (profiles.every((p) => p.id != id)) {
      throw StateError('Bảng giá không tồn tại');
    }
    final next = profiles.where((p) => p.id != id).toList();
    final chosen = activeId == id ? (next.isEmpty ? null : next.first.id) : activeId;
    final result = ConfirmedTariffBook(profiles: next, activeId: chosen);
    result.validate();
    return result;
  }

  String encode() {
    validate();
    return jsonEncode({
      'schema': 1,
      'activeId': activeId,
      'profiles': profiles.map((p) => p.toJson()).toList(),
    });
  }

  factory ConfirmedTariffBook.decode(String raw) {
    final value = jsonDecode(raw);
    if (value is! Map || value['schema'] != 1 ||
        value['profiles'] is! List) {
      throw const FormatException('Định dạng danh mục bảng giá không hỗ trợ');
    }
    final profiles = (value['profiles'] as List).map((p) {
      if (p is! Map) throw const FormatException('Bảng giá sai định dạng');
      return ConfirmedTariff.fromJson(Map<String, dynamic>.from(p));
    }).toList(growable: false);
    final book = ConfirmedTariffBook(
      profiles: profiles,
      activeId: value['activeId'] as String?,
    );
    book.validate();
    return book;
  }
}

/// Tariff settings are local and namespaced. Trip receipts remain in SQLite.
/// A failed read never falls back to a fabricated / sample tariff.
class ConfirmedTariffStore {
  ConfirmedTariffStore({SharedPreferencesAsync? preferences})
      : _preferences = preferences ?? SharedPreferencesAsync();

  static const key = 'navi_confirmed_tariffs_v1';
  final SharedPreferencesAsync _preferences;

  Future<ConfirmedTariffBook> read() async {
    final raw = await _preferences.getString(key);
    return raw == null
        ? const ConfirmedTariffBook.empty()
        : ConfirmedTariffBook.decode(raw);
  }

  Future<void> write(ConfirmedTariffBook book) async {
    final encoded = book.encode();
    await _preferences.setString(key, encoded);
    final saved = await _preferences.getString(key);
    if (saved != encoded) {
      throw StateError('Không thể xác minh việc lưu bảng giá');
    }
  }
}
