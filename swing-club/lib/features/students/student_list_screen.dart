import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../shared/widgets.dart';
import 'student_provider.dart';
import 'enroll_student_sheet.dart';

const _kNavy = Color(0xFF071B3D);
const _filters = ['All', 'Active', 'Trial', 'Overdue Fees'];

Future<bool> _confirmRemove(BuildContext context, String name) async {
  return await showDialog<bool>(
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
}

class StudentListScreen extends ConsumerStatefulWidget {
  const StudentListScreen({super.key});

  @override
  ConsumerState<StudentListScreen> createState() => _StudentListScreenState();
}

class _StudentListScreenState extends ConsumerState<StudentListScreen> {
  final _searchCtrl = TextEditingController();
  String _search = '';
  String _filter = 'All';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _apply(List<Map<String, dynamic>> students) {
    var result = students;
    if (_search.isNotEmpty) {
      final q = _search.toLowerCase();
      result = result.where((s) {
        final name  = _studentName(s).toLowerCase();
        final phone = _studentPhone(s).toLowerCase();
        return name.contains(q) || phone.contains(q);
      }).toList();
    }
    switch (_filter) {
      case 'Active':
        result = result.where((s) => s['enrollmentStatus'] == 'ACTIVE').toList();
      case 'Trial':
        result = result.where((s) => s['isTrial'] == true).toList();
      case 'Overdue Fees':
        result = result.where((s) => s['feeStatus'] == 'OVERDUE').toList();
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(studentsProvider);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Search ────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
              child: Row(children: [
                Expanded(
                  child: TextField(
                    controller: _searchCtrl,
                    onChanged: (v) => setState(() => _search = v),
                    style: const TextStyle(fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Search students…',
                      hintStyle: const TextStyle(fontSize: 14, color: Colors.grey),
                      prefixIcon: const Icon(Icons.search_rounded, size: 20, color: Colors.grey),
                      suffixIcon: _search.isNotEmpty
                          ? GestureDetector(
                              onTap: () => setState(() { _searchCtrl.clear(); _search = ''; }),
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
                          borderSide: const BorderSide(color: _kNavy)),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                state.maybeWhen(
                  data: (all) {
                    final filtered = _apply(all);
                    final count = _search.isEmpty && _filter == 'All'
                        ? '${all.length}'
                        : '${filtered.length}/${all.length}';
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                          color: _kNavy, borderRadius: BorderRadius.circular(10)),
                      child: Text(count,
                          style: const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13)),
                    );
                  },
                  orElse: () => const SizedBox.shrink(),
                ),
              ]),
            ),

            // ── Filter chips ───────────────────────────────────────────────
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Row(
                children: _filters.map((f) {
                  final active = _filter == f;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => setState(() => _filter = f),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          color: active ? _kNavy : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: active ? _kNavy : const Color(0xFFE0DED6)),
                        ),
                        child: Text(f,
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: active ? Colors.white : Colors.grey)),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            // ── List ───────────────────────────────────────────────────────
            Expanded(
              child: state.when(
                loading: loadingBody,
                error: (e, _) => errorBody(e, () => ref.invalidate(studentsProvider)),
                data: (all) {
                  final students = _apply(all);
                  if (students.isEmpty) {
                    return emptyBody(_search.isEmpty && _filter == 'All'
                        ? 'No students yet'
                        : 'No results');
                  }
                  return RefreshIndicator(
                    onRefresh: () async => ref.invalidate(studentsProvider),
                    child: ListView.builder(
                      padding: const EdgeInsets.only(bottom: 100),
                      itemCount: students.length,
                      itemBuilder: (_, i) => _StudentCard(student: students[i]),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: state.maybeWhen(
        data: (_) => FloatingActionButton.extended(
          heroTag: null,
          onPressed: () => showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
            builder: (_) => const EnrollStudentSheet(),
          ).then((v) { if (v == true) ref.invalidate(studentsProvider); }),
          icon: const Icon(Icons.person_add_outlined),
          label: const Text('Add Student', style: TextStyle(fontWeight: FontWeight.w700)),
        ),
        orElse: () => const SizedBox.shrink(),
      ),
    );
  }
}

// ── Student card ───────────────────────────────────────────────────────────────

class _StudentCard extends ConsumerWidget {
  final Map<String, dynamic> student;
  const _StudentCard({required this.student});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final name        = _studentName(student);
    final phone       = _studentPhone(student);
    final batch       = (student['batch'] as Map?)?.cast<String, dynamic>() ?? {};
    final batchName   = batch['name'] as String? ?? '';
    final enrollStatus = student['enrollmentStatus'] as String? ?? '';
    final feeStatus   = student['feeStatus'] as String? ?? '';
    final isTrial     = student['isTrial'] == true;
    final id          = student['id'] as String;

    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    final color   = _avatarColor(name);
    final displayStatus = isTrial ? 'TRIAL' : enrollStatus;

    return Row(
      children: [
        // Tappable area — navigates to detail
        Expanded(
          child: InkWell(
            onTap: () => context.push('/students/$id'),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
              child: Row(
                children: [
                  // Avatar
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: color.withValues(alpha: 0.15),
                    child: Text(initial,
                        style: TextStyle(
                            color: color, fontWeight: FontWeight.w800, fontSize: 16)),
                  ),
                  const SizedBox(width: 12),

                  // Name + batch
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Expanded(
                            child: Text(name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700, fontSize: 14, color: _kNavy)),
                          ),
                          if (isTrial) ...[
                            const SizedBox(width: 6),
                            _Tag('Trial', const Color(0xFFE65100), const Color(0xFFFFF3E0)),
                          ],
                        ]),
                        if (batchName.isNotEmpty) ...[
                          const SizedBox(height: 3),
                          Text(batchName,
                              style: const TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Status badges — centered
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (displayStatus.isNotEmpty) statusBadge(displayStatus),
                      if (feeStatus.isNotEmpty && feeStatus != displayStatus) ...[
                        const SizedBox(width: 4),
                        statusBadge(feeStatus),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),

        // Action buttons — outside InkWell so taps aren't intercepted
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (phone.isNotEmpty) ...[
                _IconAction(
                  icon: Icons.call_rounded,
                  color: const Color(0xFF2E7D32),
                  onTap: () => launchUrl(
                      Uri.parse('tel:$phone'),
                      mode: LaunchMode.externalApplication),
                ),
                const SizedBox(width: 6),
              ],
              _IconAction(
                icon: Icons.person_remove_outlined,
                color: Colors.red.shade400,
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
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;
  final Color fg;
  final Color bg;
  const _Tag(this.label, this.fg, this.bg);

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(5)),
    child: Text(label,
        style: TextStyle(fontSize: 10, color: fg, fontWeight: FontWeight.w700)),
  );
}

class _IconAction extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _IconAction({required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) => Material(
    color: color.withValues(alpha: 0.1),
    borderRadius: BorderRadius.circular(8),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Icon(icon, size: 18, color: color),
      ),
    ),
  );
}

// ── Helpers ────────────────────────────────────────────────────────────────────

String _studentName(Map<String, dynamic> student) {
  final profile = student['playerProfile'] as Map<String, dynamic>?;
  if (profile != null) {
    final u = profile['user'] as Map<String, dynamic>?;
    final name = u?['name'] as String?;
    if (name != null && name.isNotEmpty) return name;
    // fallback: playerProfile.username
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
    Color(0xFF1565C0), Color(0xFF6A1B9A), Color(0xFF00695C),
    Color(0xFFE65100), Color(0xFF4527A0), Color(0xFF283593),
    Color(0xFF558B2F), Color(0xFFC62828),
  ];
  return colors[name.codeUnits.fold(0, (a, b) => a + b) % colors.length];
}
