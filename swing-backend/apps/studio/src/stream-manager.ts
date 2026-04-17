import IORedis from "ioredis";
import { config } from "./config";
import { ActiveStream } from "./types";
import { startOverlayCapture, stopOverlayCapture } from "./overlay-capture";
import {
  startCompositor,
  stopCompositor,
  isCompositorRunning,
} from "./compositor";
import { startBridge, stopBridge, shutdownBridges } from "./bridge";

const redis = new IORedis(config.redisUrl, {
  maxRetriesPerRequest: null,
  enableReadyCheck: false,
});

const STREAM_TTL = 28800; // 8 hours
const streamKey = (matchId: string) => `studio:stream:${matchId}`;

const managedStreams = new Map<
  string,
  { youtubeRtmpUrl?: string; status: string }
>();

/**
 * Register a stream to go live.
 * youtubeRtmpUrl is optional — if omitted, only HLS is produced.
 */
export async function registerStream(
  matchId: string,
  youtubeRtmpUrl?: string
): Promise<ActiveStream> {
  const cameraPageUrl = `${config.adminBaseUrl}/admin/stream/${matchId}`;
  const wsUrl = config.wsBaseUrl;

  const stream: ActiveStream = {
    matchId,
    youtubeRtmpUrl,
    status: "starting",
    cameraPageUrl,
    wsUrl,
    startedAt: new Date().toISOString(),
  };

  await redis.setex(streamKey(matchId), STREAM_TTL, JSON.stringify(stream));

  managedStreams.set(matchId, { youtubeRtmpUrl, status: "starting" });

  await startOverlayCapture(matchId);

  console.log(`[manager] Stream registered for match ${matchId}`);
  console.log(`[manager] Camera page: ${cameraPageUrl}`);
  console.log(`[manager] YouTube RTMP: ${youtubeRtmpUrl ?? "none (HLS only)"}`);
  return stream;
}

/**
 * Called when phone browser WebSocket connects.
 */
export async function onPhoneConnected(matchId: string): Promise<void> {
  const managed = managedStreams.get(matchId);
  if (!managed) {
    console.log(`[manager] Phone connected for unregistered match ${matchId} — ignoring`);
    return;
  }

  console.log(`[manager] Phone connected for match ${matchId} — starting compositor`);

  if (isCompositorRunning(matchId)) {
    stopCompositor(matchId);
    await new Promise((r) => setTimeout(r, 1000));
  }

  startCompositor(matchId, async (code, signal) => {
    if (code !== 0 && managedStreams.has(matchId)) {
      console.error(`[manager] Compositor crashed for ${matchId} (code=${code})`);
      await updateStreamStatus(matchId, "error", `FFmpeg exited with code ${code}`);
    }
  });

  // Start YouTube bridge if a RTMP URL was provided
  if (managed.youtubeRtmpUrl) {
    startBridge(matchId, managed.youtubeRtmpUrl);
  }

  await updateStreamStatus(matchId, "live");
}

/**
 * Called when phone browser WebSocket disconnects.
 */
export async function onPhoneDisconnected(matchId: string): Promise<void> {
  const managed = managedStreams.get(matchId);
  if (!managed) return;

  console.log(`[manager] Phone disconnected for match ${matchId}`);
  stopBridge(matchId);
  stopCompositor(matchId);
  await updateStreamStatus(matchId, "starting");
}

/**
 * Stop a stream entirely.
 */
export async function stopStream(matchId: string): Promise<void> {
  console.log(`[manager] Stopping stream for match ${matchId}`);

  stopBridge(matchId);
  stopCompositor(matchId);
  await stopOverlayCapture(matchId);
  managedStreams.delete(matchId);
  await redis.del(streamKey(matchId));

  console.log(`[manager] Stream fully stopped for match ${matchId}`);
}

export async function getStream(matchId: string): Promise<ActiveStream | null> {
  const data = await redis.get(streamKey(matchId));
  if (!data) return null;
  try {
    return JSON.parse(data);
  } catch {
    return null;
  }
}

export async function listStreams(): Promise<ActiveStream[]> {
  const keys = await redis.keys("studio:stream:*");
  if (keys.length === 0) return [];

  const pipeline = redis.pipeline();
  for (const key of keys) pipeline.get(key);
  const results = await pipeline.exec();
  if (!results) return [];

  const streams: ActiveStream[] = [];
  for (const [err, val] of results) {
    if (!err && val) {
      try { streams.push(JSON.parse(val as string)); } catch {}
    }
  }
  return streams;
}

async function updateStreamStatus(matchId: string, status: string, error?: string): Promise<void> {
  const stream = await getStream(matchId);
  if (!stream) return;

  stream.status = status as ActiveStream["status"];
  if (error) stream.error = error;

  await redis.setex(streamKey(matchId), STREAM_TTL, JSON.stringify(stream));

  const managed = managedStreams.get(matchId);
  if (managed) managed.status = status;
}

export async function shutdownStreamManager(): Promise<void> {
  for (const [matchId] of managedStreams) {
    await stopStream(matchId);
  }
  shutdownBridges();
  await redis.quit();
}
