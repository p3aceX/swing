-- ============================================================
-- Migration: competitive_chat_foundation
-- Adds player follows, direct chat tables, and renames legacy
-- XP platform-config keys to IP terminology.
-- ============================================================

CREATE TYPE "ChatConversationType" AS ENUM ('DIRECT');
CREATE TYPE "ChatMessageKind" AS ENUM ('TEXT', 'SYSTEM');

CREATE TABLE "player_follows" (
  "followerPlayerId" TEXT NOT NULL,
  "followingPlayerId" TEXT NOT NULL,
  "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

  CONSTRAINT "player_follows_pkey" PRIMARY KEY ("followerPlayerId", "followingPlayerId"),
  CONSTRAINT "player_follows_followerPlayerId_fkey"
    FOREIGN KEY ("followerPlayerId") REFERENCES "PlayerProfile"("id")
    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT "player_follows_followingPlayerId_fkey"
    FOREIGN KEY ("followingPlayerId") REFERENCES "PlayerProfile"("id")
    ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE INDEX "player_follows_followingPlayerId_createdAt_idx"
  ON "player_follows"("followingPlayerId", "createdAt");

CREATE INDEX "player_follows_followerPlayerId_createdAt_idx"
  ON "player_follows"("followerPlayerId", "createdAt");

CREATE TABLE "chat_conversations" (
  "id" TEXT NOT NULL,
  "type" "ChatConversationType" NOT NULL DEFAULT 'DIRECT',
  "directKey" TEXT,
  "title" TEXT,
  "createdByPlayerId" TEXT,
  "lastMessageAt" TIMESTAMP(3),
  "lastMessagePreview" TEXT,
  "lastMessageSenderId" TEXT,
  "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updatedAt" TIMESTAMP(3) NOT NULL,

  CONSTRAINT "chat_conversations_pkey" PRIMARY KEY ("id"),
  CONSTRAINT "chat_conversations_createdByPlayerId_fkey"
    FOREIGN KEY ("createdByPlayerId") REFERENCES "PlayerProfile"("id")
    ON DELETE SET NULL ON UPDATE CASCADE
);

CREATE UNIQUE INDEX "chat_conversations_directKey_key"
  ON "chat_conversations"("directKey");

CREATE INDEX "chat_conversations_lastMessageAt_updatedAt_idx"
  ON "chat_conversations"("lastMessageAt", "updatedAt");

CREATE TABLE "chat_conversation_participants" (
  "id" TEXT NOT NULL,
  "conversationId" TEXT NOT NULL,
  "playerId" TEXT NOT NULL,
  "joinedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "lastReadAt" TIMESTAMP(3),
  "mutedAt" TIMESTAMP(3),

  CONSTRAINT "chat_conversation_participants_pkey" PRIMARY KEY ("id"),
  CONSTRAINT "chat_conversation_participants_conversationId_fkey"
    FOREIGN KEY ("conversationId") REFERENCES "chat_conversations"("id")
    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT "chat_conversation_participants_playerId_fkey"
    FOREIGN KEY ("playerId") REFERENCES "PlayerProfile"("id")
    ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE UNIQUE INDEX "chat_conversation_participants_conversationId_playerId_key"
  ON "chat_conversation_participants"("conversationId", "playerId");

CREATE INDEX "chat_conversation_participants_playerId_joinedAt_idx"
  ON "chat_conversation_participants"("playerId", "joinedAt");

CREATE TABLE "chat_messages" (
  "id" TEXT NOT NULL,
  "conversationId" TEXT NOT NULL,
  "senderPlayerId" TEXT NOT NULL,
  "kind" "ChatMessageKind" NOT NULL DEFAULT 'TEXT',
  "body" TEXT NOT NULL,
  "attachmentUrl" TEXT,
  "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "editedAt" TIMESTAMP(3),
  "deletedAt" TIMESTAMP(3),

  CONSTRAINT "chat_messages_pkey" PRIMARY KEY ("id"),
  CONSTRAINT "chat_messages_conversationId_fkey"
    FOREIGN KEY ("conversationId") REFERENCES "chat_conversations"("id")
    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT "chat_messages_senderPlayerId_fkey"
    FOREIGN KEY ("senderPlayerId") REFERENCES "PlayerProfile"("id")
    ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE INDEX "chat_messages_conversationId_createdAt_idx"
  ON "chat_messages"("conversationId", "createdAt");

CREATE INDEX "chat_messages_senderPlayerId_createdAt_idx"
  ON "chat_messages"("senderPlayerId", "createdAt");

UPDATE "PlatformConfig"
SET "key" = 'ip_match_win_ranked',
    "description" = 'Impact Points for winning a ranked match'
WHERE "key" = 'xp_match_win_ranked';

UPDATE "PlatformConfig"
SET "key" = 'ip_match_win_friendly',
    "description" = 'Impact Points for winning a friendly match'
WHERE "key" = 'xp_match_win_friendly';

UPDATE "PlatformConfig"
SET "key" = 'ip_match_loss',
    "description" = 'Impact Points for losing any match'
WHERE "key" = 'xp_match_loss';

UPDATE "PlatformConfig"
SET "key" = 'ip_session_present',
    "description" = 'Impact Points for attending session on time'
WHERE "key" = 'xp_session_present';

UPDATE "PlatformConfig"
SET "key" = 'ip_session_late',
    "description" = 'Impact Points for attending session late'
WHERE "key" = 'xp_session_late';

UPDATE "PlatformConfig"
SET "key" = 'ip_drill_complete',
    "description" = 'Impact Points for completing assigned drill'
WHERE "key" = 'xp_drill_complete';

UPDATE "PlatformConfig"
SET "key" = 'ip_batting_50',
    "description" = 'Impact Points for scoring 50+ runs'
WHERE "key" = 'xp_batting_50';

UPDATE "PlatformConfig"
SET "key" = 'ip_batting_100',
    "description" = 'Impact Points for scoring a century'
WHERE "key" = 'xp_batting_100';

UPDATE "PlatformConfig"
SET "key" = 'ip_bowling_5wkt',
    "description" = 'Impact Points for a 5-wicket haul'
WHERE "key" = 'xp_bowling_5wkt';

UPDATE "PlatformConfig"
SET "key" = 'ip_no_show_penalty',
    "description" = 'Impact Points deducted for a no-show'
WHERE "key" = 'xp_no_show_penalty';

UPDATE "PlatformConfig"
SET "description" = 'Enable or disable ranked match Impact Points'
WHERE "key" = 'ranked_matches_enabled';
