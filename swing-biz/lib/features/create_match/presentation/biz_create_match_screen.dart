import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_host_core/flutter_host_core.dart' as host;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/me_providers.dart';
import '../../../core/router/app_router.dart';

class BizCreateMatchScreen extends ConsumerStatefulWidget {
  const BizCreateMatchScreen({
    super.key,
    this.existingMatchId,
    this.editMode = false,
  });

  final String? existingMatchId;

  /// When true, opens the create-match form pre-populated with the existing
  /// match's values (Edit Match flow). When false (default), follows the
  /// resume flow that lands on Playing 11.
  final bool editMode;

  @override
  ConsumerState<BizCreateMatchScreen> createState() =>
      _BizCreateMatchScreenState();
}

class _BizCreateMatchScreenState extends ConsumerState<BizCreateMatchScreen> {
  host.HostMatchSummary? _resumeMatch;
  String? _resumeError;
  bool _resumeLoaded = false;

  bool get _hasMatchId => (widget.existingMatchId ?? '').trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    if (_hasMatchId) _loadResumeMatch();
  }

  Future<void> _loadResumeMatch() async {
    final matchId = widget.existingMatchId!.trim();
    try {
      final summary = await ref
          .read(host.hostCreateMatchRepositoryProvider)
          .getMatch(matchId);

      var teamAId = summary.teamAId;
      var teamBId = summary.teamBId;

      // Legacy matches don't have team IDs stored — resolve by name search.
      if (teamAId.isEmpty || teamBId.isEmpty) {
        final dio = ref.read(host.hostDioProvider);
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
                : host.HostMatchSummary(
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
      final paths = ref.read(host.hostPathConfigProvider);
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

  void _onTossCompleted(BuildContext context, String matchId) {
    context.go('${AppRoutes.scoreMatch}/${Uri.encodeComponent(matchId)}');
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = ref.watch(meProvider).valueOrNull?.user.id;

    // Resume + Edit both need the match summary loaded first.
    if (_hasMatchId) {
      if (!_resumeLoaded) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
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
      // the existing match (toss / Playing 11 / scoring all preserved) and
      // pops back to the previous screen.
      if (widget.editMode) {
        return host.CreateMatchScreen(
          currentUserId: currentUserId,
          onTossCompleted: _onTossCompleted,
          onBack: () => context.pop(),
          editMatchId: summary.id,
          onEditSaved: (ctx, _) => ctx.pop(),
          initialPrefill: host.CreateMatchPrefill(
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

      // Resume mode: jump straight to Playing 11.
      return host.PlayingElevenScreen(
        matchId: summary.id,
        teamAId: summary.teamAId,
        teamAName: summary.teamAName,
        teamBId: summary.teamBId,
        teamBName: summary.teamBName,
        onTossCompleted: _onTossCompleted,
        onBack: () => context.pop(),
      );
    }

    return host.CreateMatchScreen(
      currentUserId: currentUserId,
      onTossCompleted: _onTossCompleted,
      onBack: () => context.pop(),
    );
  }
}
