import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import 'booking_tab.dart';

class BookingModuleTab extends StatefulWidget {
  const BookingModuleTab({
    super.key,
    required this.currentCity,
    this.currentLatitude,
    this.currentLongitude,
    this.initialTabIndex = 0,
  });

  final String currentCity;
  final double? currentLatitude;
  final double? currentLongitude;
  final int initialTabIndex;

  @override
  State<BookingModuleTab> createState() => _BookingModuleTabState();
}

class _BookingModuleTabState extends State<BookingModuleTab> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: widget.initialTabIndex.clamp(0, 1),
      length: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: TabBar(
                    isScrollable: true,
                    tabAlignment: TabAlignment.start,
                    indicatorColor: context.accent,
                    indicatorWeight: 3,
                    indicatorSize: TabBarIndicatorSize.label,
                    dividerColor: Colors.transparent,
                    labelColor: context.fg,
                    unselectedLabelColor: context.fgSub,
                    labelPadding: const EdgeInsets.only(right: 24),
                    labelStyle: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                    unselectedLabelStyle: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                    ),
                    tabs: const [
                      Tab(text: 'Facilities'),
                      Tab(text: 'Coaching'),
                    ],
                  ),
                ),
                _LocationChip(city: widget.currentCity),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: TabBarView(
              children: [
                BookingTab(
                  currentCity: widget.currentCity,
                  currentLatitude: widget.currentLatitude,
                  currentLongitude: widget.currentLongitude,
                ),
                const _CoachingBookingPlaceholder(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CoachingBookingPlaceholder extends StatelessWidget {
  const _CoachingBookingPlaceholder();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 140),
      physics: const BouncingScrollPhysics(),
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                context.cardBg,
                context.panel.withValues(alpha: 0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: context.stroke.withValues(alpha: 0.5)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: context.sky.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.sports_cricket_rounded,
                  color: context.sky,
                  size: 22,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Coaching coming soon',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: context.fg,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'We are building a world-class coaching discovery platform. Stay tuned for expert sessions and training modules.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: context.fgSub,
                      height: 1.5,
                      fontWeight: FontWeight.w500,
                    ),
              ),
              const SizedBox(height: 24),
              const Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _CoachingBadge(label: 'Expert Coaches'),
                  _CoachingBadge(label: 'Skill Drills'),
                  _CoachingBadge(label: 'Performance Tracking'),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: context.cardBg,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: context.stroke.withValues(alpha: 0.4)),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: context.panel,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.auto_awesome_rounded,
                  color: context.gold,
                  size: 22,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dedicated Experience',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: context.fg,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Separated workflows for facility booking and high-performance coaching.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: context.fgSub,
                            height: 1.4,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LocationChip extends StatelessWidget {
  const _LocationChip({required this.city});
  final String city;

  @override
  Widget build(BuildContext context) {
    final label = (city.isEmpty ||
            city == 'Fetching...' ||
            city == 'Fetching location...')
        ? '...'
        : city.split(',').first.trim();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: context.panel.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: context.stroke.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.location_on_rounded, size: 12, color: context.accent),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: context.fg,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _CoachingBadge extends StatelessWidget {
  const _CoachingBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: context.panel.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: context.stroke.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: context.fg,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.2,
            ),
      ),
    );
  }
}
