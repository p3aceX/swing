import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../domain/fitness_models.dart';

class FitnessRepository {
  static const _localSessionsKey = 'fitness_local_sessions_v1';

  final _client = ApiClient.instance.dio;

  Future<List<FitnessExercise>> searchExercises(String query) async {
    try {
      final response = await _client.get(
        ApiEndpoints.fitnessLibrary,
        queryParameters: {'search': query, 'limit': 30},
      );

      final data = response.data;
      final List results;
      if (data is Map<String, dynamic>) {
        final payload = data['data'];
        if (payload is Map<String, dynamic>) {
          results =
              payload['items'] as List? ?? payload['exercises'] as List? ?? [];
        } else {
          results = data['items'] as List? ?? data['exercises'] as List? ?? [];
        }
      } else if (data is List) {
        results = data;
      } else {
        results = [];
      }

      return results
          .map((item) => FitnessExercise.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('FitnessRepository.searchExercises error: $e');
      return [];
    }
  }

  Future<void> logSession(WorkoutSession session) async {
    try {
      await _client.post(
        ApiEndpoints.fitnessLog,
        data: session.toJson(),
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        await _saveLocalSession(session);
        return;
      }
      debugPrint('FitnessRepository.logSession error: $e');
      rethrow;
    } catch (e) {
      debugPrint('FitnessRepository.logSession error: $e');
      rethrow;
    }
  }

  Future<FitnessSummary> getFitnessSummary({DateTime? date}) async {
    final summaryDate = date ?? DateTime.now();
    FitnessSummary remoteSummary =
        FitnessSummary(date: summaryDate, sessions: []);
    try {
      final formattedDate = summaryDate.toIso8601String().split('T')[0];
      final response = await _client.get(
        ApiEndpoints.fitnessSummary,
        queryParameters: {'date': formattedDate},
      );

      final data =
          response.data is Map ? response.data : {'data': response.data};
      remoteSummary = _mapSummary(data['data'] ?? data, summaryDate);
    } catch (e) {
      debugPrint('FitnessRepository.getFitnessSummary error: $e');
      if (e is! DioException || e.response?.statusCode != 404) {
        rethrow;
      }
    }
    final localSessions = await _loadLocalSessionsForDate(summaryDate);
    if (localSessions.isEmpty) return remoteSummary;
    return FitnessSummary(
      date: remoteSummary.date,
      sessions: [...remoteSummary.sessions, ...localSessions],
      totalFatigueImpact: remoteSummary.totalFatigueImpact +
          localSessions.fold<double>(
              0, (sum, session) => sum + session.estimatedFatigueImpact),
      totalRecoveryLoad: remoteSummary.totalRecoveryLoad,
      muscleCoverage: remoteSummary.muscleCoverage,
      weeklyLoad: remoteSummary.weeklyLoad,
    );
  }

  FitnessSummary _mapSummary(Map<String, dynamic> json, DateTime date) {
    // Basic mapping, assuming backend returns a list of sessions and some stats
    final rawSessions = json['sessions'] as List? ?? [];
    final rawWeeklyLoad = json['weeklyLoad'] as List? ?? [];
    final muscleData = json['muscleCoverage'] as Map? ?? {};

    return FitnessSummary(
      date: date,
      sessions: rawSessions.map((s) => _mapSession(s)).toList(),
      totalFatigueImpact: _toDouble(json['totalFatigueImpact']),
      totalRecoveryLoad: _toDouble(json['totalRecoveryLoad']),
      muscleCoverage: muscleData.cast<String, double>(),
      weeklyLoad: rawWeeklyLoad
          .map((p) => LoadDataPoint(
                date: DateTime.tryParse(p['date'].toString()) ?? DateTime.now(),
                value: _toDouble(p['value']),
                intensity: p['intensity']?.toString() ?? 'MED',
              ))
          .toList(),
    );
  }

  WorkoutSession _mapSession(Map<String, dynamic> json) {
    final rawExercises = json['exercises'] as List? ?? [];
    return WorkoutSession(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      loggedAt: DateTime.tryParse(json['loggedAt']?.toString() ?? '') ??
          DateTime.now(),
      intensity: _parseIntensity(json['intensity']),
      exercises: rawExercises.map((e) => _mapWorkoutExercise(e)).toList(),
      notes: json['notes']?.toString(),
    );
  }

  WorkoutExercise _mapWorkoutExercise(Map<String, dynamic> json) {
    final rawExercise = json['exercise'] ?? json;
    return WorkoutExercise(
      exercise: FitnessExercise.fromJson(rawExercise),
      sets: _toInt(json['sets']),
      reps: _toInt(json['reps']),
      weightKg: _toDouble(json['weightKg']),
      durationMinutes: _toInt(json['durationMinutes']),
      intensity: _toInt(json['intensity']),
    );
  }

  SessionIntensity _parseIntensity(dynamic v) {
    final s = v?.toString().toUpperCase() ?? '';
    if (s == 'LOW') return SessionIntensity.low;
    if (s == 'INTENSE' || s == 'HIGH') return SessionIntensity.intense;
    return SessionIntensity.moderate;
  }

  double _toDouble(dynamic v) =>
      v is num ? v.toDouble() : double.tryParse(v?.toString() ?? '') ?? 0;

  int _toInt(dynamic v) =>
      v is num ? v.toInt() : int.tryParse(v?.toString() ?? '') ?? 0;

  Future<void> _saveLocalSession(WorkoutSession session) async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList(_localSessionsKey) ?? const <String>[];
    final localSession = WorkoutSession(
      id: session.id.isNotEmpty
          ? session.id
          : 'local-${DateTime.now().microsecondsSinceEpoch}',
      loggedAt: session.loggedAt,
      exercises: session.exercises,
      intensity: session.intensity,
      notes: session.notes,
    );
    await prefs.setStringList(
      _localSessionsKey,
      [...saved, jsonEncode(_sessionToLocalJson(localSession))],
    );
    debugPrint(
        'FitnessRepository saved session locally because backend fitness route is unavailable');
  }

  Future<List<WorkoutSession>> _loadLocalSessionsForDate(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList(_localSessionsKey) ?? const <String>[];
    final result = <WorkoutSession>[];
    for (final raw in saved) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is! Map<String, dynamic>) continue;
        final session = _mapSession(decoded);
        if (_sameDate(session.loggedAt, date)) result.add(session);
      } catch (e) {
        debugPrint('FitnessRepository local session parse error: $e');
      }
    }
    return result;
  }

  Map<String, dynamic> _sessionToLocalJson(WorkoutSession session) => {
        'id': session.id,
        'loggedAt': session.loggedAt.toIso8601String(),
        'intensity': session.intensity.name.toUpperCase(),
        'exercises': session.exercises
            .map((exercise) => exercise.toJson(includeExercise: true))
            .toList(),
        if (session.notes != null) 'notes': session.notes,
      };

  bool _sameDate(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
