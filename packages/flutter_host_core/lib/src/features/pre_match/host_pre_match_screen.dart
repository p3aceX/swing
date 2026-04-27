import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../repositories/host_match_repository.dart';
import '../../theme/host_colors.dart';
import '../playing_eleven/presentation/playing_eleven_screen.dart';

/// Shown before Playing 11 selection for tournament matches.
/// Displays match context and lets the organiser adjust overs before proceeding.
class HostPreMatchScreen extends ConsumerStatefulWidget {
  const HostPreMatchScreen({
    super.key,
    required this.matchId,
    required this.teamAId,
    required this.teamAName,
    required this.teamBId,
    required this.teamBName,
    required this.currentOvers,
    required this.formatLabel,
    this.round,
    this.tournamentName,
    this.onTossCompleted,
    this.onBack,
  });

  final String matchId;
  final String teamAId;
  final String teamAName;
  final String teamBId;
  final String teamBName;
  final int currentOvers;
  final String formatLabel;
  final String? round;
  final String? tournamentName;
  final void Function(BuildContext context, String matchId)? onTossCompleted;
  final VoidCallback? onBack;

  @override
  ConsumerState<HostPreMatchScreen> createState() => _HostPreMatchScreenState();
}

class _HostPreMatchScreenState extends ConsumerState<HostPreMatchScreen> {
  late final TextEditingController _oversCtrl;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _oversCtrl = TextEditingController(text: '${widget.currentOvers}');
  }

  @override
  void dispose() {
    _oversCtrl.dispose();
    super.dispose();
  }

  int? get _parsedOvers {
    final v = int.tryParse(_oversCtrl.text.trim());
    return (v != null && v > 0) ? v : null;
  }

  Future<void> _confirm() async {
    final overs = _parsedOvers;
    if (overs == null) {
      setState(() => _error = 'Enter a valid number of overs');
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      if (overs != widget.currentOvers) {
        await ref
            .read(hostMatchRepositoryProvider)
            .updateMatchOvers(widget.matchId, overs);
      }
      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => PlayingElevenScreen(
            matchId: widget.matchId,
            teamAId: widget.teamAId,
            teamAName: widget.teamAName,
            teamBId: widget.teamBId,
            teamBName: widget.teamBName,
            onTossCompleted: widget.onTossCompleted,
            onBack: () => Navigator.of(context).maybePop(),
          ),
        ),
      );
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: context.bg,
      appBar: AppBar(
        backgroundColor: context.bg,
        elevation: 0,
        leading: BackButton(
          onPressed: widget.onBack ?? () => Navigator.of(context).maybePop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.tournamentName != null)
              Text(
                widget.tournamentName!,
                style: textTheme.labelSmall?.copyWith(color: context.fgSub),
              ),
            if (widget.round != null)
              Text(
                widget.round!,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: context.fg,
                ),
              ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _MatchupRow(
              teamAName: widget.teamAName,
              teamBName: widget.teamBName,
            ),
            const SizedBox(height: 32),
            _OversField(
              controller: _oversCtrl,
              formatLabel: widget.formatLabel,
              error: _error,
              onChanged: (_) => setState(() => _error = null),
            ),
            const Spacer(),
            FilledButton(
              onPressed: _saving ? null : _confirm,
              style: FilledButton.styleFrom(
                backgroundColor: context.ctaBg,
                foregroundColor: context.ctaFg,
                minimumSize: const Size.fromHeight(52),
              ),
              child: _saving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Select Playing 11'),
            ),
          ],
        ),
      ),
    );
  }
}

class _MatchupRow extends StatelessWidget {
  const _MatchupRow({required this.teamAName, required this.teamBName});

  final String teamAName;
  final String teamBName;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      children: [
        Expanded(
          child: Text(
            teamAName,
            textAlign: TextAlign.center,
            style: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: context.fg,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'vs',
            style: textTheme.titleMedium?.copyWith(color: context.fgSub),
          ),
        ),
        Expanded(
          child: Text(
            teamBName,
            textAlign: TextAlign.center,
            style: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: context.fg,
            ),
          ),
        ),
      ],
    );
  }
}

class _OversField extends StatelessWidget {
  const _OversField({
    required this.controller,
    required this.formatLabel,
    required this.onChanged,
    this.error,
  });

  final TextEditingController controller;
  final String formatLabel;
  final String? error;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Overs',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: context.fg,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: context.accentBg,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                formatLabel,
                style: textTheme.labelSmall?.copyWith(color: context.accent),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          onChanged: onChanged,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(
            hintText: 'e.g. 20',
            errorText: error,
            filled: true,
            fillColor: context.surf,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: context.stroke),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: context.stroke),
            ),
          ),
          style: textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: context.fg,
          ),
        ),
      ],
    );
  }
}
