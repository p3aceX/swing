import { spawn, ChildProcess } from "child_process";
import fs from "fs";
import { config } from "./config";
import { getOverlayPath } from "./overlay-capture";
import { setCompositorStdin, removeCompositorStdin, sendToClient } from "./ws-server";

const activeProcesses = new Map<string, ChildProcess>();

/**
 * Start FFmpeg compositor for a match.
 *
 * Reads video from stdin (WebSocket chunks piped in by ws-server),
 * overlays the PNG screenshot, and outputs HLS segments only.
 * YouTube RTMP is handled separately by the bridge (bridge.ts).
 *
 * Pipeline:
 *   Phone browser → WebSocket → stdin pipe → FFmpeg → overlay → HLS
 */
export function startCompositor(
  matchId: string,
  onExit: (code: number | null, signal: string | null) => void
): void {
  if (activeProcesses.has(matchId)) {
    console.log(`[compositor] Already running for match ${matchId}`);
    return;
  }

  const overlayPath = getOverlayPath(matchId);
  const hlsDir = `/tmp/streams/${matchId}`;
  const hlsPath = `${hlsDir}/index.m3u8`;

  // Ensure HLS output directory exists
  fs.mkdirSync(hlsDir, { recursive: true });

  const filterComplex = [
    "[1:v]scale=iw:ih:force_original_aspect_ratio=disable,format=rgba[ovr]",
    "[0:v][ovr]overlay=0:0:shortest=0:eof_action=repeat[out]",
  ].join(";");

  const args = [
    // Input 0: webm from phone camera via stdin
    "-f", "webm", "-i", "pipe:0",
    // Input 1: overlay PNG (loops)
    "-stream_loop", "-1", "-framerate", "2", "-i", overlayPath,
    // Filter
    "-filter_complex", filterComplex,
    // HLS output
    "-map", "[out]", "-map", "0:a?",
    "-c:v", "libx264",
    "-preset", config.preset,
    "-tune", "zerolatency",
    "-b:v", config.videoBitrate,
    "-maxrate", config.videoBitrate,
    "-bufsize", `${parseInt(config.videoBitrate) * 2}k`,
    "-g", "60",
    "-keyint_min", "60",
    "-c:a", "aac",
    "-b:a", config.audioBitrate,
    "-ar", "44100",
    "-f", "hls",
    "-hls_time", "2",
    "-hls_list_size", "5",
    "-hls_flags", "delete_segments+append_list",
    hlsPath,
  ];

  console.log(`[compositor] Starting FFmpeg for match ${matchId}`);
  console.log(`[compositor] HLS output: ${hlsPath}`);

  const ffmpeg = spawn(config.ffmpegPath, args, {
    stdio: ["pipe", "pipe", "pipe"],
  });

  if (ffmpeg.stdin) {
    setCompositorStdin(matchId, ffmpeg.stdin);
  }

  sendToClient(matchId, { type: "compositor_ready" });

  ffmpeg.stderr?.on("data", (data: Buffer) => {
    console.log(`[ffmpeg:${matchId}] ${data.toString().trim()}`);
  });

  ffmpeg.on("error", (err) => {
    console.error(`[compositor] FFmpeg spawn error for ${matchId}:`, err);
    removeCompositorStdin(matchId);
    activeProcesses.delete(matchId);
    sendToClient(matchId, { type: "error", message: "Compositor failed to start" });
    onExit(null, null);
  });

  ffmpeg.on("exit", (code, signal) => {
    console.log(`[compositor] FFmpeg exited for ${matchId} — code=${code} signal=${signal}`);
    removeCompositorStdin(matchId);
    activeProcesses.delete(matchId);
    onExit(code, signal);
  });

  activeProcesses.set(matchId, ffmpeg);
}

/**
 * Stop FFmpeg compositor for a match.
 */
export function stopCompositor(matchId: string): void {
  const proc = activeProcesses.get(matchId);
  if (!proc) return;

  console.log(`[compositor] Stopping FFmpeg for match ${matchId}`);
  removeCompositorStdin(matchId);

  try { proc.stdin?.end(); } catch {}
  setTimeout(() => {
    if (activeProcesses.has(matchId)) {
      proc.kill("SIGKILL");
      activeProcesses.delete(matchId);
    }
  }, 5000);
}

export function isCompositorRunning(matchId: string): boolean {
  return activeProcesses.has(matchId);
}

export function shutdownCompositors(): void {
  for (const [matchId, proc] of activeProcesses) {
    console.log(`[compositor] Killing FFmpeg for ${matchId}`);
    removeCompositorStdin(matchId);
    proc.kill("SIGKILL");
  }
  activeProcesses.clear();
}
