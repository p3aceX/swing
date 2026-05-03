import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../shared/widgets.dart';
import 'session_provider.dart';

class SessionDetailScreen extends ConsumerStatefulWidget {
  final String sessionId;

  const SessionDetailScreen({super.key, required this.sessionId});

  @override
  ConsumerState<SessionDetailScreen> createState() => _SessionDetailScreenState();
}

class _SessionDetailScreenState extends ConsumerState<SessionDetailScreen> {
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    _startPollingIfLive();
  }

  void _startPollingIfLive() {
    _pollTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      final state = ref.read(sessionDetailProvider(widget.sessionId));
      if (state.valueOrNull?['status'] == 'LIVE') {
        ref.invalidate(sessionDetailProvider(widget.sessionId));
      } else {
        _pollTimer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(sessionDetailProvider(widget.sessionId));

    return Scaffold(
      appBar: AppBar(
        title: state.maybeWhen(
          data: (s) {
            final batch = s['batch'] as Map<String, dynamic>? ?? {};
            return Text(batch['name'] as String? ?? 'Session');
          },
          orElse: () => const Text('Session'),
        ),
      ),
      body: state.when(
        loading: loadingBody,
        error: (e, _) =>
            errorBody(e, () => ref.invalidate(sessionDetailProvider(widget.sessionId))),
        data: (session) => _SessionBody(session: session),
      ),
    );
  }
}

class _SessionBody extends StatelessWidget {
  final Map<String, dynamic> session;

  const _SessionBody({required this.session});

  @override
  Widget build(BuildContext context) {
    final batch = session['batch'] as Map<String, dynamic>? ?? {};
    final coach = session['coach'] as Map<String, dynamic>? ?? {};
    final status = session['status'] as String? ?? '';
    final attendance = (session['attendance'] as List? ?? []).cast<Map<String, dynamic>>();

    String dtLabel = '';
    final dt = session['scheduledAt'] as String? ?? session['startTime'] as String? ?? '';
    if (dt.isNotEmpty) {
      try {
        dtLabel = DateFormat('EEE, d MMM yyyy · HH:mm').format(DateTime.parse(dt).toLocal());
      } catch (_) {
        dtLabel = dt;
      }
    }

    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  statusBadge(status),
                  if (status == 'LIVE') ...[
                    const SizedBox(width: 8),
                    const _LiveIndicator(),
                  ],
                ],
              ),
              const SizedBox(height: 12),
              if (dtLabel.isNotEmpty)
                Text(dtLabel, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.person_outline, size: 16, color: Colors.grey),
                  const SizedBox(width: 6),
                  Text(coach['name'] as String? ?? 'Unassigned',
                      style: const TextStyle(color: Colors.grey, fontSize: 14)),
                  const SizedBox(width: 16),
                  const Icon(Icons.groups_outlined, size: 16, color: Colors.grey),
                  const SizedBox(width: 6),
                  Text(batch['name'] as String? ?? '—',
                      style: const TextStyle(color: Colors.grey, fontSize: 14)),
                ],
              ),
              if (session['location'] != null) ...[
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, size: 16, color: Colors.grey),
                    const SizedBox(width: 6),
                    Text(session['location'] as String,
                        style: const TextStyle(color: Colors.grey, fontSize: 14)),
                  ],
                ),
              ],
            ],
          ),
        ),
        const Divider(),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
          child: Text(
            'Attendance${attendance.isNotEmpty ? ' (${attendance.length})' : ''}',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                color: Colors.grey, letterSpacing: 0.5),
          ),
        ),
        if (attendance.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Text('No attendance data', style: TextStyle(color: Colors.grey)),
          )
        else
          ...attendance.map((a) => _AttendanceTile(record: a)),
      ],
    );
  }
}

class _AttendanceTile extends StatelessWidget {
  final Map<String, dynamic> record;

  const _AttendanceTile({required this.record});

  @override
  Widget build(BuildContext context) {
    final user = record['user'] as Map<String, dynamic>? ?? {};
    final attStatus = record['status'] as String? ?? '';

    return Column(
      children: [
        ListTile(
          dense: true,
          title: Text(user['name'] as String? ?? '—'),
          trailing: statusBadge(attStatus),
        ),
        const Divider(),
      ],
    );
  }
}

class _LiveIndicator extends StatefulWidget {
  const _LiveIndicator();

  @override
  State<_LiveIndicator> createState() => _LiveIndicatorState();
}

class _LiveIndicatorState extends State<_LiveIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 800),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
        opacity: _ctrl,
        child: Container(
          width: 8,
          height: 8,
          decoration: const BoxDecoration(
            color: Color(0xFF1565C0),
            shape: BoxShape.circle,
          ),
        ),
      );
}
