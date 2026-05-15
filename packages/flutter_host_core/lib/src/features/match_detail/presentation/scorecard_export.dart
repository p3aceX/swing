import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../domain/match_models.dart';

// Shareable match scorecard as a PDF. A full card (11+11 batsmen +
// bowlers) is unavoidably long, so `pw.MultiPage` paginates it across
// A4 pages automatically. `pw.Table` with explicit column widths keeps
// the numeric columns aligned and roomy. `PdfPreview` (printing pkg)
// renders the doc and exposes share / save / print actions for free.

const PdfColor _ink = PdfColor.fromInt(0xFF0A0B0A);
const PdfColor _inkSub = PdfColor.fromInt(0xFF6B6B6B);
const PdfColor _accent = PdfColor.fromInt(0xFF2BA84A);
const PdfColor _zebra = PdfColor.fromInt(0xFFF6F5F0);
const PdfColor _line = PdfColor.fromInt(0xFFE2E0D8);
const PdfColor _headerBg = PdfColor.fromInt(0xFF0A0B0A);

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
        // Toolbar exposes Share + Save/Print across platforms — covers
        // both "download" and "share to WhatsApp".
        useActions: true,
      ),
    );
  }
}

Future<Uint8List> _buildScorecardPdf(
  MatchCenter center,
  PdfPageFormat format,
) async {
  final doc = pw.Document();
  final innings =
      center.innings.where((i) => !i.isSuperOver).toList(growable: false);
  final superOvers =
      center.innings.where((i) => i.isSuperOver).toList(growable: false);

  doc.addPage(
    pw.MultiPage(
      pageFormat: format.copyWith(
        marginTop: 0,
        marginBottom: 24,
        marginLeft: 0,
        marginRight: 0,
      ),
      build: (context) => [
        _pdfHeader(center),
        pw.SizedBox(height: 4),
        for (final inn in innings) ...[
          _pdfInnings(inn),
          pw.SizedBox(height: 10),
        ],
        for (final so in superOvers) ...[
          _pdfInnings(so, superOver: true),
          pw.SizedBox(height: 10),
        ],
        _pdfFooter(),
      ],
    ),
  );

  return doc.save();
}

pw.Widget _pdfHeader(MatchCenter center) {
  final meta = <String>[
    if (center.formatLabel?.trim().isNotEmpty == true)
      center.formatLabel!.trim(),
    if (center.venueLabel?.trim().isNotEmpty == true) center.venueLabel!.trim(),
  ].join('   ·   ');
  final result = center.resultSummary?.trim();
  return pw.Container(
    width: double.infinity,
    color: _headerBg,
    padding: const pw.EdgeInsets.fromLTRB(24, 22, 24, 18),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          center.competitionLabel?.trim().isNotEmpty == true
              ? center.competitionLabel!.trim().toUpperCase()
              : 'MATCH SCORECARD',
          style: pw.TextStyle(
            color: _accent,
            fontSize: 9,
            fontWeight: pw.FontWeight.bold,
            letterSpacing: 1.4,
          ),
        ),
        pw.SizedBox(height: 7),
        pw.Text(
          '${center.teamAName}  vs  ${center.teamBName}',
          style: pw.TextStyle(
            color: PdfColors.white,
            fontSize: 19,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        if (meta.isNotEmpty) ...[
          pw.SizedBox(height: 5),
          pw.Text(
            meta,
            style: const pw.TextStyle(
              color: PdfColor.fromInt(0xFFBFBFBF),
              fontSize: 10,
            ),
          ),
        ],
        if (result != null && result.isNotEmpty) ...[
          pw.SizedBox(height: 10),
          pw.Container(
            padding:
                const pw.EdgeInsets.symmetric(horizontal: 9, vertical: 5),
            decoration: pw.BoxDecoration(
              color: _accent,
              borderRadius: pw.BorderRadius.circular(5),
            ),
            child: pw.Text(
              result,
              style: pw.TextStyle(
                color: PdfColors.white,
                fontSize: 10.5,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
        ],
      ],
    ),
  );
}

pw.Widget _pdfInnings(MatchInnings innings, {bool superOver = false}) {
  return pw.Container(
    margin: const pw.EdgeInsets.symmetric(horizontal: 24),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        // Innings title bar
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 10),
          color: _zebra,
          child: pw.Row(
            children: [
              pw.Expanded(
                child: pw.Text(
                  superOver
                      ? '${innings.battingTeamName} · Super Over'
                      : innings.battingTeamName,
                  style: pw.TextStyle(
                    color: _ink,
                    fontSize: 13,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.Text(
                innings.score,
                style: pw.TextStyle(
                  color: _ink,
                  fontSize: 13,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        pw.SizedBox(height: 6),
        _battingTable(innings),
        pw.SizedBox(height: 4),
        _extrasLine(innings),
        if (innings.bowling.isNotEmpty) ...[
          pw.SizedBox(height: 10),
          _bowlingTable(innings),
        ],
        if (innings.fallOfWickets.isNotEmpty) ...[
          pw.SizedBox(height: 8),
          _fallOfWickets(innings),
        ],
      ],
    ),
  );
}

pw.Widget _battingTable(MatchInnings innings) {
  return pw.Table(
    columnWidths: {
      0: pw.FlexColumnWidth(),
      1: pw.FixedColumnWidth(40),
      2: pw.FixedColumnWidth(36),
      3: pw.FixedColumnWidth(30),
      4: pw.FixedColumnWidth(30),
      5: pw.FixedColumnWidth(48),
    },
    children: [
      _tableHeader(const ['BATTING', 'R', 'B', '4s', '6s', 'SR']),
      for (var i = 0; i < innings.batting.length; i++)
        _battingRow(innings.batting[i], zebra: i.isOdd),
    ],
  );
}

pw.TableRow _battingRow(MatchBatsmanRow b, {required bool zebra}) {
  return pw.TableRow(
    decoration: zebra ? const pw.BoxDecoration(color: _zebra) : null,
    children: [
      pw.Padding(
        padding: const pw.EdgeInsets.fromLTRB(10, 6, 4, 6),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              b.name,
              style: pw.TextStyle(
                color: _ink,
                fontSize: 10.5,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 1),
            pw.Text(
              b.isOut ? (b.dismissal ?? 'out') : 'not out',
              style: pw.TextStyle(
                color: b.isOut ? _inkSub : _accent,
                fontSize: 8.5,
              ),
            ),
          ],
        ),
      ),
      _numCell('${b.runs}', bold: true),
      _numCell('${b.balls}'),
      _numCell('${b.fours}'),
      _numCell('${b.sixes}'),
      _numCell(b.strikeRate),
    ],
  );
}

pw.Widget _bowlingTable(MatchInnings innings) {
  return pw.Table(
    columnWidths: {
      0: pw.FlexColumnWidth(),
      1: pw.FixedColumnWidth(44),
      2: pw.FixedColumnWidth(40),
      3: pw.FixedColumnWidth(34),
      4: pw.FixedColumnWidth(52),
    },
    children: [
      _tableHeader(const ['BOWLING', 'O', 'R', 'W', 'Econ']),
      for (var i = 0; i < innings.bowling.length; i++)
        _bowlingRow(innings.bowling[i], zebra: i.isOdd),
    ],
  );
}

pw.TableRow _bowlingRow(MatchBowlerRow w, {required bool zebra}) {
  final extras = <String>[
    if (w.wides > 0) 'wd ${w.wides}',
    if (w.noBalls > 0) 'nb ${w.noBalls}',
  ].join(', ');
  return pw.TableRow(
    decoration: zebra ? const pw.BoxDecoration(color: _zebra) : null,
    children: [
      pw.Padding(
        padding: const pw.EdgeInsets.fromLTRB(10, 6, 4, 6),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              w.name,
              style: pw.TextStyle(
                color: _ink,
                fontSize: 10.5,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            if (extras.isNotEmpty) ...[
              pw.SizedBox(height: 1),
              pw.Text(
                extras,
                style: const pw.TextStyle(color: _inkSub, fontSize: 8.5),
              ),
            ],
          ],
        ),
      ),
      _numCell(w.overs),
      _numCell('${w.runs}'),
      _numCell('${w.wickets}', bold: true),
      _numCell(w.economy),
    ],
  );
}

pw.Widget _extrasLine(MatchInnings innings) {
  final e = innings.extrasBreakdown;
  final parts = <String>[
    if (e.wides != 0) 'wd ${e.wides}',
    if (e.noBalls != 0) 'nb ${e.noBalls}',
    if (e.byes != 0) 'b ${e.byes}',
    if (e.legByes != 0) 'lb ${e.legByes}',
    if (e.penalty != 0) 'pen ${e.penalty}',
  ];
  final detail = parts.isEmpty ? '' : ' (${parts.join(', ')})';
  return pw.Padding(
    padding: const pw.EdgeInsets.symmetric(horizontal: 10),
    child: pw.Row(
      children: [
        pw.Expanded(
          child: pw.Text(
            'Extras$detail',
            style: pw.TextStyle(
              color: _inkSub,
              fontSize: 9.5,
              fontWeight: pw.FontWeight.bold,
            ),
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
  );
}

pw.Widget _fallOfWickets(MatchInnings innings) {
  final text = innings.fallOfWickets
      .map((f) => '${f.score} (${f.player}, ${f.over})')
      .join('   ');
  return pw.Padding(
    padding: const pw.EdgeInsets.symmetric(horizontal: 10),
    child: pw.RichText(
      text: pw.TextSpan(
        children: [
          pw.TextSpan(
            text: 'Fall of wickets  ',
            style: pw.TextStyle(
              color: _inkSub,
              fontSize: 8.5,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.TextSpan(
            text: text,
            style: const pw.TextStyle(color: _inkSub, fontSize: 8.5),
          ),
        ],
      ),
    ),
  );
}

pw.TableRow _tableHeader(List<String> cells) {
  pw.Widget head(String t, {bool first = false}) => pw.Padding(
        padding: pw.EdgeInsets.fromLTRB(first ? 10 : 4, 5, 4, 5),
        child: pw.Text(
          t,
          textAlign: first ? pw.TextAlign.left : pw.TextAlign.right,
          style: pw.TextStyle(
            color: _inkSub,
            fontSize: 8,
            fontWeight: pw.FontWeight.bold,
            letterSpacing: 0.6,
          ),
        ),
      );
  return pw.TableRow(
    decoration: const pw.BoxDecoration(
      border: pw.Border(bottom: pw.BorderSide(color: _line, width: 1)),
    ),
    children: [
      for (var i = 0; i < cells.length; i++) head(cells[i], first: i == 0),
    ],
  );
}

pw.Widget _numCell(String value, {bool bold = false}) {
  return pw.Padding(
    padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 6),
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

pw.Widget _pdfFooter() {
  return pw.Container(
    margin: const pw.EdgeInsets.only(top: 6),
    padding: const pw.EdgeInsets.symmetric(vertical: 8),
    alignment: pw.Alignment.center,
    child: pw.RichText(
      text: pw.TextSpan(
        children: [
          pw.TextSpan(
            text: 'Scored on ',
            style: const pw.TextStyle(color: _inkSub, fontSize: 9),
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
