import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../contracts/host_path_config.dart';
import '../../../providers/host_dio_provider.dart';
import '../../../repositories/host_team_repository.dart';
import '../../../theme/host_colors.dart';
import '../../create_match/data/create_match_repository.dart';
import '../../create_match/presentation/toss_screen.dart';

// ══════════════════════════════════════════════════════════════════════════════
// PUBLIC SCREEN
// ══════════════════════════════════════════════════════════════════════════════

/// Two-tab Playing 11 picker. Loads each team's full roster, lets the user
/// select 11 players + assign captain, vice-captain and wicket-keeper, then
/// PUTs `/matches/:id/players`.
///
/// On success the screen pushes the shared [TossScreen] with [onTossCompleted]
/// passed straight through, so callers wire scoring navigation in one place.
class PlayingElevenScreen extends ConsumerStatefulWidget {
  const PlayingElevenScreen({
    super.key,
    required this.matchId,
    required this.teamAId,
    required this.teamAName,
    required this.teamBId,
    required this.teamBName,
    this.hasImpactPlayer = false,
    this.onTossCompleted,
    this.onBack,
  });

  final String matchId;
  final String teamAId;
  final String teamAName;
  final String teamBId;
  final String teamBName;
  final bool hasImpactPlayer;

  /// Forwarded to the [TossScreen] this screen pushes after submit. Lets the
  /// host route into its scoring screen on success.
  final void Function(BuildContext context, String matchId)? onTossCompleted;

  /// Custom back action for the AppBar. Defaults to `Navigator.maybePop`.
  final VoidCallback? onBack;

  @override
  ConsumerState<PlayingElevenScreen> createState() =>
      _PlayingElevenScreenState();
}

class _PlayingElevenScreenState extends ConsumerState<PlayingElevenScreen>
    with SingleTickerProviderStateMixin {
  static const _squadSize = 11;

  late final TabController _tabs;

  _RosterState _teamA = const _RosterState.loading();
  _RosterState _teamB = const _RosterState.loading();
  final Set<String> _hiddenA = <String>{};
  final Set<String> _hiddenB = <String>{};
  bool _submitting = false;
  String? _submitError;

  @override
  void initState() {
    super.initState();
    debugPrint('[PlayingEleven] initState matchId=${widget.matchId} teamAId=${widget.teamAId} teamBId=${widget.teamBId}');
    _tabs = TabController(length: 2, vsync: this);
    _loadBoth();
  }

  @override
  void dispose() {
    debugPrint('[PlayingEleven] dispose matchId=${widget.matchId}');
    _tabs.dispose();
    super.dispose();
  }

  Future<void> _loadBoth() async {
    await Future.wait([
      _loadSide(isA: true),
      _loadSide(isA: false),
    ]);
  }

  Future<void> _loadSide({required bool isA}) async {
    final teamId = isA ? widget.teamAId : widget.teamBId;
    final side = isA ? 'A' : 'B';
    debugPrint('[PlayingEleven] _loadSide $side teamId=$teamId');
    if (teamId.isEmpty) {
      setState(() {
        final empty = _RosterState.ready(players: const [], selected: const {});
        if (isA) {
          _teamA = empty;
        } else {
          _teamB = empty;
        }
      });
      return;
    }
    setState(() {
      if (isA) {
        _teamA = const _RosterState.loading();
      } else {
        _teamB = const _RosterState.loading();
      }
    });
    try {
      final roster =
          await ref.read(hostTeamRepositoryProvider).getTeamRoster(teamId);
      if (!mounted) return;
      final players = roster.players
          .map((row) => _RosterPlayer.fromJson(row))
          .where((p) => p.profileId.isNotEmpty)
          .where((p) => !(isA ? _hiddenA : _hiddenB).contains(p.profileId))
          .toList();
      final loaded = _RosterState.ready(
        players: players,
        selected: _prefillSelected(
          current: isA ? _teamA.asLoaded : _teamB.asLoaded,
          players: players,
        ),
        captainId: roster.captainId,
        viceCaptainId: roster.viceCaptainId,
        wicketKeeperId: roster.wicketKeeperId,
      );
      setState(() {
        if (isA) {
          _teamA = loaded;
        } else {
          _teamB = loaded;
        }
      });
    } catch (error) {
      debugPrint('[PlayingEleven] _loadSide $side ERROR teamId=$teamId: $error');
      if (error is Exception) {
        // ignore: avoid_dynamic_calls
        final resp = (error as dynamic).response;
        if (resp != null) {
          debugPrint('[PlayingEleven] status=${resp.statusCode} body=${resp.data}');
        }
      }
      if (!mounted) return;
      setState(() {
        final errored = _RosterState.error(error.toString());
        if (isA) {
          _teamA = errored;
        } else {
          _teamB = errored;
        }
      });
    }
  }

  void _updateLoaded({
    required bool isA,
    required _LoadedRoster Function(_LoadedRoster current) transform,
  }) {
    final current = (isA ? _teamA : _teamB).asLoaded;
    if (current == null) return;
    final next = _RosterState.withLoaded(transform(current));
    setState(() {
      if (isA) {
        _teamA = next;
      } else {
        _teamB = next;
      }
    });
  }

  // ── Actions ─────────────────────────────────────────────────────────────

  void _toggleSelect(bool isA, String profileId) {
    _updateLoaded(
      isA: isA,
      transform: (loaded) {
        final picked = {...loaded.selected};
        if (picked.contains(profileId)) {
          picked.remove(profileId);
          return loaded.rebuild(
            selected: picked,
            captainId:
                loaded.captainId == profileId ? null : loaded.captainId,
            viceCaptainId: loaded.viceCaptainId == profileId
                ? null
                : loaded.viceCaptainId,
            wicketKeeperId: loaded.wicketKeeperId == profileId
                ? null
                : loaded.wicketKeeperId,
          );
        }
        if (picked.length >= _squadSize) return loaded;
        picked.add(profileId);
        return loaded.rebuild(selected: picked);
      },
    );
  }

  // ── Add player ──────────────────────────────────────────────────────────

  Future<void> _addPlayer(bool isA) async {
    final teamId = isA ? widget.teamAId : widget.teamBId;
    final results = await showModalBottomSheet<List<_RosterPlayer>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _AddPlayerSheet(),
    );
    if (results == null || results.isEmpty || !mounted) return;

    final toAppend = <_RosterPlayer>[];
    for (final result in results) {
      if (teamId.isNotEmpty) {
        try {
          final added = await ref.read(hostTeamRepositoryProvider).quickAddPlayer(
                teamId,
                profileId: (result.profileId.isNotEmpty &&
                        !result.profileId.startsWith('local:'))
                    ? result.profileId
                    : null,
                name: result.name,
                phone: result.phone?.trim().isNotEmpty == true ? result.phone!.trim() : null,
              );
          final profileId = '${added['data']?['profileId'] ?? added['profileId'] ?? result.profileId}'.trim();
          toAppend.add(
            _RosterPlayer(
              profileId: profileId.isNotEmpty ? profileId : result.profileId,
              teamPlayerId: '${added['data']?['id'] ?? added['id'] ?? profileId}'.trim(),
              userId: result.userId,
              name: result.name,
              avatarUrl: result.avatarUrl,
              swingId: result.swingId,
            ),
          );
          continue;
        } catch (_) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Could not add ${result.name}. Please retry.')),
            );
          }
          continue;
        }
      }
      toAppend.add(result);
    }
    _appendPlayers(isA, toAppend);
  }

  void _appendPlayers(bool isA, List<_RosterPlayer> playersToAdd) {
    if (playersToAdd.isEmpty) return;
    _updateLoaded(
      isA: isA,
      transform: (loaded) {
        final players = [...loaded.players];
        final sel = {...loaded.selected};
        for (final player in playersToAdd) {
          if (player.profileId.isEmpty) continue;
          if (isA) {
            _hiddenA.remove(player.profileId);
          } else {
            _hiddenB.remove(player.profileId);
          }
          final exists = players.any((p) => p.profileId == player.profileId);
          if (!exists) players.add(player);
          if (sel.length < _squadSize) sel.add(player.profileId);
        }
        return loaded.rebuild(players: players, selected: sel);
      },
    );
  }

  Future<void> _removePlayer(bool isA, _RosterPlayer player) async {
    if (isA) {
      _hiddenA.add(player.profileId);
    } else {
      _hiddenB.add(player.profileId);
    }
    _updateLoaded(
      isA: isA,
      transform: (loaded) {
        final nextPlayers =
            loaded.players.where((p) => p.profileId != player.profileId).toList();
        final nextSelected = {...loaded.selected}..remove(player.profileId);
        return loaded.rebuild(
          players: nextPlayers,
          selected: nextSelected,
          captainId:
              loaded.captainId == player.profileId ? null : loaded.captainId,
          viceCaptainId: loaded.viceCaptainId == player.profileId
              ? null
              : loaded.viceCaptainId,
          wicketKeeperId: loaded.wicketKeeperId == player.profileId
              ? null
              : loaded.wicketKeeperId,
        );
      },
    );
  }

  Set<String> _prefillSelected({
    required _LoadedRoster? current,
    required List<_RosterPlayer> players,
  }) {
    final available = players.map((p) => p.profileId).toSet();
    if (current != null) {
      final kept = current.selected.where(available.contains).toSet();
      if (kept.isNotEmpty) return kept;
    }
    return {for (final p in players.take(_squadSize)) p.profileId};
  }

  void _setRole(bool isA, String profileId, _Role role) {
    _updateLoaded(
      isA: isA,
      transform: (loaded) {
        if (!loaded.selected.contains(profileId)) return loaded;

        String? captain = loaded.captainId;
        String? vc = loaded.viceCaptainId;
        String? wk = loaded.wicketKeeperId;

        switch (role) {
          case _Role.captain:
            captain = captain == profileId ? null : profileId;
            if (vc == profileId) vc = null;
            break;
          case _Role.viceCaptain:
            vc = vc == profileId ? null : profileId;
            if (captain == profileId) captain = null;
            break;
          case _Role.wicketKeeper:
            wk = wk == profileId ? null : profileId;
            break;
        }
        return loaded.rebuild(
          captainId: captain,
          viceCaptainId: vc,
          wicketKeeperId: wk,
        );
      },
    );
  }

  Future<void> _continue() async {
    final a = _teamA.asLoaded;
    final b = _teamB.asLoaded;
    if (a == null || b == null || !a.isComplete || !b.isComplete) return;

    setState(() {
      _submitting = true;
      _submitError = null;
    });
    try {
      debugPrint('[PlayingEleven] setPlayingEleven matchId=${widget.matchId} teamA=${a.selected.length} teamB=${b.selected.length}');
      await ref
          .read(hostCreateMatchRepositoryProvider)
          .setPlayingEleven(
            widget.matchId,
            teamA: HostTeamEleven(
              playerIds: a.selected.toList(),
              captainId: a.captainId,
              viceCaptainId: a.viceCaptainId,
              wicketKeeperId: a.wicketKeeperId,
            ),
            teamB: HostTeamEleven(
              playerIds: b.selected.toList(),
              captainId: b.captainId,
              viceCaptainId: b.viceCaptainId,
              wicketKeeperId: b.wicketKeeperId,
            ),
          );
      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => TossScreen(
            matchId: widget.matchId,
            teamAName: widget.teamAName,
            teamBName: widget.teamBName,
            onCompleted: widget.onTossCompleted,
          ),
        ),
      );
    } catch (error) {
      // ignore: avoid_dynamic_calls
      final resp = (error as dynamic).response;
      final status = resp?.statusCode;
      final body = resp?.data;
      debugPrint('[PlayingEleven] setPlayingEleven ERROR status=$status body=$body');
      if (!mounted) return;
      String msg;
      if (body is Map) {
        final err = body['error'];
        msg = (err is Map ? err['message'] : null) ??
            '${body['message'] ?? body['error'] ?? error}';
      } else {
        msg = 'Could not save playing XI. Please try again.';
      }
      setState(() => _submitError = msg);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final a = _teamA.asLoaded;
    final b = _teamB.asLoaded;
    final aComplete = a?.isComplete ?? false;
    final bComplete = b?.isComplete ?? false;
    final canSubmit = aComplete && bComplete && !_submitting;

    return Scaffold(
      backgroundColor: context.bg,
      appBar: AppBar(
        backgroundColor: context.bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: 0,
        leading: IconButton(
          onPressed: () {
            final onBack = widget.onBack;
            if (onBack != null) {
              onBack();
            } else {
              Navigator.of(context).maybePop();
            }
          },
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: context.fg, size: 18),
        ),
        title: Text(
          'Playing 11',
          style: TextStyle(
            color: context.fg,
            fontSize: 17,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: AnimatedBuilder(
            animation: _tabs,
            builder: (_, __) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: context.surf,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: TabBar(
                    controller: _tabs,
                    indicator: BoxDecoration(
                      color: context.accent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerColor: Colors.transparent,
                    labelColor: Theme.of(context).colorScheme.onPrimary,
                    unselectedLabelColor: context.fgSub,
                    labelStyle: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.2,
                    ),
                    unselectedLabelStyle: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                    tabs: [
                      _TabChip(
                        name: widget.teamAName,
                        selectedCount: a?.selected.length ?? 0,
                        total: _squadSize,
                        complete: aComplete,
                      ),
                      _TabChip(
                        name: widget.teamBName,
                        selectedCount: b?.selected.length ?? 0,
                        total: _squadSize,
                        complete: bComplete,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [
          _RosterPane(
            state: _teamA,
            onRetry: () => _loadSide(isA: true),
            onToggleSelect: (id) => _toggleSelect(true, id),
            onSetRole: (id, role) => _setRole(true, id, role),
            onRemovePlayer: (p) => _removePlayer(true, p),
            onAddPlayer: () => _addPlayer(true),
          ),
          _RosterPane(
            state: _teamB,
            onRetry: () => _loadSide(isA: false),
            onToggleSelect: (id) => _toggleSelect(false, id),
            onSetRole: (id, role) => _setRole(false, id, role),
            onRemovePlayer: (p) => _removePlayer(false, p),
            onAddPlayer: () => _addPlayer(false),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        minimum: const EdgeInsets.fromLTRB(20, 0, 20, 14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_submitError != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text(
                  _submitError!,
                  style: TextStyle(color: context.danger, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ),
            _ContinueCta(
              label: _submitting ? 'Saving…' : 'Continue to toss',
              enabled: canSubmit,
              onTap: _continue,
              missingSummary: _missingSummary(a: a, b: b),
            ),
          ],
        ),
      ),
    );
  }

  String? _missingSummary({_LoadedRoster? a, _LoadedRoster? b}) {
    final gaps = <String>[];
    for (final entry in {widget.teamAName: a, widget.teamBName: b}.entries) {
      final state = entry.value;
      if (state == null) continue;
      final missing = <String>[];
      final remaining = _squadSize - state.selected.length;
      if (remaining > 0) missing.add('$remaining more');
      if (state.captainId == null) missing.add('captain');
      if (state.viceCaptainId == null) missing.add('vice-captain');
      if (state.wicketKeeperId == null) missing.add('wicket-keeper');
      if (missing.isNotEmpty) {
        gaps.add('${entry.key}: ${missing.join(', ')}');
      }
    }
    return gaps.isEmpty ? null : gaps.join(' · ');
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// ROSTER PANE
// ══════════════════════════════════════════════════════════════════════════════

class _RosterPane extends StatelessWidget {
  const _RosterPane({
    required this.state,
    required this.onRetry,
    required this.onToggleSelect,
    required this.onSetRole,
    required this.onRemovePlayer,
    this.onAddPlayer,
  });

  final _RosterState state;
  final VoidCallback onRetry;
  final ValueChanged<String> onToggleSelect;
  final void Function(String profileId, _Role role) onSetRole;
  final ValueChanged<_RosterPlayer> onRemovePlayer;
  final VoidCallback? onAddPlayer;

  @override
  Widget build(BuildContext context) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.error != null) {
      return _ErrorState(message: state.error!, onRetry: onRetry);
    }
    final loaded = state.asLoaded;
    if (loaded == null || loaded.players.isEmpty) {
      return _EmptyState(onRetry: onRetry, onAddPlayer: onAddPlayer);
    }

    // rows: [0] = status strip, [1] = add player button, [2..] = players
    final playerCount = loaded.players.length;
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
      itemCount: playerCount + 2,
      separatorBuilder: (_, i) =>
          i == 0 ? const SizedBox(height: 14) : const SizedBox(height: 10),
      itemBuilder: (_, i) {
        if (i == 0) return _StatusStrip(loaded: loaded);
        if (i == 1) {
          if (onAddPlayer == null) return const SizedBox.shrink();
          return Padding(
            padding: const EdgeInsets.only(top: 2, bottom: 2),
            child: FilledButton.icon(
              onPressed: onAddPlayer,
              icon: const Icon(Icons.person_search_rounded, size: 16),
              label: const Text('Add Player (search name, phone, swing id)'),
              style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, 46),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          );
        }
        final player = loaded.players[i - 2];
        if (i >= 2) {
          final isSelected = loaded.selected.contains(player.profileId);
          return _PlayerRow(
            player: player,
            isSelected: isSelected,
            canPick: isSelected || loaded.selected.length < 11,
            roles: loaded.rolesFor(player.profileId),
            onToggleSelect: () => onToggleSelect(player.profileId),
            onSetRole: (role) => onSetRole(player.profileId, role),
            onRemove: () => onRemovePlayer(player),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class _StatusStrip extends StatelessWidget {
  const _StatusStrip({required this.loaded});
  final _LoadedRoster loaded;

  @override
  Widget build(BuildContext context) {
    final count = loaded.selected.length;
    final accent = context.accent;

    Widget pill({
      required String label,
      required bool filled,
      required IconData icon,
    }) {
      final fg = filled ? accent : context.fgSub;
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        decoration: BoxDecoration(
          color: filled ? accent.withValues(alpha: 0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: filled
                ? accent.withValues(alpha: 0.35)
                : context.fgSub.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: fg, size: 11),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: fg,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      );
    }

    return Row(
      children: [
        pill(
          label: '$count/11',
          filled: count == 11,
          icon: count == 11 ? Icons.check_circle_rounded : Icons.people_rounded,
        ),
        const SizedBox(width: 6),
        pill(
          label: 'C',
          filled: loaded.captainId != null,
          icon: Icons.star_rounded,
        ),
        const SizedBox(width: 6),
        pill(
          label: 'VC',
          filled: loaded.viceCaptainId != null,
          icon: Icons.star_half_rounded,
        ),
        const SizedBox(width: 6),
        pill(
          label: 'WK',
          filled: loaded.wicketKeeperId != null,
          icon: Icons.sports_handball_rounded,
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// PLAYER ROW
// ══════════════════════════════════════════════════════════════════════════════

class _PlayerRow extends StatelessWidget {
  const _PlayerRow({
    required this.player,
    required this.isSelected,
    required this.canPick,
    required this.roles,
    required this.onToggleSelect,
    required this.onSetRole,
    required this.onRemove,
  });

  final _RosterPlayer player;
  final bool isSelected;
  final bool canPick;
  final Set<_Role> roles;
  final VoidCallback onToggleSelect;
  final void Function(_Role) onSetRole;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final dimmed = !canPick;
    final accent = context.accent;

    return Opacity(
      opacity: dimmed ? 0.45 : 1,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        decoration: BoxDecoration(
          color: context.surf,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? accent.withValues(alpha: 0.4)
                : Colors.transparent,
            width: isSelected ? 1.2 : 0,
          ),
        ),
        child: Column(
          children: [
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                onTap: canPick || isSelected ? onToggleSelect : null,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 14, 12),
                  child: Row(
                    children: [
                      _Checkbox(checked: isSelected),
                      const SizedBox(width: 12),
                      _Avatar(
                        name: player.name,
                        url: player.avatarUrl,
                        size: 40,
                        accent: accent,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              player.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: context.fg,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            if (player.swingId.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                player.swingId,
                                style: TextStyle(
                                  color: context.fgSub
                                      .withValues(alpha: 0.7),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: onRemove,
                        icon: Icon(
                          Icons.remove_circle_outline_rounded,
                          color: context.fgSub.withValues(alpha: 0.8),
                          size: 20,
                        ),
                        tooltip: 'Remove from XI',
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (isSelected) ...[
              Container(
                height: 0.6,
                color: context.stroke,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: _RoleToggle(
                        label: 'Captain',
                        icon: Icons.star_rounded,
                        selected: roles.contains(_Role.captain),
                        onTap: () => onSetRole(_Role.captain),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _RoleToggle(
                        label: 'Vice',
                        icon: Icons.star_half_rounded,
                        selected: roles.contains(_Role.viceCaptain),
                        onTap: () => onSetRole(_Role.viceCaptain),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _RoleToggle(
                        label: 'Keeper',
                        icon: Icons.sports_handball_rounded,
                        selected: roles.contains(_Role.wicketKeeper),
                        onTap: () => onSetRole(_Role.wicketKeeper),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _RoleToggle extends StatelessWidget {
  const _RoleToggle({
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
    return Material(
      color: selected ? accent.withValues(alpha: 0.16) : Colors.transparent,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected
                  ? accent.withValues(alpha: 0.45)
                  : context.fgSub.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 14, color: selected ? accent : context.fgSub),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: selected ? accent : context.fgSub,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Checkbox extends StatelessWidget {
  const _Checkbox({required this.checked});
  final bool checked;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      width: 22,
      height: 22,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: checked ? context.accent : Colors.transparent,
        borderRadius: BorderRadius.circular(7),
        border: Border.all(
          color: checked
              ? context.accent
              : context.fgSub.withValues(alpha: 0.4),
          width: 1.4,
        ),
      ),
      child: checked
          ? Icon(Icons.check_rounded, color: Theme.of(context).colorScheme.onPrimary, size: 15)
          : null,
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({
    required this.name,
    required this.url,
    required this.size,
    required this.accent,
  });
  final String name;
  final String? url;
  final double size;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final initial = name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase();
    Widget initialsWidget() => Center(
          child: Text(
            initial,
            style: TextStyle(
              color: accent,
              fontSize: size * 0.42,
              fontWeight: FontWeight.w900,
            ),
          ),
        );

    return Container(
      width: size,
      height: size,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.14),
        shape: BoxShape.circle,
      ),
      child: (url ?? '').isEmpty
          ? initialsWidget()
          : CachedNetworkImage(
              imageUrl: url!,
              fit: BoxFit.cover,
              errorWidget: (_, __, ___) => initialsWidget(),
              placeholder: (_, __) => initialsWidget(),
            ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// TAB CHIP + CTA
// ══════════════════════════════════════════════════════════════════════════════

class _TabChip extends StatelessWidget implements PreferredSizeWidget {
  const _TabChip({
    required this.name,
    required this.selectedCount,
    required this.total,
    required this.complete,
  });

  final String name;
  final int selectedCount;
  final int total;
  final bool complete;

  @override
  Size get preferredSize => const Size.fromHeight(40);

  @override
  Widget build(BuildContext context) {
    return Tab(
      height: 38,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
            child: Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: context.fg.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '$selectedCount/$total',
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          if (complete) ...[
            const SizedBox(width: 6),
            const Icon(Icons.check_circle_rounded, size: 13),
          ],
        ],
      ),
    );
  }
}

class _ContinueCta extends StatelessWidget {
  const _ContinueCta({
    required this.label,
    required this.enabled,
    required this.onTap,
    this.missingSummary,
  });

  final String label;
  final bool enabled;
  final VoidCallback onTap;
  final String? missingSummary;

  @override
  Widget build(BuildContext context) {
    final ctaBg = context.ctaBg;
    final ctaFg = context.ctaFg;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (missingSummary != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              'Still needed — $missingSummary',
              style: TextStyle(
                color: context.fgSub.withValues(alpha: 0.9),
                fontSize: 11.5,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        SizedBox(
          width: double.infinity,
          height: 54,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            decoration: BoxDecoration(
              color: enabled ? ctaBg : ctaBg.withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(16),
              boxShadow: enabled
                  ? [
                      BoxShadow(
                        color: ctaBg.withValues(alpha: 0.25),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: enabled ? onTap : null,
                child: Center(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: enabled ? ctaFg : ctaFg.withValues(alpha: 0.55),
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// EMPTY / ERROR
// ══════════════════════════════════════════════════════════════════════════════

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.wifi_off_rounded, color: context.fgSub, size: 36),
            const SizedBox(height: 12),
            Text(
              'Could not load roster',
              style: TextStyle(
                color: context.fg,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: context.fgSub, fontSize: 12),
            ),
            const SizedBox(height: 16),
            OutlinedButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onRetry, this.onAddPlayer});
  final VoidCallback onRetry;
  final VoidCallback? onAddPlayer;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.group_outlined, color: context.fgSub, size: 36),
            const SizedBox(height: 12),
            Text(
              'No players in this squad yet',
              style: TextStyle(
                color: context.fg,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              'Search and add players directly below.',
              style: TextStyle(color: context.fgSub, fontSize: 12),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            if (onAddPlayer != null)
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: onAddPlayer,
                  icon: const Icon(Icons.person_add_rounded, size: 16),
                  label: const Text('Add Player'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
            const SizedBox(height: 10),
            OutlinedButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// ADD PLAYER SHEET
// ══════════════════════════════════════════════════════════════════════════════

class _AddPlayerSheet extends ConsumerStatefulWidget {
  const _AddPlayerSheet();

  @override
  ConsumerState<_AddPlayerSheet> createState() => _AddPlayerSheetState();
}

class _AddPlayerSheetState extends ConsumerState<_AddPlayerSheet> {
  final _ctrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  List<_RosterPlayer> _results = [];
  Set<String> _pickedIds = {};
  bool _loading = false;

  @override
  void dispose() {
    _ctrl.dispose();
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _search(String q) async {
    if (_nameCtrl.text.trim().isEmpty) {
      _nameCtrl.text = q.trim();
    }
    if (q.trim().length < 2) {
      setState(() {
        _results = [];
        _pickedIds = {};
        _loading = false;
      });
      return;
    }
    setState(() => _loading = true);
    try {
      final dio = ref.read(hostDioProvider);
      final paths = ref.read(hostPathConfigProvider);
      final resp = await dio.get<Map<String, dynamic>>(
        paths.playerSearch,
        queryParameters: {'q': q.trim(), 'type': 'players', 'limit': 20},
      );
      final body = resp.data ?? {};
      final data = body['data'];
      final raw = (data is Map ? data['players'] : null) as List? ?? [];
      if (!mounted) return;
      setState(() {
        _results = raw
            .whereType<Map>()
            .map((p) => _RosterPlayer.fromJson(Map<String, dynamic>.from(p)))
            .toList();
        _pickedIds = {};
        _loading = false;
      });
    } on DioException catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _digitsOnly(String input) =>
      input.replaceAll(RegExp(r'[^0-9]'), '');

  Future<void> _createQuickPlayer() async {
    final name = _nameCtrl.text.trim();
    final phone = _phoneCtrl.text.trim();
    if (name.length < 2) return;
    if (phone.length < 8) return;

    // Prevent duplicate quick-create when mobile already exists.
    final normalizedPhone = _digitsOnly(phone);
    if (normalizedPhone.length >= 8) {
      await _search(normalizedPhone);
      final hasExact = _results.any(
        (p) => _digitsOnly(p.phone ?? '') == normalizedPhone,
      );
      if (!mounted) return;
      if (hasExact) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Player with this mobile already exists. Select from results.'),
          ),
        );
        return;
      }
    }

    Navigator.of(context).pop([
      _RosterPlayer(
        profileId: 'local:${DateTime.now().microsecondsSinceEpoch}',
        teamPlayerId: '',
        userId: '',
        name: name,
        avatarUrl: null,
        swingId: '',
        phone: phone,
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final maxH = MediaQuery.of(context).size.height * 0.82;
    final accent = context.accent;
    final query = _ctrl.text.trim();
    final canSearch = query.length >= 2;

    return Container(
      constraints: BoxConstraints(maxHeight: maxH),
      decoration: BoxDecoration(
        color: context.bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 4),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: context.fgSub.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Add Player',
                  style: TextStyle(
                    color: context.fg,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Search first. If not found, create quickly.',
                  style: TextStyle(
                    color: context.fgSub,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
            child: TextField(
              controller: _ctrl,
              autofocus: true,
              onChanged: _search,
              style: TextStyle(color: context.fg, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Search by name, phone or Swing ID…',
                hintStyle: TextStyle(color: context.fgSub, fontSize: 14),
                prefixIcon: Icon(Icons.search_rounded, color: context.fgSub, size: 20),
                suffixIcon: query.isEmpty
                    ? null
                    : IconButton(
                        onPressed: () {
                          _ctrl.clear();
                          setState(() {
                            _results = [];
                            _pickedIds = {};
                            _loading = false;
                          });
                        },
                        icon: Icon(Icons.close_rounded, color: context.fgSub, size: 18),
                      ),
                filled: true,
                fillColor: context.surf,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          Flexible(
            child: _loading
                ? const Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(child: CircularProgressIndicator()),
                  )
                : _results.isEmpty
                    ? SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              canSearch
                                  ? 'No players found'
                                  : 'Type at least 2 characters to search',
                              style: TextStyle(
                                color: context.fgSub,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.left,
                            ),
                            if (canSearch) ...[
                              const SizedBox(height: 12),
                              TextField(
                                controller: _nameCtrl,
                                textCapitalization: TextCapitalization.words,
                                style: TextStyle(
                                  color: context.fg,
                                  fontSize: 14,
                                ),
                                decoration: InputDecoration(
                                  labelText: 'Player name',
                                  labelStyle: TextStyle(
                                    color: context.fgSub,
                                    fontSize: 13,
                                  ),
                                  filled: true,
                                  fillColor: context.surf,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              TextField(
                                controller: _phoneCtrl,
                                keyboardType: TextInputType.phone,
                                style: TextStyle(
                                  color: context.fg,
                                  fontSize: 14,
                                ),
                                decoration: InputDecoration(
                                  labelText: 'Mobile number',
                                  labelStyle: TextStyle(
                                    color: context.fgSub,
                                    fontSize: 13,
                                  ),
                                  filled: true,
                                  fillColor: context.surf,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                child: FilledButton.icon(
                                  onPressed: _createQuickPlayer,
                                  icon: const Icon(Icons.person_add_alt_rounded, size: 16),
                                  label: const Text('Create Player'),
                                  style: FilledButton.styleFrom(
                                    minimumSize: const Size(double.infinity, 46),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                        shrinkWrap: true,
                        itemCount: _results.length,
                        itemBuilder: (_, i) {
                          final p = _results[i];
                          final picked = _pickedIds.contains(p.profileId);
                          return InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () {
                              setState(() {
                                if (picked) {
                                  _pickedIds.remove(p.profileId);
                                } else {
                                  _pickedIds.add(p.profileId);
                                }
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 11),
                              child: Row(
                                children: [
                                  _Avatar(
                                    name: p.name,
                                    url: p.avatarUrl,
                                    size: 38,
                                    accent: accent,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          p.name,
                                          style: TextStyle(
                                            color: context.fg,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        if (p.swingId.isNotEmpty)
                                          Text(
                                            p.swingId,
                                            style: TextStyle(
                                              color: context.fgSub,
                                              fontSize: 11,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  Icon(Icons.add_circle_outline_rounded,
                                      color: picked ? accent : context.fgSub, size: 20),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
          if (_results.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _pickedIds.isEmpty
                      ? null
                      : () {
                          final selected = _results
                              .where((p) => _pickedIds.contains(p.profileId))
                              .toList();
                          Navigator.of(context).pop(selected);
                        },
                  child: Text('Add Selected (${_pickedIds.length})'),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// MODELS
// ══════════════════════════════════════════════════════════════════════════════

enum _Role { captain, viceCaptain, wicketKeeper }

class _RosterPlayer {
  const _RosterPlayer({
    required this.profileId,
    required this.teamPlayerId,
    required this.userId,
    required this.name,
    required this.avatarUrl,
    required this.swingId,
    this.phone,
  });

  final String profileId;
  final String teamPlayerId;
  final String userId;
  final String name;
  final String? avatarUrl;
  final String swingId;
  final String? phone;

  factory _RosterPlayer.fromJson(Map<String, dynamic> json) {
    String s(Object? v) => '${v ?? ''}'.trim();
    final avatar = s(json['avatarUrl']);
    return _RosterPlayer(
      profileId: s(json['profileId'] ?? json['id'] ?? json['playerId']),
      teamPlayerId: s(json['id'] ?? json['playerId'] ?? json['profileId']),
      userId: s(json['userId']),
      name: s(json['name']).isEmpty ? 'Player' : s(json['name']),
      avatarUrl: avatar.isEmpty ? null : avatar,
      swingId: s(json['swingId']),
      phone: s(json['phone']).isEmpty ? null : s(json['phone']),
    );
  }
}

class _RosterState {
  const _RosterState._({
    required this.isLoading,
    this.error,
    this.data,
  });

  final bool isLoading;
  final String? error;
  final _LoadedRoster? data;

  const _RosterState.loading()
      : isLoading = true,
        error = null,
        data = null;

  const _RosterState.error(String message)
      : isLoading = false,
        error = message,
        data = null;

  factory _RosterState.ready({
    required List<_RosterPlayer> players,
    required Set<String> selected,
    String? captainId,
    String? viceCaptainId,
    String? wicketKeeperId,
  }) {
    return _RosterState._(
      isLoading: false,
      error: null,
      data: _LoadedRoster(
        players: players,
        selected: selected,
        captainId: captainId,
        viceCaptainId: viceCaptainId,
        wicketKeeperId: wicketKeeperId,
      ),
    );
  }

  factory _RosterState.withLoaded(_LoadedRoster loaded) {
    return _RosterState._(isLoading: false, error: null, data: loaded);
  }

  _LoadedRoster? get asLoaded => data;
}

class _LoadedRoster {
  const _LoadedRoster({
    required this.players,
    required this.selected,
    this.captainId,
    this.viceCaptainId,
    this.wicketKeeperId,
  });

  final List<_RosterPlayer> players;
  final Set<String> selected;
  final String? captainId;
  final String? viceCaptainId;
  final String? wicketKeeperId;

  /// Sentinel used to distinguish "keep the existing value" (default) from
  /// "explicitly set to null" in [rebuild].
  static const Object _unset = Object();

  _LoadedRoster rebuild({
    List<_RosterPlayer>? players,
    Set<String>? selected,
    Object? captainId = _unset,
    Object? viceCaptainId = _unset,
    Object? wicketKeeperId = _unset,
  }) {
    return _LoadedRoster(
      players: players ?? this.players,
      selected: selected ?? this.selected,
      captainId:
          identical(captainId, _unset) ? this.captainId : captainId as String?,
      viceCaptainId: identical(viceCaptainId, _unset)
          ? this.viceCaptainId
          : viceCaptainId as String?,
      wicketKeeperId: identical(wicketKeeperId, _unset)
          ? this.wicketKeeperId
          : wicketKeeperId as String?,
    );
  }

  bool get isComplete =>
      selected.length == 11 &&
      captainId != null &&
      viceCaptainId != null &&
      wicketKeeperId != null &&
      selected.contains(captainId) &&
      selected.contains(viceCaptainId) &&
      selected.contains(wicketKeeperId);

  Set<_Role> rolesFor(String profileId) {
    final roles = <_Role>{};
    if (profileId == captainId) roles.add(_Role.captain);
    if (profileId == viceCaptainId) roles.add(_Role.viceCaptain);
    if (profileId == wicketKeeperId) roles.add(_Role.wicketKeeper);
    return roles;
  }
}
