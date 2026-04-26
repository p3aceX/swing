# Swing Backend — API Reference

Fastify 4 service deployed to GCP Cloud Run (`asia-south1`).
Base URL (prod): `https://swing-backend-1007730655118.asia-south1.run.app`
OpenAPI / Swagger UI: `GET /docs`
Health check: `GET /health`

## Conventions

- **Auth**: all routes marked `🔒` require a Bearer JWT (`Authorization: Bearer <token>`). Tokens expire in 15 min; refresh via `POST /auth/refresh`.
- **Role guard**: some admin routes additionally require `SWING_ADMIN` or `SWING_SUPPORT`. Admin login returns such a token.
- **Response envelope** (all routes): `{ success: boolean, data?: T, error?: { code, message } }`.
- **Rate limit**: 500 req/min/IP (Redis-backed).
- **IDs** in paths are Prisma `cuid`s unless otherwise noted.

Route files live under `apps/api/src/modules/<name>/*.routes.ts`. Each module is registered with a prefix in `apps/api/src/app.ts`.

---

## Table of Contents

1. [System / Infra](#1-system--infra)
2. [Auth](#2-auth-auth)
3. [Player](#3-player-player)
4. [Chat](#4-chat-chat)
5. [Academy](#5-academy-academy)
6. [Coach](#6-coach-coach)
7. [Sessions (Academy)](#7-sessions-sessions)
8. [Matches](#8-matches-matches)
9. [Arenas](#9-arenas-arenas)
10. [Bookings](#10-bookings-bookings)
11. [Matchmaking](#11-matchmaking-matchmaking)
12. [Gigs](#12-gigs-gigs)
13. [Payments](#13-payments-payments)
14. [Notifications](#14-notifications-notifications)
15. [Public](#15-public-public) — unauthenticated
16. [Session Logs](#16-session-logs-session-logs)
17. [Curriculum](#17-curriculum-curriculum)
18. [Payroll](#18-payroll-payroll)
19. [1-on-1 Coaching](#19-1-on-1-coaching-1on1)
20. [Development (Coach Signals)](#20-development-coach-signals-root)
21. [Live Scoring Helper](#21-live-scoring-helper-live)
22. [Studio (Overlay Control)](#22-studio-overlay-control-studio)
23. [Store (Retail)](#23-store-retail-store)
24. [Wearables](#24-wearables-wearables)
25. [Elite Performance](#25-elite-performance-v1elite)
26. [Growth Insights](#26-growth-insights-v1player)
27. [Library (Drills, Fitness, Nutrition)](#27-library-library)
28. [Business Owner](#28-business-owner-biz)
29. [Admin](#29-admin-admin)
30. [Admin — Support](#30-admin--support-admin)

---

## 1. System / Infra

| Method | Path | Auth | Purpose |
|---|---|---|---|
| GET  | `/health` | — | Liveness probe (`{ status, timestamp, version }`) |
| GET  | `/docs` | — | Swagger UI |
| GET  | `/studio/hls/:matchId/*` | — | Proxy to Studio VM NGINX (`:8080/hls/...`) for HLS segments |
| GET  | `/studio/ws` | — | WebSocket upgrade; proxies to Studio VM `:4000` (phone camera feed) |

---

## 2. Auth (`/auth`)

Phone OTP via Firebase for players/business users; email/password for admin (see §29).

| Method | Path | Auth | Purpose |
|---|---|---|---|
| POST | `/auth/check-phone` | — | Pre-login check; returns role options for a phone number |
| POST | `/auth/login` | — | Generic login (role inferred) |
| POST | `/auth/player/login` | — | Player login (phone + OTP) |
| POST | `/auth/biz/login` | — | Business owner login |
| POST | `/auth/refresh` | — | Exchange refresh token for fresh access token |
| POST | `/auth/logout` | 🔒 | Invalidate refresh token |
| POST | `/auth/switch-role` | 🔒 | Switch active role (users with multiple profiles) |

---

## 3. Player (`/player`)

Everything a logged-in player sees or does that isn't match scoring.

### Profile
| Method | Path | Purpose |
|---|---|---|
| GET   | `/player/profile` | Own profile (summary) |
| PUT   | `/player/profile` | Update profile |
| PUT   | `/player/profile/avatar` | Replace avatar (S3 key) |
| GET   | `/player/profile/full` | Full profile incl. stats |
| GET   | `/player/profile/:id` | Public profile (by id) |
| GET   | `/player/profile/:id/full` | Full profile of another player |
| GET   | `/player/profile/:id/matches` | Match history for a player |
| POST  | `/player/profile/complete-onboarding` | Mark onboarding done |
| GET   | `/player/card` | Shareable player card (OG-style) |

### Follows / Fan System
Legacy path `/follows/...` and current path `/follow/...` both exist.

| Method | Path | Purpose |
|---|---|---|
| POST   | `/player/follows/:playerId` | (legacy) follow |
| DELETE | `/player/follows/:playerId` | (legacy) unfollow |
| GET    | `/player/follows/:playerId/status` | (legacy) follow status |
| GET    | `/player/followers` | My followers |
| GET    | `/player/following` | Who I follow |
| POST   | `/player/follow/player/:playerId` | Follow player |
| DELETE | `/player/follow/player/:playerId` | Unfollow player |
| GET    | `/player/follow/player/:playerId/status` | Status |
| GET    | `/player/follow/player/:playerId/followers` | Followers list |
| GET    | `/player/follow/following` | Entities I follow |
| POST   | `/player/follow/team/:teamId` | Follow team |
| DELETE | `/player/follow/team/:teamId` | Unfollow team |
| POST   | `/player/follow/tournament/:tournamentId` | Follow tournament |
| DELETE | `/player/follow/tournament/:tournamentId` | Unfollow tournament |
| GET    | `/player/follow/:type/:id/status` | Generic status (`type` = player/team/tournament) |

### Showcase (pinned highlights on profile)
| Method | Path | Purpose |
|---|---|---|
| GET    | `/player/showcase` | List items |
| POST   | `/player/showcase` | Add item |
| PATCH  | `/player/showcase/:itemId` | Update |
| DELETE | `/player/showcase/:itemId` | Remove |

### Stats & Index
| Method | Path | Purpose |
|---|---|---|
| GET | `/player/stats` | Aggregate stats |
| GET | `/player/stats/trend` | Trend series |
| GET | `/player/index` | Swing Index (current) |
| GET | `/player/index/trend` | Swing Index history |
| GET | `/player/index/breakdown` | Swing Index component breakdown |
| GET | `/player/:playerId/swing-index` | SI v2 for any player |
| GET | `/player/:playerId/swing-index/summary` | SI v2 summary |
| GET | `/player/physical` | Physical metrics (height/weight/etc.) |
| GET | `/player/rank-config` | Rank thresholds (Rookie → Apex) |
| GET | `/player/season` | Current competitive season state |
| GET | `/player/competitive` | Competitive profile (rank, IP, form) |
| GET | `/player/ip-log` | IP transaction history |
| GET | `/player/leaderboard` | Global / filtered leaderboard |
| GET | `/player/recommendations` | Recommended profiles |
| GET | `/player/search` | Search players |

### Teams (player-owned)
| Method | Path | Purpose |
|---|---|---|
| GET    | `/player/teams` | My teams |
| POST   | `/player/teams` | Create team |
| PATCH  | `/player/teams/:id` | Edit team |
| DELETE | `/player/teams/:id` | Delete team |
| GET    | `/player/teams/search` | Search teams |
| GET    | `/player/teams/:teamId/players` | Roster |
| POST   | `/player/teams/:teamId/players/quick-add` | Add guest player |
| DELETE | `/player/teams/:id/players/:playerId` | Remove player |
| GET    | `/player/teams/:teamId/public` | Public team profile |
| GET    | `/player/teams/:teamId/matches` | Team match history |

### Tournaments (player-created)
| Method | Path | Purpose |
|---|---|---|
| GET    | `/player/tournaments` | My tournaments |
| POST   | `/player/tournaments` | Create tournament |
| GET    | `/player/tournaments/:id` | Detail |
| PATCH  | `/player/tournaments/:id` | Update |
| DELETE | `/player/tournaments/:id` | Delete |
| GET    | `/player/tournaments/:id/teams` | Teams in tournament |
| POST   | `/player/tournaments/:id/teams` | Add team |
| DELETE | `/player/tournaments/:id/teams/:teamId` | Remove team |
| PATCH  | `/player/tournaments/:id/teams/:teamId/confirm` | Confirm participation |
| GET    | `/player/tournaments/:id/groups` | Group stage groups |
| POST   | `/player/tournaments/:id/groups` | Create groups |
| PATCH  | `/player/tournaments/:id/teams/:teamId/assign-group` | Move team into group |
| GET    | `/player/tournaments/:id/standings` | Standings table |
| POST   | `/player/tournaments/:id/recalculate-standings` | Force recompute |
| GET    | `/player/tournaments/:id/schedule` | Full fixture list |
| POST   | `/player/tournaments/:id/auto-generate` | Auto-generate fixtures |
| POST   | `/player/tournaments/:id/generate-schedule` | Manual schedule generator |
| POST   | `/player/tournaments/:id/smart-schedule` | Arena-aware scheduler |
| DELETE | `/player/tournaments/:id/schedule` | Wipe schedule |
| POST   | `/player/tournaments/:id/advance-round` | Advance knockout bracket |

### Matches (player-facing lists)
| Method | Path | Purpose |
|---|---|---|
| GET | `/player/matches` | My matches |
| GET | `/player/recommended` | Recommended matches to join |
| GET | `/player/enrollments` | Academy enrollments |
| GET | `/player/gig-bookings` | My gig bookings |
| GET | `/player/activity` | Activity feed |
| GET | `/player/badges` | Earned badges |

### Events
| Method | Path | Purpose |
|---|---|---|
| GET  | `/player/events` | Upcoming events (I follow) |
| POST | `/player/events` | Create event |

### Wellness & Workload
| Method | Path | Purpose |
|---|---|---|
| POST | `/player/wellness` | Daily wellness check-in |
| GET  | `/player/wellness/latest` | Latest |
| GET  | `/player/wellness/history` | History |
| POST | `/player/workload` | Log workload event |
| GET  | `/player/workload/recent` | Recent entries |
| GET  | `/player/workload/history` | History |
| GET  | `/player/workload/summary` | Aggregated summary |
| GET  | `/player/health/dashboard` | Combined health dashboard |

### Coach-driven player surfaces
| Method | Path | Purpose |
|---|---|---|
| GET  | `/player/weekly-review` | Latest coach review |
| GET  | `/player/drill-assignments` | Drills assigned to me |
| GET  | `/player/drills` | Drill library (player view) |
| POST | `/player/drills/:id/log` | Log a drill completion |
| GET  | `/player/sessions/live` | Live sessions I can join |
| GET  | `/player/training-plans` | Training plans |
| GET  | `/player/feedback` | Coach feedback |
| GET  | `/player/report-cards` | Report cards |

All routes in this section require auth unless noted — `/player/profile/:id` is public.

---

## 4. Chat (`/chat`)

DM + team chat. Each conversation is `ChatConversation`; participants in `ChatConversationParticipant`.

| Method | Path | Purpose |
|---|---|---|
| GET    | `/chat/conversations` | List my conversations (unread counts) |
| POST   | `/chat/direct/:playerId` | Get or create DM with player |
| GET    | `/chat/conversations/:conversationId/messages` | Paginated message history |
| POST   | `/chat/conversations/:conversationId/messages` | Send message |
| POST   | `/chat/conversations/:conversationId/read` | Mark read |
| POST   | `/chat/team/:teamId` | Get or create team chat (auto-adds all team members) |
| DELETE | `/chat/team/:teamId/leave` | Leave team chat |

All require auth.

---

## 5. Academy (`/academy`)

Used by `ACADEMY_OWNER` (and authorised coaches).

### Academy + staff
| Method | Path | Purpose |
|---|---|---|
| GET   | `/academy/my` | My academy (as owner) |
| POST  | `/academy` | Create academy |
| GET   | `/academy/:id` | Public view |
| PUT   | `/academy/:id` | Update |
| POST  | `/academy/:id/coaches` | Add coach |
| PATCH | `/academy/:id/coaches/:coachLinkId` | Update coach link (role, payout) |
| POST  | `/academy/:id/batches/:batchId/coaches` | Assign coach to batch |

### Batches + students
| Method | Path | Purpose |
|---|---|---|
| POST   | `/academy/:id/batches` | Create batch |
| GET    | `/academy/:id/batches` | List batches |
| PATCH  | `/academy/:id/batches/:batchId` | Update |
| POST   | `/academy/:id/batches/:batchId/schedules` | Add weekly schedule slot |
| DELETE | `/academy/:id/batches/:batchId/schedules/:scheduleId` | Remove slot |
| POST   | `/academy/:id/batches/:batchId/students` | Enrol student |
| PATCH  | `/academy/:id/students/:enrollmentId` | Update enrollment (status / batch move) |
| GET    | `/academy/:id/students` | Roster |

### Operations
| Method | Path | Purpose |
|---|---|---|
| GET  | `/academy/:id/sessions` | Sessions calendar |
| GET  | `/academy/:id/attendance-report` | Attendance report |
| POST | `/academy/:id/fee-structures` | Create fee structure |
| GET  | `/academy/:id/fee-payments` | Payment list |
| POST | `/academy/:id/fee-payments` | Record offline payment |
| POST | `/academy/:id/fee-payments/:paymentId/remind` | Send reminder |
| POST | `/academy/:id/announcements` | Post announcement |
| GET  | `/academy/:id/inventory` | Inventory |
| POST | `/academy/:id/inventory` | Add inventory item |

---

## 6. Coach (`/coach`)

Used by users with a `CoachProfile`.

| Method | Path | Purpose |
|---|---|---|
| GET   | `/coach/profile` | My coach profile |
| PUT   | `/coach/profile` | Update |
| GET   | `/coach/:id` | Public view |
| GET   | `/coach/students` | My students |
| GET   | `/coach/batches` | My batches |
| GET   | `/coach/earnings` | Earnings summary |
| GET   | `/coach/gig-bookings` | Gig bookings (I'm the coach) |

### Sessions
| Method | Path | Purpose |
|---|---|---|
| POST  | `/coach/sessions` | Schedule / run session |
| GET   | `/coach/sessions` | List |
| POST  | `/coach/sessions/:id/cancel` | Cancel |
| POST  | `/coach/sessions/:id/generate-qr` | Attendance QR |
| POST  | `/coach/sessions/:id/close-qr` | Close QR window |
| POST  | `/coach/sessions/:id/attendance` | Mark attendance (bulk) |

### Recurring schedules
| Method | Path | Purpose |
|---|---|---|
| GET   | `/coach/schedules` | List recurring slots |
| POST  | `/coach/schedules` | Create |
| PATCH | `/coach/schedules/:id` | Update |
| POST  | `/coach/schedules/:id/generate` | Materialise upcoming sessions |

### Drills + plans + feedback
| Method | Path | Purpose |
|---|---|---|
| GET  | `/coach/drills` | My drills |
| POST | `/coach/drills` | Create drill |
| GET  | `/coach/drills/:id` | Detail |
| GET  | `/coach/drill-plans` | List plans |
| POST | `/coach/drill-plans` | Create plan |
| POST | `/coach/feedback` | Add feedback for a student |
| GET  | `/coach/report-cards` | Report cards |
| POST | `/coach/report-cards` | Create |
| POST | `/coach/report-cards/:id/publish` | Publish |

---

## 7. Sessions (`/sessions`)

Academy session lifecycle (player-facing entry points).

| Method | Path | Purpose |
|---|---|---|
| POST  | `/sessions` | Start ad-hoc session |
| GET   | `/sessions/:id` | Detail |
| PATCH | `/sessions/:id/close` | Close |
| POST  | `/sessions/:id/join-qr` | Join via QR (player) |
| POST  | `/sessions/:id/join-app` | Join in-app |
| POST  | `/sessions/:id/checkin-coach` | Coach self check-in |
| POST  | `/sessions/scan` | Scan QR (universal) |
| GET   | `/sessions/:id/attendance` | Attendance list |
| PATCH | `/sessions/:id/attendance/:playerId` | Manual mark (override) |

---

## 8. Matches (`/matches`)

Ball-by-ball scoring + lifecycle.

### Lifecycle
| Method | Path | Purpose |
|---|---|---|
| POST   | `/matches` | Create match |
| POST   | `/matches/:id/toss` | Record toss result |
| POST   | `/matches/:id/start` | Transition to IN_PROGRESS |
| POST   | `/matches/:id/complete` | Close match |
| POST   | `/matches/:id/continue-innings` | Resume after break |
| PATCH  | `/matches/:id/cancel` | Cancel |
| DELETE | `/matches/:id` | Delete (cascades; revokes IP) |
| PATCH  | `/matches/:id/scorer` | Change scorer |
| PUT    | `/matches/:id/players` | Replace player list |
| POST   | `/matches/:id/verify` | Scorer marks match verified |
| POST   | `/matches/:id/followon` | Enforce follow-on (TWO_INNINGS) |
| POST   | `/matches/:id/superover` | Kick off super over |
| POST   | `/matches/schedule` | Propose match schedule (matchmaking) |

### Innings & balls
| Method | Path | Purpose |
|---|---|---|
| POST   | `/matches/:id/innings/:num/ball` | Record ball event |
| DELETE | `/matches/:id/innings/:num/last-ball` | Undo last ball |
| POST   | `/matches/:id/innings/:num/complete` | Close innings |
| POST   | `/matches/:id/innings/:num/declare` | Declare (TEST/TWO_INNINGS) |
| POST   | `/matches/:id/innings/:num/reopen` | Reopen closed innings |
| PATCH  | `/matches/:id/innings/:num/state` | Patch innings state (freeform) |
| GET    | `/matches/:id/innings/:num/over/:overNum` | Over details |

### Read surfaces
| Method | Path | Auth | Purpose |
|---|---|---|---|
| GET | `/matches/:id` | — | Full match |
| GET | `/matches/:id/preview` | — | Preview card |
| GET | `/matches/:id/scorecard` | — | Scorecard |
| GET | `/matches/:id/highlights` | — | Highlights |
| GET | `/matches/:id/commentary` | — | Ball commentary |
| GET | `/matches/:id/analysis` | — | Analytical breakdown |
| GET | `/matches/:id/players` | 🔒 | Players with stats |
| GET | `/matches/recommended` | 🔒 | Recommended for me |

---

## 9. Arenas (`/arenas`)

Venues bookable for practice/matches.

| Method | Path | Auth | Purpose |
|---|---|---|---|
| POST   | `/arenas` | 🔒 | Create arena |
| GET    | `/arenas` | — | List / search |
| GET    | `/arenas/:id` | — | Detail |
| PUT    | `/arenas/:id` | 🔒 | Update |
| GET    | `/arenas/:id/availability` | — | Slot availability |
| GET    | `/arenas/:id/stats` | 🔒 | Owner stats |
| POST   | `/arenas/:id/managers` | 🔒 | Add arena manager |
| POST   | `/arenas/:id/units` | 🔒 | Add unit (pitch/net/turf) |
| PATCH  | `/arenas/u/:unitId` | 🔒 | Update unit |
| DELETE | `/arenas/u/:unitId` | 🔒 | Delete unit |
| GET    | `/arenas/:id/blocks` | 🔒 | Owner's time-blocks (closed hours) |
| POST   | `/arenas/:id/blocks` | 🔒 | Add block |
| DELETE | `/arenas/blocks/:blockId` | 🔒 | Remove block |

---

## 10. Bookings (`/bookings`)

Arena slot booking.

| Method | Path | Purpose |
|---|---|---|
| POST | `/bookings/hold` | Hold a slot (5-min hold) |
| POST | `/bookings` | Confirm booking |
| GET  | `/bookings` | My bookings |
| GET  | `/bookings/:id` | Detail |
| POST | `/bookings/:id/cancel` | Cancel |
| POST | `/bookings/:id/checkin` | Check in |
| GET  | `/bookings/arena/:arenaId` | Arena's upcoming bookings (owner view) |

All require auth.

---

## 11. Matchmaking (`/matchmaking`)

Split into two route files but same prefix.

### Requests
| Method | Path | Purpose |
|---|---|---|
| POST | `/matchmaking/requests` | Post challenge |
| GET  | `/matchmaking/requests` | Discover open requests |
| GET  | `/matchmaking/requests/mine` | My requests |
| POST | `/matchmaking/requests/:id/respond` | Respond (accept/counter) |
| POST | `/matchmaking/requests/:id/cancel` | Cancel |

### Queue (faster pairing)
| Method | Path | Purpose |
|---|---|---|
| POST   | `/matchmaking/queue` | Join queue |
| GET    | `/matchmaking/queue/:id` | Queue entry status |
| DELETE | `/matchmaking/queue/:id` | Leave queue |
| POST   | `/matchmaking/confirm/:requestId` | Confirm matched request |

---

## 12. Gigs (`/gigs`)

One-off paid sessions (coach↔player).

| Method | Path | Auth | Purpose |
|---|---|---|---|
| POST | `/gigs` | 🔒 | Create gig listing |
| GET  | `/gigs` | — | List / search |
| GET  | `/gigs/:id` | — | Detail |
| PUT  | `/gigs/:id` | 🔒 | Update |
| POST | `/gigs/:id/book` | 🔒 | Book |
| GET  | `/gigs/my-bookings` | 🔒 | My bookings (both sides) |
| POST | `/gigs/bookings/:id/cancel` | 🔒 | Cancel |
| POST | `/gigs/bookings/:id/complete` | 🔒 | Mark complete |

---

## 13. Payments (`/payments`)

Razorpay integration.

| Method | Path | Auth | Purpose |
|---|---|---|---|
| POST | `/payments/orders` | 🔒 | Create Razorpay order |
| POST | `/payments/verify` | 🔒 | Verify client-side signature |
| POST | `/payments/webhook` | — | Razorpay webhook (HMAC-verified) |
| GET  | `/payments` | 🔒 | My payment history |
| GET  | `/payments/:id` | 🔒 | Detail |
| POST | `/payments/:id/refund` | 🔒 | Refund (admin-gated) |

---

## 14. Notifications (`/notifications`)

In-app + FCM push.

| Method | Path | Purpose |
|---|---|---|
| POST   | `/notifications/fcm-token` | Register device token |
| DELETE | `/notifications/fcm-token` | Unregister |
| GET    | `/notifications` | List |
| GET    | `/notifications/summary` | Unread counts / summary |
| GET    | `/notifications/preferences` | Preferences |
| PUT    | `/notifications/preferences` | Update preferences |
| POST   | `/notifications/:id/read` | Mark one read |
| POST   | `/notifications/read-all` | Mark all read |

All require auth.

---

## 15. Public (`/public`)

Unauthenticated read-only endpoints for the marketing site (`swing-web`) and OG image pipeline.

| Method | Path | Purpose |
|---|---|---|
| GET | `/public/cities` | City list for dropdowns |
| GET | `/public/tournaments` | Tournament index |
| GET | `/public/tournament/:slug` | Tournament detail |
| GET | `/public/tournament/:slug/matches` | Matches in tournament |
| GET | `/public/tournament/:slug/standings` | Standings |
| GET | `/public/tournament/:slug/leaderboard` | Leaderboard |
| GET | `/public/match/:id` | Public match view |
| GET | `/public/overlay/:matchId` | Overlay state (initial JSON) |
| GET | `/public/overlay/:matchId/stream` | SSE stream of overlay state changes |
| GET | `/public/overlay/:matchId/widget` | HTML widget rendered by Puppeteer for broadcast |
| GET | `/public/overlay/:matchId/widget-legacy` | Legacy widget (still used by some overlays) |
| GET | `/public/overlay-assets/logo` | Logo asset |

---

## 16. Session Logs (`/session-logs`)

Per-student, per-session coach notes driving Elite insights.

| Method | Path | Purpose |
|---|---|---|
| POST | `/session-logs` | Submit session log |
| GET  | `/session-logs/chips` | Skill chips taxonomy (public) |
| GET  | `/session-logs/:id` | Log detail |
| GET  | `/session-logs/batch/:academyId/:batchId` | Batch log history |
| GET  | `/session-logs/student/:enrollmentId/insights` | Student insights |
| GET  | `/session-logs/batch/:academyId/:batchId/insights` | Batch insights |
| GET  | `/session-logs/academy/:academyId/development` | Academy-wide development view |
| GET  | `/session-logs/student/:playerProfileId/:academyId/skill-matrix` | Skill matrix |

All require auth except `/chips`.

---

## 17. Curriculum (`/curriculum`)

Multi-phase training curricula attached to batches.

| Method | Path | Purpose |
|---|---|---|
| POST   | `/curriculum` | Create curriculum |
| GET    | `/curriculum` | List |
| GET    | `/curriculum/:id` | Detail |
| POST   | `/curriculum/:id/phases` | Add phase |
| POST   | `/curriculum/phases/:phaseId/topics` | Add topic |
| POST   | `/curriculum/assign` | Assign curriculum to batch |
| GET    | `/curriculum/batch/:batchId` | Batch progress |
| POST   | `/curriculum/assignments/:id/complete/:topicId` | Mark topic done |
| DELETE | `/curriculum/assignments/:id/complete/:topicId` | Un-mark |

---

## 18. Payroll (`/payroll`)

Academy coach payroll.

| Method | Path | Purpose |
|---|---|---|
| GET   | `/payroll/:academyId/dashboard` | Payroll dashboard |
| GET   | `/payroll/:academyId/compensations` | Coach compensation list |
| POST  | `/payroll/:academyId/compensations` | Upsert compensation rule |
| GET   | `/payroll/:academyId/calculate` | Compute payouts for period |
| GET   | `/payroll/:academyId/payouts` | Payout records |
| POST  | `/payroll/:academyId/payouts` | Create payout |
| PATCH | `/payroll/payouts/:payoutId/pay` | Mark paid |
| GET   | `/payroll/my` | My payouts (coach view) |
| GET   | `/payroll/my-summary` | Coach earnings summary |

---

## 19. 1-on-1 Coaching (`/1on1`)

Private lessons bookable by slot.

| Method | Path | Purpose |
|---|---|---|
| GET  | `/1on1/my-profile` | My coach 1-on-1 profile |
| PUT  | `/1on1/my-profile` | Update (rate, availability) |
| PUT  | `/1on1/my-slots` | Replace slots |
| GET  | `/1on1/bookings` | Bookings |
| POST | `/1on1/bookings/:id/accept` | Accept |
| POST | `/1on1/bookings/:id/reject` | Reject |
| POST | `/1on1/bookings/:id/complete` | Complete |
| GET  | `/1on1/earnings` | Coach earnings |
| GET  | `/1on1/coach/:coachId` | Public coach profile (unauth) |
| POST | `/1on1/request` | Player request a slot |

---

## 20. Development / Coach Signals (root)

These routes are mounted **without a prefix** (see `app.register(developmentRoutes)`). Consumed by player/coach apps.

| Method | Path | Purpose |
|---|---|---|
| GET  | `/session-types` | Session type taxonomy |
| GET  | `/skill-areas` | Skill area list (optional `roleTag`) |
| GET  | `/watch-flags` | Watch flag taxonomy |
| GET  | `/players/:id/signals` | Latest signals for a player |
| GET  | `/players/:id/drill-assignments` | Drill assignments |
| GET  | `/players/:id/card` | Development card |
| GET  | `/players/:id/weekly-review` | Weekly review |
| GET  | `/drills` | Drill library (dev) |
| POST | `/drills` | Create drill |
| POST | `/drill-assignments` | Assign drill |
| POST | `/drill-assignments/:id/log` | Log progress |
| GET  | `/drill-assignments/:id/progress` | Progress detail |
| POST | `/sessions/:id/signals/:playerId` | Coach submits signal for player in a session |
| POST | `/players/:id/apex-goal` | Set Apex goal for player |

All require auth.

---

## 21. Live Scoring Helper (`/live`)

Helpers used by the scoring UI on phones and the Studio overlay renderer. Endpoints are mostly public (no user context, match-scoped).

| Method | Path | Purpose |
|---|---|---|
| POST | `/live/validate-match` | Validate pin/code for match (scorer) |
| POST | `/live/validate-tournament` | Validate tournament scorer pin |
| GET  | `/live/tournaments/:tournamentId/matches` | Scorable matches |
| GET  | `/live/matches/:matchId/overlay` | Overlay payload (broadcaster-friendly) |
| POST | `/live/session/start` | Begin a live scoring session |
| POST | `/live/session/heartbeat` | Keep-alive |
| POST | `/live/session/stop` | End session |
| GET  | `/live/session/:matchId` | Session status |

---

## 22. Studio (Overlay Control) (`/studio`)

Mirrors `OverlayStudio` / `OverlayScene` / `OverlayTrigger` / `AdSlot` models. Broadcast overlay control plane.

### Templates + match-scoped studio
| Method | Path | Auth | Purpose |
|---|---|---|---|
| GET   | `/studio/templates` | 🔒 | Overlay pack templates |
| POST  | `/studio/:matchId/init` | 🔒 | Init studio for match |
| GET   | `/studio/:matchId` | 🔒 | Studio state |
| GET   | `/studio/:matchId/current` | — | Public current state (used by overlay widget) |
| PATCH | `/studio/:matchId/active-scene` | 🔒 | Switch scene |
| PATCH | `/studio/:matchId/settings` | 🔒 | Studio settings |
| POST  | `/studio/:matchId/trigger-event` | 🔒 | Fire named event |

### Scenes
| Method | Path | Purpose |
|---|---|---|
| POST   | `/studio/:matchId/scenes` | Create scene |
| PATCH  | `/studio/:matchId/scenes/:sceneId` | Update |
| DELETE | `/studio/:matchId/scenes/:sceneId` | Delete |

### Triggers
| Method | Path | Purpose |
|---|---|---|
| POST   | `/studio/:matchId/triggers` | Add trigger |
| PATCH  | `/studio/:matchId/triggers/:triggerId` | Update |
| DELETE | `/studio/:matchId/triggers/:triggerId` | Delete |

### Ad slots
| Method | Path | Purpose |
|---|---|---|
| POST   | `/studio/:matchId/ads` | Add ad |
| PATCH  | `/studio/:matchId/ads/:adId` | Update |
| DELETE | `/studio/:matchId/ads/:adId` | Delete |
| PATCH  | `/studio/:matchId/ads/reorder` | Reorder |

---

## 23. Store (Retail) (`/store`)

Cricket store (products, orders, delivery).

### Stores
| Method | Path | Auth | Purpose |
|---|---|---|---|
| POST | `/store` | 🔒 | Create store |
| GET  | `/store/search` | — | Search stores/products |
| GET  | `/store/:id` | — | Store detail |
| PUT  | `/store/:id/inventory` | 🔒 | Bulk upsert inventory |
| GET  | `/store/:id/inventory` | 🔒 | Owner inventory |

### Catalog
| Method | Path | Auth | Purpose |
|---|---|---|---|
| GET  | `/store/categories` | — | Categories |
| POST | `/store/categories` | 🔒 | Create category |
| POST | `/store/products` | 🔒 | Create product |

### Orders
| Method | Path | Purpose |
|---|---|---|
| POST  | `/store/orders` | Place order |
| GET   | `/store/orders/:id` | Detail |
| PATCH | `/store/orders/:id/status` | Update status |

---

## 24. Wearables (`/wearables`)

| Method | Path | Purpose |
|---|---|---|
| POST | `/wearables/ingest` | Push health samples from `health` (Flutter) package |

---

## 25. Elite Performance (`/v1/elite`)

Premium performance module — "My Plan", day logs, analytics, SWOT, scouting. See `PerformanceService` + `ElitePlanService`.

### My Plan
| Method | Path | Purpose |
|---|---|---|
| GET   | `/v1/elite/my-plan` | Current plan |
| POST  | `/v1/elite/my-plan` | Create plan |
| PATCH | `/v1/elite/my-plan` | Update |

### Day logs
| Method | Path | Purpose |
|---|---|---|
| GET    | `/v1/elite/day-log/:date` | Day plan + actuals |
| PATCH  | `/v1/elite/day-log/:date/plan` | Edit planned activities |
| POST   | `/v1/elite/day-log/:date/execute` | Mark activity executed |
| GET    | `/v1/elite/execute-summary` | Execution summary (week) |

### Journal + streak
| Method | Path | Purpose |
|---|---|---|
| POST  | `/v1/elite/player/:playerId/journal` | Journal entry |
| GET   | `/v1/elite/player/:playerId/journal-streak` | Streak |

### Apex + goals
| Method | Path | Purpose |
|---|---|---|
| GET  | `/v1/elite/player/:id/apex-state` | Apex progress |
| POST | `/v1/elite/player/:id/goal` | Set goal |

### Health
| Method | Path | Purpose |
|---|---|---|
| GET  | `/v1/elite/player/:id/health-dashboard` | Dashboard |
| POST | `/v1/elite/performance/health/log` | Log health entry |

### Analytics
| Method | Path | Auth | Purpose |
|---|---|---|---|
| GET | `/v1/elite/player/:id/profile` | — | Elite public profile |
| GET | `/v1/elite/player/:id/analytics` | 🔒 | Analytics |
| GET | `/v1/elite/player/:id/stats-extended` | — | Extended stats |
| GET | `/v1/elite/player/:id/arena-performance` | 🔒 | Arena-filtered perf |
| GET | `/v1/elite/player/:id/benchmarks` | 🔒 | Benchmarks |
| GET | `/v1/elite/player/:id/precision` | 🔒 | Precision scores |
| GET | `/v1/elite/player/:id/swot` | 🔒 | SWOT |
| GET | `/v1/elite/player/:id/scouting/:opponentId` | 🔒 | Scouting report |
| GET | `/v1/elite/analytics/compare` | 🔒 | Compare players |
| GET | `/v1/elite/team/compare` | 🔒 | Compare teams |
| GET | `/v1/elite/team/:id/analytics` | 🔒 | Team analytics |

### Admin helpers (elite)
| Method | Path | Purpose |
|---|---|---|
| POST | `/v1/elite/admin/trigger-challenge-check` | Force challenge detector run |
| POST | `/v1/elite/admin/generate-snapshots` | Force snapshot regeneration |

---

## 26. Growth Insights (`/v1/player`)

| Method | Path | Purpose |
|---|---|---|
| GET | `/v1/player/growth-insights` | Weekly growth insights |
| GET | `/v1/player/nearby-coaches` | Geo-recommended coaches |

---

## 27. Library (`/library`)

Sub-registered: `drills` and `fitness-exercises` get their own sub-prefix; nutrition routes define their own sub-paths.

### Drills (`/library/drills`)
| Method | Path | Auth | Purpose |
|---|---|---|---|
| GET    | `/library/drills` | — | List |
| GET    | `/library/drills/:id` | — | Detail |
| POST   | `/library/drills` | 🔒 | Create |
| PATCH  | `/library/drills/:id` | 🔒 | Update |
| DELETE | `/library/drills/:id` | 🔒 | Delete |

### Fitness (`/library/fitness-exercises`)
| Method | Path | Auth | Purpose |
|---|---|---|---|
| GET    | `/library/fitness-exercises` | — | List |
| GET    | `/library/fitness-exercises/:id` | — | Detail |
| POST   | `/library/fitness-exercises` | 🔒 | Create |
| PATCH  | `/library/fitness-exercises/:id` | 🔒 | Update |
| DELETE | `/library/fitness-exercises/:id` | 🔒 | Delete |

### Nutrition (`/library/nutrition-items`, `/library/nutrition-recipes`)
| Method | Path | Auth | Purpose |
|---|---|---|---|
| GET    | `/library/nutrition-items` | — | List |
| GET    | `/library/nutrition-items/:id` | — | Detail |
| POST   | `/library/nutrition-items` | 🔒 | Create |
| PATCH  | `/library/nutrition-items/:id` | 🔒 | Update |
| DELETE | `/library/nutrition-items/:id` | 🔒 | Delete |
| POST   | `/library/nutrition-items/:nutritionItemId/recipes` | 🔒 | Add recipe |
| PATCH  | `/library/nutrition-recipes/:id` | 🔒 | Update recipe |
| DELETE | `/library/nutrition-recipes/:id` | 🔒 | Delete recipe |

---

## 28. Business Owner (`/biz`)

Used by a `BUSINESS_OWNER` logged in via `/auth/biz/login`.

| Method | Path | Purpose |
|---|---|---|
| GET  | `/biz/me` | Business account |
| PUT  | `/biz/business-details` | Update business details |
| POST | `/biz/academy` | Spawn academy under this business |
| POST | `/biz/coach` | Add coach to business |
| POST | `/biz/arena` | Spawn arena under this business |
| GET  | `/biz/stores` | Business's stores |

---

## 29. Admin (`/admin`)

All routes require a JWT where the user's role is `SWING_ADMIN` or `SWING_SUPPORT`. Login is via email/password.

### Admin auth
| Method | Path | Auth | Purpose |
|---|---|---|---|
| POST   | `/admin/auth/login` | — | Email+password login; returns access token |
| GET    | `/admin/auth/admins` | 🔒 | List admin users |
| POST   | `/admin/auth/admins` | 🔒 | Create admin |
| PATCH  | `/admin/auth/admins/:id` | 🔒 | Update admin |
| DELETE | `/admin/auth/admins/:id` | 🔒 | Delete admin |

### Dashboard & analytics
| Method | Path | Purpose |
|---|---|---|
| GET  | `/admin/dashboard` | KPI dashboard (period: today/week/month/ytd) |
| GET  | `/admin/analytics/revenue` | Revenue analytics |
| GET  | `/admin/audit` | Audit log |
| GET  | `/admin/config` | Platform config kv |
| PUT  | `/admin/config/:key` | Update config key |

### Users
| Method | Path | Purpose |
|---|---|---|
| GET    | `/admin/users` | List (role/search/blocked/paged) |
| GET    | `/admin/users/:id` | Detail |
| POST   | `/admin/users` | Create user |
| PATCH  | `/admin/users/:id` | Update |
| DELETE | `/admin/users/:id` | Delete |
| POST   | `/admin/users/:id/block` | Block |
| POST   | `/admin/users/:id/unblock` | Unblock |
| POST   | `/admin/users/:id/grant-role` | Grant role |
| POST   | `/admin/users/:id/revoke-role` | Revoke role |
| POST   | `/admin/users/:id/profiles` | Attach profile (e.g. coach profile) |
| DELETE | `/admin/users/:id/profiles/:type` | Remove profile |

### Players (admin tooling)
| Method | Path | Purpose |
|---|---|---|
| PATCH | `/admin/players/:id` | Edit player |
| PATCH | `/admin/players/:id/competitive` | Edit competitive profile (rank/IP override) |
| POST  | `/admin/players/:playerId/rebuild-ip` | Rebuild IP ledger from matches |

### Coaches / academies / arenas (verification & governance)
| Method | Path | Purpose |
|---|---|---|
| GET   | `/admin/coaches` | List |
| PATCH | `/admin/coaches/:id` | Edit |
| PATCH | `/admin/coaches/:id/verify` | Toggle verification |
| GET   | `/admin/academies` | List |
| PATCH | `/admin/academies/:id/verify` | Verify |
| PATCH | `/admin/academies/:id/<coach-payouts>` (see line 544) | Payouts-related patch |
| GET   | `/admin/arenas` | List |
| PATCH | `/admin/arenas/:id/verify` | Verify |
| PATCH | `/admin/arenas/:id/toggle-swing` | Toggle Swing-enabled flag |
| DELETE| `/admin/arenas/:id` | Delete |
| PATCH | `/admin/arena-owners/:id` | Edit arena owner |
| GET   | `/admin/venues` | List venues |

### Taxonomies (session types, skill areas, watch flags, drills)
| Method | Path | Purpose |
|---|---|---|
| GET    | `/admin/session-types` | List |
| POST   | `/admin/session-types` | Create |
| PATCH  | `/admin/session-types/:id` | Update |
| DELETE | `/admin/session-types/:id` | Delete |
| GET    | `/admin/skill-areas` | List |
| POST   | `/admin/skill-areas` | Create |
| PATCH  | `/admin/skill-areas/:id` | Update |
| DELETE | `/admin/skill-areas/:id` | Delete |
| GET    | `/admin/watch-flags` | List |
| POST   | `/admin/watch-flags` | Create |
| PATCH  | `/admin/watch-flags/:id` | Update |
| DELETE | `/admin/watch-flags/:id` | Delete |
| GET    | `/admin/drills` | List |
| POST   | `/admin/drills` | Create |
| PATCH  | `/admin/drills/:id` | Update |
| DELETE | `/admin/drills/:id` | Delete |

### Matches (admin control)
| Method | Path | Purpose |
|---|---|---|
| GET    | `/admin/matches` | List |
| POST   | `/admin/matches` | Create |
| GET    | `/admin/matches/:id` | Detail |
| PATCH  | `/admin/matches/:id` | Update |
| DELETE | `/admin/matches/:id` | Delete |
| POST   | `/admin/matches/:id/verify` | Verify match stats (triggers IP engine) |
| POST   | `/admin/matches/:id/reprocess` | Reprocess through performance engine |
| PATCH  | `/admin/matches/:id/playing11` | Set Playing XI |
| GET    | `/admin/matches/:id/players` | Players in match |
| POST   | `/admin/matches/:id/quick-add-player` | Quick-add guest |
| PATCH  | `/admin/matches/:id/wicketkeeper` | Set keeper |
| POST   | `/admin/matches/:id/toss` | Record toss |
| PATCH  | `/admin/matches/:id/start` | Start match |
| POST   | `/admin/matches/:id/innings/:num/ball` | Score a ball |
| DELETE | `/admin/matches/:id/innings/:num/last-ball` | Undo ball |
| POST   | `/admin/matches/:id/innings/:num/complete` | End innings |
| POST   | `/admin/matches/:id/innings/:num/reopen` | Reopen innings |
| POST   | `/admin/matches/:id/continue-innings` | Continue |
| POST   | `/admin/matches/:id/end-of-day` | Multi-day close |
| POST   | `/admin/matches/:id/followon` | Enforce follow-on |
| POST   | `/admin/matches/:id/superover` | Start super over |
| PATCH  | `/admin/matches/:id/complete` | Complete |
| POST   | `/admin/matches/:id/highlights` | Add highlight |
| DELETE | `/admin/matches/:id/highlights/:highlightId` | Remove highlight |

### Live streaming (match)
| Method | Path | Purpose |
|---|---|---|
| PATCH | `/admin/matches/:id/stream` | Configure stream metadata |
| GET   | `/admin/matches/:id/stream` | Status (proxied) |
| POST  | `/admin/matches/:id/stream/start` | Start stream (proxy to Studio VM) |
| POST  | `/admin/matches/:id/stream/stop` | Stop stream |
| GET   | `/admin/streams` | List all active streams |
| GET   | `/admin/matches/:id/studio` | Studio state |
| PATCH | `/admin/matches/:id/studio` | Update studio settings |

### Overlay packs
| Method | Path | Purpose |
|---|---|---|
| GET    | `/admin/overlay-packs` | List |
| POST   | `/admin/overlay-packs` | Create |
| PATCH  | `/admin/overlay-packs/:id` | Update |
| PATCH  | `/admin/tournaments/:id/overlay-pack` | Assign pack to tournament |
| PATCH  | `/admin/matches/:id/overlay-pack` | Override pack for match |
| GET    | `/admin/matches/:id/overlay-pack/effective` | Effective pack (inheritance resolved) |

### Tournaments (admin)
| Method | Path | Purpose |
|---|---|---|
| GET    | `/admin/tournaments` | List |
| POST   | `/admin/tournaments` | Create |
| GET    | `/admin/tournaments/:id` | Detail |
| PATCH  | `/admin/tournaments/:id` | Update |
| DELETE | `/admin/tournaments/:id` | Delete |
| GET    | `/admin/tournaments/:id/teams` | Teams |
| POST   | `/admin/tournaments/:id/teams` | Add |
| DELETE | `/admin/tournaments/:id/teams/:teamId` | Remove |
| GET    | `/admin/tournaments/:id/groups` | Groups |
| POST   | `/admin/tournaments/:id/groups` | Create groups |
| PATCH  | `/admin/tournaments/:id/teams/:teamId/assign-group` | Assign group |
| PATCH  | `/admin/tournaments/:id/teams/:teamId/confirm` | Confirm team |
| GET    | `/admin/tournaments/:id/standings` | Standings |
| POST   | `/admin/tournaments/:id/recalculate-standings` | Recompute |
| GET    | `/admin/tournaments/:id/schedule` | Schedule |
| POST   | `/admin/tournaments/:id/generate-schedule` | Generate |
| POST   | `/admin/tournaments/:id/smart-schedule` | Arena-aware scheduler |
| DELETE | `/admin/tournaments/:id/schedule` | Wipe |
| POST   | `/admin/tournaments/:id/auto-generate` | Full auto-gen (fixtures+groups) |
| POST   | `/admin/tournaments/:id/advance-round` | Advance knockout |

### Teams (admin)
| Method | Path | Purpose |
|---|---|---|
| GET    | `/admin/teams` | List |
| POST   | `/admin/teams` | Create |
| GET    | `/admin/teams/:id` | Detail |
| PATCH  | `/admin/teams/:id` | Update |
| DELETE | `/admin/teams/:id` | Delete |
| POST   | `/admin/teams/:id/players` | Add player |
| POST   | `/admin/teams/:id/players/quick-add` | Quick add |
| DELETE | `/admin/teams/:id/players/:playerId` | Remove |

### Payments / events / broadcasts / gigs / stores
| Method | Path | Purpose |
|---|---|---|
| GET   | `/admin/payments` | Payment ledger |
| GET   | `/admin/events` | Events |
| POST  | `/admin/events` | Create event |
| POST  | `/admin/notifications/broadcast` | Broadcast notification to user cohort |
| GET   | `/admin/gigs` | Gigs |
| PATCH | `/admin/gigs/:id/feature` | Feature/unfeature |
| GET   | `/admin/stores` | Stores |
| POST  | `/admin/stores` | Create |

### Seasons (competitive)
| Method | Path | Purpose |
|---|---|---|
| GET  | `/admin/season/current` | Current season |
| POST | `/admin/season/reset` | Trigger 90-day reset |
| POST | `/admin/season/decay` | Trigger rank decay |

---

## 30. Admin — Support (`/admin`)

Same prefix as admin but a separate router (`admin.support.routes.ts`).

| Method | Path | Purpose |
|---|---|---|
| GET  | `/admin/support` | List tickets (status filter) |
| GET  | `/admin/support/:id` | Ticket detail |
| POST | `/admin/support/:id/message` | Add message |
| POST | `/admin/support/:id/assign` | Assign to admin |
| POST | `/admin/support/:id/resolve` | Resolve |
| POST | `/admin/support/:id/close` | Close |

---

## Notes & gotchas

- **Duplicate follow paths**: `/player/follows/...` (legacy, 3 endpoints) overlaps with the newer `/player/follow/...` surface. New clients should use `/follow/...`.
- **Admin vs player parity for matches**: almost every match-lifecycle endpoint is mirrored under `/admin/matches/...`. Admin path skips some permission checks (scorer role) and can operate on any match.
- **Studio streaming proxy**: `POST /admin/matches/:id/stream/start` on the API Cloud Run forwards to the Studio VM at `STUDIO_SERVICE_URL` (`http://34.47.234.51:4000`). Similarly `GET /studio/hls/*` and `/studio/ws` are transparent proxies so the public camera page stays on HTTPS/WSS.
- **Workers**: several routes fire-and-forget enqueue BullMQ jobs (notifications, slot release). These run in-process if `START_WORKERS=true`, or as a dedicated `SERVICE_MODE=worker` container.
- **Public-by-design**: read-only surfaces under `/public/*`, `/matches/:id`, `/matches/:id/scorecard`, `/arenas`, `/arenas/:id`, `/gigs`, `/store/search`, `/store/categories`, `/1on1/coach/:coachId`, `/library/**` (GETs), and the overlay endpoints. Everything else requires auth.
- **Versioning**: only Elite and Growth Insights are namespaced `/v1/...`. The rest is unversioned — breaking changes ripple to all clients at once.
