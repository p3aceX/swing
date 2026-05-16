import 'package:flutter/foundation.dart';
import 'package:googleapis/youtube/v3.dart';

import 'stream_session.dart';

/// Result of [BroadcastRepository.findOrCreate] — caller wants to know
/// whether we picked up an existing broadcast or minted a new one (for UX).
typedef FindOrCreateResult = ({StreamSession session, bool reused});

/// Talks to the YouTube Data API. Every method here costs quota — call only
/// when a cached session is missing, stale, or the user explicitly ends.
class BroadcastRepository {
  /// Fetch all 'upcoming' and 'active' broadcasts and their stream info.
  Future<List<StreamSession>> listActiveBroadcasts(
    YouTubeApi api, {
    required bool isVertical,
  }) async {
    final List<StreamSession> results = [];
    for (final status in const ['active', 'upcoming']) {
      try {
        final list = await api.liveBroadcasts.list(
          ['id', 'snippet', 'contentDetails'],
          broadcastStatus: status,
          maxResults: 10,
        );
        for (final b in list.items ?? const <LiveBroadcast>[]) {
          final streamId = b.contentDetails?.boundStreamId;
          if (b.id == null || streamId == null) continue;

          // Check if this broadcast is already in our results (unlikely but possible if status changed mid-loop)
          if (results.any((s) => s.broadcastId == b.id)) continue;

          final streams = await api.liveStreams.list(['cdn'], id: [streamId]);
          final ingest =
              streams.items?.isEmpty == false
                  ? streams.items!.first.cdn?.ingestionInfo
                  : null;
          final key = ingest?.streamName;
          if (key == null || key.isEmpty) continue;

          var url =
              ingest?.ingestionAddress ?? 'rtmp://a.rtmp.youtube.com/live2';
          if (url.startsWith('rtmps://')) {
            url = url.replaceFirst('rtmps://', 'rtmp://');
          }

          results.add(StreamSession(
            broadcastId: b.id!,
            streamId: streamId,
            rtmpUrl: url,
            streamKey: key,
            createdAt: b.snippet?.scheduledStartTime ?? DateTime.now(),
            wasStreaming: status == 'active',
            isVertical: isVertical,
          ));
        }
      } catch (e) {
        debugPrint('[BCAST] list $status failed: $e');
      }
    }
    return results;
  }

  /// Cheap reuse path. Lists upcoming + active broadcasts (~2 quota units)
  /// and returns credentials for the first one with a bound stream key.
  /// Falls back to [createFresh] if nothing is usable. This is what we
  /// call when the local session cache is empty — protects against
  /// "user uninstalls / wipes prefs and now has 50 abandoned broadcasts".
  Future<FindOrCreateResult> findOrCreate(
    YouTubeApi api, {
    required bool isVertical,
  }) async {
    final actives = await listActiveBroadcasts(api, isVertical: isVertical);
    if (actives.isNotEmpty) {
      final session = actives.first;
      await session.save();
      debugPrint('[BCAST] reused existing broadcast: ${session.broadcastId}');
      return (session: session, reused: true);
    }
    final fresh = await createFresh(api, isVertical: isVertical);
    return (session: fresh, reused: false);
  }

  /// Create stream + broadcast + bind. ~150 quota units.
  /// enableAutoStop=false is critical: it lets a crashed app reconnect
  /// without YouTube ending the broadcast 60s after RTMP drops.
  Future<StreamSession> createFresh(
    YouTubeApi api, {
    required bool isVertical,
  }) async {
    debugPrint('[BCAST] creating fresh broadcast');

    final stream = await api.liveStreams.insert(
      LiveStream(
        snippet: LiveStreamSnippet(title: 'Swing Live'),
        cdn: CdnSettings(
          ingestionType: 'rtmp',
          resolution: 'variable',
          frameRate: 'variable',
        ),
      ),
      ['snippet', 'cdn'],
    );

    final broadcast = await api.liveBroadcasts.insert(
      LiveBroadcast(
        snippet: LiveBroadcastSnippet(
          title: 'Swing Live',
          scheduledStartTime:
              DateTime.now().toUtc().add(const Duration(seconds: 30)),
        ),
        status: LiveBroadcastStatus(
          privacyStatus: 'unlisted',
          selfDeclaredMadeForKids: false,
        ),
        contentDetails: LiveBroadcastContentDetails(
          enableAutoStart: true,
          enableAutoStop: false,
        ),
      ),
      ['snippet', 'status', 'contentDetails'],
    );

    await api.liveBroadcasts.bind(
      broadcast.id!,
      ['id', 'contentDetails'],
      streamId: stream.id!,
    );

    final ingest = stream.cdn?.ingestionInfo;
    var url =
        ingest?.ingestionAddress ?? 'rtmp://a.rtmp.youtube.com/live2';
    if (url.startsWith('rtmps://')) {
      url = url.replaceFirst('rtmps://', 'rtmp://');
    }

    final session = StreamSession(
      broadcastId: broadcast.id!,
      streamId: stream.id!,
      rtmpUrl: url,
      streamKey: ingest?.streamName ?? '',
      createdAt: DateTime.now(),
      wasStreaming: false,
      isVertical: isVertical,
    );
    await session.save();
    debugPrint('[BCAST] created: ${session.broadcastId}');
    return session;
  }

  /// Transition broadcast to complete. ~50 quota units. After this call the
  /// session is dead — caller must clear local cache.
  Future<void> end(YouTubeApi api, String broadcastId) async {
    try {
      await api.liveBroadcasts.transition(
        'complete',
        broadcastId,
        ['id', 'status'],
      );
      debugPrint('[BCAST] ended: $broadcastId');
    } catch (e) {
      // 403 "redundantTransition" is fine — broadcast already complete on
      // YouTube side. Anything else we just log; local cache will be cleared
      // regardless so the next goLive() will create a new broadcast.
      debugPrint('[BCAST] end error (continuing): $e');
    }
  }
}
