// Thin shim over [HostMatchDetailRepository]. Host owns the implementation —
// this class only adds the player-app naming aliases (`loadMyMatches`,
// `loadMyMatchesStream`) and a no-arg constructor for legacy call sites that
// don't have a Riverpod ref handy.
import 'dart:async';

import 'package:flutter_host_core/flutter_host_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';

class MatchesRepository extends HostMatchDetailRepository {
  MatchesRepository.withDeps(super.dio, super.paths);

  factory MatchesRepository() => MatchesRepository.withDeps(
        ApiClient.instance.dio,
        HostPathConfig.player(),
      );

  Future<List<PlayerMatch>> loadMyMatches() => fetchMyMatches();

  Stream<List<PlayerMatch>> loadMyMatchesStream() async* {
    yield await fetchMyMatches();
  }
}

final matchesRepositoryProvider = Provider<MatchesRepository>(
  (ref) => MatchesRepository.withDeps(
    ref.watch(hostDioProvider),
    ref.watch(hostPathConfigProvider),
  ),
);
