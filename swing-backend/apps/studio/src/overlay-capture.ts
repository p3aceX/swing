import puppeteer, { Browser, Page } from "puppeteer";
import { config } from "./config";
import * as fs from "fs";
import * as path from "path";

const TMP_DIR = "/tmp/studio-overlays";

// Ensure temp directory exists
if (!fs.existsSync(TMP_DIR)) {
  fs.mkdirSync(TMP_DIR, { recursive: true });
}

let browser: Browser | null = null;
const activeCaptures = new Map<
  string,
  { page: Page; interval: NodeJS.Timeout }
>();

async function getBrowser(): Promise<Browser> {
  if (!browser || !browser.connected) {
    browser = await puppeteer.launch({
      headless: true,
      args: [
        "--no-sandbox",
        "--disable-setuid-sandbox",
        "--disable-dev-shm-usage",
        "--disable-gpu",
        "--single-process",
      ],
    });
  }
  return browser;
}

/**
 * Returns the file path for a match's overlay PNG.
 * FFmpeg reads this file continuously — we do atomic writes to avoid tearing.
 */
export function getOverlayPath(matchId: string): string {
  return path.join(TMP_DIR, `overlay-${matchId}.png`);
}

/**
 * Start capturing overlay screenshots for a match.
 * Opens the overlay widget in a headless browser and takes periodic screenshots.
 */
export async function startOverlayCapture(matchId: string): Promise<void> {
  if (activeCaptures.has(matchId)) {
    console.log(`[overlay] Capture already running for match ${matchId}`);
    return;
  }

  const b = await getBrowser();
  const page = await b.newPage();

  // Set viewport to match overlay resolution
  await page.setViewport({
    width: config.overlayWidth,
    height: config.overlayHeight,
  });

  // Navigate to overlay widget
  const widgetUrl = `${config.apiBaseUrl}/public/overlay/${matchId}/widget?view=standard`;
  console.log(`[overlay] Opening widget: ${widgetUrl}`);
  await page.goto(widgetUrl, { waitUntil: "networkidle2", timeout: 30000 });

  // Wait for initial render
  await new Promise((r) => setTimeout(r, 2000));

  const overlayPath = getOverlayPath(matchId);
  const tmpPath = `${overlayPath}.tmp`;

  // Take initial screenshot
  await captureFrame(page, overlayPath, tmpPath);

  // Start periodic capture
  const interval = setInterval(async () => {
    try {
      await captureFrame(page, overlayPath, tmpPath);
    } catch (err) {
      console.error(`[overlay] Screenshot error for match ${matchId}:`, err);
    }
  }, config.overlayCaptureIntervalMs);

  activeCaptures.set(matchId, { page, interval });
  console.log(
    `[overlay] Capture started for match ${matchId} (every ${config.overlayCaptureIntervalMs}ms)`
  );
}

/**
 * Atomic screenshot: write to .tmp then rename, avoiding FFmpeg reading a partial file.
 */
async function captureFrame(
  page: Page,
  targetPath: string,
  tmpPath: string
): Promise<void> {
  await page.screenshot({
    path: tmpPath,
    type: "png",
    omitBackground: true, // transparent background for overlay
  });
  fs.renameSync(tmpPath, targetPath);
}

/**
 * Stop overlay capture for a match.
 */
export async function stopOverlayCapture(matchId: string): Promise<void> {
  const capture = activeCaptures.get(matchId);
  if (!capture) return;

  clearInterval(capture.interval);
  try {
    await capture.page.close();
  } catch {}
  activeCaptures.delete(matchId);

  // Clean up temp files
  const overlayPath = getOverlayPath(matchId);
  try {
    fs.unlinkSync(overlayPath);
  } catch {}
  try {
    fs.unlinkSync(`${overlayPath}.tmp`);
  } catch {}

  console.log(`[overlay] Capture stopped for match ${matchId}`);
}

/**
 * Cleanup all captures and browser on shutdown.
 */
export async function shutdownOverlayCapture(): Promise<void> {
  for (const [matchId] of activeCaptures) {
    await stopOverlayCapture(matchId);
  }
  if (browser) {
    try {
      await browser.close();
    } catch {}
    browser = null;
  }
}
