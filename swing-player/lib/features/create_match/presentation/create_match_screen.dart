import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_host_core/flutter_host_core.dart' as fhc;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/token_storage.dart';

/// Player-side wrapper around the shared [fhc.CreateMatchScreen].
///
/// Handles three concerns the shared package can't:
///   1. Pulling the current user id from `TokenStorage` so "my squads" can
///      be split from "playing for" in the picker.
///   2. Wiring `go_router` navigation for back + post-toss routing.
///   3. Branching on `?mode=...` — `resume` (default when matchId is
///      present) hands off to Playing 11; `edit` opens the form
///      pre-populated with the existing match's values and PATCHes on save.
class CreateMatchScreen extends ConsumerStatefulWidget {
  const CreateMatchScreen({
    super.key,
    this.existingMatchId,
    this.existingTeamAName,
    this.existingTeamBName,
    this.editMode = false,
  });

  final String? existingMatchId;
  final String? existingTeamAName;
  final String? existingTeamBName;

  /// When true, opens the create-match form pre-populated with the existing
  /// match's values. Submit PATCHes that match (toss / Playing 11 / scoring
  /// state preserved). When false (default), follows the legacy resume flow
  /// that lands on Playing 11.
  final bool editMode;

  @override
  ConsumerState<CreateMatchScreen> createState() => _CreateMatchScreenState();
}

class _CreateMatchScreenState extends ConsumerState<CreateMatchScreen> {
  String? _userId;
  bool _userIdLoaded = false;

  fhc.HostMatchSummary? _resumeMatch;
  String? _resumeError;
  bool _resumeLoaded = false;

  bool get _hasMatchId => (widget.existingMatchId ?? '').trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _loadUserId();
    if (_hasMatchId) _loadResumeMatch();
  }

  Future<void> _loadUserId() async {
    final id = await TokenStorage.getUserId();
    if (!mounted) return;
    setState(() {
      _userId = id;
      _userIdLoaded = true;
    });
  }

  Future<void> _loadResumeMatch() async {
    final matchId = widget.existingMatchId!.trim();
    try {
      final summary = await ref
          .read(fhc.hostCreateMatchRepositoryProvider)
          .getMatch(matchId);

      var teamAId = summary.teamAId;
      var teamBId = summary.teamBId;

      // Legacy matches don't have team IDs stored — resolve by name search.
      if (teamAId.isEmpty || teamBId.isEmpty) {
        final dio = ref.read(fhc.hostDioProvider);
        teamAId = teamAId.isNotEmpty
            ? teamAId
            : await _resolveTeamId(dio, summary.teamAName);
        teamBId = teamBId.isNotEmpty
            ? teamBId
            : await _resolveTeamId(dio, summary.teamBName);
      }

      if (!mounted) return;
      setState(() {
        _resumeMatch =
            teamAId == summary.teamAId && teamBId == summary.teamBId
                ? summary
                : fhc.HostMatchSummary(
                    id: summary.id,
                    teamAId: teamAId,
                    teamBId: teamBId,
                    teamAName: summary.teamAName,
                    teamBName: summary.teamBName,
                    teamALogoUrl: summary.teamALogoUrl,
                    teamBLogoUrl: summary.teamBLogoUrl,
                    teamACity: summary.teamACity,
                    teamBCity: summary.teamBCity,
                    format: summary.format,
                    matchType: summary.matchType,
                    category: summary.category,
                    ageGroup: summary.ageGroup,
                    ballType: summary.ballType,
                    venueId: summary.venueId,
                    venueName: summary.venueName,
                    venueCity: summary.venueCity,
                    scheduledAt: summary.scheduledAt,
                    customOvers: summary.customOvers,
                    hasImpactPlayer: summary.hasImpactPlayer,
                  );
        _resumeLoaded = true;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _resumeError = error.toString();
        _resumeLoaded = true;
      });
    }
  }

  Future<String> _resolveTeamId(Dio dio, String teamName) async {
    if (teamName.trim().isEmpty) return '';
    try {
      final paths = ref.read(fhc.hostPathConfigProvider);
      final resp = await dio.get<Map<String, dynamic>>(
        paths.teamSearch,
        queryParameters: {'q': teamName.trim(), 'limit': 10},
      );
      final body = resp.data ?? {};
      final data = body['data'];
      final teams = (data is Map ? data['teams'] : null) as List? ?? [];
      final match = teams.whereType<Map>().firstWhere(
            (t) => '${t['name'] ?? t['teamName'] ?? ''}' == teamName.trim(),
            orElse: () => <String, dynamic>{},
          );
      return '${match['id'] ?? match['teamId'] ?? ''}'.trim();
    } catch (_) {
      return '';
    }
  }

  void _onTossCompleted(BuildContext ctx, String matchId) {
    ctx.go('/score-match/${Uri.encodeComponent(matchId)}');
  }

  @override
  Widget build(BuildContext context) {
    if (_hasMatchId) {
      if (!_resumeLoaded) {
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      }
      final summary = _resumeMatch;
      if (summary == null) {
        return Scaffold(
          appBar: AppBar(title: const Text('Match')),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                _resumeError ?? 'Could not load this match.',
                textAlign: TextAlign.center,
              ),
            ),
          ),
        );
      }

      // Edit mode: open the create-match form pre-populated. Submit PATCHes
      // the existing match (toss / Playing 11 / scoring all preserved).
      if (widget.editMode) {
        // Wait on user id so the team picker shows the OWNER badge if they
        // wander back to step 1.
        if (!_userIdLoaded) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return fhc.CreateMatchScreen(
          currentUserId: _userId,
          onTossCompleted: _onTossCompleted,
          onBack: () => context.pop(),
          editMatchId: summary.id,
          onEditSaved: (ctx, _) => ctx.pop(),
          initialPrefill: fhc.CreateMatchPrefill(
            teamAId: summary.teamAId,
            teamAName: summary.teamAName,
            teamALogoUrl: summary.teamALogoUrl,
            teamACity: summary.teamACity,
            teamBId: summary.teamBId,
            teamBName: summary.teamBName,
            teamBLogoUrl: summary.teamBLogoUrl,
            teamBCity: summary.teamBCity,
            format: summary.format,
            category: summary.category,
            ageGroup: summary.ageGroup,
            ballType: summary.ballType,
            venueId: summary.venueId,
            venueName: summary.venueName,
            venueCity: summary.venueCity,
            scheduledAt: summary.scheduledAt,
            customOvers: summary.customOvers,
            hasImpactPlayer: summary.hasImpactPlayer,
          ),
        );
      }

      // Resume mode: jump to Playing 11.
      return fhc.PlayingElevenScreen(
        matchId: summary.id,
        teamAId: summary.teamAId,
        teamAName: summary.teamAName,
        teamBId: summary.teamBId,
        teamBName: summary.teamBName,
        onTossCompleted: _onTossCompleted,
        onBack: () => context.pop(),
      );
    }

    // Fresh-create flow. Wait for the user id once so the picker can show
    // the OWNER badge from the very first build.
    if (!_userIdLoaded) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return fhc.CreateMatchScreen(
      currentUserId: _userId,
      onTossCompleted: _onTossCompleted,
      onBack: () => context.pop(),
    );
  }
}
