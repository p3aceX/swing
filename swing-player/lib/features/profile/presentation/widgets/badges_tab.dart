import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../domain/profile_models.dart';
import '../../domain/rank_visual_theme.dart';

class BadgesTab extends StatefulWidget {
  const BadgesTab({
    super.key,
    required this.badges,
    required this.rankTheme,
    this.overlapHandle,
  });

  final List<ProfileBadge> badges;
  final RankVisualTheme rankTheme;
  final SliverOverlapAbsorberHandle? overlapHandle;

  @override
  State<BadgesTab> createState() => _BadgesTabState();
}

class _BadgesTabState extends State<BadgesTab> {
  String _selectedCategory = 'All';

  List<String> get _categories {
    final cats = <String>{'All'};
    for (final b in widget.badges) {
      if (b.category.isNotEmpty) cats.add(_displayCategory(b.category));
    }
    return cats.toList();
  }

  List<ProfileBadge> get _filtered {
    final base = _selectedCategory == 'All'
        ? widget.badges
        : widget.badges.where((b) => _displayCategory(b.category) == _selectedCategory).toList();
    // Unlocked first, locked after
    return [...base..sort((a, b) => (b.isUnlocked ? 1 : 0) - (a.isUnlocked ? 1 : 0))];
  }

  @override
  Widget build(BuildContext context) {
    final badges = _filtered;
    final unlocked = badges.where((b) => b.isUnlocked).length;
    final categories = _categories;

    return CustomScrollView(
      slivers: [
        if (widget.overlapHandle != null)
          SliverOverlapInjector(handle: widget.overlapHandle!),
        // Progress header
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
            child: _ProgressHeader(
              unlocked: widget.badges.where((b) => b.isUnlocked).length,
              total: widget.badges.length,
              rankTheme: widget.rankTheme,
            ),
          ),
        ),

        // Category filter chips
        SliverToBoxAdapter(
          child: SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              itemCount: categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final cat = categories[i];
                final isSelected = cat == _selectedCategory;
                return GestureDetector(
                  onTap: () => setState(() => _selectedCategory = cat),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? widget.rankTheme.primary.withOpacity(0.15)
                          : Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? widget.rankTheme.primary.withOpacity(0.6)
                            : Colors.white.withOpacity(0.1),
                      ),
                    ),
                    child: Text(
                      cat,
                      style: TextStyle(
                        color: isSelected ? widget.rankTheme.primary : Colors.white54,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),

        // Unlocked count for current filter
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Text(
              '$unlocked / ${badges.length} unlocked',
              style: TextStyle(
                color: Colors.white.withOpacity(0.35),
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),

        // Badge grid — or empty state
        if (badges.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.workspace_premium_rounded,
                    size: 48,
                    color: Colors.white.withOpacity(0.15)),
                const SizedBox(height: 16),
                Text(
                  widget.badges.isEmpty
                      ? 'No badges yet'
                      : 'No badges in this category',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.4),
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.badges.isEmpty
                      ? 'Play matches and complete challenges\nto earn your first badge.'
                      : 'Try a different category filter.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.25),
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
            sliver: SliverGrid(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return _BadgeTile(
                    badge: badges[index],
                    rankTheme: widget.rankTheme,
                    index: index,
                  );
                },
                childCount: badges.length,
              ),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.78,
              ),
            ),
          ),
      ],
    );
  }
}

class _ProgressHeader extends StatelessWidget {
  const _ProgressHeader({
    required this.unlocked,
    required this.total,
    required this.rankTheme,
  });

  final int unlocked;
  final int total;
  final RankVisualTheme rankTheme;

  @override
  Widget build(BuildContext context) {
    final pct = total == 0 ? 0.0 : unlocked / total;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: rankTheme.deep,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: rankTheme.border.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.workspace_premium_rounded,
                  color: rankTheme.primary, size: 18),
              const SizedBox(width: 8),
              Text(
                'BADGE COLLECTION',
                style: TextStyle(
                  color: rankTheme.primary,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                ),
              ),
              const Spacer(),
              Text(
                '$unlocked / $total',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: pct,
              backgroundColor: Colors.white.withOpacity(0.08),
              valueColor: AlwaysStoppedAnimation(rankTheme.primary),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${(pct * 100).toStringAsFixed(0)}% complete · ${total - unlocked} badges to go',
            style: TextStyle(
              color: Colors.white.withOpacity(0.4),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _BadgeTile extends StatelessWidget {
  const _BadgeTile({
    required this.badge,
    required this.rankTheme,
    required this.index,
  });

  final ProfileBadge badge;
  final RankVisualTheme rankTheme;
  final int index;

  @override
  Widget build(BuildContext context) {
    final unlocked = badge.isUnlocked;
    final color = _categoryColor(badge.category, rankTheme);
    final icon = _categoryIcon(badge.category, badge.name);

    return GestureDetector(
      onTap: () => _showDetail(context),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: unlocked
              ? color.withOpacity(0.08)
              : Colors.white.withOpacity(0.03),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: unlocked
                ? color.withOpacity((badge.isRare == true) ? 0.7 : 0.3)
                : Colors.white.withOpacity(0.07),
            width: (badge.isRare == true) && unlocked ? 1.5 : 1,
          ),
          boxShadow: unlocked && (badge.isRare == true)
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.25),
                    blurRadius: 12,
                    spreadRadius: -2,
                  )
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon area
            Stack(
              alignment: Alignment.center,
              children: [
                if (unlocked)
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                  ),
                if (!unlocked)
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.04),
                      shape: BoxShape.circle,
                    ),
                  ),
                Icon(
                  icon,
                  color: unlocked ? color : Colors.white.withOpacity(0.15),
                  size: 26,
                ),
                if (!unlocked)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: Colors.white.withOpacity(0.1), width: 1),
                      ),
                      child: Icon(
                        Icons.lock_rounded,
                        size: 10,
                        color: Colors.white.withOpacity(0.3),
                      ),
                    ),
                  ),
                if (unlocked && (badge.isRare == true))
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD7A94B),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.black, width: 1.5),
                      ),
                      child: const Icon(Icons.star_rounded,
                          size: 10, color: Colors.black),
                    ),
                  ),
              ],
            )
                .animate(
                  target: unlocked ? 1 : 0,
                )
                .shimmer(
                  duration: 2400.ms,
                  color: color.withOpacity(0.4),
                  delay: Duration(milliseconds: index * 80),
                ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Text(
                badge.name,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: unlocked ? Colors.white : Colors.white.withOpacity(0.25),
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                ),
              ),
            ),
          ],
        ),
      )
          .animate()
          .fadeIn(
            duration: 300.ms,
            delay: Duration(milliseconds: (index * 30).clamp(0, 600)),
          )
          .scale(begin: const Offset(0.9, 0.9), duration: 300.ms),
    );
  }

  void _showDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _BadgeDetailSheet(
        badge: badge,
        rankTheme: rankTheme,
      ),
    );
  }
}

class _BadgeDetailSheet extends StatelessWidget {
  const _BadgeDetailSheet({required this.badge, required this.rankTheme});

  final ProfileBadge badge;
  final RankVisualTheme rankTheme;

  @override
  Widget build(BuildContext context) {
    final unlocked = badge.isUnlocked;
    final color = _categoryColor(badge.category, rankTheme);
    final icon = _categoryIcon(badge.category, badge.name);

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF111C16),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 28),

          // Big icon
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  color: color.withOpacity(unlocked ? 0.15 : 0.05),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: color.withOpacity(unlocked ? 0.4 : 0.1),
                    width: 2,
                  ),
                ),
              ),
              Icon(icon,
                  size: 40,
                  color: unlocked ? color : Colors.white.withOpacity(0.2)),
              if (!unlocked)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: Colors.white.withOpacity(0.1), width: 1.5),
                    ),
                    child: Icon(Icons.lock_rounded,
                        size: 14, color: Colors.white.withOpacity(0.35)),
                  ),
                ),
              if (unlocked && (badge.isRare == true))
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD7A94B),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.black, width: 2),
                    ),
                    child: const Icon(Icons.star_rounded,
                        size: 13, color: Colors.black),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),

          // Category chip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Text(
              _displayCategory(badge.category).toUpperCase(),
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.0,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Badge name
          Text(
            badge.name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w900,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 16),

          // Status + description
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.04),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.08)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      unlocked
                          ? Icons.check_circle_rounded
                          : Icons.info_outline_rounded,
                      size: 14,
                      color: unlocked ? color : Colors.white.withOpacity(0.4),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      unlocked ? 'Achievement' : 'How to unlock',
                      style: TextStyle(
                        color: unlocked ? color : Colors.white.withOpacity(0.4),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  badge.description.isNotEmpty
                      ? badge.description
                      : 'Complete the challenge to unlock this badge.',
                  style: TextStyle(
                    color: Colors.white.withOpacity(unlocked ? 0.85 : 0.55),
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),


          if ((badge.isRare == true)) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFD7A94B).withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: const Color(0xFFD7A94B).withOpacity(0.25)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.star_rounded,
                      color: Color(0xFFD7A94B), size: 14),
                  const SizedBox(width: 6),
                  const Text(
                    'RARE BADGE — only a few players hold this',
                    style: TextStyle(
                      color: Color(0xFFD7A94B),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
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

// ─── Helpers ─────────────────────────────────────────────────────────────────

String _displayCategory(String raw) {
  return switch (raw.toUpperCase()) {
    'BATTING'     => 'Batting',
    'BOWLING'     => 'Bowling',
    'FIELDING'    => 'Fielding',
    'ALL_ROUNDER' => 'All-Rounder',
    'FITNESS'     => 'Fitness',
    'GENERAL'     => 'General',
    'MILESTONE'   => 'Milestone',
    'STREAK'      => 'Streak',
    'SOCIAL'      => 'Social',
    'WELLNESS'    => 'Wellness',
    'TRAINING'    => 'Training',
    'CLUTCH'      => 'Clutch',
    'TEAM'        => 'Team',
    'TOURNAMENT'  => 'Tournament',
    'MVP'         => 'MVP',
    'CONSISTENCY' => 'Consistency',
    _             => raw.isEmpty ? 'General' : raw,
  };
}

Color _categoryColor(String category, RankVisualTheme rankTheme) {
  return switch (category.toUpperCase()) {
    'BATTING'     => const Color(0xFF3FA66A),
    'BOWLING'     => const Color(0xFF6D8FB5),
    'FIELDING'    => const Color(0xFFE0A44A),
    'ALL_ROUNDER' => const Color(0xFF9B7BE8),
    'FITNESS'     => const Color(0xFF5BC4A0),
    'GENERAL'     => const Color(0xFF84C97E),
    'MILESTONE'   => const Color(0xFFD7A94B),
    'STREAK'      => const Color(0xFFE56B4A),
    'SOCIAL'      => const Color(0xFF7BA4E8),
    'WELLNESS'    => const Color(0xFF5BC4A0),
    'TRAINING'    => const Color(0xFF63C07E),
    'CLUTCH'      => const Color(0xFFE05C6A),
    'TEAM'        => const Color(0xFF5B9FE0),
    'TOURNAMENT'  => const Color(0xFFD7A94B),
    'MVP'         => const Color(0xFFF0C060),
    'CONSISTENCY' => const Color(0xFF84C97E),
    _             => rankTheme.primary,
  };
}

IconData _categoryIcon(String category, String name) {
  final cat = category.toUpperCase();
  final n = name.toLowerCase();

  // Name-specific overrides for common badges
  if (n.contains('century') || n.contains('hundred')) return Icons.looks_one_rounded;
  if (n.contains('fifty') || n.contains('half')) return Icons.looks_two_rounded;
  if (n.contains('six')) return Icons.rocket_launch_rounded;
  if (n.contains('four')) return Icons.arrow_forward_rounded;
  if (n.contains('duck')) return Icons.do_not_disturb_rounded;
  if (n.contains('mvp') || n.contains('man of')) return Icons.emoji_events_rounded;
  if (n.contains('hat-trick') || n.contains('hattrick')) return Icons.all_inclusive_rounded;
  if (n.contains('maiden')) return Icons.remove_circle_outline_rounded;
  if (n.contains('run out')) return Icons.directions_run_rounded;
  if (n.contains('stump')) return Icons.crisis_alert_rounded;
  if (n.contains('catch')) return Icons.pan_tool_rounded;
  if (n.contains('captain') || n.contains('leader')) return Icons.shield_rounded;
  if (n.contains('fire') || n.contains('hot')) return Icons.local_fire_department_rounded;
  if (n.contains('streak')) return Icons.bolt_rounded;
  if (n.contains('win')) return Icons.emoji_events_rounded;
  if (n.contains('follow')) return Icons.people_rounded;
  if (n.contains('rank')) return Icons.workspace_premium_rounded;
  if (n.contains('ip') || n.contains('impact')) return Icons.bolt_rounded;

  return switch (cat) {
    'BATTING'     => Icons.sports_cricket_rounded,
    'BOWLING'     => Icons.adjust_rounded,
    'FIELDING'    => Icons.back_hand_rounded,
    'ALL_ROUNDER' => Icons.stars_rounded,
    'FITNESS'     => Icons.fitness_center_rounded,
    'GENERAL'     => Icons.workspace_premium_rounded,
    'MILESTONE'   => Icons.flag_rounded,
    'STREAK'      => Icons.local_fire_department_rounded,
    'SOCIAL'      => Icons.people_rounded,
    'WELLNESS'    => Icons.favorite_rounded,
    'TRAINING'    => Icons.fitness_center_rounded,
    'CLUTCH'      => Icons.bolt_rounded,
    'TEAM'        => Icons.groups_rounded,
    'TOURNAMENT'  => Icons.emoji_events_rounded,
    'MVP'         => Icons.emoji_events_rounded,
    'CONSISTENCY' => Icons.show_chart_rounded,
    _             => Icons.workspace_premium_rounded,
  };
}
