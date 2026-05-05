import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants.dart';
import '../../shared/widgets.dart';
import 'batch_provider.dart';
import '../fees/fee_provider.dart';
import '../students/enroll_student_sheet.dart';

class BatchDetailScreen extends ConsumerStatefulWidget {
  final String batchId;

  const BatchDetailScreen({super.key, required this.batchId});

  @override
  ConsumerState<BatchDetailScreen> createState() => _BatchDetailScreenState();
}

class _BatchDetailScreenState extends ConsumerState<BatchDetailScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs = TabController(length: 5, vsync: this);

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
              onPressed: () => context.push(
                '/batches/${widget.batchId}/edit',
                extra: b,
              ),
            ),
            orElse: () => const SizedBox.shrink(),
          ),
        ],
        bottom: TabBar(
          controller: _tabs,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          tabs: const [
            Tab(text: 'Info'),
            Tab(text: 'Schedule'),
            Tab(text: 'Students'),
            Tab(text: 'Coaches'),
            Tab(text: 'Payments'),
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
            _InfoTab(batch: batch, batchId: widget.batchId),
            _ScheduleTab(batchId: widget.batchId),
            _StudentsTab(batch: batch, batchId: widget.batchId),
            _CoachesTab(batch: batch, batchId: widget.batchId),
            _BatchPaymentsTab(batchId: widget.batchId, batch: batch),
          ],
        ),
      ),
    );
  }
}

class _InfoTab extends ConsumerWidget {
  final Map<String, dynamic> batch;
  final String batchId;

  const _InfoTab({required this.batch, required this.batchId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enrollments = (batch['enrollments'] as List? ?? []).cast<Map<String, dynamic>>();
    final totalStudents  = enrollments.length;
    final activeStudents = enrollments.where((e) {
      final s = (e['enrollmentStatus'] as String? ?? '').toUpperCase();
      return s == 'ACTIVE' || s == 'TRIAL';
    }).length;

    final paymentsAsync = ref.watch(batchPaymentsProvider(batchId));

    int receivedPaise = 0;
    int pendingPaise  = 0;
    paymentsAsync.whenData((payments) {
      for (final p in payments) {
        final status = (p['status'] as String? ?? '').toUpperCase();
        final amount = (p['amountPaise'] as num? ?? 0).toInt();
        if (status == 'PAID' || status == 'COMPLETED') {
          receivedPaise += amount;
        } else if (status == 'PENDING' || status == 'OVERDUE') {
          pendingPaise += amount;
        }
      }
    });

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // ── Metrics row ────────────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF071B3D),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              _MetricTile(
                value: '$totalStudents',
                label: 'Total',
                icon: Icons.group_rounded,
                color: Colors.white,
              ),
              _vDivider(),
              _MetricTile(
                value: '$activeStudents',
                label: 'Active',
                icon: Icons.check_circle_outline_rounded,
                color: const Color(0xFF4CAF50),
              ),
              _vDivider(),
              _MetricTile(
                value: rupeesFromPaise(receivedPaise),
                label: 'Received',
                icon: Icons.arrow_downward_rounded,
                color: const Color(0xFF4CAF50),
                loading: paymentsAsync.isLoading,
              ),
              _vDivider(),
              _MetricTile(
                value: rupeesFromPaise(pendingPaise),
                label: 'Pending',
                icon: Icons.schedule_rounded,
                color: const Color(0xFFFFA726),
                loading: paymentsAsync.isLoading,
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),
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

  Widget _vDivider() => Container(
    width: 1, height: 40,
    color: Colors.white.withValues(alpha: 0.15),
  );
}

class _MetricTile extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;
  final bool loading;

  const _MetricTile({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(height: 6),
          loading
              ? const SizedBox(
                  width: 14, height: 14,
                  child: CircularProgressIndicator(color: Colors.white54, strokeWidth: 1.5),
                )
              : Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w900, color: Colors.white,
                  ),
                ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(fontSize: 10, color: Colors.white54, fontWeight: FontWeight.w600),
          ),
        ],
      ),
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
              final cs = Theme.of(context).colorScheme;
              return GestureDetector(
                onTap: () => setState(() =>
                    selected ? _selectedDays.remove(i) : _selectedDays.add(i)),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: selected ? cs.onSurface : cs.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(kDayLabels[i],
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: selected ? cs.surface : cs.onSurface.withValues(alpha: 0.6),
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
    final cs = Theme.of(context).colorScheme;

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
                    hintStyle: TextStyle(fontSize: 14, color: cs.onSurface.withValues(alpha: 0.4)),
                    prefixIcon: Icon(Icons.search_rounded, size: 20, color: cs.onSurface.withValues(alpha: 0.4)),
                    suffixIcon: _query.isNotEmpty
                        ? GestureDetector(
                            onTap: () => setState(() {
                              _searchCtrl.clear();
                              _query = '';
                              _shown = _pageSize;
                            }),
                            child: Icon(Icons.close_rounded, size: 18, color: cs.onSurface.withValues(alpha: 0.4)),
                          )
                        : null,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: cs.outlineVariant)),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: cs.outlineVariant)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: cs.primary)),
                    filled: true,
                    fillColor: cs.surfaceContainerHighest,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: cs.onSurface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _query.isEmpty
                      ? '$total'
                      : '${filtered.length}/$total',
                  style: TextStyle(
                      color: cs.surface, fontWeight: FontWeight.w800, fontSize: 13),
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

// ── Payments Tab ─────────────────────────────────────────────────────────────

class _BatchPaymentsTab extends ConsumerStatefulWidget {
  final String batchId;
  final Map<String, dynamic> batch;

  const _BatchPaymentsTab({required this.batchId, required this.batch});

  @override
  ConsumerState<_BatchPaymentsTab> createState() => _BatchPaymentsTabState();
}

class _BatchPaymentsTabState extends ConsumerState<_BatchPaymentsTab> {
  // 0 = All, 1 = Received, 2 = Pending
  int _filter = 0;

  List<Map<String, dynamic>> _applyFilter(List<Map<String, dynamic>> all) {
    if (_filter == 1) {
      return all.where((p) {
        final s = (p['status'] as String? ?? '').toUpperCase();
        return s == 'PAID' || s == 'COMPLETED';
      }).toList();
    }
    if (_filter == 2) {
      return all.where((p) {
        final s = (p['status'] as String? ?? '').toUpperCase();
        return s == 'PENDING' || s == 'OVERDUE';
      }).toList();
    }
    return all;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(batchPaymentsProvider(widget.batchId));
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          // ── filter chips ────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Row(
              children: [
                _chip(context, 'All',      0),
                const SizedBox(width: 8),
                _chip(context, 'Received', 1),
                const SizedBox(width: 8),
                _chip(context, 'Pending',  2),
                const Spacer(),
                state.maybeWhen(
                  data: (p) {
                    final shown = _applyFilter(p);
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: cs.onSurface,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${shown.length}',
                        style: TextStyle(
                            color: cs.surface, fontWeight: FontWeight.w800, fontSize: 13),
                      ),
                    );
                  },
                  orElse: () => const SizedBox.shrink(),
                ),
              ],
            ),
          ),

          // ── list ────────────────────────────────────────────────────────
          Expanded(
            child: state.when(
              loading: loadingBody,
              error: (e, _) => errorBody(
                  e, () => ref.invalidate(batchPaymentsProvider(widget.batchId))),
              data: (payments) {
                final filtered = _applyFilter(payments);
                if (filtered.isEmpty) {
                  return emptyBody(_filter == 0 ? 'No payments recorded' : 'No payments here');
                }
                return RefreshIndicator(
                  onRefresh: () async =>
                      ref.invalidate(batchPaymentsProvider(widget.batchId)),
                  child: ListView.separated(
                    padding: const EdgeInsets.only(bottom: 100),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (_, i) => _PaymentTile(payment: filtered[i]),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.small(
        heroTag: null,
        onPressed: () => _openRecordSheet(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _chip(BuildContext context, String label, int index) {
    final selected = _filter == index;
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: () => setState(() => _filter = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? cs.onSurface : cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: selected ? cs.surface : cs.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ),
    );
  }

  void _openRecordSheet(BuildContext context) {
    // Build a list of enrollments from the batch so user picks from this batch
    final enrollments =
        (widget.batch['enrollments'] as List? ?? []).cast<Map<String, dynamic>>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => _BatchRecordPaymentSheet(
        batchId: widget.batchId,
        enrollments: enrollments,
        onRecorded: () => ref.invalidate(batchPaymentsProvider(widget.batchId)),
      ),
    );
  }
}

class _PaymentTile extends StatelessWidget {
  final Map<String, dynamic> payment;
  const _PaymentTile({required this.payment});

  @override
  Widget build(BuildContext context) {
    final enrollment = payment['enrollment'] as Map<String, dynamic>? ?? {};
    final user       = enrollment['user'] as Map<String, dynamic>? ?? {};
    final name       = user['name'] as String? ?? '—';
    final amount     = rupeesFromPaise(payment['amountPaise']);
    final status     = payment['status'] as String? ?? '';
    final mode       = payment['paymentMode'] as String? ?? '';

    String dateLabel = '';
    final paidAt = payment['paidAt'] as String? ?? payment['createdAt'] as String?;
    if (paidAt != null) {
      try {
        dateLabel = DateFormat('d MMM yyyy').format(DateTime.parse(paidAt).toLocal());
      } catch (_) {}
    }

    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    final color   = _avatarColor(name);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: CircleAvatar(
        radius: 18,
        backgroundColor: color.withValues(alpha: 0.12),
        child: Text(initial,
            style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 13)),
      ),
      title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
      subtitle: Text(
        [if (dateLabel.isNotEmpty) dateLabel, if (mode.isNotEmpty) mode].join(' · '),
        style: const TextStyle(fontSize: 12, color: Colors.grey),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(amount,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
          const SizedBox(height: 2),
          statusBadge(status),
        ],
      ),
    );
  }
}

// Lightweight record-payment sheet pre-scoped to this batch's students
class _BatchRecordPaymentSheet extends ConsumerStatefulWidget {
  final String batchId;
  final List<Map<String, dynamic>> enrollments;
  final VoidCallback onRecorded;

  const _BatchRecordPaymentSheet({
    required this.batchId,
    required this.enrollments,
    required this.onRecorded,
  });

  @override
  ConsumerState<_BatchRecordPaymentSheet> createState() => _BatchRecordPaymentSheetState();
}

class _BatchRecordPaymentSheetState extends ConsumerState<_BatchRecordPaymentSheet> {
  String? _enrollmentId;
  final _amountCtrl = TextEditingController();
  String _mode      = kPaymentModes.first;
  final _notesCtrl  = TextEditingController();
  DateTime _paidAt  = DateTime.now();
  bool _loading     = false;

  @override
  void dispose() {
    _amountCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_enrollmentId == null) { showSnack(context, 'Select a student'); return; }
    if (_amountCtrl.text.isEmpty) { showSnack(context, 'Enter amount'); return; }
    setState(() => _loading = true);
    try {
      await ref.read(batchPaymentsProvider(widget.batchId).notifier).recordPayment({
        'enrollmentId': _enrollmentId,
        'amountPaise':  (double.tryParse(_amountCtrl.text) ?? 0) * 100,
        'paymentMode':  _mode,
        if (_notesCtrl.text.isNotEmpty) 'notes': _notesCtrl.text.trim(),
        'paidAt': _paidAt.toIso8601String(),
      });
      widget.onRecorded();
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) showSnack(context, 'Failed to record payment');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20, right: 20, top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('Record Payment',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                const Spacer(),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
              ],
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _enrollmentId,
              decoration: const InputDecoration(labelText: 'Student *'),
              items: widget.enrollments.map((e) {
                final user = e['user'] as Map<String, dynamic>? ?? {};
                return DropdownMenuItem(
                  value: e['id'] as String?,
                  child: Text(user['name'] as String? ?? '—'),
                );
              }).toList(),
              onChanged: (v) => setState(() => _enrollmentId = v),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _amountCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Amount (₹) *', prefixText: '₹ '),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _mode,
              decoration: const InputDecoration(labelText: 'Payment Mode'),
              items: kPaymentModes
                  .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                  .toList(),
              onChanged: (v) => setState(() => _mode = v!),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _notesCtrl,
              decoration: const InputDecoration(labelText: 'Notes (optional)'),
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Payment Date'),
              subtitle: Text('${_paidAt.day}/${_paidAt.month}/${_paidAt.year}'),
              trailing: const Icon(Icons.calendar_today_outlined, size: 18),
              onTap: () async {
                final d = await showDatePicker(
                  context: context,
                  initialDate: _paidAt,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                );
                if (d != null) setState(() => _paidAt = d);
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loading ? null : _save,
              child: _loading
                  ? const SizedBox(
                      width: 20, height: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Record Payment'),
            ),
          ],
        ),
      ),
    );
  }
}
