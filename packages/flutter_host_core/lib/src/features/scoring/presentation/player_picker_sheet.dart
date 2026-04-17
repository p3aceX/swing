import 'package:flutter/material.dart';

import '../../../theme/host_colors.dart';
import '../domain/scoring_models.dart';

class PlayerPickerSheet extends StatefulWidget {
  const PlayerPickerSheet({
    super.key,
    required this.title,
    required this.players,
    required this.onSelected,
    this.roleLabelsForPlayer,
    this.onSearchExternal,
  });

  final String title;
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
    final localFiltered = widget.players.where((player) {
      if (_query.trim().isEmpty) return true;
      final q = _query.trim().toLowerCase();
      return player.name.toLowerCase().contains(q) ||
          (player.phone ?? '').toLowerCase().contains(q);
    }).toList();

    final seen = <String>{...localFiltered.map((p) => p.profileId)};
    final merged = [
      ...localFiltered,
      ..._externalPlayers.where((player) => seen.add(player.profileId)),
    ];

    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
          color: context.cardBg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Text(
                    widget.title,
                    style: TextStyle(
                      color: context.fg,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(Icons.close, color: context.fgSub),
                  ),
                ],
              ),
              TextField(
                controller: _searchController,
                onChanged: (v) => setState(() {
                  _query = v;
                  _externalPlayers = [];
                }),
                onSubmitted: (_) => _performExternalSearch(),
                decoration: InputDecoration(
                  hintText: 'Search by name or phone...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: widget.onSearchExternal == null
                      ? null
                      : IconButton(
                          onPressed: _isSearchingExternal
                              ? null
                              : _performExternalSearch,
                          icon: _isSearchingExternal
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.public),
                        ),
                ),
              ),
              const SizedBox(height: 12),
              Flexible(
                child: merged.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          'No eligible players found.',
                          style: TextStyle(color: context.fgSub),
                        ),
                      )
                    : ListView.separated(
                        shrinkWrap: true,
                        itemCount: merged.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final player = merged[index];
                          final labels =
                              widget.roleLabelsForPlayer?.call(player) ?? const <String>[];
                          return ListTile(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                              side: BorderSide(color: context.stroke),
                            ),
                            title: Text(
                              player.name,
                              style: TextStyle(
                                color: context.fg,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            subtitle: labels.isEmpty
                                ? (player.phone == null || player.phone!.isEmpty
                                    ? null
                                    : Text(player.phone!))
                                : Text(labels.join(' • ')),
                            onTap: () => widget.onSelected(player),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
