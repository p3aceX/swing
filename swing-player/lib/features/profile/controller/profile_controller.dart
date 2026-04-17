import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../data/academy_fee_service.dart';
import '../data/profile_repository.dart';
import '../domain/profile_models.dart';

/// Bumped whenever player follow/unfollow succeeds.
/// Providers that depend on social graph data watch this to refresh immediately.
final followGraphRefreshTickProvider = StateProvider<int>((ref) => 0);

final profileRepositoryProvider = Provider<ProfileRepository>(
    (ref) => ProfileRepository(ApiClient.instance.dio));

final academyFeeServiceProvider =
    Provider<AcademyFeeService>((ref) => AcademyFeeService());

class ProfileState {
  const ProfileState({
    this.isLoading = false,
    this.isActionLoading = false,
    this.data,
    this.error,
  });

  final bool isLoading;
  final bool isActionLoading;
  final PlayerProfilePageData? data;
  final String? error;

  ProfileState copyWith({
    bool? isLoading,
    bool? isActionLoading,
    PlayerProfilePageData? data,
    String? error,
  }) {
    return ProfileState(
      isLoading: isLoading ?? this.isLoading,
      isActionLoading: isActionLoading ?? this.isActionLoading,
      data: data ?? this.data,
      error: error,
    );
  }
}

class ProfileController extends StateNotifier<ProfileState> {
  ProfileController(this._ref, this._repository, {this.profileId})
      : super(const ProfileState(isLoading: true)) {
    load();
  }

  final Ref _ref;
  final ProfileRepository _repository;
  final String? profileId;

  DateTime? _loadedAt;

  // Re-fetch only if data is older than this.
  static const _ttl = Duration(minutes: 2);

  Future<void> load() async {
    state = state.copyWith(isLoading: state.data == null, error: null);
    try {
      await for (final data in _repository.loadProfilePageStream(profileId: profileId)) {
        _loadedAt = DateTime.now();
        state = ProfileState(isLoading: false, data: data);
      }
    } catch (error) {
      // 401 = not authenticated yet (app startup before login) — stay silent
      final is401 = error is DioException && error.response?.statusCode == 401;
      if (kDebugMode) {
        debugPrint('[Profile] load error: $error is401=$is401');
      }
      state = ProfileState(
        isLoading: false,
        error: is401 ? null : _profileErrorMessage(error),
      );
    }
  }

  Future<void> refresh() => load();

  /// Re-fetches in the background — existing data stays visible, no
  /// loading spinner shown. Skipped if data was loaded within [_ttl].
  Future<void> silentRefresh({bool force = false}) async {
    final isStale =
        _loadedAt == null || DateTime.now().difference(_loadedAt!) > _ttl;
    if (!force && !isStale) return;
    if (state.isLoading) return; // full load already in progress

    try {
      final data = await _repository.loadProfilePage(profileId: profileId);
      _loadedAt = DateTime.now();
      if (mounted) state = ProfileState(isLoading: false, data: data);
    } catch (_) {
      // Silent — don't replace existing data with an error on background fetch.
    }
  }

  Future<void> toggleFollow() async {
    final current = state.data;
    final context = current?.viewerContext;
    if (current == null || context == null || context.isSelf) return;

    state = state.copyWith(isActionLoading: true, error: null);
    try {
      final nowFollowing = context.following
          ? await _repository.unfollowPlayer(current.identity.id)
          : await _repository.followPlayer(current.identity.id);
      final followerCountDelta = nowFollowing ? 1 : -1;

      final updatedIdentity = PlayerIdentity(
        id: current.identity.id,
        fullName: current.identity.fullName,
        swingId: current.identity.swingId,
        followersCount: (current.identity.followersCount + followerCountDelta)
            .clamp(0, 1 << 30),
        followingCount: current.identity.followingCount,
        primaryRole: current.identity.primaryRole,
        battingStyle: current.identity.battingStyle,
        bowlingStyle: current.identity.bowlingStyle,
        archetype: current.identity.archetype,
        competitiveTier: current.identity.competitiveTier,
        level: current.identity.level,
        pulseStatus: current.identity.pulseStatus,
        city: current.identity.city,
        state: current.identity.state,
        goal: current.identity.goal,
        bio: current.identity.bio,
        avatarUrl: current.identity.avatarUrl,
        coverUrl: current.identity.coverUrl,
      );
      final unifiedIdentity = current.unified.identity;
      final updatedUnifiedIdentity = ProfileIdentity(
        id: unifiedIdentity.id,
        name: unifiedIdentity.name,
        avatarUrl: unifiedIdentity.avatarUrl,
        bio: unifiedIdentity.bio,
        city: unifiedIdentity.city,
        state: unifiedIdentity.state,
        playerRole: unifiedIdentity.playerRole,
        battingStyle: unifiedIdentity.battingStyle,
        bowlingStyle: unifiedIdentity.bowlingStyle,
        level: unifiedIdentity.level,
        fans: (unifiedIdentity.fans + followerCountDelta).clamp(0, 1 << 30),
        following: unifiedIdentity.following,
      );
      state = state.copyWith(
        isActionLoading: false,
        data: current.copyWith(
          identity: updatedIdentity,
          unified: UnifiedProfileData(
            identity: updatedUnifiedIdentity,
            ranking: current.unified.ranking,
            stats: current.unified.stats,
            precision: current.unified.precision,
            badges: current.unified.badges,
            wellness: current.unified.wellness,
            teams: current.unified.teams,
          ),
          viewerContext: context.copyWith(following: nowFollowing),
        ),
      );
      // Trigger immediate refresh for social-count and follow-list providers.
      _ref.read(followGraphRefreshTickProvider.notifier).state++;
    } catch (error) {
      state = state.copyWith(
        isActionLoading: false,
        error: _profileErrorMessage(error),
      );
    }
  }

  Future<String?> startDirectConversation() async {
    final current = state.data;
    final context = current?.viewerContext;
    if (current == null || context == null || context.isSelf) return null;
    if (context.directConversationId != null &&
        context.directConversationId!.trim().isNotEmpty) {
      return context.directConversationId;
    }

    state = state.copyWith(isActionLoading: true, error: null);
    try {
      final conversationId =
          await _repository.startDirectConversation(current.identity.id);
      state = state.copyWith(
        isActionLoading: false,
        data: current.copyWith(
          viewerContext: context.copyWith(
            directConversationId: conversationId,
          ),
        ),
      );
      return conversationId;
    } catch (error) {
      state = state.copyWith(
        isActionLoading: false,
        error: _profileErrorMessage(error),
      );
      rethrow;
    }
  }

  void patchAvatar(String avatarUrl) {
    final current = state.data;
    if (current == null || avatarUrl.trim().isEmpty) return;

    state = state.copyWith(
      data: current.copyWith(
        identity: current.identity.copyWith(avatarUrl: avatarUrl),
        editableProfile: current.editableProfile.copyWith(avatarUrl: avatarUrl),
      ),
    );
  }

  void patchCover(String coverUrl) {
    final current = state.data;
    if (current == null || coverUrl.trim().isEmpty) return;

    state = state.copyWith(
      data: current.copyWith(
        identity: current.identity.copyWith(coverUrl: coverUrl),
        editableProfile: current.editableProfile.copyWith(coverUrl: coverUrl),
      ),
    );
  }
}

String _profileErrorMessage(Object error) {
  if (error is DioException) {
    final status = error.response?.statusCode;
    if (status == 401) {
      return 'Session expired. Please log in again.';
    }
    if (status == 404) {
      return 'Profile not found.';
    }
    if (status == 500) {
      return 'Profile is unavailable right now.';
    }
    if (error.type == DioExceptionType.connectionError) {
      return 'Could not reach the profile service.';
    }
  }
  return 'Could not load profile right now.';
}

final profileControllerProvider =
    StateNotifierProvider.autoDispose<ProfileController, ProfileState>((ref) {
  return ProfileController(ref, ref.watch(profileRepositoryProvider));
});

final playerProfileProvider = StateNotifierProvider.autoDispose
    .family<ProfileController, ProfileState, String>((ref, profileId) {
  return ProfileController(ref, ref.watch(profileRepositoryProvider),
      profileId: profileId);
});

/// The current signed-in player's profile ID (PlayerProfile.id).
/// This is the canonical ID used by the social/chat APIs.
/// Returns null while the profile is still loading.
final currentPlayerIdProvider = Provider<String?>((ref) {
  return ref.watch(profileControllerProvider).data?.identity.id;
});
