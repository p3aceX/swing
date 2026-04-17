# Studio Implementation Notes — Remaining Tasks

## Current State
- **Studio VM** running at `34.47.234.51` (ports 4000 API, 4001 WebSocket)
- **Camera page** at `/admin/stream/[id]` — shows camera preview but recording doesn't start
- **Studio tab** in match detail page — has Go Live flow with YouTube stream key input
- **Backend** on Cloud Run has proxy routes to Studio VM (`/admin/matches/:id/stream/start|stop`)

## Issues to Fix

### 1. Camera page recording not starting
The camera page at `/admin/stream/[id]` shows the camera preview but clicking record doesn't work because:
- The `useLiveStreamQuery` hook requires authentication (admin session) but the phone browser may not be logged in
- The `wsUrl` comes from the stream status API which needs auth
- **Fix**: The camera page should accept the WebSocket URL as a query parameter instead of fetching it from the API. When the Studio tab shows the camera link, it should include `?ws=ws://34.47.234.51:4001` in the URL. Then the camera page reads `ws` from `searchParams` instead of from `useLiveStreamQuery`.

**In `/admin/stream/[id]/page.tsx`:**
- Remove the `useLiveStreamQuery` dependency for getting `wsUrl`
- Read `wsUrl` from URL search params: `const searchParams = useSearchParams(); const wsUrl = searchParams.get("ws");`
- The page should work without any auth — it just needs the WebSocket URL and matchId
- If no `wsUrl` param, show a message "Missing WebSocket URL"

**In `stream-manager.ts` on the VM:**
- Update `cameraPageUrl` to include the ws param:
  ```
  const cameraPageUrl = `${config.adminBaseUrl}/admin/stream/${matchId}?ws=${encodeURIComponent(wsUrl)}`;
  ```

### 2. Remove navigation/sidebar from camera page
The camera page should be full-screen with no admin chrome (sidebar, header, etc).

**Option A (recommended):** Move the camera page OUT of the `(admin)` layout group:
- Move from: `app/(admin)/admin/stream/[id]/page.tsx`
- Move to: `app/stream/[id]/page.tsx`
- This bypasses the admin layout (sidebar, header, auth check)
- Update the camera page URL in `stream-manager.ts` to `/stream/${matchId}?ws=...`

**Option B:** Add a layout override in the stream directory:
- Create `app/(admin)/admin/stream/layout.tsx` that returns just `{children}` with no sidebar/header

### 3. Update Studio VM with correct ADMIN_BASE_URL
Run this on the VM:
```bash
gcloud compute ssh swing-studio --zone=asia-south1-b --command="
    sudo docker stop swing-studio && sudo docker rm swing-studio
    EXTERNAL_IP=\$(curl -s http://metadata.google.internal/computeMetadata/v1/instance/network-interfaces/0/access-configs/0/external-ip -H 'Metadata-Flavor: Google')
    sudo docker run -d \
        --name swing-studio \
        --restart unless-stopped \
        -p 4000:4000 \
        -p 4001:4001 \
        -e PUBLIC_HOST=\${EXTERNAL_IP} \
        -e API_BASE_URL=https://swing-backend-nbid5gga4q-el.a.run.app \
        -e ADMIN_BASE_URL=https://admin.swingcricketapp.com \
        -e 'REDIS_URL=rediss://default:gQAAAAAAAS5VAAIncDJjZjU5M2M1MDYxODc0MzcyODliNTg3OWE1MmJiMjJiN3AyNzczOTc@true-cowbird-77397.upstash.io:6379' \
        -e STUDIO_PORT=4000 \
        -e WS_PORT=4001 \
        asia-south1-docker.pkg.dev/project-0e62f040-2f77-4498-abd/swing/studio:latest
"
```

### 4. Redis rate limit issue
Upstash free tier hit 500K request limit. Either:
- Wait for monthly reset
- Upgrade Upstash plan (~$10/month for 10M requests)
- The Studio VM stream-manager uses Redis to store stream state — it will fail until Redis is available

## Architecture Summary

```
Phone Browser (camera page)
  getUserMedia() → MediaRecorder (webm/vp8) → WebSocket chunks
                                                    ↓
Studio VM (34.47.234.51)
  ws-server.ts:4001 receives chunks
  → pipes to FFmpeg stdin
  FFmpeg: webm input + overlay PNG → libx264 → YouTube RTMP
                ↑
  overlay-capture.ts: Puppeteer screenshots overlay widget every 1s

Admin (Studio Tab)
  → POST /admin/matches/:id/stream/start → Cloud Run → Studio VM
  → Shows camera page URL for phone
  → Scene control (standard/stats/break/clean) → Redis → SSE → overlay auto-switches
```

## Files Reference

### Studio VM (`apps/studio/`)
- `src/index.ts` — Express API + startup
- `src/ws-server.ts` — WebSocket server, receives video chunks from phone
- `src/compositor.ts` — FFmpeg process, reads stdin + overlay → YouTube RTMP
- `src/overlay-capture.ts` — Puppeteer screenshots overlay widget
- `src/stream-manager.ts` — Orchestrates streams, stores state in Redis
- `src/config.ts` — Environment config
- `src/types.ts` — TypeScript interfaces
- `Dockerfile` — FFmpeg + Chromium + Node.js

### Admin (`swing-admin/`)
- `app/(admin)/admin/stream/[id]/page.tsx` — Camera page (needs to move to `app/stream/[id]/page.tsx`)
- `app/(admin)/admin/matches/[id]/page.tsx` — Match detail with Studio tab (MatchStudioTab component ~line 4270)
- `lib/api.ts` — `startLiveStream`, `stopLiveStream`, `getLiveStreamStatus`
- `lib/queries.ts` — `useLiveStreamQuery`, `useStartLiveStreamMutation`, `useStopLiveStreamMutation`

### Backend API (`apps/api/`)
- `src/modules/admin/admin.routes.ts` — Proxy routes: POST stream/start, POST stream/stop, GET stream
- `src/lib/redis.ts` — Studio scene helpers (getStudioScene, setStudioScene)
- `src/modules/public/public.routes.ts` — buildOverlayState includes scene field from Redis

## Deploy Commands
- **Studio VM rebuild:** `cd apps/studio && gcloud builds submit --config=cloudbuild.yaml .`
- **Studio VM redeploy:** SSH + docker pull + docker run (see step 3 above)
- **Backend Cloud Run:** `cd swing-backend && COMMIT_SHA=$(git rev-parse --short HEAD) && gcloud builds submit --config=cloudbuild.yaml --substitutions=COMMIT_SHA=$COMMIT_SHA .`
- **Admin Vercel:** `git push origin master` (auto-deploys)
