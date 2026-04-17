import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/profile_models.dart';
import 'profile_section_card.dart';

class StrengthsWorkOnsCard extends StatelessWidget {
  const StrengthsWorkOnsCard({
    super.key,
    required this.insights,
  });

  final PlayerProfileInsights insights;

  @override
  Widget build(BuildContext context) {
    return ProfileSectionCard(
      title: 'Strengths and Work-ons',
      subtitle:
          'Where your profile is already dangerous and where the next gains live.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final stacked = constraints.maxWidth < 380;
              if (stacked) {
                return Column(
                  children: [
                    _InsightColumn(
                      title: 'Strengths',
                      icon: Icons.trending_up_rounded,
                      tone: context.accent,
                      items: insights.strengths,
                    ),
                    const SizedBox(height: 14),
                    _InsightColumn(
                      title: 'Work-ons',
                      icon: Icons.build_circle_outlined,
                      tone: context.gold,
                      items: insights.workOns,
                    ),
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _InsightColumn(
                      title: 'Strengths',
                      icon: Icons.trending_up_rounded,
                      tone: context.accent,
                      items: insights.strengths,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _InsightColumn(
                      title: 'Work-ons',
                      icon: Icons.build_circle_outlined,
                      tone: context.gold,
                      items: insights.workOns,
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: context.panel,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: context.stroke),
            ),
            child: Text(
              insights.summary,
              style: TextStyle(
                color: context.fg,
                fontSize: 13,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InsightColumn extends StatelessWidget {
  const _InsightColumn({
    required this.title,
    required this.icon,
    required this.tone,
    required this.items,
  });

  final String title;
  final IconData icon;
  final Color tone;
  final List<PlayerFocusItem> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.panel,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.stroke),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: tone.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: tone, size: 16),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: context.fg,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _InsightRow(
                item: item,
                tone: tone,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InsightRow extends StatelessWidget {
  const _InsightRow({
    required this.item,
    required this.tone,
  });

  final PlayerFocusItem item;
  final Color tone;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.only(top: 6),
          decoration: BoxDecoration(
            color: tone,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.title,
                style: TextStyle(
                  color: context.fg,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                item.subtitle,
                style: TextStyle(
                  color: context.fgSub,
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
