import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_host_core/flutter_host_core.dart'
    show hostArenaBookingRepositoryProvider;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../domain/booking_models.dart';

class BookingTab extends ConsumerStatefulWidget {
  const BookingTab({
    super.key,
    required this.currentCity,
    this.currentLatitude,
    this.currentLongitude,
  });

  final String currentCity;
  final double? currentLatitude;
  final double? currentLongitude;

  @override
  ConsumerState<BookingTab> createState() => _BookingTabState();
}

class _BookingTabState extends ConsumerState<BookingTab> {
  List<ArenaListing> _arenas = const [];
  bool _loading = true;
  String? _loadError;
  int _requestId = 0;

  // City filter
  String? _filterCity; // null = show all

  @override
  void initState() {
    super.initState();
    _loadArenas();
  }

  @override
  void didUpdateWidget(covariant BookingTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentCity != widget.currentCity ||
        oldWidget.currentLatitude != widget.currentLatitude ||
        oldWidget.currentLongitude != widget.currentLongitude) {
      _loadArenas();
    }
  }

  Future<void> _loadArenas() async {
    final requestId = ++_requestId;
    setState(() {
      _loading = true;
      _loadError = null;
    });

    final hasCoords =
        widget.currentLatitude != null && widget.currentLongitude != null;
    final effectiveCity = _apiCityQuery(widget.currentCity);

    debugPrint('[BookingTab] currentCity="${widget.currentCity}" '
        'effectiveCity="$effectiveCity" hasCoords=$hasCoords');
    debugPrint('[BookingTab] lat=${widget.currentLatitude} '
        'lng=${widget.currentLongitude}');

    try {
      final arenas =
          await ref.read(hostArenaBookingRepositoryProvider).fetchArenas(
                city: effectiveCity,
                sport: 'CRICKET',
                latitude: widget.currentLatitude,
                longitude: widget.currentLongitude,
                radiusKm: hasCoords ? 200 : null,
              );

      debugPrint('[BookingTab] fetchArenas → ${arenas.length} results');
      for (var i = 0; i < arenas.length; i++) {
        debugPrint('[BookingTab] [$i] id=${arenas[i].id} '
            'name="${arenas[i].name}" address="${arenas[i].address}" '
            'units=${arenas[i].units.length}');
      }

      if (!mounted || requestId != _requestId) return;
      setState(() {
        _arenas = arenas;
        _loading = false;
      });
    } catch (e, st) {
      debugPrint('[BookingTab] ERROR: $e\n$st');
      if (!mounted || requestId != _requestId) return;
      setState(() {
        _loading = false;
        _loadError = 'Could not load arenas right now.';
      });
    }
  }

  String? _apiCityQuery(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty || trimmed == 'Fetching location...') return null;
    final firstPart = trimmed.split(',').first.trim();
    return firstPart.isEmpty ? null : firstPart;
  }

  List<String> get _cities {
    final seen = <String>{};
    final result = <String>[];
    for (final arena in _arenas) {
      final city = _arenaCity(arena);
      if (city != null && seen.add(city)) result.add(city);
    }
    result.sort();
    return result;
  }

  String? _arenaCity(ArenaListing arena) {
    final parts = arena.address.split(',');
    if (parts.length < 2) return null;
    final city = parts[parts.length - 2].trim();
    return city.isEmpty ? null : city;
  }

  List<ArenaListing> get _visibleArenas {
    if (_filterCity == null) return _arenas;
    return _arenas.where((a) => _arenaCity(a) == _filterCity).toList();
  }

  double? _calculateDistance(double? lat, double? lng) {
    if (lat == null ||
        lng == null ||
        widget.currentLatitude == null ||
        widget.currentLongitude == null) {
      return null;
    }
    const p = 0.017453292519943295;
    final a = 0.5 -
        math.cos((lat - widget.currentLatitude!) * p) / 2 +
        math.cos(widget.currentLatitude! * p) *
            math.cos(lat * p) *
            (1 - math.cos((lng - widget.currentLongitude!) * p)) /
            2;
    return 12742 * math.asin(math.sqrt(a));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // City filter chips
        if (!_loading && _loadError == null && _cities.isNotEmpty)
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                _CityChip(
                  label: 'All',
                  selected: _filterCity == null,
                  onTap: () => setState(() => _filterCity = null),
                ),
                const SizedBox(width: 8),
                ..._cities.map((city) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: _CityChip(
                        label: city,
                        selected: _filterCity == city,
                        onTap: () => setState(() => _filterCity = city),
                      ),
                    )),
              ],
            ),
          ),
        const SizedBox(height: 16),
        Expanded(
          child: _loading
              ? const Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : _loadError != null
                  ? _FeedbackState(
                      message: _loadError!,
                      actionLabel: 'Retry',
                      onAction: _loadArenas,
                    )
                  : _visibleArenas.isEmpty
                      ? const _FeedbackState(
                          message: 'No arenas found.',
                        )
                      : ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          padding: EdgeInsets.fromLTRB(20, 0, 20, 140 + MediaQuery.of(context).padding.bottom),
                          itemCount: _visibleArenas.length,
                          itemBuilder: (context, i) {
                            final arena = _visibleArenas[i];
                            return _ArenaCard(
                              arena: arena,
                              distanceKm: _calculateDistance(
                                  arena.latitude, arena.longitude),
                            );
                          },
                        ),
        ),
      ],
    );
  }
}

// ── City chip ────────────────────────────────────────────────────────────────

class _CityChip extends StatelessWidget {
  const _CityChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color:
              selected ? context.accent : context.panel.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? context.accent
                : context.stroke.withValues(alpha: 0.3),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : context.fgSub,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

// ── Arena card ───────────────────────────────────────────────────────────────

class _ArenaCard extends StatelessWidget {
  const _ArenaCard({required this.arena, this.distanceKm});

  final ArenaListing arena;
  final double? distanceKm;

  @override
  Widget build(BuildContext context) {
    final parts = arena.address.split(',');
    final locality = parts.first.trim();

    final facilityTypes = <String>{};
    int boundary = 0;
    for (final unit in arena.units) {
      final t = unit.unitType.toUpperCase();
      if (t.contains('NET')) facilityTypes.add('Nets');
      if (t.contains('TURF')) facilityTypes.add('Turf');
      if (t.contains('GROUND')) facilityTypes.add('Ground');
      if (unit.boundarySize != null && unit.boundarySize! > boundary) {
        boundary = unit.boundarySize!;
      }
    }
    if (facilityTypes.isEmpty) facilityTypes.add('Other');

    final prices = arena.units
        .map((u) => u.pricePerHourPaise)
        .where((p) => p > 0)
        .toList()
      ..sort();
    final startingPrice = prices.isNotEmpty
        ? '₹${(prices.first / 100).toStringAsFixed(0)}'
        : null;

    final imageUrl = arena.photoUrls.isNotEmpty ? arena.photoUrls.first : null;

    return GestureDetector(
      onTap: () => context.push('/arena-booking/${arena.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: context.cardBg,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: context.stroke.withValues(alpha: 0.4)),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Stack(
              children: [
                Container(
                  height: 200,
                  width: double.infinity,
                  color: context.panel,
                  child: imageUrl != null
                      ? Image.network(imageUrl, fit: BoxFit.cover)
                      : Center(
                          child: Icon(Icons.stadium_rounded,
                              color: context.fg.withValues(alpha: 0.08),
                              size: 60)),
                ),
                // Gradient
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.75),
                        ],
                        stops: const [0.45, 1.0],
                      ),
                    ),
                  ),
                ),
                // Top-left tags
                Positioned(
                  top: 14,
                  left: 14,
                  child: Row(
                    children: [
                      _Tag(label: facilityTypes.join(' · ').toUpperCase()),
                      if (boundary > 0) ...[
                        const SizedBox(width: 6),
                        _Tag(label: '$boundary YDS'),
                      ],
                    ],
                  ),
                ),
                // Bottom info
                Positioned(
                  bottom: 14,
                  left: 16,
                  right: 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        arena.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.4,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text(
                            locality.toUpperCase(),
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.85),
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.4,
                            ),
                          ),
                          if (distanceKm != null) ...[
                            Text('  ·  ',
                                style: TextStyle(
                                    color:
                                        Colors.white.withValues(alpha: 0.4))),
                            Text(
                              '${distanceKm!.toStringAsFixed(1)} km',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.85),
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // Bottom bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  if (startingPrice != null) ...[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Starting from',
                              style: TextStyle(
                                  color: context.fgSub,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.3)),
                          Text(
                            '$startingPrice / hr',
                            style: TextStyle(
                                color: context.fg,
                                fontSize: 17,
                                fontWeight: FontWeight.w900),
                          ),
                        ],
                      ),
                    ),
                  ] else
                    const Spacer(),
                  ElevatedButton(
                    onPressed: () => context.push('/arena-booking/${arena.id}'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.accent,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      minimumSize: const Size(0, 42),
                      padding: const EdgeInsets.symmetric(horizontal: 22),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('BOOK',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5)),
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

class _Tag extends StatelessWidget {
  const _Tag({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Text(label,
          style: const TextStyle(
              color: Colors.white,
              fontSize: 9,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5)),
    );
  }
}

class _FeedbackState extends StatelessWidget {
  const _FeedbackState(
      {required this.message, this.actionLabel, this.onAction});
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message,
              style: TextStyle(
                  color: context.fgSub,
                  fontSize: 14,
                  fontWeight: FontWeight.w500)),
          if (actionLabel != null)
            TextButton(
                onPressed: onAction,
                child: Text(actionLabel!,
                    style: TextStyle(
                        color: context.accent, fontWeight: FontWeight.w700))),
        ],
      ),
    );
  }
}
