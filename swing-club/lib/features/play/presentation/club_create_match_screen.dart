import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_host_core/flutter_host_core.dart' as host;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../providers/auth_provider.dart';

class ClubCreateMatchScreen extends ConsumerStatefulWidget {
  const ClubCreateMatchScreen({super.key, this.existingMatchId});

  final String? existingMatchId;

  @override
  ConsumerState<ClubCreateMatchScreen> createState() =>
      _ClubCreateMatchScreenState();
}

class _ClubCreateMatchScreenState extends ConsumerState<ClubCreateMatchScreen> {
  host.HostMatchSummary? _resumeMatch;
  String? _resumeError;
  bool _resumeLoaded = false;

  bool get _isResume => (widget.existingMatchId ?? '').trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    if (_isResume) _loadResumeMatch();
  }

  Future<void> _loadResumeMatch() async {
    final matchId = widget.existingMatchId!.trim();
    try {
      final summary = await ref
          .read(host.hostCreateMatchRepositoryProvider)
          .getMatch(matchId);

      var teamAId = summary.teamAId;
      var teamBId = summary.teamBId;

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
        _resumeMatch = teamAId == summary.teamAId && teamBId == summary.teamBId
            ? summary
            : host.HostMatchSummary(
                id: summary.id,
                teamAId: teamAId,
                teamBId: teamBId,
                teamAName: summary.teamAName,
                teamBName: summary.teamBName,
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
      final resp = await dio.get<Map<String, dynamic>>(
        '/player/teams/search',
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
    ctx.push('/play/score/${Uri.encodeComponent(matchId)}');
  }

  @override
  Widget build(BuildContext context) {
    if (_isResume) {
      if (!_resumeLoaded) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }
      final summary = _resumeMatch;
      if (summary == null) {
        return Scaffold(
          appBar: AppBar(title: const Text('Resume match')),
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

    final currentUserId = ref.watch(authProvider).userId;
    return host.CreateMatchScreen(
      currentUserId: currentUserId,
      onTossCompleted: _onTossCompleted,
      onBack: () => context.pop(),
    );
  }
}
