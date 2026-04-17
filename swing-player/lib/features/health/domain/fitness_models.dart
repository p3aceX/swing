import 'package:flutter/material.dart';

// ── Exercise Library Model ────────────────────────────────────────────────────

enum FitnessLevel { beginner, intermediate, advanced }

class FitnessExercise {
  const FitnessExercise({
    required this.id,
    required this.name,
    required this.category,
    required this.bodyAreaTags,
    required this.level,
    required this.fatigueImpact, // 1-5
    required this.recoveryDemand, // 1-5
    required this.minReadiness,
    required this.maxReadiness,
    this.durationMins,
    this.defaultSets,
    this.defaultReps,
    this.intensityLevel,
    this.primaryMuscle,
    this.secondaryMuscles = const [],
    this.icon,
  });

  final String id;
  final String name;
  final String category;
  final List<String> bodyAreaTags;
  final FitnessLevel level;
  final int fatigueImpact;
  final int recoveryDemand;
  final int minReadiness;
  final int maxReadiness;
  final int? durationMins;
  final int? defaultSets;
  final int? defaultReps;
  final String? intensityLevel;
  final String? primaryMuscle;
  final List<String> secondaryMuscles;
  final IconData? icon;

  factory FitnessExercise.fromJson(Map<String, dynamic> json) {
    return FitnessExercise(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      name: (json['name'] ?? 'Unknown').toString(),
      category: (json['category'] ?? 'General').toString(),
      bodyAreaTags: _toStringList(json['bodyAreaTags']),
      level: _parseLevel(json['level'] ?? json['levelTags']),
      fatigueImpact: _loadValue(json['fatigueImpact']),
      recoveryDemand:
          _loadValue(json['recoveryDemand'] ?? json['recoveryLoad']),
      minReadiness: _toInt(json['minReadiness'] ?? json['readinessMin']),
      maxReadiness: _toInt(json['maxReadiness'] ?? json['readinessMax'] ?? 100),
      durationMins: _nullableInt(json['durationMins']),
      defaultSets: _nullableInt(json['sets']),
      defaultReps: _nullableInt(json['reps']),
      intensityLevel: json['intensityLevel']?.toString(),
      primaryMuscle: json['primaryMuscle']?.toString(),
      secondaryMuscles: _toStringList(json['secondaryMuscles']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'category': category,
        'bodyAreaTags': bodyAreaTags,
        'level': level.name,
        'fatigueImpact': fatigueImpact,
        'recoveryDemand': recoveryDemand,
        'minReadiness': minReadiness,
        'maxReadiness': maxReadiness,
        if (durationMins != null) 'durationMins': durationMins,
        if (defaultSets != null) 'sets': defaultSets,
        if (defaultReps != null) 'reps': defaultReps,
        if (intensityLevel != null) 'intensityLevel': intensityLevel,
        if (primaryMuscle != null) 'primaryMuscle': primaryMuscle,
        'secondaryMuscles': secondaryMuscles,
      };

  static FitnessLevel _parseLevel(dynamic v) {
    final s = v is List
        ? v.join(' ').toLowerCase()
        : v?.toString().toLowerCase() ?? '';
    if (s.contains('adv')) return FitnessLevel.advanced;
    if (s.contains('elite')) return FitnessLevel.advanced;
    if (s.contains('int')) return FitnessLevel.intermediate;
    return FitnessLevel.beginner;
  }

  static int _loadValue(dynamic v) {
    if (v is num) return v.round().clamp(0, 5);
    final s = v?.toString().toUpperCase() ?? '';
    if (s == 'HIGH') return 4;
    if (s == 'MODERATE') return 3;
    if (s == 'LOW') return 1;
    return 2;
  }
}

// ── Logged Exercise Model ─────────────────────────────────────────────────────

class WorkoutExercise {
  WorkoutExercise({
    required this.exercise,
    this.sets = 3,
    this.reps = 10,
    this.weightKg,
    this.durationMinutes,
    this.intensity = 5,
  });

  final FitnessExercise exercise;
  int sets;
  int reps;
  double? weightKg;
  int? durationMinutes;
  int intensity; // 1-10

  Map<String, dynamic> toJson({bool includeExercise = false}) => {
        'exerciseId': exercise.id,
        if (includeExercise) 'exercise': exercise.toJson(),
        'sets': sets,
        'reps': reps,
        if (weightKg != null) 'weightKg': weightKg,
        if (durationMinutes != null) 'durationMinutes': durationMinutes,
        'intensity': intensity,
      };
}

// ── Session Model ─────────────────────────────────────────────────────────────

enum SessionIntensity { low, moderate, intense }

class WorkoutSession {
  WorkoutSession({
    required this.id,
    required this.loggedAt,
    required this.exercises,
    this.intensity = SessionIntensity.moderate,
    this.notes,
  });

  final String id;
  final DateTime loggedAt;
  final List<WorkoutExercise> exercises;
  SessionIntensity intensity;
  String? notes;

  int get totalDuration =>
      exercises.fold(0, (sum, e) => sum + (e.durationMinutes ?? 0));

  double get estimatedFatigueImpact {
    if (exercises.isEmpty) return 0;
    final total = exercises.fold(
        0.0, (sum, e) => sum + (e.exercise.fatigueImpact * (e.intensity / 5)));
    return (total / exercises.length).clamp(0, 5);
  }

  Map<String, dynamic> toJson() => {
        'loggedAt': loggedAt.toIso8601String(),
        'intensity': intensity.name.toUpperCase(),
        'exercises': exercises.map((e) => e.toJson()).toList(),
        if (notes != null) 'notes': notes,
      };
}

// ── Dashboard / Summary Models ────────────────────────────────────────────────

class FitnessSummary {
  const FitnessSummary({
    required this.date,
    required this.sessions,
    this.totalFatigueImpact = 0,
    this.totalRecoveryLoad = 0,
    this.muscleCoverage = const {},
    this.weeklyLoad = const [],
  });

  final DateTime date;
  final List<WorkoutSession> sessions;
  final double totalFatigueImpact;
  final double totalRecoveryLoad;
  final Map<String, double> muscleCoverage; // "Upper": 0.7, etc.
  final List<LoadDataPoint> weeklyLoad;
}

class LoadDataPoint {
  const LoadDataPoint({
    required this.date,
    required this.value,
    required this.intensity,
  });
  final DateTime date;
  final double value;
  final String intensity; // LOW, MED, HIGH
}

// ── Helpers ──────────────────────────────────────────────────────────────────

int _toInt(dynamic v) =>
    v is num ? v.toInt() : int.tryParse(v?.toString() ?? '') ?? 0;

int? _nullableInt(dynamic v) =>
    v == null ? null : (v is num ? v.toInt() : int.tryParse(v.toString()));

List<String> _toStringList(dynamic v) =>
    v is List ? v.map((e) => e.toString()).toList() : [];
