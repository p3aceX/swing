import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../shared/widgets.dart';
import 'student_provider.dart';
import 'enroll_student_sheet.dart';

class StudentListScreen extends ConsumerStatefulWidget {
  const StudentListScreen({super.key});

  @override
  ConsumerState<StudentListScreen> createState() => _StudentListScreenState();
}

class _StudentListScreenState extends ConsumerState<StudentListScreen> {
  String _search = '';
  String _filter = 'All';

  static const _filters = ['All', 'Active', 'Trial', 'Overdue Fees'];

  List<Map<String, dynamic>> _apply(List<Map<String, dynamic>> students) {
    var result = students;
    if (_search.isNotEmpty) {
      final q = _search.toLowerCase();
      result = result.where((s) {
        final user = s['user'] as Map<String, dynamic>? ?? {};
        return (user['name'] as String? ?? '').toLowerCase().contains(q);
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

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(studentsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Students'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'Search students...',
                    prefixIcon: Icon(Icons.search, size: 20),
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 10),
                  ),
                  onChanged: (v) => setState(() => _search = v),
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Row(
                  children: _filters
                      .map((f) => Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              label: Text(f),
                              selected: _filter == f,
                              onSelected: (_) => setState(() => _filter = f),
                            ),
                          ))
                      .toList(),
                ),
              ),
            ],
          ),
        ),
      ),
      body: state.when(
        loading: loadingBody,
        error: (e, _) => errorBody(e, () => ref.invalidate(studentsProvider)),
        data: (all) {
          final students = _apply(all);
          if (students.isEmpty) return emptyBody('No students found');
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(studentsProvider),
            child: ListView.separated(
              itemCount: students.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (_, i) => _StudentTile(student: students[i]),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
          builder: (_) => const EnrollStudentSheet(),
        ),
        child: const Icon(Icons.person_add_outlined),
      ),
    );
  }
}

class _StudentTile extends StatelessWidget {
  final Map<String, dynamic> student;

  const _StudentTile({required this.student});

  @override
  Widget build(BuildContext context) {
    final user = student['user'] as Map<String, dynamic>? ?? {};
    final batch = student['batch'] as Map<String, dynamic>? ?? {};
    final feeStatus = student['feeStatus'] as String? ?? '';
    final enrollStatus = student['enrollmentStatus'] as String? ?? '';

    return ListTile(
      title: Text(user['name'] as String? ?? '—',
          style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(batch['name'] as String? ?? '—'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (feeStatus.isNotEmpty) statusBadge(feeStatus),
          const SizedBox(width: 6),
          if (enrollStatus.isNotEmpty) statusBadge(enrollStatus),
        ],
      ),
      onTap: () => context.push('/students/${student['id']}'),
    );
  }
}
