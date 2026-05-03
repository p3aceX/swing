import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants.dart';
import '../../shared/widgets.dart';
import 'batch_provider.dart';
import 'batch_form_sheet.dart';

class BatchDetailScreen extends ConsumerStatefulWidget {
  final String batchId;

  const BatchDetailScreen({super.key, required this.batchId});

  @override
  ConsumerState<BatchDetailScreen> createState() => _BatchDetailScreenState();
}

class _BatchDetailScreenState extends ConsumerState<BatchDetailScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs = TabController(length: 4, vsync: this);

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final detailState = ref.watch(batchDetailProvider(widget.batchId));

    return Scaffold(
      appBar: AppBar(
        title: detailState.maybeWhen(
          data: (b) => Text(b['name'] as String? ?? 'Batch'),
          orElse: () => const Text('Batch'),
        ),
        actions: [
          detailState.maybeWhen(
            data: (b) => IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => _showEdit(context, b),
            ),
            orElse: () => const SizedBox.shrink(),
          ),
        ],
        bottom: TabBar(
          controller: _tabs,
          tabs: const [
            Tab(text: 'Info'),
            Tab(text: 'Schedule'),
            Tab(text: 'Students'),
            Tab(text: 'Coaches'),
          ],
        ),
      ),
      body: detailState.when(
        loading: loadingBody,
        error: (e, _) =>
            errorBody(e, () => ref.invalidate(batchDetailProvider(widget.batchId))),
        data: (batch) => TabBarView(
          controller: _tabs,
          children: [
            _InfoTab(batch: batch),
            _ScheduleTab(batchId: widget.batchId),
            _StudentsTab(batch: batch),
            _CoachesTab(batch: batch, batchId: widget.batchId),
          ],
        ),
      ),
    );
  }

  void _showEdit(BuildContext context, Map<String, dynamic> batch) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => BatchFormSheet(existing: batch),
    ).then((updated) {
      if (updated == true) ref.invalidate(batchDetailProvider(widget.batchId));
    });
  }
}

class _InfoTab extends StatelessWidget {
  final Map<String, dynamic> batch;

  const _InfoTab({required this.batch});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _InfoRow('Name', batch['name'] as String? ?? '—'),
        const Divider(),
        _InfoRow('Age Group', batch['ageGroup'] as String? ?? '—'),
        const Divider(),
        _InfoRow('Sport', batch['sport'] as String? ?? '—'),
        const Divider(),
        _InfoRow('Max Students', '${batch['maxStudents'] ?? '—'}'),
        if (batch['description'] != null) ...[
          const Divider(),
          _InfoRow('Description', batch['description'] as String),
        ],
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            SizedBox(
              width: 120,
              child: Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
            ),
            Expanded(
              child: Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            ),
          ],
        ),
      );
}

class _ScheduleTab extends ConsumerStatefulWidget {
  final String batchId;

  const _ScheduleTab({required this.batchId});

  @override
  ConsumerState<_ScheduleTab> createState() => _ScheduleTabState();
}

class _ScheduleTabState extends ConsumerState<_ScheduleTab> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(batchSchedulesProvider(widget.batchId));

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: state.when(
        loading: loadingBody,
        error: (e, _) =>
            errorBody(e, () => ref.invalidate(batchSchedulesProvider(widget.batchId))),
        data: (schedules) => schedules.isEmpty
            ? emptyBody('No schedule yet')
            : ListView.separated(
                itemCount: schedules.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (_, i) => _ScheduleTile(
                  schedule: schedules[i],
                  onDelete: () => _delete(schedules[i]['id'] as String),
                ),
              ),
      ),
      floatingActionButton: FloatingActionButton.small(
        onPressed: _showAddSheet,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _delete(String scheduleId) async {
    await ref.read(batchSchedulesProvider(widget.batchId).notifier).remove(scheduleId);
  }

  void _showAddSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => _AddScheduleSheet(batchId: widget.batchId),
    );
  }
}

class _ScheduleTile extends StatelessWidget {
  final Map<String, dynamic> schedule;
  final VoidCallback onDelete;

  const _ScheduleTile({required this.schedule, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final day = kDayLabels[schedule['dayOfWeek'] as int? ?? 0];
    final start = schedule['startTime'] as String? ?? '';
    final end = schedule['endTime'] as String? ?? '';
    final note = schedule['groundNote'] as String?;

    return ListTile(
      title: Text('$day  $start – $end',
          style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: note != null ? Text(note) : null,
      trailing: IconButton(
        icon: const Icon(Icons.delete_outline, size: 20, color: Colors.grey),
        onPressed: onDelete,
      ),
    );
  }
}

class _AddScheduleSheet extends ConsumerStatefulWidget {
  final String batchId;

  const _AddScheduleSheet({required this.batchId});

  @override
  ConsumerState<_AddScheduleSheet> createState() => _AddScheduleSheetState();
}

class _AddScheduleSheetState extends ConsumerState<_AddScheduleSheet> {
  int _day = 1;
  final _startCtrl = TextEditingController(text: '08:00');
  final _endCtrl = TextEditingController(text: '10:00');
  final _noteCtrl = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _startCtrl.dispose();
    _endCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _isLoading = true);
    try {
      await ref.read(batchSchedulesProvider(widget.batchId).notifier).add({
        'dayOfWeek': _day,
        'startTime': _startCtrl.text.trim(),
        'endTime': _endCtrl.text.trim(),
        if (_noteCtrl.text.isNotEmpty) 'groundNote': _noteCtrl.text.trim(),
      });
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) showSnack(context, e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20, right: 20, top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Add Schedule', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          DropdownButtonFormField<int>(
            value: _day,
            decoration: const InputDecoration(labelText: 'Day of Week'),
            items: List.generate(7, (i) => DropdownMenuItem(value: i, child: Text(kDayLabels[i]))),
            onChanged: (v) => setState(() => _day = v!),
          ),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(
              child: TextFormField(
                controller: _startCtrl,
                decoration: const InputDecoration(labelText: 'Start (HH:mm)'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _endCtrl,
                decoration: const InputDecoration(labelText: 'End (HH:mm)'),
              ),
            ),
          ]),
          const SizedBox(height: 12),
          TextFormField(
            controller: _noteCtrl,
            decoration: const InputDecoration(labelText: 'Ground Note (optional)'),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _isLoading ? null : _save,
            child: const Text('Add Schedule'),
          ),
        ],
      ),
    );
  }
}

class _StudentsTab extends StatelessWidget {
  final Map<String, dynamic> batch;

  const _StudentsTab({required this.batch});

  @override
  Widget build(BuildContext context) {
    final enrollments =
        (batch['enrollments'] as List? ?? []).cast<Map<String, dynamic>>();
    if (enrollments.isEmpty) return emptyBody('No students in this batch');
    return ListView.separated(
      itemCount: enrollments.length,
      separatorBuilder: (_, __) => const Divider(),
      itemBuilder: (_, i) {
        final e = enrollments[i];
        final user = e['user'] as Map<String, dynamic>? ?? {};
        return ListTile(
          title: Text(user['name'] as String? ?? '—',
              style: const TextStyle(fontWeight: FontWeight.w500)),
          trailing: statusBadge(e['enrollmentStatus'] as String? ?? ''),
        );
      },
    );
  }
}

class _CoachesTab extends ConsumerWidget {
  final Map<String, dynamic> batch;
  final String batchId;

  const _CoachesTab({required this.batch, required this.batchId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coaches =
        (batch['coaches'] as List? ?? []).cast<Map<String, dynamic>>();
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: coaches.isEmpty
          ? emptyBody('No coaches assigned')
          : ListView.separated(
              itemCount: coaches.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (_, i) {
                final c = coaches[i];
                final user = c['user'] as Map<String, dynamic>? ?? {};
                return ListTile(
                  title: Text(user['name'] as String? ?? '—',
                      style: const TextStyle(fontWeight: FontWeight.w500)),
                  trailing: c['isHeadCoach'] == true
                      ? statusBadge('HEAD')
                      : null,
                );
              },
            ),
    );
  }
}
