import "package:cached_network_image/cached_network_image.dart";
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../booking/presentation/booking_module_tab.dart';
import '../../../profile/presentation/widgets/profile_section_card.dart';
import '../models/growth_insights_model.dart';

class NearbyCoachesSection extends StatelessWidget {
  const NearbyCoachesSection({
    super.key,
    required this.coaches,
    required this.weaknessAxis,
    required this.currentCity,
    this.isLoading = false,
  });

  final List<CoachSuggestion> coaches;
  final String? weaknessAxis;
  final String currentCity;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return ProfileSectionCard(
      title: 'Coaches who can help',
      subtitle: weaknessAxis == null || weaknessAxis!.isEmpty
          ? 'Nearby coaches matched for your current profile.'
          : 'With your ${_prettyAxis(weaknessAxis!)}',
      child: SizedBox(
        height: 208,
        child: isLoading && coaches.isEmpty
            ? ListView.separated(
                scrollDirection: Axis.horizontal,
                itemBuilder: (_, __) => const _CoachSkeletonCard(),
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemCount: 2,
              )
            : coaches.isEmpty
                ? _EmptyCoachState(currentCity: currentCity)
                : ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) => _CoachCard(
                      coach: coaches[index],
                      currentCity: currentCity,
                    ),
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemCount: coaches.length,
                  ),
      ),
    );
  }
}

class _CoachCard extends StatelessWidget {
  const _CoachCard({
    required this.coach,
    required this.currentCity,
  });

  final CoachSuggestion coach;
  final String currentCity;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 184,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.panel.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: context.stroke.withValues(alpha: 0.55)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: context.accentBg,
                backgroundImage: coach.avatarUrl?.isNotEmpty == true
                    ? CachedNetworkImageProvider(coach.avatarUrl!)
                    : null,
                child: coach.avatarUrl?.isNotEmpty == true
                    ? null
                    : Text(
                        coach.name.isEmpty
                            ? 'C'
                            : coach.name.characters.first.toUpperCase(),
                        style: TextStyle(
                          color: context.accent,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      coach.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: context.fg,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '★ ${coach.rating.toStringAsFixed(1)} · ${coach.totalSessions} sessions',
                      style: TextStyle(
                        color: context.fgSub,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (coach.specializations.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: context.cardBg,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                _prettyEnum(coach.specializations.first),
                style: TextStyle(
                  color: context.fgSub,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          const Spacer(),
          if (coach.distanceKm != null)
            Text(
              '${coach.distanceKm!.toStringAsFixed(1)} km away',
              style: TextStyle(
                color: context.fgSub,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          const SizedBox(height: 6),
          Text(
            _currency.format(coach.sessionPricePaise / 100),
            style: TextStyle(
              color: context.fg,
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            '/ session',
            style: TextStyle(
              color: context.fgSub,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => _openCoachBooking(context, currentCity),
              style: FilledButton.styleFrom(
                backgroundColor: context.accent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 11),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text('Book 1-on-1'),
            ),
          ),
        ],
      ),
    );
  }
}

class _CoachSkeletonCard extends StatelessWidget {
  const _CoachSkeletonCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 184,
      decoration: BoxDecoration(
        color: context.panel.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: context.stroke.withValues(alpha: 0.4)),
      ),
    );
  }
}

class _EmptyCoachState extends StatelessWidget {
  const _EmptyCoachState({required this.currentCity});

  final String currentCity;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: context.panel.withValues(alpha: 0.48),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: context.stroke.withValues(alpha: 0.55)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.person_search_rounded, color: context.fgSub, size: 24),
          const SizedBox(height: 12),
          Text(
            'No coaches available in your area yet',
            style: TextStyle(
              color: context.fg,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Browse the existing coaching module while we expand local coach coverage.',
            style: TextStyle(
              color: context.fgSub,
              fontSize: 12,
              height: 1.45,
            ),
          ),
          const Spacer(),
          TextButton(
            onPressed: () => _openCoachBooking(context, currentCity),
            child: const Text('Browse all coaches →'),
          ),
        ],
      ),
    );
  }
}

void _openCoachBooking(BuildContext context, String currentCity) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => Scaffold(
        backgroundColor: context.bg,
        appBar: AppBar(
          backgroundColor: context.bg,
          foregroundColor: context.fg,
          title: const Text('Book 1-on-1'),
        ),
        body: SafeArea(
          child: BookingModuleTab(
            currentCity: currentCity,
            initialTabIndex: 1,
          ),
        ),
      ),
    ),
  );
}

String _prettyAxis(String raw) {
  if (raw.isEmpty) return 'growth area';
  return raw
      .split('_')
      .map((part) => part.isEmpty
          ? part
          : '${part[0].toUpperCase()}${part.substring(1).toLowerCase()}')
      .join(' ');
}

String _prettyEnum(String raw) => _prettyAxis(raw);

final NumberFormat _currency =
    NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
