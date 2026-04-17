import 'package:flutter/material.dart';

class EliteProfile {
  final EliteRanking ranking;
  final ElitePreparation preparation;
  final List<EliteInsight> insights;
  final EliteSwot swot;
  final List<EliteStreakDay> streak;
  final List<EliteTechnicalMetric> technical;
  final List<EliteLoadPoint> trainingLoad;
  final Map<String, dynamic> precision;
  final bool isApex;
  final ApexGoal? goal;

  /// 0.0–100.0 — percentage of planned sessions actually executed.
  final double disciplineScore;

  /// Maps activity type → {actual, planned} counts.
  /// e.g. {"NETS": {"actual": 3, "planned": 4}, "GYM": {"actual": 2, "planned": 3}}
  final Map<String, Map<String, int>> planAdherence;

  const EliteProfile({
    required this.ranking,
    required this.preparation,
    required this.insights,
    required this.swot,
    this.streak = const [],
    this.technical = const [],
    this.trainingLoad = const [],
    this.precision = const {},
    this.isApex = false,
    this.goal,
    this.disciplineScore = 0,
    this.planAdherence = const {},
  });

  factory EliteProfile.fromJson(Map<String, dynamic> json) {
    try {
      final dash = _asMap(json['apexDashboard']);
      debugPrint(
          '[EliteProfile] Parsing started. Has dash: ${dash.isNotEmpty}');

      final ranking =
          EliteRanking.fromJson(_asMap(json['ranking'] ?? dash['ranking']));
      debugPrint('[EliteProfile] Ranking parsed: ${ranking.swingIndex}');

      final preparation = ElitePreparation.fromJson(
          _asMap(json['preparation'] ?? dash['preparation']));
      debugPrint('[EliteProfile] Prep parsed: ${preparation.score}');

      final insights = _asList(json['insights'] ?? dash['insights'])
          .map((e) => EliteInsight.fromJson(_asMap(e)))
          .toList();
      debugPrint('[EliteProfile] Insights parsed: ${insights.length}');

      final swot = EliteSwot.fromJson(_asMap(json['swot'] ?? dash['swot']));
      debugPrint('[EliteProfile] SWOT parsed');

      final streak = _asList(json['streak'] ?? dash['streak'])
          .map((e) => EliteStreakDay.fromJson(_asMap(e)))
          .toList();
      debugPrint('[EliteProfile] Streak parsed: ${streak.length}');

      final technical = _asList(json['technical'] ?? dash['technical'])
          .map((e) => EliteTechnicalMetric.fromJson(_asMap(e)))
          .toList();
      debugPrint('[EliteProfile] Tech parsed: ${technical.length}');

      final trainingLoad = _asList(json['trainingLoad'] ?? dash['trainingLoad'])
          .map((e) => EliteLoadPoint.fromJson(_asMap(e)))
          .toList();
      debugPrint('[EliteProfile] Load parsed: ${trainingLoad.length}');

      final precision = _asMap(json['precision'] ?? dash['precision']);
      debugPrint('[EliteProfile] Precision keys: ${precision.keys.toList()}');

      final isApex = json['isApex'] ?? dash['isApex'] ?? false;

      final goalRaw = json['ambition'] ?? json['goal'] ?? dash['ambition'] ?? dash['goal'];
      final goal = goalRaw != null ? ApexGoal.fromJson(_asMap(goalRaw)) : null;

      final disciplineScore =
          (json['disciplineScore'] ?? dash['disciplineScore'] ?? 0).toDouble();

      final adherenceRaw = json['planAdherence'] ?? dash['planAdherence'];
      final planAdherence = <String, Map<String, int>>{};
      if (adherenceRaw is Map) {
        for (final entry in adherenceRaw.entries) {
          final inner = entry.value;
          if (inner is Map) {
            planAdherence['${entry.key}'] = {
              'actual': (inner['actual'] ?? 0) as int,
              'planned': (inner['planned'] ?? 0) as int,
            };
          }
        }
      }
      debugPrint(
          '[EliteProfile] disciplineScore=$disciplineScore, adherence keys=${planAdherence.keys.toList()}');

      return EliteProfile(
        ranking: ranking,
        preparation: preparation,
        insights: insights,
        swot: swot,
        streak: streak,
        technical: technical,
        trainingLoad: trainingLoad,
        precision: precision,
        isApex: isApex == true,
        goal: goal,
        disciplineScore: disciplineScore,
        planAdherence: planAdherence,
      );
    } catch (e, stack) {
      debugPrint('[EliteProfile] FATAL parsing error: $e');
      debugPrint(stack.toString());
      rethrow;
    }
  }
}

class ApexGoal {
  // ── Cricket mission ────────────────────────────────────────────────────────
  final String targetRole;
  final String targetFormat;
  final String styleIdentity;
  final String targetLevel;
  final String timeline;
  final List<String> focusAreas;
  final Map<String, int> selfAssessment;
  final String commitmentStatement;

  // ── Body goal ──────────────────────────────────────────────────────────────
  /// 'male' | 'female' | 'other'  — stored here until backend has gender field
  final String? gender;
  final double? targetWeight;           // kg
  /// 'cut' | 'bulk' | 'recompose' | 'maintain'
  final String? bodyTransformDirection;
  final double? targetBodyFatPercent;   // %

  // ── Measurements (US Navy Method) ──────────────────────────────────────────
  final double? waistCm;
  final double? neckCm;
  final double? hipCm;

  // ── Fitness goal ───────────────────────────────────────────────────────────
  final int? trainingDaysPerWeek;       // 1–7
  /// 'strength' | 'endurance' | 'speed' | 'mobility' | 'recovery' | 'all_round'
  final List<String> fitnessFocuses;

  // ── Nutrition goal ─────────────────────────────────────────────────────────
  /// 'fat_loss' | 'maintenance' | 'muscle_gain' | 'performance_fueling'
  final String? nutritionObjective;

  // ── Recovery & lifestyle ───────────────────────────────────────────────────
  final double? dailySleepHoursGoal;        // 6.0–10.0
  final double? dailyHydrationLitresGoal;   // 1.5–5.0
  final String? morningWakeUpTime;           // 'HH:MM' 24-hour
  final List<String> habitsToQuit;
  final List<String> disciplineGoals;

  // ── Physical profile (synced to PlayerProfile) ─────────────────────────────
  final double? heightCm;          // cm
  final double? weightKg;          // current weight, kg
  final double? bmi;               // computed server-side
  final double? bodyFatPercent;    // %, computed server-side (US Navy Method)
  final int? dailyCalorieTarget;   // kcal, computed server-side

  const ApexGoal({
    required this.targetRole,
    required this.targetFormat,
    required this.styleIdentity,
    required this.targetLevel,
    required this.timeline,
    required this.focusAreas,
    required this.selfAssessment,
    required this.commitmentStatement,
    this.gender,
    this.targetWeight,
    this.bodyTransformDirection,
    this.targetBodyFatPercent,
    this.waistCm,
    this.neckCm,
    this.hipCm,
    this.trainingDaysPerWeek,
    this.fitnessFocuses = const [],
    this.nutritionObjective,
    this.dailySleepHoursGoal,
    this.dailyHydrationLitresGoal,
    this.morningWakeUpTime,
    this.habitsToQuit = const [],
    this.disciplineGoals = const [],
    this.heightCm,
    this.weightKg,
    this.bmi,
    this.bodyFatPercent,
    this.dailyCalorieTarget,
  });

  factory ApexGoal.fromJson(Map<String, dynamic> json) => ApexGoal(
        targetRole: json['targetRole'] ?? '',
        targetFormat: json['targetFormat'] ?? '',
        styleIdentity: json['styleIdentity'] ?? '',
        targetLevel: json['targetLevel'] ?? '',
        timeline: json['timeline'] ?? '',
        focusAreas: List<String>.from(json['focusAreas'] ?? []),
        selfAssessment: Map<String, int>.from(json['selfAssessment'] ?? {}),
        commitmentStatement: json['commitmentStatement'] ?? '',
        gender: (json['gender'] ?? _asMap(json['profile'])['gender']) as String?,
        targetWeight: (json['targetWeight'] as num?)?.toDouble(),
        bodyTransformDirection: json['bodyTransformDirection'] as String?,
        targetBodyFatPercent: (json['targetBodyFatPercent'] as num?)?.toDouble(),
        waistCm: (json['waistCm'] ?? json['waistCircumferenceCm'])?.toDouble(),
        neckCm: (json['neckCm'] ?? json['neckCircumferenceCm'])?.toDouble(),
        hipCm: (json['hipCm'] ?? json['hipCircumferenceCm'])?.toDouble(),
        trainingDaysPerWeek: json['trainingDaysPerWeek'] as int?,
        fitnessFocuses: List<String>.from(json['fitnessFocuses'] ?? []),
        nutritionObjective: json['nutritionObjective'] as String?,
        dailySleepHoursGoal: (json['dailySleepHoursGoal'] as num?)?.toDouble(),
        dailyHydrationLitresGoal:
            (json['dailyHydrationLitresGoal'] as num?)?.toDouble(),
        morningWakeUpTime: json['morningWakeUpTime'] as String?,
        habitsToQuit: List<String>.from(json['habitsToQuit'] ?? []),
        disciplineGoals: List<String>.from(json['disciplineGoals'] ?? []),
        heightCm: (json['heightCm'] ?? json['height'] ?? _asMap(json['profile'])['heightCm'])?.toDouble(),
        weightKg: (json['weightKg'] ?? json['weight'] ?? _asMap(json['profile'])['weightKg'])?.toDouble(),
        bmi: (json['bmi'] as num?)?.toDouble(),
        bodyFatPercent: (json['bodyFatPercent'] as num?)?.toDouble(),
        dailyCalorieTarget: json['dailyCalorieTarget'] as int?,
      );

  Map<String, dynamic> toJson() => {
        'targetRole': targetRole,
        'targetFormat': targetFormat,
        'styleIdentity': styleIdentity,
        'targetLevel': targetLevel,
        'timeline': timeline,
        'focusAreas': focusAreas,
        'selfAssessment': selfAssessment,
        'commitmentStatement': commitmentStatement,
        if (gender != null) 'gender': gender,
        if (targetWeight != null) 'targetWeight': targetWeight,
        if (bodyTransformDirection != null)
          'bodyTransformDirection': bodyTransformDirection,
        if (targetBodyFatPercent != null)
          'targetBodyFatPercent': targetBodyFatPercent,
        if (waistCm != null) 'waistCm': waistCm,
        if (neckCm != null) 'neckCm': neckCm,
        if (hipCm != null) 'hipCm': hipCm,
        if (trainingDaysPerWeek != null)
          'trainingDaysPerWeek': trainingDaysPerWeek,
        if (fitnessFocuses.isNotEmpty) 'fitnessFocuses': fitnessFocuses,
        if (nutritionObjective != null) 'nutritionObjective': nutritionObjective,
        if (dailySleepHoursGoal != null)
          'dailySleepHoursGoal': dailySleepHoursGoal,
        if (dailyHydrationLitresGoal != null)
          'dailyHydrationLitresGoal': dailyHydrationLitresGoal,
        if (morningWakeUpTime != null) 'morningWakeUpTime': morningWakeUpTime,
        if (habitsToQuit.isNotEmpty) 'habitsToQuit': habitsToQuit,
        if (disciplineGoals.isNotEmpty) 'disciplineGoals': disciplineGoals,
        if (heightCm != null) 'heightCm': heightCm,
        if (weightKg != null) 'weightKg': weightKg,
        if (bmi != null) 'bmi': bmi,
        if (bodyFatPercent != null) 'bodyFatPercent': bodyFatPercent,
        if (dailyCalorieTarget != null) 'dailyCalorieTarget': dailyCalorieTarget,
      };
}

List<dynamic> _asList(dynamic val) => (val is List) ? val : [];

Map<String, dynamic> _asMap(dynamic val) =>
    (val is Map) ? Map<String, dynamic>.from(val) : <String, dynamic>{};

double _toDouble(dynamic val) {
  if (val == null) return 0.0;
  if (val is num) return val.toDouble();
  if (val is String) return double.tryParse(val) ?? 0.0;
  return 0.0;
}

int _toInt(dynamic val) {
  if (val == null) return 0;
  if (val is num) return val.toInt();
  if (val is String) return int.tryParse(val) ?? 0;
  return 0;
}

bool _toBool(dynamic val) {
  if (val == null) return false;
  if (val is bool) return val;
  if (val is num) return val != 0;
  if (val is String) {
    final normalized = val.trim().toLowerCase();
    return normalized == 'true' || normalized == '1' || normalized == 'yes';
  }
  return false;
}

DateTime _toDate(dynamic val) {
  if (val == null) return DateTime.now();
  if (val is String) {
    return DateTime.tryParse(val) ?? DateTime.now();
  }
  return DateTime.now();
}

// ── Performance Audit UI Models ─────────────────────────────────────────────

enum LogType { TRAINING, MATCH, RECOVERY }

class ElitePerformanceLog {
  final DateTime date;
  final LogType type;
  final DayState dayState;
  final String dayTakeaway;
  final List<TrainingSession>? sessions;
  final MatchReview? matchReview;
  final RecoveryDetail? recoveryDetail;

  const ElitePerformanceLog({
    required this.date,
    required this.type,
    required this.dayState,
    required this.dayTakeaway,
    this.sessions,
    this.matchReview,
    this.recoveryDetail,
  });

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String().split('T')[0], // YYYY-MM-DD
        'type': type.name,
        'dayState': dayState.toJson(),
        'dayTakeaway': dayTakeaway,
        if (type == LogType.TRAINING)
          'sessions': sessions?.map((s) => s.toJson()).toList(),
        if (type == LogType.MATCH) 'matchReview': matchReview?.toJson(),
        if (type == LogType.RECOVERY)
          'recoveryDetail': recoveryDetail?.toJson(),
      };
}

class DayState {
  final double sleepHours;
  final int sleepQuality;
  final double hydrationLiters;
  final int soreness;
  final int fatigue;
  final int mentalFreshness;
  final int motivation;

  const DayState({
    required this.sleepHours,
    required this.sleepQuality,
    required this.hydrationLiters,
    required this.soreness,
    required this.fatigue,
    required this.mentalFreshness,
    required this.motivation,
  });

  Map<String, dynamic> toJson() => {
        'sleepHours': sleepHours,
        'sleepQuality': sleepQuality,
        'hydrationLiters': hydrationLiters,
        'soreness': soreness,
        'fatigue': fatigue,
        'mentalFreshness': mentalFreshness,
        'motivation': motivation,
      };
}

class TrainingSession {
  final String type;
  final int plannedDuration;
  final int actualDuration;
  final int plannedIntensity;
  final int actualIntensity;
  final String objective;
  final List<DrillAudit> drills;
  final List<MetricRating> ratings;

  const TrainingSession({
    required this.type,
    required this.plannedDuration,
    required this.actualDuration,
    required this.plannedIntensity,
    required this.actualIntensity,
    required this.objective,
    required this.drills,
    required this.ratings,
  });

  Map<String, dynamic> toJson() => {
        'type': type,
        'plannedDuration': plannedDuration,
        'actualDuration': actualDuration,
        'plannedIntensity': plannedIntensity,
        'actualIntensity': actualIntensity,
        'objective': objective,
        'drills': drills.map((d) => d.toJson()).toList(),
        'ratings': ratings.map((r) => r.toJson()).toList(),
      };
}

class DrillAudit {
  final String drillId;
  final int plannedReps;
  final int actualReps;
  final int executionQuality;

  const DrillAudit({
    required this.drillId,
    required this.plannedReps,
    required this.actualReps,
    required this.executionQuality,
  });

  Map<String, dynamic> toJson() => {
        'drillId': drillId,
        'plannedReps': plannedReps,
        'actualReps': actualReps,
        'executionQuality': executionQuality,
      };
}

class MetricRating {
  final String metricCode;
  final int value;

  const MetricRating({required this.metricCode, required this.value});

  Map<String, dynamic> toJson() => {
        'metricCode': metricCode,
        'value': value,
      };
}

class MatchReview {
  final String matchSource;
  final String? matchId;
  final Map<String, dynamic>? manualData;
  final String role;
  final List<String> intentCodes;
  final String successDefinition;
  final int selfRating;
  final String tacticalPivot;
  final String turningPoint;

  const MatchReview({
    required this.matchSource,
    this.matchId,
    this.manualData,
    required this.role,
    required this.intentCodes,
    required this.successDefinition,
    required this.selfRating,
    required this.tacticalPivot,
    required this.turningPoint,
  });

  Map<String, dynamic> toJson() => {
        'matchSource': matchSource,
        if (matchId != null) 'matchId': matchId,
        if (manualData != null) 'manualData': manualData,
        'role': role,
        'intentCodes': intentCodes,
        'successDefinition': successDefinition,
        'selfRating': selfRating,
        'tacticalPivot': tacticalPivot,
        'turningPoint': turningPoint,
      };
}

class RecoveryDetail {
  final String primaryActivity;
  final String notes;

  const RecoveryDetail({required this.primaryActivity, required this.notes});

  Map<String, dynamic> toJson() => {
        'primaryActivity': primaryActivity,
        'notes': notes,
      };
}

// ── Journal Submission Model (Backend Specification) ─────────────────────────

class EliteJournalEntry {
  final DateTime date;
  final String activityType;
  final int durationMinutes;
  final int intensity;
  final List<String> drillIds;
  final String? notes;
  final EliteMentalStats mental;
  final EliteContextStats context;

  const EliteJournalEntry({
    required this.date,
    required this.activityType,
    required this.durationMinutes,
    required this.intensity,
    required this.drillIds,
    this.notes,
    required this.mental,
    required this.context,
  });

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(), // Validates against DateTime pattern
        'activity': {
          'type': activityType,
          'durationMinutes': durationMinutes,
          'intensity': intensity,
          'drillIds': drillIds,
          'notes': notes,
        },
        'mental': {
          'confidence': mental.confidence,
          'focus': mental.focus,
          'resilience': mental.resilience,
        },
        'context': {
          'sleepQuality': context.sleepQuality,
          'hydrationLiters': context.hydrationLiters,
          'soreness': context.soreness,
          'fatigue': context.fatigue,
          'mood': context.mood,
          'stress': context.stress,
        },
      };
}

class EliteMentalStats {
  final int confidence;
  final int focus;
  final int resilience;

  const EliteMentalStats({
    required this.confidence,
    required this.focus,
    required this.resilience,
  });
}

class EliteContextStats {
  final int sleepQuality;
  final double hydrationLiters;
  final int soreness;
  final int fatigue;
  final int mood;
  final int stress;

  const EliteContextStats({
    required this.sleepQuality,
    required this.hydrationLiters,
    required this.soreness,
    required this.fatigue,
    required this.mood,
    required this.stress,
  });
}

// ── Dashboard Sub-Models ────────────────────────────────────────────────────

class EliteTechnicalMetric {
  final String label;
  final double value; // 0-100

  const EliteTechnicalMetric({required this.label, required this.value});

  factory EliteTechnicalMetric.fromJson(Map<String, dynamic> json) {
    return EliteTechnicalMetric(
      label: json['label'] ?? '',
      value: _toDouble(json['value']),
    );
  }
}

class EliteLoadPoint {
  final DateTime date;
  final double duration;
  final double recovery;

  const EliteLoadPoint({
    required this.date,
    required this.duration,
    required this.recovery,
  });

  factory EliteLoadPoint.fromJson(Map<String, dynamic> json) {
    return EliteLoadPoint(
      date: _toDate(json['date']),
      duration: _toDouble(json['duration']),
      recovery: _toDouble(json['recovery']),
    );
  }
}

class EliteRanking {
  final double swingIndex;
  final String label;
  final int division;
  final List<EliteTrendPoint> history;

  const EliteRanking({
    required this.swingIndex,
    this.label = '',
    this.division = 0,
    required this.history,
  });

  factory EliteRanking.fromJson(Map<String, dynamic> json) {
    return EliteRanking(
      swingIndex: _toDouble(json['swingIndex']),
      label: json['label'] ?? '',
      division: _toInt(json['division']),
      history: _asList(json['history'])
          .map((e) => EliteTrendPoint.fromJson(_asMap(e)))
          .toList(),
    );
  }
}

class ElitePreparation {
  final double score;
  final double trainingConsistency;
  final double mentalStrength;
  final int daysLogged;
  // Kept for backward compatibility
  final double readiness;
  final double load;
  final double recovery;

  const ElitePreparation({
    required this.score,
    this.trainingConsistency = 0,
    this.mentalStrength = 0,
    this.daysLogged = 0,
    this.readiness = 0,
    this.load = 0,
    this.recovery = 0,
  });

  factory ElitePreparation.fromJson(Map<String, dynamic> json) {
    return ElitePreparation(
      score: _toDouble(json['score']),
      trainingConsistency: _toDouble(json['trainingConsistency']),
      mentalStrength: _toDouble(json['mentalStrength']),
      daysLogged: _toInt(json['daysLogged']),
      readiness: _toDouble(json['readiness']),
      load: _toDouble(json['load']),
      recovery: _toDouble(json['recovery']),
    );
  }
}

class EliteTrendPoint {
  final DateTime date;
  final double value;

  const EliteTrendPoint({
    required this.date,
    required this.value,
  });

  factory EliteTrendPoint.fromJson(Map<String, dynamic> json) {
    return EliteTrendPoint(
      date: _toDate(json['date']),
      value: _toDouble(json['value']),
    );
  }
}

class EliteInsight {
  final String id;
  final String title;
  final String description;
  final EliteInsightCategory category;

  const EliteInsight({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
  });

  factory EliteInsight.fromJson(Map<String, dynamic> json) {
    return EliteInsight(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      category: _parseCategory(json['category']),
    );
  }

  static EliteInsightCategory _parseCategory(String? cat) {
    return switch (cat?.toLowerCase()) {
      'tactical' => EliteInsightCategory.tactical,
      'physical' => EliteInsightCategory.physical,
      'mental' => EliteInsightCategory.mental,
      'technical' => EliteInsightCategory.technical,
      _ => EliteInsightCategory.tactical,
    };
  }
}

enum EliteInsightCategory { tactical, physical, mental, technical }

class EliteSwot {
  final List<String> strengths;
  final List<String> weaknesses;
  final List<String> opportunities;
  final List<String> threats;

  const EliteSwot({
    required this.strengths,
    required this.weaknesses,
    required this.opportunities,
    required this.threats,
  });

  factory EliteSwot.fromJson(Map<String, dynamic> json) {
    return EliteSwot(
      strengths: List<String>.from(json['strengths'] ?? []),
      weaknesses: List<String>.from(json['weaknesses'] ?? []),
      opportunities: List<String>.from(json['opportunities'] ?? []),
      threats: List<String>.from(json['threats'] ?? []),
    );
  }
}

class EliteStreakDay {
  final DateTime date;
  final bool active;
  final bool isIndiscipline;

  const EliteStreakDay({
    required this.date,
    required this.active,
    this.isIndiscipline = false,
  });

  factory EliteStreakDay.fromJson(Map<String, dynamic> json) {
    final reason = (json['reason'] ?? '').toString().toUpperCase();
    return EliteStreakDay(
      date: _toDate(json['date']),
      active: json['active'] ?? false,
      isIndiscipline: json['isIndiscipline'] == true ||
          reason == 'CHEAT_DAY' ||
          reason == 'MISSING_LOG' ||
          reason == 'INDISCIPLINE',
    );
  }
}

// ── New Journal Models (Activity-based) ─────────────────────────────────────

enum ActivityCategory {
  nets,
  skillWork,
  conditioning,
  gym,
  match,
  recovery,
}

extension ActivityCategoryX on ActivityCategory {
  String get label => switch (this) {
        ActivityCategory.nets => 'Nets',
        ActivityCategory.skillWork => 'Skill Work',
        ActivityCategory.conditioning => 'Conditioning',
        ActivityCategory.gym => 'Gym',
        ActivityCategory.match => 'Match',
        ActivityCategory.recovery => 'Recovery',
      };

  String get subtitle => switch (this) {
        ActivityCategory.nets => 'Session at the crease',
        ActivityCategory.skillWork => 'Drills & solo practice',
        ActivityCategory.conditioning => 'Running, meditation',
        ActivityCategory.gym => 'Strength & fitness',
        ActivityCategory.match => 'Game day',
        ActivityCategory.recovery => 'Rest & maintenance',
      };

  String get apiType => switch (this) {
        ActivityCategory.nets => 'NETS',
        ActivityCategory.skillWork => 'SKILL_WORK',
        ActivityCategory.conditioning => 'CONDITIONING',
        ActivityCategory.gym => 'GYM',
        ActivityCategory.match => 'MATCH',
        ActivityCategory.recovery => 'RECOVERY',
      };
}

enum ConditioningType { running, meditation }

extension ConditioningTypeX on ConditioningType {
  String get label =>
      this == ConditioningType.running ? 'Running' : 'Meditation';
}

enum RunType { easy, intervals, sprints, longRun }

extension RunTypeX on RunType {
  String get label => switch (this) {
        RunType.easy => 'Easy Run',
        RunType.intervals => 'Intervals',
        RunType.sprints => 'Sprints',
        RunType.longRun => 'Long Run',
      };
}

enum GymFocus { strength, cardio, mixed, mobility }

extension GymFocusX on GymFocus {
  String get label => switch (this) {
        GymFocus.strength => 'Strength',
        GymFocus.cardio => 'Cardio',
        GymFocus.mixed => 'Mixed',
        GymFocus.mobility => 'Mobility',
      };
}

enum BodyState { sore, okay, fresh }

extension BodyStateX on BodyState {
  String get label => switch (this) {
        BodyState.sore => 'Sore',
        BodyState.okay => 'Okay',
        BodyState.fresh => 'Fresh',
      };
}

class DailyVitals {
  final double sleepHours;
  final double hydrationLiters;

  const DailyVitals({required this.sleepHours, required this.hydrationLiters});

  Map<String, dynamic> toJson() => {
        'sleepHours': sleepHours,
        'hydrationLiters': hydrationLiters,
      };
}

class NetsJournalDetail {
  final List<String> drills;
  final String whatClicked;
  final String whatNeedsWork;
  final int rating; // 1–10

  const NetsJournalDetail({
    required this.drills,
    required this.whatClicked,
    required this.whatNeedsWork,
    required this.rating,
  });
}

class SkillWorkJournalDetail {
  final String drillName;
  final int quality; // 1–10
  final String observation;

  const SkillWorkJournalDetail({
    required this.drillName,
    required this.quality,
    required this.observation,
  });
}

class ConditioningJournalDetail {
  final ConditioningType type;
  final RunType? runType; // only when type == running
  final String observation;

  const ConditioningJournalDetail({
    required this.type,
    this.runType,
    required this.observation,
  });
}

class GymJournalDetail {
  final GymFocus focus;
  final int energyLevel; // 1–10
  final String note;

  const GymJournalDetail({
    required this.focus,
    required this.energyLevel,
    required this.note,
  });
}

class MatchJournalDetail {
  final String role;
  final String executedWell;
  final String toFix;
  final int rating; // 1–10

  const MatchJournalDetail({
    required this.role,
    required this.executedWell,
    required this.toFix,
    required this.rating,
  });
}

class RecoveryJournalDetail {
  final List<String> types;
  final BodyState bodyState;
  final String note;

  const RecoveryJournalDetail({
    required this.types,
    required this.bodyState,
    required this.note,
  });
}

class ActivityJournalEntry {
  final DateTime date;
  final ActivityCategory activity;
  final NetsJournalDetail? netsDetail;
  final SkillWorkJournalDetail? skillWorkDetail;
  final ConditioningJournalDetail? conditioningDetail;
  final GymJournalDetail? gymDetail;
  final MatchJournalDetail? matchDetail;
  final RecoveryJournalDetail? recoveryDetail;
  final DailyVitals vitals;
  final String takeaway;

  /// True when the user tapped "Cheat Day" — entry should NOT count toward
  /// discipline score or planAdherence on the backend.
  final bool isCheatDay;

  const ActivityJournalEntry({
    required this.date,
    required this.activity,
    this.netsDetail,
    this.skillWorkDetail,
    this.conditioningDetail,
    this.gymDetail,
    this.matchDetail,
    this.recoveryDetail,
    required this.vitals,
    required this.takeaway,
    this.isCheatDay = false,
  });

  /// Maps to the existing backend journal API shape.
  Map<String, dynamic> toApiJson() {
    final drillIds = <String>[];
    int intensity = 7;
    final notes = StringBuffer();

    switch (activity) {
      case ActivityCategory.nets:
        drillIds.addAll(netsDetail?.drills ?? []);
        intensity = netsDetail?.rating ?? 7;
        if (netsDetail?.whatClicked.isNotEmpty == true) {
          notes.write('Clicked: ${netsDetail!.whatClicked}. ');
        }
        if (netsDetail?.whatNeedsWork.isNotEmpty == true) {
          notes.write('Needs work: ${netsDetail!.whatNeedsWork}.');
        }
      case ActivityCategory.skillWork:
        if (skillWorkDetail?.drillName.isNotEmpty == true) {
          drillIds.add(skillWorkDetail!.drillName);
        }
        intensity = skillWorkDetail?.quality ?? 7;
        notes.write(skillWorkDetail?.observation ?? '');
      case ActivityCategory.gym:
        intensity = gymDetail?.energyLevel ?? 7;
        notes.write(gymDetail?.note ?? '');
      case ActivityCategory.conditioning:
        notes.write(conditioningDetail?.observation ?? '');
      case ActivityCategory.match:
        intensity = matchDetail?.rating ?? 7;
        notes.write(
            'Role: ${matchDetail?.role}. Well: ${matchDetail?.executedWell}. Fix: ${matchDetail?.toFix}.');
      case ActivityCategory.recovery:
        notes.write(
            'Types: ${recoveryDetail?.types.join(', ')}. Body: ${recoveryDetail?.bodyState.label}. ${recoveryDetail?.note}');
    }

    if (takeaway.isNotEmpty) notes.write(' Takeaway: $takeaway');

    return {
      'date': date.toIso8601String(),
      'isCheatDay': isCheatDay,
      'activity': {
        'type': activity.apiType,
        'durationMinutes': 0,
        'intensity': intensity,
        'drillIds': drillIds,
        'notes': notes.toString().trim(),
      },
      'mental': {
        'confidence': intensity,
        'focus': intensity,
        'resilience': intensity,
      },
      'context': {
        'sleepQuality': (vitals.sleepHours / 10 * 10).round().clamp(1, 10),
        'hydrationLiters': vitals.hydrationLiters,
        'soreness': 3,
        'fatigue': 5,
        'mood': intensity,
        'stress': 5,
      },
    };
  }
}

// ── My Plan Models ────────────────────────────────────────────────────────────

class PlannedActivity {
  final ActivityCategory category;
  final int timesPerWeek; // 1–7
  final List<int> days; // 1=Mon ... 7=Sun

  const PlannedActivity({
    required this.category,
    required this.timesPerWeek,
    this.days = const [],
  });

  factory PlannedActivity.fromJson(Map<String, dynamic> json) {
    final cat = (json['category'] as String?) ?? '';
    final category = ActivityCategory.values.firstWhere(
      (c) => c.apiType == cat,
      orElse: () => ActivityCategory.nets,
    );
    return PlannedActivity(
      category: category,
      timesPerWeek: _toInt(json['timesPerWeek']),
      days: _asList(json['days'])
          .map((e) => _toInt(e))
          .where((d) => d >= 1 && d <= 7)
          .toList(growable: false),
    );
  }

  Map<String, dynamic> toJson() => {
        'category': category.apiType,
        'timesPerWeek': timesPerWeek,
        if (days.isNotEmpty) 'days': days,
      };

  PlannedActivity copyWith({int? timesPerWeek, List<int>? days}) {
    return PlannedActivity(
      category: category,
      timesPerWeek: timesPerWeek ?? this.timesPerWeek,
      days: days ?? this.days,
    );
  }
}

class MyPlan {
  final String name;
  final List<PlannedActivity> activities;
  final double sleepTargetHours;
  final double hydrationTargetLiters;

  const MyPlan({
    required this.name,
    required this.activities,
    this.sleepTargetHours = 8.0,
    this.hydrationTargetLiters = 3.0,
  });

  factory MyPlan.empty() => const MyPlan(
        name: 'My Training Plan',
        activities: [],
      );

  factory MyPlan.fromJson(Map<String, dynamic> json) {
    final body = (json['data'] is Map)
        ? Map<String, dynamic>.from(json['data'] as Map)
        : json;
    return MyPlan(
      name: body['name'] ?? 'My Training Plan',
      activities: _asList(body['activities'])
          .map((e) => PlannedActivity.fromJson(_asMap(e)))
          .toList(),
      sleepTargetHours: _toDouble(body['sleepTargetHours'] ?? 8),
      hydrationTargetLiters: _toDouble(body['hydrationTargetLiters'] ?? 3),
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'activities': activities.map((a) => a.toJson()).toList(),
        'sleepTargetHours': sleepTargetHours,
        'hydrationTargetLiters': hydrationTargetLiters,
      };

  MyPlan copyWith({
    String? name,
    List<PlannedActivity>? activities,
    double? sleepTargetHours,
    double? hydrationTargetLiters,
  }) {
    return MyPlan(
      name: name ?? this.name,
      activities: activities ?? this.activities,
      sleepTargetHours: sleepTargetHours ?? this.sleepTargetHours,
      hydrationTargetLiters:
          hydrationTargetLiters ?? this.hydrationTargetLiters,
    );
  }
}

// ── Weekly Plan Models ───────────────────────────────────────────────────────

const kDayKeys = [
  'MONDAY',
  'TUESDAY',
  'WEDNESDAY',
  'THURSDAY',
  'FRIDAY',
  'SATURDAY',
  'SUNDAY',
];

const kDayLabels = [
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
  'Sunday',
];

const kWeeklyPlanWeekdays = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];

const kWeeklyPlanWeekdayLabels = [
  'Mon',
  'Tue',
  'Wed',
  'Thu',
  'Fri',
  'Sat',
  'Sun',
];

class WeeklyTemplateDay {
  final int netsMinutes;
  final int drillsMinutes;
  final int gymMinutes;
  final int recoveryMinutes;
  final double sleepHours;

  const WeeklyTemplateDay({
    this.netsMinutes = 0,
    this.drillsMinutes = 0,
    this.gymMinutes = 0,
    this.recoveryMinutes = 0,
    this.sleepHours = 8.0,
  });

  factory WeeklyTemplateDay.fromJson(Map<String, dynamic> json) {
    return WeeklyTemplateDay(
      netsMinutes: _toInt(json['netsMinutes']),
      drillsMinutes: _toInt(json['drillsMinutes']),
      gymMinutes: _toInt(json['gymMinutes']),
      recoveryMinutes: _toInt(json['recoveryMinutes']),
      sleepHours: _toDouble(json['sleepHours'] ?? 8),
    );
  }

  Map<String, dynamic> toJson() => {
        'netsMinutes': netsMinutes,
        'drillsMinutes': drillsMinutes,
        'gymMinutes': gymMinutes,
        'recoveryMinutes': recoveryMinutes,
        'sleepHours': sleepHours,
      };

  WeeklyTemplateDay copyWith({
    int? netsMinutes,
    int? drillsMinutes,
    int? gymMinutes,
    int? recoveryMinutes,
    double? sleepHours,
  }) {
    return WeeklyTemplateDay(
      netsMinutes: netsMinutes ?? this.netsMinutes,
      drillsMinutes: drillsMinutes ?? this.drillsMinutes,
      gymMinutes: gymMinutes ?? this.gymMinutes,
      recoveryMinutes: recoveryMinutes ?? this.recoveryMinutes,
      sleepHours: sleepHours ?? this.sleepHours,
    );
  }
}

class WeeklyPlanDay {
  final String weekday; // MON..SUN
  final int netsMinutes;
  final int drillsMinutes;
  final int fitnessMinutes;
  final int recoveryMinutes;
  final double sleepTargetHours;
  final double hydrationTargetLiters;
  // Boolean activity flags (backend may return hasX=true with 0 minutes)
  final bool hasNets;
  final bool hasSkillWork;
  final bool hasGym;
  final bool hasConditioning;
  final bool hasMatch;
  final bool hasRecovery;
  final bool hasProperDiet;

  const WeeklyPlanDay({
    this.weekday = '',
    this.netsMinutes = 0,
    this.drillsMinutes = 0,
    this.fitnessMinutes = 0,
    this.recoveryMinutes = 0,
    this.sleepTargetHours = 8.0,
    this.hydrationTargetLiters = 4.0,
    this.hasNets = false,
    this.hasSkillWork = false,
    this.hasGym = false,
    this.hasConditioning = false,
    this.hasMatch = false,
    this.hasRecovery = false,
    this.hasProperDiet = false,
  });

  int get gymMinutes => fitnessMinutes;
  double get sleepHours => sleepTargetHours;

  /// Whether a given activity key is active (boolean flag OR minutes > 0).
  bool isActive(String key) {
    switch (key) {
      case 'NETS':     return hasNets || netsMinutes > 0;
      case 'DRILLS':   return hasSkillWork || drillsMinutes > 0;
      case 'GYM':      return hasGym || fitnessMinutes > 0;
      case 'CONDITIONING': return hasConditioning || fitnessMinutes > 0;
      case 'MATCH': return hasMatch || drillsMinutes > 0;
      case 'RECOVERY': return hasRecovery || recoveryMinutes > 0;
    }
    return false;
  }

  factory WeeklyPlanDay.fromJson(Map<String, dynamic> json) {
    final rawWeekday = '${json['weekday'] ?? json['day'] ?? ''}'.trim();
    return WeeklyPlanDay(
      weekday: rawWeekday.toUpperCase(),
      netsMinutes: _toInt(json['netsMinutes']),
      drillsMinutes: _toInt(json['drillsMinutes']),
      fitnessMinutes: _toInt(json['fitnessMinutes'] ?? json['gymMinutes']),
      recoveryMinutes: _toInt(json['recoveryMinutes']),
      sleepTargetHours:
          _toDouble(json['sleepTargetHours'] ?? json['sleepHours'] ?? 8),
      hydrationTargetLiters: _toDouble(
          json['hydrationTargetLiters'] ?? json['hydrationLiters'] ?? 4),
      hasNets:      json['hasNets'] as bool? ?? false,
      hasSkillWork: json['hasSkillWork'] as bool? ?? false,
      hasGym:       json['hasGym'] as bool? ?? false,
      hasConditioning: json['hasConditioning'] as bool? ?? false,
      hasMatch: json['hasMatch'] as bool? ?? false,
      hasRecovery:  json['hasRecovery'] as bool? ?? false,
      hasProperDiet: json['hasProperDiet'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'weekday': weekday,
        'netsMinutes': netsMinutes,
        'drillsMinutes': drillsMinutes,
        'fitnessMinutes': fitnessMinutes,
        'recoveryMinutes': recoveryMinutes,
        'sleepTargetHours': sleepTargetHours,
        'hydrationTargetLiters': hydrationTargetLiters,
        'hasNets': hasNets || netsMinutes > 0,
        'hasSkillWork': hasSkillWork || drillsMinutes > 0,
        'hasGym': hasGym || fitnessMinutes > 0,
        'hasConditioning': hasConditioning || fitnessMinutes > 0,
        'hasMatch': hasMatch || drillsMinutes > 0,
        'hasRecovery': hasRecovery || recoveryMinutes > 0,
        'hasProperDiet': hasProperDiet,
      };

  WeeklyPlanDay copyWith({
    String? weekday,
    int? netsMinutes,
    int? drillsMinutes,
    int? fitnessMinutes,
    int? recoveryMinutes,
    double? sleepTargetHours,
    double? hydrationTargetLiters,
    bool? hasNets,
    bool? hasSkillWork,
    bool? hasGym,
    bool? hasConditioning,
    bool? hasMatch,
    bool? hasRecovery,
    bool? hasProperDiet,
  }) {
    return WeeklyPlanDay(
      weekday: weekday ?? this.weekday,
      netsMinutes: netsMinutes ?? this.netsMinutes,
      drillsMinutes: drillsMinutes ?? this.drillsMinutes,
      fitnessMinutes: fitnessMinutes ?? this.fitnessMinutes,
      recoveryMinutes: recoveryMinutes ?? this.recoveryMinutes,
      sleepTargetHours: sleepTargetHours ?? this.sleepTargetHours,
      hydrationTargetLiters:
          hydrationTargetLiters ?? this.hydrationTargetLiters,
      hasNets: hasNets ?? this.hasNets,
      hasSkillWork: hasSkillWork ?? this.hasSkillWork,
      hasGym: hasGym ?? this.hasGym,
      hasConditioning: hasConditioning ?? this.hasConditioning,
      hasMatch: hasMatch ?? this.hasMatch,
      hasRecovery: hasRecovery ?? this.hasRecovery,
      hasProperDiet: hasProperDiet ?? this.hasProperDiet,
    );
  }

  /// Total planned training load (nets + drills + fitness + recovery) in minutes.
  int get totalTrainingMinutes =>
      netsMinutes + drillsMinutes + fitnessMinutes + recoveryMinutes;

  /// True if this day has any scheduled training activity.
  bool get hasAnyTraining =>
      hasNets || hasSkillWork || hasGym || hasConditioning || hasMatch ||
      netsMinutes > 0 || drillsMinutes > 0 || fitnessMinutes > 0;
}

class WeeklyPlan {
  final String? id;
  final String name;
  final bool isActive;
  final bool isAlignedWithAmbition;
  final DateTime? lastSyncedAt;

  /// Ordered list as provided by backend (typically Mon→Sun).
  final List<WeeklyPlanDay> days;

  const WeeklyPlan({
    this.id,
    required this.name,
    required this.isActive,
    this.isAlignedWithAmbition = true,
    this.lastSyncedAt,
    required this.days,
  });

  factory WeeklyPlan.empty() {
    return WeeklyPlan(
      name: 'My Weekly Plan',
      isActive: true,
      isAlignedWithAmbition: true,
      days: List.generate(
        kWeeklyPlanWeekdays.length,
        (i) => WeeklyPlanDay(weekday: kWeeklyPlanWeekdays[i]),
      ),
    );
  }

  factory WeeklyPlan.fromJson(Map<String, dynamic> json) {
    final data = _asMap(json['data']);
    
    // Try different paths for the plan object
    Map<String, dynamic> plan;
    if (_asMap(data['plan']).isNotEmpty) {
      plan = _asMap(data['plan']);
    } else if (_asMap(json['plan']).isNotEmpty) {
      plan = _asMap(json['plan']);
    } else if (data.containsKey('days')) {
      plan = data;
    } else if (json.containsKey('days')) {
      plan = json;
    } else {
      plan = <String, dynamic>{};
    }

    final rawDays = _asList(plan['days']);
    final parsedDays = <WeeklyPlanDay>[];
    for (var i = 0; i < rawDays.length; i++) {
      final entry = WeeklyPlanDay.fromJson(_asMap(rawDays[i]));
      if (entry.weekday.trim().isNotEmpty) {
        parsedDays.add(entry);
      } else {
        final fallback =
            i < kWeeklyPlanWeekdays.length ? kWeeklyPlanWeekdays[i] : '';
        parsedDays.add(entry.copyWith(weekday: fallback));
      }
    }

    final rawId = '${plan['id'] ?? ''}'.trim();
    final rawName = '${plan['name'] ?? ''}'.trim();
    final syncStr = plan['lastSyncedAt'] ?? plan['updatedAt'] ?? data['updatedAt'];

    return WeeklyPlan(
      id: rawId.isEmpty ? null : rawId,
      name: rawName.isEmpty ? 'My Weekly Plan' : rawName,
      isActive: _toBool(plan['isActive'] ?? true),
      isAlignedWithAmbition: _toBool(plan['isAlignedWithAmbition'] ?? true),
      lastSyncedAt: syncStr != null ? DateTime.tryParse(syncStr.toString()) : null,
      days: parsedDays.isEmpty ? WeeklyPlan.empty().days : parsedDays,
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null && id!.trim().isNotEmpty) 'id': id,
        'name': name,
        'isActive': isActive,
        'isAlignedWithAmbition': isAlignedWithAmbition,
        if (lastSyncedAt != null) 'lastSyncedAt': lastSyncedAt!.toIso8601String(),
        'days': days.map((d) => d.toJson()).toList(growable: false),
      };

  WeeklyPlan copyWith({
    String? id,
    String? name,
    bool? isActive,
    bool? isAlignedWithAmbition,
    DateTime? lastSyncedAt,
    List<WeeklyPlanDay>? days,
  }) {
    return WeeklyPlan(
      id: id ?? this.id,
      name: name ?? this.name,
      isActive: isActive ?? this.isActive,
      isAlignedWithAmbition:
          isAlignedWithAmbition ?? this.isAlignedWithAmbition,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      days: days ?? this.days,
    );
  }
}

// ── Plan → Execution Models ──────────────────────────────────────────────────

class WeeklyPlanTemplate {
  final String name;

  /// 7 entries ordered Monday→Sunday.
  final List<WeeklyTemplateDay> days;

  const WeeklyPlanTemplate({
    required this.name,
    required this.days,
  });

  factory WeeklyPlanTemplate.empty() {
    return WeeklyPlanTemplate(
      name: 'My Training Week',
      days: List.generate(7, (_) => const WeeklyTemplateDay()),
    );
  }

  factory WeeklyPlanTemplate.fromJson(Map<String, dynamic> json) {
    final rawDays = _asMap(json['days']);
    final days = kDayKeys.map((key) {
      final d = rawDays[key];
      return d != null
          ? WeeklyTemplateDay.fromJson(_asMap(d))
          : const WeeklyTemplateDay();
    }).toList();
    return WeeklyPlanTemplate(
      name: json['name'] ?? 'My Training Week',
      days: days,
    );
  }

  Map<String, dynamic> toJson() {
    final daysMap = <String, dynamic>{};
    for (var i = 0; i < 7; i++) {
      daysMap[kDayKeys[i]] = days[i].toJson();
    }
    return {'name': name, 'days': daysMap};
  }

  WeeklyPlanTemplate copyWith({String? name, List<WeeklyTemplateDay>? days}) {
    return WeeklyPlanTemplate(
      name: name ?? this.name,
      days: days ?? this.days,
    );
  }
}

class ApexDayPlan {
  final int netsMinutes;
  final int drillsMinutes;
  final int fitnessMinutes;
  final int recoveryMinutes;
  final double sleepTargetHours;
  final double hydrationTargetLiters;

  const ApexDayPlan({
    this.netsMinutes = 0,
    this.drillsMinutes = 0,
    this.fitnessMinutes = 0,
    this.recoveryMinutes = 0,
    this.sleepTargetHours = 8.0,
    this.hydrationTargetLiters = 4.0,
  });

  bool get hasAnyTarget =>
      netsMinutes > 0 ||
      drillsMinutes > 0 ||
      fitnessMinutes > 0 ||
      recoveryMinutes > 0;

  factory ApexDayPlan.fromJson(Map<String, dynamic> json) {
    return ApexDayPlan(
      netsMinutes: _toInt(json['netsMinutes'] ?? json['targetNetsMinutes']),
      drillsMinutes:
          _toInt(json['drillsMinutes'] ?? json['targetDrillsMinutes']),
      fitnessMinutes: _toInt(json['fitnessMinutes'] ??
          json['gymMinutes'] ??
          json['targetGymMinutes']),
      recoveryMinutes:
          _toInt(json['recoveryMinutes'] ?? json['targetRecoveryMinutes']),
      sleepTargetHours: _toDouble(json['sleepTargetHours'] ??
          json['sleepHours'] ??
          json['targetSleepHours'] ??
          8),
      hydrationTargetLiters: _toDouble(
          json['hydrationTargetLiters'] ?? json['hydrationLiters'] ?? 4),
    );
  }

  Map<String, dynamic> toJson() => {
        'netsMinutes': netsMinutes,
        'drillsMinutes': drillsMinutes,
        'fitnessMinutes': fitnessMinutes,
        'recoveryMinutes': recoveryMinutes,
        'sleepTargetHours': sleepTargetHours,
        'hydrationTargetLiters': hydrationTargetLiters,
      };
}

class ApexDayExecution {
  final int actualNetsMinutes;
  final int actualDrillsMinutes;
  final int actualFitnessMinutes;
  final int actualRecoveryMinutes;
  final double? actualSleepHours;
  final double? actualHydrationLiters;
  final int actualCalories;
  final String? whatDidWell;
  final String? whatDidBadly;
  final String? note;

  const ApexDayExecution({
    this.actualNetsMinutes = 0,
    this.actualDrillsMinutes = 0,
    this.actualFitnessMinutes = 0,
    this.actualRecoveryMinutes = 0,
    this.actualSleepHours,
    this.actualHydrationLiters,
    this.actualCalories = 0,
    this.whatDidWell,
    this.whatDidBadly,
    this.note,
  });

  factory ApexDayExecution.fromJson(Map<String, dynamic> json) {
    return ApexDayExecution(
      actualNetsMinutes: _toInt(json['actualNetsMinutes']),
      actualDrillsMinutes: _toInt(json['actualDrillsMinutes']),
      actualFitnessMinutes:
          _toInt(json['actualFitnessMinutes'] ?? json['actualGymMinutes']),
      actualRecoveryMinutes: _toInt(json['actualRecoveryMinutes']),
      actualSleepHours: json['actualSleepHours'] == null
          ? null
          : _toDouble(json['actualSleepHours']),
      actualHydrationLiters: json['actualHydrationLiters'] == null
          ? null
          : _toDouble(json['actualHydrationLiters']),
      actualCalories: _toInt(json['actualCalories'] ?? json['caloriesConsumed']),
      whatDidWell:
          json['whatDidWell'] == null ? null : '${json['whatDidWell']}',
      whatDidBadly:
          json['whatDidBadly'] == null ? null : '${json['whatDidBadly']}',
      note: json['note'] == null ? null : '${json['note']}',
    );
  }
}

class ApexDayLog {
  final String id;
  final String date; // YYYY-MM-DD
  final String weekday; // MON/TUE...
  final bool isLocked;
  final String? oneThingToday;
  final ApexDayPlan plan;
  final ApexDayExecution execution;
  final double? executionScore;

  const ApexDayLog({
    this.id = '',
    required this.date,
    this.weekday = '',
    required this.isLocked,
    this.oneThingToday,
    required this.plan,
    required this.execution,
    this.executionScore,
  });

  factory ApexDayLog.fromJson(Map<String, dynamic> json) {
    final data = _asMap(json['data'] ?? json);
    final dayLog = _asMap(data['dayLog']);
    final body = dayLog.isNotEmpty ? dayLog : data;
    return ApexDayLog(
      id: '${body['id'] ?? ''}',
      date: '${body['date'] ?? ''}',
      weekday: '${body['weekday'] ?? ''}'.toUpperCase(),
      isLocked: _toBool(body['isLocked']),
      oneThingToday:
          body['oneThingToday'] == null ? null : '${body['oneThingToday']}',
      plan: ApexDayPlan.fromJson(
          _asMap(body['plan']).isNotEmpty ? _asMap(body['plan']) : body),
      execution: ApexDayExecution.fromJson(_asMap(body['execution']).isNotEmpty
          ? _asMap(body['execution'])
          : body),
      executionScore: body['executionScore'] == null
          ? null
          : _toDouble(body['executionScore']),
    );
  }
}

class ApexDayPlanPatch {
  final String? oneThingToday;
  final ApexDayPlan? plan;
  final bool? cheatDay;

  const ApexDayPlanPatch({
    this.oneThingToday,
    this.plan,
    this.cheatDay,
  });

  Map<String, dynamic> toJson() {
    final out = <String, dynamic>{};
    if (oneThingToday != null) out['oneThingToday'] = oneThingToday;
    if (cheatDay != null) out['cheatDay'] = cheatDay;
    if (plan != null) {
      out['plan'] = plan!.toJson();
      out['netsMinutes'] = plan!.netsMinutes;
      out['drillsMinutes'] = plan!.drillsMinutes;
      out['fitnessMinutes'] = plan!.fitnessMinutes;
      out['recoveryMinutes'] = plan!.recoveryMinutes;
      out['sleepTargetHours'] = plan!.sleepTargetHours;
      out['hydrationTargetLiters'] = plan!.hydrationTargetLiters;
    }
    return out;
  }
}

class ApexDayExecutionSubmit {
  final int actualNetsMinutes;
  final int actualDrillsMinutes;
  final int actualFitnessMinutes;
  final int actualRecoveryMinutes;
  final double actualSleepHours;
  final double actualHydrationLiters;
  final String? whatDidWell;
  final String? whatDidBadly;
  final String? note;

  const ApexDayExecutionSubmit({
    required this.actualNetsMinutes,
    required this.actualDrillsMinutes,
    required this.actualFitnessMinutes,
    required this.actualRecoveryMinutes,
    required this.actualSleepHours,
    required this.actualHydrationLiters,
    this.whatDidWell,
    this.whatDidBadly,
    this.note,
  });

  Map<String, dynamic> toJson() => {
        'actualNetsMinutes': actualNetsMinutes,
        'actualDrillsMinutes': actualDrillsMinutes,
        'actualFitnessMinutes': actualFitnessMinutes,
        'actualRecoveryMinutes': actualRecoveryMinutes,
        'actualSleepHours': actualSleepHours,
        'actualHydrationLiters': actualHydrationLiters,
        if (whatDidWell != null) 'whatDidWell': whatDidWell,
        if (whatDidBadly != null) 'whatDidBadly': whatDidBadly,
        if (note != null) 'note': note,
      };
}

class DayLog {
  final String date; // YYYY-MM-DD
  final bool isLocked;
  final String? oneThingToday;
  final int targetNetsMinutes;
  final int targetDrillsMinutes;
  final int targetGymMinutes;
  final int targetRecoveryMinutes;
  final double targetSleepHours;
  final int? actualNetsMinutes;
  final int? actualDrillsMinutes;
  final int? actualGymMinutes;
  final int? actualRecoveryMinutes;
  final double? actualSleepHours;
  final double? executionScore;

  const DayLog({
    required this.date,
    required this.isLocked,
    this.oneThingToday,
    this.targetNetsMinutes = 0,
    this.targetDrillsMinutes = 0,
    this.targetGymMinutes = 0,
    this.targetRecoveryMinutes = 0,
    this.targetSleepHours = 8.0,
    this.actualNetsMinutes,
    this.actualDrillsMinutes,
    this.actualGymMinutes,
    this.actualRecoveryMinutes,
    this.actualSleepHours,
    this.executionScore,
  });

  bool get hasPlan => oneThingToday != null && oneThingToday!.isNotEmpty;
  bool get hasExecution => executionScore != null;

  factory DayLog.fromJson(Map<String, dynamic> json) {
    final body = (json['data'] is Map)
        ? Map<String, dynamic>.from(json['data'] as Map)
        : json;
    return DayLog(
      date: body['date'] ?? '',
      isLocked: body['isLocked'] == true,
      oneThingToday: body['oneThingToday'] as String?,
      targetNetsMinutes: _toInt(body['targetNetsMinutes']),
      targetDrillsMinutes: _toInt(body['targetDrillsMinutes']),
      targetGymMinutes: _toInt(body['targetGymMinutes']),
      targetRecoveryMinutes: _toInt(body['targetRecoveryMinutes']),
      targetSleepHours: _toDouble(body['targetSleepHours'] ?? 8),
      actualNetsMinutes: body['actualNetsMinutes'] == null
          ? null
          : _toInt(body['actualNetsMinutes']),
      actualDrillsMinutes: body['actualDrillsMinutes'] == null
          ? null
          : _toInt(body['actualDrillsMinutes']),
      actualGymMinutes: body['actualGymMinutes'] == null
          ? null
          : _toInt(body['actualGymMinutes']),
      actualRecoveryMinutes: body['actualRecoveryMinutes'] == null
          ? null
          : _toInt(body['actualRecoveryMinutes']),
      actualSleepHours: body['actualSleepHours'] == null
          ? null
          : _toDouble(body['actualSleepHours']),
      executionScore: body['executionScore'] == null
          ? null
          : _toDouble(body['executionScore']),
    );
  }
}

class DayPlanUpdate {
  final String oneThingToday;
  final int targetNetsMinutes;
  final int targetDrillsMinutes;
  final int targetGymMinutes;
  final int targetRecoveryMinutes;
  final double targetSleepHours;

  const DayPlanUpdate({
    required this.oneThingToday,
    required this.targetNetsMinutes,
    required this.targetDrillsMinutes,
    required this.targetGymMinutes,
    required this.targetRecoveryMinutes,
    required this.targetSleepHours,
  });

  Map<String, dynamic> toJson() => {
        'oneThingToday': oneThingToday,
        'targetNetsMinutes': targetNetsMinutes,
        'targetDrillsMinutes': targetDrillsMinutes,
        'targetGymMinutes': targetGymMinutes,
        'targetRecoveryMinutes': targetRecoveryMinutes,
        'targetSleepHours': targetSleepHours,
      };
}

class ExecutionSubmission {
  final int actualNetsMinutes;
  final int actualDrillsMinutes;
  final int actualGymMinutes;
  final int actualRecoveryMinutes;
  final double actualSleepHours;
  final String? whatDidWell;
  final String? whatDidBadly;

  const ExecutionSubmission({
    required this.actualNetsMinutes,
    required this.actualDrillsMinutes,
    required this.actualGymMinutes,
    required this.actualRecoveryMinutes,
    required this.actualSleepHours,
    this.whatDidWell,
    this.whatDidBadly,
  });

  Map<String, dynamic> toJson() => {
        'actualNetsMinutes': actualNetsMinutes,
        'actualDrillsMinutes': actualDrillsMinutes,
        'actualGymMinutes': actualGymMinutes,
        'actualRecoveryMinutes': actualRecoveryMinutes,
        'actualSleepHours': actualSleepHours,
        if (whatDidWell != null) 'whatDidWell': whatDidWell,
        if (whatDidBadly != null) 'whatDidBadly': whatDidBadly,
      };
}

enum ExecutionIntensity { indiscipline, low, medium, high }

class ExecutionStreakEntry {
  final DateTime date;
  final double score; // EE% 0–100

  const ExecutionStreakEntry({required this.date, required this.score});

  ExecutionIntensity get intensity {
    if (score <= 0) return ExecutionIntensity.indiscipline;
    if (score < 40) return ExecutionIntensity.low;
    if (score < 75) return ExecutionIntensity.medium;
    return ExecutionIntensity.high;
  }

  factory ExecutionStreakEntry.fromJson(Map<String, dynamic> json) {
    return ExecutionStreakEntry(
      date: _toDate(json['date']),
      score: _toDouble(json['score']),
    );
  }
}

class JournalConsistency {
  final JournalSummary summary;
  final List<JournalDay> days;
  final JournalWeekly weekly;

  const JournalConsistency({
    required this.summary,
    required this.days,
    required this.weekly,
  });

  factory JournalConsistency.fromJson(Map<String, dynamic> json) {
    final data = _asMap(json['data'] ?? json);
    final dayList = _asList(data['days'])
        .map((e) => JournalDay.fromJson(_asMap(e)))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    return JournalConsistency(
      summary: JournalSummary.fromJson(_asMap(data['summary'])),
      days: dayList,
      weekly: JournalWeekly.fromJson(_asMap(data['weekly'])),
    );
  }
}

class JournalSummary {
  final int currentStreak;
  final int activeDaysInWindow;
  final int plannedDays;
  final int executedDays;
  final double planVsExecutionPct;

  const JournalSummary({
    this.currentStreak = 0,
    this.activeDaysInWindow = 0,
    this.plannedDays = 0,
    this.executedDays = 0,
    this.planVsExecutionPct = 0,
  });

  factory JournalSummary.fromJson(Map<String, dynamic> json) {
    return JournalSummary(
      currentStreak: _toInt(json['currentStreak']),
      activeDaysInWindow: _toInt(json['activeDaysInWindow']),
      plannedDays: _toInt(json['plannedDays']),
      executedDays: _toInt(json['executedDays']),
      planVsExecutionPct: _toDouble(json['planVsExecutionPct']),
    );
  }
}

class JournalWeekly {
  final double disciplineScore;
  final Map<String, JournalAdherence> adherence;

  const JournalWeekly({
    this.disciplineScore = 0,
    this.adherence = const {},
  });

  factory JournalWeekly.fromJson(Map<String, dynamic> json) {
    final out = <String, JournalAdherence>{};
    final raw = _asMap(json['adherence']);
    for (final entry in raw.entries) {
      out[entry.key.toString()] =
          JournalAdherence.fromJson(_asMap(entry.value));
    }
    return JournalWeekly(
      disciplineScore: _toDouble(json['disciplineScore']),
      adherence: out,
    );
  }
}

class JournalAdherence {
  final int planned;
  final int actual;

  const JournalAdherence({
    this.planned = 0,
    this.actual = 0,
  });

  double get completionPct => planned <= 0 ? 0 : (actual / planned) * 100;

  factory JournalAdherence.fromJson(Map<String, dynamic> json) {
    return JournalAdherence(
      planned: _toInt(json['planned']),
      actual: _toInt(json['actual']),
    );
  }
}

class JournalDay {
  final DateTime date;
  final bool isActive;
  final bool isLocked;
  final int streakCount;
  final int plannedActivityCount;
  final int actualActivityCount;
  final int plannedMinutes;
  final int actualMinutes;
  final int plannedTargets;
  final int actualTargets;
  final bool isPlannedDay;
  final bool isExecutedDay;
  final bool hasWorkload;
  final bool hasWellness;
  final double executionScore;

  const JournalDay({
    required this.date,
    this.isActive = false,
    this.isLocked = false,
    this.streakCount = 0,
    this.plannedActivityCount = 0,
    this.actualActivityCount = 0,
    this.plannedMinutes = 0,
    this.actualMinutes = 0,
    this.plannedTargets = 0,
    this.actualTargets = 0,
    this.isPlannedDay = false,
    this.isExecutedDay = false,
    this.hasWorkload = false,
    this.hasWellness = false,
    this.executionScore = 0,
  });

  factory JournalDay.fromJson(Map<String, dynamic> json) {
    final plan = _asMap(json['plan']);
    final execution = _asMap(json['execution']);
    final badges =
        _asList(json['badges']).map((e) => '$e'.toUpperCase()).toSet();

    int positiveCount(List<int> values) => values.where((v) => v > 0).length;

    final plannedActivityCount = _toInt(
      json['plannedActivityCount'] ??
          plan['plannedActivityCount'] ??
          plan['activityCount'],
    );
    final actualActivityCount = _toInt(
      json['actualActivityCount'] ??
          execution['actualActivityCount'] ??
          execution['activityCount'],
    );

    final derivedPlannedActivityCount = positiveCount([
      _toInt(plan['netsMinutes'] ?? plan['targetNetsMinutes']),
      _toInt(plan['drillsMinutes'] ?? plan['targetDrillsMinutes']),
      _toInt(plan['fitnessMinutes'] ??
          plan['gymMinutes'] ??
          plan['targetGymMinutes']),
      _toInt(plan['recoveryMinutes'] ?? plan['targetRecoveryMinutes']),
    ]);

    final derivedActualActivityCount = positiveCount([
      _toInt(execution['actualNetsMinutes']),
      _toInt(execution['actualDrillsMinutes']),
      _toInt(
          execution['actualFitnessMinutes'] ?? execution['actualGymMinutes']),
      _toInt(execution['actualRecoveryMinutes']),
    ]);

    final plannedMinutes = _toInt(
      json['plannedMinutes'] ??
          plan['plannedMinutes'] ??
          plan['totalMinutes'] ??
          plan['minutes'],
    );
    final actualMinutes = _toInt(
      json['actualMinutes'] ??
          execution['actualMinutes'] ??
          execution['totalMinutes'] ??
          execution['minutes'],
    );
    final plannedTargets = _toInt(
      json['plannedTargets'] ?? plan['targetCount'] ?? plan['plannedTargets'],
    );
    final actualTargets = _toInt(
      json['actualTargets'] ??
          execution['targetCount'] ??
          execution['actualTargets'],
    );

    final executionScore = _toDouble(
      json['executionScore'] ??
          execution['executionScore'] ??
          json['planVsExecutionPct'],
    );

    final isPlannedDay = _toBool(
      json['isPlannedDay'] ??
          plan['isPlannedDay'] ??
          (plannedMinutes > 0 || plannedTargets > 0),
    );
    final isExecutedDay = _toBool(
      json['isExecutedDay'] ??
          execution['isExecutedDay'] ??
          (actualMinutes > 0 || actualTargets > 0),
    );

    final hasWorkload = _toBool(
          json['hasWorkload'] ??
              json['workloadLogged'] ??
              plan['hasWorkload'] ??
              execution['hasWorkload'],
        ) ||
        badges.contains('WORKLOAD');
    final hasWellness = _toBool(
          json['hasWellness'] ??
              json['wellnessLogged'] ??
              plan['hasWellness'] ??
              execution['hasWellness'],
        ) ||
        badges.contains('WELLNESS');

    return JournalDay(
      date: _toDate(json['date'] ?? json['day'] ?? json['dayDate']),
      isActive: _toBool(json['isActive'] ?? json['active']),
      isLocked: _toBool(json['isLocked'] ?? json['locked']),
      streakCount: _toInt(json['streakCount'] ?? json['streak']),
      plannedActivityCount: plannedActivityCount > 0
          ? plannedActivityCount
          : derivedPlannedActivityCount,
      actualActivityCount: actualActivityCount > 0
          ? actualActivityCount
          : derivedActualActivityCount,
      plannedMinutes: plannedMinutes,
      actualMinutes: actualMinutes,
      plannedTargets: plannedTargets,
      actualTargets: actualTargets,
      isPlannedDay: isPlannedDay,
      isExecutedDay: isExecutedDay,
      hasWorkload: hasWorkload,
      hasWellness: hasWellness,
      executionScore: executionScore,
    );
  }
}

// ── Apex State (Consolidated) ───────────────────────────────────────────────

class ApexState {
  final ApexStateGoal goal;
  final ApexStateToday today;
  final ApexStateWeeklyPlan weeklyPlan;
  final ApexStateConsistency consistency;

  const ApexState({
    required this.goal,
    required this.today,
    required this.weeklyPlan,
    required this.consistency,
  });

  factory ApexState.fromJson(Map<String, dynamic> json) {
    final data = _asMap(json['data'] ?? json);
    return ApexState(
      goal: ApexStateGoal.fromJson(_asMap(data['ambition'] ?? data['goal'])),
      today: ApexStateToday.fromJson(_asMap(data['today'])),
      weeklyPlan: ApexStateWeeklyPlan.fromJson(_asMap(data['weeklyPlan'])),
      consistency: ApexStateConsistency.fromJson(_asMap(data['consistency'])),
    );
  }
}

class ApexStateGoal {
  final String? targetRole;
  final String? targetFormat;
  final String? styleIdentity;
  final String? targetLevel;
  final String? timeline;
  final List<String> focusAreas;
  final String? commitmentStatement;

  // Physical blueprint
  final String? gender;
  final double? heightCm;
  final double? weightKg;
  final double? targetWeight;
  final String? bodyTransformDirection;
  final double? targetBodyFatPercent;
  final double? waistCm;
  final double? neckCm;
  final double? hipCm;
  final int? trainingDaysPerWeek;
  final List<String> fitnessFocuses;
  final String? nutritionObjective;
  final double? dailySleepHoursGoal;
  final double? dailyHydrationLitresGoal;
  final String? morningWakeUpTime;
  final List<String> habitsToQuit;
  final List<String> disciplineGoals;

  final double? bmi;
  final double? bodyFatPercent;
  final int? dailyCalorieTarget;

  const ApexStateGoal({
    this.targetRole,
    this.targetFormat,
    this.styleIdentity,
    this.targetLevel,
    this.timeline,
    this.focusAreas = const [],
    this.commitmentStatement,
    this.gender,
    this.heightCm,
    this.weightKg,
    this.targetWeight,
    this.bodyTransformDirection,
    this.targetBodyFatPercent,
    this.waistCm,
    this.neckCm,
    this.hipCm,
    this.trainingDaysPerWeek,
    this.fitnessFocuses = const [],
    this.nutritionObjective,
    this.dailySleepHoursGoal,
    this.dailyHydrationLitresGoal,
    this.morningWakeUpTime,
    this.habitsToQuit = const [],
    this.disciplineGoals = const [],
    this.bmi,
    this.bodyFatPercent,
    this.dailyCalorieTarget,
  });

  factory ApexStateGoal.fromJson(Map<String, dynamic> json) {
    return ApexStateGoal(
      targetRole: json['targetRole'] as String?,
      targetFormat: json['targetFormat'] as String?,
      styleIdentity: json['styleIdentity'] as String?,
      targetLevel: json['targetLevel'] as String?,
      timeline: json['timeline'] as String?,
      focusAreas: _asList(json['focusAreas']).map((e) => e.toString()).toList(),
      commitmentStatement: json['commitmentStatement'] as String?,
      gender: json['gender'] as String?,
      heightCm: _toDouble(json['heightCm'] ?? json['height']),
      weightKg: _toDouble(json['weightKg'] ?? json['weight']),
      targetWeight: _toDouble(json['targetWeight']),
      bodyTransformDirection: json['bodyTransformDirection'] as String?,
      targetBodyFatPercent: _toDouble(json['targetBodyFatPercent']),
      waistCm: _toDouble(json['waistCm'] ?? json['waistCircumferenceCm']),
      neckCm: _toDouble(json['neckCm'] ?? json['neckCircumferenceCm']),
      hipCm: _toDouble(json['hipCm'] ?? json['hipCircumferenceCm']),
      trainingDaysPerWeek: _toInt(json['trainingDaysPerWeek']),
      fitnessFocuses: _asList(json['fitnessFocuses']).map((e) => e.toString()).toList(),
      nutritionObjective: json['nutritionObjective'] as String?,
      dailySleepHoursGoal: _toDouble(json['dailySleepHoursGoal']),
      dailyHydrationLitresGoal: _toDouble(json['dailyHydrationLitresGoal']),
      morningWakeUpTime: json['morningWakeUpTime'] as String?,
      habitsToQuit: _asList(json['habitsToQuit']).map((e) => e.toString()).toList(),
      disciplineGoals: _asList(json['disciplineGoals']).map((e) => e.toString()).toList(),
      bmi: _toDouble(json['bmi']),
      bodyFatPercent: _toDouble(json['bodyFatPercent']),
      dailyCalorieTarget: _toInt(json['dailyCalorieTarget']),
    );
  }
}

class ApexStateToday {
  final String date;
  final bool isLocked;
  final ApexStateTodayPlan plan;
  final ApexStateTodayExecution execution;

  const ApexStateToday({
    required this.date,
    required this.isLocked,
    required this.plan,
    required this.execution,
  });

  factory ApexStateToday.fromJson(Map<String, dynamic> json) {
    return ApexStateToday(
      date: json['date'] ?? '',
      isLocked: _toBool(json['isLocked']),
      plan: ApexStateTodayPlan.fromJson(_asMap(json['plan'])),
      execution: ApexStateTodayExecution.fromJson(_asMap(json['execution'])),
    );
  }
}

class ApexStateTodayPlan {
  final String? oneThing;
  final int targetCalories;
  final int targetNetsMinutes;
  final int targetGymMinutes;
  final int targetDrillsMinutes;
  final int targetRecoveryMinutes;

  const ApexStateTodayPlan({
    this.oneThing,
    this.targetCalories = 0,
    this.targetNetsMinutes = 0,
    this.targetGymMinutes = 0,
    this.targetDrillsMinutes = 0,
    this.targetRecoveryMinutes = 0,
  });

  factory ApexStateTodayPlan.fromJson(Map<String, dynamic> json) {
    return ApexStateTodayPlan(
      oneThing: json['oneThing'] as String?,
      targetCalories: _toInt(json['targetCalories']),
      targetNetsMinutes: _toInt(json['targetNetsMinutes']),
      targetGymMinutes: _toInt(json['targetGymMinutes']),
      targetDrillsMinutes: _toInt(json['targetDrillsMinutes']),
      targetRecoveryMinutes: _toInt(json['targetRecoveryMinutes']),
    );
  }
}

class ApexStateTodayExecution {
  final int actualCalories;
  final int actualNetsMinutes;
  final int actualGymMinutes;
  final int actualDrillsMinutes;
  final int actualRecoveryMinutes;
  final String status; // NOT_STARTED, ON_TRACK, PARTIAL, MISSED

  const ApexStateTodayExecution({
    this.actualCalories = 0,
    this.actualNetsMinutes = 0,
    this.actualGymMinutes = 0,
    this.actualDrillsMinutes = 0,
    this.actualRecoveryMinutes = 0,
    this.status = 'NOT_STARTED',
  });

  factory ApexStateTodayExecution.fromJson(Map<String, dynamic> json) {
    return ApexStateTodayExecution(
      actualCalories: _toInt(json['actualCalories']),
      actualNetsMinutes: _toInt(json['actualNetsMinutes']),
      actualGymMinutes: _toInt(json['actualGymMinutes']),
      actualDrillsMinutes: _toInt(json['actualDrillsMinutes']),
      actualRecoveryMinutes: _toInt(json['actualRecoveryMinutes']),
      status: json['status'] ?? 'NOT_STARTED',
    );
  }
}

class ApexStateWeeklyPlan {
  final String? name;
  final List<ApexStateWeeklyDay> days;

  const ApexStateWeeklyPlan({
    this.name,
    this.days = const [],
  });

  factory ApexStateWeeklyPlan.fromJson(Map<String, dynamic> json) {
    return ApexStateWeeklyPlan(
      name: json['name'] as String?,
      days: _asList(json['days'])
          .map((e) => ApexStateWeeklyDay.fromJson(_asMap(e)))
          .toList(),
    );
  }
}

class ApexStateWeeklyDay {
  final String day; // MON..SUN
  final int nets;
  final int gym;
  final int recovery;
  final int conditioning;
  final int drills;
  final int match;

  const ApexStateWeeklyDay({
    required this.day,
    this.nets = 0,
    this.gym = 0,
    this.recovery = 0,
    this.conditioning = 0,
    this.drills = 0,
    this.match = 0,
  });

  factory ApexStateWeeklyDay.fromJson(Map<String, dynamic> json) {
    return ApexStateWeeklyDay(
      day: json['day'] ?? '',
      nets: _toInt(json['nets']),
      gym: _toInt(json['gym']),
      recovery: _toInt(json['recovery']),
      conditioning: _toInt(json['conditioning']),
      drills: _toInt(json['drills'] ?? json['skill_work']),
      match: _toInt(json['match']),
    );
  }
}

class ApexStateConsistency {
  final int currentStreak;
  final double adherencePercentage;
  final List<ApexStateHistoryEntry> history;

  const ApexStateConsistency({
    this.currentStreak = 0,
    this.adherencePercentage = 0,
    this.history = const [],
  });

  factory ApexStateConsistency.fromJson(Map<String, dynamic> json) {
    return ApexStateConsistency(
      currentStreak: _toInt(json['currentStreak']),
      adherencePercentage: _toDouble(json['adherencePercentage']),
      history: _asList(json['history'])
          .map((e) => ApexStateHistoryEntry.fromJson(_asMap(e)))
          .toList(),
    );
  }
}

class ApexStateHistoryEntry {
  final String date;
  final double score;
  final String status; // COMPLETED, PARTIAL, MISSED

  const ApexStateHistoryEntry({
    required this.date,
    this.score = 0,
    this.status = 'MISSED',
  });

  factory ApexStateHistoryEntry.fromJson(Map<String, dynamic> json) {
    return ApexStateHistoryEntry(
      date: json['date'] ?? '',
      score: _toDouble(json['score']),
      status: json['status'] ?? 'MISSED',
    );
  }
}
