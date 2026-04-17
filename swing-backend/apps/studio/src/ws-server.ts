import { WebSocketServer, WebSocket } from "ws";
import { IncomingMessage, Server } from "http";
import { Writable } from "stream";

type StreamCallback = (matchId: string) => void;

let wss: WebSocketServer | null = null;

// Map of matchId → connected WebSocket client
const clients = new Map<string, WebSocket>();

// Map of matchId → FFmpeg stdin writable (set by compositor)
const stdinStreams = new Map<string, Writable>();

// Buffer for binary chunks that arrive before FFmpeg stdin is ready.
// Flushed immediately when setCompositorStdin is called.
const pendingBuffers = new Map<string, Buffer[]>();

/**
 * Start WebSocket server attached to the existing HTTP server.
 * WS and HTTP share the same port — no separate port needed.
 *
 * Phone browser connects to: ws(s)://<studio-host>/
 * First message is JSON handshake: { type: "join", matchId: "xxx" }
 * Subsequent binary messages are webm video chunks from MediaRecorder.
 */
export function startWsServer(
  onConnect: StreamCallback,
  onDisconnect: StreamCallback,
  httpServer: Server
): void {
  wss = new WebSocketServer({ server: httpServer });

  wss.on("connection", (ws) => {
    let matchId: string | null = null;

    ws.on("message", (data, isBinary) => {
      // First message: JSON handshake
      if (!matchId) {
        try {
          const msg = JSON.parse(data.toString());
          if (msg.type === "join" && msg.matchId) {
            matchId = msg.matchId;

            // Close existing connection for this match if any
            const existing = clients.get(matchId);
            if (existing && existing.readyState === WebSocket.OPEN) {
              existing.close(1000, "replaced");
            }

            clients.set(matchId, ws);
            console.log(`[ws] Camera connected for match ${matchId}`);

            // Send confirmation
            ws.send(JSON.stringify({ type: "joined", matchId }));

            // Notify stream manager
            onConnect(matchId);
          } else {
            ws.send(JSON.stringify({ type: "error", message: "Send { type: 'join', matchId: '...' } first" }));
          }
        } catch {
          ws.send(JSON.stringify({ type: "error", message: "Invalid handshake" }));
        }
        return;
      }

      // Binary messages: video chunks → pipe to FFmpeg stdin
      if (isBinary) {
        const stdin = stdinStreams.get(matchId);
        if (stdin && !stdin.destroyed) {
          stdin.write(data as Buffer, (err) => {
            if (err) console.warn(`[ws] stdin write error for ${matchId}: ${err.message}`);
          });
        } else {
          // FFmpeg not ready yet — buffer the chunk so the EBML header
          // and codec init data aren't lost before compositor starts
          const buf = pendingBuffers.get(matchId) ?? [];
          buf.push(data as Buffer);
          pendingBuffers.set(matchId, buf);
        }
      }
    });

    ws.on("close", () => {
      if (matchId) {
        console.log(`[ws] Camera disconnected for match ${matchId}`);
        clients.delete(matchId);
        pendingBuffers.delete(matchId);
        onDisconnect(matchId);
      }
    });

    ws.on("error", (err) => {
      console.error(`[ws] Error for match ${matchId}:`, err.message);
      if (matchId) {
        clients.delete(matchId);
        pendingBuffers.delete(matchId);
        onDisconnect(matchId);
      }
    });

    // Ping every 30s to detect dead connections
    const pingInterval = setInterval(() => {
      if (ws.readyState === WebSocket.OPEN) {
        ws.ping();
      } else {
        clearInterval(pingInterval);
      }
    }, 30000);

    ws.on("close", () => clearInterval(pingInterval));
  });

  console.log(`[ws] WebSocket camera server attached to HTTP server`);
}

/**
 * Register FFmpeg stdin for a match so incoming video chunks can be piped to it.
 * Flushes any chunks that arrived before FFmpeg was ready.
 */
export function setCompositorStdin(matchId: string, stdin: Writable): void {
  // Prevent unhandled EPIPE from crashing the process when FFmpeg exits
  stdin.on("error", (err) => {
    console.warn(`[ws] FFmpeg stdin error for ${matchId}: ${err.message}`);
  });
  stdinStreams.set(matchId, stdin);

  // Flush buffered chunks (EBML header + early frames) to FFmpeg stdin
  const buffered = pendingBuffers.get(matchId);
  if (buffered?.length) {
    console.log(`[ws] Flushing ${buffered.length} buffered chunks to FFmpeg for match ${matchId}`);
    for (const chunk of buffered) {
      if (!stdin.destroyed) stdin.write(chunk);
    }
    pendingBuffers.delete(matchId);
  }
}

/**
 * Remove FFmpeg stdin for a match.
 */
export function removeCompositorStdin(matchId: string): void {
  stdinStreams.delete(matchId);
}

/**
 * Send a message to the phone browser for a match.
 */
export function sendToClient(matchId: string, message: any): void {
  const ws = clients.get(matchId);
  if (ws && ws.readyState === WebSocket.OPEN) {
    ws.send(JSON.stringify(message));
  }
}

/**
 * Check if a camera is connected for a match.
 */
export function isCameraConnected(matchId: string): boolean {
  const ws = clients.get(matchId);
  return !!ws && ws.readyState === WebSocket.OPEN;
}

/**
 * Stop WebSocket server.
 */
export function stopWsServer(): void {
  if (wss) {
    // Close all connections
    for (const [, ws] of clients) {
      ws.close(1000, "server shutdown");
    }
    clients.clear();
    stdinStreams.clear();
    pendingBuffers.clear();
    wss.close();
    wss = null;
  }
}
