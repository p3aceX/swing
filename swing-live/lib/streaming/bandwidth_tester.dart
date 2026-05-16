import 'dart:math' as math;
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import 'rtmp_engine.dart';

/// Measures upload bandwidth by POSTing a known-size random payload to a
/// public endpoint and timing the round-trip. We use Cloudflare's
/// purpose-built speed-test endpoint — free, fast, no auth, no quota.
///
/// Why upload (not download): YouTube Live cares only about how fast we
/// can push out, and that's almost always the limiting side. Wi-Fi/4G/5G
/// asymmetric links have download >> upload, so a download test would
/// over-promise.
class BandwidthTester {
  static const _endpoint = 'https://speed.cloudflare.com/__up';
  // 2 MB strikes a balance: large enough to be dominated by transit time
  // (not TCP slow-start), small enough to finish under 4 seconds on a
  // weak link before the test feels broken.
  static const _payloadBytes = 2 * 1024 * 1024;

  /// Run an upload test and return Mbps. Throws on HTTP / timeout failure.
  static Future<double> testUploadMbps({
    Duration timeout = const Duration(seconds: 10),
  }) async {
    final payload = Uint8List(_payloadBytes);
    // Fill with non-compressible data so any transparent path compression
    // (cellular gateway proxies sometimes do this) doesn't make the result
    // wildly optimistic.
    final rng = math.Random();
    for (var i = 0; i < _payloadBytes; i++) {
      payload[i] = rng.nextInt(256);
    }

    final sw = Stopwatch()..start();
    final res = await http
        .post(Uri.parse(_endpoint), body: payload)
        .timeout(timeout);
    sw.stop();

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw 'HTTP ${res.statusCode}';
    }
    final ms = sw.elapsedMilliseconds;
    if (ms <= 0) return 0;
    // bits / seconds → Mbps
    return (_payloadBytes * 8) / (ms / 1000.0) / 1_000_000;
  }

  /// Map a measured Mbps to the best preset whose target bitrate has at
  /// least 1.3× headroom over the link — to leave room for B-frame spikes
  /// and brief WiFi/cellular dips.
  static StreamQuality recommendFor(double mbps) {
    final headroomBps = mbps * 1_000_000 / 1.3;
    for (final q in [
      StreamQuality.p1080_60,
      StreamQuality.p1080_30,
      StreamQuality.p720_60,
      StreamQuality.p720_30,
    ]) {
      if (q.bitrate <= headroomBps) return q;
    }
    return StreamQuality.p720_30;
  }
}
