import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../domain/arena.dart';
import '../domain/arena_workspace_models.dart';

class ArenasRepository {
  ArenasRepository(this._api);
  final ApiClient _api;

  Future<List<Arena>> list({
    String? search,
    String? city,
    int page = 1,
    int limit = 20,
  }) async {
    final resp = await _api.get(
      '/admin/arenas',
      query: {
        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
        if (city != null && city.trim().isNotEmpty) 'city': city.trim(),
        'page': '$page',
        'limit': '$limit',
      },
    );
    final items = _extractList(resp, keys: const ['arenas', 'items']);
    return items
        .whereType<Map>()
        .map((m) => Arena.fromJson(Map<String, dynamic>.from(m)))
        .toList();
  }

  Future<ArenaDetail> get(String id) async {
    final resp = await _api.get('/arenas/$id');
    return ArenaDetail.fromJson(_asMap(resp));
  }

  Future<ArenaDetail> createArena(Map<String, dynamic> body) async {
    final resp = await _api.post('/arenas/', body);
    return ArenaDetail.fromJson(_asMap(resp));
  }

  Future<ArenaDetail> updateArena(String id, Map<String, dynamic> body) async {
    final resp = await _api.put('/arenas/$id', body);
    return ArenaDetail.fromJson(_asMap(resp));
  }

  Future<String> uploadMedia({
    required String folder,
    required List<int> bytes,
    required String filename,
  }) async {
    final resp = await _api.uploadFile(
      '/admin/media/upload',
      bytes: bytes,
      filename: filename,
      fields: {'folder': folder},
    );
    final map = _asMap(resp);
    final publicUrl = map['publicUrl']?.toString() ?? '';
    if (publicUrl.isEmpty) {
      throw StateError('Upload succeeded but no public URL was returned');
    }
    return publicUrl;
  }

  Future<void> verifyArena(String id, String arenaGrade) async {
    await _api.patch('/admin/arenas/$id/verify', {'arenaGrade': arenaGrade});
  }

  Future<void> toggleSwingArena(String id) async {
    await _api.patch('/admin/arenas/$id/toggle-swing', {});
  }

  Future<void> deleteArena(String id) async {
    await _api.delete('/admin/arenas/$id');
  }

  Future<ArenaUnitDetail> addUnit(
    String arenaId,
    Map<String, dynamic> body,
  ) async {
    final resp = await _api.post('/arenas/$arenaId/units', body);
    return ArenaUnitDetail.fromJson(_asMap(resp));
  }

  Future<ArenaUnitDetail> updateUnit(
    String unitId,
    Map<String, dynamic> body,
  ) async {
    final resp = await _api.patch('/arenas/u/$unitId', body);
    return ArenaUnitDetail.fromJson(_asMap(resp));
  }

  Future<void> deleteUnit(String unitId) async {
    await _api.delete('/arenas/u/$unitId');
  }

  Future<List<ArenaTimeBlockDetail>> listBlocks(
    String arenaId, {
    String? date,
    String? unitId,
    bool recurringOnly = false,
  }) async {
    final resp = await _api.get(
      '/arenas/$arenaId/blocks',
      query: {
        if (date != null && date.isNotEmpty) 'date': date,
        if (unitId != null && unitId.isNotEmpty) 'unitId': unitId,
        if (recurringOnly) 'recurringOnly': 'true',
      },
    );
    final items = _extractList(resp, keys: const ['blocks', 'items']);
    return items
        .whereType<Map>()
        .map((m) => ArenaTimeBlockDetail.fromJson(Map<String, dynamic>.from(m)))
        .toList();
  }

  Future<ArenaTimeBlockDetail> createBlock(
    String arenaId,
    Map<String, dynamic> body,
  ) async {
    final resp = await _api.post('/arenas/$arenaId/blocks', body);
    return ArenaTimeBlockDetail.fromJson(_asMap(resp));
  }

  Future<void> deleteBlock(String blockId) async {
    await _api.delete('/blocks/$blockId');
  }

  Future<List<ArenaAvailabilityUnitDetail>> getAvailability(
    String arenaId, {
    required String date,
    String? unitId,
  }) async {
    final resp = await _api.get(
      '/arenas/$arenaId/availability',
      query: {
        'date': date,
        if (unitId != null && unitId.isNotEmpty) 'unitId': unitId,
      },
    );
    final items = _extractList(resp, keys: const ['availability', 'items']);
    return items
        .whereType<Map>()
        .map(
          (m) => ArenaAvailabilityUnitDetail.fromJson(
            Map<String, dynamic>.from(m),
          ),
        )
        .toList();
  }

  Future<ArenaStatsDetail> getStats(String arenaId) async {
    final resp = await _api.get('/arenas/$arenaId/stats');
    return ArenaStatsDetail.fromJson(_asMap(resp));
  }

  Future<ArenaManagerDetail> addManager(
    String arenaId,
    Map<String, dynamic> body,
  ) async {
    final resp = await _api.post('/arenas/$arenaId/managers', body);
    return ArenaManagerDetail.fromJson(_asMap(resp));
  }

  Future<List<ArenaBookingDetail>> getBookings(
    String arenaId, {
    String? date,
  }) async {
    final resp = await _api.get(
      '/bookings/arena/$arenaId',
      query: {if (date != null && date.isNotEmpty) 'date': date},
    );
    final items = _extractList(resp, keys: const ['bookings', 'items']);
    return items
        .whereType<Map>()
        .map((m) => ArenaBookingDetail.fromJson(Map<String, dynamic>.from(m)))
        .toList();
  }

  List<dynamic> _extractList(dynamic resp, {required List<String> keys}) {
    if (resp is List) return resp;
    if (resp is Map) {
      for (final key in keys) {
        final value = resp[key];
        if (value is List) return value;
      }
    }
    return const [];
  }

  Map<String, dynamic> _asMap(dynamic resp) {
    if (resp is Map) return Map<String, dynamic>.from(resp);
    return <String, dynamic>{};
  }
}

final arenasRepositoryProvider = Provider<ArenasRepository>((ref) {
  return ArenasRepository(ref.watch(apiClientProvider));
});

final arenasListProvider = FutureProvider<List<Arena>>((ref) {
  return ref.watch(arenasRepositoryProvider).list();
});

final arenaDetailProvider = FutureProvider.family<ArenaDetail, String>((
  ref,
  id,
) {
  return ref.watch(arenasRepositoryProvider).get(id);
});

final arenaStatsProvider = FutureProvider.family<ArenaStatsDetail, String>((
  ref,
  id,
) {
  return ref.watch(arenasRepositoryProvider).getStats(id);
});

final arenaBookingsProvider =
    FutureProvider.family<
      List<ArenaBookingDetail>,
      ({String arenaId, String? date})
    >((ref, args) {
      return ref
          .watch(arenasRepositoryProvider)
          .getBookings(args.arenaId, date: args.date);
    });

final arenaBlocksProvider =
    FutureProvider.family<
      List<ArenaTimeBlockDetail>,
      ({String arenaId, String? date, String? unitId, bool recurringOnly})
    >((ref, args) {
      return ref
          .watch(arenasRepositoryProvider)
          .listBlocks(
            args.arenaId,
            date: args.date,
            unitId: args.unitId,
            recurringOnly: args.recurringOnly,
          );
    });

final arenaAvailabilityProvider =
    FutureProvider.family<
      List<ArenaAvailabilityUnitDetail>,
      ({String arenaId, String date, String? unitId})
    >((ref, args) {
      return ref
          .watch(arenasRepositoryProvider)
          .getAvailability(args.arenaId, date: args.date, unitId: args.unitId);
    });
