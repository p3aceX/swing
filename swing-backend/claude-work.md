# Swing Backend — Claude Work Log

## Last Updated: 2026-04-08

## Project
Swing Cricket Backend — Node.js + Fastify + Prisma + PostgreSQL (Supabase) + GCP Cloud Run.
API base: `https://swing-backend-1007730655118.asia-south1.run.app`

---

## What Was Done This Session

### 1. IP Engine Fixes
- Rewrote SR/economy penalty logic with absolute thresholds
- Fixed `winnerId` resolution (was comparing team name string vs 'A'/'B')
- Fixed `didBowl = false` bug for manually-entered match stats
- Added `revokeMatchIp(matchId)` — auto-called when admin deletes a match
- Added haul bonus to MVP calculation
- Added 90-day season reset (60% rankProgressPoints retention)

### 2. Tennis Ball Stat Fix
- Backfilled 22 NULL `ballType` rows in `match_player_facts` from parent Match
- All tennis ball stats now correctly filtered via `?ballType=TENNIS`

### 3. Phase 2 — Follow / Fan System
- `PlayerFollow` (player→player) routes already existed in player.service.ts
- Added `Follow` model for team/tournament follows
- New routes at `POST/DELETE /player/follow/team/:teamId` and `POST/DELETE /player/follow/tournament/:tournamentId`
- `followersCount` + `followingCount` already in profile API response

### 4. Phase 3 — Notifications
- Already existed: in-app + push, preferences, mark read
- Wired: new follower → push notification auto-triggered
- Wired: new chat message → push notification auto-triggered

### 5. Phase 4 — Messaging
- DM chat already existed (ChatConversation, ChatMessage)
- Added TEAM_CHAT type to schema
- Added `POST /chat/team/:teamId` — get/create team chat (auto-adds all team members)
- Added `DELETE /chat/team/:teamId/leave`

### 6. Quick Wins
- **View Tracking**: ProfileView, MatchView, TournamentView tables created. Auto-tracked fire-and-forget on profile/match/tournament GET endpoints.
- **Match Live Notification**: When match starts → notifies all followers of players in that match via push.
- **Tournament Update Notification**: When schedule generated or knockout advances → notifies tournament followers.

---

## Pending / Next Steps

### High Priority
- [ ] **3 players with orphaned IP** from a deleted match — transaction records already deleted, can't identify the players without knowing the match. Ask user for more info.
- [ ] **View count endpoint** — expose `viewStats` (total, last7days, uniqueViewers) on profile/match/tournament API response so frontend can display it.

### Features
- [ ] Chat image/media support (ChatMessageKind has IMAGE slot but unused)
- [ ] Admin engagement dashboard (top viewed profiles, active followers, message volume)
- [ ] Leaderboard by followers count

---

## Key File Locations
- IP Engine: `apps/api/src/modules/performance/ip-engine.ts`
- Performance Config (rank thresholds): `apps/api/src/modules/performance/performance.config.ts`
- Follow Service: `apps/api/src/modules/player/follow.service.ts`
- View Tracking Service: `apps/api/src/modules/player/view-tracking.service.ts`
- Chat Service: `apps/api/src/modules/chat/chat.service.ts`
- Notification Service: `apps/api/src/modules/notifications/notification.service.ts`
- Match Service: `apps/api/src/modules/matches/match.service.ts`
- Tournament Service: `apps/api/src/modules/tournaments/tournament.service.ts`

## Rank IP Thresholds
| Rank | III | II | I |
|------|-----|----|---|
| Rookie | 0 | 100 | 250 |
| Striker | 450 | 700 | 1000 |
| Vanguard | 1350 | 1750 | 2200 |
| Phantom | 2750 | 3350 | 4000 |
| Dominion | 4750 | 5600 | 6500 |
| Ascendant | 7500 | 8600 | 9800 |
| Immortal | 11100 | 12500 | 14000 |
| Apex | 16000 | — | — |

## API Endpoints Added This Session
```
# Follow
POST   /player/follow/player/:playerId        — follow player
DELETE /player/follow/player/:playerId        — unfollow player
GET    /player/follow/player/:playerId/status — check if following
GET    /player/follow/player/:playerId/followers
GET    /player/follow/following
POST   /player/follow/team/:teamId
DELETE /player/follow/team/:teamId
POST   /player/follow/tournament/:tournamentId
DELETE /player/follow/tournament/:tournamentId
GET    /player/follow/:type/:id/status

# Chat
POST   /chat/team/:teamId       — get or create team chat
DELETE /chat/team/:teamId/leave — leave team chat

# Notifications (already existed)
GET    /notifications
GET    /notifications/summary
POST   /notifications/:id/read
POST   /notifications/read-all
GET    /notifications/preferences
PUT    /notifications/preferences
```

## DB Notes
- `player_competitive_profile` PK is `playerId` (not `id`)
- `match_player_facts` table has `ballType` column — always backfill from parent Match
- `IpTransaction` table is named `"IpTransaction"` (capital I, capital T) in Supabase
- Season reset runs every 90 days, retains 60% of rankProgressPoints
