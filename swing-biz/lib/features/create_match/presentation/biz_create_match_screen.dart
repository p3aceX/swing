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
  });

  final String? existingMatchId;

  @override
  ConsumerState<BizCreateMatchScreen> createState() =>
      _BizCreateMatchScreenState();
}

class _BizCreateMatchScreenState extends ConsumerState<BizCreateMatchScreen> {
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

  void _onTossCompleted(BuildContext context, String matchId) {
    context.go('${AppRoutes.scoreMatch}/${Uri.encodeComponent(matchId)}');
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = ref.watch(meProvider).valueOrNull?.user.id;

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

    return host.CreateMatchScreen(
      currentUserId: currentUserId,
      onTossCompleted: _onTossCompleted,
      onBack: () => context.pop(),
    );
  }
}
