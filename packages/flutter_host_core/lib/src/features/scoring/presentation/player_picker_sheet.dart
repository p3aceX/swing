import 'package:flutter/material.dart';

import '../../../theme/host_colors.dart';
import '../domain/scoring_models.dart';

class PlayerPickerSheet extends StatefulWidget {
  const PlayerPickerSheet({
    super.key,
    required this.title,
    required this.players,
    required this.onSelected,
    this.subtitle,
    this.roleLabelsForPlayer,
    this.onSearchExternal,
  });

  final String title;
  final String? subtitle;
  final List<ScoringMatchPlayer> players;
  final ValueChanged<ScoringMatchPlayer> onSelected;
  final List<String> Function(ScoringMatchPlayer player)? roleLabelsForPlayer;
  final Future<List<ScoringMatchPlayer>> Function(String query)? onSearchExternal;

  @override
  State<PlayerPickerSheet> createState() => _PlayerPickerSheetState();
}

class _PlayerPickerSheetState extends State<PlayerPickerSheet> {
  final _searchController = TextEditingController();
  String _query = '';
  List<ScoringMatchPlayer> _externalPlayers = [];
  bool _isSearchingExternal = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _performExternalSearch() async {
    final callback = widget.onSearchExternal;
    if (callback == null || _query.trim().isEmpty) return;
    setState(() => _isSearchingExternal = true);
    try {
      final result = await callback(_query.trim());
      if (!mounted) return;
      setState(() => _externalPlayers = result);
    } finally {
      if (mounted) setState(() => _isSearchingExternal = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final localFiltered = widget.players.where((p) {
      if (_query.trim().isEmpty) return true;
      final q = _query.trim().toLowerCase();
      return p.name.toLowerCase().contains(q) ||
          (p.phone ?? '').toLowerCase().contains(q);
    }).toList();

    final seen = <String>{...localFiltered.map((p) => p.profileId)};
    final merged = [
      ...localFiltered,
      ..._externalPlayers.where((p) => seen.add(p.profileId)),
    ];

    final screenH = MediaQuery.of(context).size.height;

    return Container(
      constraints: BoxConstraints(maxHeight: screenH * 0.82),
      color: context.bg,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Handle ──────────────────────────────────────────────────────────
          const SizedBox(height: 10),
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: context.stroke,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // ── Header ──────────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 12, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: TextStyle(
                          color: context.fg,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.4,
                        ),
                      ),
                      if (widget.subtitle != null)
                        Text(
                          widget.subtitle!,
                          style: TextStyle(color: context.fgSub, fontSize: 13),
                        ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(Icons.close_rounded, color: context.fgSub, size: 20),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // ── Search field ─────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 42,
                    decoration: BoxDecoration(
                      color: context.cardBg,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (v) => setState(() {
                        _query = v;
                        _externalPlayers = [];
                      }),
                      onSubmitted: (_) => _performExternalSearch(),
                      style: TextStyle(color: context.fg, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Search player...',
                        hintStyle: TextStyle(color: context.fgSub, fontSize: 14),
                        prefixIcon: Icon(Icons.search_rounded, color: context.fgSub, size: 18),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ),
                if (widget.onSearchExternal != null) ...[
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 42,
                    height: 42,
                    child: Material(
                      color: context.cardBg,
                      borderRadius: BorderRadius.circular(10),
                      child: InkWell(
                        onTap: _isSearchingExternal ? null : _performExternalSearch,
                        borderRadius: BorderRadius.circular(10),
                        child: Center(
                          child: _isSearchingExternal
                              ? SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: context.fgSub,
                                  ),
                                )
                              : Icon(Icons.public_rounded, color: context.fgSub, size: 18),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 8),
          Divider(height: 1, color: context.stroke),

          // ── Player list ──────────────────────────────────────────────────────
          Flexible(
            child: merged.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.person_off_rounded, color: context.fgSub, size: 36),
                        const SizedBox(height: 12),
                        Text(
                          'No eligible players found',
                          style: TextStyle(
                            color: context.fgSub,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.only(bottom: 24),
                    itemCount: merged.length,
                    separatorBuilder: (_, __) =>
                        Divider(height: 1, color: context.stroke),
                    itemBuilder: (context, index) {
                      final player = merged[index];
                      final labels =
                          widget.roleLabelsForPlayer?.call(player) ?? const <String>[];
                      final sub = labels.isNotEmpty
                          ? labels.join(' • ')
                          : (player.phone?.isNotEmpty == true ? player.phone! : null);
                      return _PlayerRow(
                        player: player,
                        subtitle: sub,
                        onTap: () => widget.onSelected(player),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _PlayerRow extends StatelessWidget {
  const _PlayerRow({
    required this.player,
    required this.onTap,
    this.subtitle,
  });

  final ScoringMatchPlayer player;
  final String? subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Row(
            children: [
              _Avatar(name: player.name),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      player.name,
                      style: TextStyle(
                        color: context.fg,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle!,
                        style: TextStyle(color: context.fgSub, fontSize: 12),
                      ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: context.fgSub, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.name});

  final String name;

  static const _palette = [
    Color(0xFF1D4ED8),
    Color(0xFF065F46),
    Color(0xFF9333EA),
    Color(0xFFB45309),
    Color(0xFFB91C1C),
    Color(0xFF0F766E),
    Color(0xFF1E40AF),
    Color(0xFF6D28D9),
  ];

  Color _color() {
    final code = name.codeUnits.fold(0, (a, b) => a + b);
    return _palette[code % _palette.length];
  }

  String _initial() =>
      name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: _color(),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        _initial(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
