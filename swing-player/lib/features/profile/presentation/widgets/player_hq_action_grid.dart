import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import 'profile_section_card.dart';

class PlayerHqActionItem {
  const PlayerHqActionItem({
    required this.label,
    required this.icon,
    required this.subtitle,
    required this.onTap,
    this.highlight = false,
  });

  final String label;
  final IconData icon;
  final String subtitle;
  final VoidCallback onTap;
  final bool highlight;
}

class PlayerHqActionGrid extends StatelessWidget {
  const PlayerHqActionGrid({
    super.key,
    required this.actions,
  });

  final List<PlayerHqActionItem> actions;

  @override
  Widget build(BuildContext context) {
    return ProfileSectionCard(
      title: 'Quick Actions',
      subtitle:
          'Jump straight into profile flows and command-center shortcuts.',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 420;
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: actions.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: compact ? 2 : 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              mainAxisExtent: compact ? 100 : 108,
            ),
            itemBuilder: (context, index) {
              final action = actions[index];
              return _ActionCard(action: action);
            },
          );
        },
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.action,
  });

  final PlayerHqActionItem action;

  @override
  Widget build(BuildContext context) {
    final tone = action.highlight ? context.gold : context.accent;

    return InkWell(
      onTap: action.onTap,
      borderRadius: BorderRadius.circular(20),
      child: Ink(
        decoration: BoxDecoration(
          color: action.highlight
              ? context.gold.withValues(alpha: 0.12)
              : context.panel,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: action.highlight
                ? context.gold.withValues(alpha: 0.24)
                : context.stroke,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: tone.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(action.icon, color: tone, size: 18),
              ),
              const Spacer(),
              Text(
                action.label,
                style: TextStyle(
                  color: context.fg,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                action.subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: context.fgSub,
                  fontSize: 10,
                  height: 1.25,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
