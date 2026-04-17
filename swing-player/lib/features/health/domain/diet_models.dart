// ── Nutrition Item (from library) ─────────────────────────────────────────────

class NutritionItem {
  const NutritionItem({
    required this.id,
    required this.name,
    required this.calories,
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
    this.fiberG = 0,
    this.sugarG = 0,
    this.sodiumMg = 0,
    this.hydrationScore = 0,
    this.recoveryScore = 0,
    this.energyScore = 0,
    this.category,
    this.subCategory,
    this.goalTags = const [],
    this.timingTags = const [],
    this.dietTags = const [],
    this.cuisineTags = const [],
    this.allergenTags = const [],
    this.digestibility,
    this.matchDaySafe = false,
    this.heavyMeal = false,
    this.recommendedFor = const [],
    this.avoidIfTags = const [],
  });

  final String id;
  final String name;
  final double calories;
  final double proteinG;
  final double carbsG;
  final double fatG;
  final double fiberG;
  final double sugarG;
  final double sodiumMg;
  final int hydrationScore;
  final int recoveryScore;
  final int energyScore;
  final String? category;
  final String? subCategory;
  final List<String> goalTags;
  final List<String> timingTags;
  final List<String> dietTags;
  final List<String> cuisineTags;
  final List<String> allergenTags;
  final String? digestibility;
  final bool matchDaySafe;
  final bool heavyMeal;
  final List<String> recommendedFor;
  final List<String> avoidIfTags;

  factory NutritionItem.fromJson(Map<String, dynamic> json) {
    return NutritionItem(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      name: (json['name'] ?? 'Unknown').toString(),
      calories: _toDouble(json['calories']),
      proteinG: _toDouble(json['proteinG']),
      carbsG: _toDouble(json['carbsG']),
      fatG: _toDouble(json['fatG']),
      fiberG: _toDouble(json['fiberG']),
      sugarG: _toDouble(json['sugarG']),
      sodiumMg: _toDouble(json['sodiumMg']),
      hydrationScore: _toInt(json['hydrationScore']),
      recoveryScore: _toInt(json['recoveryScore']),
      energyScore: _toInt(json['energyScore']),
      category: json['category'] as String?,
      subCategory: json['subCategory'] as String?,
      goalTags: _toStringList(json['goalTags']),
      timingTags: _toStringList(json['timingTags']),
      dietTags: _toStringList(json['dietTags']),
      cuisineTags: _toStringList(json['cuisineTags']),
      allergenTags: _toStringList(json['allergenTags']),
      digestibility: json['digestibility'] as String?,
      matchDaySafe: json['matchDaySafe'] == true,
      heavyMeal: json['heavyMeal'] == true,
      recommendedFor: _toStringList(json['recommendedFor']),
      avoidIfTags: _toStringList(json['avoidIfTags']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'calories': calories,
        'proteinG': proteinG,
        'carbsG': carbsG,
        'fatG': fatG,
        'fiberG': fiberG,
        'sugarG': sugarG,
        'sodiumMg': sodiumMg,
        'hydrationScore': hydrationScore,
        'recoveryScore': recoveryScore,
        'energyScore': energyScore,
        if (category != null) 'category': category,
        if (subCategory != null) 'subCategory': subCategory,
        'goalTags': goalTags,
        'timingTags': timingTags,
        'dietTags': dietTags,
        'cuisineTags': cuisineTags,
        'allergenTags': allergenTags,
        if (digestibility != null) 'digestibility': digestibility,
        'matchDaySafe': matchDaySafe,
        'heavyMeal': heavyMeal,
        'recommendedFor': recommendedFor,
        'avoidIfTags': avoidIfTags,
      };

  NutritionItem scaledTo(double servings) {
    return NutritionItem(
      id: id,
      name: name,
      calories: calories * servings,
      proteinG: proteinG * servings,
      carbsG: carbsG * servings,
      fatG: fatG * servings,
      fiberG: fiberG * servings,
      sugarG: sugarG * servings,
      sodiumMg: sodiumMg * servings,
      hydrationScore: hydrationScore,
      recoveryScore: recoveryScore,
      energyScore: energyScore,
      category: category,
      subCategory: subCategory,
      goalTags: goalTags,
      timingTags: timingTags,
      dietTags: dietTags,
      matchDaySafe: matchDaySafe,
      heavyMeal: heavyMeal,
    );
  }
}

// ── Meal types ────────────────────────────────────────────────────────────────

enum MealType {
  breakfast,
  lunch,
  dinner,
  preMeal,
  postMeal,
  snacks;

  String get label => switch (this) {
        MealType.breakfast => 'Breakfast',
        MealType.lunch => 'Lunch',
        MealType.dinner => 'Dinner',
        MealType.preMeal => 'Pre-meal',
        MealType.postMeal => 'Post-meal',
        MealType.snacks => 'Snacks',
      };

  String get apiValue => switch (this) {
        MealType.breakfast => 'BREAKFAST',
        MealType.lunch => 'LUNCH',
        MealType.dinner => 'DINNER',
        MealType.preMeal => 'PRE_MEAL',
        MealType.postMeal => 'POST_MEAL',
        MealType.snacks => 'SNACKS',
      };

  static MealType fromString(String v) {
    final s = v.toUpperCase();
    for (final t in values) {
      if (t.apiValue == s) return t;
    }
    return MealType.snacks;
  }
}

// ── A logged meal row ─────────────────────────────────────────────────────────

class MealLog {
  const MealLog({
    required this.id,
    required this.mealType,
    required this.loggedAt,
    required this.items,
    this.waterMl = 0,
    this.notes,
  });

  final String id;
  final MealType mealType;
  final DateTime loggedAt;
  final List<MealLogItem> items;
  final int waterMl;
  final String? notes;

  double get totalCalories =>
      items.fold(0, (sum, i) => sum + i.item.calories * i.servings);
  double get totalProtein =>
      items.fold(0, (sum, i) => sum + i.item.proteinG * i.servings);
  double get totalCarbs =>
      items.fold(0, (sum, i) => sum + i.item.carbsG * i.servings);
  double get totalFat =>
      items.fold(0, (sum, i) => sum + i.item.fatG * i.servings);

  factory MealLog.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List? ?? [];
    return MealLog(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      mealType: MealType.fromString((json['mealType'] ?? '').toString()),
      loggedAt: DateTime.tryParse((json['loggedAt'] ?? '').toString()) ??
          DateTime.now(),
      items: rawItems
          .whereType<Map<String, dynamic>>()
          .map(MealLogItem.fromJson)
          .toList(),
      waterMl: _toInt(json['waterMl']),
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'mealType': mealType.apiValue,
        'loggedAt': loggedAt.toIso8601String(),
        'items': items.map((i) => i.toJson()).toList(),
        'waterMl': waterMl,
        if (notes != null) 'notes': notes,
      };
}

class MealLogItem {
  const MealLogItem({
    required this.item,
    required this.servings,
  });

  final NutritionItem item;
  final double servings;

  factory MealLogItem.fromJson(Map<String, dynamic> json) {
    final rawItem =
        (json['nutritionItem'] ?? json['item'] ?? json) as Map<String, dynamic>;
    return MealLogItem(
      item: NutritionItem.fromJson(rawItem),
      servings: _toDouble(json['servings'] ?? 1),
    );
  }

  Map<String, dynamic> toJson({bool includeItem = false}) => {
        'nutritionItemId': item.id,
        if (includeItem) 'item': item.toJson(),
        'servings': servings,
      };
}

// ── Daily summary aggregated on client ───────────────────────────────────────

class DietDailySummary {
  const DietDailySummary({
    required this.date,
    required this.meals,
    required this.totalWaterMl,
    required this.calorieTarget,
    required this.proteinTargetG,
    required this.carbsTargetG,
    required this.fatTargetG,
  });

  final DateTime date;
  final List<MealLog> meals;
  final int totalWaterMl;
  final double calorieTarget;
  final double proteinTargetG;
  final double carbsTargetG;
  final double fatTargetG;

  double get totalCalories => meals.fold(0, (s, m) => s + m.totalCalories);
  double get totalProtein => meals.fold(0, (s, m) => s + m.totalProtein);
  double get totalCarbs => meals.fold(0, (s, m) => s + m.totalCarbs);
  double get totalFat => meals.fold(0, (s, m) => s + m.totalFat);

  double get totalFiber => meals.fold(
      0,
      (s, m) =>
          s + m.items.fold(0, (si, i) => si + i.item.fiberG * i.servings));

  double get totalSugar => meals.fold(
      0,
      (s, m) =>
          s + m.items.fold(0, (si, i) => si + i.item.sugarG * i.servings));

  double get caloriePct =>
      calorieTarget > 0 ? (totalCalories / calorieTarget).clamp(0, 1) : 0;
  double get proteinPct =>
      proteinTargetG > 0 ? (totalProtein / proteinTargetG).clamp(0, 1) : 0;
  double get carbsPct =>
      carbsTargetG > 0 ? (totalCarbs / carbsTargetG).clamp(0, 1) : 0;
  double get fatPct => fatTargetG > 0 ? (totalFat / fatTargetG).clamp(0, 1) : 0;

  double get waterPct => (totalWaterMl / 2500).clamp(0, 1);

  int get avgHydrationScore {
    final allItems = meals.expand((m) => m.items).toList();
    if (allItems.isEmpty) return 0;
    final sum = allItems.fold(0, (s, i) => s + i.item.hydrationScore);
    return sum ~/ allItems.length;
  }

  int get avgRecoveryScore {
    final allItems = meals.expand((m) => m.items).toList();
    if (allItems.isEmpty) return 0;
    final sum = allItems.fold(0, (s, i) => s + i.item.recoveryScore);
    return sum ~/ allItems.length;
  }

  int get avgEnergyScore {
    final allItems = meals.expand((m) => m.items).toList();
    if (allItems.isEmpty) return 0;
    final sum = allItems.fold(0, (s, i) => s + i.item.energyScore);
    return sum ~/ allItems.length;
  }

  List<DietInsight> get insights {
    final result = <DietInsight>[];

    if (proteinPct < 0.8) {
      final remaining = (proteinTargetG - totalProtein).round();
      result.add(DietInsight(
        type: DietInsightType.warning,
        title: 'Protein at ${(proteinPct * 100).round()}%',
        body:
            'Have ${remaining}g more — try a lean source with your next meal.',
        cta: 'Log Protein',
      ));
    } else {
      result.add(const DietInsight(
        type: DietInsightType.good,
        title: 'Protein on track ✓',
        body: 'Great job hitting your protein targets today.',
      ));
    }

    if (waterPct < 0.6) {
      result.add(const DietInsight(
        type: DietInsightType.critical,
        title: 'Hydration below optimal',
        body: 'You\'re significantly under your daily water target.',
        cta: 'Log Water',
      ));
    }

    if (carbsPct > 0.92) {
      result.add(const DietInsight(
        type: DietInsightType.warning,
        title: 'High carb intake today',
        body: 'Consider lighter carbs at dinner to balance your macros.',
      ));
    }

    final heavyItems =
        meals.expand((m) => m.items).where((i) => i.item.heavyMeal).toList();
    if (heavyItems.isNotEmpty) {
      result.add(const DietInsight(
        type: DietInsightType.info,
        title: 'Heavy meal logged',
        body: 'Allow 2+ hours before your next training session.',
      ));
    }

    if (avgRecoveryScore > 70) {
      result.add(const DietInsight(
        type: DietInsightType.good,
        title: 'Good recovery nutrition 💪',
        body: 'Today\'s meals are supporting post-training recovery well.',
      ));
    }

    return result;
  }

  MealLog? mealFor(MealType type) {
    try {
      return meals.firstWhere((m) => m.mealType == type);
    } catch (_) {
      return null;
    }
  }

  static DietDailySummary empty(DateTime date) => DietDailySummary(
        date: date,
        meals: [],
        totalWaterMl: 0,
        calorieTarget: 2400,
        proteinTargetG: 80,
        carbsTargetG: 240,
        fatTargetG: 65,
      );
}

// ── Insight model ────────────────────────────────────────────────────────────

enum DietInsightType { good, warning, critical, info }

class DietInsight {
  const DietInsight({
    required this.type,
    required this.title,
    required this.body,
    this.cta,
  });

  final DietInsightType type;
  final String title;
  final String body;
  final String? cta;
}

// ── Helpers ──────────────────────────────────────────────────────────────────

double _toDouble(dynamic v) =>
    v is num ? v.toDouble() : double.tryParse(v?.toString() ?? '') ?? 0;

int _toInt(dynamic v) =>
    v is num ? v.toInt() : int.tryParse(v?.toString() ?? '') ?? 0;

List<String> _toStringList(dynamic v) =>
    v is List ? v.map((e) => e.toString()).toList() : [];
