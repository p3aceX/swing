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
      appBar: AppBar(
        title: const Text('Sessions'),
        actions: [
          TextButton(
            onPressed: () => context.push('/sessions/report'),
            child: const Text('Report'),
          ),
        ],
      ),
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
          const Divider(),
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
                        itemCount: sessions.length,
                        separatorBuilder: (_, __) => const Divider(),
                        itemBuilder: (_, i) => _SessionTile(session: sessions[i]),
                      ),
                    ),
            ),
          ),
        ],
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
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          OutlinedButton.icon(
            icon: const Icon(Icons.calendar_today_outlined, size: 15),
            label: Text('${fmt.format(from)} – ${fmt.format(to)}',
                style: const TextStyle(fontSize: 13)),
            onPressed: () => _pickRange(context),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
          const SizedBox(width: 8),
          if (batches.isNotEmpty)
            Expanded(
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String?>(
                  value: batchId,
                  hint: const Text('All Batches', style: TextStyle(fontSize: 13)),
                  isDense: true,
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
      title: Text(
        batch['name'] as String? ?? session['sessionType'] as String? ?? 'Session',
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Text('${coach['name'] ?? 'Unassigned'} · $dateLabel'),
      trailing: statusBadge(status),
      onTap: () => context.push('/sessions/${session['id']}'),
    );
  }
}
