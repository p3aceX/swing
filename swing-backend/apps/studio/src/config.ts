export const config = {
  // Studio API
  port: parseInt(process.env.STUDIO_PORT || "4000"),

  // WebSocket server (receives camera from phone browser)
  // WS runs on the same HTTP server (port) — no separate wsPort needed.
  // WS_BASE_URL is used to construct the wsUrl returned to clients.
  // Use ws:// for local dev, wss:// when behind a TLS-terminating reverse proxy.
  wsBaseUrl: process.env.WS_BASE_URL || `ws://localhost:4000`,

  // Redis
  redisUrl: process.env.REDIS_URL || "redis://localhost:6379",

  // Swing API (for overlay widget)
  apiBaseUrl: process.env.API_BASE_URL || "https://api.swingcricket.com",

  // Admin URL (for camera page links)
  adminBaseUrl: process.env.ADMIN_BASE_URL || "https://admin.swingcricketapp.com",

  // FFmpeg
  ffmpegPath: process.env.FFMPEG_PATH || "ffmpeg",

  // Overlay capture
  overlayWidth: 1280,
  overlayHeight: 720,
  overlayCaptureIntervalMs: 3000,

  // Stream defaults — ultrafast preset to keep up with real-time on a single-core VM
  videoBitrate: "1500k",
  audioBitrate: "128k",
  preset: "ultrafast",
  maxStreams: 20, // max concurrent streams per instance
};
