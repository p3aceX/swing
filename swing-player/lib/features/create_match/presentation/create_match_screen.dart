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
///   3. Honouring the legacy `?matchId=...` Resume entry — we load the
///      match's team ids and hand off to [fhc.PlayingElevenScreen] directly.
class CreateMatchScreen extends ConsumerStatefulWidget {
  const CreateMatchScreen({
    super.key,
    this.existingMatchId,
    this.existingTeamAName,
    this.existingTeamBName,
  });

  final String? existingMatchId;
  final String? existingTeamAName;
  final String? existingTeamBName;

  @override
  ConsumerState<CreateMatchScreen> createState() => _CreateMatchScreenState();
}

class _CreateMatchScreenState extends ConsumerState<CreateMatchScreen> {
  String? _userId;
  bool _userIdLoaded = false;

  fhc.HostMatchSummary? _resumeMatch;
  String? _resumeError;
  bool _resumeLoaded = false;

  bool get _isResume => (widget.existingMatchId ?? '').trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _loadUserId();
    if (_isResume) _loadResumeMatch();
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
      if (!mounted) return;
      setState(() {
        _resumeMatch = summary;
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

  void _onTossCompleted(BuildContext ctx, String matchId) {
    ctx.go('/score-match/${Uri.encodeComponent(matchId)}');
  }

  @override
  Widget build(BuildContext context) {
    if (_isResume) {
      if (!_resumeLoaded) {
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
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
