import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/youtube/v3.dart';
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class YouTubeService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      YouTubeApi.youtubeScope,
      YouTubeApi.youtubeReadonlyScope,
    ],
  );

  YouTubeApi? _youtubeApi;
  String? _currentBroadcastId;

  // Full interactive sign-in (shows OAuth consent screen).
  Future<GoogleSignInAccount?> signIn() async {
    debugPrint("[DEBUG] YouTubeService: Starting signIn flow...");
    try {
      final account = await _googleSignIn.signIn();
      if (account == null) {
        debugPrint("[DEBUG] YouTubeService: User cancelled sign-in.");
        return null;
      }
      return await _initApiClient(account);
    } catch (e) {
      debugPrint("[DEBUG] YouTubeService ERROR: $e");
      if (e is PlatformException) {
        debugPrint("[DEBUG] YouTubeService: Code=${e.code}, Message=${e.message}");
      }
      return null;
    }
  }

  // Silent sign-in — restores the previous session without any UI.
  // Returns null if the token has expired and interactive sign-in is needed.
  Future<GoogleSignInAccount?> signInSilently() async {
    debugPrint("[DEBUG] YouTubeService: Attempting silent sign-in...");
    try {
      final account = await _googleSignIn.signInSilently();
      if (account == null) {
        debugPrint("[DEBUG] YouTubeService: No previous session found.");
        return null;
      }
      return await _initApiClient(account);
    } catch (e) {
      debugPrint("[DEBUG] YouTubeService: Silent sign-in failed: $e");
      return null;
    }
  }

  Future<GoogleSignInAccount?> _initApiClient(GoogleSignInAccount account) async {
    debugPrint("[DEBUG] YouTubeService: Signed in as ${account.email}.");
    final httpClient = await _googleSignIn.authenticatedClient();
    if (httpClient == null) {
      debugPrint("[DEBUG] YouTubeService: Failed to get authenticated HTTP client.");
      return account;
    }
    _youtubeApi = YouTubeApi(httpClient);
    return account;
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    _youtubeApi = null;
    _currentBroadcastId = null;
  }

  Future<Map<String, String>?> getLiveStreamCredentials() async {
    if (_youtubeApi == null) return null;

    try {
      // 1. Check for an existing upcoming broadcast with a bound stream
      debugPrint("[DEBUG] YouTubeService: Checking for existing broadcasts...");
      final broadcasts = await _youtubeApi!.liveBroadcasts.list(
        ['snippet', 'contentDetails', 'status'],
        broadcastStatus: 'upcoming',
      );

      String? broadcastId;
      String? boundStreamId;
      String? broadcastTitle;

      if (broadcasts.items != null) {
        for (final b in broadcasts.items!) {
          if (b.contentDetails?.boundStreamId != null) {
            broadcastId = b.id;
            boundStreamId = b.contentDetails!.boundStreamId;
            broadcastTitle = b.snippet?.title;
            debugPrint("[DEBUG] YouTubeService: Found existing broadcast '$broadcastTitle'.");
            break;
          }
        }
      }

      // 2. No usable broadcast — create a stream then a broadcast and bind them
      if (broadcastId == null || boundStreamId == null) {
        debugPrint("[DEBUG] YouTubeService: No broadcast found, creating one...");

        final newStream = await _youtubeApi!.liveStreams.insert(
          LiveStream(
            snippet: LiveStreamSnippet(title: 'Swing Live Stream'),
            cdn: CdnSettings(
              ingestionType: 'rtmp',
              resolution: '1080p',
              frameRate: '30fps',
            ),
          ),
          ['snippet', 'cdn'],
        );
        boundStreamId = newStream.id;
        debugPrint("[DEBUG] YouTubeService: Created live stream id=$boundStreamId");

        final scheduledStart = DateTime.now().toUtc().add(const Duration(seconds: 30));
        final newBroadcast = await _youtubeApi!.liveBroadcasts.insert(
          LiveBroadcast(
            snippet: LiveBroadcastSnippet(
              title: 'Swing Live',
              scheduledStartTime: scheduledStart,
            ),
            status: LiveBroadcastStatus(privacyStatus: 'public'),
            contentDetails: LiveBroadcastContentDetails(
              enableAutoStart: true,
              enableAutoStop: true,
            ),
          ),
          ['snippet', 'status', 'contentDetails'],
        );
        broadcastId = newBroadcast.id;
        broadcastTitle = newBroadcast.snippet?.title;
        debugPrint("[DEBUG] YouTubeService: Created broadcast id=$broadcastId");

        await _youtubeApi!.liveBroadcasts.bind(
          broadcastId!,
          ['id', 'contentDetails'],
          streamId: boundStreamId,
        );
        debugPrint("[DEBUG] YouTubeService: Bound stream to broadcast.");
      }

      // 3. Get RTMP credentials from the stream
      final streams = await _youtubeApi!.liveStreams.list(
        ['cdn'],
        id: [boundStreamId!],
      );

      if (streams.items == null || streams.items!.isEmpty) {
        debugPrint("[DEBUG] YouTubeService: Could not fetch stream CDN info.");
        return null;
      }

      final ingestionInfo = streams.items!.first.cdn?.ingestionInfo;
      _currentBroadcastId = broadcastId;

      debugPrint("[DEBUG] YouTubeService: Credentials ready for '$broadcastTitle'.");
      return {
        'url': ingestionInfo?.ingestionAddress ?? 'rtmp://a.rtmp.youtube.com/live2',
        'key': ingestionInfo?.streamName ?? '',
        'title': broadcastTitle ?? 'Swing Live',
      };
    } catch (e) {
      debugPrint("[DEBUG] YouTubeService ERROR during credential fetch: $e");
      return null;
    }
  }

  GoogleSignInAccount? get currentUser => _googleSignIn.currentUser;
  String? get currentBroadcastId => _currentBroadcastId;
}
