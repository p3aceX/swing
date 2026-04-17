import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../domain/diet_models.dart';

class DietRepository {
  static const _localLogsKey = 'diet_local_meal_logs_v1';

  final _client = ApiClient.instance.dio;

  // Fetch today's meals logs
  Future<DietDailySummary> getDailySummary({DateTime? date}) async {
    final d = date ?? DateTime.now();
    final dateStr =
        '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
    DietDailySummary remoteSummary = DietDailySummary.empty(d);
    try {
      final res = await _client.get(ApiEndpoints.dietSummary, queryParameters: {
        'date': dateStr,
      });
      final raw = _unwrap(res.data);
      remoteSummary = _mapSummary(raw, d);
    } catch (e) {
      debugPrint('[DietRepo] getDailySummary error: $e');
    }
    final localMeals = await _loadLocalMealsForDate(d);
    if (localMeals.isEmpty) return remoteSummary;
    return DietDailySummary(
      date: remoteSummary.date,
      meals: [...remoteSummary.meals, ...localMeals],
      totalWaterMl: remoteSummary.totalWaterMl +
          localMeals.fold(0, (sum, meal) => sum + meal.waterMl),
      calorieTarget: remoteSummary.calorieTarget,
      proteinTargetG: remoteSummary.proteinTargetG,
      carbsTargetG: remoteSummary.carbsTargetG,
      fatTargetG: remoteSummary.fatTargetG,
    );
  }

  // Search nutrition library
  Future<List<NutritionItem>> searchNutritionLibrary(String query,
      {int limit = 20}) async {
    try {
      final res = await _client.get(ApiEndpoints.nutritionLibrary,
          queryParameters: {'search': query, 'limit': limit});

      final raw = _unwrap(res.data);
      final list = raw['items'] as List? ?? raw['data'] as List? ?? [];
      return list
          .whereType<Map<String, dynamic>>()
          .map(NutritionItem.fromJson)
          .toList();
    } catch (e) {
      debugPrint('[DietRepo] searchNutritionLibrary error: $e');
      return [];
    }
  }

  // Log a meal
  Future<void> logMeal(MealLog log) async {
    try {
      await _client.post(ApiEndpoints.dietLog, data: log.toJson());
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        await _saveLocalMeal(log);
        return;
      }
      debugPrint('[DietRepo] logMeal error: $e');
      rethrow;
    } catch (e) {
      debugPrint('[DietRepo] logMeal error: $e');
      rethrow;
    }
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  Map<String, dynamic> _unwrap(dynamic data) {
    if (data is Map<String, dynamic>) {
      if (data.containsKey('data')) {
        final d = data['data'];
        if (d is Map<String, dynamic>) return d;
      }
      return data;
    }
    return {};
  }

  DietDailySummary _mapSummary(Map<String, dynamic> raw, DateTime date) {
    final rawMeals = raw['meals'] as List? ?? raw['logs'] as List? ?? [];
    final meals = rawMeals
        .whereType<Map<String, dynamic>>()
        .map(MealLog.fromJson)
        .toList();

    final targets = raw['targets'] as Map<String, dynamic>? ?? {};

    return DietDailySummary(
      date: date,
      meals: meals,
      totalWaterMl: _toInt(raw['totalWaterMl'] ?? raw['waterMl']),
      calorieTarget: _toDouble(targets['calories'] ?? 2400),
      proteinTargetG: _toDouble(targets['proteinG'] ?? 80),
      carbsTargetG: _toDouble(targets['carbsG'] ?? 240),
      fatTargetG: _toDouble(targets['fatG'] ?? 65),
    );
  }

  double _toDouble(dynamic v) =>
      v is num ? v.toDouble() : double.tryParse(v?.toString() ?? '') ?? 0;
  int _toInt(dynamic v) =>
      v is num ? v.toInt() : int.tryParse(v?.toString() ?? '') ?? 0;

  Future<void> _saveLocalMeal(MealLog log) async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList(_localLogsKey) ?? const <String>[];
    final localLog = MealLog(
      id: log.id.isNotEmpty
          ? log.id
          : 'local-${DateTime.now().microsecondsSinceEpoch}',
      mealType: log.mealType,
      loggedAt: log.loggedAt,
      items: log.items,
      waterMl: log.waterMl,
      notes: log.notes,
    );
    await prefs.setStringList(
      _localLogsKey,
      [...saved, jsonEncode(_mealLogToLocalJson(localLog))],
    );
    debugPrint(
        '[DietRepo] saved meal locally because backend diet route is unavailable');
  }

  Future<List<MealLog>> _loadLocalMealsForDate(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList(_localLogsKey) ?? const <String>[];
    final result = <MealLog>[];
    for (final raw in saved) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is! Map<String, dynamic>) continue;
        final log = MealLog.fromJson(decoded);
        if (_sameDate(log.loggedAt, date)) result.add(log);
      } catch (e) {
        debugPrint('[DietRepo] local meal parse error: $e');
      }
    }
    return result;
  }

  Map<String, dynamic> _mealLogToLocalJson(MealLog log) => {
        'id': log.id,
        'mealType': log.mealType.apiValue,
        'loggedAt': log.loggedAt.toIso8601String(),
        'items': log.items.map((i) => i.toJson(includeItem: true)).toList(),
        'waterMl': log.waterMl,
        if (log.notes != null) 'notes': log.notes,
      };

  bool _sameDate(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
