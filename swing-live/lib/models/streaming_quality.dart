enum StreamingQuality {
  standard720p30(
    label: "720p 30fps",
    width: 1280,
    height: 720,
    bitrate: 2500 * 1000,
    fps: 30,
  ),
  high1080p30(
    label: "1080p 30fps",
    width: 1920,
    height: 1080,
    bitrate: 5000 * 1000,
    fps: 30,
  ),
  ultra1080p60(
    label: "1080p 60fps",
    width: 1920,
    height: 1080,
    bitrate: 8000 * 1000,
    fps: 60,
  ),
  premium1440p(
    label: "1440p 30fps",
    width: 2560,
    height: 1440,
    bitrate: 10000 * 1000,
    fps: 30,
  );

  final String label;
  final int width;
  final int height;
  final int bitrate;
  final int fps;

  const StreamingQuality({
    required this.label,
    required this.width,
    required this.height,
    required this.bitrate,
    required this.fps,
  });
}
