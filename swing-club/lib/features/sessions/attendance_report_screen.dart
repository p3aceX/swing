import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../shared/widgets.dart';
import '../batches/batch_provider.dart';
import 'session_provider.dart';

class AttendanceReportScreen extends ConsumerStatefulWidget {
  const AttendanceReportScreen({super.key});

  @override
  ConsumerState<AttendanceReportScreen> createState() => _AttendanceReportScreenState();
}

class _AttendanceReportScreenState extends ConsumerState<AttendanceReportScreen> {
  DateTime _from = DateTime.now().subtract(const Duration(days: 30));
  DateTime _to = DateTime.now();
  String? _batchId;

  SessionFilter get _filter => SessionFilter(from: _from, to: _to, batchId: _batchId);

  @override
  Widget build(BuildContext context) {
    final reportState = ref.watch(attendanceReportProvider(_filter));
    final batchesState = ref.watch(batchesProvider);
    final fmt = DateFormat('d MMM');

    return Scaffold(
      appBar: AppBar(title: const Text('Attendance Report')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                OutlinedButton.icon(
                  icon: const Icon(Icons.date_range_outlined, size: 15),
                  label: Text('${fmt.format(_from)} – ${fmt.format(_to)}',
                      style: const TextStyle(fontSize: 13)),
                  onPressed: () => _pickRange(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                const SizedBox(width: 8),
                if ((batchesState.valueOrNull ?? []).isNotEmpty)
                  Expanded(
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String?>(
                        value: _batchId,
                        hint: const Text('All Batches', style: TextStyle(fontSize: 13)),
                        isDense: true,
                        items: [
                          const DropdownMenuItem(value: null, child: Text('All Batches')),
                          ...(batchesState.valueOrNull ?? []).map((b) => DropdownMenuItem(
                              value: b['id'] as String,
                              child: Text(b['name'] as String? ?? ''))),
                        ],
                        onChanged: (v) => setState(() => _batchId = v),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: reportState.when(
              loading: loadingBody,
              error: (e, _) =>
                  errorBody(e, () => ref.invalidate(attendanceReportProvider(_filter))),
              data: (report) => _ReportBody(report: report),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickRange(BuildContext context) async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: _from, end: _to),
    );
    if (range != null) {
      setState(() {
        _from = range.start;
        _to = range.end;
      });
    }
  }
}

class _ReportBody extends StatelessWidget {
  final Map<String, dynamic> report;

  const _ReportBody({required this.report});

  @override
  Widget build(BuildContext context) {
    final totalSessions = report['totalSessions'] as int? ?? 0;
    final avgPct = (report['averageAttendancePercent'] as num?)?.toDouble() ?? 0.0;
    final students = (report['students'] as List? ?? []).cast<Map<String, dynamic>>();

    return ListView(
      children: [
        _SummaryRow(totalSessions: totalSessions, avgPct: avgPct, atRisk: students
            .where((s) => _pct(s) < 70)
            .length),
        const Divider(),
        ...students.map((s) => _StudentAttRow(student: s)),
      ],
    );
  }

  double _pct(Map<String, dynamic> s) {
    final present = s['sessionsPresent'] as int? ?? 0;
    final total = s['sessionsTotal'] as int? ?? 0;
    return total == 0 ? 0 : present / total * 100;
  }
}

class _SummaryRow extends StatelessWidget {
  final int totalSessions;
  final double avgPct;
  final int atRisk;

  const _SummaryRow({required this.totalSessions, required this.avgPct, required this.atRisk});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Row(
          children: [
            _Stat(value: '$totalSessions', label: 'Sessions'),
            const VerticalDivider(),
            _Stat(value: '${avgPct.toStringAsFixed(0)}%', label: 'Avg Attendance'),
            const VerticalDivider(),
            _Stat(value: '$atRisk', label: 'At Risk (<70%)'),
          ],
        ),
      );
}

class _Stat extends StatelessWidget {
  final String value;
  final String label;

  const _Stat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) => Expanded(
        child: Column(
          children: [
            Text(value,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 2),
            Text(label,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
                textAlign: TextAlign.center),
          ],
        ),
      );
}

class _StudentAttRow extends StatelessWidget {
  final Map<String, dynamic> student;

  const _StudentAttRow({required this.student});

  @override
  Widget build(BuildContext context) {
    final user = student['user'] as Map<String, dynamic>? ?? {};
    final present = student['sessionsPresent'] as int? ?? 0;
    final total = student['sessionsTotal'] as int? ?? 0;
    final pct = total == 0 ? 0.0 : present / total * 100;

    Color color;
    if (pct >= 80) {
      color = const Color(0xFF2E7D32);
    } else if (pct >= 60) {
      color = const Color(0xFFF57F17);
    } else {
      color = const Color(0xFFC62828);
    }

    return Column(
      children: [
        ListTile(
          title: Text(user['name'] as String? ?? '—'),
          subtitle: Text('$present / $total sessions'),
          trailing: Text(
            '${pct.toStringAsFixed(0)}%',
            style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 16),
          ),
        ),
        const Divider(),
      ],
    );
  }
}
