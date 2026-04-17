-- Enable trigram index support for fast ILIKE/contains lookups
CREATE EXTENSION IF NOT EXISTS pg_trgm;

-- Players / users
CREATE INDEX IF NOT EXISTS "User_name_trgm_idx"
  ON "User" USING GIN (LOWER("name") gin_trgm_ops);

-- Teams
CREATE INDEX IF NOT EXISTS "Team_name_trgm_idx"
  ON "Team" USING GIN (LOWER("name") gin_trgm_ops);
CREATE INDEX IF NOT EXISTS "Team_shortName_trgm_idx"
  ON "Team" USING GIN (LOWER("shortName") gin_trgm_ops);
CREATE INDEX IF NOT EXISTS "Team_city_trgm_idx"
  ON "Team" USING GIN (LOWER("city") gin_trgm_ops);
CREATE INDEX IF NOT EXISTS "Team_isActive_teamType_createdAt_idx"
  ON "Team"("isActive", "teamType", "createdAt" DESC);

-- Venues
CREATE INDEX IF NOT EXISTS "Venue_name_trgm_idx"
  ON "Venue" USING GIN (LOWER("name") gin_trgm_ops);
CREATE INDEX IF NOT EXISTS "Venue_city_trgm_idx"
  ON "Venue" USING GIN (LOWER("city") gin_trgm_ops);
CREATE INDEX IF NOT EXISTS "Venue_address_trgm_idx"
  ON "Venue" USING GIN (LOWER("address") gin_trgm_ops);

-- Tournaments
CREATE INDEX IF NOT EXISTS "Tournament_name_trgm_idx"
  ON "Tournament" USING GIN (LOWER("name") gin_trgm_ops);
CREATE INDEX IF NOT EXISTS "Tournament_city_trgm_idx"
  ON "Tournament" USING GIN (LOWER("city") gin_trgm_ops);
CREATE INDEX IF NOT EXISTS "Tournament_venueName_trgm_idx"
  ON "Tournament" USING GIN (LOWER("venueName") gin_trgm_ops);
CREATE INDEX IF NOT EXISTS "Tournament_isPublic_status_format_sport_startDate_idx"
  ON "Tournament"("isPublic", "status", "format", "sport", "startDate" DESC);
