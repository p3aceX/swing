import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../repositories/host_team_repository.dart';
import '../../../theme/host_colors.dart';

class TeamSearchSheet extends ConsumerStatefulWidget {
  const TeamSearchSheet({
    super.key,
    this.title = 'Select Team',
    this.initialQuery = '',
    this.onSelected,
  });

  final String title;
  final String initialQuery;
  final ValueChanged<Map<String, dynamic>>? onSelected;

  @override
  ConsumerState<TeamSearchSheet> createState() => _TeamSearchSheetState();
}

class _TeamSearchSheetState extends ConsumerState<TeamSearchSheet> {
  late final TextEditingController _ctrl;
  Timer? _debounce;
  List<Map<String, dynamic>> _results = const [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.initialQuery);
    if (widget.initialQuery.trim().isNotEmpty) _search(widget.initialQuery);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 280), () => _search(value));
  }

  Future<void> _search(String query) async {
    final q = query.trim();
    if (q.isEmpty) {
      setState(() { _results = const []; _isLoading = false; _error = null; });
      return;
    }
    setState(() { _isLoading = true; _error = null; });
    try {
      debugPrint('[TeamSearch] searching q="$q"');
      final rows = await ref.read(hostTeamRepositoryProvider).searchTeams(q);
      debugPrint('[TeamSearch] got ${rows.length} results');
      if (!mounted) return;
      setState(() { _results = rows; _isLoading = false; });
    } catch (e) {
      debugPrint('[TeamSearch] error: $e');
      if (!mounted) return;
      setState(() { _isLoading = false; _error = e.toString(); });
    }
  }

  void _select(Map<String, dynamic> team) {
    widget.onSelected?.call(team);
    Navigator.of(context).pop(team);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
          color: context.cardBg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // ── Header ─────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 8, 0),
              child: Row(
                children: [
                  Text(
                    widget.title,
                    style: TextStyle(
                      color: context.fg,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(Icons.close_rounded, color: context.fgSub, size: 20),
                  ),
                ],
              ),
            ),

            // ── Search bar ─────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
              child: Container(
                height: 46,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: context.panel,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.search_rounded, color: context.fgSub, size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _ctrl,
                        autofocus: true,
                        onChanged: _onChanged,
                        cursorColor: context.accent,
                        style: TextStyle(
                          color: context.fg,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Search by name or city…',
                          hintStyle: TextStyle(color: context.fgSub, fontSize: 14),
                          border: InputBorder.none,
                          isCollapsed: true,
                        ),
                      ),
                    ),
                    if (_isLoading)
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
            ),

            const SizedBox(height: 8),

            // ── Results ────────────────────────────────────────────────────
            Expanded(
              child: _buildBody(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline_rounded, color: context.danger, size: 32),
              const SizedBox(height: 12),
              Text(
                'Search failed',
                style: TextStyle(color: context.fg, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              Text(
                _error!,
                style: TextStyle(color: context.fgSub, fontSize: 12),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () => _search(_ctrl.text),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_ctrl.text.trim().isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(
            'Start typing to search teams',
            style: TextStyle(color: context.fgSub, fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (!_isLoading && _results.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(
            'No teams matched "${_ctrl.text.trim()}"',
            style: TextStyle(color: context.fgSub, fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      itemCount: _results.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) {
        final team = _results[i];
        final name = '${team['name'] ?? team['teamName'] ?? 'Unnamed Team'}';
        final shortName = '${team['shortName'] ?? ''}'.trim();
        final city = '${team['city'] ?? ''}'.trim();
        final teamType = '${team['teamType'] ?? ''}'.trim();
        final logo = '${team['logoUrl'] ?? ''}'.trim();
        final memberCount = team['memberCount'];
        final location = [city].where((e) => e.isNotEmpty).join(', ');

        return GestureDetector(
          onTap: () => _select(team),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: context.panel,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                _Avatar(name: name, logoUrl: logo.isEmpty ? null : logo),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: context.fg,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          if (shortName.isNotEmpty)
                            _Chip(label: shortName),
                          if (location.isNotEmpty)
                            _Chip(
                              label: location,
                              icon: Icons.location_on_rounded,
                            ),
                          if (teamType.isNotEmpty)
                            _Chip(label: _teamTypeLabel(teamType)),
                          if (memberCount != null && memberCount != 0)
                            _Chip(
                              label: '$memberCount players',
                              icon: Icons.person_rounded,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: context.accentBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.add_rounded, color: context.accent, size: 18),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.name, this.logoUrl});
  final String name;
  final String? logoUrl;

  @override
  Widget build(BuildContext context) {
    final initials = _initials(name);
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: context.accentBg,
        borderRadius: BorderRadius.circular(10),
        image: logoUrl != null
            ? DecorationImage(
                image: NetworkImage(logoUrl!),
                fit: BoxFit.cover,
                onError: (_, __) {},
              )
            : null,
      ),
      child: logoUrl == null
          ? Center(
              child: Text(
                initials,
                style: TextStyle(
                  color: context.accent,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            )
          : null,
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, this.icon});
  final String label;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: context.stroke.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 10, color: context.fgSub),
            const SizedBox(width: 3),
          ],
          Text(
            label,
            style: TextStyle(
              color: context.fgSub,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

String _teamTypeLabel(String type) => switch (type.toUpperCase()) {
  'CLUB' => 'Club',
  'CORPORATE' => 'Corporate',
  'ACADEMY' => 'Academy',
  'SCHOOL' => 'School',
  'COLLEGE' => 'College',
  'DISTRICT' => 'District',
  'STATE' => 'State',
  'NATIONAL' => 'National',
  'FRIENDLY' => 'Friendly',
  'GULLY' => 'Gully',
  _ => type,
};

String _initials(String value) {
  final parts = value.trim().split(RegExp(r'\s+'));
  if (parts.isEmpty) return '?';
  if (parts.length == 1) return parts.first.characters.first.toUpperCase();
  return '${parts.first.characters.first}${parts.last.characters.first}'.toUpperCase();
}
