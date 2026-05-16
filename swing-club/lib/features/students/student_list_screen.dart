import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../shared/widgets.dart';
import 'student_provider.dart';
import 'enroll_student_sheet.dart';

// ── Palette (same pastels as home/finance) ────────────────────────────────────

class _C {
  static const green = Color(0xFF16A34A);
  static const blue  = Color(0xFF2563EB);
}

// ── Confirm dialog ────────────────────────────────────────────────────────────

Future<bool> _confirmRemove(BuildContext context, String name) async =>
    await showDialog<bool>(
      context: context,
      useRootNavigator: true,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove Student'),
        content: Text('Remove $name from your academy?\nThey will be marked inactive.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Remove', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    ) ?? false;

// ── Screen ────────────────────────────────────────────────────────────────────

class StudentListScreen extends ConsumerStatefulWidget {
  const StudentListScreen({super.key});

  @override
  ConsumerState<StudentListScreen> createState() => _StudentListScreenState();
}

class _StudentListScreenState extends ConsumerState<StudentListScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs = TabController(length: 4, vsync: this);
  final _searchCtrl = TextEditingController();
  String _search = '';

  @override
  void initState() {
    super.initState();
    _tabs.addListener(() { if (mounted) setState(() {}); });
  }

  @override
  void dispose() {
    _tabs.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _openAddSheet() {
    final bg = Theme.of(context).scaffoldBackgroundColor;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      useSafeArea: true,
      backgroundColor: bg,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => const EnrollStudentSheet(),
    ).then((v) { if (v == true) ref.invalidate(studentsProvider); });
  }

  List<Map<String, dynamic>> _filterByTab(List<Map<String, dynamic>> all) {
    var result = all;
    if (_search.isNotEmpty) {
      final q = _search.toLowerCase();
      result = result.where((s) {
        return _studentName(s).toLowerCase().contains(q) ||
               _studentPhone(s).toLowerCase().contains(q);
      }).toList();
    }
    switch (_tabs.index) {
      case 1: return result.where((s) => s['enrollmentStatus'] == 'ACTIVE').toList();
      case 2: return result.where((s) => s['isTrial'] == true).toList();
      case 3: return result.where((s) => s['feeStatus'] == 'OVERDUE').toList();
      default: return result;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs        = Theme.of(context).colorScheme;
    final state     = ref.watch(studentsProvider);
    final divColor  = cs.onSurface.withValues(alpha: 0.08);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: Row(children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Students',
                          style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900,
                              color: cs.onSurface, letterSpacing: -0.5)),
                      const SizedBox(height: 2),
                      state.maybeWhen(
                        data: (all) => Text('${all.length} total',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500,
                                color: cs.onSurface.withValues(alpha: 0.45))),
                        orElse: () => const SizedBox.shrink(),
                      ),
                    ],
                  ),
                ),
                _OutlineBtn(
                  icon: Icons.person_add_alt_1_rounded,
                  label: 'Add',
                  onTap: _openAddSheet,
                ),
              ]),
            ),

            // ── Search ────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: cs.onSurface.withValues(alpha: 0.10), width: 1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: (v) => setState(() => _search = v),
                  style: TextStyle(fontSize: 14, color: cs.onSurface),
                  decoration: InputDecoration(
                    hintText: 'Search students…',
                    hintStyle: TextStyle(fontSize: 14,
                        color: cs.onSurface.withValues(alpha: 0.35),
                        fontWeight: FontWeight.w400),
                    prefixIcon: Icon(Icons.search_rounded, size: 20,
                        color: cs.onSurface.withValues(alpha: 0.35)),
                    suffixIcon: _search.isNotEmpty
                        ? GestureDetector(
                            onTap: () => setState(() { _searchCtrl.clear(); _search = ''; }),
                            child: Icon(Icons.close_rounded, size: 18,
                                color: cs.onSurface.withValues(alpha: 0.35)),
                          )
                        : null,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    filled: false,
                  ),
                ),
              ),
            ),

            // ── Divider ───────────────────────────────────────────────────
            Divider(height: 1, thickness: 0.5, color: divColor),

            // ── Tab bar ───────────────────────────────────────────────────
            TabBar(
              controller: _tabs,
              tabs: const [
                Tab(text: 'All'),
                Tab(text: 'Active'),
                Tab(text: 'Trial'),
                Tab(text: 'Overdue'),
              ],
            ),

            // ── Tab content ───────────────────────────────────────────────
            Expanded(
              child: state.when(
                loading: loadingBody,
                error: (e, _) => errorBody(e, () => ref.invalidate(studentsProvider)),
                data: (all) => TabBarView(
                  controller: _tabs,
                  children: List.generate(4, (i) {
                    final filtered = _filterByTabIndex(all, i);
                    if (filtered.isEmpty) {
                      return all.isEmpty
                          ? _EmptyStudents(onAdd: _openAddSheet)
                          : emptyBody(_search.isNotEmpty
                              ? 'No match for "$_search"'
                              : 'No students in this category');
                    }
                    return RefreshIndicator(
                      onRefresh: () async => ref.invalidate(studentsProvider),
                      color: _C.blue,
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 10, 16, 100),
                        itemCount: filtered.length,
                        itemBuilder: (_, i) => _StudentCard(student: filtered[i]),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _filterByTabIndex(
      List<Map<String, dynamic>> all, int index) {
    var result = all;
    if (_search.isNotEmpty) {
      final q = _search.toLowerCase();
      result = result.where((s) {
        return _studentName(s).toLowerCase().contains(q) ||
               _studentPhone(s).toLowerCase().contains(q);
      }).toList();
    }
    switch (index) {
      case 1: return result.where((s) => s['enrollmentStatus'] == 'ACTIVE').toList();
      case 2: return result.where((s) => s['isTrial'] == true).toList();
      case 3: return result.where((s) => s['feeStatus'] == 'OVERDUE').toList();
      default: return result;
    }
  }
}

// ── Student Card ──────────────────────────────────────────────────────────────

class _StudentCard extends ConsumerWidget {
  final Map<String, dynamic> student;
  const _StudentCard({required this.student});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs        = Theme.of(context).colorScheme;
    final name      = _studentName(student);
    final phone     = _studentPhone(student);
    final batch     = (student['batch'] as Map?)?.cast<String, dynamic>() ?? {};
    final batchName = batch['name'] as String? ?? '';
    final feeStatus = student['feeStatus'] as String? ?? '';
    final isTrial   = student['isTrial'] == true;
    final id        = student['id'] as String;
    final initial   = name.isNotEmpty ? name[0].toUpperCase() : '?';
    final color     = _avatarColor(name);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(16),
        ),
        child: InkWell(
          onTap: () => context.push('/students/$id'),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 10, 14),
            child: Row(children: [
              // Avatar
              Container(
                width: 52, height: 52,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(initial,
                      style: TextStyle(color: color,
                          fontWeight: FontWeight.w900, fontSize: 20)),
                ),
              ),
              const SizedBox(width: 13),

              // Info
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name + fee badge
                  Row(children: [
                    Expanded(
                      child: Text(name,
                          maxLines: 1, overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontWeight: FontWeight.w700,
                              fontSize: 15, color: cs.onSurface)),
                    ),
                    if (feeStatus.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      _FeeBadge(feeStatus),
                    ],
                  ]),
                  const SizedBox(height: 7),
                  // Batch + trial + actions
                  Row(children: [
                    if (batchName.isNotEmpty) ...[
                      Icon(Icons.sports_cricket_rounded, size: 12,
                          color: cs.onSurface.withValues(alpha: 0.35)),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(batchName,
                            maxLines: 1, overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 12,
                                color: cs.onSurface.withValues(alpha: 0.45),
                                fontWeight: FontWeight.w500)),
                      ),
                    ],
                    if (isTrial) ...[
                      const SizedBox(width: 6),
                      _Pill(label: 'Trial', color: const Color(0xFFE65100)),
                    ],
                    const Spacer(),
                    if (phone.isNotEmpty) ...[
                      GestureDetector(
                        onTap: () => launchUrl(Uri.parse('tel:$phone'),
                            mode: LaunchMode.externalApplication),
                        child: Container(
                          width: 30, height: 30,
                          decoration: BoxDecoration(
                            color: _C.green.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(Icons.phone_rounded, size: 15,
                              color: _C.green),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    GestureDetector(
                      onTap: () async {
                        final confirmed = await _confirmRemove(context, name);
                        if (confirmed && context.mounted) {
                          try {
                            await ref.read(studentsProvider.notifier).remove(id);
                            if (context.mounted) showSnack(context, '$name removed');
                          } catch (e) {
                            if (context.mounted) showSnack(context, 'Error: $e');
                          }
                        }
                      },
                      child: Container(
                        width: 30, height: 30,
                        decoration: BoxDecoration(
                          color: cs.onSurface.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.person_off_rounded, size: 15,
                            color: cs.onSurface.withValues(alpha: 0.35)),
                      ),
                    ),
                  ]),
                ],
              )),
            ]),
          ),
        ),
      ),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

class _Pill extends StatelessWidget {
  final String label;
  final Color color;
  const _Pill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
            color: color.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(6)),
        child: Text(label,
            style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w700)),
      );
}

class _FeeBadge extends StatelessWidget {
  final String status;
  const _FeeBadge(this.status);

  @override
  Widget build(BuildContext context) {
    final Color color;
    final String label;
    switch (status.toUpperCase()) {
      case 'PAID':    color = const Color(0xFF16A34A); label = 'Paid';
      case 'OVERDUE': color = const Color(0xFFDC2626); label = 'Overdue';
      case 'PENDING': color = const Color(0xFFF59E0B); label = 'Pending';
      default:
        color = const Color(0xFF9E9E9E);
        label = status.isNotEmpty
            ? status[0].toUpperCase() + status.substring(1).toLowerCase()
            : '';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        border: Border.all(color: color.withValues(alpha: 0.30), width: 1),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(label,
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: color)),
    );
  }
}


class _OutlineBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _OutlineBtn({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          border: Border.all(color: cs.onSurface.withValues(alpha: 0.12), width: 1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 16, color: cs.onSurface),
          const SizedBox(width: 5),
          Text(label,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
                  color: cs.onSurface)),
        ]),
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyStudents extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyStudents({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
      child: Column(mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              border: Border.all(color: cs.onSurface.withValues(alpha: 0.12), width: 1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(Icons.people_outline_rounded, size: 24,
                color: cs.onSurface.withValues(alpha: 0.5)),
          ),
          const SizedBox(height: 20),
          Text('No students yet',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900,
                  color: cs.onSurface, letterSpacing: -0.5)),
          const SizedBox(height: 8),
          Text('Enrol your first student to start tracking progress and fees.',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500,
                  color: cs.onSurface.withValues(alpha: 0.5), height: 1.5)),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onAdd,
              style: FilledButton.styleFrom(
                backgroundColor: cs.onSurface,
                foregroundColor: cs.surface,
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('Enrol Student',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
            ),
          ),
        ]),
    );
  }
}

// ── Name / phone / color helpers ──────────────────────────────────────────────

String _studentName(Map<String, dynamic> student) {
  final profile = student['playerProfile'] as Map<String, dynamic>?;
  if (profile != null) {
    final u = profile['user'] as Map<String, dynamic>?;
    final name = u?['name'] as String?;
    if (name != null && name.isNotEmpty) return name;
    final username = profile['username'] as String?;
    if (username != null && username.isNotEmpty) return username;
  }
  final u = student['user'] as Map<String, dynamic>?;
  return (u?['name'] ?? u?['username']) as String? ?? '—';
}

String _studentPhone(Map<String, dynamic> student) {
  final profile = student['playerProfile'] as Map<String, dynamic>?;
  final u = profile?['user'] as Map<String, dynamic>?;
  if (u?['phone'] != null) return u!['phone'] as String;
  return (student['user'] as Map<String, dynamic>?)?['phone'] as String? ?? '';
}

Color _avatarColor(String name) {
  const colors = [
    Color(0xFF2563EB), Color(0xFF7C3AED), Color(0xFF059669),
    Color(0xFFEA580C), Color(0xFF0891B2), Color(0xFFDC2626),
    Color(0xFF1565C0), Color(0xFF558B2F),
  ];
  return colors[name.codeUnits.fold(0, (a, b) => a + b) % colors.length];
}
