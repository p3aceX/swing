import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../shared/widgets.dart';
import 'student_provider.dart';
import 'enroll_student_sheet.dart';

const _kNavy = Color(0xFF071B3D);

const _filters = ['All', 'Active', 'Trial', 'Overdue Fees'];

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
        final user  = (s['user'] as Map<String, dynamic>?)
                   ?? (s['playerProfile'] as Map<String, dynamic>?)
                   ?? {};
        final name  = ((user['name'] ?? user['username']) as String? ?? '').toLowerCase();
        final phone = (user['phone'] as String? ?? '').toLowerCase();
        return name.contains(q) || phone.contains(q);
      }).toList();
    }
    switch (_filter) {
      case 'Active':
        result = result.where((s) => s['enrollmentStatus'] == 'ACTIVE').toList();
        break;
      case 'Trial':
        result = result.where((s) => s['isTrial'] == true).toList();
        break;
      case 'Overdue Fees':
        result = result.where((s) => s['feeStatus'] == 'OVERDUE').toList();
        break;
    }
    return result;
  }

  void _openEnroll(List<Map<String, dynamic>> allStudents) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => const EnrollStudentSheet(),
    ).then((enrolled) {
      if (enrolled == true) ref.invalidate(studentsProvider);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(studentsProvider);

    return Scaffold(
      body: Column(
        children: [
          // ── search + count ─────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(children: [
              Expanded(
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: (v) => setState(() => _search = v),
                  style: const TextStyle(fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Search by name or phone…',
                    hintStyle: const TextStyle(fontSize: 14, color: Colors.grey),
                    prefixIcon: const Icon(Icons.search_rounded, size: 20, color: Colors.grey),
                    suffixIcon: _search.isNotEmpty
                        ? GestureDetector(
                            onTap: () => setState(() {
                              _searchCtrl.clear();
                              _search = '';
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
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: _kNavy,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _search.isEmpty && _filter == 'All'
                          ? '${all.length}'
                          : '${filtered.length}/${all.length}',
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 13),
                    ),
                  );
                },
                orElse: () => const SizedBox.shrink(),
              ),
            ]),
          ),

          // ── filter chips ───────────────────────────────────────────────
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Row(
              children: _filters.map((f) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => setState(() => _filter = f),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: _filter == f ? _kNavy : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: _filter == f ? _kNavy : const Color(0xFFE0DED6)),
                    ),
                    child: Text(f,
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: _filter == f ? Colors.white : Colors.grey)),
                  ),
                ),
              )).toList(),
            ),
          ),

          // ── list ──────────────────────────────────────────────────────
          Expanded(
            child: state.when(
              loading: loadingBody,
              error: (e, _) => errorBody(e, () => ref.invalidate(studentsProvider)),
              data: (all) {
                final students = _apply(all);
                if (students.isEmpty) {
                  return emptyBody(
                      _search.isEmpty && _filter == 'All'
                          ? 'No students yet'
                          : 'No results');
                }
                return RefreshIndicator(
                  onRefresh: () async => ref.invalidate(studentsProvider),
                  child: ListView.separated(
                    padding: const EdgeInsets.only(bottom: 100),
                    itemCount: students.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (_, i) => _StudentTile(student: students[i]),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: state.maybeWhen(
        data: (all) => FloatingActionButton.extended(
          heroTag: null,
          onPressed: () => _openEnroll(all),
          icon: const Icon(Icons.person_add_outlined),
          label: const Text('Add Student',
              style: TextStyle(fontWeight: FontWeight.w700)),
        ),
        orElse: () => const SizedBox.shrink(),
      ),
    );
  }
}

class _StudentTile extends StatelessWidget {
  final Map<String, dynamic> student;

  const _StudentTile({required this.student});

  @override
  Widget build(BuildContext context) {
    final user    = (student['user']          as Map<String, dynamic>?)
                 ?? (student['playerProfile'] as Map<String, dynamic>?)
                 ?? {};
    final batch   = student['batch'] as Map<String, dynamic>? ?? {};
    final name    = (user['name']  ?? user['username']) as String? ?? '—';
    final phone   = user['phone']  as String? ?? '';
    final batchName   = batch['name'] as String? ?? '';
    final enrollStatus = student['enrollmentStatus'] as String? ?? '';
    final feeStatus    = student['feeStatus']        as String? ?? '';
    final isTrial      = student['isTrial'] == true;

    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    final color   = _avatarColor(name);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: CircleAvatar(
        radius: 22,
        backgroundColor: color.withOpacity(0.15),
        child: Text(initial,
            style: TextStyle(
                color: color, fontWeight: FontWeight.w800, fontSize: 16)),
      ),
      title: Row(children: [
        Expanded(
          child: Text(name,
              style: const TextStyle(
                  fontWeight: FontWeight.w700, fontSize: 15)),
        ),
        if (isTrial)
          Container(
            margin: const EdgeInsets.only(left: 6),
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3E0),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text('Trial',
                style: TextStyle(
                    fontSize: 10,
                    color: Color(0xFFE65100),
                    fontWeight: FontWeight.w700)),
          ),
      ]),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (batchName.isNotEmpty)
            Text(batchName,
                style: const TextStyle(fontSize: 12, color: Colors.grey)),
          if (phone.isNotEmpty)
            Text(phone,
                style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
      isThreeLine: batchName.isNotEmpty && phone.isNotEmpty,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (enrollStatus.isNotEmpty) statusBadge(enrollStatus),
              if (feeStatus.isNotEmpty) ...[
                const SizedBox(height: 4),
                statusBadge(feeStatus),
              ],
            ],
          ),
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
      onTap: () => context.push('/students/${student['id']}'),
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
