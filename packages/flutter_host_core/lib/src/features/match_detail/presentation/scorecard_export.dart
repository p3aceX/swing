import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:share_plus/share_plus.dart';

import '../domain/match_models.dart';

// Shareable match scorecard — a fixed-width, non-scrolling card rendered
// off the main scorecard tab. The card uses a fixed light palette (not
// theme colors) so the exported PNG always looks the same regardless of
// the viewer's dark/light mode. Capture works by wrapping the card in a
// RepaintBoundary inside a SingleChildScrollView: SingleChildScrollView
// lays the child out at full intrinsic height, so toImage() captures the
// whole card even though only part of it is visible on screen.

const double _kCardWidth = 380;
const Color _ink = Color(0xFF0A0B0A);
const Color _inkSub = Color(0xFF6B6B6B);
const Color _paper = Color(0xFFFFFFFF);
const Color _paper2 = Color(0xFFF4F2EB);
const Color _line = Color(0x14000000);
const Color _accent = Color(0xFF2BA84A);

/// Opens the scorecard preview page. Returns immediately.
void openScorecardPreview(BuildContext context, MatchCenter center) {
  Navigator.of(context, rootNavigator: true).push(
    MaterialPageRoute<void>(
      builder: (_) => ScorecardPreviewPage(center: center),
    ),
  );
}

class ScorecardPreviewPage extends StatefulWidget {
  const ScorecardPreviewPage({super.key, required this.center});

  final MatchCenter center;

  @override
  State<ScorecardPreviewPage> createState() => _ScorecardPreviewPageState();
}

class _ScorecardPreviewPageState extends State<ScorecardPreviewPage> {
  final GlobalKey _cardKey = GlobalKey();
  bool _busy = false;

  Future<Uint8List?> _capture() async {
    final boundary =
        _cardKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) return null;
    final image = await boundary.toImage(pixelRatio: 3);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData?.buffer.asUint8List();
  }

  Future<File> _writeTemp(Uint8List bytes) async {
    final safeTitle = widget.center.title
        .replaceAll(RegExp(r'[^A-Za-z0-9]+'), '_')
        .replaceAll(RegExp(r'_+'), '_');
    // Directory.systemTemp resolves to the app's sandboxed temp dir on
    // both iOS and Android — no path_provider dependency needed.
    final file = File(
      '${Directory.systemTemp.path}/scorecard_${safeTitle}_${DateTime.now().millisecondsSinceEpoch}.png',
    );
    await file.writeAsBytes(bytes);
    return file;
  }

  Future<void> _share() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final bytes = await _capture();
      if (bytes == null) throw Exception('Could not render scorecard');
      final file = await _writeTemp(bytes);
      await Share.shareXFiles(
        [XFile(file.path, mimeType: 'image/png')],
        text: widget.center.title,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not share scorecard: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _save() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final bytes = await _capture();
      if (bytes == null) throw Exception('Could not render scorecard');
      final file = await _writeTemp(bytes);
      // share_plus is the cross-platform path that exposes Save Image /
      // Save to Files in the OS sheet without pulling a gallery plugin
      // into host_core (which every host app would then have to bump).
      await Share.shareXFiles(
        [XFile(file.path, mimeType: 'image/png')],
        text: 'Scorecard — ${widget.center.title}',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not save scorecard: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        title: const Text('Scorecard'),
        backgroundColor: const Color(0xFF1A1A1A),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Center(
          child: RepaintBoundary(
            key: _cardKey,
            child: ScorecardExportCard(center: widget.center),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _busy ? null : _save,
                  icon: const Icon(Icons.download_rounded, size: 18),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white24),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  label: const Text('Save'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.icon(
                  onPressed: _busy ? null : _share,
                  icon: _busy
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.share_rounded, size: 18),
                  style: FilledButton.styleFrom(
                    backgroundColor: _accent,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  label: const Text('Share'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ScorecardExportCard extends StatelessWidget {
  const ScorecardExportCard({super.key, required this.center});

  final MatchCenter center;

  @override
  Widget build(BuildContext context) {
    final innings =
        center.innings.where((i) => !i.isSuperOver).toList(growable: false);
    final superOvers =
        center.innings.where((i) => i.isSuperOver).toList(growable: false);
    return Container(
      width: _kCardWidth,
      decoration: BoxDecoration(
        color: _paper,
        borderRadius: BorderRadius.circular(14),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          _header(),
          for (final inn in innings) _InningsBlock(innings: inn),
          for (final so in superOvers)
            _InningsBlock(innings: so, superOver: true),
          _footer(),
        ],
      ),
    );
  }

  Widget _header() {
    final result = center.resultSummary?.trim();
    final meta = <String>[
      if (center.formatLabel != null && center.formatLabel!.trim().isNotEmpty)
        center.formatLabel!.trim(),
      if (center.venueLabel != null && center.venueLabel!.trim().isNotEmpty)
        center.venueLabel!.trim(),
    ].join('  ·  ');
    return Container(
      color: _ink,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            center.competitionLabel?.trim().isNotEmpty == true
                ? center.competitionLabel!.trim().toUpperCase()
                : 'MATCH SCORECARD',
            style: const TextStyle(
              color: _accent,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${center.teamAName}  vs  ${center.teamBName}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          if (meta.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              meta,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
          if (result != null && result.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _accent,
                borderRadius: BorderRadius.circular(5),
              ),
              child: Text(
                result,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _footer() {
    return Container(
      color: _paper2,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Scored on ',
            style: TextStyle(color: _inkSub, fontSize: 10.5),
          ),
          const Text(
            'Swing',
            style: TextStyle(
              color: _accent,
              fontSize: 11.5,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _InningsBlock extends StatelessWidget {
  const _InningsBlock({required this.innings, this.superOver = false});

  final MatchInnings innings;
  final bool superOver;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Innings header
        Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  superOver
                      ? '${innings.battingTeamName} · Super Over'
                      : innings.battingTeamName,
                  style: const TextStyle(
                    color: _ink,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Text(
                innings.score,
                style: const TextStyle(
                  color: _ink,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        // Batting table
        _battingTable(),
        _extrasLine(),
        // Bowling table
        if (innings.bowling.isNotEmpty) _bowlingTable(),
        const Divider(height: 1, color: _line),
      ],
    );
  }

  Widget _battingTable() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          _row(
            cells: const ['BATTING', 'R', 'B', '4s', '6s', 'SR'],
            isHeader: true,
          ),
          for (final b in innings.batting)
            _row(
              cells: [
                b.name,
                '${b.runs}',
                '${b.balls}',
                '${b.fours}',
                '${b.sixes}',
                b.strikeRate,
              ],
              subtitle: b.isOut ? (b.dismissal ?? 'out') : 'not out',
              dim: !b.isOut,
            ),
        ],
      ),
    );
  }

  Widget _bowlingTable() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Column(
        children: [
          _row(
            cells: const ['BOWLING', 'O', 'R', 'W', 'Econ', ''],
            isHeader: true,
          ),
          for (final w in innings.bowling)
            _row(
              cells: [
                w.name,
                w.overs,
                '${w.runs}',
                '${w.wickets}',
                w.economy,
                '',
              ],
            ),
        ],
      ),
    );
  }

  Widget _extrasLine() {
    final e = innings.extrasBreakdown;
    final parts = <String>[
      if (e.wides != 0) 'wd ${e.wides}',
      if (e.noBalls != 0) 'nb ${e.noBalls}',
      if (e.byes != 0) 'b ${e.byes}',
      if (e.legByes != 0) 'lb ${e.legByes}',
      if (e.penalty != 0) 'pen ${e.penalty}',
    ];
    final detail = parts.isEmpty ? '' : ' (${parts.join(', ')})';
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 2),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Extras$detail',
              style: TextStyle(
                color: _inkSub,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            '${innings.extras}',
            style: const TextStyle(
              color: _ink,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  // A 6-column row: first column flex (name), the rest fixed-width numerics.
  Widget _row({
    required List<String> cells,
    bool isHeader = false,
    String? subtitle,
    bool dim = false,
  }) {
    final nameStyle = TextStyle(
      color: isHeader ? _inkSub : _ink,
      fontSize: isHeader ? 9.5 : 12,
      fontWeight: isHeader ? FontWeight.w800 : FontWeight.w600,
      letterSpacing: isHeader ? 0.6 : 0,
    );
    final numStyle = TextStyle(
      color: isHeader ? _inkSub : _ink,
      fontSize: isHeader ? 9.5 : 12,
      fontWeight: isHeader ? FontWeight.w800 : FontWeight.w700,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(cells[0], style: nameStyle),
                if (subtitle != null)
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: dim ? _accent : _inkSub,
                      fontSize: 9.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ),
          for (var i = 1; i < cells.length; i++)
            SizedBox(
              width: 34,
              child: Text(
                cells[i],
                textAlign: TextAlign.right,
                style: numStyle,
              ),
            ),
        ],
      ),
    );
  }
}
