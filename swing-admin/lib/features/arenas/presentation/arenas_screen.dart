import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../data/arenas_repository.dart';
import '../domain/arena.dart';

final arenaSearchProvider = StateProvider<String>((_) => '');
final arenaVerifiedOnlyProvider = StateProvider<bool>((_) => false);

final filteredArenasProvider = Provider<AsyncValue<List<Arena>>>((ref) {
  final async = ref.watch(arenasListProvider);
  final q = ref.watch(arenaSearchProvider).trim().toLowerCase();
  final verifiedOnly = ref.watch(arenaVerifiedOnlyProvider);
  return async.whenData((arenas) {
    return arenas.where((a) {
      if (verifiedOnly && !a.verified) return false;
      if (q.isEmpty) return true;
      return a.name.toLowerCase().contains(q) ||
          a.city.toLowerCase().contains(q) ||
          a.state.toLowerCase().contains(q) ||
          a.address.toLowerCase().contains(q) ||
          (a.ownerName ?? '').toLowerCase().contains(q);
    }).toList();
  });
});

class ArenasScreen extends ConsumerWidget {
  const ArenasScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(filteredArenasProvider);
    final totalAsync = ref.watch(arenasListProvider);
    final verifiedOnly = ref.watch(arenaVerifiedOnlyProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
          child: Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Arenas',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.7,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Manage venue onboarding, photos, units, blocks, and bookings.',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              totalAsync.when(
                data: (all) {
                  final shown = async.asData?.value.length ?? 0;
                  return _CountPill(label: '$shown / ${all.length}');
                },
                loading: () => const SizedBox.shrink(),
                error: (_, _) => const SizedBox.shrink(),
              ),
              const SizedBox(width: 8),
              IconButton(
                tooltip: 'Refresh',
                icon: const Icon(Icons.refresh,
                    size: 18, color: AppColors.textSecondary),
                onPressed: () => ref.invalidate(arenasListProvider),
              ),
              const SizedBox(width: 4),
              FilledButton.icon(
                onPressed: () => context.go('/arenas/new'),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Create'),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  onChanged: (q) =>
                      ref.read(arenaSearchProvider.notifier).state = q,
                  decoration: const InputDecoration(
                    hintText: 'Search name, city, owner',
                    prefixIcon: Icon(Icons.search,
                        size: 18, color: AppColors.textMuted),
                    prefixIconConstraints:
                        BoxConstraints(minWidth: 38, minHeight: 38),
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              _VerifiedToggle(
                selected: verifiedOnly,
                onTap: () => ref
                    .read(arenaVerifiedOnlyProvider.notifier)
                    .state = !verifiedOnly,
              ),
            ],
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(arenasListProvider);
              await ref.read(arenasListProvider.future);
            },
            child: async.when(
              data: (arenas) {
                if (arenas.isEmpty) {
                  return const _EmptyState(
                    message: 'No arenas match your filters',
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
                  itemCount: arenas.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (_, i) => _ArenaCard(arena: arenas[i]),
                );
              },
              loading: () => const Center(
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
              error: (e, _) => _ErrorView(
                message: e.toString(),
                onRetry: () => ref.invalidate(arenasListProvider),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CountPill extends StatelessWidget {
  const _CountPill({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _VerifiedToggle extends StatelessWidget {
  const _VerifiedToggle({required this.selected, required this.onTap});
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.textPrimary : AppColors.surface,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: selected ? AppColors.textPrimary : AppColors.border,
            ),
          ),
          child: Text(
            'Verified only',
            style: TextStyle(
              color: selected ? Colors.white : AppColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

class _ArenaCard extends StatelessWidget {
  const _ArenaCard({required this.arena});
  final Arena arena;

  @override
  Widget build(BuildContext context) {
    final location = [
      if (arena.city.isNotEmpty) arena.city,
      if (arena.state.isNotEmpty) arena.state,
    ].join(', ');
    final metaParts = <String>[
      if (location.isNotEmpty) location,
      if (arena.ownerName != null && arena.ownerName!.isNotEmpty)
        arena.ownerName!,
      if (arena.openTime.isNotEmpty && arena.closeTime.isNotEmpty)
        '${arena.openTime}–${arena.closeTime}',
      if (arena.unitCount > 0) '${arena.unitCount} units',
      if (arena.totalRatings > 0)
        '${arena.rating.toStringAsFixed(1)}★ (${arena.totalRatings})',
    ];

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => context.go('/arenas/${arena.id}'),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: AppColors.bg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                  image: arena.photoUrl != null
                      ? DecorationImage(
                          image: NetworkImage(arena.photoUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: arena.photoUrl == null
                    ? const Icon(Icons.stadium_outlined,
                        size: 22, color: AppColors.textSecondary)
                    : null,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            arena.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              color: AppColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (arena.verified) ...[
                          const SizedBox(width: 6),
                          const Icon(Icons.verified_rounded,
                              size: 14, color: AppColors.success),
                        ],
                        const SizedBox(width: 8),
                        if (arena.swingEnabled)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.bg,
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: const Text(
                              'Swing',
                              style: TextStyle(
                                fontSize: 10.5,
                                letterSpacing: 0.2,
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      metaParts.join('  ·  '),
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _MiniMetric(label: 'Units', value: '${arena.unitCount}'),
                        _MiniMetric(label: 'Ratings', value: arena.totalRatings > 0
                            ? '${arena.rating.toStringAsFixed(1)}★'
                            : '—'),
                        _MiniMetric(label: 'Timing',
                            value: '${arena.openTime.isNotEmpty ? arena.openTime : '—'}-${arena.closeTime.isNotEmpty ? arena.closeTime : '—'}'),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              const Icon(Icons.chevron_right, size: 20, color: AppColors.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniMetric extends StatelessWidget {
  const _MiniMetric({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        '$label: $value',
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        const SizedBox(height: 100),
        Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Couldn\'t reach API',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              const SizedBox(height: 4),
              Text(
                message,
                style: const TextStyle(
                    fontSize: 12.5, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: onRetry,
                child: const Text('Try again'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
