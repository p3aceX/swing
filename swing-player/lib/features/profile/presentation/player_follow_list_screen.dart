import "package:cached_network_image/cached_network_image.dart";
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/theme/app_colors.dart';
import '../controller/profile_controller.dart';

enum FollowListMode { followers, following }

// ─── Providers ─────────────────────────────────────────────────────────────────

final _followListProvider = FutureProvider.autoDispose
    .family<List<_PlayerSummary>, ({String profileId, FollowListMode mode})>(
  (ref, args) async {
    ref.watch(followGraphRefreshTickProvider);
    final dio = ApiClient.instance.dio;
    final endpoint = args.mode == FollowListMode.followers
        ? ApiEndpoints.playerFollowers
        : ApiEndpoints.playerFollowing;
    final response = await dio.get(
      endpoint,
      queryParameters: {'playerId': args.profileId},
    );
    final body = response.data;
    List<dynamic> list = [];
    if (body is List) {
      list = body;
    } else if (body is Map<String, dynamic>) {
      final dataNode = body['data'];
      if (dataNode is List) {
        list = dataNode;
      } else if (dataNode is Map<String, dynamic>) {
        final inner = dataNode['data'] ??
            dataNode['followers'] ??
            dataNode['following'] ??
            dataNode['players'] ??
            dataNode['items'] ??
            [];
        if (inner is List) list = inner;
      } else {
        final inner = body['followers'] ??
            body['following'] ??
            body['players'] ??
            body['items'] ??
            body['results'] ??
            [];
        if (inner is List) list = inner;
      }
    }
    return list
        .whereType<Map<String, dynamic>>()
        .map(_PlayerSummary.fromJson)
        .toList();
  },
);

final _followingTeamsProvider =
    FutureProvider.autoDispose<List<_EntitySummary>>((ref) async {
  ref.watch(followGraphRefreshTickProvider);
  final dio = ApiClient.instance.dio;
  try {
    final response = await dio.get(ApiEndpoints.playerFollowFollowing);
    final fromUnified = _parseEntityList(response.data, 'team');
    if (fromUnified.isNotEmpty) return fromUnified;
  } on DioException {
    // fallback below
  }
  try {
    final response = await dio.get(ApiEndpoints.playerFollowingTeams);
    return _parseEntityList(response.data, 'team');
  } on DioException {
    return [];
  }
});

final _followingTournamentsProvider =
    FutureProvider.autoDispose<List<_EntitySummary>>((ref) async {
  ref.watch(followGraphRefreshTickProvider);
  final dio = ApiClient.instance.dio;
  try {
    final response = await dio.get(ApiEndpoints.playerFollowFollowing);
    final fromUnified = _parseEntityList(response.data, 'tournament');
    if (fromUnified.isNotEmpty) return fromUnified;
  } on DioException {
    // fallback below
  }
  try {
    final response = await dio.get(ApiEndpoints.playerFollowingTournaments);
    return _parseEntityList(response.data, 'tournament');
  } on DioException {
    return [];
  }
});

List<_EntitySummary> _parseEntityList(dynamic body, String kind) {
  final entities = <Map<String, dynamic>>[];

  bool matchesKind(String rawType) {
    final t = rawType.trim().toLowerCase();
    if (t.isEmpty) return false;
    if (t == kind || t == '${kind}s') return true;
    if (kind == 'team' && t.contains('team')) return true;
    if (kind == 'tournament' && t.contains('tournament')) return true;
    return false;
  }

  void collectFromList(List<dynamic> list) {
    for (final item in list) {
      if (item is! Map<String, dynamic>) continue;
      final type = (item['type'] ?? item['entityType'] ?? item['targetType'])
          .toString()
          .trim()
          .toLowerCase();

      final nestedCandidates = <dynamic>[
        item[kind],
        item['entity'],
        item['target'],
        item['resource'],
        item['item'],
      ];

      for (final nested in nestedCandidates) {
        if (nested is Map<String, dynamic>) {
          entities.add({
            ...nested,
            'type': item['type'] ?? item['entityType'] ?? item['targetType'],
            'entityId': item['entityId'] ?? item['targetId'] ?? item['id'],
          });
          continue;
        }
      }

      if (item[kind] is Map<String, dynamic>) {
        continue;
      }

      if (type.isNotEmpty && !matchesKind(type)) continue;
      entities.add(item);
    }
  }

  if (body is List) {
    collectFromList(body);
  } else if (body is Map<String, dynamic>) {
    final rootCandidates = <dynamic>[
      body['${kind}s'],
      body['following${kind[0].toUpperCase()}${kind.substring(1)}s'],
      body['followed${kind[0].toUpperCase()}${kind.substring(1)}s'],
      body[kind],
      body['items'],
      body['results'],
      body['data'],
      body['following'],
    ];
    for (final candidate in rootCandidates) {
      if (candidate is List) collectFromList(candidate);
      if (candidate is Map<String, dynamic>) {
        final nestedCandidates = <dynamic>[
          candidate['${kind}s'],
          candidate['following${kind[0].toUpperCase()}${kind.substring(1)}s'],
          candidate['followed${kind[0].toUpperCase()}${kind.substring(1)}s'],
          candidate[kind],
          candidate['items'],
          candidate['results'],
          candidate['data'],
          candidate['following'],
        ];
        for (final nested in nestedCandidates) {
          if (nested is List) collectFromList(nested);
        }
      }
    }
  }

  final seen = <String>{};
  final out = <_EntitySummary>[];
  for (final entity in entities) {
    final parsed = _EntitySummary.fromJson(entity, kind);
    if (parsed.id.isEmpty || seen.contains(parsed.id)) continue;
    seen.add(parsed.id);
    out.add(parsed);
  }
  return out;
}

// ─── Models ───────────────────────────────────────────────────────────────────

class _PlayerSummary {
  const _PlayerSummary({
    required this.id,
    required this.name,
    required this.swingId,
    required this.avatarUrl,
    required this.playerRole,
    required this.city,
  });

  final String id;
  final String name;
  final String swingId;
  final String? avatarUrl;
  final String playerRole;
  final String city;

  factory _PlayerSummary.fromJson(Map<String, dynamic> j) {
    String s(String k) => (j[k] ?? '').toString().trim();
    final name = s('fullName').isNotEmpty ? s('fullName') : s('name');
    final swingId = s('username').isNotEmpty ? s('username') : s('swingId');
    return _PlayerSummary(
      id: s('id'),
      name: name,
      swingId: swingId,
      avatarUrl: s('avatarUrl').isEmpty ? null : s('avatarUrl'),
      playerRole: s('playerRole'),
      city: s('city'),
    );
  }
}

class _EntitySummary {
  const _EntitySummary({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.logoUrl,
    required this.kind,
  });

  final String id;
  final String name;
  final String subtitle;
  final String? logoUrl;
  final String kind; // 'team' or 'tournament'

  factory _EntitySummary.fromJson(Map<String, dynamic> j, String kind) {
    String s(String k) => (j[k] ?? '').toString().trim();
    final inferredKind = (j['type'] ?? j['entityType'] ?? j['targetType'])
        .toString()
        .trim()
        .toLowerCase();
    final effectiveKind = inferredKind.contains('team')
        ? 'team'
        : inferredKind.contains('tournament')
            ? 'tournament'
            : kind;
    final logo = s('logoUrl').isNotEmpty
        ? s('logoUrl')
        : s('avatarUrl').isNotEmpty
            ? s('avatarUrl')
            : null;
    final id = switch (effectiveKind) {
      'team' => s('id').isNotEmpty
          ? s('id')
          : s('_id').isNotEmpty
              ? s('_id')
              : s('teamId').isNotEmpty
                  ? s('teamId')
                  : s('entityId').isNotEmpty
                      ? s('entityId')
                      : s('targetId'),
      'tournament' => s('slug').isNotEmpty
          ? s('slug')
          : s('id').isNotEmpty
              ? s('id')
              : s('_id').isNotEmpty
                  ? s('_id')
                  : s('tournamentId').isNotEmpty
                      ? s('tournamentId')
                      : s('entityId').isNotEmpty
                          ? s('entityId')
                          : s('targetId'),
      _ => s('id'),
    };
    final sub = [
      if (s('city').isNotEmpty) s('city'),
      if (s('teamType').isNotEmpty) s('teamType'),
      if (s('format').isNotEmpty) s('format'),
      if (s('status').isNotEmpty) s('status'),
    ].join(' · ');
    return _EntitySummary(
      id: id,
      name: s('name').isNotEmpty
          ? s('name')
          : s('entityName').isNotEmpty
              ? s('entityName')
              : s('title').isNotEmpty
                  ? s('title')
                  : (effectiveKind == 'team' ? 'Team' : 'Tournament'),
      subtitle: sub,
      logoUrl: logo,
      kind: effectiveKind,
    );
  }
}

// ─── Screen ───────────────────────────────────────────────────────────────────

class PlayerFollowListScreen extends ConsumerWidget {
  const PlayerFollowListScreen({
    super.key,
    required this.profileId,
    required this.mode,
  });

  final String profileId;
  final FollowListMode mode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final title = mode == FollowListMode.followers ? 'Followers' : 'Following';

    if (mode == FollowListMode.followers) {
      // Followers: only players (only players can follow)
      final async = ref.watch(
        _followListProvider((profileId: profileId, mode: mode)),
      );
      return _FollowersScaffold(
        title: title,
        async: async,
      );
    }

    // Following: tabs — Players / Teams / Tournaments
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: context.bg,
        appBar: AppBar(
          backgroundColor: context.bg,
          surfaceTintColor: Colors.transparent,
          title: Text(
            title,
            style: TextStyle(
              color: context.fg,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded,
                color: context.fg, size: 18),
            onPressed: () => Navigator.of(context).pop(),
          ),
          bottom: TabBar(
            indicatorColor: context.accent,
            indicatorWeight: 2.5,
            labelColor: context.accent,
            unselectedLabelColor: context.fgSub,
            labelStyle:
                const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
            unselectedLabelStyle:
                const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            tabs: const [
              Tab(text: 'Players'),
              Tab(text: 'Teams'),
              Tab(text: 'Tournaments'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _PlayerFollowingTab(profileId: profileId),
            _EntityFollowingTab(
              asyncValue: ref.watch(_followingTeamsProvider),
              emptyText: 'Not following any teams yet.',
              onTap: (e) => context.push('/team/${e.id}'),
              icon: Icons.groups_rounded,
            ),
            _EntityFollowingTab(
              asyncValue: ref.watch(_followingTournamentsProvider),
              emptyText: 'Not following any tournaments yet.',
              onTap: (e) => context.push('/tournament/${e.id}'),
              icon: Icons.emoji_events_rounded,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Followers scaffold (only players) ────────────────────────────────────────

class _FollowersScaffold extends StatelessWidget {
  const _FollowersScaffold({required this.title, required this.async});
  final String title;
  final AsyncValue<List<_PlayerSummary>> async;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bg,
      appBar: AppBar(
        backgroundColor: context.bg,
        surfaceTintColor: Colors.transparent,
        title: Text(
          title,
          style: TextStyle(
            color: context.fg,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: context.fg, size: 18),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Could not load $title.',
              style: TextStyle(color: context.fgSub),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        data: (players) =>
            _PlayerList(players: players, mode: FollowListMode.followers),
      ),
    );
  }
}

// ── Players tab (in Following) ────────────────────────────────────────────────

class _PlayerFollowingTab extends ConsumerWidget {
  const _PlayerFollowingTab({required this.profileId});
  final String profileId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(
      _followListProvider(
          (profileId: profileId, mode: FollowListMode.following)),
    );
    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Text('Could not load.', style: TextStyle(color: context.fgSub)),
      ),
      data: (players) =>
          _PlayerList(players: players, mode: FollowListMode.following),
    );
  }
}

// ── Entity tab (Teams / Tournaments) ─────────────────────────────────────────

class _EntityFollowingTab extends StatelessWidget {
  const _EntityFollowingTab({
    required this.asyncValue,
    required this.emptyText,
    required this.onTap,
    required this.icon,
  });
  final AsyncValue<List<_EntitySummary>> asyncValue;
  final String emptyText;
  final void Function(_EntitySummary) onTap;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return asyncValue.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Text('Could not load.', style: TextStyle(color: context.fgSub)),
      ),
      data: (items) {
        if (items.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 48, color: context.fgSub),
                  const SizedBox(height: 12),
                  Text(
                    emptyText,
                    style: TextStyle(color: context.fgSub, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: items.length,
          separatorBuilder: (_, __) =>
              Divider(color: context.stroke, height: 1, indent: 72),
          itemBuilder: (_, i) => _EntityTile(
            entity: items[i],
            onTap: () => onTap(items[i]),
          ),
        );
      },
    );
  }
}

// ─── Player list ──────────────────────────────────────────────────────────────

class _PlayerList extends StatelessWidget {
  const _PlayerList({required this.players, required this.mode});
  final List<_PlayerSummary> players;
  final FollowListMode mode;

  @override
  Widget build(BuildContext context) {
    if (players.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.people_outline_rounded,
                  size: 48, color: context.fgSub),
              const SizedBox(height: 12),
              Text(
                mode == FollowListMode.followers
                    ? 'No followers yet.'
                    : 'Not following any players yet.',
                style: TextStyle(color: context.fgSub, fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: players.length,
      separatorBuilder: (_, __) =>
          Divider(color: context.stroke, height: 1, indent: 72),
      itemBuilder: (_, i) => _PlayerTile(player: players[i]),
    );
  }
}

// ─── Player tile ──────────────────────────────────────────────────────────────

class _PlayerTile extends StatelessWidget {
  const _PlayerTile({required this.player});
  final _PlayerSummary player;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      onTap: () => context.push('/player/${player.id}'),
      leading: CircleAvatar(
        radius: 24,
        backgroundColor: context.cardBg,
        backgroundImage:
            player.avatarUrl != null ? CachedNetworkImageProvider(player.avatarUrl!) : null,
        child: player.avatarUrl == null
            ? Text(
                player.name.isNotEmpty ? player.name[0].toUpperCase() : '?',
                style: TextStyle(
                  color: context.fg,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              )
            : null,
      ),
      title: Text(
        player.name,
        style: TextStyle(
          color: context.fg,
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
      ),
      subtitle: Text(
        [
          if (player.swingId.isNotEmpty) '@${player.swingId}',
          if (player.playerRole.isNotEmpty) player.playerRole,
          if (player.city.isNotEmpty) player.city,
        ].join(' · '),
        style: TextStyle(color: context.fgSub, fontSize: 12),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing:
          Icon(Icons.chevron_right_rounded, color: context.fgSub, size: 20),
    );
  }
}

// ─── Entity tile ──────────────────────────────────────────────────────────────

class _EntityTile extends StatelessWidget {
  const _EntityTile({required this.entity, required this.onTap});
  final _EntitySummary entity;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      onTap: onTap,
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: context.cardBg,
          borderRadius: BorderRadius.circular(12),
          image: entity.logoUrl != null
              ? DecorationImage(
                  image: CachedNetworkImageProvider(entity.logoUrl!), fit: BoxFit.cover)
              : null,
        ),
        child: entity.logoUrl == null
            ? Icon(
                entity.kind == 'team'
                    ? Icons.groups_rounded
                    : Icons.emoji_events_rounded,
                color: context.fgSub,
                size: 22,
              )
            : null,
      ),
      title: Text(
        entity.name,
        style: TextStyle(
          color: context.fg,
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
      ),
      subtitle: entity.subtitle.isNotEmpty
          ? Text(
              entity.subtitle,
              style: TextStyle(color: context.fgSub, fontSize: 12),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            )
          : null,
      trailing:
          Icon(Icons.chevron_right_rounded, color: context.fgSub, size: 20),
    );
  }
}
