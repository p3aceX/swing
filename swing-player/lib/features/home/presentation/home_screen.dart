import 'dart:async';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';

import '../../notifications/presentation/notifications_screen.dart';
import '../../chat/presentation/conversations_screen.dart';
import '../../matchmaking/presentation/matchmaking_tab_page.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/theme/app_colors.dart';
import '../../booking/presentation/booking_module_tab.dart';
import '../../../app.dart';
import '../../profile/controller/profile_controller.dart';
import '../../profile/data/profile_repository.dart';
import '../../profile/presentation/profile_qr_sheet.dart';
import '../../auth/controller/auth_controller.dart';
import '../../store/domain/store_models.dart';
import '../../store/presentation/storefront_screen.dart';
import 'player_home_body.dart';
import 'play_tab.dart';
// import '../../health/presentation/apex_health_shell.dart'; // v1 archived

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  static const _navItems = [
    _NavItem(icon: Icons.grid_view_outlined, activeIcon: Icons.grid_view_rounded, label: 'Home'),
    _NavItem(icon: Icons.sports_cricket_outlined, activeIcon: Icons.sports_cricket_rounded, label: 'Play'),
    _NavItem(icon: Icons.bolt_rounded, activeIcon: Icons.bolt_rounded, label: 'Rivals'),
    _NavItem(icon: Icons.calendar_month_outlined, activeIcon: Icons.calendar_month_rounded, label: 'Book'),
    _NavItem(icon: Icons.storefront_outlined, activeIcon: Icons.storefront_rounded, label: 'Store'),
  ];

  int _currentIndex = 0;
  String _currentCity = 'Location';
  double? _currentLatitude;
  double? _currentLongitude;
  final _profileRepository = ProfileRepository();

  @override
  void initState() {
    super.initState();
    _loadCurrentCity();
  }

  void _onNavTap(int index) => setState(() => _currentIndex = index);

  Future<void> _openLocationSheet() async {
    final searchCtrl = TextEditingController(
        text: _currentCity == 'Location' ? '' : _currentCity);
    final searchFocus = FocusNode();
    Timer? modalDebounce;
    List<CitySuggestion> modalSuggestions = const [];
    bool modalSearching = false;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            Future<void> handleQuery(String value) async {
              modalDebounce?.cancel();
              final query = value.trim();
              if (query.length < 2) {
                setSheetState(() {
                  modalSuggestions = const [];
                  modalSearching = false;
                });
                return;
              }

              setSheetState(() => modalSearching = true);
              modalDebounce =
                  Timer(const Duration(milliseconds: 220), () async {
                try {
                  final suggestions =
                      await _profileRepository.searchCities(query);
                  if (!mounted || searchCtrl.text.trim() != query) return;
                  setSheetState(() {
                    modalSuggestions = suggestions;
                    modalSearching = false;
                  });
                } catch (_) {
                  if (!mounted || searchCtrl.text.trim() != query) return;
                  setSheetState(() {
                    modalSuggestions = const [];
                    modalSearching = false;
                  });
                }
              });
            }

            return Container(
              decoration: BoxDecoration(
                color: context.bg,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(32)),
              ),
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 12),
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: context.stroke.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Location',
                            style: TextStyle(
                              color: context.fg,
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Find facilities in your city',
                            style: TextStyle(
                              color: context.fgSub,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 32),
                          Container(
                            height: 52,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: context.panel.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.search_rounded,
                                    color: context.fgSub, size: 20),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: TextField(
                                    controller: searchCtrl,
                                    focusNode: searchFocus,
                                    autofocus: true,
                                    onChanged: handleQuery,
                                    cursorColor: context.accent,
                                    style: TextStyle(
                                      color: context.fg,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: 'Search for a city...',
                                      hintStyle: TextStyle(
                                        color: context.fgSub
                                            .withValues(alpha: 0.5),
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      border: InputBorder.none,
                                      isCollapsed: true,
                                    ),
                                  ),
                                ),
                                if (modalSearching)
                                  SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: context.accent,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.4,
                      ),
                      child: _BookingLocationSuggestionsList(
                        suggestions: modalSuggestions,
                        onSelected: (suggestion) {
                          setState(() {
                            _currentCity = suggestion.label;
                            // Clear coordinates when city is manually picked
                            _currentLatitude = null;
                            _currentLongitude = null;
                          });
                          Navigator.of(sheetContext).pop();
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    modalDebounce?.cancel();
    searchCtrl.dispose();
    searchFocus.dispose();
  }

  Future<void> _loadCurrentCity() async {
    try {
      final enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) {
        if (mounted && _currentCity == 'Location') {
          setState(() => _currentCity = 'Mumbai');
        }
        return;
      }
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (mounted && _currentCity == 'Location') {
          setState(() => _currentCity = 'Mumbai');
        }
        return;
      }
      Position? position;
      try {
        position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high,
            timeLimit: const Duration(seconds: 15));
      } catch (_) {
        position = await Geolocator.getLastKnownPosition();
      }
      if (position == null) {
        if (mounted && _currentCity == 'Location') {
          setState(() => _currentCity = 'Mumbai');
        }
        return;
      }
      final placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);
      final place = placemarks.isEmpty ? null : placemarks.first;

      // Extract city intelligently from various fields
      final detectedCity =
          place?.locality ?? place?.subAdministrativeArea ?? place?.name;

      if (!mounted) return;
      setState(() {
        _currentCity = detectedCity ?? 'Mumbai';
        _currentLatitude = position!.latitude;
        _currentLongitude = position.longitude;
      });
    } catch (_) {
      if (mounted && _currentCity == 'Location') {
        setState(() => _currentCity = 'Mumbai');
      }
    }
  }

  void _openSupport() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const _SupportSheet(),
    );
  }

  void _openSearchOverlay() {
    final overlay = Overlay.of(context, rootOverlay: true);
    late OverlayEntry entry;
    void close() {
      if (entry.mounted) entry.remove();
    }

    entry = OverlayEntry(builder: (ctx) {
      return _SearchOverlay(onClose: close);
    });
    overlay.insert(entry);
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileControllerProvider);
    final profileData = profileState.data;
    final avatarUrl = profileData?.identity.avatarUrl;

    return Scaffold(
      backgroundColor: context.bg,
      drawer: const _SideNavigation(),
      appBar: _currentIndex == 0
          ? PreferredSize(
              preferredSize: const Size.fromHeight(76),
              child: Builder(builder: (context) {
                return _SexyHeader(
                  avatarUrl: avatarUrl,
                  userName: profileData?.identity.fullName,
                  onSearchTap: _openSearchOverlay,
                  onProfileTap: () => Scaffold.of(context).openDrawer(),
                  onChatTap: () => context.push('/chat'),
                  onNotificationTap: () => context.push('/notifications'),
                  onLeaderboardTap: () => context.push('/leaderboard'),
                );
              }),
            )
          : null,
      body: _HomeBody(
        currentIndex: _currentIndex,
        currentCity: _currentCity,
        currentLatitude: _currentLatitude,
        currentLongitude: _currentLongitude,
        onLocationTap: _openLocationSheet,
        onSwitchToMatch: () => setState(() => _currentIndex = 2),
      ),
      bottomNavigationBar: _PremiumBottomNav(
        currentIndex: _currentIndex,
        items: _navItems,
        onTap: _onNavTap,
      ),
    );
  }
}

// ── App Header (ERP Shell) ────────────────────────────────────────────────────

class _SexyHeader extends ConsumerWidget {
  const _SexyHeader({
    this.avatarUrl,
    this.userName,
    required this.onSearchTap,
    required this.onProfileTap,
    required this.onChatTap,
    required this.onNotificationTap,
    required this.onLeaderboardTap,
  });

  final String? avatarUrl;
  final String? userName;
  final VoidCallback onSearchTap;
  final VoidCallback onProfileTap;
  final VoidCallback onChatTap;
  final VoidCallback onNotificationTap;
  final VoidCallback onLeaderboardTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unreadChat = ref.watch(chatUnreadCountProvider).valueOrNull ?? 0;
    final unreadNotif = ref.watch(notificationSummaryProvider).valueOrNull ?? 0;

    return Container(
      color: context.surf,
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 76,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                _GradientAvatar(url: avatarUrl, onTap: onProfileTap),
                const Spacer(),
                _SoftIconButton(
                  icon: Icons.search_rounded,
                  onTap: onSearchTap,
                  tooltip: 'Search',
                ),
                const SizedBox(width: 10),
                _SoftIconButton(
                  icon: Icons.emoji_events_outlined,
                  onTap: onLeaderboardTap,
                  tooltip: 'Leaderboard',
                ),
                const SizedBox(width: 10),
                _SoftIconButton(
                  icon: Icons.notifications_none_rounded,
                  onTap: onNotificationTap,
                  tooltip: 'Notifications',
                  hasDot: unreadNotif > 0,
                ),
                const SizedBox(width: 10),
                _SoftIconButton(
                  icon: Icons.chat_bubble_outline_rounded,
                  onTap: onChatTap,
                  tooltip: 'Messages',
                  hasDot: unreadChat > 0,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GradientAvatar extends StatelessWidget {
  const _GradientAvatar({required this.url, required this.onTap});
  final String? url;
  final VoidCallback onTap;

  // Soft pastel gradient — premium/playful (purple → pink → sky).
  static const _ringGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFB39DDB), // soft lavender
      Color(0xFFF8BBD0), // soft pink
      Color(0xFF90CAF9), // soft sky
    ],
  );

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(3),
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: _ringGradient,
        ),
        child: Container(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: context.surf,
          ),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: context.panel,
            ),
            clipBehavior: Clip.antiAlias,
            child: url != null
                ? CachedNetworkImage(
                    imageUrl: url!,
                    fit: BoxFit.cover,
                    memCacheWidth: 132, // 44 * 3
                    memCacheHeight: 132,
                    placeholder: (context, url) =>
                        Container(color: context.panel),
                    errorWidget: (context, url, error) => Icon(
                        Icons.person_rounded,
                        color: context.fgSub,
                        size: 22),
                  )
                : Icon(Icons.person_rounded, color: context.fgSub, size: 22),
          ),
        ),
      ),
    );
  }
}

class _SoftIconButton extends StatefulWidget {
  const _SoftIconButton({
    required this.icon,
    required this.onTap,
    this.tooltip,
    this.hasDot = false,
    this.active = false,
  });

  final IconData icon;
  final VoidCallback onTap;
  final String? tooltip;
  final bool hasDot;
  final bool active;

  @override
  State<_SoftIconButton> createState() => _SoftIconButtonState();
}

class _SoftIconButtonState extends State<_SoftIconButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final restBg = widget.active ? context.ctaBg : context.panel;
    final pressBg = widget.active
        ? context.ctaBg
        : (context.isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE5E7EB));
    final fg = widget.active ? context.ctaFg : context.fg;

    return Tooltip(
      message: widget.tooltip ?? '',
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapCancel: () => setState(() => _pressed = false),
        onTapUp: (_) => setState(() => _pressed = false),
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 130),
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: _pressed ? pressBg : restBg,
            shape: BoxShape.circle,
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(widget.icon, size: 22, color: fg),
              if (widget.hasDot)
                Positioned(
                  top: 11,
                  right: 11,
                  child: Container(
                    width: 9,
                    height: 9,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444),
                      shape: BoxShape.circle,
                      border: Border.all(color: restBg, width: 1.6),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Search suggestion model ───────────────────────────────────────────────────

class _SearchSuggestion {
  const _SearchSuggestion({
    required this.id,
    required this.kind,
    required this.title,
    required this.subtitle,
    this.avatarUrl,
  });
  final String id;
  final String
      kind; // 'players' | 'teams' | 'venues' | 'tournaments' | 'events'
  final String title;
  final String subtitle;
  final String? avatarUrl;

  IconData get icon => switch (kind) {
        'players' => Icons.person_outline_rounded,
        'teams' => Icons.groups_rounded,
        'venues' => Icons.stadium_rounded,
        'tournaments' => Icons.emoji_events_outlined,
        _ => Icons.event_outlined,
      };

  String get route => switch (kind) {
        'players' => '/player/${Uri.encodeComponent(id)}',
        'teams' => '/team/${Uri.encodeComponent(id)}',
        'venues' => '/arena/${Uri.encodeComponent(id)}',
        'tournaments' => '/tournament/${Uri.encodeComponent(id)}',
        _ => '',
      };
}

// ── Expanded search field with live suggestions ───────────────────────────────

class _ExpandedSearchField extends StatefulWidget {
  const _ExpandedSearchField({required this.onCloseTap});

  final VoidCallback onCloseTap;

  @override
  State<_ExpandedSearchField> createState() => _ExpandedSearchFieldState();
}

class _ExpandedSearchFieldState extends State<_ExpandedSearchField> {
  final TextEditingController _controller = TextEditingController();
  final LayerLink _layerLink = LayerLink();
  final Dio _dio = ApiClient.instance.dio;

  Timer? _debounce;
  OverlayEntry? _overlay;
  bool _isFetching = false;

  @override
  void dispose() {
    _debounce?.cancel();
    _removeOverlay();
    _controller.dispose();
    super.dispose();
  }

  void _removeOverlay() {
    _overlay?.remove();
    _overlay = null;
  }

  void _showOverlay(List<_SearchSuggestion> items) {
    _removeOverlay();
    if (items.isEmpty) return;

    final entry = OverlayEntry(
      builder: (ctx) => Positioned(
        width: MediaQuery.of(context).size.width - 32,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: const Offset(0, 60),
          child: Material(
            color: Colors.transparent,
            child: _SuggestionList(
              items: items,
              onTap: _onSuggestionTap,
            ),
          ),
        ),
      ),
    );

    _overlay = entry;
    Overlay.of(context).insert(entry);
  }

  Future<void> _onSuggestionTap(_SearchSuggestion item) async {
    var route = item.route;
    if (item.kind == 'players') {
      final resolvedId = await _resolvePlayerProfileId(item.id);
      if (!mounted) return;
      if (resolvedId == null || resolvedId.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open this profile right now.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
      route = '/player/${Uri.encodeComponent(resolvedId)}';
    }
    final router = GoRouter.of(context);
    _removeOverlay();
    widget.onCloseTap();
    if (route.isNotEmpty) {
      router.push(route);
    }
  }

  void _openSearch([String? submitted]) {
    final q = (submitted ?? _controller.text).trim();
    final router = GoRouter.of(context);
    _removeOverlay();
    widget.onCloseTap();
    if (q.isEmpty) {
      router.push('/search');
      return;
    }
    router.push('/search?q=${Uri.encodeQueryComponent(q)}');
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    final query = value.trim();
    if (query.length < 2) {
      setState(() => _isFetching = false);
      _removeOverlay();
      return;
    }
    setState(() => _isFetching = true);
    _debounce = Timer(const Duration(milliseconds: 280), () => _fetch(query));
  }

  Future<void> _fetch(String query) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.playerSearch,
        queryParameters: {'q': query, 'type': 'all', 'limit': 25},
      );
      if (!mounted) return;
      final suggestions = _parseSuggestions(response.data);
      setState(() => _isFetching = false);
      _showOverlay(suggestions);
    } catch (_) {
      if (!mounted) return;
      setState(() => _isFetching = false);
      _removeOverlay();
    }
  }

  List<_SearchSuggestion> _parseSuggestions(dynamic body) {
    final results = <_SearchSuggestion>[];
    final data = (body is Map ? body['data'] ?? body : {}) as Map;

    void parseSection(
        String kind, List items, _SearchSuggestion Function(Map) mapper) {
      for (final raw in items.take(5)) {
        if (raw is Map) results.add(mapper(raw));
      }
    }

    parseSection(
        'players',
        _asList(data['players']),
        (m) => _SearchSuggestion(
              id: _pickPlayerResultId(m),
              kind: 'players',
              title:
                  '${m['name'] ?? m['displayName'] ?? m['username'] ?? 'Player'}',
              subtitle: '${m['role'] ?? m['city'] ?? ''}',
              avatarUrl: m['avatarUrl'] as String?,
            ));
    parseSection(
        'teams',
        _asList(data['teams']),
        (m) => _SearchSuggestion(
              id: '${m['id'] ?? m['teamId'] ?? ''}',
              kind: 'teams',
              title: '${m['name'] ?? m['teamName'] ?? 'Team'}',
              subtitle: '${m['city'] ?? m['sport'] ?? ''}',
              avatarUrl: m['logoUrl'] as String?,
            ));
    parseSection(
        'venues',
        _asList(data['venues'] ?? data['arenas']),
        (m) => _SearchSuggestion(
              id: '${m['id'] ?? m['arenaId'] ?? ''}',
              kind: 'venues',
              title: '${m['name'] ?? 'Venue'}',
              subtitle: '${m['city'] ?? m['address'] ?? ''}',
            ));
    parseSection(
        'tournaments',
        _asList(data['tournaments']),
        (m) => _SearchSuggestion(
              id: '${m['id'] ?? m['tournamentId'] ?? ''}',
              kind: 'tournaments',
              title: '${m['name'] ?? 'Tournament'}',
              subtitle: '${m['sport'] ?? m['format'] ?? ''}',
            ));
    parseSection(
        'events',
        _asList(data['events']),
        (m) => _SearchSuggestion(
              id: '${m['id'] ?? m['eventId'] ?? ''}',
              kind: 'events',
              title: '${m['name'] ?? m['title'] ?? 'Event'}',
              subtitle: '${m['city'] ?? m['date'] ?? ''}',
            ));

    return results;
  }

  List _asList(dynamic v) => v is List ? v : const [];

  String _pickPlayerResultId(Map raw) {
    final user = _asMap(raw['user']);
    final profile = _asMap(raw['profile']);
    final player = _asMap(raw['player']);
    final playerProfile = _asMap(raw['playerProfile']);
    return _firstNonEmpty([
      _asString(raw['playerProfileId']),
      _asString(raw['profileId']),
      _asString(raw['playerId']),
      _asString(playerProfile['id']),
      _asString(profile['id']),
      _asString(player['id']),
      _asString(user['playerProfileId']),
      _asString(user['profileId']),
      _asString(raw['id']),
      _asString(raw['userId']),
      _asString(raw['user_id']),
      _asString(user['id']),
    ]);
  }

  Future<String?> _resolvePlayerProfileId(String rawId) async {
    final candidates = _uniqueNonEmpty([rawId]);
    if (candidates.isEmpty) return null;

    bool sawNon404Failure = false;
    for (final candidate in candidates) {
      try {
        final response = await _dio.get(
          ApiEndpoints.publicPlayerProfile(candidate),
        );
        final root = _asMap(response.data);
        final data = _asMap(root['data'] ?? root);
        return _firstNonEmpty([
          _asString(data['id']),
          _asString(_asMap(data['profile'])['id']),
          _asString(_asMap(data['playerProfile'])['id']),
          candidate,
        ]);
      } on DioException catch (error) {
        if (error.response?.statusCode != 404) {
          sawNon404Failure = true;
        }
      } catch (_) {
        sawNon404Failure = true;
      }
    }

    if (sawNon404Failure) return candidates.first;
    return null;
  }

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return <String, dynamic>{};
  }

  String _asString(dynamic value) => (value ?? '').toString().trim();

  String _firstNonEmpty(List<String> values) {
    for (final value in values) {
      if (value.trim().isNotEmpty) return value.trim();
    }
    return '';
  }

  List<String> _uniqueNonEmpty(List<String> values) {
    final out = <String>[];
    final seen = <String>{};
    for (final value in values) {
      final normalized = value.trim();
      if (normalized.isEmpty || !seen.add(normalized)) continue;
      out.add(normalized);
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 54,
        decoration: BoxDecoration(
          color: context.cardBg.withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: context.accent.withValues(alpha: 0.45),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: TextField(
          controller: _controller,
          autofocus: true,
          textInputAction: TextInputAction.search,
          onSubmitted: _openSearch,
          onChanged: _onChanged,
          decoration: InputDecoration(
            hintText: 'Search players, teams, venues...',
            hintStyle: TextStyle(
              color: context.fgSub.withValues(alpha: 0.8),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 8),
              child:
                  Icon(Icons.search_rounded, color: context.accent, size: 20),
            ),
            suffixIcon: Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_isFetching)
                    Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          color: context.accent,
                        ),
                      ),
                    ),
                  IconButton(
                    onPressed: _openSearch,
                    splashRadius: 20,
                    icon: Icon(Icons.arrow_forward_rounded,
                        color: context.accent, size: 20),
                  ),
                  const VerticalDivider(width: 1, indent: 14, endIndent: 14),
                  IconButton(
                    onPressed: () {
                      _removeOverlay();
                      widget.onCloseTap();
                    },
                    splashRadius: 20,
                    icon: Icon(Icons.close_rounded,
                        color: context.fgSub, size: 20),
                  ),
                ],
              ),
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
          ),
          style: TextStyle(
            color: context.fg,
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.2,
          ),
        ),
      ),
    );
  }
}

// ── Suggestion list overlay widget ───────────────────────────────────────────

const _kFilterOrder = ['players', 'teams', 'venues', 'tournaments', 'events'];

const _kFilterLabels = {
  'players': 'Players',
  'teams': 'Teams',
  'venues': 'Venues',
  'tournaments': 'Tournaments',
  'events': 'Events',
};

const _kFilterIcons = {
  'players': Icons.person_outline_rounded,
  'teams': Icons.groups_rounded,
  'venues': Icons.stadium_rounded,
  'tournaments': Icons.emoji_events_outlined,
  'events': Icons.event_outlined,
};

class _SuggestionList extends StatefulWidget {
  const _SuggestionList({required this.items, required this.onTap});

  final List<_SearchSuggestion> items;
  final ValueChanged<_SearchSuggestion> onTap;

  @override
  State<_SuggestionList> createState() => _SuggestionListState();
}

class _SuggestionListState extends State<_SuggestionList> {
  String? _activeKind; // null = All

  List<String> get _availableKinds {
    final seen = <String>{};
    for (final s in widget.items) {
      if (_kFilterOrder.contains(s.kind)) seen.add(s.kind);
    }
    return _kFilterOrder.where(seen.contains).toList();
  }

  List<_SearchSuggestion> get _visible {
    final filtered = _activeKind == null
        ? widget.items
        : widget.items.where((s) => s.kind == _activeKind).toList();
    return filtered.take(6).toList();
  }

  @override
  Widget build(BuildContext context) {
    final kinds = _availableKinds;
    final visible = _visible;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: context.surf,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: context.stroke,
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Filter chips ───────────────────────────────────────────────
          if (kinds.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _FilterChip(
                      label: 'All',
                      icon: Icons.travel_explore_rounded,
                      selected: _activeKind == null,
                      onTap: () => setState(() => _activeKind = null),
                    ),
                    ...kinds.map((k) => Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: _FilterChip(
                            label: _kFilterLabels[k]!,
                            icon: _kFilterIcons[k]!,
                            count:
                                widget.items.where((s) => s.kind == k).length,
                            selected: _activeKind == k,
                            onTap: () => setState(() =>
                                _activeKind = _activeKind == k ? null : k),
                          ),
                        )),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Divider(height: 1, color: context.stroke.withValues(alpha: 0.3)),
          ],
          // ── Results ────────────────────────────────────────────────────
          if (visible.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  'No ${_kFilterLabels[_activeKind] ?? 'results'} found',
                  style: TextStyle(
                    color: context.fgSub,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: visible.length,
              separatorBuilder: (_, __) => Divider(
                height: 1,
                color: context.stroke.withValues(alpha: 0.25),
                indent: 16,
                endIndent: 16,
              ),
              itemBuilder: (context, index) {
                final item = visible[index];
                return _SuggestionTile(
                  item: item,
                  onTap: widget.onTap,
                );
              },
            ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
    this.count,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  final int? count;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? context.accent.withValues(alpha: 0.12)
              : context.cardBg.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: selected
                ? context.accent.withValues(alpha: 0.4)
                : context.stroke.withValues(alpha: 0.6),
            width: 1.1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: selected ? context.accent : context.fgSub,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: selected ? context.accent : context.fgSub,
                fontSize: 12,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                letterSpacing: -0.1,
              ),
            ),
            if (count != null && count! > 0) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: selected
                      ? context.accent.withValues(alpha: 0.15)
                      : context.stroke.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    color: selected ? context.accent : context.fgSub,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
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

class _SuggestionTile extends StatelessWidget {
  const _SuggestionTile({required this.item, required this.onTap});

  final _SearchSuggestion item;
  final ValueChanged<_SearchSuggestion> onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onTap(item),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: context.accent.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                image: item.avatarUrl != null
                    ? DecorationImage(
                        image: CachedNetworkImageProvider(item.avatarUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: item.avatarUrl == null
                  ? Icon(item.icon, color: context.accent, size: 20)
                  : null,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: context.fg,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 3),
                  if (item.subtitle.isNotEmpty)
                    Text(
                      item.subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: context.fgSub.withValues(alpha: 0.85),
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                color: context.fgSub.withValues(alpha: 0.4), size: 18),
          ],
        ),
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton(
      {required this.icon, required this.onTap, this.tooltip});
  final IconData icon;
  final VoidCallback onTap;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip ?? '',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: context.fgSub, size: 20),
        ),
      ),
    );
  }
}

// ── Bottom Nav (ERP) ──────────────────────────────────────────────────────────

class _PremiumBottomNav extends StatelessWidget {
  const _PremiumBottomNav(
      {required this.currentIndex, required this.items, required this.onTap});
  final int currentIndex;
  final List<_NavItem> items;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;
    return Container(
      height: 60 + bottom,
      padding: EdgeInsets.fromLTRB(0, 8, 0, 8 + bottom),
      decoration: BoxDecoration(
        color: context.surf,
        border: Border(
            top: BorderSide(
                color: context.stroke.withValues(alpha: 0.6), width: 0.5)),
      ),
      child: Row(
        children: List.generate(items.length, (index) {
          if (index == 2) {
            return Expanded(
              child: GestureDetector(
                onTap: () => onTap(index),
                behavior: HitTestBehavior.opaque,
                child: const _CenterMatchButton(),
              ),
            );
          }
          final isSelected = currentIndex == index;
          return Expanded(
            child: GestureDetector(
              onTap: () => onTap(index),
              behavior: HitTestBehavior.opaque,
              child: _NavButton(isSelected: isSelected, item: items[index]),
            ),
          );
        }),
      ),
    );
  }
}

class _CenterMatchButton extends StatelessWidget {
  const _CenterMatchButton();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: context.ctaBg,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: context.ctaBg.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          Icons.bolt_rounded,
          size: 24,
          color: context.ctaFg,
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({required this.isSelected, required this.item});
  final bool isSelected;
  final _NavItem item;

  @override
  Widget build(BuildContext context) {
    final activeColor = context.accent;
    final inactiveColor = context.fgSub.withValues(alpha: 0.55);
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          isSelected ? item.activeIcon : item.icon,
          size: 24,
          color: isSelected ? activeColor : inactiveColor,
        ),
        const SizedBox(height: 3),
        Text(
          item.label,
          style: TextStyle(
            color: isSelected ? activeColor : inactiveColor,
            fontSize: 10,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// ── Body Switcher ─────────────────────────────────────────────────────────────

class _HomeBody extends StatelessWidget {
  const _HomeBody({
    required this.currentIndex,
    required this.currentCity,
    required this.onSwitchToMatch,
    this.onLocationTap,
    this.currentLatitude,
    this.currentLongitude,
  });
  final int currentIndex;
  final String currentCity;
  final VoidCallback onSwitchToMatch;
  final VoidCallback? onLocationTap;
  final double? currentLatitude;
  final double? currentLongitude;

  @override
  Widget build(BuildContext context) {
    return IndexedStack(
      index: currentIndex,
      children: [
        // 0: Home — no SafeArea (appBar handles it)
        PlayerHomeBody(onFindMatch: onSwitchToMatch),
        // 1: Play
        SafeArea(bottom: false, child: PlayTab(currentCity: currentCity)),
        // 2: Match — persistent lobby, no SafeArea (page handles it)
        const MatchmakingTabPage(),
        // 3: Book
        SafeArea(
          bottom: false,
          child: BookingModuleTab(
            currentCity: currentCity,
            currentLatitude: currentLatitude,
            currentLongitude: currentLongitude,
            onLocationTap: onLocationTap,
          ),
        ),
        // 4: Store
        SafeArea(
          bottom: false,
          child: StorefrontScreen(
            location: StorefrontLocation(
              city: currentCity == 'Fetching...' ? null : currentCity,
              latitude: currentLatitude,
              longitude: currentLongitude,
            ),
          ),
        ),
      ],
    );
  }
}

class _NavItem {
  const _NavItem({required this.icon, required this.label, IconData? activeIcon})
      : activeIcon = activeIcon ?? icon;
  final IconData icon;
  final IconData activeIcon;
  final String label;
}

class _BookingShellScreen extends StatefulWidget {
  const _BookingShellScreen({
    required this.currentCity,
    this.currentLatitude,
    this.currentLongitude,
  });

  final String currentCity;
  final double? currentLatitude;
  final double? currentLongitude;

  @override
  State<_BookingShellScreen> createState() => _BookingShellScreenState();
}

class _BookingShellScreenState extends State<_BookingShellScreen> {
  final _profileRepository = ProfileRepository();
  String? _selectedLocationLabel;

  Future<void> _openLocationSheet() async {
    final initialText = _selectedLocationLabel ?? widget.currentCity;
    final searchCtrl = TextEditingController(text: initialText);
    final searchFocus = FocusNode();
    Timer? modalDebounce;
    List<CitySuggestion> modalSuggestions = const [];
    bool modalSearching = false;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            Future<void> handleQuery(String value) async {
              modalDebounce?.cancel();
              final query = value.trim();
              if (query.length < 2) {
                setSheetState(() {
                  modalSuggestions = const [];
                  modalSearching = false;
                });
                return;
              }

              setSheetState(() => modalSearching = true);
              modalDebounce =
                  Timer(const Duration(milliseconds: 220), () async {
                try {
                  final suggestions =
                      await _profileRepository.searchCities(query);
                  if (!mounted || searchCtrl.text.trim() != query) return;
                  setSheetState(() {
                    modalSuggestions = suggestions;
                    modalSearching = false;
                  });
                } catch (_) {
                  if (!mounted || searchCtrl.text.trim() != query) return;
                  setSheetState(() {
                    modalSuggestions = const [];
                    modalSearching = false;
                  });
                }
              });
            }

            return Container(
              decoration: BoxDecoration(
                color: context.bg,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(32)),
              ),
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 12),
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: context.stroke.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Location',
                            style: TextStyle(
                              color: context.fg,
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Find facilities in your city',
                            style: TextStyle(
                              color: context.fgSub,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 32),
                          Container(
                            height: 52,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: context.panel.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.search_rounded,
                                    color: context.fgSub, size: 20),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: TextField(
                                    controller: searchCtrl,
                                    focusNode: searchFocus,
                                    autofocus: true,
                                    onChanged: handleQuery,
                                    cursorColor: context.accent,
                                    style: TextStyle(
                                      color: context.fg,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: 'Search for a city...',
                                      hintStyle: TextStyle(
                                        color: context.fgSub
                                            .withValues(alpha: 0.5),
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      border: InputBorder.none,
                                      isCollapsed: true,
                                    ),
                                  ),
                                ),
                                if (modalSearching)
                                  SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: context.accent,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.4,
                      ),
                      child: _BookingLocationSuggestionsList(
                        suggestions: modalSuggestions,
                        onSelected: (suggestion) {
                          setState(() {
                            _selectedLocationLabel = suggestion.label;
                          });
                          Navigator.of(sheetContext).pop();
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    modalDebounce?.cancel();
    searchCtrl.dispose();
    searchFocus.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final effectiveLocation =
        (_selectedLocationLabel?.trim().isNotEmpty ?? false)
            ? _selectedLocationLabel!.trim()
            : widget.currentCity;
    final locationParts = _locationLines(effectiveLocation);
    final useDeviceCoordinates = _selectedLocationLabel == null;

    return Scaffold(
      backgroundColor: context.bg,
      appBar: AppBar(
        backgroundColor: context.bg,
        elevation: 0,
        toolbarHeight: 72,
        titleSpacing: 16,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Booking',
              style: TextStyle(
                color: context.fg,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            GestureDetector(
              onTap: _openLocationSheet,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.location_on_rounded,
                      color: context.accent, size: 16),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      locationParts.$1.toUpperCase(),
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: context.fg,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.keyboard_arrow_down_rounded,
                      color: context.fgSub, size: 16),
                ],
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        top: false,
        child: BookingModuleTab(
          currentCity: effectiveLocation,
          currentLatitude: useDeviceCoordinates ? widget.currentLatitude : null,
          currentLongitude:
              useDeviceCoordinates ? widget.currentLongitude : null,
          onLocationTap: _openLocationSheet,
        ),
      ),
    );
  }

  (String, String?) _locationLines(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) {
      return ('Fetching location', null);
    }

    final parts = trimmed
        .split(',')
        .map((part) => part.trim())
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) {
      return ('Fetching location', null);
    }
    if (parts.length == 1) {
      return (parts.first, null);
    }
    return (parts.first, parts.sublist(1).join(', '));
  }
}

class _BookingLocationSuggestionsList extends StatelessWidget {
  const _BookingLocationSuggestionsList({
    required this.suggestions,
    required this.onSelected,
  });

  final List<CitySuggestion> suggestions;
  final ValueChanged<CitySuggestion> onSelected;

  @override
  Widget build(BuildContext context) {
    if (suggestions.isEmpty) return const SizedBox.shrink();

    return ListView.separated(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: suggestions.length,
      separatorBuilder: (_, __) => Divider(
        height: 1,
        color: context.stroke.withValues(alpha: 0.3),
      ),
      itemBuilder: (context, index) {
        final item = suggestions[index];
        return InkWell(
          onTap: () => onSelected(item),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.city,
                        style: TextStyle(
                          color: context.fg,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.state,
                        style: TextStyle(
                          color: context.fgSub,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_outward_rounded,
                  size: 18,
                  color: context.fgSub.withValues(alpha: 0.5),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SupportSheet extends StatelessWidget {
  const _SupportSheet();

  @override
  Widget build(BuildContext context) {
    final items = const [
      (
        icon: Icons.help_outline_rounded,
        label: 'Help center',
        sub: 'Browse FAQs and guides'
      ),
      (
        icon: Icons.mail_outline_rounded,
        label: 'Email us',
        sub: 'support@swing.app'
      ),
      (
        icon: Icons.bug_report_outlined,
        label: 'Report a bug',
        sub: 'Tell us what' "'" 's broken'
      ),
      (
        icon: Icons.chat_bubble_outline_rounded,
        label: 'Live chat',
        sub: 'Mon–Fri, 10am–7pm IST'
      ),
    ];
    return Container(
      decoration: BoxDecoration(
        color: context.surf,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(
          20, 12, 20, 24 + MediaQuery.of(context).padding.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: context.stroke,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'Support',
            style: TextStyle(
              color: context.fg,
              fontSize: 22,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'How can we help?',
            style: TextStyle(
              color: context.fgSub,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 18),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Material(
                  color: const Color(0xFFF1F2F5),
                  borderRadius: BorderRadius.circular(16),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => Navigator.of(context).pop(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 14),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: context.surf,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(item.icon, size: 20, color: context.fg),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.label,
                                  style: TextStyle(
                                    color: context.fg,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.2,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  item.sub,
                                  style: TextStyle(
                                    color: context.fgSub,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.chevron_right_rounded,
                              color: context.fgSub.withValues(alpha: 0.7),
                              size: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              )),
        ],
      ),
    );
  }
}

class _SearchOverlay extends StatefulWidget {
  const _SearchOverlay({required this.onClose});
  final VoidCallback onClose;

  @override
  State<_SearchOverlay> createState() => _SearchOverlayState();
}

class _SearchOverlayState extends State<_SearchOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  final TextEditingController _ctrl = TextEditingController();
  final FocusNode _focus = FocusNode();
  final Dio _dio = ApiClient.instance.dio;

  Timer? _debounce;
  bool _loading = false;
  List<_SearchSuggestion> _suggestions = const [];
  String? _activeKind;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
    _fade = CurvedAnimation(parent: _anim, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, -0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _anim, curve: Curves.easeOutCubic));
    _anim.forward();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focus.requestFocus();
    });
  }

  @override
  void dispose() {
    _anim.dispose();
    _debounce?.cancel();
    _ctrl.dispose();
    _focus.dispose();
    super.dispose();
  }

  Future<void> _close() async {
    await _anim.reverse();
    widget.onClose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    final query = value.trim();
    if (query.length < 2) {
      setState(() {
        _suggestions = const [];
        _loading = false;
      });
      return;
    }
    setState(() => _loading = true);
    _debounce = Timer(const Duration(milliseconds: 280), () => _fetch(query));
  }

  Future<void> _fetch(String query) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.playerSearch,
        queryParameters: {'q': query, 'type': 'all', 'limit': 25},
      );
      if (!mounted) return;
      setState(() {
        _suggestions = _parseSuggestions(response.data);
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _suggestions = const [];
        _loading = false;
      });
    }
  }

  List<_SearchSuggestion> _parseSuggestions(dynamic body) {
    final results = <_SearchSuggestion>[];
    final data = (body is Map ? body['data'] ?? body : {}) as Map;

    void section(String kind, List items, _SearchSuggestion Function(Map) map) {
      for (final raw in items.take(5)) {
        if (raw is Map) results.add(map(raw));
      }
    }

    List asList(dynamic v) => v is List ? v : const [];

    section(
        'players',
        asList(data['players']),
        (m) => _SearchSuggestion(
              id: '${m['id'] ?? m['userId'] ?? ''}',
              kind: 'players',
              title:
                  '${m['name'] ?? m['displayName'] ?? m['username'] ?? 'Player'}',
              subtitle: '${m['role'] ?? m['city'] ?? ''}',
              avatarUrl: m['avatarUrl'] as String?,
            ));
    section(
        'teams',
        asList(data['teams']),
        (m) => _SearchSuggestion(
              id: '${m['id'] ?? m['teamId'] ?? ''}',
              kind: 'teams',
              title: '${m['name'] ?? m['teamName'] ?? 'Team'}',
              subtitle: '${m['city'] ?? m['sport'] ?? ''}',
              avatarUrl: m['logoUrl'] as String?,
            ));
    section(
        'venues',
        asList(data['venues'] ?? data['arenas']),
        (m) => _SearchSuggestion(
              id: '${m['id'] ?? m['arenaId'] ?? ''}',
              kind: 'venues',
              title: '${m['name'] ?? 'Venue'}',
              subtitle: '${m['city'] ?? m['address'] ?? ''}',
            ));
    section(
        'tournaments',
        asList(data['tournaments']),
        (m) => _SearchSuggestion(
              id: '${m['id'] ?? m['tournamentId'] ?? ''}',
              kind: 'tournaments',
              title: '${m['name'] ?? 'Tournament'}',
              subtitle: '${m['sport'] ?? m['format'] ?? ''}',
            ));
    section(
        'events',
        asList(data['events']),
        (m) => _SearchSuggestion(
              id: '${m['id'] ?? m['eventId'] ?? ''}',
              kind: 'events',
              title: '${m['name'] ?? m['title'] ?? 'Event'}',
              subtitle: '${m['city'] ?? m['date'] ?? ''}',
            ));

    return results;
  }

  void _open(_SearchSuggestion item) async {
    await _close();
    if (!mounted) return;
    if (item.route.isNotEmpty) GoRouter.of(context).push(item.route);
  }

  void _submitFull() async {
    final q = _ctrl.text.trim();
    await _close();
    if (!mounted) return;
    GoRouter.of(context).push(
      q.isEmpty ? '/search' : '/search?q=${Uri.encodeQueryComponent(q)}',
    );
  }

  @override
  Widget build(BuildContext context) {
    final available = const [
      'players',
      'teams',
      'venues',
      'tournaments',
      'events'
    ].where((k) => _suggestions.any((s) => s.kind == k)).toList();
    final visible = _activeKind == null
        ? _suggestions
        : _suggestions.where((s) => s.kind == _activeKind).toList();

    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          // Tap-out backdrop (no dim)
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _close,
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: FadeTransition(
              opacity: _fade,
              child: SlideTransition(
                position: _slide,
                child: GestureDetector(
                  onTap: () {},
                  child: Container(
                    color: context.surf,
                    child: SafeArea(
                      bottom: false,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Search field row — flat, matches top bar height
                          SizedBox(
                            height: 76,
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(20, 0, 8, 0),
                              child: Row(
                                children: [
                                  Icon(Icons.search_rounded,
                                      color: context.fgSub, size: 22),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: TextField(
                                      controller: _ctrl,
                                      focusNode: _focus,
                                      textInputAction: TextInputAction.search,
                                      onChanged: _onChanged,
                                      onSubmitted: (_) => _submitFull(),
                                      cursorColor: context.fg,
                                      style: TextStyle(
                                        color: context.fg,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      decoration: InputDecoration(
                                        hintText:
                                            'Search players, teams, venues…',
                                        hintStyle: TextStyle(
                                          color: context.fgSub,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w400,
                                        ),
                                        filled: false,
                                        border: InputBorder.none,
                                        enabledBorder: InputBorder.none,
                                        focusedBorder: InputBorder.none,
                                        disabledBorder: InputBorder.none,
                                        errorBorder: InputBorder.none,
                                        focusedErrorBorder: InputBorder.none,
                                        isCollapsed: true,
                                        contentPadding: EdgeInsets.zero,
                                      ),
                                    ),
                                  ),
                                  if (_loading)
                                    Padding(
                                      padding: const EdgeInsets.only(right: 12),
                                      child: SizedBox(
                                        width: 14,
                                        height: 14,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 1.6,
                                            color: context.fgSub),
                                      ),
                                    ),
                                  GestureDetector(
                                    onTap: _close,
                                    behavior: HitTestBehavior.opaque,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 14, vertical: 4),
                                      child: Text(
                                        'Cancel',
                                        style: TextStyle(
                                          color: context.fg,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // Hairline divider under search
                          Container(height: 1, color: context.stroke),
                          // Filter chips (only when results exist)
                          if (available.isNotEmpty)
                            Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(20, 12, 20, 12),
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: [
                                    _MinimalChip(
                                      label: 'All',
                                      selected: _activeKind == null,
                                      onTap: () =>
                                          setState(() => _activeKind = null),
                                    ),
                                    ...available.map((k) => Padding(
                                          padding:
                                              const EdgeInsets.only(left: 16),
                                          child: _MinimalChip(
                                            label: _kFilterLabels[k]!,
                                            selected: _activeKind == k,
                                            onTap: () => setState(() =>
                                                _activeKind = _activeKind == k
                                                    ? null
                                                    : k),
                                          ),
                                        )),
                                  ],
                                ),
                              ),
                            ),
                          // Results
                          if (visible.isNotEmpty)
                            ConstrainedBox(
                              constraints: BoxConstraints(
                                maxHeight:
                                    MediaQuery.of(context).size.height * 0.6,
                              ),
                              child: ListView.separated(
                                shrinkWrap: true,
                                padding: EdgeInsets.zero,
                                itemCount: visible.length,
                                separatorBuilder: (_, __) => Container(
                                  height: 1,
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 20),
                                  color: context.stroke,
                                ),
                                itemBuilder: (ctx, i) => _SuggestionTile(
                                  item: visible[i],
                                  onTap: _open,
                                ),
                              ),
                            )
                          else if (_ctrl.text.trim().length >= 2 && !_loading)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 28),
                              child: Center(
                                child: Text(
                                  'No results',
                                  style: TextStyle(
                                    color: context.fgSub,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
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
        ],
      ),
    );
  }
}

class _MinimalChip extends StatelessWidget {
  const _MinimalChip({
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
      behavior: HitTestBehavior.opaque,
      child: Text(
        label,
        style: TextStyle(
          color: selected ? context.fg : context.fgSub,
          fontSize: 13,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          decoration: selected ? TextDecoration.underline : null,
          decorationThickness: 2,
          decorationColor: context.fg,
        ),
      ),
    );
  }
}

class _SideNavigation extends ConsumerStatefulWidget {
  const _SideNavigation({super.key});

  @override
  ConsumerState<_SideNavigation> createState() => _SideNavigationState();
}

class _SideNavigationState extends ConsumerState<_SideNavigation> {
  void _openSupport(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const _SupportSheet(),
    );
  }

  Future<void> _logout() async {
    final shouldLogout = await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            backgroundColor: context.surf,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
              side: BorderSide(color: context.stroke.withValues(alpha: 0.2)),
            ),
            title: Text(
              'Logout',
              style: TextStyle(
                color: context.fg,
                fontWeight: FontWeight.w700,
              ),
            ),
            content: const Text('Are you sure you want to logout?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: Text('Cancel', style: TextStyle(color: context.fgSub)),
              ),
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: Text('Logout',
                    style: TextStyle(
                        color: context.danger, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ) ??
        false;
    if (!shouldLogout) return;
    if (!mounted) return;
    await ref.read(authControllerProvider.notifier).signOut();
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark;
    final profileData = ref.watch(profileControllerProvider).data;

    return Drawer(
      backgroundColor: Colors.transparent,
      elevation: 0,
      width: 280,
      child: Stack(
        children: [
          // Minimalist Glass
          ClipRRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: context.bg.withValues(alpha: 0.9),
                ),
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  // Clean Profile Header
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            Navigator.pop(context);
                            context.push('/profile');
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Row(
                            children: [
                              _GradientAvatar(
                                url: profileData?.identity.avatarUrl,
                                onTap: () {
                                  Navigator.pop(context);
                                  context.push('/profile');
                                },
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      profileData?.identity.fullName ?? 'Player',
                                      style: TextStyle(
                                        color: context.fg,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: -0.5,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      '@${profileData?.identity.swingId ?? 'unknown'}',
                                      style: TextStyle(
                                        color: context.fgSub,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (profileData != null) ...[
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: () {
                            showModalBottomSheet<void>(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (_) => ProfileQrSheet(
                                  data: profileData, initialIndex: 0),
                            );
                          },
                          icon: Icon(Icons.qr_code_2_rounded,
                              color: context.fg, size: 24),
                          visualDensity: VisualDensity.compact,
                        ),
                      ],
                    ],
                  ),

                  const SizedBox(height: 60),

                  // Minimalist Nav
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.zero,
                      child: Column(
                        children: [
                          _SideNavItem(
                            label: 'Bookings',
                            icon: Icons.calendar_month_outlined,
                            onTap: () {
                              Navigator.pop(context);
                              context.push('/bookings');
                            },
                          ),
                          _SideNavItem(
                            label: 'Find Friends',
                            icon: Icons.person_add_outlined,
                            onTap: () {
                              Navigator.pop(context);
                              context.push('/recommended-connections');
                            },
                          ),
                          _SideNavItem(
                            label: 'Go Live',
                            icon: Icons.sensors_rounded,
                            onTap: () {
                              Navigator.pop(context);
                              context.push('/host');
                            },
                          ),
                          _SideNavItem(
                            label: 'Start a match',
                            icon: Icons.add_circle_outline_rounded,
                            onTap: () {
                              Navigator.pop(context);
                              context.push('/create-match');
                            },
                          ),
                          _SideNavItem(
                            label: 'Host tournament',
                            icon: Icons.emoji_events_outlined,
                            onTap: () {
                              Navigator.pop(context);
                              context.push('/create-tournament');
                            },
                          ),
                          _SideNavItem(
                            label: 'My teams',
                            icon: Icons.groups_outlined,
                            onTap: () {
                              Navigator.pop(context);
                              context.push('/create-team');
                            },
                          ),
                          _SideNavItem(
                            label: 'Subscription',
                            icon: Icons.workspace_premium_outlined,
                            onTap: () {
                              Navigator.pop(context);
                              context.push('/pro-plans');
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Bottom items
                  _SideNavItem(
                    label: isDark ? 'Light Mode' : 'Dark Mode',
                    icon: isDark
                        ? Icons.wb_sunny_outlined
                        : Icons.dark_mode_outlined,
                    onTap: () {
                      ref.read(themeModeProvider.notifier).state =
                          isDark ? ThemeMode.light : ThemeMode.dark;
                    },
                  ),
                  _SideNavItem(
                    label: 'Support',
                    icon: Icons.headset_mic_outlined,
                    onTap: () {
                      Navigator.pop(context);
                      _openSupport(context);
                    },
                  ),

                  // Minimal Logout
                  InkWell(
                    onTap: _logout,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: Row(
                        children: [
                          Icon(Icons.power_settings_new_rounded,
                              color: context.fgSub, size: 18),
                          const SizedBox(width: 12),
                          Text(
                            'Sign out',
                            style: TextStyle(
                              color: context.fgSub,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
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

class _SideNavItem extends StatelessWidget {
  const _SideNavItem({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 32),
      child: InkWell(
        onTap: onTap,
        highlightColor: Colors.transparent,
        splashColor: Colors.transparent,
        child: Row(
          children: [
            Icon(icon, color: context.fg, size: 22),
            const SizedBox(width: 20),
            Text(
              label,
              style: TextStyle(
                color: context.fg,
                fontSize: 16,
                fontWeight: FontWeight.w500,
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


