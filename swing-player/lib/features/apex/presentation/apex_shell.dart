import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../shared/apex_theme.dart';
import '../../elite/controller/elite_controller.dart';
import '../../elite/domain/elite_models.dart';
import '../../../features/profile/controller/profile_controller.dart';
import 'aim/aim_screen.dart';
import 'progress/progress_screen.dart';
import 'evaluate/evaluate_screen.dart';
import 'xlerate/xlerate_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  APEX Shell — premium module root
//
//  Gate logic (sequential):
//    1. profileDone  → core identity filled (name, role, city, level, DOB)
//    2. aimDone      → mission + ambition set (targetRole not empty)
//    3. planDone     → weekly plan exists (plan.days not empty)
//
//  Tab access:
//    A  — always unlocked (setup happens here)
//    P  — needs profileDone + aimDone
//    E  — needs profileDone + aimDone
//    X  — needs profileDone + aimDone + planDone
// ─────────────────────────────────────────────────────────────────────────────

class ApexShell extends ConsumerStatefulWidget {
  const ApexShell({super.key});

  @override
  ConsumerState<ApexShell> createState() => _ApexShellState();
}

class _ApexShellState extends ConsumerState<ApexShell>
    with SingleTickerProviderStateMixin {
  late final TabController _tc;

  @override
  void initState() {
    super.initState();
    _tc = TabController(length: 4, vsync: this);
    _tc.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tc.dispose();
    super.dispose();
  }

  void _goToTab(int index) {
    HapticFeedback.selectionClick();
    _tc.animateTo(index);
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileControllerProvider);
    final apexAsync = ref.watch(apexStateProvider);
    final planAsync = ref.watch(weeklyPlanProvider);

    // ── Derive gate flags ──────────────────────────────────────────────────
    final identity = profileState.data?.identity;
    final editable = profileState.data?.editableProfile;

    final profileDone = (identity?.fullName.trim().isNotEmpty ?? false) &&
        (identity?.primaryRole.trim().isNotEmpty ?? false) &&
        (identity?.city.trim().isNotEmpty ?? false) &&
        (identity?.level.trim().isNotEmpty ?? false) &&
        ((editable?.dateOfBirth ?? '').trim().isNotEmpty);

    final aimDone =
        apexAsync.asData?.value.goal.targetRole?.isNotEmpty ?? false;

    final planDone =
        (planAsync.asData?.value?.days.isNotEmpty ?? false);

    // Tab lock states
    final tabLocked = [
      false,                          // A — always open
      !(profileDone && aimDone),      // P
      !(profileDone && aimDone),      // E
      !(profileDone && aimDone && planDone), // X
    ];

    return ApexTabScope(
      tabController: _tc,
      child: Scaffold(
        backgroundColor: ApexColors.background,
        body: Column(
          children: [
            _ApexAppBar(
              currentIndex: _tc.index,
              tabLocked: tabLocked,
              profileDone: profileDone,
              aimDone: aimDone,
              planDone: planDone,
              onTabSelected: _goToTab,
            ),
            Expanded(
              child: TabBarView(
                controller: _tc,
                physics: const NeverScrollableScrollPhysics(),
                children: const [
                  AimScreen(),
                  ProgressScreen(),
                  EvaluateScreen(),
                  XlerateScreen(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  InheritedWidget — exposes TabController to all APEX children
// ─────────────────────────────────────────────────────────────────────────────

class ApexTabScope extends InheritedWidget {
  const ApexTabScope({
    super.key,
    required this.tabController,
    required super.child,
  });

  final TabController tabController;

  static TabController? of(BuildContext context) =>
      context
          .dependOnInheritedWidgetOfExactType<ApexTabScope>()
          ?.tabController;

  @override
  bool updateShouldNotify(ApexTabScope oldWidget) =>
      tabController != oldWidget.tabController;
}

// ─────────────────────────────────────────────────────────────────────────────
//  APEX App Bar — premium dark, per-tab accent
// ─────────────────────────────────────────────────────────────────────────────

class _ApexAppBar extends StatelessWidget {
  const _ApexAppBar({
    required this.currentIndex,
    required this.tabLocked,
    required this.profileDone,
    required this.aimDone,
    required this.planDone,
    required this.onTabSelected,
  });

  final int currentIndex;
  final List<bool> tabLocked;
  final bool profileDone;
  final bool aimDone;
  final bool planDone;
  final ValueChanged<int> onTabSelected;

  static const _labels = ['A', 'P', 'E', 'X'];
  static const _fullLabels = ['Aim', 'Progress', 'Evaluate', 'Xlerate'];
  static const _accents = [
    ApexColors.accentAim,
    ApexColors.accentProgress,
    ApexColors.accentEvaluate,
    ApexColors.accentXlerate,
  ];

  String _lockHint() {
    if (!profileDone) return 'Complete your profile in A';
    if (!aimDone) return 'Set your mission in A';
    if (!planDone) return 'Set your weekly plan in A';
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final hint = _lockHint();
    return Container(
      color: ApexColors.background,
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),

            // ── Module label + status ──────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
              child: Row(
                children: [
                  const Text(
                    'APEX',
                    style: TextStyle(
                      color: ApexColors.textPrimary,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 3,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    width: 1,
                    height: 12,
                    color: ApexColors.border,
                  ),
                  const SizedBox(width: 10),
                  // Pipeline dots
                  _PipelineDots(
                    profileDone: profileDone,
                    aimDone: aimDone,
                    planDone: planDone,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // ── Tab pills ─────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
              child: Row(
                children: List.generate(4, (i) {
                  final isSelected = i == currentIndex;
                  final locked = tabLocked[i];
                  final accent = _accents[i];

                  return Expanded(
                    child: GestureDetector(
                      onTap: locked ? null : () => onTabSelected(i),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeOutCubic,
                        margin: EdgeInsets.only(right: i < 3 ? 6 : 0),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? accent.withValues(alpha: 0.12)
                              : ApexColors.surface,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSelected
                                ? accent.withValues(alpha: 0.35)
                                : locked
                                    ? ApexColors.border
                                    : ApexColors.borderMid,
                            width: isSelected ? 1 : 0.5,
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Large letter
                            Text(
                              _labels[i],
                              style: TextStyle(
                                color: locked
                                    ? ApexColors.textDim
                                    : isSelected
                                        ? accent
                                        : ApexColors.textPrimary
                                            .withValues(alpha: 0.5),
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 2),
                            // Full label or lock icon
                            locked
                                ? Icon(
                                    Icons.lock_rounded,
                                    size: 9,
                                    color: ApexColors.textDim,
                                  )
                                : Text(
                                    _fullLabels[i],
                                    style: TextStyle(
                                      color: isSelected
                                          ? accent.withValues(alpha: 0.8)
                                          : ApexColors.textMuted,
                                      fontSize: 9,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),

            // ── Lock hint ─────────────────────────────────────────────────
            if (hint.isNotEmpty && tabLocked[currentIndex])
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                child: Row(
                  children: [
                    Icon(
                      Icons.lock_outline_rounded,
                      size: 11,
                      color: ApexColors.textDim,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      hint,
                      style: const TextStyle(
                        color: ApexColors.textDim,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 14),
            Container(height: 0.5, color: ApexColors.border),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Pipeline dot row — shows progress through Profile → AIM → Plan
// ─────────────────────────────────────────────────────────────────────────────

class _PipelineDots extends StatelessWidget {
  const _PipelineDots({
    required this.profileDone,
    required this.aimDone,
    required this.planDone,
  });

  final bool profileDone;
  final bool aimDone;
  final bool planDone;

  @override
  Widget build(BuildContext context) {
    final steps = [
      ('PROFILE', profileDone),
      ('AIM', aimDone),
      ('PLAN', planDone),
    ];

    return Row(
      children: steps.asMap().entries.map((e) {
        final idx = e.key;
        final label = e.value.$1;
        final done = e.value.$2;

        return Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: done
                    ? ApexColors.accentAim.withValues(alpha: 0.12)
                    : ApexColors.surface,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: done
                      ? ApexColors.accentAim.withValues(alpha: 0.3)
                      : ApexColors.border,
                  width: 0.5,
                ),
              ),
              child: Text(
                label,
                style: TextStyle(
                  color: done ? ApexColors.accentAim : ApexColors.textDim,
                  fontSize: 8,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                ),
              ),
            ),
            if (idx < steps.length - 1) ...[
              const SizedBox(width: 4),
              Container(
                width: 10,
                height: 0.5,
                color: ApexColors.border,
              ),
              const SizedBox(width: 4),
            ],
          ],
        );
      }).toList(),
    );
  }
}
