-- Monetisation rails. Hidden from users, set to 0 today. Locks in the
-- columns so a future commission rate can be enabled without a migration.

ALTER TABLE "MatchmakingMatch"
  ADD COLUMN "platformFeePaise" INTEGER NOT NULL DEFAULT 0,
  ADD COLUMN "arenaPayoutPaise" INTEGER NOT NULL DEFAULT 0;

ALTER TABLE "Arena"
  ADD COLUMN "commissionRateBpsOverride" INTEGER;

-- Seed the platform-wide commission setting in the existing PlatformConfig
-- key/value table. Default 0 = no commission. Admin can update the value
-- to e.g. '800' (= 8%) without a deploy.
INSERT INTO "PlatformConfig" ("id", "key", "value", "description", "updatedAt")
VALUES (
  'mm_commission_rate_bps',
  'mm_commission_rate_bps',
  '0',
  'Matchmaking commission rate in basis points. 0 = no commission. 800 = 8%.',
  CURRENT_TIMESTAMP
)
ON CONFLICT ("key") DO NOTHING;
