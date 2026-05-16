import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';

enum WhipPhase { idle, acquiring, ready, connecting, live, failed }

/// Publishes the phone camera + mic to a self-hosted media server via WHIP
/// (WebRTC-HTTP Ingestion). Lives independently from the Pedro/RTMP path
/// used by the YouTube broadcast flow. Same MediaMTX server, port 8889.
class WhipPublisher extends ChangeNotifier {
  WhipPhase _phase = WhipPhase.idle;
  String? _error;
  MediaStream? _local;
  RTCPeerConnection? _pc;
  String? _resourceUrl; // returned by WHIP server for DELETE on stop

  WhipPhase get phase => _phase;
  String? get error => _error;
  MediaStream? get localStream => _local;

  // Capture settings — set via prepareCamera, reused by start() for the
  // bitrate calculation.
  int _captureWidth = 1280;
  int _captureHeight = 720;
  int _captureFps = 30;

  /// Acquire camera + mic so we can show a preview and request permissions
  /// up front — without yet opening a peer connection. Phase goes
  /// idle → acquiring → ready. The PC is opened later by [start].
  ///
  /// [width] / [height] are the *landscape-orientation* dimensions; the
  /// caller passes them in landscape order and the OS rotates per the
  /// device's current orientation lock.
  Future<void> prepareCamera({
    bool frontCamera = false,
    int width = 1280,
    int height = 720,
    int fps = 30,
  }) async {
    _error = null;
    await _releaseLocal();
    _setPhase(WhipPhase.acquiring);

    final cam = await Permission.camera.request();
    final mic = await Permission.microphone.request();
    if (!cam.isGranted || !mic.isGranted) {
      _fail('Camera and microphone permissions are required.');
      return;
    }

    _captureWidth = width;
    _captureHeight = height;
    _captureFps = fps;

    try {
      _local = await navigator.mediaDevices.getUserMedia({
        'audio': true,
        'video': {
          'facingMode': frontCamera ? 'user' : 'environment',
          'width': {'ideal': width, 'max': width},
          'height': {'ideal': height, 'max': height},
          'frameRate': {'ideal': fps, 'max': fps},
        },
      });
    } catch (e) {
      _fail('Failed to open camera: $e');
      return;
    }
    _setPhase(WhipPhase.ready);
  }

  /// Open the peer connection and POST the WHIP offer. Assumes
  /// [prepareCamera] has already run; if not, acquires the camera first.
  /// Phase transitions to `live` once the ICE state hits connected.
  Future<void> start({
    required String server,
    required String key,
    bool frontCamera = false,
  }) async {
    _error = null;
    if (_local == null) {
      await prepareCamera(frontCamera: frontCamera);
      if (_phase == WhipPhase.failed) return;
    }

    // Peer connection.
    _setPhase(WhipPhase.connecting);
    // No STUN/TURN — Swing Studio is a LAN setup, host candidates from
    // the device's interfaces are sufficient. Adding STUN here means any
    // offline / no-internet test waits on a DNS lookup for stun.l.google.com
    // that never resolves and the WHIP handshake throws ClientException.
    final pc = await createPeerConnection({
      'iceServers': const <Map<String, dynamic>>[],
      'sdpSemantics': 'unified-plan',
    });
    _pc = pc;

    for (final track in _local!.getTracks()) {
      await pc.addTrack(track, _local!);
    }

    // Lift the per-encoder bitrate cap. WebRTC's default for VP8 starts
    // around 300 kbps which looks awful and stalls the encoder under
    // motion. Scale by resolution × framerate so 1080p60 actually has
    // headroom (~8 Mbps) while 480p30 doesn't waste bandwidth.
    final bitrate = _recommendedBitrate(
      _captureWidth, _captureHeight, _captureFps,
    );
    for (final sender in await pc.getSenders()) {
      if (sender.track?.kind != 'video') continue;
      try {
        final params = sender.parameters;
        params.encodings ??= [];
        if (params.encodings!.isEmpty) {
          params.encodings!.add(RTCRtpEncoding(maxBitrate: bitrate));
        } else {
          for (final enc in params.encodings!) {
            enc.maxBitrate = bitrate;
            enc.maxFramerate = _captureFps;
          }
        }
        params.degradationPreference =
            RTCDegradationPreference.MAINTAIN_RESOLUTION;
        await sender.setParameters(params);
      } catch (e) {
        debugPrint('[WHIP] setParameters failed (non-fatal): $e');
      }
    }

    pc.onConnectionState = (state) {
      switch (state) {
        case RTCPeerConnectionState.RTCPeerConnectionStateConnected:
          _setPhase(WhipPhase.live);
          break;
        case RTCPeerConnectionState.RTCPeerConnectionStateFailed:
        case RTCPeerConnectionState.RTCPeerConnectionStateDisconnected:
        case RTCPeerConnectionState.RTCPeerConnectionStateClosed:
          if (_phase == WhipPhase.live ||
              _phase == WhipPhase.connecting) {
            _fail('Connection lost');
          }
          break;
        default:
          break;
      }
    };

    // WHIP exchange: POST our SDP offer, receive answer.
    try {
      final offer = await pc.createOffer({});
      // Reorder PTs so H.264 is the first video codec the server picks.
      // Android's hardware H.264 encoder is far more efficient than VP8.
      final h264Sdp = _preferCodec(offer.sdp ?? '', 'H264');
      // Add b=AS: lines so any SFU that honours session-level bandwidth
      // (MediaMTX does for relayed feeds) lifts its own cap too.
      final mungedSdp = _setMaxBandwidth(
        h264Sdp,
        videoKbps: (bitrate / 1000).round(),
      );
      final mungedOffer = RTCSessionDescription(mungedSdp, offer.type);
      await pc.setLocalDescription(mungedOffer);

      final url = _whipUrl(server, key);
      final res = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/sdp'},
        body: mungedSdp,
      );
      if (res.statusCode < 200 || res.statusCode >= 300) {
        debugPrint('[WHIP] offer SDP first 200 chars:\n'
            '${mungedSdp.length > 200 ? mungedSdp.substring(0, 200) : mungedSdp}');
        debugPrint('[WHIP] server body: ${res.body}');
        throw 'HTTP ${res.statusCode}: ${res.body}';
      }
      _resourceUrl = res.headers['location'];
      // MediaMTX sometimes returns a relative Location; normalize.
      if (_resourceUrl != null && !_resourceUrl!.startsWith('http')) {
        final base = Uri.parse(url);
        _resourceUrl = base.resolve(_resourceUrl!).toString();
      }

      await pc.setRemoteDescription(
        RTCSessionDescription(res.body, 'answer'),
      );
    } catch (e) {
      _fail('WHIP handshake failed: $e');
    }
  }

  /// Stop publishing. The camera and local preview are kept alive so the
  /// user can still see themselves and can re-publish without re-acquiring.
  /// Call [releaseCamera] for full teardown.
  Future<void> stop() async {
    // Best-effort DELETE on the WHIP resource so MediaMTX tears down server
    // side immediately instead of waiting for ICE timeout.
    final res = _resourceUrl;
    if (res != null) {
      try {
        await http
            .delete(Uri.parse(res))
            .timeout(const Duration(seconds: 2));
      } catch (_) {}
    }
    _resourceUrl = null;

    try { await _pc?.close(); } catch (_) {}
    _pc = null;

    _setPhase(_local != null ? WhipPhase.ready : WhipPhase.idle);
  }

  /// Tear down everything: stop publishing AND release the camera. Call on
  /// page dispose, orientation change, or camera flip.
  Future<void> releaseCamera() async {
    await stop();
    await _releaseLocal();
    _setPhase(WhipPhase.idle);
  }

  Future<void> _releaseLocal() async {
    final local = _local;
    _local = null;
    if (local != null) {
      for (final t in local.getTracks()) {
        try { await t.stop(); } catch (_) {}
      }
      try { await local.dispose(); } catch (_) {}
    }
  }

  /// Bitrate budget keyed off resolution × framerate. Matches YouTube
  /// Live's recommended ranges. Phone HW encoders will downscale
  /// silently if they can't keep up — but giving them headroom yields
  /// noticeably crisper output at the chosen size.
  static int _recommendedBitrate(int w, int h, int fps) {
    final pixels = w * h;
    if (pixels >= 3840 * 2160) {
      if (fps >= 120) return 40_000_000;
      if (fps >= 60)  return 25_000_000;
      return 15_000_000;
    }
    if (pixels >= 2560 * 1440) {
      if (fps >= 120) return 20_000_000;
      if (fps >= 60)  return 14_000_000;
      return 8_000_000;
    }
    if (pixels >= 1920 * 1080) {
      if (fps >= 120) return 12_000_000;
      if (fps >= 60)  return 9_000_000;
      return 5_500_000;
    }
    if (pixels >= 1280 * 720) {
      if (fps >= 120) return 6_000_000;
      if (fps >= 60)  return 4_500_000;
      return 3_000_000;
    }
    return 1_800_000;
  }

  /// Inject `b=AS:<kbps>` right after the video m-line. Some encoders and
  /// most SFUs only honour explicit session bandwidth — without this they
  /// default to ~300 kbps for VP8 which is unwatchable for sport.
  static String _setMaxBandwidth(String sdp, {required int videoKbps}) {
    final lines = sdp.split(RegExp(r'\r\n|\n'));
    // Drop the trailing empty entry that split leaves when the SDP ends
    // with CRLF (which it always does). Otherwise we end up with a double
    // trailing CRLF that strict parsers reject.
    while (lines.isNotEmpty && lines.last.isEmpty) {
      lines.removeLast();
    }
    final out = <String>[];
    var inVideo = false;
    var bandwidthAdded = false;
    for (final line in lines) {
      if (line.startsWith('m=')) {
        inVideo = line.startsWith('m=video');
        bandwidthAdded = false;
        out.add(line);
        continue;
      }
      // Replace any existing b= in the video section.
      if (inVideo && line.startsWith('b=')) continue;

      out.add(line);
      // Spec order inside a media section: m=, i=, c=, b=, k=, a=*.
      // Insert b= right after the first c= we see in the video section.
      if (inVideo && !bandwidthAdded && line.startsWith('c=')) {
        out.add('b=AS:$videoKbps');
        bandwidthAdded = true;
      }
    }
    return '${out.join('\r\n')}\r\n';
  }

  /// Reorder the payload-type list on each `m=video` line so PTs whose
  /// `a=rtpmap` codec name matches [mimeName] come first. RTX PTs
  /// (`a=fmtp:<rtx> apt=<primary>`) ride along with their primary so the
  /// browser doesn't reject the SDP. If no PT matches, returns the SDP
  /// unchanged — we fall back to whatever WebRTC offered (typically VP8).
  static String _preferCodec(String sdp, String mimeName) {
    final lines = sdp.split(RegExp(r'\r\n|\n'));
    while (lines.isNotEmpty && lines.last.isEmpty) {
      lines.removeLast();
    }
    final wanted = mimeName.toLowerCase();

    // First pass: build PT → codec name and RTX PT → primary PT maps,
    // scoped per video m-section. Since PT numbers can repeat across
    // different m= sections we scan each section independently.
    final mIndices = <int>[];
    for (var i = 0; i < lines.length; i++) {
      if (lines[i].startsWith('m=video')) mIndices.add(i);
    }
    if (mIndices.isEmpty) return sdp;

    final rtpmap = RegExp(r'^a=rtpmap:(\d+)\s+([^/]+)/');
    final fmtpApt = RegExp(r'^a=fmtp:(\d+)\s+.*\bapt=(\d+)');

    var changed = false;
    for (var mi = 0; mi < mIndices.length; mi++) {
      final start = mIndices[mi];
      final end = (mi + 1 < mIndices.length) ? mIndices[mi + 1] : lines.length;

      // Stop at next m= even if it's not video — section is [start, sectionEnd).
      var sectionEnd = end;
      for (var i = start + 1; i < end; i++) {
        if (lines[i].startsWith('m=')) {
          sectionEnd = i;
          break;
        }
      }

      final ptToCodec = <String, String>{};
      final rtxToPrimary = <String, String>{};
      for (var i = start + 1; i < sectionEnd; i++) {
        final l = lines[i];
        final rm = rtpmap.firstMatch(l);
        if (rm != null) {
          ptToCodec[rm.group(1)!] = rm.group(2)!.toLowerCase();
          continue;
        }
        final fm = fmtpApt.firstMatch(l);
        if (fm != null) {
          rtxToPrimary[fm.group(1)!] = fm.group(2)!;
        }
      }

      // Parse m= line: "m=video <port> <proto> <pt1> <pt2> ..."
      final parts = lines[start].split(' ');
      if (parts.length <= 3) continue;
      final header = parts.sublist(0, 3);
      final pts = parts.sublist(3);

      // Group RTX PTs alongside their primary.
      final primaryToRtx = <String, List<String>>{};
      final rtxPts = <String>{};
      for (final pt in pts) {
        final primary = rtxToPrimary[pt];
        if (primary != null) {
          primaryToRtx.putIfAbsent(primary, () => []).add(pt);
          rtxPts.add(pt);
        }
      }

      // Iterate primaries in original order, partition by codec match.
      final preferred = <String>[];
      final rest = <String>[];
      for (final pt in pts) {
        if (rtxPts.contains(pt)) continue; // skip — appended with its primary
        final codec = ptToCodec[pt];
        final bucket = (codec == wanted) ? preferred : rest;
        bucket.add(pt);
        final rtxList = primaryToRtx[pt];
        if (rtxList != null) bucket.addAll(rtxList);
      }

      if (preferred.isEmpty) continue; // no match in this section
      final reordered = [...preferred, ...rest];
      // Skip rewrite if order is already correct.
      if (reordered.length == pts.length &&
          List.generate(pts.length, (i) => pts[i] == reordered[i])
              .every((b) => b)) {
        continue;
      }
      lines[start] = [...header, ...reordered].join(' ');
      changed = true;
    }

    if (!changed) return sdp;
    return '${lines.join('\r\n')}\r\n';
  }

  /// Server input is forgiving:
  ///   "192.168.1.3"                 → http://192.168.1.3:8889
  ///   "192.168.1.3:8889"            → http://192.168.1.3:8889
  ///   "http://host:port" or "https" → unchanged
  static String _whipUrl(String server, String key) {
    var s = server.trim();
    if (!s.startsWith('http://') && !s.startsWith('https://')) {
      if (!s.contains(':')) s = '$s:8889';
      s = 'http://$s';
    }
    if (s.endsWith('/')) s = s.substring(0, s.length - 1);
    return '$s/live/$key/whip';
  }

  void _setPhase(WhipPhase p) {
    _phase = p;
    if (_disposed) return;
    notifyListeners();
  }

  void _fail(String reason) {
    debugPrint('[WHIP] $reason');
    _error = reason;
    _setPhase(WhipPhase.failed);
  }

  bool _disposed = false;

  @override
  void dispose() {
    // Flip the flag synchronously so any in-flight async cleanup (the
    // releaseCamera below + any pending peer-connection callbacks) skips
    // notifyListeners and avoids "used after dispose" asserts.
    _disposed = true;
    // Fire-and-forget cleanup. The futures complete after super.dispose
    // returns but the disposed-guard above keeps them quiet.
    releaseCamera();
    super.dispose();
  }
}
