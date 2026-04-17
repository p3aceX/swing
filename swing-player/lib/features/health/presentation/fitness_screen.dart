import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../controller/health_controller.dart';
import '../controller/fitness_controller.dart';
import 'widgets/fitness_dashboard_view.dart';
import 'widgets/fitness_log_modal.dart';

class FitnessScreen extends ConsumerWidget {
  const FitnessScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final healthState = ref.watch(healthDashboardProvider);
    final fitnessState = ref.watch(fitnessSummaryProvider);

    return Scaffold(
      backgroundColor: context.bg,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: context.bg,
            elevation: 0,
            pinned: true,
            centerTitle: false,
            automaticallyImplyLeading: false,
            title: Row(
              children: [
                Icon(Icons.fitness_center_rounded,
                    color: context.accent, size: 20),
                const SizedBox(width: 8),
                Text(
                  'FITNESS',
                  style: TextStyle(
                    color: context.fg,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: context.panel,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: context.stroke),
                  ),
                  child: Row(
                    children: [
                      Text(
                        'Today',
                        style: TextStyle(
                          color: context.fgSub,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.keyboard_arrow_down_rounded,
                          color: context.fgSub, size: 16),
                    ],
                  ),
                ),
              ],
            ),
          ),
          healthState.when(
            data: (dashboard) => fitnessState.when(
              data: (summary) => FitnessDashboardView(
                dashboard: dashboard,
                summary: summary,
              ),
              loading: () => const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (err, _) => SliverFillRemaining(
                child: _ErrorState(onRetry: () {
                  ref.invalidate(fitnessSummaryProvider);
                }),
              ),
            ),
            loading: () => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (err, _) => SliverFillRemaining(
              child: _ErrorState(onRetry: () {
                ref.invalidate(healthDashboardProvider);
              }),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => const FitnessLogModal(),
          );
        },
        backgroundColor: context.accent,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Log Exercise',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.fitness_center_outlined, size: 48, color: context.fgSub),
          const SizedBox(height: 16),
          Text('Could not load fitness data',
              style: TextStyle(color: context.fgSub)),
          TextButton(
            onPressed: onRetry,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
