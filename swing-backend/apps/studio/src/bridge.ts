import { spawn, ChildProcess } from "child_process";
import fs from "fs";
import { config } from "./config";

const activeBridges = new Map<string, ChildProcess>();
const bridgeTimers = new Map<string, NodeJS.Timeout>();

const HLS_POLL_INTERVAL_MS = 1000;
const HLS_MAX_WAIT_MS = 30_000; // wait up to 30s for HLS to appear
const BRIDGE_RESTART_DELAY_MS = 5000;

/**
 * Start a YouTube bridge for a match.
 *
 * Waits for HLS segments to appear, then spawns a second FFmpeg process
 * that reads the local HLS playlist and re-streams to YouTube via RTMP.
 *
 * This is the "FFmpeg bridge" approach: compositor → HLS → bridge → RTMP.
 * The compositor only handles compositing + HLS; RTMP is fully decoupled.
 */
export function startBridge(matchId: string, youtubeRtmpUrl: string): void {
  if (activeBridges.has(matchId)) {
    console.log(`[bridge] Already running for match ${matchId}`);
    return;
  }

  console.log(`[bridge] Will start YouTube bridge for match ${matchId} once HLS is ready`);
  restartEnabled.add(matchId);

  const hlsPath = `/tmp/streams/${matchId}/index.m3u8`;
  const hlsUrl = `http://localhost:${config.port}/hls/${matchId}/index.m3u8`;

  // Mark as pending so stopBridge knows there's a timer in flight
  bridgeTimers.set(matchId, null as any);

  waitForHls(matchId, hlsPath, HLS_MAX_WAIT_MS, () => {
    if (!bridgeTimers.has(matchId) && !activeBridges.has(matchId)) {
      // Bridge was stopped before HLS appeared — abort
      return;
    }
    // Clear the "pending" marker
    bridgeTimers.delete(matchId);
    spawnBridge(matchId, hlsUrl, youtubeRtmpUrl);
  });
}

function waitForHls(matchId: string, hlsPath: string, remainingMs: number, onReady: () => void): void {
  if (fs.existsSync(hlsPath)) {
    onReady();
    return;
  }
  if (remainingMs <= 0) {
    console.warn(`[bridge] HLS never appeared at ${hlsPath} — bridge not started`);
    bridgeTimers.delete(matchId);
    return;
  }
  const timer = setTimeout(
    () => waitForHls(matchId, hlsPath, remainingMs - HLS_POLL_INTERVAL_MS, onReady),
    HLS_POLL_INTERVAL_MS
  );
  // Use bridgeTimers to track the pending wait (so stopBridge can cancel it)
  bridgeTimers.set(matchId, timer);
}

function spawnBridge(matchId: string, hlsUrl: string, youtubeRtmpUrl: string): void {
  if (activeBridges.has(matchId)) return;

  console.log(`[bridge] Starting FFmpeg bridge for match ${matchId}`);
  console.log(`[bridge] HLS source: ${hlsUrl}`);
  console.log(`[bridge] RTMP target: ${youtubeRtmpUrl.replace(/\/[^/]+$/, "/<key>")}`);

  // Stream copy — no re-encode. HLS is already H.264+AAC from the compositor.
  // Just remux into FLV/RTMP. This avoids double-encode CPU cost.
  const args = [
    "-re",
    "-i", hlsUrl,
    "-c:v", "copy",
    "-c:a", "copy",
    "-f", "flv",
    "-flvflags", "no_duration_filesize",
    youtubeRtmpUrl,
  ];

  const ffmpeg = spawn(config.ffmpegPath, args, {
    stdio: ["ignore", "pipe", "pipe"],
  });

  activeBridges.set(matchId, ffmpeg);

  ffmpeg.stderr?.on("data", (data: Buffer) => {
    console.log(`[bridge:${matchId}] ${data.toString().trim()}`);
  });

  ffmpeg.on("error", (err) => {
    console.error(`[bridge] Spawn error for ${matchId}:`, err);
    activeBridges.delete(matchId);
    scheduleRestart(matchId, hlsUrl, youtubeRtmpUrl);
  });

  ffmpeg.on("exit", (code, signal) => {
    console.log(`[bridge] FFmpeg exited for ${matchId} — code=${code} signal=${signal}`);
    activeBridges.delete(matchId);
    if (signal !== "SIGKILL" && signal !== "SIGTERM") {
      scheduleRestart(matchId, hlsUrl, youtubeRtmpUrl);
    }
  });
}

// Restart tracker: matchId present means auto-restart is desired
const restartEnabled = new Set<string>();

function scheduleRestart(matchId: string, hlsUrl: string, youtubeRtmpUrl: string): void {
  // Don't restart if stopBridge was called (restartEnabled was cleared)
  if (!restartEnabled.has(matchId)) return;

  console.log(`[bridge] Restarting bridge for ${matchId} in ${BRIDGE_RESTART_DELAY_MS}ms`);
  const timer = setTimeout(() => {
    bridgeTimers.delete(matchId);
    spawnBridge(matchId, hlsUrl, youtubeRtmpUrl);
  }, BRIDGE_RESTART_DELAY_MS);
  bridgeTimers.set(matchId, timer);
}

/**
 * Stop the YouTube bridge for a match.
 */
export function stopBridge(matchId: string): void {
  // Cancel any pending wait/restart timer
  const timer = bridgeTimers.get(matchId);
  if (timer) {
    clearTimeout(timer);
    bridgeTimers.delete(matchId);
  }

  restartEnabled.delete(matchId);

  const proc = activeBridges.get(matchId);
  if (!proc) return;

  console.log(`[bridge] Stopping YouTube bridge for match ${matchId}`);
  proc.kill("SIGTERM");
  setTimeout(() => {
    if (activeBridges.has(matchId)) {
      proc.kill("SIGKILL");
      activeBridges.delete(matchId);
    }
  }, 3000);
}

export function isBridgeRunning(matchId: string): boolean {
  return activeBridges.has(matchId);
}

export function shutdownBridges(): void {
  for (const [matchId] of activeBridges) {
    console.log(`[bridge] Killing bridge for ${matchId}`);
    activeBridges.get(matchId)?.kill("SIGKILL");
  }
  activeBridges.clear();
  for (const timer of bridgeTimers.values()) clearTimeout(timer);
  bridgeTimers.clear();
  restartEnabled.clear();
}
