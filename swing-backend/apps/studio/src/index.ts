import express from "express";
import cors from "cors";
import path from "path";
import { z } from "zod";
import { config } from "./config";
import { startWsServer, stopWsServer } from "./ws-server";
import {
  registerStream,
  stopStream,
  getStream,
  listStreams,
  onPhoneConnected,
  onPhoneDisconnected,
  shutdownStreamManager,
} from "./stream-manager";
import { shutdownOverlayCapture } from "./overlay-capture";
import { shutdownCompositors } from "./compositor";

const app = express();
app.use(cors());
app.use(express.json());

// ─── Serve HLS segments ──────────────────────────────────────
// FFmpeg writes HLS segments to /tmp/streams/{matchId}/
// Clients (via Cloud Run proxy) fetch them here.
app.use("/hls", (req, res, next) => {
  res.setHeader("Access-Control-Allow-Origin", "*");
  res.setHeader("Cache-Control", "no-cache");
  next();
}, express.static("/tmp/streams"));

// ─── Health check ────────────────────────────────────────────
app.get("/health", (_req, res) => {
  res.json({ status: "ok", service: "swing-studio", uptime: process.uptime() });
});

// ─── Start a stream ──────────────────────────────────────────
const startSchema = z.object({
  matchId: z.string().min(1),
  youtubeRtmpUrl: z.string().startsWith("rtmp").optional(),
});

app.post("/streams/start", async (req, res) => {
  try {
    const body = startSchema.parse(req.body);

    const existing = await getStream(body.matchId);
    if (existing && existing.status !== "error") {
      return res.status(409).json({
        success: false,
        error: "Stream already active for this match",
        data: existing,
      });
    }

    const stream = await registerStream(body.matchId, body.youtubeRtmpUrl);

    res.json({
      success: true,
      data: stream,
      message: `Stream registered. Open the camera page on your phone: ${stream.cameraPageUrl}`,
    });
  } catch (err: any) {
    if (err instanceof z.ZodError) {
      return res.status(400).json({ success: false, error: err.errors });
    }
    console.error("[api] Error starting stream:", err);
    res.status(500).json({ success: false, error: err.message });
  }
});

// ─── Stop a stream ───────────────────────────────────────────
const stopSchema = z.object({ matchId: z.string().min(1) });

app.post("/streams/stop", async (req, res) => {
  try {
    const body = stopSchema.parse(req.body);
    await stopStream(body.matchId);
    res.json({ success: true, message: "Stream stopped" });
  } catch (err: any) {
    if (err instanceof z.ZodError) {
      return res.status(400).json({ success: false, error: err.errors });
    }
    console.error("[api] Error stopping stream:", err);
    res.status(500).json({ success: false, error: err.message });
  }
});

// ─── Get stream status ──────────────────────────────────────
app.get("/streams/:matchId", async (req, res) => {
  try {
    const stream = await getStream(req.params.matchId);
    if (!stream) {
      return res.status(404).json({ success: false, error: "No active stream" });
    }
    res.json({ success: true, data: stream });
  } catch (err: any) {
    res.status(500).json({ success: false, error: err.message });
  }
});

// ─── List all active streams ─────────────────────────────────
app.get("/streams", async (_req, res) => {
  try {
    const streams = await listStreams();
    res.json({ success: true, data: streams });
  } catch (err: any) {
    res.status(500).json({ success: false, error: err.message });
  }
});

// ─── Start everything ────────────────────────────────────────
async function main() {
  const server = app.listen(config.port, () => {
    console.log(`\n=== Swing Studio Service ===`);
    console.log(`API + WebSocket: http://0.0.0.0:${config.port}`);
    console.log(`HLS segments:    http://0.0.0.0:${config.port}/hls/{matchId}/index.m3u8`);
    console.log(`WS base URL:     ${config.wsBaseUrl}`);
    console.log(`============================\n`);
  });

  startWsServer(
    (matchId) => onPhoneConnected(matchId),
    (matchId) => onPhoneDisconnected(matchId),
    server
  );
}

// ─── Graceful shutdown ───────────────────────────────────────
async function shutdown() {
  console.log("\n[studio] Shutting down...");
  shutdownCompositors();
  await shutdownOverlayCapture();
  await shutdownStreamManager();
  stopWsServer();
  process.exit(0);
}

process.on("SIGINT", shutdown);
process.on("SIGTERM", shutdown);

main().catch((err) => {
  console.error("[studio] Fatal error:", err);
  process.exit(1);
});
