import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../shared/widgets.dart';
import '../batches/batch_provider.dart';
import 'session_provider.dart';

class SessionListScreen extends ConsumerStatefulWidget {
  const SessionListScreen({super.key});

  @override
  ConsumerState<SessionListScreen> createState() => _SessionListScreenState();
}

class _SessionListScreenState extends ConsumerState<SessionListScreen> {
  late DateTime _from = DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1));
  late DateTime _to = _from.add(const Duration(days: 6));
  String? _batchId;

  SessionFilter get _filter => SessionFilter(from: _from, to: _to, batchId: _batchId);

  @override
  Widget build(BuildContext context) {
    final sessionsState = ref.watch(sessionsProvider(_filter));
    final batchesState = ref.watch(batchesProvider);

    return Scaffold(
      body: Column(
        children: [
          _FilterBar(
            from: _from,
            to: _to,
            batchId: _batchId,
            batches: batchesState.valueOrNull ?? [],
            onFromChanged: (d) => setState(() => _from = d),
            onToChanged: (d) => setState(() => _to = d),
            onBatchChanged: (id) => setState(() => _batchId = id),
          ),
          const Divider(height: 1),
          Expanded(
            child: sessionsState.when(
              loading: loadingBody,
              error: (e, _) =>
                  errorBody(e, () => ref.invalidate(sessionsProvider(_filter))),
              data: (sessions) => sessions.isEmpty
                  ? emptyBody('No sessions in this period')
                  : RefreshIndicator(
                      onRefresh: () async => ref.invalidate(sessionsProvider(_filter)),
                      child: ListView.separated(
                        padding: EdgeInsets.zero,
                        itemCount: sessions.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (_, i) => _SessionTile(session: sessions[i]),
                      ),
                    ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: null,
        onPressed: () => context.push('/sessions/report'),
        child: const Icon(Icons.assessment_outlined),
      ),
    );
  }
}

class _FilterBar extends StatelessWidget {
  final DateTime from;
  final DateTime to;
  final String? batchId;
  final List<Map<String, dynamic>> batches;
  final ValueChanged<DateTime> onFromChanged;
  final ValueChanged<DateTime> onToChanged;
  final ValueChanged<String?> onBatchChanged;

  const _FilterBar({
    required this.from,
    required this.to,
    required this.batchId,
    required this.batches,
    required this.onFromChanged,
    required this.onToChanged,
    required this.onBatchChanged,
  });

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('d MMM');
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () => _pickRange(context),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today_rounded, size: 16),
                    const SizedBox(width: 8),
                    Text('${fmt.format(from)} – ${fmt.format(to)}',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          if (batches.isNotEmpty)
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String?>(
                    value: batchId,
                    hint: const Text('All Batches', style: TextStyle(fontSize: 13)),
                    isDense: true,
                    icon: const Icon(Icons.keyboard_arrow_down_rounded),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('All Batches')),
                      ...batches.map((b) => DropdownMenuItem(
                          value: b['id'] as String,
                          child: Text(b['name'] as String? ?? ''))),
                    ],
                    onChanged: onBatchChanged,
                  ),
                ),
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
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: DateTimeRange(start: from, end: to),
    );
    if (range != null) {
      onFromChanged(range.start);
      onToChanged(range.end);
    }
  }
}

class _SessionTile extends StatelessWidget {
  final Map<String, dynamic> session;

  const _SessionTile({required this.session});

  @override
  Widget build(BuildContext context) {
    final batch = session['batch'] as Map<String, dynamic>? ?? {};
    final coach = session['coach'] as Map<String, dynamic>? ?? {};
    final status = session['status'] as String? ?? '';
    final dt = session['scheduledAt'] as String? ?? session['startTime'] as String? ?? '';

    String dateLabel = dt;
    if (dt.isNotEmpty) {
      try {
        final parsed = DateTime.parse(dt).toLocal();
        dateLabel = DateFormat('d MMM, HH:mm').format(parsed);
      } catch (_) {}
    }

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      title: Text(
        batch['name'] as String? ?? session['sessionType'] as String? ?? 'Session',
        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
      ),
      subtitle: Text('${coach['name'] ?? 'Unassigned'} · $dateLabel', style: const TextStyle(fontSize: 13)),
      trailing: statusBadge(status),
      onTap: () => context.push('/sessions/${session['id']}'),
    );
  }
}
