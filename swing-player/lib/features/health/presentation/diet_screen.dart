import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../controller/diet_controller.dart';
import '../data/diet_repository.dart';
import '../domain/diet_models.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  Premium Diet Log Modal  ·  v2
//  Redesigned as a technical nutrition hub.
//  Two-tab system: BUILD PLATE | TODAY'S LOG
// ─────────────────────────────────────────────────────────────────────────────

class DietLogModal extends ConsumerStatefulWidget {
  const DietLogModal({super.key, required this.onSaved});
  final VoidCallback onSaved;

  @override
  ConsumerState<DietLogModal> createState() => _DietLogModalState();
}

class _DietLogModalState extends ConsumerState<DietLogModal> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final logState = ref.watch(dietLogProvider);
    final summaryAsync = ref.watch(dietSummaryProvider(null)); // Today's summary

    return Container(
      height: MediaQuery.of(context).size.height * 0.94,
      decoration: const BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
      ),
      child: Column(
        children: [
          // ── Technical Header ───────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('NUTRITION COMMAND', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2.0)),
                    const SizedBox(height: 4),
                    Text(
                      'LOGGING: ${logState.selectedMealType.label.toUpperCase()}',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 14, fontWeight: FontWeight.w900, fontFamily: 'monospace'),
                    ),
                  ],
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded, color: Colors.white30),
                ),
              ],
            ),
          ),

          // ── Tabs ──────────────────────────────────────────────────────────
          TabBar(
            controller: _tabController,
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white24,
            labelStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5),
            dividerColor: Colors.white.withValues(alpha: 0.05),
            tabs: const [
              Tab(text: 'BUILD PLATE'),
              Tab(text: "TODAY'S LOG"),
            ],
          ),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // ── Tab 1: Build Plate ──────────────────────────────────────
                _BuildPlateTab(
                  logState: logState,
                  searchCtrl: _searchCtrl,
                  onSearchChanged: (v) => setState(() => _searchQuery = v),
                  searchQuery: _searchQuery,
                ),

                // ── Tab 2: Today's Log ──────────────────────────────────────
                _DailyLogOverview(summaryAsync: summaryAsync),
              ],
            ),
          ),

          // ── Save Action ────────────────────────────────────────────────────
          if (_tabController.index == 0)
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: _SaveButton(
                  logState: logState,
                  onSave: () async {
                    final repo = DietRepository();
                    await ref.read(dietLogProvider.notifier).submit(repo);
                    if (!ref.read(dietLogProvider).isSubmitting && ref.read(dietLogProvider).error == null) {
                      widget.onSaved();
                      if (context.mounted) Navigator.of(context).pop();
                    }
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Tab Contents ─────────────────────────────────────────────────────────────

class _BuildPlateTab extends ConsumerWidget {
  const _BuildPlateTab({
    required this.logState,
    required this.searchCtrl,
    required this.onSearchChanged,
    required this.searchQuery,
  });

  final DietLogState logState;
  final TextEditingController searchCtrl;
  final ValueChanged<String> onSearchChanged;
  final String searchQuery;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
      children: [
        // Current Selection Summary
        _TechnicalPlateSummary(state: logState),
        const SizedBox(height: 32),

        // Meal Type Quick Switch
        const _Label('SELECT MEAL TYPE'),
        const SizedBox(height: 12),
        _MealPillRow(
          selected: logState.selectedMealType,
          onSelect: (t) => ref.read(dietLogProvider.notifier).setMealType(t),
        ),
        const SizedBox(height: 40),

        // Search Section
        const _Label('INITIALISE SEARCH'),
        const SizedBox(height: 12),
        _PremiumSearchField(controller: searchCtrl, onChanged: onSearchChanged),
        
        const SizedBox(height: 24),

        if (searchQuery.isNotEmpty)
          _SearchResults(
            query: searchQuery,
            selectedEntries: logState.loggedItems,
            onAdd: (item) {
              ref.read(dietLogProvider.notifier).addItem(item);
              HapticFeedback.lightImpact();
            },
          ),

        // Active List
        if (logState.loggedItems.isNotEmpty) ...[
          const SizedBox(height: 32),
          const _Label('ON YOUR PLATE'),
          const SizedBox(height: 16),
          ...logState.loggedItems.map((e) => _LoggedItemTile(
            entry: e,
            onUpdate: (v) => ref.read(dietLogProvider.notifier).updateServings(e.item.id, v),
            onRemove: () => ref.read(dietLogProvider.notifier).removeItem(e.item.id),
          )),
        ],

        const SizedBox(height: 32),
        _WaterLogger(
          currentMl: logState.waterMl,
          onChange: (ml) => ref.read(dietLogProvider.notifier).setWater(ml),
        ),
      ],
    );
  }
}

class _DailyLogOverview extends StatelessWidget {
  const _DailyLogOverview({required this.summaryAsync});
  final AsyncValue<DietDailySummary> summaryAsync;

  @override
  Widget build(BuildContext context) {
    return summaryAsync.when(
      loading: () => const Center(child: CircularProgressIndicator(color: Colors.white, strokeWidth: 1)),
      error: (e, st) => Center(child: Text('ERR: $e', style: const TextStyle(color: Colors.red))),
      data: (summary) {
        if (summary.meals.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.restaurant_menu_outlined, color: Colors.white.withValues(alpha: 0.1), size: 48),
                const SizedBox(height: 16),
                const Text('NO DATA FOR TODAY', style: TextStyle(color: Colors.white24, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
              ],
            ),
          );
        }

        return ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const _Label("TODAY'S FUEL ACCUMULATION"),
            const SizedBox(height: 24),
            ...summary.meals.map((meal) => _MealSummaryCard(meal: meal)),
          ],
        );
      },
    );
  }
}

// ── Components ───────────────────────────────────────────────────────────────

class _TechnicalPlateSummary extends StatelessWidget {
  const _TechnicalPlateSummary({required this.state});
  final DietLogState state;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        color: Colors.white.withValues(alpha: 0.02),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _MetricBlock(label: 'CALORIES', value: '${state.totalCalories.toInt()}', unit: 'KCAL'),
              _MetricBlock(label: 'PROTEIN', value: state.totalProtein.toStringAsFixed(0), unit: 'G'),
              _MetricBlock(label: 'CARBS', value: state.totalCarbs.toStringAsFixed(0), unit: 'G'),
              _MetricBlock(label: 'FAT', value: state.totalFat.toStringAsFixed(0), unit: 'G'),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricBlock extends StatelessWidget {
  const _MetricBlock({required this.label, required this.value, required this.unit});
  final String label, value, unit;
  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontSize: 8, fontWeight: FontWeight.w900)),
      const SizedBox(height: 8),
      Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900, fontFamily: 'monospace')),
      Text(unit, style: TextStyle(color: Colors.white.withValues(alpha: 0.2), fontSize: 7, fontWeight: FontWeight.w700)),
    ],
  );
}

class _MealPillRow extends StatelessWidget {
  const _MealPillRow({required this.selected, required this.onSelect});
  final MealType selected;
  final ValueChanged<MealType> onSelect;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: MealType.values.map((type) {
          final isSelected = type == selected;
          return GestureDetector(
            onTap: () => onSelect(type),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(2),
                border: Border.all(color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.1)),
              ),
              child: Text(type.label.toUpperCase(), style: TextStyle(color: isSelected ? Colors.black : Colors.white60, fontSize: 9, fontWeight: FontWeight.w900)),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _PremiumSearchField extends StatelessWidget {
  const _PremiumSearchField({required this.controller, required this.onChanged});
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      style: const TextStyle(color: Colors.white, fontSize: 14, fontFamily: 'monospace'),
      decoration: InputDecoration(
        hintText: 'SEARCH FUEL SOURCES...',
        hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.1), fontSize: 12, letterSpacing: 1.0),
        prefixIcon: const Icon(Icons.search_rounded, color: Colors.white30, size: 18),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.03),
        border: const OutlineInputBorder(borderSide: BorderSide(color: Colors.white10)),
        enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.white10)),
        focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
        contentPadding: const EdgeInsets.all(16),
      ),
    );
  }
}

class _LoggedItemTile extends StatelessWidget {
  const _LoggedItemTile({required this.entry, required this.onUpdate, required this.onRemove});
  final DietLogEntry entry;
  final ValueChanged<double> onUpdate;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.02),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(entry.item.name.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                const SizedBox(height: 4),
                Text(
                  '${(entry.item.calories * entry.servings).toInt()} KCAL // ${entry.servings} SERVING',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontSize: 9, fontWeight: FontWeight.w700, fontFamily: 'monospace'),
                ),
              ],
            ),
          ),
          _Stepper(value: entry.servings, onPlus: () => onUpdate(entry.servings + 0.5), onMinus: () => onUpdate(entry.servings - 0.5)),
          const SizedBox(width: 12),
          IconButton(onPressed: onRemove, icon: const Icon(Icons.close_rounded, color: Colors.red, size: 16), constraints: const BoxConstraints()),
        ],
      ),
    );
  }
}

class _Stepper extends StatelessWidget {
  const _Stepper({required this.value, required this.onPlus, required this.onMinus});
  final double value;
  final VoidCallback onPlus, onMinus;
  @override
  Widget build(BuildContext context) => Row(
    children: [
      GestureDetector(onTap: onMinus, child: Icon(Icons.remove_circle_outline_rounded, color: Colors.white.withValues(alpha: 0.2), size: 18)),
      const SizedBox(width: 12),
      Text('$value', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w900, fontFamily: 'monospace')),
      const SizedBox(width: 12),
      GestureDetector(onTap: onPlus, child: const Icon(Icons.add_circle_outline_rounded, color: Colors.white, size: 18)),
    ],
  );
}

class _MealSummaryCard extends StatelessWidget {
  const _MealSummaryCard({required this.meal});
  final MealLog meal;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(meal.mealType.label.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1.0)),
              Text('${meal.totalCalories.toInt()} KCAL', style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 10, fontWeight: FontWeight.w800, fontFamily: 'monospace')),
            ],
          ),
          const SizedBox(height: 16),
          ...meal.items.map((i) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              children: [
                const Icon(Icons.chevron_right_rounded, color: Colors.white24, size: 14),
                const SizedBox(width: 8),
                Text(i.item.name, style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 11)),
                const Spacer(),
                Text('${i.servings}x', style: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontSize: 10, fontFamily: 'monospace')),
              ],
            ),
          )),
        ],
      ),
    );
  }
}

class _WaterLogger extends StatelessWidget {
  const _WaterLogger({required this.currentMl, required this.onChange});
  final int currentMl;
  final ValueChanged<int> onChange;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.02),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.water_drop_outlined, color: Colors.white, size: 16),
              const SizedBox(width: 10),
              const Text('HYDRATION ACCUMULATION', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900)),
              const Spacer(),
              Text('${(currentMl / 1000).toStringAsFixed(1)}L', style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w900, fontFamily: 'monospace')),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [250, 500, 750, 1000].map((ml) => GestureDetector(
              onTap: () => onChange(currentMl + ml),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(border: Border.all(color: Colors.white.withValues(alpha: 0.1)), borderRadius: BorderRadius.circular(2)),
                child: Text(ml >= 1000 ? '1L' : '${ml}ML', style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 10, fontWeight: FontWeight.w900)),
              ),
            )).toList(),
          ),
        ],
      ),
    );
  }
}

class _SaveButton extends StatelessWidget {
  const _SaveButton({required this.logState, required this.onSave});
  final DietLogState logState;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final isEmpty = logState.loggedItems.isEmpty && logState.waterMl == 0;
    return GestureDetector(
      onTap: isEmpty || logState.isSubmitting ? null : onSave,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: isEmpty ? Colors.white.withValues(alpha: 0.1) : Colors.white,
          borderRadius: BorderRadius.circular(2),
        ),
        child: Center(
          child: logState.isSubmitting
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
            : Text(
                isEmpty ? 'NO DATA TO INITIALISE' : 'COMMIT ${logState.selectedMealType.label.toUpperCase()}',
                style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1.5),
              ),
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Text(
    text,
    style: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 2.0),
  );
}

class _SearchResults extends ConsumerWidget {
  const _SearchResults({required this.query, required this.selectedEntries, required this.onAdd});
  final String query;
  final List<DietLogEntry> selectedEntries;
  final ValueChanged<NutritionItem> onAdd;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(nutritionSearchProvider(query));
    return async.when(
      loading: () => const Padding(padding: EdgeInsets.all(24), child: Center(child: CircularProgressIndicator(color: Colors.white, strokeWidth: 1))),
      error: (_, __) => const Center(child: Text('SEARCH OFFLINE', style: TextStyle(color: Colors.white24, fontSize: 10))),
      data: (items) {
        if (items.isEmpty) return const Center(child: Text('NO RESULTS', style: TextStyle(color: Colors.white24, fontSize: 10)));
        return Column(
          children: items.map((item) {
            final isAdded = selectedEntries.any((e) => e.item.id == item.id);
            return GestureDetector(
              onTap: () => onAdd(item),
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isAdded ? Colors.white.withValues(alpha: 0.05) : Colors.white.withValues(alpha: 0.02),
                  border: Border.all(color: isAdded ? Colors.white.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.05)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.name.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w900)),
                          const SizedBox(height: 4),
                          Text('${item.calories.toInt()} KCAL // ${item.proteinG.toInt()}G P', style: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontSize: 9, fontFamily: 'monospace')),
                        ],
                      ),
                    ),
                    Icon(isAdded ? Icons.check_circle_outline_rounded : Icons.add_circle_outline_rounded, color: isAdded ? Colors.white : Colors.white24, size: 18),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

class DietScreen extends ConsumerWidget {
  const DietScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(dietSummaryProvider(null));
    return _DailyLogOverview(summaryAsync: summaryAsync);
  }
}

