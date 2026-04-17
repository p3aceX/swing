import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../auth/token_storage.dart';
import '../../features/elite/domain/elite_models.dart';

class GoalStorage {
  GoalStorage._();

  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );
  static const _goalKeyPrefix = 'apex_goal_v1';
  static const _legacyGoalKey = 'apex_goal_v1';
  static const _journalDateKeyPrefix = 'last_journal_date';
  static const _cheatDateKeyPrefix = 'last_cheat_day';

  // ── Goal ──────────────────────────────────────────────────────────────────

  static Future<void> save(ApexGoal goal) async {
    final key = await _goalKey();
    await _storage.write(key: key, value: jsonEncode(goal.toJson()));
  }

  static Future<ApexGoal?> load() async {
    try {
      final key = await _goalKey();
      final scopedRaw = await _storage.read(key: key);
      if (scopedRaw != null && scopedRaw.isNotEmpty) {
        return ApexGoal.fromJson(jsonDecode(scopedRaw) as Map<String, dynamic>);
      }

      // Backward compatibility for older builds that stored one global goal key.
      final legacyRaw = await _storage.read(key: _legacyGoalKey);
      if (legacyRaw == null || legacyRaw.isEmpty) return null;

      final goal =
          ApexGoal.fromJson(jsonDecode(legacyRaw) as Map<String, dynamic>);
      if (key != _legacyGoalKey) {
        await _storage.write(key: key, value: legacyRaw);
      }
      return goal;
    } catch (_) {
      return null;
    }
  }

  static Future<void> clearGoal() async {
    await _storage.delete(key: await _goalKey());
    await _storage.delete(key: _legacyGoalKey);
  }

  // ── Journal date tracking (for optimistic streak) ─────────────────────────

  /// Saves today's date so the streak can show it as active immediately.
  static Future<void> saveJournalDate() async {
    final today = _todayKey();
    await _storage.write(key: await _journalDateKey(), value: today);
  }

  /// Returns true if the user has submitted a journal today.
  static Future<bool> journaledToday() async {
    final stored = await _storage.read(key: await _journalDateKey());
    return stored == _todayKey();
  }

  /// Persists whether today's journal was marked as a cheat day.
  static Future<void> saveCheatDayStatus({required bool isCheatDay}) async {
    final key = await _cheatDateKey();
    if (isCheatDay) {
      await _storage.write(key: key, value: _todayKey());
    } else {
      await _storage.delete(key: key);
    }
  }

  /// Returns true if today's journal is marked as cheat day.
  static Future<bool> cheatDayToday() async {
    final stored = await _storage.read(key: await _cheatDateKey());
    return stored == _todayKey();
  }

  static Future<String> _goalKey() async {
    final userId = await TokenStorage.getUserId();
    if (userId == null || userId.isEmpty) return _legacyGoalKey;
    return '${_goalKeyPrefix}_$userId';
  }

  static Future<String> _journalDateKey() async {
    final userId = await TokenStorage.getUserId();
    if (userId == null || userId.isEmpty) return _journalDateKeyPrefix;
    return '${_journalDateKeyPrefix}_$userId';
  }

  static Future<String> _cheatDateKey() async {
    final userId = await TokenStorage.getUserId();
    if (userId == null || userId.isEmpty) return _cheatDateKeyPrefix;
    return '${_cheatDateKeyPrefix}_$userId';
  }

  static String _todayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }
}
