import 'dart:ui';
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
            child: Stack(
              children: [
                TabBarView(
                  children: [
                    BookingTab(
                      currentCity: widget.currentCity,
                      currentLatitude: widget.currentLatitude,
                      currentLongitude: widget.currentLongitude,
                    ),
                    const _CoachingBookingPlaceholder(),
                  ],
                ),
                // "Coming Soon" Overlay
                Positioned.fill(
                  child: ClipRect(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                      child: Container(
                        color: context.bg.withValues(alpha: 0.96),
                        child: Center(
                          child: SingleChildScrollView(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(24),
                                    decoration: BoxDecoration(
                                      color: context.accent.withValues(alpha: 0.1),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: context.accent.withValues(alpha: 0.2),
                                        width: 2,
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.stars_rounded,
                                      color: context.accent,
                                      size: 56,
                                    ),
                                  ),
                                  const SizedBox(height: 28),
                                  Text(
                                    'Booking Coming Soon',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: context.fg,
                                      fontSize: 32,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: -1.2,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Facility and Coach Booking are on their way. No more hustle to find your perfect ground or turf!',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: context.fgSub,
                                      fontSize: 17,
                                      height: 1.6,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 36),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 24, vertical: 20),
                                    decoration: BoxDecoration(
                                      color: context.panel.withValues(alpha: 0.8),
                                      borderRadius: BorderRadius.circular(24),
                                      border: Border.all(
                                          color: context.stroke
                                              .withValues(alpha: 0.6)),
                                    ),
                                    child: Column(
                                      children: [
                                        _ComingSoonFeature(
                                          icon: Icons.stadium_rounded,
                                          label: 'Verified Arenas & Turfs',
                                        ),
                                        const SizedBox(height: 20),
                                        _ComingSoonFeature(
                                          icon: Icons.sports_rounded,
                                          label: 'Pro Coaching Sessions',
                                        ),
                                        const SizedBox(height: 20),
                                        _ComingSoonFeature(
                                          icon: Icons.flash_on_rounded,
                                          label: 'Instant Slot Confirmation',
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 48),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: context.accent.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    child: Text(
                                      'YOUR CRICKET HOME, JUST A TAP AWAY',
                                      style: TextStyle(
                                        color: context.accent,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
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

class _ComingSoonFeature extends StatelessWidget {
  const _ComingSoonFeature({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: context.fgSub, size: 20),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(
            color: context.fg,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
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
