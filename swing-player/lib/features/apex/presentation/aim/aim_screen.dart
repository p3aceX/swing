import "package:cached_network_image/cached_network_image.dart";
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../shared/apex_theme.dart';
import '../../../elite/controller/elite_controller.dart';
import '../../../elite/domain/elite_models.dart';
import '../../../profile/controller/profile_controller.dart';
import '../../../profile/presentation/edit_profile_screen.dart';
import 'journal_flow.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  AIM Screen — Journey Chapter 1
//  "Who you are → Who you want to be → What it takes"
//
//  Data sources (CORRECT):
//    • eliteProfileProvider      → ApexGoal (full model: height/weight/body/fitness)
//    • weeklyPlanProvider        → WeeklyPlan (actual plan from DB)
//    • journalConsistencyProvider → streak + plan vs execution
// ─────────────────────────────────────────────────────────────────────────────

class AimScreen extends ConsumerStatefulWidget {
  const AimScreen({super.key});

  @override
  ConsumerState<AimScreen> createState() => _AimScreenState();
}

class _AimScreenState extends ConsumerState<AimScreen> {
  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(eliteProfileProvider);

    return Scaffold(
      backgroundColor: ApexColors.background,
      body: profileAsync.when(
        loading: () => const _AimShimmer(),
        error: (e, _) => ApexErrorWidget(
          onRetry: () => ref.invalidate(eliteProfileProvider),
          message: 'Could not load mission data',
        ),
        data: (profile) {
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: animation.drive(Tween(
                    begin: const Offset(0, 0.05),
                    end: Offset.zero,
                  ).chain(CurveTween(curve: Curves.easeOutCubic))),
                  child: child,
                ),
              );
            },
            child: KeyedSubtree(
              key: ValueKey(profile.goal?.targetRole ?? 'empty_goal'),
              child: _AimCommandCenter(
                onSetupMission: () => _openMissionSetup(profile.goal),
                onJournal: () => _openJournal(context, ref),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _openMissionSetup(ApexGoal? existing) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (_) => _MissionGoalStep2Screen(existing: existing),
      ),
    );
    if (!mounted) return;
    ref.invalidate(eliteProfileProvider);
    ref.invalidate(apexStateProvider);
  }

  void _openJournal(BuildContext context, WidgetRef ref) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ProviderScope(
        parent: ProviderScope.containerOf(context),
        child: const JournalFlow(),
      ),
    ).then((_) {
      ref.invalidate(journalConsistencyProvider(30));
      ref.invalidate(apexStateProvider);
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Loading shimmer
// ─────────────────────────────────────────────────────────────────────────────

class _AimShimmer extends StatelessWidget {
  const _AimShimmer();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const ApexShimmerBox(height: 160),
        const SizedBox(height: 16),
        const ApexShimmerBox(height: 80),
        const SizedBox(height: 16),
        const ApexShimmerBox(height: 220),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Cinematic onboarding — no goal set
// ─────────────────────────────────────────────────────────────────────────────

class _AimOnboarding extends StatelessWidget {
  const _AimOnboarding({required this.onEnterApex});
  final VoidCallback onEnterApex;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Decorative background elements
        Positioned(
          top: -100,
          right: -100,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: ApexColors.accentAim.withValues(alpha: 0.05),
            ),
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  const ApexLiveDot(color: ApexColors.accentAim, size: 8),
                  const SizedBox(width: 12),
                  Text('SYSTEM READY // OPTIMIZING PERFORMANCE',
                      style: TextStyle(
                          color: ApexColors.accentAim.withValues(alpha: 0.7),
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 2)),
                ]),
                const Spacer(),
                const Text('ASCEND\nTO YOUR\nAPEX',
                    style: TextStyle(
                      color: ApexColors.textPrimary,
                      fontSize: 64,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -4,
                      height: 0.85,
                    )),
                const SizedBox(height: 24),
                Container(
                  width: 40,
                  height: 2,
                  color: ApexColors.accentAim,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Transform your game with elite-level tracking, mission-driven focus, and systematic performance growth.',
                  style: TextStyle(
                      color: ApexColors.textMuted,
                      fontSize: 18,
                      height: 1.5,
                      fontWeight: FontWeight.w400),
                ),
                const SizedBox(height: 48),
                _FeatureLinePremium(
                    number: '01',
                    label: 'IDENTITY',
                    detail: 'Define your elite playing style'),
                const SizedBox(height: 24),
                _FeatureLinePremium(
                    number: '02',
                    label: 'MISSION',
                    detail: 'Set high-performance objectives'),
                const SizedBox(height: 24),
                _FeatureLinePremium(
                    number: '03',
                    label: 'EXECUTION',
                    detail: 'Follow a professional routine'),
                const Spacer(flex: 2),
                GestureDetector(
                  onTap: () {
                    HapticFeedback.heavyImpact();
                    onEnterApex();
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 22),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          ApexColors.accentAim,
                          ApexColors.accentAim.withValues(alpha: 0.8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: ApexColors.accentAim.withValues(alpha: 0.3),
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text('INITIALIZE MISSION',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 3,
                          )),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _FeatureLinePremium extends StatelessWidget {
  const _FeatureLinePremium(
      {required this.number, required this.label, required this.detail});
  final String number, label, detail;

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: ApexColors.surfaceHigh,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: ApexColors.border),
        ),
        child: Center(
          child: Text(number,
              style: const TextStyle(
                  color: ApexColors.accentAim,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5)),
        ),
      ),
      const SizedBox(width: 16),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label,
            style: const TextStyle(
                color: ApexColors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.5)),
        const SizedBox(height: 2),
        Text(detail,
            style: const TextStyle(
                color: ApexColors.textMuted,
                fontSize: 13,
                fontWeight: FontWeight.w400)),
      ]),
    ]);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Aim Command Center — goal is set
// ─────────────────────────────────────────────────────────────────────────────

class _AimCommandCenter extends ConsumerWidget {
  const _AimCommandCenter({
    required this.onSetupMission,
    required this.onJournal,
  });
  final VoidCallback onSetupMission;
  final VoidCallback onJournal;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final planAsync = ref.watch(weeklyPlanProvider);
    final profileAsync = ref.watch(eliteProfileProvider);
    final fullProfile = ref.watch(profileControllerProvider).data;

    final identity = fullProfile?.identity;
    final editable = fullProfile?.editableProfile;

    // ── Profile gate flags ─────────────────────────────────────────────────
    final hasName = (identity?.fullName.trim().isNotEmpty ?? false);
    final hasRole = (identity?.primaryRole.trim().isNotEmpty ?? false);
    final hasCity = (identity?.city.trim().isNotEmpty ?? false);
    final hasLevel = (identity?.level.trim().isNotEmpty ?? false);
    final hasDob = ((editable?.dateOfBirth ?? '').trim().isNotEmpty);

    final isProfileComplete = hasName && hasRole && hasCity && hasLevel && hasDob;

    final missingFields = <String>[
      if (!hasName) 'Full Name',
      if (!hasRole) 'Primary Role',
      if (!hasCity) 'City',
      if (!hasLevel) 'Player Level',
      if (!hasDob) 'Date of Birth',
    ];

    return Scaffold(
      backgroundColor: ApexColors.background,
      floatingActionButton: isProfileComplete ? _LogTodayFab(onTap: onJournal) : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: RefreshIndicator(
        color: ApexColors.accentAim,
        backgroundColor: ApexColors.surface,
        onRefresh: () async {
          ref.invalidate(eliteProfileProvider);
          ref.invalidate(weeklyPlanProvider);
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            const SliverToBoxAdapter(child: SizedBox(height: 8)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    profileAsync.when(
                      loading: () => const ApexShimmerBox(height: 80),
                      error: (_, __) => const SizedBox.shrink(),
                      data: (profile) {
                        final isAimDone =
                            profile.goal?.targetRole.trim().isNotEmpty ?? false;

                        return Column(
                          children: [
                            _AimProfileTopCard(
                              avatarUrl: identity?.avatarUrl,
                              name: (identity?.fullName ?? '').trim(),
                              role: (identity?.primaryRole ?? '').trim(),
                              city: (identity?.city ?? '').trim(),
                              level: (identity?.level ?? '').trim(),
                              battingStyle: (identity?.battingStyle ?? '').trim(),
                              bowlingStyle: (identity?.bowlingStyle ?? '').trim(),
                              gender: (editable?.gender ?? '').trim(),
                              dateOfBirth: editable?.dateOfBirth,
                              isComplete: isProfileComplete,
                              missingFields: missingFields,
                              onEditTap: () async {
                                if (fullProfile == null) return;
                                await Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                    builder: (_) =>
                                        EditProfileScreen(data: fullProfile),
                                  ),
                                );
                                ref.invalidate(profileControllerProvider);
                                ref.invalidate(eliteProfileProvider);
                                ref.invalidate(apexStateProvider);
                              },
                            ),
                            if (isProfileComplete) ...[
                              const SizedBox(height: 10),
                              _AmbitionPlanCard(
                                goal: profile.goal,
                                onEditTap: onSetupMission,
                              ),
                              if (!isAimDone) ...[
                                const SizedBox(height: 12),
                                _SetMissionCta(onTap: onSetupMission),
                              ],
                            ],
                          ],
                        );
                      },
                    ),
                    // Weekly plan gated behind profile + aim
                    Builder(builder: (context) {
                      final profile = profileAsync.asData?.value;
                      final isAimDone =
                          profile?.goal?.targetRole.trim().isNotEmpty ?? false;
                      if (!isProfileComplete || !isAimDone) {
                        return const SizedBox.shrink();
                      }
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 32),
                          planAsync.when(
                            loading: () => const ApexShimmerBox(height: 300),
                            error: (_, __) => _TrainingPlanCard(
                              plan: null,
                              onRefresh: () => ref.invalidate(weeklyPlanProvider),
                            ),
                            data: (plan) => _TrainingPlanPremium(
                              plan: plan,
                              onRefresh: () => ref.invalidate(weeklyPlanProvider),
                            ),
                          ),
                        ],
                      );
                    }),
                    const SizedBox(height: 140),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AimProfileTopCard extends StatelessWidget {
  const _AimProfileTopCard({
    required this.avatarUrl,
    required this.name,
    required this.role,
    required this.city,
    required this.level,
    required this.battingStyle,
    required this.bowlingStyle,
    required this.gender,
    required this.dateOfBirth,
    required this.isComplete,
    required this.missingFields,
    required this.onEditTap,
  });

  final String? avatarUrl;
  final String name;
  final String role;
  final String city;
  final String level;
  final String battingStyle;
  final String bowlingStyle;
  final String gender;
  final String? dateOfBirth;
  final bool isComplete;
  final List<String> missingFields;
  final VoidCallback onEditTap;

  String _ageLabel() {
    final dob = (dateOfBirth ?? '').trim();
    if (dob.isEmpty) return '';
    final parsed = DateTime.tryParse(dob);
    if (parsed == null) return '';
    final now = DateTime.now();
    var years = now.year - parsed.year;
    final hadBirthday = now.month > parsed.month ||
        (now.month == parsed.month && now.day >= parsed.day);
    if (!hadBirthday) years -= 1;
    if (years < 0 || years > 100) return '';
    return '$years yrs';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final primaryMeta =
        [if (role.isNotEmpty) role, if (city.isNotEmpty) city].join(' • ');
    final ageLabel = _ageLabel();
    final meta2 = [
      if (level.isNotEmpty) level,
      if (gender.isNotEmpty) gender,
      if (ageLabel.isNotEmpty) ageLabel,
    ].join(' • ');
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.45)),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            cs.surfaceContainerHighest.withValues(alpha: 0.95),
            cs.surfaceContainer.withValues(alpha: 0.96),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'PROFILE',
                style: TextStyle(
                  color: cs.onSurfaceVariant,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: isComplete
                      ? Colors.green.withValues(alpha: 0.12)
                      : cs.tertiaryContainer.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: isComplete
                        ? Colors.green.withValues(alpha: 0.28)
                        : cs.outlineVariant.withValues(alpha: 0.35),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isComplete
                          ? Icons.check_circle_rounded
                          : Icons.pending_rounded,
                      size: 14,
                      color: isComplete ? Colors.green : cs.onTertiaryContainer,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      isComplete ? 'Completed' : 'Pending',
                      style: TextStyle(
                        color:
                            isComplete ? Colors.green : cs.onTertiaryContainer,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onEditTap,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: cs.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: cs.outlineVariant.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Icon(
                      Icons.arrow_outward_rounded,
                      size: 18,
                      color: cs.onSurface,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: cs.outlineVariant.withValues(alpha: 0.35),
                  ),
                ),
                child: CircleAvatar(
                  radius: 30,
                  backgroundColor: cs.surfaceContainerHighest,
                  backgroundImage: (avatarUrl ?? '').trim().isNotEmpty
                      ? CachedNetworkImageProvider(avatarUrl!)
                      : null,
                  child: (avatarUrl ?? '').trim().isEmpty
                      ? Icon(
                          Icons.person_rounded,
                          color: cs.onSurfaceVariant,
                          size: 28,
                        )
                      : null,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name.isEmpty ? 'Player Profile' : name,
                      style: TextStyle(
                        color: cs.onSurface,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        height: 1.05,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      primaryMeta.isEmpty ? 'Add role and city' : primaryMeta,
                      style: TextStyle(
                        color: cs.onSurfaceVariant,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (meta2.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: meta2
                            .split(' • ')
                            .where((e) => e.trim().isNotEmpty)
                            .map(
                              (item) => Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: cs.surface,
                                  borderRadius: BorderRadius.circular(999),
                                  border: Border.all(
                                    color:
                                        cs.outlineVariant.withValues(alpha: 0.35),
                                  ),
                                ),
                                child: Text(
                                  item,
                                  style: TextStyle(
                                    color: cs.onSurface,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _ProfileInfoPane(
                  label: 'Batting Style',
                  value: battingStyle.isEmpty ? 'Not added' : battingStyle,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ProfileInfoPane(
                  label: 'Bowling Style',
                  value: bowlingStyle.isEmpty ? 'Not added' : bowlingStyle,
                ),
              ),
            ],
          ),
          // Missing fields banner
          if (!isComplete && missingFields.isNotEmpty) ...[
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFE65100).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFE65100).withValues(alpha: 0.25),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.info_outline_rounded,
                          size: 13, color: Color(0xFFFF8A50)),
                      SizedBox(width: 6),
                      Text(
                        'COMPLETE YOUR PROFILE TO UNLOCK APEX',
                        style: TextStyle(
                          color: Color(0xFFFF8A50),
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: missingFields
                        .map((f) => Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 9, vertical: 5),
                              decoration: BoxDecoration(
                                color:
                                    const Color(0xFFE65100).withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: const Color(0xFFE65100)
                                      .withValues(alpha: 0.3),
                                ),
                              ),
                              child: Text(
                                f,
                                style: const TextStyle(
                                  color: Color(0xFFFF8A50),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ProfileInfoPane extends StatelessWidget {
  const _ProfileInfoPane({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.32)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: cs.onSurfaceVariant,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: cs.onSurface,
              fontSize: 13,
              fontWeight: FontWeight.w800,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _AmbitionPlanCard extends StatelessWidget {
  const _AmbitionPlanCard({
    required this.goal,
    required this.onEditTap,
  });

  final ApexGoal? goal;
  final VoidCallback onEditTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.45)),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            cs.surfaceContainer.withValues(alpha: 0.98),
            cs.surfaceContainerHighest.withValues(alpha: 0.96),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'AMBITION PLAN',
                style: TextStyle(
                  color: cs.onSurfaceVariant,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                ),
              ),
              const Spacer(),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onEditTap,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: cs.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: cs.outlineVariant.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Icon(
                      Icons.edit_rounded,
                      size: 18,
                      color: cs.onSurface,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _AmbitionInfoPill(
                label: 'Target Role',
                value: _goalValue(goal?.targetRole),
              ),
              _AmbitionInfoPill(
                label: 'Target Format',
                value: _goalValue(goal?.targetFormat),
              ),
              _AmbitionInfoPill(
                label: 'Style Identity',
                value: _goalValue(goal?.styleIdentity),
              ),
              _AmbitionInfoPill(
                label: 'Target Level',
                value: _goalValue(goal?.targetLevel),
              ),
              _AmbitionInfoPill(
                label: 'Timeline',
                value: _goalValue(goal?.timeline),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.32)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Commitment Statement',
                  style: TextStyle(
                    color: cs.onSurfaceVariant,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _goalValue(goal?.commitmentStatement),
                  style: TextStyle(
                    color: cs.onSurface,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AmbitionInfoPill extends StatelessWidget {
  const _AmbitionInfoPill({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      constraints: const BoxConstraints(minWidth: 140),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.32)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              color: cs.onSurfaceVariant,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.7,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: TextStyle(
              color: cs.onSurface,
              fontSize: 13,
              fontWeight: FontWeight.w800,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

String _goalValue(String? value) {
  final trimmed = (value ?? '').trim();
  return trimmed.isEmpty ? 'Not set' : trimmed;
}

// ─────────────────────────────────────────────────────────────────────────────
//  Set Mission CTA — shown when profile is done but AIM not set
// ─────────────────────────────────────────────────────────────────────────────

class _SetMissionCta extends StatelessWidget {
  const _SetMissionCta({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        onTap();
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              ApexColors.accentAim.withValues(alpha: 0.15),
              ApexColors.accentAim.withValues(alpha: 0.06),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: ApexColors.accentAim.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: ApexColors.accentAim.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: ApexColors.accentAim.withValues(alpha: 0.3),
                ),
              ),
              child: const Icon(
                Icons.flag_rounded,
                color: ApexColors.accentAim,
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'SET YOUR MISSION',
                    style: TextStyle(
                      color: ApexColors.accentAim,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Define your target role, level, and timeline to unlock Progress & Evaluate.',
                    style: TextStyle(
                      color: ApexColors.textMuted,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: ApexColors.accentAim,
              size: 14,
            ),
          ],
        ),
      ),
    );
  }
}

class _MissionStatusHeader extends StatelessWidget {
  const _MissionStatusHeader({required this.goal, required this.onEdit});
  final ApexGoal? goal;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            ApexColors.surfaceHigh,
            ApexColors.surface,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: ApexColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(goal?.targetRole.toUpperCase() ?? 'NO ROLE',
                        style: const TextStyle(
                            color: ApexColors.accentAim,
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.5)),
                    const SizedBox(height: 4),
                    Text(goal?.targetLevel ?? 'Aspirant',
                        style: const TextStyle(
                            color: ApexColors.textPrimary,
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5)),
                  ],
                ),
              ),
              GestureDetector(
                onTap: onEdit,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: ApexColors.background,
                    shape: BoxShape.circle,
                    border: Border.all(color: ApexColors.border),
                  ),
                  child: const Icon(Icons.settings_input_component_rounded,
                      color: ApexColors.textMuted, size: 18),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              _StatusMiniItem(
                  label: 'TIMELINE', value: goal?.timeline ?? '--'),
              const SizedBox(width: 32),
              _StatusMiniItem(
                  label: 'FORMAT', value: goal?.targetFormat ?? '--'),
              const SizedBox(width: 32),
              _StatusMiniItem(
                  label: 'DAYS/WK', value: '${goal?.trainingDaysPerWeek ?? '--'}'),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusMiniItem extends StatelessWidget {
  const _StatusMiniItem({required this.label, required this.value});
  final String label, value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: ApexTextStyles.labelCaps.copyWith(fontSize: 8)),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(
                color: ApexColors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w700)),
      ],
    );
  }
}

Map<String, dynamic> _asStringMap(dynamic value) =>
    value is Map ? Map<String, dynamic>.from(value) : <String, dynamic>{};

class _StepStatTag extends StatelessWidget {
  const _StepStatTag({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.28)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _MissionGoalStep2Screen extends ConsumerStatefulWidget {
  const _MissionGoalStep2Screen({this.existing});
  final ApexGoal? existing;

  @override
  ConsumerState<_MissionGoalStep2Screen> createState() =>
      _MissionGoalStep2ScreenState();
}

class _MissionGoalStep2ScreenState
    extends ConsumerState<_MissionGoalStep2Screen> {
  static const _roleOptions = [
    'Batting',
    'Bowling',
    'All Rounder',
    'WK-Batsman',
  ];
  static const _formatOptions = ['T20', 'Days', 'All Format'];
  static const _styleOptions = ['Aggressive', 'Balanced', 'Consistency'];
  static const _levelOptions = [
    'Division',
    'State',
    'IPL',
    'International',
    'Corporate',
  ];
  static const _timelineOptions = ['3', '6', '12', '18', '24'];

  String? _targetRole;
  String? _targetFormat;
  String? _styleIdentity;
  String? _targetLevel;
  String? _timeline;
  bool _saving = false;

  late final PageController _pageController;

  int _activeStep = 0;
  static const _stepCount = 5;

  int get _filledCount =>
      [_targetRole, _targetFormat, _styleIdentity, _targetLevel, _timeline]
          .whereType<String>()
          .where((v) => v.trim().isNotEmpty)
          .length;

  void _openStep(int step) {
    if (step == _activeStep) return;
    setState(() => _activeStep = step);
    _pageController.animateToPage(
      step,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutQuart,
    );
  }

  void _setRole(String value) {
    setState(() => _targetRole = value);
    Future.delayed(const Duration(milliseconds: 200), () => _openStep(_nextOpenStep()));
  }

  void _setFormat(String value) {
    setState(() => _targetFormat = value);
    Future.delayed(const Duration(milliseconds: 200), () => _openStep(_nextOpenStep()));
  }

  void _setStyle(String value) {
    setState(() => _styleIdentity = value);
    Future.delayed(const Duration(milliseconds: 200), () => _openStep(_nextOpenStep()));
  }

  void _setLevel(String value) {
    setState(() => _targetLevel = value);
    Future.delayed(const Duration(milliseconds: 200), () => _openStep(_nextOpenStep()));
  }

  int _nextOpenStep() {
    if (_targetRole == null) return 0;
    if (_targetFormat == null) return 1;
    if (_styleIdentity == null) return 2;
    if (_targetLevel == null) return 3;
    if (_timeline == null) return 4;
    return 4;
  }

  int get _timelineIndex {
    if (_timeline == null) return 0;
    final idx = _timelineOptions.indexOf(_timeline!);
    return idx < 0 ? 0 : idx;
  }

  @override
  void initState() {
    super.initState();
    final g = widget.existing;
    if (g != null) {
      _targetRole = g.targetRole.isNotEmpty ? g.targetRole : null;
      _targetFormat = g.targetFormat.isNotEmpty ? g.targetFormat : null;
      _styleIdentity = g.styleIdentity.isNotEmpty ? g.styleIdentity : null;
      _targetLevel = g.targetLevel.isNotEmpty ? g.targetLevel : null;
      _timeline = g.timeline.isNotEmpty ? g.timeline : null;
    }
    _activeStep = _nextOpenStep();
    _pageController = PageController(initialPage: _activeStep);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_targetRole == null ||
        _targetFormat == null ||
        _styleIdentity == null ||
        _targetLevel == null ||
        _timeline == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all required fields')),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      final goal = ApexGoal(
        targetRole: _targetRole!,
        targetFormat: _targetFormat!,
        styleIdentity: _styleIdentity!,
        targetLevel: _targetLevel!,
        timeline: _timeline!,
        focusAreas: widget.existing?.focusAreas ?? const [],
        selfAssessment: widget.existing?.selfAssessment ?? const {},
        commitmentStatement: widget.existing?.commitmentStatement ?? '',
        gender: widget.existing?.gender,
        weightKg: widget.existing?.weightKg,
        heightCm: widget.existing?.heightCm,
        targetWeight: widget.existing?.targetWeight,
        waistCm: widget.existing?.waistCm,
        neckCm: widget.existing?.neckCm,
        hipCm: widget.existing?.hipCm,
        bodyTransformDirection: widget.existing?.bodyTransformDirection,
        trainingDaysPerWeek: widget.existing?.trainingDaysPerWeek,
        fitnessFocuses: widget.existing?.fitnessFocuses ?? const [],
        nutritionObjective: widget.existing?.nutritionObjective,
        dailySleepHoursGoal: widget.existing?.dailySleepHoursGoal,
        dailyHydrationLitresGoal: widget.existing?.dailyHydrationLitresGoal,
        habitsToQuit: widget.existing?.habitsToQuit ?? const [],
        disciplineGoals: widget.existing?.disciplineGoals ?? const [],
      );
      final ok = await ref.read(apexGoalControllerProvider.notifier).save(goal);
      if (!mounted) return;
      if (ok) {
        ref.invalidate(eliteProfileProvider);
        ref.invalidate(apexStateProvider);
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save mission goal')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isComplete = _filledCount == 5;

    final steps = [
      _MissionStepData(
        title: 'Target role',
        subtitle: 'What is your primary focus on the field?',
        options: _roleOptions,
        selected: _targetRole,
        onSelect: _setRole,
      ),
      _MissionStepData(
        title: 'Target format',
        subtitle: 'Which version of the game do you want to master?',
        options: _formatOptions,
        selected: _targetFormat,
        onSelect: _setFormat,
      ),
      _MissionStepData(
        title: 'Style identity',
        subtitle: 'How do you approach your game?',
        options: _styleOptions,
        selected: _styleIdentity,
        onSelect: _setStyle,
      ),
      _MissionStepData(
        title: 'Target level',
        subtitle: 'Where do you see yourself playing?',
        options: _levelOptions,
        selected: _targetLevel,
        onSelect: _setLevel,
      ),
      _MissionStepData(
        title: 'Timeline',
        subtitle: 'How soon do you want to reach your goal?',
        isTimeline: true,
      ),
    ];

    return Scaffold(
      backgroundColor: ApexColors.background,
      appBar: AppBar(
        backgroundColor: ApexColors.background,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'AMBITION',
          style: TextStyle(
            letterSpacing: 2,
            fontWeight: FontWeight.w900,
            fontSize: 14,
          ),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),
          _MissionStageTracker(
            activeStep: _activeStep,
            onStepTap: (step) {
              // Only allow tapping steps that are already filled or the next one
              if (step <= _filledCount) {
                _openStep(step);
              }
            },
          ),
          const SizedBox(height: 24),
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: steps.length,
              itemBuilder: (context, index) {
                final step = steps[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'STEP ${index + 1}',
                        style: TextStyle(
                          color: cs.primary,
                          fontWeight: FontWeight.w900,
                          fontSize: 12,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        step.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 28,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        step.subtitle,
                        style: TextStyle(
                          color: cs.onSurfaceVariant,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 32),
                      if (step.isTimeline)
                        _TimelinePicker(
                          selected: _timeline,
                          options: _timelineOptions,
                          onChanged: (val) {
                            setState(() {
                              _timeline = val;
                            });
                          },
                        )
                      else
                        Expanded(
                          child: ListView.separated(
                            itemCount: step.options.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 12),
                            itemBuilder: (context, optIdx) {
                              final option = step.options[optIdx];
                              return _ModernChoiceCard(
                                label: option,
                                isSelected: option == step.selected,
                                onTap: () => step.onSelect!(option),
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
          SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
              child: Row(
                children: [
                  if (_activeStep > 0)
                    Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: IconButton.filledTonal(
                        onPressed: () => _openStep(_activeStep - 1),
                        style: IconButton.styleFrom(
                          padding: const EdgeInsets.all(16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                      ),
                    ),
                  Expanded(
                    child: FilledButton(
                      onPressed: _saving || !isComplete ? null : _save,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        backgroundColor: cs.primary,
                        foregroundColor: cs.onPrimary,
                        disabledBackgroundColor: cs.surfaceContainerHigh,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: _saving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              isComplete ? 'LOCK IN AMBITION' : 'COMPLETE ALL STEPS',
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 15,
                                letterSpacing: 0.5,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MissionStepData {
  final String title;
  final String subtitle;
  final List<String> options;
  final String? selected;
  final ValueChanged<String>? onSelect;
  final bool isTimeline;

  _MissionStepData({
    required this.title,
    required this.subtitle,
    this.options = const [],
    this.selected,
    this.onSelect,
    this.isTimeline = false,
  });
}

class _MissionStageTracker extends StatelessWidget {
  const _MissionStageTracker({
    required this.activeStep,
    required this.onStepTap,
  });

  final int activeStep;
  final ValueChanged<int> onStepTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(5, (index) {
          final isCompleted = index < activeStep;
          final isActive = index == activeStep;

          return Expanded(
            child: GestureDetector(
              onTap: () => onStepTap(index),
              behavior: HitTestBehavior.opaque,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 2,
                          color: index == 0
                              ? Colors.transparent
                              : (isCompleted || isActive
                                  ? cs.primary
                                  : cs.surfaceContainerHigh),
                        ),
                      ),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: isCompleted
                              ? cs.primary
                              : (isActive ? cs.primary : cs.surfaceContainerHigh),
                          shape: BoxShape.circle,
                          border: isActive
                              ? Border.all(color: cs.primary, width: 2)
                              : null,
                          boxShadow: isActive
                              ? [
                                  BoxShadow(
                                    color: cs.primary.withValues(alpha: 0.4),
                                    blurRadius: 10,
                                    spreadRadius: 2,
                                  )
                                ]
                              : null,
                        ),
                        child: Center(
                          child: isCompleted
                              ? const Icon(Icons.check_rounded,
                                  size: 18, color: Colors.black)
                              : Text(
                                  '${index + 1}',
                                  style: TextStyle(
                                    color: isActive ? Colors.black : cs.onSurfaceVariant,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          height: 2,
                          color: index == 4
                              ? Colors.transparent
                              : (isCompleted ? cs.primary : cs.surfaceContainerHigh),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    ['Role', 'Format', 'Style', 'Level', 'Time'][index],
                    style: TextStyle(
                      color: isActive ? cs.primary : cs.onSurfaceVariant,
                      fontSize: 10,
                      fontWeight: isActive ? FontWeight.w900 : FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _ModernChoiceCard extends StatelessWidget {
  const _ModernChoiceCard({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 240),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          decoration: BoxDecoration(
            color: isSelected ? cs.primary : cs.surfaceContainerHigh.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? cs.primary : cs.outlineVariant.withValues(alpha: 0.2),
              width: 1.5,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: cs.primary.withValues(alpha: 0.25),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    )
                  ]
                : null,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label.toUpperCase(),
                  style: TextStyle(
                    color: isSelected ? Colors.black : Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
                ),
              ),
              if (isSelected)
                const Icon(Icons.check_circle_rounded, color: Colors.black, size: 24)
              else
                Icon(Icons.add_circle_outline_rounded,
                    color: cs.onSurfaceVariant.withValues(alpha: 0.5), size: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _TimelinePicker extends StatelessWidget {
  const _TimelinePicker({
    required this.selected,
    required this.options,
    required this.onChanged,
  });

  final String? selected;
  final List<String> options;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 2.2,
          ),
          itemCount: options.length,
          itemBuilder: (context, index) {
            final option = options[index];
            final isSelected = option == selected;
            return Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  HapticFeedback.mediumImpact();
                  onChanged(option);
                },
                borderRadius: BorderRadius.circular(16),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 240),
                  decoration: BoxDecoration(
                    color: isSelected ? cs.primary : cs.surfaceContainerHigh.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? cs.primary : cs.outlineVariant.withValues(alpha: 0.2),
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          option,
                          style: TextStyle(
                            color: isSelected ? Colors.black : Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          'MONTHS',
                          style: TextStyle(
                            color: isSelected ? Colors.black.withValues(alpha: 0.7) : cs.onSurfaceVariant,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

// ── Card 2: Weekly Training Plan (inline editable) ────────────────────────────

class _TrainingPlanPremium extends ConsumerStatefulWidget {
  const _TrainingPlanPremium({required this.plan, required this.onRefresh});
  final WeeklyPlan? plan;
  final VoidCallback onRefresh;

  @override
  ConsumerState<_TrainingPlanPremium> createState() =>
      _TrainingPlanPremiumState();
}

class _TrainingPlanPremiumState extends ConsumerState<_TrainingPlanPremium> {
  static const _kWeekdays = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
  bool _saving = false;

  _PlanEditorModel _modelFromPlan(WeeklyPlan? plan) {
    final days = plan?.days ?? WeeklyPlan.empty().days;
    final activityDays = <String, Set<int>>{
      for (final act in _activityDefs) act.key: <int>{},
    };
    final activityMinutes = <String, int>{
      for (final act in _activityDefs) act.key: act.defaultMinutes,
    };

    bool activeFor(WeeklyPlanDay d, String key) {
      switch (key) {
        case 'NETS': return d.hasNets || d.netsMinutes > 0;
        case 'DRILLS': return d.hasSkillWork || d.drillsMinutes > 0;
        case 'GYM': return d.hasGym || d.fitnessMinutes > 0;
        case 'CONDITIONING': return d.hasConditioning || d.fitnessMinutes > 0;
        case 'MATCH': return d.hasMatch || d.drillsMinutes > 0;
        case 'RECOVERY': return d.hasRecovery || d.recoveryMinutes > 0;
      }
      return false;
    }

    int minutesFor(WeeklyPlanDay d, String key) {
      switch (key) {
        case 'NETS': return d.netsMinutes;
        case 'DRILLS': case 'MATCH': return d.drillsMinutes;
        case 'GYM': case 'CONDITIONING': return d.fitnessMinutes;
        case 'RECOVERY': return d.recoveryMinutes;
      }
      return 0;
    }

    for (var i = 0; i < days.length; i++) {
      final day = days[i];
      for (final act in _activityDefs) {
        if (!activeFor(day, act.key)) continue;
        activityDays[act.key]!.add(i + 1);
        final mins = minutesFor(day, act.key);
        if (mins > 0) activityMinutes[act.key] = mins;
      }
    }

    return _PlanEditorModel(
      selectedDays: activityDays,
      activityMinutes: activityMinutes,
      sleepTarget: days.isNotEmpty ? days.first.sleepTargetHours : 8.0,
      hydrationTarget: days.isNotEmpty ? days.first.hydrationTargetLiters : 4.0,
    );
  }

  List<WeeklyPlanDay> _daysFromModel(_PlanEditorModel model) {
    final built = List.generate(
      7,
      (i) => WeeklyPlanDay(
        weekday: _kWeekdays[i],
        sleepTargetHours: model.sleepTarget,
        hydrationTargetLiters: model.hydrationTarget,
      ),
    );
    for (final act in _activityDefs) {
      final mins = model.activityMinutes[act.key] ?? act.defaultMinutes;
      for (final dayNum in model.selectedDays[act.key] ?? const <int>{}) {
        final idx = dayNum - 1;
        if (idx < 0 || idx >= built.length) continue;
        final day = built[idx];
        switch (act.key) {
          case 'NETS':
            built[idx] = day.copyWith(netsMinutes: day.netsMinutes + mins, hasNets: true);
            break;
          case 'DRILLS':
            built[idx] = day.copyWith(drillsMinutes: day.drillsMinutes + mins, hasSkillWork: true);
            break;
          case 'GYM':
            built[idx] = day.copyWith(fitnessMinutes: day.fitnessMinutes + mins, hasGym: true);
            break;
          case 'CONDITIONING':
            built[idx] = day.copyWith(fitnessMinutes: day.fitnessMinutes + mins, hasConditioning: true);
            break;
          case 'MATCH':
            built[idx] = day.copyWith(drillsMinutes: day.drillsMinutes + mins, hasMatch: true);
            break;
          case 'RECOVERY':
            built[idx] = day.copyWith(recoveryMinutes: day.recoveryMinutes + mins, hasRecovery: true);
            break;
        }
      }
    }
    return built;
  }

  Future<void> _openEditor() async {
    final initial = _modelFromPlan(widget.plan);
    final edited = await showModalBottomSheet<_PlanEditorModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _WeeklyPlanEditorSheet(
        initial: initial,
        activities: _activityDefs,
      ),
    );
    if (!mounted || edited == null) return;
    setState(() => _saving = true);
    final existing = widget.plan;
    final updated = (existing ?? WeeklyPlan.empty()).copyWith(
      name: 'My Weekly Plan',
      isActive: true,
      days: _daysFromModel(edited),
    );
    final ctrl = ref.read(weeklyPlanSaveControllerProvider.notifier);
    final ok = existing != null
        ? await ctrl.update(updated)
        : await ctrl.create(updated);
    if (!mounted) return;
    setState(() => _saving = false);
    if (ok) {
      widget.onRefresh();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save plan')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final plan = widget.plan;
    final hasPlan = plan != null && plan.days.isNotEmpty;
    final todayAbbr = _kWeekdays[DateTime.now().weekday - 1];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header with edit button
        Row(
          children: [
            const Text(
              'WEEKLY PLAN',
              style: TextStyle(
                color: ApexColors.textPrimary,
                fontSize: 11,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: _saving ? null : () => _openEditor(),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: ApexColors.surface,
                  borderRadius: BorderRadius.circular(7),
                  border: Border.all(color: ApexColors.border, width: 0.5),
                ),
                child: _saving
                    ? const SizedBox(
                        width: 12, height: 12,
                        child: CircularProgressIndicator(
                            strokeWidth: 1.5, color: ApexColors.textMuted),
                      )
                    : Row(mainAxisSize: MainAxisSize.min, children: const [
                        Icon(Icons.edit_rounded,
                            size: 11, color: ApexColors.textMuted),
                        SizedBox(width: 5),
                        Text('Edit',
                            style: TextStyle(
                                color: ApexColors.textMuted,
                                fontSize: 11, fontWeight: FontWeight.w700)),
                      ]),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        if (!hasPlan) ...[
          // Empty state
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 32),
            decoration: BoxDecoration(
              color: ApexColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: ApexColors.border, width: 0.5),
            ),
            child: Column(children: [
              const Icon(Icons.calendar_today_rounded,
                  color: ApexColors.textDim, size: 28),
              const SizedBox(height: 12),
              const Text('No weekly plan yet',
                  style: TextStyle(
                      color: ApexColors.textMuted, fontSize: 13,
                      fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              const Text('Tap Edit to create your training week',
                  style: TextStyle(color: ApexColors.textDim, fontSize: 11)),
            ]),
          ),
        ] else ...[
          // Wellness targets row
          Row(children: [
            _WellnessBadge(
              icon: Icons.bedtime_rounded,
              label: 'Sleep',
              value: '${plan.days.first.sleepTargetHours.toStringAsFixed(1)}h',
            ),
            const SizedBox(width: 8),
            _WellnessBadge(
              icon: Icons.water_drop_rounded,
              label: 'Water',
              value: '${plan.days.first.hydrationTargetLiters.toStringAsFixed(1)}L',
            ),
          ]),
          const SizedBox(height: 14),

          // Day-by-day list
          ...plan.days.map((day) {
            final isToday = day.weekday == todayAbbr;
            final activities = _dayActivities(day);
            final isRest = activities.isEmpty;
            return _PlanDayRow(
              day: day,
              activities: activities,
              isToday: isToday,
              isRest: isRest,
            );
          }),
        ],
      ],
    );
  }

  List<String> _dayActivities(WeeklyPlanDay day) {
    final list = <String>[];
    if (day.hasNets || day.netsMinutes > 0) list.add('Nets');
    if (day.hasGym || (day.fitnessMinutes > 0 && !day.hasConditioning)) list.add('Gym');
    if (day.hasConditioning) list.add('Cond.');
    if (day.hasSkillWork || day.drillsMinutes > 0) list.add('Drills');
    if (day.hasMatch) list.add('Match');
    if (day.hasRecovery || day.recoveryMinutes > 0) list.add('Recovery');
    return list;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Plan day row — clean day-by-day list
// ─────────────────────────────────────────────────────────────────────────────

class _PlanDayRow extends StatelessWidget {
  const _PlanDayRow({
    required this.day,
    required this.activities,
    required this.isToday,
    required this.isRest,
  });

  final WeeklyPlanDay day;
  final List<String> activities;
  final bool isToday;
  final bool isRest;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isToday ? ApexColors.surfaceHigh : ApexColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isToday ? ApexColors.borderMid : ApexColors.border,
          width: isToday ? 1 : 0.5,
        ),
      ),
      child: Row(children: [
        // Day label
        SizedBox(
          width: 40,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                day.weekday.substring(0, 3),
                style: TextStyle(
                  color: isToday ? ApexColors.textPrimary : ApexColors.textMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
              if (isToday)
                Container(
                  margin: const EdgeInsets.only(top: 3),
                  width: 18, height: 2,
                  decoration: BoxDecoration(
                    color: ApexColors.accentAim,
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        // Activities
        Expanded(
          child: isRest
              ? const Text('Rest',
                  style: TextStyle(
                      color: ApexColors.textDim,
                      fontSize: 12, fontStyle: FontStyle.italic))
              : Wrap(
                  spacing: 6, runSpacing: 4,
                  children: activities.map((a) => Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: ApexColors.background,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                          color: ApexColors.border, width: 0.5),
                    ),
                    child: Text(a,
                        style: const TextStyle(
                            color: ApexColors.textMuted,
                            fontSize: 10, fontWeight: FontWeight.w700)),
                  )).toList(),
                ),
        ),
        // Minutes
        if (!isRest)
          Text(
            _totalMins(),
            style: const TextStyle(
                color: ApexColors.textDim, fontSize: 10,
                fontWeight: FontWeight.w600),
          ),
      ]),
    );
  }

  String _totalMins() {
    final total = day.netsMinutes + day.drillsMinutes +
        day.fitnessMinutes + day.recoveryMinutes;
    if (total == 0) return '';
    return '${total}m';
  }
}

class _WellnessBadge extends StatelessWidget {
  const _WellnessBadge({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: ApexColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: ApexColors.border, width: 0.5),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 12, color: ApexColors.textDim),
        const SizedBox(width: 6),
        Text(label,
            style: const TextStyle(
                color: ApexColors.textDim,
                fontSize: 10, fontWeight: FontWeight.w600)),
        const SizedBox(width: 4),
        Text(value,
            style: const TextStyle(
                color: ApexColors.textPrimary,
                fontSize: 10, fontWeight: FontWeight.w800)),
      ]),
    );
  }
}

class _ActivityRowPremium extends StatelessWidget {
  const _ActivityRowPremium({required this.act, required this.plan});
  final _ActivityDef act;
  final WeeklyPlan plan;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Row(
              children: [
                Icon(act.icon, color: act.color, size: 14),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(act.label,
                      style: TextStyle(
                          color: act.color,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5)),
                ),
              ],
            ),
          ),
          ...List.generate(7, (i) {
            final day = plan.days[i];
            final active = _isActiveForActivity(day, act.key);
            return Expanded(
              child: Center(
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: active
                        ? act.color.withValues(alpha: 0.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: active
                          ? act.color.withValues(alpha: 0.4)
                          : ApexColors.border.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: active
                      ? Center(
                          child: Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: act.color,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: act.color.withValues(alpha: 0.5),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                          ),
                        )
                      : null,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  bool _isActiveForActivity(WeeklyPlanDay d, String key) {
    switch (key) {
      case 'NETS':
        return d.hasNets || d.netsMinutes > 0;
      case 'DRILLS':
        return d.hasSkillWork || d.drillsMinutes > 0;
      case 'GYM':
        return d.hasGym || d.fitnessMinutes > 0;
      case 'CONDITIONING':
        return d.hasConditioning || d.fitnessMinutes > 0;
      case 'MATCH':
        return d.hasMatch || d.drillsMinutes > 0;
      case 'RECOVERY':
        return d.hasRecovery || d.recoveryMinutes > 0;
    }
    return false;
  }
}

class _RecoveryMetricPremium extends StatelessWidget {
  const _RecoveryMetricPremium(
      {required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label, value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ApexColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ApexColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, color: ApexColors.textMuted, size: 18),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: ApexTextStyles.labelCaps.copyWith(fontSize: 8)),
              const SizedBox(height: 2),
              Text(value,
                  style: const TextStyle(
                      color: ApexColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w800)),
            ],
          ),
        ],
      ),
    );
  }
}
const _activityDefs = <_ActivityDef>[
    _ActivityDef(
      key: 'NETS',
      label: 'NETS',
      icon: Icons.sports_cricket_rounded,
      color: ApexColors.accentAim,
      defaultMinutes: 75,
    ),
    _ActivityDef(
      key: 'DRILLS',
      label: 'SKILL',
      icon: Icons.track_changes_rounded,
      color: ApexColors.accentProgress,
      defaultMinutes: 60,
    ),
    _ActivityDef(
      key: 'GYM',
      label: 'GYM',
      icon: Icons.fitness_center_rounded,
      color: ApexColors.accentEvaluate,
      defaultMinutes: 45,
    ),
    _ActivityDef(
      key: 'CONDITIONING',
      label: 'COND.',
      icon: Icons.directions_run_rounded,
      color: ApexColors.accentProgress,
      defaultMinutes: 30,
    ),
    _ActivityDef(
      key: 'MATCH',
      label: 'MATCH',
      icon: Icons.emoji_events_rounded,
      color: ApexColors.accentEvaluate,
      defaultMinutes: 120,
    ),
    _ActivityDef(
      key: 'RECOVERY',
      label: 'RECOVERY',
      icon: Icons.favorite_rounded,
      color: ApexColors.accentXlerate,
      defaultMinutes: 45,
    ),
  ];

class _TrainingPlanCard extends ConsumerStatefulWidget {
  const _TrainingPlanCard({required this.plan, required this.onRefresh});
  final WeeklyPlan? plan;
  final VoidCallback onRefresh;

  @override
  ConsumerState<_TrainingPlanCard> createState() => _TrainingPlanCardState();
}

class _TrainingPlanCardState extends ConsumerState<_TrainingPlanCard> {
  bool _saving = false;

  static const _kWeekdays = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
  _PlanEditorModel _modelFromPlan(WeeklyPlan? plan) {
    final days = plan?.days ?? WeeklyPlan.empty().days;
    final activityDays = <String, Set<int>>{
      for (final act in _activityDefs) act.key: <int>{},
    };
    final activityMinutes = <String, int>{
      for (final act in _activityDefs) act.key: act.defaultMinutes,
    };

    int minutesFor(WeeklyPlanDay d, String key) {
      switch (key) {
        case 'NETS':
          return d.netsMinutes;
        case 'DRILLS':
        case 'MATCH':
          return d.drillsMinutes;
        case 'GYM':
        case 'CONDITIONING':
          return d.fitnessMinutes;
        case 'RECOVERY':
          return d.recoveryMinutes;
      }
      return 0;
    }

    bool activeFor(WeeklyPlanDay d, String key) {
      switch (key) {
        case 'NETS':
          return d.hasNets || d.netsMinutes > 0;
        case 'DRILLS':
          return d.hasSkillWork || d.drillsMinutes > 0;
        case 'GYM':
          return d.hasGym || d.fitnessMinutes > 0;
        case 'CONDITIONING':
          return d.hasConditioning || d.fitnessMinutes > 0;
        case 'MATCH':
          return d.hasMatch || d.drillsMinutes > 0;
        case 'RECOVERY':
          return d.hasRecovery || d.recoveryMinutes > 0;
      }
      return false;
    }

    for (var i = 0; i < days.length; i++) {
      final day = days[i];
      final dayNumber = i + 1;
      for (final act in _activityDefs) {
        if (!activeFor(day, act.key)) continue;
        activityDays[act.key]!.add(dayNumber);
        final mins = minutesFor(day, act.key);
        if (mins > 0) activityMinutes[act.key] = mins;
      }
    }

    final sleepTarget = days.isNotEmpty ? days.first.sleepTargetHours : 8.0;
    final hydrationTarget =
        days.isNotEmpty ? days.first.hydrationTargetLiters : 4.0;

    return _PlanEditorModel(
      selectedDays: activityDays,
      activityMinutes: activityMinutes,
      sleepTarget: sleepTarget,
      hydrationTarget: hydrationTarget,
    );
  }

  List<WeeklyPlanDay> _daysFromModel(_PlanEditorModel model) {
    final built = List.generate(
      7,
      (i) => WeeklyPlanDay(
        weekday: _kWeekdays[i],
        sleepTargetHours: model.sleepTarget,
        hydrationTargetLiters: model.hydrationTarget,
      ),
    );

    for (final act in _activityDefs) {
      final mins = model.activityMinutes[act.key] ?? act.defaultMinutes;
      for (final dayNum in model.selectedDays[act.key] ?? const <int>{}) {
        final idx = dayNum - 1;
        if (idx < 0 || idx >= built.length) continue;
        final day = built[idx];
        switch (act.key) {
          case 'NETS':
            built[idx] =
                day.copyWith(netsMinutes: day.netsMinutes + mins, hasNets: true);
            break;
          case 'DRILLS':
            built[idx] = day.copyWith(
              drillsMinutes: day.drillsMinutes + mins,
              hasSkillWork: true,
            );
            break;
          case 'GYM':
            built[idx] = day.copyWith(
              fitnessMinutes: day.fitnessMinutes + mins,
              hasGym: true,
            );
            break;
          case 'CONDITIONING':
            built[idx] = day.copyWith(
              fitnessMinutes: day.fitnessMinutes + mins,
              hasConditioning: true,
            );
            break;
          case 'MATCH':
            built[idx] = day.copyWith(
              drillsMinutes: day.drillsMinutes + mins,
              hasMatch: true,
            );
            break;
          case 'RECOVERY':
            built[idx] = day.copyWith(
              recoveryMinutes: day.recoveryMinutes + mins,
              hasRecovery: true,
            );
            break;
        }
      }
    }

    return built;
  }

  Future<void> _openEditor() async {
    final initial = _modelFromPlan(widget.plan);
    final edited = await showModalBottomSheet<_PlanEditorModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _WeeklyPlanEditorSheet(
        initial: initial,
        activities: _activityDefs,
      ),
    );
    if (!mounted || edited == null) return;
    await _saveFromModel(edited);
  }

  Future<void> _saveFromModel(_PlanEditorModel model) async {
    setState(() => _saving = true);
    final existing = widget.plan;
    final updated = (existing ?? WeeklyPlan.empty()).copyWith(
      name: 'My Weekly Plan',
      isActive: true,
      days: _daysFromModel(model),
    );
    final ctrl = ref.read(weeklyPlanSaveControllerProvider.notifier);
    final ok = existing != null ? await ctrl.update(updated) : await ctrl.create(updated);
    if (!mounted) return;
    setState(() => _saving = false);
    if (ok) {
      widget.onRefresh();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save plan')),
      );
    }
  }

  int _countActiveDays(WeeklyPlan plan) {
    return plan.days.where((day) {
      return day.hasNets ||
          day.hasSkillWork ||
          day.hasGym ||
          day.hasConditioning ||
          day.hasMatch ||
          day.hasRecovery ||
          day.netsMinutes > 0 ||
          day.drillsMinutes > 0 ||
          day.fitnessMinutes > 0 ||
          day.recoveryMinutes > 0;
    }).length;
  }

  int _minutesForActivity(WeeklyPlanDay d, String key) {
    switch (key) {
      case 'NETS':
        return d.netsMinutes;
      case 'DRILLS':
      case 'MATCH':
        return d.drillsMinutes;
      case 'GYM':
      case 'CONDITIONING':
        return d.fitnessMinutes;
      case 'RECOVERY':
        return d.recoveryMinutes;
    }
    return 0;
  }

  bool _isActiveForActivity(WeeklyPlanDay d, String key) {
    switch (key) {
      case 'NETS':
        return d.hasNets || d.netsMinutes > 0;
      case 'DRILLS':
        return d.hasSkillWork || d.drillsMinutes > 0;
      case 'GYM':
        return d.hasGym || d.fitnessMinutes > 0;
      case 'CONDITIONING':
        return d.hasConditioning || d.fitnessMinutes > 0;
      case 'MATCH':
        return d.hasMatch || d.drillsMinutes > 0;
      case 'RECOVERY':
        return d.hasRecovery || d.recoveryMinutes > 0;
    }
    return false;
  }

  Future<void> _save() async {
    await _openEditor();
  }

  @override
  Widget build(BuildContext context) {
    final plan = widget.plan;
    final hasPlan = plan != null && plan.days.isNotEmpty;
    final activeDays = hasPlan ? _countActiveDays(plan) : 0;
    final sleepTarget =
        hasPlan ? plan.days.first.sleepTargetHours : 8.0;
    final hydrationTarget =
        hasPlan ? plan.days.first.hydrationTargetLiters : 4.0;

    return ApexCard(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: ApexColors.accentProgress.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: ApexColors.accentProgress.withValues(alpha: 0.35),
              ),
            ),
            child: const Icon(Icons.calendar_today_rounded,
                color: ApexColors.accentProgress, size: 13),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'MY WEEKLY PLAN',
                  style: TextStyle(
                      color: ApexColors.textPrimary,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1),
                ),
                const SizedBox(height: 3),
                Text(
                  hasPlan ? 'Active on $activeDays of 7 days' : 'No plan created yet',
                  style: ApexTextStyles.labelMuted.copyWith(fontSize: 11),
                ),
              ],
            ),
          ),
          if (_saving)
            const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2.2,
                color: ApexColors.accentProgress,
              ),
            )
          else
            _PlanBtn(
              label: hasPlan ? 'EDIT PLAN' : 'CREATE PLAN',
              color: ApexColors.textMuted,
              onTap: _save,
            ),
        ]),
        const SizedBox(height: 14),

        if (!hasPlan) ...[
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 18),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.add_chart_rounded, color: ApexColors.textMuted, size: 24),
                const SizedBox(height: 10),
                const Text('No weekly plan yet',
                    style: TextStyle(color: ApexColors.textPrimary,
                        fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                const Text('Tap CREATE PLAN to setup your week.',
                    style: ApexTextStyles.labelMuted),
              ]),
            ),
          ),
        ] else ...[
          Row(children: [
            const SizedBox(width: 84),
            ...plan.days.map((d) => Expanded(
                  child: Center(
                    child: Text(
                      d.weekday.isEmpty
                          ? ''
                          : d.weekday.substring(0, d.weekday.length >= 2 ? 2 : 1),
                      style: const TextStyle(
                        color: ApexColors.textMuted,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                )),
          ]),
          const SizedBox(height: 8),
          ..._activityDefs.map((act) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    SizedBox(
                      width: 84,
                      child: Row(
                        children: [
                          Icon(act.icon, color: act.color, size: 13),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              act.label,
                              style: TextStyle(
                                color: act.color,
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ...plan.days.map((day) {
                      final active = _isActiveForActivity(day, act.key);
                      final mins = _minutesForActivity(day, act.key);
                      return Expanded(
                        child: Center(
                          child: Container(
                            width: 30,
                            height: 20,
                            decoration: BoxDecoration(
                              color: active
                                  ? act.color.withValues(alpha: 0.16)
                                  : ApexColors.background,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: active
                                    ? act.color.withValues(alpha: 0.55)
                                    : ApexColors.border.withValues(alpha: 0.6),
                                width: 0.5,
                              ),
                            ),
                            child: active
                                ? Center(
                                    child: Text(
                                      mins >= 60
                                          ? '${(mins / 60).toStringAsFixed(0)}h'
                                          : '${mins}m',
                                      style: TextStyle(
                                        color: act.color,
                                        fontSize: 7,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  )
                                : null,
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              )),
          const SizedBox(height: 4),
          const ApexRule(),
          const SizedBox(height: 10),
          Wrap(
            spacing: 14,
            runSpacing: 8,
            children: [
              _PlanTarget(
                icon: Icons.bedtime_rounded,
                label: 'SLEEP',
                value: '${sleepTarget.toStringAsFixed(1)}h/night',
              ),
              _PlanTarget(
                icon: Icons.water_drop_rounded,
                label: 'HYDRATION',
                value: '${hydrationTarget.toStringAsFixed(1)}L/day',
              ),
            ],
          ),
        ],
      ]),
    );
  }
}

class _PlanBtn extends StatelessWidget {
  const _PlanBtn({required this.label, required this.color, required this.onTap});
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () { HapticFeedback.selectionClick(); onTap(); },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          border: Border.all(color: color.withValues(alpha: 0.4)),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(label,
            style: TextStyle(color: color, fontSize: 9,
                fontWeight: FontWeight.w800, letterSpacing: 1)),
      ),
    );
  }
}

class _PlanTarget extends StatelessWidget {
  const _PlanTarget({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: ApexColors.textMuted, size: 12),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: ApexTextStyles.labelCaps.copyWith(fontSize: 8)),
            Text(
              value,
              style: const TextStyle(
                color: ApexColors.textPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ActivityDef {
  const _ActivityDef({
    required this.key,
    required this.label,
    required this.icon,
    required this.color,
    required this.defaultMinutes,
  });

  final String key;
  final String label;
  final IconData icon;
  final Color color;
  final int defaultMinutes;
}

class _PlanEditorModel {
  const _PlanEditorModel({
    required this.selectedDays,
    required this.activityMinutes,
    required this.sleepTarget,
    required this.hydrationTarget,
  });

  final Map<String, Set<int>> selectedDays;
  final Map<String, int> activityMinutes;
  final double sleepTarget;
  final double hydrationTarget;

  _PlanEditorModel copyWith({
    Map<String, Set<int>>? selectedDays,
    Map<String, int>? activityMinutes,
    double? sleepTarget,
    double? hydrationTarget,
  }) {
    return _PlanEditorModel(
      selectedDays: selectedDays ?? this.selectedDays,
      activityMinutes: activityMinutes ?? this.activityMinutes,
      sleepTarget: sleepTarget ?? this.sleepTarget,
      hydrationTarget: hydrationTarget ?? this.hydrationTarget,
    );
  }
}

class _WeeklyPlanEditorSheet extends StatefulWidget {
  const _WeeklyPlanEditorSheet({
    required this.initial,
    required this.activities,
  });

  final _PlanEditorModel initial;
  final List<_ActivityDef> activities;

  @override
  State<_WeeklyPlanEditorSheet> createState() => _WeeklyPlanEditorSheetState();
}

class _WeeklyPlanEditorSheetState extends State<_WeeklyPlanEditorSheet> {
  static const _dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
  late _PlanEditorModel _model;

  @override
  void initState() {
    super.initState();
    _model = widget.initial;
  }

  void _toggleDay(String key, int day) {
    final selected = Map<String, Set<int>>.from(_model.selectedDays);
    final set = {...(selected[key] ?? <int>{})};
    if (set.contains(day)) {
      set.remove(day);
    } else {
      set.add(day);
    }
    selected[key] = set;
    setState(() => _model = _model.copyWith(selectedDays: selected));
  }

  void _setDuration(String key, int duration) {
    final minutes = Map<String, int>.from(_model.activityMinutes);
    minutes[key] = duration;
    setState(() => _model = _model.copyWith(activityMinutes: minutes));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: ApexColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            const SizedBox(height: 10),
            Container(
              width: 42,
              height: 4,
              decoration: BoxDecoration(
                color: ApexColors.border,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Text(
                    'Edit My Weekly Plan',
                    style: TextStyle(
                      color: ApexColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Spacer(),
                  _PlanBtn(
                    label: 'SAVE',
                    color: ApexColors.accentProgress,
                    onTap: () => Navigator.of(context).pop(_model),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                children: [
                  ...widget.activities.map((activity) {
                    final selected = _model.selectedDays[activity.key] ?? <int>{};
                    final duration =
                        _model.activityMinutes[activity.key] ?? activity.defaultMinutes;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: ApexColors.background,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: ApexColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(activity.icon, color: activity.color, size: 16),
                              const SizedBox(width: 8),
                              Text(
                                activity.label,
                                style: TextStyle(
                                  color: activity.color,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: ApexColors.surface,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: ApexColors.border),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  'Time',
                                  style: ApexTextStyles.labelMuted.copyWith(
                                    color: ApexColors.textPrimary,
                                    fontSize: 12,
                                  ),
                                ),
                                const Spacer(),
                                _StepBtn(
                                  icon: Icons.remove,
                                  onTap: () {
                                    final next = (duration - 15).clamp(15, 240);
                                    _setDuration(activity.key, next);
                                  },
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '$duration min',
                                  style: TextStyle(
                                    color: activity.color,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                _StepBtn(
                                  icon: Icons.add,
                                  onTap: () {
                                    final next = (duration + 15).clamp(15, 240);
                                    _setDuration(activity.key, next);
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: List.generate(7, (i) {
                              final day = i + 1;
                              final active = selected.contains(day);
                              return Expanded(
                                child: Padding(
                                  padding: EdgeInsets.only(right: i < 6 ? 6 : 0),
                                  child: GestureDetector(
                                    onTap: () => _toggleDay(activity.key, day),
                                    child: Container(
                                      height: 34,
                                      decoration: BoxDecoration(
                                        color: active
                                            ? activity.color.withValues(alpha: 0.18)
                                            : ApexColors.surface,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: active
                                              ? activity.color.withValues(alpha: 0.7)
                                              : ApexColors.border,
                                        ),
                                      ),
                                      child: Center(
                                        child: Text(
                                          _dayLabels[i],
                                          style: TextStyle(
                                            color: active
                                                ? activity.color
                                                : ApexColors.textMuted,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 4),
                  const Text(
                    'Recovery Targets',
                    style: TextStyle(
                      color: ApexColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _TargetStepper(
                    label: 'Sleep Target',
                    unit: 'h/night',
                    value: _model.sleepTarget,
                    step: 0.5,
                    min: 5.0,
                    max: 10.0,
                    onChanged: (v) => setState(() {
                      _model = _model.copyWith(sleepTarget: v);
                    }),
                  ),
                  const SizedBox(height: 10),
                  _TargetStepper(
                    label: 'Hydration Target',
                    unit: 'L/day',
                    value: _model.hydrationTarget,
                    step: 0.5,
                    min: 1.5,
                    max: 6.0,
                    onChanged: (v) => setState(() {
                      _model = _model.copyWith(hydrationTarget: v);
                    }),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TargetStepper extends StatelessWidget {
  const _TargetStepper({
    required this.label,
    required this.unit,
    required this.value,
    required this.step,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  final String label;
  final String unit;
  final double value;
  final double step;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: ApexColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ApexColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: ApexTextStyles.labelCaps.copyWith(fontSize: 9)),
                Text(
                  '${value.toStringAsFixed(1)}$unit',
                  style: const TextStyle(
                    color: ApexColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          _StepBtn(
            icon: Icons.remove,
            onTap: () => onChanged((value - step).clamp(min, max)),
          ),
          const SizedBox(width: 6),
          _StepBtn(
            icon: Icons.add,
            onTap: () => onChanged((value + step).clamp(min, max)),
          ),
        ],
      ),
    );
  }
}

class _StepBtn extends StatelessWidget {
  const _StepBtn({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          color: ApexColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: ApexColors.border),
        ),
        child: Icon(icon, size: 14, color: ApexColors.textMuted),
      ),
    );
  }
}

// ── LOG TODAY FAB ─────────────────────────────────────────────────────────────

class _LogTodayFab extends StatelessWidget {
  const _LogTodayFab({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () { HapticFeedback.mediumImpact(); onTap(); },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
        decoration: BoxDecoration(
          color: ApexColors.accentAim,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: ApexColors.accentAim.withValues(alpha: 0.4),
              blurRadius: 20, offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: const [
          Icon(Icons.add_rounded, color: Colors.white, size: 18),
          SizedBox(width: 8),
          Text('LOG TODAY',
              style: TextStyle(
                  color: Colors.white, fontSize: 13,
                  fontWeight: FontWeight.w900, letterSpacing: 1.5)),
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
