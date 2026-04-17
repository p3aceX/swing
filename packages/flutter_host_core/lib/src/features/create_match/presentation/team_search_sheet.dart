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
  late final TextEditingController _searchController;
  List<Map<String, dynamic>> _teams = const [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.initialQuery);
    _loadTeams();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadTeams() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final repo = ref.read(hostTeamRepositoryProvider);
      final query = _searchController.text.trim();
      final teams = query.isEmpty
          ? await repo.getMyTeams()
          : await repo.searchTeams(query);
      if (!mounted) return;
      setState(() => _teams = teams);
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _selectTeam(Map<String, dynamic> team) {
    widget.onSelected?.call(team);
    Navigator.of(context).pop(team);
  }

  @override
  Widget build(BuildContext context) {
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
                textInputAction: TextInputAction.search,
                onSubmitted: (_) => _loadTeams(),
                decoration: InputDecoration(
                  hintText: 'Search teams...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: IconButton(
                    onPressed: _isLoading ? null : _loadTeams,
                    icon: _isLoading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.arrow_forward),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Flexible(
                child: _error != null
                    ? _MessageState(message: _error!, isError: true)
                    : _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : _teams.isEmpty
                            ? _MessageState(
                                message: _searchController.text.trim().isEmpty
                                    ? 'No teams found for this account.'
                                    : 'No teams matched your search.',
                              )
                            : ListView.separated(
                                shrinkWrap: true,
                                itemCount: _teams.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 8),
                                itemBuilder: (context, index) {
                                  final team = _teams[index];
                                  final title =
                                      '${team['name'] ?? team['teamName'] ?? 'Unnamed Team'}';
                                  final subtitle = [
                                    '${team['shortName'] ?? ''}'.trim(),
                                    '${team['city'] ?? ''}'.trim(),
                                    '${team['teamType'] ?? ''}'.trim(),
                                  ]
                                      .where((value) => value.isNotEmpty)
                                      .join(' • ');
                                  final initials = _initials(title);
                                  return ListTile(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      side: BorderSide(color: context.stroke),
                                    ),
                                    leading: CircleAvatar(
                                      backgroundColor: context.accentBg,
                                      foregroundColor: context.fg,
                                      child: Text(initials),
                                    ),
                                    title: Text(
                                      title,
                                      style: TextStyle(
                                        color: context.fg,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    subtitle: subtitle.isEmpty
                                        ? null
                                        : Text(
                                            subtitle,
                                            style:
                                                TextStyle(color: context.fgSub),
                                          ),
                                    trailing: Icon(
                                      Icons.chevron_right,
                                      color: context.fgSub,
                                    ),
                                    onTap: () => _selectTeam(team),
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

class _MessageState extends StatelessWidget {
  const _MessageState({
    required this.message,
    this.isError = false,
  });

  final String message;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isError ? context.danger : context.fgSub,
          ),
        ),
      ),
    );
  }
}

String _initials(String value) {
  final parts = value
      .split(' ')
      .map((part) => part.trim())
      .where((part) => part.isNotEmpty)
      .toList();
  if (parts.isEmpty) return '?';
  if (parts.length == 1) return parts.first.characters.first.toUpperCase();
  return '${parts.first.characters.first}${parts.last.characters.first}'
      .toUpperCase();
}
