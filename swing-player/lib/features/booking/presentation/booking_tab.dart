import 'dart:math' as math;
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_host_core/flutter_host_core.dart'
    show hostArenaBookingRepositoryProvider;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../arena_booking/presentation/player_booking_sheet.dart';
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

  // Unit filter
  String? _filterUnitType; // null = show all

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

    try {
      final arenas =
          await ref.read(hostArenaBookingRepositoryProvider).fetchArenas(
                city: effectiveCity,
                sport: 'CRICKET',
                latitude: widget.currentLatitude,
                longitude: widget.currentLongitude,
                radiusKm: hasCoords ? 200 : null,
              );

      if (!mounted || requestId != _requestId) return;
      setState(() {
        _arenas = arenas;
        _loading = false;
      });
    } catch (e) {
      if (!mounted || requestId != _requestId) return;
      setState(() {
        _loading = false;
        _loadError = 'Could not load arenas right now.';
      });
    }
  }

  String? _apiCityQuery(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty ||
        trimmed == 'Fetching...' ||
        trimmed == 'Fetching location...') return null;
    final firstPart = trimmed.split(',').first.trim();
    return firstPart.isEmpty ? null : firstPart;
  }

  List<String> get _unitTypes {
    final types = <String>{};
    for (final arena in _arenas) {
      for (final unit in arena.units) {
        final t = _normalizeUnitType(unit.unitType);
        types.add(t);
      }
    }
    final result = types.toList()..sort();
    return result;
  }

  String _normalizeUnitType(String raw) {
    final t = raw.toUpperCase();
    if (t.contains('NET')) return 'Nets';
    if (t.contains('TURF')) return 'Turf';
    if (t.contains('GROUND')) return 'Ground';
    return 'Other';
  }

  List<ArenaListing> get _visibleArenas {
    if (_filterUnitType == null) return _arenas;
    return _arenas.where((a) {
      return a.units.any((u) => _normalizeUnitType(u.unitType) == _filterUnitType);
    }).toList();
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
    final unitTypes = _unitTypes;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Unit filter chips
        if (!_loading && _loadError == null && unitTypes.isNotEmpty)
          Container(
            height: 44,
            margin: const EdgeInsets.only(bottom: 8),
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                _FilterChip(
                  label: 'All',
                  icon: Icons.grid_view_rounded,
                  selected: _filterUnitType == null,
                  onTap: () => setState(() => _filterUnitType = null),
                ),
                const SizedBox(width: 8),
                ...unitTypes.map((type) {
                  final icon = switch (type.toLowerCase()) {
                    'nets' => Icons.sports_cricket_rounded,
                    'turf' => Icons.grass_rounded,
                    'ground' => Icons.stadium_rounded,
                    _ => Icons.layers_outlined,
                  };
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _FilterChip(
                      label: type,
                      icon: icon,
                      selected: _filterUnitType == type,
                      onTap: () => setState(() => _filterUnitType = type),
                    ),
                  );
                }),
              ],
            ),
          ),
        Expanded(
          child: _loading
              ? const Center(
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : _loadError != null
                  ? _FeedbackState(
                      message: _loadError!,
                      actionLabel: 'RETRY',
                      onAction: _loadArenas,
                    )
                  : _visibleArenas.isEmpty
                      ? const _FeedbackState(
                          message: 'COMING SOON',
                        )
                      : RefreshIndicator(
                          onRefresh: _loadArenas,
                          color: context.accent,
                          backgroundColor: context.isDark ? Colors.black : Colors.white,
                          child: ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(
                                parent: BouncingScrollPhysics()),
                            padding: EdgeInsets.fromLTRB(20, 8, 20, 140 + MediaQuery.of(context).padding.bottom),
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
        ),
      ],
    );
  }
}

// ── Filter chip ──────────────────────────────────────────────────────────────

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final accent = context.accent;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? accent.withValues(alpha: 0.08) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? accent : context.stroke.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: selected ? accent : context.fgSub),
            const SizedBox(width: 8),
            Text(
              label.toUpperCase(),
              style: TextStyle(
                color: selected ? accent : context.fgSub,
                fontSize: 11,
                fontWeight: selected ? FontWeight.w900 : FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ],
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
    for (final unit in arena.units) {
      final t = unit.unitType.toUpperCase();
      if (t.contains('NET')) facilityTypes.add('Nets');
      if (t.contains('TURF')) facilityTypes.add('Turf');
      if (t.contains('GROUND')) facilityTypes.add('Ground');
    }
    if (facilityTypes.isEmpty) facilityTypes.add('Other');

    final prices = arena.units.expand((u) {
      if (u.netVariants.isNotEmpty) {
        return u.netVariants
            .map((v) => v.pricePaise ?? u.pricePerHourPaise)
            .where((p) => p > 0);
      }
      return [u.pricePerHourPaise].where((p) => p > 0);
    }).toList()
      ..sort();
    final startingPrice = prices.isNotEmpty
        ? '₹${(prices.first / 100).toStringAsFixed(0)}'
        : null;

    final imageUrl = arena.photoUrls.isNotEmpty ? arena.photoUrls.first : null;
    final isDark = context.isDark;

    return GestureDetector(
      onTap: () => showPlayerBookingSheet(context, arena),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0D0D0D) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            if (!isDark)
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image - Compact Square (Increased size)
            Container(
              width: 115,
              height: 115,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: context.panel,
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                children: [
                  imageUrl != null
                      ? CachedNetworkImage(
                          imageUrl: imageUrl,
                          width: 115,
                          height: 115,
                          fit: BoxFit.cover,
                        )
                      : Center(
                          child: Icon(Icons.stadium_rounded,
                              color: context.fg.withValues(alpha: 0.1),
                              size: 36)),
                  if (distanceKm != null)
                    Positioned(
                      bottom: 6,
                      left: 6,
                      right: 6,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${distanceKm!.toStringAsFixed(1)} KM',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // Info Column
            Expanded(
              child: SizedBox(
                height: 115,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Facility Type Tags
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: facilityTypes.map((type) {
                          return Container(
                            margin: const EdgeInsets.only(right: 6),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: context.accent.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              type.toUpperCase(),
                              style: TextStyle(
                                color: context.accent,
                                fontSize: 8,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.5,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      arena.name.toUpperCase(),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: context.fg,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.2,
                        height: 1.1,
                      ),
                    ),
                    Text(
                      locality.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: context.fgSub.withValues(alpha: 0.4),
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (startingPrice != null)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'ONWARDS',
                                style: TextStyle(
                                  color: context.fgSub.withValues(alpha: 0.4),
                                  fontSize: 8,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              Text(
                                startingPrice,
                                style: TextStyle(
                                  color: context.fg,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  height: 1.1,
                                ),
                              ),
                            ],
                          ),                        _BookButtonSmall(
                            onPressed: () =>
                                showPlayerBookingSheet(context, arena)),
                      ],
                    ),
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

class _BookButtonSmall extends StatelessWidget {
  const _BookButtonSmall({required this.onPressed});
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: context.fg,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          'BOOK',
          style: TextStyle(
            color: context.isDark ? Colors.black : Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.5,
          ),
        ),
      ),
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
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.info_outline_rounded, color: context.fgSub, size: 40),
            const SizedBox(height: 16),
            Text(
              message.toUpperCase(),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: context.fgSub,
                fontSize: 13,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
            if (actionLabel != null) ...[
              const SizedBox(height: 16),
              TextButton(
                onPressed: onAction,
                child: Text(
                  actionLabel!,
                  style: TextStyle(
                    color: context.accent,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

