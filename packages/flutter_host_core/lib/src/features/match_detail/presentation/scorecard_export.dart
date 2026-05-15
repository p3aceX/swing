import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../domain/match_models.dart';

// Match scorecard PDF — "classic scorebook" aesthetic: serif type,
// ruled lines, letter-spaced team names, "182 for 6 (19.4 overs)"
// phrasing. `pw.MultiPage` paginates a full line-up across A4 pages.
// `PdfPreview` (printing pkg) renders it in-app with Share / Save /
// Print actions.

const PdfColor _ink = PdfColor.fromInt(0xFF1A1A1A);
const PdfColor _inkSoft = PdfColor.fromInt(0xFF5C5A52);
const PdfColor _rule = PdfColor.fromInt(0xFF1A1A1A);
const PdfColor _ruleThin = PdfColor.fromInt(0xFFC9C6BB);
const PdfColor _star = PdfColor.fromInt(0xFFFBF4DD);
const PdfColor _accent = PdfColor.fromInt(0xFF2BA84A);

/// Opens the scorecard PDF preview page.
void openScorecardPreview(BuildContext context, MatchCenter center) {
  Navigator.of(context, rootNavigator: true).push(
    MaterialPageRoute<void>(
      builder: (_) => ScorecardPdfPage(center: center),
    ),
  );
}

class ScorecardPdfPage extends StatelessWidget {
  const ScorecardPdfPage({super.key, required this.center});

  final MatchCenter center;

  String get _fileName {
    final safe = center.title
        .replaceAll(RegExp(r'[^A-Za-z0-9]+'), '_')
        .replaceAll(RegExp(r'_+'), '_');
    return 'scorecard_$safe.pdf';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scorecard')),
      body: PdfPreview(
        build: (format) => _buildScorecardPdf(center, format),
        canChangePageFormat: false,
        canChangeOrientation: false,
        canDebug: false,
        pdfFileName: _fileName,
        useActions: true,
      ),
    );
  }
}

Future<Uint8List> _buildScorecardPdf(
  MatchCenter center,
  PdfPageFormat format,
) async {
  // Serif theme for the classic-scorebook feel. Times is one of the
  // built-in PDF base-14 fonts — no asset bundling needed.
  final theme = pw.ThemeData.withFont(
    base: pw.Font.times(),
    bold: pw.Font.timesBold(),
    italic: pw.Font.timesItalic(),
    boldItalic: pw.Font.timesBoldItalic(),
  );
  final doc = pw.Document(theme: theme);

  final innings =
      center.innings.where((i) => !i.isSuperOver).toList(growable: false);
  final superOvers =
      center.innings.where((i) => i.isSuperOver).toList(growable: false);

  doc.addPage(
    pw.MultiPage(
      pageFormat: format.copyWith(
        marginTop: 30,
        marginBottom: 30,
        marginLeft: 34,
        marginRight: 34,
      ),
      build: (context) => [
        _header(center),
        pw.SizedBox(height: 14),
        for (final inn in innings) ...[
          _inningsSection(center, inn),
          pw.SizedBox(height: 16),
        ],
        for (final so in superOvers) ...[
          _inningsSection(center, so, superOver: true),
          pw.SizedBox(height: 16),
        ],
        _resultBlock(center),
        pw.SizedBox(height: 12),
        _metaFooter(center),
        pw.SizedBox(height: 10),
        _brand(),
      ],
    ),
  );

  return doc.save();
}

// ── Header ────────────────────────────────────────────────────────────────
pw.Widget _header(MatchCenter center) {
  final comp = center.competitionLabel?.trim();
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.stretch,
    children: [
      _doubleRule(),
      pw.SizedBox(height: 10),
      if (comp != null && comp.isNotEmpty)
        pw.Center(
          child: pw.Text(
            _spaced(comp.toUpperCase()),
            style: pw.TextStyle(
              color: _inkSoft,
              fontSize: 8.5,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ),
      pw.SizedBox(height: 5),
      pw.Center(
        child: pw.Text(
          '${center.teamAName}  v  ${center.teamBName}',
          style: pw.TextStyle(
            color: _ink,
            fontSize: 18,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
      ),
      pw.SizedBox(height: 10),
      _doubleRule(),
    ],
  );
}

// ── Innings ───────────────────────────────────────────────────────────────
pw.Widget _inningsSection(
  MatchCenter center,
  MatchInnings innings, {
  bool superOver = false,
}) {
  // Top performers — bold + faint tint on the standout row.
  int topBatIdx = -1;
  for (var i = 0; i < innings.batting.length; i++) {
    if (topBatIdx < 0 ||
        innings.batting[i].runs > innings.batting[topBatIdx].runs) {
      topBatIdx = i;
    }
  }
  int topBowlIdx = -1;
  for (var i = 0; i < innings.bowling.length; i++) {
    final cur = innings.bowling[i];
    if (topBowlIdx < 0) {
      topBowlIdx = i;
      continue;
    }
    final best = innings.bowling[topBowlIdx];
    if (cur.wickets > best.wickets ||
        (cur.wickets == best.wickets && cur.runs < best.runs)) {
      topBowlIdx = i;
    }
  }

  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.stretch,
    children: [
      // Letter-spaced team name + "N for W (O overs)"
      pw.Center(
        child: pw.Text(
          _spaced(
            (superOver
                    ? '${innings.battingTeamName} Super Over'
                    : innings.battingTeamName)
                .toUpperCase(),
          ),
          style: pw.TextStyle(
            color: _ink,
            fontSize: 13,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
      ),
      pw.SizedBox(height: 2),
      pw.Center(
        child: pw.Text(
          _classicScore(innings.score),
          style: const pw.TextStyle(color: _inkSoft, fontSize: 10),
        ),
      ),
      pw.SizedBox(height: 8),

      // Batting
      _battingTable(innings, topBatIdx),
      pw.SizedBox(height: 5),
      _extrasAndTotal(innings),
      _didNotBat(center, innings),

      // Fall of wickets
      if (innings.fallOfWickets.isNotEmpty) ...[
        pw.SizedBox(height: 7),
        _fallOfWickets(innings),
      ],

      // Bowling
      if (innings.bowling.isNotEmpty) ...[
        pw.SizedBox(height: 11),
        _bowlingTable(innings, topBowlIdx),
      ],
      pw.SizedBox(height: 10),
      _thinRule(),
    ],
  );
}

pw.Widget _battingTable(MatchInnings innings, int topIdx) {
  return pw.Table(
    columnWidths: {
      0: const pw.FlexColumnWidth(),
      1: const pw.FixedColumnWidth(38),
      2: const pw.FixedColumnWidth(34),
      3: const pw.FixedColumnWidth(30),
      4: const pw.FixedColumnWidth(30),
      5: const pw.FixedColumnWidth(48),
    },
    children: [
      _headRow(const ['BATSMAN', 'R', 'B', '4s', '6s', 'SR']),
      for (var i = 0; i < innings.batting.length; i++)
        _battingRow(innings.batting[i], isTop: i == topIdx),
    ],
  );
}

pw.TableRow _battingRow(MatchBatsmanRow b, {required bool isTop}) {
  return pw.TableRow(
    decoration: isTop ? const pw.BoxDecoration(color: _star) : null,
    children: [
      pw.Padding(
        padding: const pw.EdgeInsets.fromLTRB(4, 5, 4, 5),
        child: pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Expanded(
              child: pw.RichText(
                text: pw.TextSpan(
                  children: [
                    pw.TextSpan(
                      text: b.name,
                      style: pw.TextStyle(
                        color: _ink,
                        fontSize: 10.5,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.TextSpan(
                      text: '   ${b.isOut ? (b.dismissal ?? 'out') : 'not out'}',
                      style: pw.TextStyle(
                        color: b.isOut ? _inkSoft : _accent,
                        fontSize: 9,
                        fontStyle: pw.FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (isTop)
              pw.Text(
                ' *',
                style: pw.TextStyle(
                  color: _inkSoft,
                  fontSize: 9,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
          ],
        ),
      ),
      _num('${b.runs}', bold: true),
      _num('${b.balls}'),
      _num('${b.fours}'),
      _num('${b.sixes}'),
      _num(b.strikeRate),
    ],
  );
}

pw.Widget _bowlingTable(MatchInnings innings, int topIdx) {
  return pw.Table(
    columnWidths: {
      0: const pw.FlexColumnWidth(),
      1: const pw.FixedColumnWidth(44),
      2: const pw.FixedColumnWidth(40),
      3: const pw.FixedColumnWidth(34),
      4: const pw.FixedColumnWidth(52),
    },
    children: [
      _headRow(const ['BOWLER', 'O', 'R', 'W', 'Econ']),
      for (var i = 0; i < innings.bowling.length; i++)
        _bowlingRow(innings.bowling[i], isTop: i == topIdx),
    ],
  );
}

pw.TableRow _bowlingRow(MatchBowlerRow w, {required bool isTop}) {
  final extras = <String>[
    if (w.wides > 0) 'w ${w.wides}',
    if (w.noBalls > 0) 'nb ${w.noBalls}',
  ].join(', ');
  return pw.TableRow(
    decoration: isTop ? const pw.BoxDecoration(color: _star) : null,
    children: [
      pw.Padding(
        padding: const pw.EdgeInsets.fromLTRB(4, 5, 4, 5),
        child: pw.RichText(
          text: pw.TextSpan(
            children: [
              pw.TextSpan(
                text: w.name,
                style: pw.TextStyle(
                  color: _ink,
                  fontSize: 10.5,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              if (extras.isNotEmpty)
                pw.TextSpan(
                  text: '   ($extras)',
                  style: pw.TextStyle(
                    color: _inkSoft,
                    fontSize: 9,
                    fontStyle: pw.FontStyle.italic,
                  ),
                ),
            ],
          ),
        ),
      ),
      _num(w.overs),
      _num('${w.runs}'),
      _num('${w.wickets}', bold: true),
      _num(w.economy),
    ],
  );
}

pw.Widget _extrasAndTotal(MatchInnings innings) {
  final e = innings.extrasBreakdown;
  final parts = <String>[
    'b ${e.byes}',
    'lb ${e.legByes}',
    'w ${e.wides}',
    'nb ${e.noBalls}',
    if (e.penalty != 0) 'pen ${e.penalty}',
  ];
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.stretch,
    children: [
      _thinRule(),
      pw.SizedBox(height: 4),
      pw.Row(
        children: [
          pw.Expanded(
            child: pw.Text(
              'Extras  (${parts.join(', ')})',
              style: const pw.TextStyle(color: _inkSoft, fontSize: 9.5),
            ),
          ),
          pw.Text(
            '${innings.extras}',
            style: pw.TextStyle(
              color: _ink,
              fontSize: 9.5,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ],
      ),
      pw.SizedBox(height: 3),
      pw.Row(
        children: [
          pw.Expanded(
            child: pw.Text(
              'TOTAL',
              style: pw.TextStyle(
                color: _ink,
                fontSize: 11,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
          pw.Text(
            innings.score,
            style: pw.TextStyle(
              color: _ink,
              fontSize: 11,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ],
      ),
    ],
  );
}

pw.Widget _didNotBat(MatchCenter center, MatchInnings innings) {
  // Squad members who don't appear in the batting card.
  final squad = center.squads
      .where((s) =>
          s.teamName.trim().toLowerCase() ==
          innings.battingTeamName.trim().toLowerCase())
      .map((s) => s.players)
      .expand((p) => p)
      .toList(growable: false);
  if (squad.isEmpty) return pw.SizedBox();
  final batted = innings.batting
      .map((b) => b.name.trim().toLowerCase())
      .toSet();
  final dnb = squad
      .where((p) => !batted.contains(p.name.trim().toLowerCase()))
      .map((p) => p.name)
      .toList(growable: false);
  if (dnb.isEmpty) return pw.SizedBox();
  return pw.Padding(
    padding: const pw.EdgeInsets.only(top: 5),
    child: pw.Text(
      'Did not bat:  ${dnb.join(', ')}',
      style: pw.TextStyle(
        color: _inkSoft,
        fontSize: 9,
        fontStyle: pw.FontStyle.italic,
      ),
    ),
  );
}

pw.Widget _fallOfWickets(MatchInnings innings) {
  final text = innings.fallOfWickets
      .map((f) => '${f.score} (${f.player}, ${f.over})')
      .join('  ·  ');
  return pw.RichText(
    text: pw.TextSpan(
      children: [
        pw.TextSpan(
          text: 'Fall of wickets   ',
          style: pw.TextStyle(
            color: _ink,
            fontSize: 8.5,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.TextSpan(
          text: text,
          style: const pw.TextStyle(color: _inkSoft, fontSize: 8.5),
        ),
      ],
    ),
  );
}

// ── Result + meta ─────────────────────────────────────────────────────────
pw.Widget _resultBlock(MatchCenter center) {
  final result = center.resultSummary?.trim();
  if (result == null || result.isEmpty) return pw.SizedBox();
  return pw.Container(
    width: double.infinity,
    padding: const pw.EdgeInsets.symmetric(vertical: 9, horizontal: 12),
    decoration: pw.BoxDecoration(
      border: pw.Border.all(color: _rule, width: 1.4),
    ),
    child: pw.Column(
      children: [
        pw.Text(
          _spaced('RESULT'),
          style: pw.TextStyle(
            color: _inkSoft,
            fontSize: 7.5,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 3),
        pw.Text(
          result,
          textAlign: pw.TextAlign.center,
          style: pw.TextStyle(
            color: _ink,
            fontSize: 12.5,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
      ],
    ),
  );
}

pw.Widget _metaFooter(MatchCenter center) {
  final rows = <String>[
    if (center.tossSummary?.trim().isNotEmpty == true)
      'Toss   ${center.tossSummary!.trim()}',
    if (center.formatLabel?.trim().isNotEmpty == true)
      'Format   ${center.formatLabel!.trim()}',
    if (center.venueLabel?.trim().isNotEmpty == true)
      'Venue   ${center.venueLabel!.trim()}',
    if (center.scheduledAt != null) 'Date   ${_fmtDate(center.scheduledAt!)}',
  ];
  if (rows.isEmpty) return pw.SizedBox();
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.center,
    children: [
      for (final r in rows)
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 1),
          child: pw.Text(
            r,
            style: const pw.TextStyle(color: _inkSoft, fontSize: 8.5),
          ),
        ),
    ],
  );
}

pw.Widget _brand() {
  return pw.Center(
    child: pw.RichText(
      text: pw.TextSpan(
        children: [
          pw.TextSpan(
            text: 'Scored on ',
            style: const pw.TextStyle(color: _inkSoft, fontSize: 9),
          ),
          pw.TextSpan(
            text: 'Swing',
            style: pw.TextStyle(
              color: _accent,
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ],
      ),
    ),
  );
}

// ── Primitives ────────────────────────────────────────────────────────────
pw.TableRow _headRow(List<String> cells) {
  pw.Widget head(String t, {required bool first}) => pw.Padding(
        padding: const pw.EdgeInsets.fromLTRB(4, 3, 4, 4),
        child: pw.Text(
          t,
          textAlign: first ? pw.TextAlign.left : pw.TextAlign.right,
          style: pw.TextStyle(
            color: _inkSoft,
            fontSize: 7.5,
            fontWeight: pw.FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      );
  return pw.TableRow(
    decoration: const pw.BoxDecoration(
      border: pw.Border(
        top: pw.BorderSide(color: _rule, width: 0.9),
        bottom: pw.BorderSide(color: _ruleThin, width: 0.7),
      ),
    ),
    children: [
      for (var i = 0; i < cells.length; i++)
        head(cells[i], first: i == 0),
    ],
  );
}

pw.Widget _num(String value, {bool bold = false}) {
  return pw.Padding(
    padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 5),
    child: pw.Text(
      value,
      textAlign: pw.TextAlign.right,
      style: pw.TextStyle(
        color: _ink,
        fontSize: 10.5,
        fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
      ),
    ),
  );
}

pw.Widget _thinRule() => pw.Container(height: 0.7, color: _ruleThin);

pw.Widget _doubleRule() => pw.Column(
      children: [
        pw.Container(height: 1.4, color: _rule),
        pw.SizedBox(height: 1.6),
        pw.Container(height: 0.6, color: _rule),
      ],
    );

// "182/6 (20.0 ov)" → "182 for 6 (20.0 overs)"
String _classicScore(String raw) {
  var s = raw.replaceFirst('/', ' for ');
  s = s.replaceAll(RegExp(r'\bov\b'), 'overs').replaceAll('ov)', 'overs)');
  return s;
}

// Letter-spacing for the classic scorebook headings: "MUMBAI" → "M U M B A I".
String _spaced(String s) => s.split('').join('  ');

String _fmtDate(DateTime d) {
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  return '${d.day} ${months[d.month - 1]} ${d.year}';
}
