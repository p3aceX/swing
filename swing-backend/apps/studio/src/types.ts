export interface StreamConfig {
  matchId: string;
  youtubeRtmpUrl?: string; // optional: rtmp://a.rtmp.youtube.com/live2/STREAM_KEY
  scene: "standard" | "stats" | "break" | "clean";
  breakType?: "drinks" | "innings" | "powerplay" | null;
}

export interface ActiveStream {
  matchId: string;
  youtubeRtmpUrl?: string;
  status: "starting" | "live" | "stopping" | "error";
  cameraPageUrl: string; // URL to open on phone browser
  wsUrl: string; // WebSocket URL for direct connection
  startedAt: string;
  error?: string;
}

export interface StreamEvent {
  type: "stream_connected" | "stream_disconnected" | "compositor_started" | "compositor_error";
  matchId: string;
  timestamp: string;
  details?: string;
}
