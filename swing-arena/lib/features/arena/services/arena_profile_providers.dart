import 'package:flutter_host_core/flutter_host_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/auth/me_providers.dart';

final arenaDetailProvider = FutureProvider<ArenaListing?>((ref) async {
  final me = await ref.watch(meProvider.future);
  final arenaId = me?.businessStatus.arenaId;

  if (arenaId == null) return null;

  final repo = ref.watch(hostArenaBookingRepositoryProvider);
  return repo.fetchArenaDetail(arenaId);
});

final arenaDetailByIdProvider =
    FutureProvider.family<ArenaListing, String>((ref, arenaId) async {
  final repo = ref.watch(hostArenaBookingRepositoryProvider);
  return repo.fetchArenaDetail(arenaId);
});

final ownedArenasProvider = FutureProvider<List<ArenaListing>>((ref) async {
  final repo = ref.watch(hostArenaBookingRepositoryProvider);
  try {
    return await repo.fetchOwnedArenas();
  } catch (_) {
    final me = await ref.watch(meProvider.future);
    final arenaIds = {
      ...?me?.businessStatus.arenaIds,
      if (me?.businessStatus.arenaId != null) me!.businessStatus.arenaId!,
      if (me?.businessStatus.managedArenaId != null)
        me!.businessStatus.managedArenaId!,
    }.toList();
    if (arenaIds.isEmpty) return const [];
    final arenas = await Future.wait(arenaIds.map(repo.fetchArenaDetail));
    return arenas;
  }
});
