import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../repositories/host_player_repository.dart';
import '../../../repositories/host_team_repository.dart';
import '../../../theme/host_colors.dart';

class PlayerManageSheet extends ConsumerStatefulWidget {
  const PlayerManageSheet({
    super.key,
    required this.teamId,
    this.teamName,
    this.title = 'Manage Players',
  });

  final String teamId;
  final String? teamName;
  final String title;

  @override
  ConsumerState<PlayerManageSheet> createState() => _PlayerManageSheetState();
}

class _PlayerManageSheetState extends ConsumerState<PlayerManageSheet> {
  final _searchController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _swingIdController = TextEditingController();

  List<Map<String, dynamic>> _players = const [];
  List<Map<String, dynamic>> _searchResults = const [];
  bool _isLoadingPlayers = true;
  bool _isSearching = false;
  bool _isSubmitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPlayers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _swingIdController.dispose();
    super.dispose();
  }

  Future<void> _loadPlayers() async {
    setState(() {
      _isLoadingPlayers = true;
      _error = null;
    });
    try {
      final players = await ref
          .read(hostTeamRepositoryProvider)
          .getTeamPlayers(widget.teamId);
      if (!mounted) return;
      setState(() => _players = players);
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _isLoadingPlayers = false);
    }
  }

  Future<void> _searchPlayers() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      setState(() => _searchResults = const []);
      return;
    }
    setState(() {
      _isSearching = true;
      _error = null;
    });
    try {
      final rows =
          await ref.read(hostPlayerRepositoryProvider).searchPlayers(query);
      if (!mounted) return;
      final existingIds = _players
          .map((player) => _playerId(player))
          .where((id) => id.isNotEmpty)
          .toSet();
      setState(() {
        _searchResults =
            rows.where((row) => !existingIds.contains(_playerId(row))).toList();
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  Future<void> _quickAdd({
    String? profileId,
    String? name,
    String? phone,
    String? swingId,
  }) async {
    setState(() {
      _isSubmitting = true;
      _error = null;
    });
    try {
      await ref.read(hostTeamRepositoryProvider).quickAddPlayer(
            widget.teamId,
            profileId: profileId,
            name: name,
            phone: phone,
            swingId: swingId,
          );
      _nameController.clear();
      _phoneController.clear();
      _swingIdController.clear();
      _searchController.clear();
      _searchResults = const [];
      await _loadPlayers();
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _removePlayer(Map<String, dynamic> player) async {
    final playerId = _playerId(player);
    if (playerId.isEmpty) return;
    setState(() {
      _isSubmitting = true;
      _error = null;
    });
    try {
      await ref.read(hostTeamRepositoryProvider).removePlayer(
            widget.teamId,
            playerId,
          );
      await _loadPlayers();
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: TextStyle(
                            color: context.fg,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        if ((widget.teamName ?? '').trim().isNotEmpty)
                          Text(
                            widget.teamName!.trim(),
                            style: TextStyle(color: context.fgSub),
                          ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(Icons.close, color: context.fgSub),
                  ),
                ],
              ),
              if ((_error ?? '').isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    _error!,
                    style: TextStyle(color: context.danger),
                  ),
                ),
              _SectionCard(
                title: 'Current Squad',
                child: SizedBox(
                  height: 220,
                  child: _isLoadingPlayers
                      ? const Center(child: CircularProgressIndicator())
                      : _players.isEmpty
                          ? _EmptyState(
                              message:
                                  'No players have been added to this team yet.',
                            )
                          : ListView.separated(
                              itemCount: _players.length,
                              separatorBuilder: (_, __) =>
                                  Divider(color: context.stroke, height: 1),
                              itemBuilder: (context, index) {
                                final player = _players[index];
                                return ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: CircleAvatar(
                                    backgroundColor: context.accentBg,
                                    child:
                                        Text(_avatarText(_playerName(player))),
                                  ),
                                  title: Text(
                                    _playerName(player),
                                    style: TextStyle(
                                      color: context.fg,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  subtitle: Text(
                                    [
                                      _playerPhone(player),
                                      '${player['swingId'] ?? player['playerCode'] ?? ''}'
                                          .trim(),
                                    ]
                                        .where((value) => value.isNotEmpty)
                                        .join(' • '),
                                  ),
                                  trailing: IconButton(
                                    onPressed: _isSubmitting
                                        ? null
                                        : () => _removePlayer(player),
                                    icon: Icon(
                                      Icons.remove_circle_outline,
                                      color: context.danger,
                                    ),
                                  ),
                                );
                              },
                            ),
                ),
              ),
              const SizedBox(height: 12),
              _SectionCard(
                title: 'Add Existing Player',
                child: Column(
                  children: [
                    TextField(
                      controller: _searchController,
                      textInputAction: TextInputAction.search,
                      onSubmitted: (_) => _searchPlayers(),
                      decoration: InputDecoration(
                        hintText: 'Search by name, phone, or Swing ID...',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: IconButton(
                          onPressed: _isSearching ? null : _searchPlayers,
                          icon: _isSearching
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.arrow_forward),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 180,
                      child: _searchResults.isEmpty
                          ? _EmptyState(
                              message: _searchController.text.trim().isEmpty
                                  ? 'Search to add an existing Swing player.'
                                  : 'No matching players found.',
                            )
                          : ListView.separated(
                              itemCount: _searchResults.length,
                              separatorBuilder: (_, __) =>
                                  Divider(color: context.stroke, height: 1),
                              itemBuilder: (context, index) {
                                final player = _searchResults[index];
                                return ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  title: Text(
                                    _playerName(player),
                                    style: TextStyle(
                                      color: context.fg,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  subtitle: Text(
                                    [
                                      _playerPhone(player),
                                      '${player['city'] ?? ''}'.trim(),
                                    ]
                                        .where((value) => value.isNotEmpty)
                                        .join(' • '),
                                  ),
                                  trailing: FilledButton(
                                    onPressed: _isSubmitting
                                        ? null
                                        : () => _quickAdd(
                                              profileId: _playerId(player),
                                            ),
                                    child: const Text('Add'),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _SectionCard(
                title: 'Quick Add Guest',
                child: Column(
                  children: [
                    TextField(
                      controller: _nameController,
                      decoration:
                          const InputDecoration(labelText: 'Player name'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(labelText: 'Phone'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _swingIdController,
                      decoration: const InputDecoration(
                        labelText: 'Swing ID',
                        hintText: 'Optional if phone or name is provided',
                      ),
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: FilledButton(
                        onPressed: _isSubmitting
                            ? null
                            : () => _quickAdd(
                                  name: _nameController.text,
                                  phone: _phoneController.text,
                                  swingId: _swingIdController.text,
                                ),
                        child: Text(_isSubmitting ? 'Saving...' : 'Quick add'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.panel,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: context.stroke),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: context.fg,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(color: context.fgSub),
        ),
      ),
    );
  }
}

String _playerId(Map<String, dynamic> player) =>
    '${player['profileId'] ?? player['id'] ?? player['playerId'] ?? ''}'.trim();

String _playerName(Map<String, dynamic> player) =>
    '${player['name'] ?? player['fullName'] ?? player['playerName'] ?? 'Unknown Player'}';

String _playerPhone(Map<String, dynamic> player) =>
    '${player['phone'] ?? player['phoneNumber'] ?? ''}'.trim();

String _avatarText(String value) {
  final trimmed = value.trim();
  if (trimmed.isEmpty) return '?';
  final parts = trimmed.split(' ').where((part) => part.isNotEmpty).toList();
  if (parts.length == 1) return parts.first.characters.first.toUpperCase();
  return '${parts.first.characters.first}${parts.last.characters.first}'
      .toUpperCase();
}
