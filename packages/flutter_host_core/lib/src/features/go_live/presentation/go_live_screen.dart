import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../repositories/host_match_repository.dart';
import '../../../theme/host_colors.dart';

/// Step between toss completion and scoring. Gives the host the option to
/// take the match live by sharing their Swing ID and Swing Pass with viewers.
/// Skipping is fine — the scorer can always share credentials later.
class GoLiveScreen extends ConsumerStatefulWidget {
  const GoLiveScreen({
    super.key,
    required this.matchId,
    this.teamAName,
    this.teamBName,
    this.onCompleted,
  });

  final String matchId;

  /// Optional display names. When null the screen fetches them from the match.
  final String? teamAName;
  final String? teamBName;

  /// Called when the user taps "Start Scoring". Hosts use this to navigate
  /// into the scoring screen. If null, the screen pops itself.
  final void Function(BuildContext context, String matchId)? onCompleted;

  @override
  ConsumerState<GoLiveScreen> createState() => _GoLiveScreenState();
}

class _GoLiveScreenState extends ConsumerState<GoLiveScreen> {
  bool? _choice; // null=pending, true=goLive, false=skip
  String _liveCode = '';
  String _livePin = '';
  String _teamA = '';
  String _teamB = '';
  bool _credsLoading = true;
  String? _credsError;

  @override
  void initState() {
    super.initState();
    _teamA = widget.teamAName ?? '';
    _teamB = widget.teamBName ?? '';
    _fetchCreds();
  }

  Future<void> _fetchCreds() async {
    try {
      final creds = await ref
          .read(hostMatchRepositoryProvider)
          .fetchLiveCreds(widget.matchId);
      if (!mounted) return;
      setState(() {
        _liveCode = creds.liveCode;
        _livePin = creds.livePin;
        if (_teamA.isEmpty) _teamA = creds.teamAName;
        if (_teamB.isEmpty) _teamB = creds.teamBName;
        _credsLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _credsError = 'Could not load live credentials';
        _credsLoading = false;
      });
    }
  }

  void _startScoring() {
    final onCompleted = widget.onCompleted;
    if (onCompleted != null) {
      onCompleted(context, widget.matchId);
    } else {
      Navigator.of(context).pop(widget.matchId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bg,
      appBar: AppBar(
        backgroundColor: context.bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: context.fg, size: 18),
        ),
        title: Text(
          'Go Live?',
          style: TextStyle(
            color: context.fg,
            fontSize: 17,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 6, 20, 40),
        children: [
          // Matchup
          Row(
            children: [
              Expanded(
                child: Text(
                  _teamA.isEmpty ? 'Team A' : _teamA,
                  textAlign: TextAlign.start,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: context.fg,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  'vs',
                  style: TextStyle(
                    color: context.fgSub.withValues(alpha: 0.55),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.6,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  _teamB.isEmpty ? 'Team B' : _teamB,
                  textAlign: TextAlign.end,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: context.fg,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),

          // Live icon + headline
          Center(
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: context.danger.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.live_tv_rounded,
                  color: context.danger, size: 30),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Take this match live?',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: context.fg,
              fontSize: 20,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Share your Swing ID & Pass with\nviewers and scoreboards.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: context.fgSub,
              fontSize: 14,
              height: 1.4,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 28),

          // Choice cards
          Row(
            children: [
              Expanded(
                child: _ChoiceCard(
                  icon: Icons.skip_next_rounded,
                  label: 'Not now',
                  selected: _choice == false,
                  accent: false,
                  onTap: () => setState(() => _choice = false),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ChoiceCard(
                  icon: Icons.sensors_rounded,
                  label: 'Go Live',
                  selected: _choice == true,
                  accent: true,
                  onTap: () => setState(() => _choice = true),
                ),
              ),
            ],
          ),

          // Live credentials (shown when "Go Live" chosen)
          AnimatedSize(
            duration: const Duration(milliseconds: 280),
            alignment: Alignment.topCenter,
            curve: Curves.easeOutCubic,
            child: _choice != true
                ? const SizedBox.shrink()
                : Padding(
                    padding: const EdgeInsets.only(top: 24),
                    child: _credsLoading
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.all(24),
                              child: CircularProgressIndicator(),
                            ),
                          )
                        : _credsError != null
                            ? Center(
                                child: Text(
                                  _credsError!,
                                  style: TextStyle(
                                      color: context.danger, fontSize: 13),
                                ),
                              )
                            : _LiveCredsPanel(
                                liveCode: _liveCode,
                                livePin: _livePin,
                              ),
                  ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        minimum: const EdgeInsets.fromLTRB(20, 0, 20, 14),
        child: _PrimaryCta(
          label: 'Start Scoring',
          enabled: _choice != null,
          onTap: _startScoring,
        ),
      ),
    );
  }
}

// ── Choice card ──────────────────────────────────────────────────────────────

class _ChoiceCard extends StatelessWidget {
  const _ChoiceCard({
    required this.icon,
    required this.label,
    required this.selected,
    required this.accent,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final bool accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = accent ? context.danger : context.fgSub;
    final selectedBg = accent
        ? context.danger.withValues(alpha: 0.12)
        : context.stroke.withValues(alpha: 0.5);
    final selectedBorder = accent
        ? context.danger.withValues(alpha: 0.5)
        : context.fgSub.withValues(alpha: 0.4);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      decoration: BoxDecoration(
        color: selected ? selectedBg : context.surf,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: selected ? selectedBorder : context.stroke.withValues(alpha: 0.5),
          width: selected ? 1.4 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon,
                    color: selected ? color : context.fgSub, size: 26),
                const SizedBox(height: 8),
                Text(
                  label,
                  style: TextStyle(
                    color: selected ? color : context.fg,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Live credentials panel ───────────────────────────────────────────────────

class _LiveCredsPanel extends StatelessWidget {
  const _LiveCredsPanel({required this.liveCode, required this.livePin});

  final String liveCode;
  final String livePin;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SHARE WITH VIEWERS',
          style: TextStyle(
            color: context.fgSub.withValues(alpha: 0.7),
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.6,
          ),
        ),
        const SizedBox(height: 12),
        _CredRow(label: 'Swing ID', value: liveCode),
        const SizedBox(height: 10),
        _CredRow(label: 'Swing Pass', value: livePin, obscure: true),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: context.accent.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline_rounded,
                  color: context.accent, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Viewers enter these on the Swing app or website to follow live.',
                  style: TextStyle(
                    color: context.accent,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Download the Swing Live app and paste these credentials to broadcast your match live.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: context.fgSub,
            fontSize: 13,
            fontWeight: FontWeight.w500,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}

class _CredRow extends StatefulWidget {
  const _CredRow({
    required this.label,
    required this.value,
    this.obscure = false,
  });

  final String label;
  final String value;
  final bool obscure;

  @override
  State<_CredRow> createState() => _CredRowState();
}

class _CredRowState extends State<_CredRow> {
  bool _revealed = false;
  bool _copied = false;

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: widget.value));
    if (!mounted) return;
    setState(() => _copied = true);
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() => _copied = false);
  }

  @override
  Widget build(BuildContext context) {
    final display = (widget.obscure && !_revealed)
        ? '••••••'
        : widget.value;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.label,
                  style: TextStyle(
                    color: context.fgSub,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.4,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  display,
                  style: TextStyle(
                    color: context.fg,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    letterSpacing: widget.obscure && !_revealed ? 3 : 0,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
          if (widget.obscure)
            IconButton(
              onPressed: () => setState(() => _revealed = !_revealed),
              icon: Icon(
                _revealed
                    ? Icons.visibility_off_rounded
                    : Icons.visibility_rounded,
                color: context.fgSub,
                size: 18,
              ),
              visualDensity: VisualDensity.compact,
            ),
          IconButton(
            onPressed: _copy,
            icon: Icon(
              _copied ? Icons.check_rounded : Icons.copy_rounded,
              color: _copied ? context.success : context.fgSub,
              size: 18,
            ),
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }
}

// ── CTA ──────────────────────────────────────────────────────────────────────

class _PrimaryCta extends StatelessWidget {
  const _PrimaryCta({
    required this.label,
    required this.enabled,
    required this.onTap,
  });

  final String label;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bg = context.ctaBg;
    final fg = context.ctaFg;
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: enabled ? bg : bg.withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(16),
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
                  color: enabled ? fg : fg.withValues(alpha: 0.55),
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.2,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
