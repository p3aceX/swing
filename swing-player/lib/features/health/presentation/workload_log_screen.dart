import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../controller/health_controller.dart';
import '../domain/health_models.dart';

class WorkloadLogScreen extends ConsumerStatefulWidget {
  const WorkloadLogScreen({super.key});

  @override
  ConsumerState<WorkloadLogScreen> createState() => _WorkloadLogScreenState();
}

class _WorkloadLogScreenState extends ConsumerState<WorkloadLogScreen> {
  String _activityType = 'Match';
  final _durationController = TextEditingController();
  final _ballsBowledController = TextEditingController();
  final _ballsFacedController = TextEditingController();
  final _notesController = TextEditingController();
  int _rpe = 5;
  bool _isSubmitting = false;

  final _activityTypes = [
    'Match',
    'Net Session',
    'Gym / Strength',
    'Cardio / Running',
    'Fielding Drill',
    'Recovery Session',
    'Other',
  ];

  Future<void> _submit() async {
    final duration = int.tryParse(_durationController.text);
    if (duration == null || duration <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid duration')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final type = switch (_activityType) {
        'Match' => WorkloadType.MATCH,
        'Net Session' => WorkloadType.BOWLING_NETS,
        'Gym / Strength' => WorkloadType.STRENGTH,
        'Cardio / Running' => WorkloadType.RUNNING,
        'Fielding Drill' => WorkloadType.FIELDING,
        _ => WorkloadType.CONDITIONING,
      };

      final event = WorkloadEvent(
        type: type,
        durationMinutes: duration,
        intensity: _rpe,
        ballsBowled: int.tryParse(_ballsBowledController.text),
        ballsFaced: int.tryParse(_ballsFacedController.text),
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        occurredAt: DateTime.now(),
      );
      await ref.read(healthDashboardProvider.notifier).submitWorkload(event);
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to log workload: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bg,
      appBar: AppBar(
        title: const Text('Log Workload'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Activity Type', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: context.cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: context.stroke),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _activityType,
                  isExpanded: true,
                  dropdownColor: context.cardBg,
                  borderRadius: BorderRadius.circular(16),
                  items: _activityTypes
                      .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                      .toList(),
                  onChanged: (v) => setState(() => _activityType = v!),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text('Duration (minutes)', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            TextField(
              controller: _durationController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: 'e.g. 90',
              ),
            ),
            const SizedBox(height: 24),
            Text('Intensity (RPE 1-10)', style: Theme.of(context).textTheme.titleMedium),
            Text(
              'Rate of Perceived Exertion - how hard was the session?',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            _RpeSlider(
              value: _rpe,
              onChanged: (v) => setState(() => _rpe = v),
            ),
            const SizedBox(height: 24),
            if (_activityType == 'Match' || _activityType == 'Net Session') ...[
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Balls Bowled', style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _ballsBowledController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(hintText: '0'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Balls Faced', style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _ballsFacedController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(hintText: '0'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
            Text('Notes (Optional)', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            TextField(
              controller: _notesController,
              maxLines: 2,
              decoration: const InputDecoration(
                hintText: 'Add any notes about the session...',
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isSubmitting ? null : _submit,
              child: _isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Save Workload'),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _RpeSlider extends StatelessWidget {
  const _RpeSlider({required this.value, required this.onChanged});
  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(10, (index) {
            final val = index + 1;
            final isSelected = value == val;
            final color = Color.lerp(context.accent, context.danger, index / 9)!;

            return GestureDetector(
              onTap: () => onChanged(val),
              child: Container(
                width: 32,
                height: 40,
                decoration: BoxDecoration(
                  color: isSelected ? color : context.panel,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected ? color : context.stroke,
                  ),
                ),
                child: Center(
                  child: Text(
                    '$val',
                    style: TextStyle(
                      color: isSelected ? Colors.white : context.fgSub,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Very Easy', style: TextStyle(color: context.fgSub, fontSize: 11)),
            Text('Max Effort', style: TextStyle(color: context.fgSub, fontSize: 11)),
          ],
        ),
      ],
    );
  }
}
