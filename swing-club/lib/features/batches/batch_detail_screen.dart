import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants.dart';
import '../../shared/widgets.dart';
import 'batch_provider.dart';
import 'batch_form_sheet.dart';
import '../students/enroll_student_sheet.dart';

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
            _StudentsTab(batch: batch, batchId: widget.batchId),
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
        heroTag: null,
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
  final Set<int> _selectedDays = {1};
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
    if (_selectedDays.isEmpty) {
      showSnack(context, 'Select at least one day');
      return;
    }
    setState(() => _isLoading = true);
    try {
      for (final day in _selectedDays) {
        await ref.read(batchSchedulesProvider(widget.batchId).notifier).add({
          'dayOfWeek': day,
          'startTime': _startCtrl.text.trim(),
          'endTime': _endCtrl.text.trim(),
          if (_noteCtrl.text.isNotEmpty) 'groundNote': _noteCtrl.text.trim(),
        });
      }
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
          const Text('Days', style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            children: List.generate(7, (i) {
              final selected = _selectedDays.contains(i);
              return GestureDetector(
                onTap: () => setState(() =>
                    selected ? _selectedDays.remove(i) : _selectedDays.add(i)),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: selected ? const Color(0xFF071B3D) : const Color(0xFFECEAE3),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(kDayLabels[i],
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: selected ? Colors.white : Colors.grey,
                      )),
                ),
              );
            }),
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

class _StudentsTab extends ConsumerStatefulWidget {
  final Map<String, dynamic> batch;
  final String batchId;

  const _StudentsTab({required this.batch, required this.batchId});

  @override
  ConsumerState<_StudentsTab> createState() => _StudentsTabState();
}

class _StudentsTabState extends ConsumerState<_StudentsTab> {
  final _searchCtrl = TextEditingController();
  String _query     = '';
  int    _shown     = 20;

  static const _pageSize = 20;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _enrollments =>
      (widget.batch['enrollments'] as List? ?? [])
          .cast<Map<String, dynamic>>();

  List<Map<String, dynamic>> get _filtered {
    if (_query.isEmpty) return _enrollments;
    final q = _query.toLowerCase();
    return _enrollments.where((e) {
      final user  = e['user'] as Map<String, dynamic>? ?? {};
      final name  = (user['name']  as String? ?? '').toLowerCase();
      final phone = (user['phone'] as String? ?? '').toLowerCase();
      return name.contains(q) || phone.contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    final visible  = filtered.take(_shown).toList();
    final total    = _enrollments.length;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          // ── search + count bar ──────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Row(children: [
              Expanded(
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: (v) => setState(() { _query = v; _shown = _pageSize; }),
                  style: const TextStyle(fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Search by name or phone…',
                    hintStyle: const TextStyle(fontSize: 14, color: Colors.grey),
                    prefixIcon: const Icon(Icons.search_rounded, size: 20, color: Colors.grey),
                    suffixIcon: _query.isNotEmpty
                        ? GestureDetector(
                            onTap: () => setState(() {
                              _searchCtrl.clear();
                              _query = '';
                              _shown = _pageSize;
                            }),
                            child: const Icon(Icons.close_rounded, size: 18, color: Colors.grey),
                          )
                        : null,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFFE0DED6))),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFFE0DED6))),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFF071B3D))),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF071B3D),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _query.isEmpty
                      ? '$total'
                      : '${filtered.length}/$total',
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13),
                ),
              ),
            ]),
          ),
          // ── list ───────────────────────────────────────────────────────
          Expanded(
            child: filtered.isEmpty
                ? emptyBody(_query.isEmpty ? 'No students in this batch' : 'No results for "$_query"')
                : ListView.separated(
                    padding: const EdgeInsets.only(bottom: 100),
                    itemCount: visible.length + (visible.length < filtered.length ? 1 : 0),
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (_, i) {
                      if (i == visible.length) {
                        return TextButton(
                          onPressed: () => setState(() => _shown += _pageSize),
                          child: Text(
                            'Load more (${filtered.length - visible.length} remaining)',
                            style: const TextStyle(fontSize: 13),
                          ),
                        );
                      }
                      final e    = visible[i];
                      final user = e['user'] as Map<String, dynamic>? ?? {};
                      final name  = user['name']  as String? ?? '—';
                      final phone = user['phone'] as String? ?? '';
                      final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
                      final color   = _avatarColor(name);

                      return ListTile(
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        leading: CircleAvatar(
                          radius: 20,
                          backgroundColor: color.withOpacity(0.15),
                          child: Text(initial,
                              style: TextStyle(
                                  color: color,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 15)),
                        ),
                        title: Text(name,
                            style: const TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 14)),
                        subtitle: phone.isNotEmpty
                            ? Text(phone,
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.grey))
                            : null,
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            statusBadge(e['enrollmentStatus'] as String? ?? ''),
                            if (phone.isNotEmpty) ...[
                              const SizedBox(width: 4),
                              IconButton(
                                icon: const Icon(Icons.call_rounded,
                                    size: 20, color: Color(0xFF2E7D32)),
                                onPressed: () => launchUrl(
                                    Uri.parse('tel:$phone'),
                                    mode: LaunchMode.externalApplication),
                                tooltip: 'Call $phone',
                                visualDensity: VisualDensity.compact,
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.small(
        heroTag: null,
        onPressed: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
          builder: (_) => EnrollStudentSheet(
              batchId: widget.batchId,
              batchName: widget.batch['name'] as String?),
        ).then((enrolled) {
          if (enrolled == true) ref.invalidate(batchDetailProvider(widget.batchId));
        }),
        child: const Icon(Icons.person_add_outlined),
      ),
    );
  }
}

Color _avatarColor(String name) {
  const colors = [
    Color(0xFF1565C0), Color(0xFF6A1B9A), Color(0xFF00695C),
    Color(0xFFE65100), Color(0xFF4527A0), Color(0xFF283593),
    Color(0xFF558B2F), Color(0xFFC62828),
  ];
  return colors[name.codeUnits.fold(0, (a, b) => a + b) % colors.length];
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
