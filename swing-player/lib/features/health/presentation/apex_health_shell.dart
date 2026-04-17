import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../elite/controller/elite_controller.dart';
import '../../elite/presentation/elite_dashboard_screen.dart';
import '../../profile/controller/profile_controller.dart';
import '../../profile/data/stats_extended_provider.dart';
import '../controller/diet_controller.dart';
import '../controller/health_controller.dart';
import '../controller/health_integration_controller.dart';
import 'diet_screen.dart';
import 'fitness_screen.dart';
import 'vitals_screen.dart';
import 'widgets/workload_log_sheet.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  APEX Health Shell
//
//  Top tab bar: APEX | DIET | FITNESS | VITALS
//  Right side actions: [⊕ Add Log ▾]  [↺]
// ─────────────────────────────────────────────────────────────────────────────

// ─── ARCHIVED v1 ─── Use ApexShell (apex_shell.dart) for the active build.
class ApexHealthShellV1 extends ConsumerStatefulWidget {
  const ApexHealthShellV1({super.key, this.initialIndex = 0});
  final int initialIndex;

  @override
  ConsumerState<ApexHealthShellV1> createState() => _ApexHealthShellV1State();
}

class _ApexHealthShellV1State extends ConsumerState<ApexHealthShellV1>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 4,
      vsync: this,
      initialIndex: widget.initialIndex,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ── Refresh all providers relevant to current tab ─────────────────────────
  void _refresh() {
    HapticFeedback.lightImpact();
    final tab = _tabController.index;
    final profileState = ref.read(profileControllerProvider);
    final playerId = profileState.data?.identity.id;

    // Always refresh APEX data
    ref.invalidate(eliteProfileProvider);
    ref.invalidate(weeklyPlanProvider);
    ref.invalidate(executionStreakProvider);
    ref.invalidate(journalConsistencyProvider(30));
    ref.invalidate(profileControllerProvider);
    if (playerId != null && playerId.trim().isNotEmpty) {
      ref.invalidate(statsExtendedProvider(playerId.trim()));
    }

    // Tab-specific
    if (tab == 1) ref.invalidate(dietSummaryProvider);
    if (tab == 2 || tab == 3) {
      ref.invalidate(healthDashboardProvider);
      ref.invalidate(recentHealthDataProvider);
    }
  }

  // ── Multi-log bottom sheet ─────────────────────────────────────────────────
  void _openAddLog() {
    HapticFeedback.mediumImpact();
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _AddLogSheet(ref: ref),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bg,
      appBar: AppBar(
        backgroundColor: context.bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        toolbarHeight: 56,
        titleSpacing: 18,
        // ── Brand ─────────────────────────────────────────────────────────────
        title: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    context.accent,
                    Color.lerp(context.accent, context.gold, 0.45)!,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(9),
              ),
              child: const Icon(
                Icons.offline_bolt_rounded,
                color: Colors.white,
                size: 17,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'APEX',
              style: TextStyle(
                color: context.fg,
                fontSize: 20,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.4,
              ),
            ),
          ],
        ),
        // ── Actions ───────────────────────────────────────────────────────────
        actions: [
          // Multi-log button
          _AddLogButton(onTap: _openAddLog),
          const SizedBox(width: 8),
          // Refresh
          _RefreshButton(onTap: _refresh),
          const SizedBox(width: 14),
        ],
        // ── Top tab strip ──────────────────────────────────────────────────────
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(42),
          child: _ApexTabBar(controller: _tabController),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        physics: const NeverScrollableScrollPhysics(),
        children: const [
          EliteDashboardScreen(),
          DietScreen(),
          FitnessScreen(),
          VitalsScreen(),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  ⊕ Add Log Button
// ─────────────────────────────────────────────────────────────────────────────

class _AddLogButton extends StatelessWidget {
  const _AddLogButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              context.accent.withValues(alpha: 0.18),
              context.accent.withValues(alpha: 0.08),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: context.accent.withValues(alpha: 0.35),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add_rounded, color: context.accent, size: 15),
            const SizedBox(width: 5),
            Text(
              'Add Log',
              style: TextStyle(
                color: context.accent,
                fontSize: 12.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              color: context.accent.withValues(alpha: 0.7),
              size: 14,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Refresh button
// ─────────────────────────────────────────────────────────────────────────────

class _RefreshButton extends StatelessWidget {
  const _RefreshButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: context.cardBg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: context.stroke),
        ),
        child: Icon(Icons.refresh_rounded, color: context.fgSub, size: 18),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Add Log Bottom Sheet — premium multi-option sheet
// ─────────────────────────────────────────────────────────────────────────────

class _AddLogSheet extends StatelessWidget {
  const _AddLogSheet({required this.ref});
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.surf,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(
          top: BorderSide(color: context.stroke.withValues(alpha: 0.5)),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 36),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: context.stroke,
                borderRadius: BorderRadius.circular(100),
              ),
            ),
          ),
          // Header
          Text(
            'Add Log',
            style: TextStyle(
              color: context.fg,
              fontSize: 22,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'What do you want to record today?',
            style: TextStyle(
              color: context.fgSub,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 24),
          // Options
          _LogOption(
            icon: Icons.edit_note_rounded,
            label: 'Log Journal',
            subtitle: 'Daily readiness, mood & session notes',
            color: context.accent,
            onTap: () {
              Navigator.pop(context);
              openApexJournalModal(context, ref);
            },
          ),
          const SizedBox(height: 12),
          _LogOption(
            icon: Icons.restaurant_menu_rounded,
            label: 'Log Meal',
            subtitle: 'Track calories, macros & hydration',
            color: context.gold,
            onTap: () {
              Navigator.pop(context);
              ref.read(dietLogProvider.notifier).reset();
              showModalBottomSheet<void>(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                useSafeArea: true,
                builder: (_) => DietLogModal(
                  onSaved: () => ref.invalidate(dietSummaryProvider),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          _LogOption(
            icon: Icons.fitness_center_rounded,
            label: 'Log Fitness',
            subtitle: 'Session load, RPE & workout type',
            color: context.success,
            onTap: () {
              Navigator.pop(context);
              showModalBottomSheet<void>(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => const WorkloadLogSheet(),
              );
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Log option tile
// ─────────────────────────────────────────────────────────────────────────────

class _LogOption extends StatelessWidget {
  const _LogOption({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color.withValues(alpha: 0.18)),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: context.fg,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: context.fgSub,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: color.withValues(alpha: 0.6),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Top tab bar ───────────────────────────────────────────────────────────────

class _ApexTabBar extends StatelessWidget {
  const _ApexTabBar({required this.controller});
  final TabController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: context.stroke.withValues(alpha: 0.5),
            width: 0.5,
          ),
        ),
      ),
      child: TabBar(
        controller: controller,
        isScrollable: false,
        dividerColor: Colors.transparent,
        splashFactory: NoSplash.splashFactory,
        overlayColor: WidgetStateProperty.all(Colors.transparent),
        labelColor: context.accent,
        unselectedLabelColor: context.fgSub,
        indicatorColor: context.accent,
        indicatorWeight: 2.5,
        indicatorSize: TabBarIndicatorSize.tab,
        labelStyle: const TextStyle(
          fontWeight: FontWeight.w800,
          fontSize: 12.5,
          letterSpacing: 0.5,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 12.5,
          letterSpacing: 0.3,
        ),
        tabs: const [
          Tab(text: 'APEX'),
          Tab(text: 'DIET'),
          Tab(text: 'FITNESS'),
          Tab(text: 'VITALS'),
        ],
      ),
    );
  }
}
