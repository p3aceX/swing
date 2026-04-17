#!/usr/bin/env bash
set -euo pipefail

# Set your production DB URL here or export it before running.
export DATABASE_URL="${DATABASE_URL:-postgresql://postgres:Nitvik202456@db.pdlqotoyxpzrylxvrmdm.supabase.co:5432/postgres?sslmode=require}"

SCHEMA="./packages/db/prisma/schema.prisma"

echo "Using DATABASE_URL=$DATABASE_URL"
echo "Applying baseline resolves..."

npx prisma migrate resolve --applied 20260318_match_round --schema "$SCHEMA"
npx prisma migrate resolve --applied 20260318_missing_endpoints_additions --schema "$SCHEMA"
npx prisma migrate resolve --applied 20260318_team_roles --schema "$SCHEMA"
npx prisma migrate resolve --applied 20260318_team_type --schema "$SCHEMA"
npx prisma migrate resolve --applied 20260318_tournament_module --schema "$SCHEMA"
npx prisma migrate resolve --applied 20260319_player_jersey_number --schema "$SCHEMA"
npx prisma migrate resolve --applied 20260319_player_level_corporate --schema "$SCHEMA"
npx prisma migrate resolve --applied 20260319_tournament_series_support --schema "$SCHEMA"

echo "Deploying pending migrations..."
npx prisma migrate deploy --schema "$SCHEMA"

echo "Migrations applied successfully."
