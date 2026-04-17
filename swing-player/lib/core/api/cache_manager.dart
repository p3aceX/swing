import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';

class CacheManager {
  CacheManager._();

  static final Box<String> _box = Hive.box<String>('app_cache');

  static Future<void> set(String key, dynamic value, {Duration? ttl}) async {
    final data = {
      'value': value,
      'expiry': ttl != null
          ? DateTime.now().add(ttl).millisecondsSinceEpoch
          : null,
    };
    await _box.put(key, jsonEncode(data));
  }

  static dynamic get(String key) {
    final raw = _box.get(key);
    if (raw == null) return null;

    try {
      final data = jsonDecode(raw) as Map<String, dynamic>;
      final expiry = data['expiry'] as int?;

      if (expiry != null &&
          DateTime.now().isAfter(DateTime.fromMillisecondsSinceEpoch(expiry))) {
        _box.delete(key);
        return null;
      }

      return data['value'];
    } catch (_) {
      return null;
    }
  }

  static Future<void> delete(String key) async {
    await _box.delete(key);
  }

  static Future<void> clear() async {
    await _box.clear();
  }
}
