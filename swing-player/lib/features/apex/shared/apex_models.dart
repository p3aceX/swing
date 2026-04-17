// ─────────────────────────────────────────────────────────────────────────────
//  APEX Models — new models not present in elite_models.dart
//  All models use null-safe fromJson factories.
// ─────────────────────────────────────────────────────────────────────────────

class ExecuteSummaryEntry {
  final String date;
  final String status;      // COMPLETED | PARTIAL | MISSED
  final double completion;  // 0.0 – 1.0
  final String? activityType;
  final String? reflection;

  const ExecuteSummaryEntry({
    required this.date,
    required this.status,
    required this.completion,
    this.activityType,
    this.reflection,
  });

  factory ExecuteSummaryEntry.fromJson(Map<String, dynamic> json) {
    return ExecuteSummaryEntry(
      date: json['date'] as String? ?? '',
      status: (json['status'] as String? ?? 'MISSED').toUpperCase(),
      completion: _toDouble(json['completion'] ?? json['completionPercent']),
      activityType: json['activityType'] as String?,
      reflection: json['reflection'] as String?,
    );
  }
}

class ExecuteSummary {
  final List<ExecuteSummaryEntry> entries;
  final int currentStreak;
  final int bestStreak;
  final double adherencePercent;
  final int trainingSessions;
  final int recoveryDays;
  final int totalCaloriesConsumed;
  final int totalCaloriesRequired;

  const ExecuteSummary({
    required this.entries,
    this.currentStreak = 0,
    this.bestStreak = 0,
    this.adherencePercent = 0,
    this.trainingSessions = 0,
    this.recoveryDays = 0,
    this.totalCaloriesConsumed = 0,
    this.totalCaloriesRequired = 0,
  });

  factory ExecuteSummary.fromJson(Map<String, dynamic> json) {
    final data = _asMap(json['data'] ?? json);
    final rawEntries = _asList(data['entries'] ?? data['history'] ?? data['days']);
    return ExecuteSummary(
      entries: rawEntries
          .map((e) => ExecuteSummaryEntry.fromJson(_asMap(e)))
          .toList(),
      currentStreak: _toInt(data['currentStreak'] ?? data['streak']),
      bestStreak: _toInt(data['bestStreak'] ?? data['longestStreak']),
      adherencePercent: _toDouble(data['adherencePercent'] ?? data['adherence']),
      trainingSessions: _toInt(data['trainingSessions']),
      recoveryDays: _toInt(data['recoveryDays']),
      totalCaloriesConsumed: _toInt(data['totalCaloriesConsumed']),
      totalCaloriesRequired: _toInt(data['totalCaloriesRequired']),
    );
  }
}

class JournalStreak {
  final int currentStreak;
  final int longestStreak;
  final List<JournalEntry> recentEntries;

  const JournalStreak({
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.recentEntries = const [],
  });

  factory JournalStreak.fromJson(Map<String, dynamic> json) {
    final data = _asMap(json['data'] ?? json);
    return JournalStreak(
      currentStreak: _toInt(data['currentStreak'] ?? data['streak']),
      longestStreak: _toInt(data['longestStreak'] ?? data['best']),
      recentEntries: _asList(data['recentEntries'] ?? data['entries'])
          .map((e) => JournalEntry.fromJson(_asMap(e)))
          .toList(),
    );
  }
}

class JournalEntry {
  final String date;
  final String activityType;
  final String preview;
  final bool isComplete;

  const JournalEntry({
    required this.date,
    required this.activityType,
    required this.preview,
    this.isComplete = false,
  });

  factory JournalEntry.fromJson(Map<String, dynamic> json) {
    return JournalEntry(
      date: json['date'] as String? ?? '',
      activityType: json['activityType'] as String? ?? json['type'] as String? ?? 'TRAINING',
      preview: json['preview'] as String? ?? json['notes'] as String? ?? '',
      isComplete: json['isComplete'] as bool? ?? json['complete'] as bool? ?? false,
    );
  }
}

class HealthDashboard {
  final double sleepAvgHours;
  final double sleepGoalHours;
  final double hydrationAvgLitres;
  final double hydrationGoalLitres;
  final double caloriesConsumedToday;
  final double caloriesGoal;
  final List<WeightDataPoint> weightHistory;
  final int trainingDaysThisWeek;
  final int trainingDaysGoal;

  const HealthDashboard({
    this.sleepAvgHours = 0,
    this.sleepGoalHours = 8,
    this.hydrationAvgLitres = 0,
    this.hydrationGoalLitres = 3,
    this.caloriesConsumedToday = 0,
    this.caloriesGoal = 2500,
    this.weightHistory = const [],
    this.trainingDaysThisWeek = 0,
    this.trainingDaysGoal = 5,
  });

  factory HealthDashboard.fromJson(Map<String, dynamic> json) {
    final data = _asMap(json['data'] ?? json);
    return HealthDashboard(
      sleepAvgHours: _toDouble(data['sleepAvgHours'] ?? data['avgSleep']),
      sleepGoalHours: _toDouble(data['sleepGoalHours'] ?? data['sleepGoal'] ?? 8),
      hydrationAvgLitres: _toDouble(data['hydrationAvgLitres'] ?? data['avgHydration']),
      hydrationGoalLitres: _toDouble(data['hydrationGoalLitres'] ?? data['hydrationGoal'] ?? 3),
      caloriesConsumedToday: _toDouble(data['caloriesConsumedToday'] ?? data['caloriesConsumed']),
      caloriesGoal: _toDouble(data['caloriesGoal'] ?? data['calorieTarget'] ?? 2500),
      weightHistory: _asList(data['weightHistory'] ?? data['weight'])
          .map((e) => WeightDataPoint.fromJson(_asMap(e)))
          .toList(),
      trainingDaysThisWeek: _toInt(data['trainingDaysThisWeek'] ?? data['activeDays']),
      trainingDaysGoal: _toInt(data['trainingDaysGoal'] ?? 5),
    );
  }
}

class WeightDataPoint {
  final String date;
  final double weightKg;

  const WeightDataPoint({required this.date, required this.weightKg});

  factory WeightDataPoint.fromJson(Map<String, dynamic> json) {
    return WeightDataPoint(
      date: json['date'] as String? ?? '',
      weightKg: _toDouble(json['weightKg'] ?? json['weight']),
    );
  }
}

class ApexAnalytics {
  final SkillMatrix skillMatrix;
  final PerformanceIndex performanceIndex;
  final List<AnalyticsDeviation> deviations;
  final String? battingWeakness;
  final String? bowlingWeakness;

  const ApexAnalytics({
    required this.skillMatrix,
    required this.performanceIndex,
    this.deviations = const [],
    this.battingWeakness,
    this.bowlingWeakness,
  });

  factory ApexAnalytics.fromJson(Map<String, dynamic> json) {
    final data = _asMap(json['data'] ?? json);
    return ApexAnalytics(
      skillMatrix: SkillMatrix.fromJson(_asMap(data['skillMatrix'] ?? data['skills'])),
      performanceIndex: PerformanceIndex.fromJson(_asMap(data['performanceIndex'] ?? data['index'])),
      deviations: _asList(data['deviations'])
          .map((e) => AnalyticsDeviation.fromJson(_asMap(e)))
          .toList(),
      battingWeakness: data['battingWeakness'] as String?,
      bowlingWeakness: data['bowlingWeakness'] as String?,
    );
  }
}

class SkillMatrix {
  final double reliability;
  final double power;
  final double bowling;
  final double fielding;
  final double impact;
  final double captaincy;

  const SkillMatrix({
    this.reliability = 0,
    this.power = 0,
    this.bowling = 0,
    this.fielding = 0,
    this.impact = 0,
    this.captaincy = 0,
  });

  factory SkillMatrix.fromJson(Map<String, dynamic> json) {
    return SkillMatrix(
      reliability: _toDouble(json['reliability']),
      power: _toDouble(json['power']),
      bowling: _toDouble(json['bowling']),
      fielding: _toDouble(json['fielding']),
      impact: _toDouble(json['impact']),
      captaincy: _toDouble(json['captaincy']),
    );
  }

  List<double> toList() => [reliability, power, bowling, fielding, impact, captaincy];
}

class PerformanceIndex {
  final double batting;
  final double bowling;
  final double fielding;
  final double impact;
  final double battingPercentile;
  final double bowlingPercentile;
  final double fieldingPercentile;
  final double impactPercentile;

  const PerformanceIndex({
    this.batting = 0,
    this.bowling = 0,
    this.fielding = 0,
    this.impact = 0,
    this.battingPercentile = 0,
    this.bowlingPercentile = 0,
    this.fieldingPercentile = 0,
    this.impactPercentile = 0,
  });

  factory PerformanceIndex.fromJson(Map<String, dynamic> json) {
    return PerformanceIndex(
      batting: _toDouble(json['batting'] ?? json['battingIndex']),
      bowling: _toDouble(json['bowling'] ?? json['bowlingIndex']),
      fielding: _toDouble(json['fielding'] ?? json['fieldingIndex']),
      impact: _toDouble(json['impact'] ?? json['impactIndex']),
      battingPercentile: _toDouble(json['battingPercentile']),
      bowlingPercentile: _toDouble(json['bowlingPercentile']),
      fieldingPercentile: _toDouble(json['fieldingPercentile']),
      impactPercentile: _toDouble(json['impactPercentile']),
    );
  }
}

class AnalyticsDeviation {
  final String title;
  final String description;
  final String severity; // HIGH | MEDIUM | LOW
  final String? icon;

  const AnalyticsDeviation({
    required this.title,
    required this.description,
    this.severity = 'MEDIUM',
    this.icon,
  });

  factory AnalyticsDeviation.fromJson(Map<String, dynamic> json) {
    return AnalyticsDeviation(
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? json['message'] as String? ?? '',
      severity: (json['severity'] as String? ?? 'MEDIUM').toUpperCase(),
      icon: json['icon'] as String?,
    );
  }
}

class Signal {
  final String id;
  final String category;  // Body | Batting | Bowling | Discipline
  final String headline;
  final String body;
  final String flag;      // LOOKING_GOOD | NEEDS_WORK | WATCH_CLOSELY
  final bool isActionable;

  const Signal({
    required this.id,
    required this.category,
    required this.headline,
    required this.body,
    this.flag = 'NEEDS_WORK',
    this.isActionable = false,
  });

  factory Signal.fromJson(Map<String, dynamic> json) {
    return Signal(
      id: json['id'] as String? ?? '',
      category: json['category'] as String? ?? json['type'] as String? ?? 'Discipline',
      headline: json['headline'] as String? ?? json['title'] as String? ?? '',
      body: json['body'] as String? ?? json['description'] as String? ?? json['message'] as String? ?? '',
      flag: (json['flag'] as String? ?? json['status'] as String? ?? 'NEEDS_WORK').toUpperCase(),
      isActionable: json['isActionable'] as bool? ?? false,
    );
  }
}

class WeeklyReview {
  final String weekLabel;
  final List<Signal> insights;
  final List<Recommendation> recommendations;
  final double overallScore;

  const WeeklyReview({
    this.weekLabel = '',
    this.insights = const [],
    this.recommendations = const [],
    this.overallScore = 0,
  });

  factory WeeklyReview.fromJson(Map<String, dynamic> json) {
    final data = _asMap(json['data'] ?? json);
    return WeeklyReview(
      weekLabel: data['weekLabel'] as String? ?? '',
      insights: _asList(data['insights'])
          .map((e) => Signal.fromJson(_asMap(e)))
          .toList(),
      recommendations: _asList(data['recommendations'])
          .map((e) => Recommendation.fromJson(_asMap(e)))
          .toList(),
      overallScore: _toDouble(data['overallScore']),
    );
  }
}

class Recommendation {
  final String id;
  final String text;
  final String category;
  final int priority; // 1, 2, 3
  final String impact; // HIGH | MEDIUM | LOW

  const Recommendation({
    required this.id,
    required this.text,
    this.category = '',
    this.priority = 2,
    this.impact = 'MEDIUM',
  });

  factory Recommendation.fromJson(Map<String, dynamic> json) {
    return Recommendation(
      id: json['id'] as String? ?? '',
      text: json['text'] as String? ?? json['recommendation'] as String? ?? '',
      category: json['category'] as String? ?? '',
      priority: _toInt(json['priority'] ?? 2),
      impact: (json['impact'] as String? ?? 'MEDIUM').toUpperCase(),
    );
  }
}

class Benchmarks {
  final List<BenchmarkEntry> entries;

  const Benchmarks({this.entries = const []});

  factory Benchmarks.fromJson(Map<String, dynamic> json) {
    final data = _asMap(json['data'] ?? json);
    return Benchmarks(
      entries: _asList(data['benchmarks'] ?? data['entries'])
          .map((e) => BenchmarkEntry.fromJson(_asMap(e)))
          .toList(),
    );
  }
}

class BenchmarkEntry {
  final String metric;
  final double yourValue;
  final double cityAvg;
  final double top10Percent;

  const BenchmarkEntry({
    required this.metric,
    required this.yourValue,
    required this.cityAvg,
    required this.top10Percent,
  });

  factory BenchmarkEntry.fromJson(Map<String, dynamic> json) {
    return BenchmarkEntry(
      metric: json['metric'] as String? ?? '',
      yourValue: _toDouble(json['yourValue'] ?? json['you']),
      cityAvg: _toDouble(json['cityAvg'] ?? json['city']),
      top10Percent: _toDouble(json['top10Percent'] ?? json['top10']),
    );
  }
}

class DrillAssignment {
  final String id;
  final String name;
  final String assignedDate;
  final int targetReps;
  final int targetMinutes;
  final int loggedReps;
  final int loggedMinutes;

  const DrillAssignment({
    required this.id,
    required this.name,
    this.assignedDate = '',
    this.targetReps = 0,
    this.targetMinutes = 0,
    this.loggedReps = 0,
    this.loggedMinutes = 0,
  });

  factory DrillAssignment.fromJson(Map<String, dynamic> json) {
    return DrillAssignment(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? json['drillName'] as String? ?? '',
      assignedDate: json['assignedDate'] as String? ?? json['date'] as String? ?? '',
      targetReps: _toInt(json['targetReps']),
      targetMinutes: _toInt(json['targetMinutes']),
      loggedReps: _toInt(json['loggedReps'] ?? json['completedReps']),
      loggedMinutes: _toInt(json['loggedMinutes'] ?? json['completedMinutes']),
    );
  }

  double get progress {
    if (targetReps > 0) return (loggedReps / targetReps).clamp(0.0, 1.0);
    if (targetMinutes > 0) return (loggedMinutes / targetMinutes).clamp(0.0, 1.0);
    return 0;
  }
}

// Payload for saving the AIM goal
class AimGoalPayload {
  final String? targetRole;
  final List<String> targetFormats;
  final String? styleIdentity;
  final String? targetLevel;
  final String? timeline;
  final List<String> focusAreas;
  final String? commitmentStatement;

  // Physical
  final double? heightCm;
  final double? weightKg;
  final double? targetWeight;
  final String? bodyTransformDirection;
  final double? targetBodyFatPercent;
  final int? trainingDaysPerWeek;
  final List<String> fitnessFocuses;
  final String? nutritionObjective;
  final double? dailySleepHoursGoal;
  final double? dailyHydrationLitresGoal;
  final String? morningWakeUpTime;
  final List<String> habitsToQuit;
  final List<String> disciplineGoals;

  const AimGoalPayload({
    this.targetRole,
    this.targetFormats = const [],
    this.styleIdentity,
    this.targetLevel,
    this.timeline,
    this.focusAreas = const [],
    this.commitmentStatement,
    this.heightCm,
    this.weightKg,
    this.targetWeight,
    this.bodyTransformDirection,
    this.targetBodyFatPercent,
    this.trainingDaysPerWeek,
    this.fitnessFocuses = const [],
    this.nutritionObjective,
    this.dailySleepHoursGoal,
    this.dailyHydrationLitresGoal,
    this.morningWakeUpTime,
    this.habitsToQuit = const [],
    this.disciplineGoals = const [],
  });

  Map<String, dynamic> toJson() => {
    if (targetRole != null) 'targetRole': targetRole,
    'targetFormat': targetFormats.isNotEmpty ? targetFormats.join(',') : null,
    if (styleIdentity != null) 'styleIdentity': styleIdentity,
    if (targetLevel != null) 'targetLevel': targetLevel,
    if (timeline != null) 'timeline': timeline,
    'focusAreas': focusAreas,
    if (commitmentStatement != null) 'commitmentStatement': commitmentStatement,
    if (heightCm != null) 'heightCm': heightCm,
    if (weightKg != null) 'weightKg': weightKg,
    if (targetWeight != null) 'targetWeight': targetWeight,
    if (bodyTransformDirection != null) 'bodyTransformDirection': bodyTransformDirection,
    if (targetBodyFatPercent != null) 'targetBodyFatPercent': targetBodyFatPercent,
    if (trainingDaysPerWeek != null) 'trainingDaysPerWeek': trainingDaysPerWeek,
    'fitnessFocuses': fitnessFocuses,
    if (nutritionObjective != null) 'nutritionObjective': nutritionObjective,
    if (dailySleepHoursGoal != null) 'dailySleepHoursGoal': dailySleepHoursGoal,
    if (dailyHydrationLitresGoal != null) 'dailyHydrationLitresGoal': dailyHydrationLitresGoal,
    if (morningWakeUpTime != null) 'morningWakeUpTime': morningWakeUpTime,
    'habitsToQuit': habitsToQuit,
    'disciplineGoals': disciplineGoals,
  };
}

// ─────────────────────────────────────────────────────────────────────────────
//  Helpers
// ─────────────────────────────────────────────────────────────────────────────
double _toDouble(dynamic v) {
  if (v == null) return 0;
  if (v is double) return v;
  if (v is int) return v.toDouble();
  return double.tryParse(v.toString()) ?? 0;
}

int _toInt(dynamic v) {
  if (v == null) return 0;
  if (v is int) return v;
  if (v is double) return v.round();
  return int.tryParse(v.toString()) ?? 0;
}

Map<String, dynamic> _asMap(dynamic v) =>
    (v is Map) ? Map<String, dynamic>.from(v) : {};

List<dynamic> _asList(dynamic v) => (v is List) ? v : const [];
