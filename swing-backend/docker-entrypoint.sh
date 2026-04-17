#!/bin/sh
set -e

MODE="${SERVICE_MODE:-api}"
RUN_DB_MIGRATIONS="${RUN_DB_MIGRATIONS:-false}"

run_migrations() {
  if [ "$RUN_DB_MIGRATIONS" = "true" ]; then
    SCHEMA="packages/db/prisma/schema.prisma"
    echo "Starting database synchronization..."
    
    # Check if DATABASE_URL is set
    if [ -z "$DATABASE_URL" ]; then
      echo "ERROR: DATABASE_URL is not set. Cannot run migrations."
      exit 1
    fi

    echo "Ensuring Prisma client is synced with manual schema changes..."
    # Older production environments were bootstrapped before migrate deploy
    # was wired into startup. Mark those historical baselines as applied if
    # they are missing, then deploy all pending migrations normally.
    # Note: We mark everything as applied because SQL was run manually.
    npx prisma migrate resolve --applied 20260318_match_round --schema "$SCHEMA" || true
    npx prisma migrate resolve --applied 20260318_missing_endpoints_additions --schema "$SCHEMA" || true
    npx prisma migrate resolve --applied 20260318_team_roles --schema "$SCHEMA" || true
    npx prisma migrate resolve --applied 20260318_team_type --schema "$SCHEMA" || true
    npx prisma migrate resolve --applied 20260318_tournament_module --schema "$SCHEMA" || true
    npx prisma migrate resolve --applied 20260319_player_jersey_number --schema "$SCHEMA" || true
    npx prisma migrate resolve --applied 20260319_player_level_corporate --schema "$SCHEMA" || true
    npx prisma migrate resolve --applied 20260319_tournament_series_support --schema "$SCHEMA" || true
    npx prisma migrate resolve --applied 20260323_session_player_development --schema "$SCHEMA" || true
    npx prisma migrate resolve --applied 20260323_session_qr_columns --schema "$SCHEMA" || true
    npx prisma migrate resolve --applied 20260326_match_live_code_pin --schema "$SCHEMA" || true
    npx prisma migrate resolve --applied 20260326_studio_module --schema "$SCHEMA" || true
    npx prisma migrate resolve --applied 20260326_studio_scheduled_switches --schema "$SCHEMA" || true
    npx prisma migrate resolve --applied 20260327_overlay_pack_assignments --schema "$SCHEMA" || true
    npx prisma migrate resolve --applied 20260328_add_wagon_zone --schema "$SCHEMA" || true
    npx prisma migrate resolve --applied 20260328_ball_outcome_five --schema "$SCHEMA" || true
    npx prisma migrate resolve --applied 20260328_competitive_performance_system --schema "$SCHEMA" || true
    npx prisma migrate resolve --applied 20260331_add_ground_package_pricing --schema "$SCHEMA" || true
    npx prisma migrate resolve --applied 20260331_add_unit_boundary_size --schema "$SCHEMA" || true
    npx prisma migrate resolve --applied 20260408_follow_team_tournament --schema "$SCHEMA" || true
    npx prisma migrate resolve --applied 20260408_apex_elite_journal_v3 --schema "$SCHEMA" || true
    npx prisma migrate resolve --applied 20260408_performance_domain_v3 --schema "$SCHEMA" || true
    npx prisma migrate resolve --applied 20260409_performance_my_plan --schema "$SCHEMA" || true
    npx prisma migrate resolve --applied 20260409_match_cascade_deletes --schema "$SCHEMA" || true
    # journal_streak_days was manually executed in production in some environments.
    # Ensure Prisma history is aligned so migrate deploy does not try to recreate existing table.
    npx prisma migrate resolve --applied 20260409_journal_streak_days --schema "$SCHEMA" || true
    # library_entities was wrongly pre-marked applied without SQL running — execute SQL directly
    # All statements use IF NOT EXISTS so this is safe to run repeatedly
    npx prisma db execute --file packages/db/prisma/migrations/20260409_library_entities/migration.sql --schema "$SCHEMA" || true

    echo "Running final check..."
    npx prisma migrate deploy --schema "$SCHEMA"
    echo "Database synchronization complete."
  fi
}

case "$MODE" in
  api)
    run_migrations
    exec npm run start:api
    ;;
  worker)
    exec npm run start:worker
    ;;
  all)
    export START_WORKERS=true
    run_migrations
    exec npm run start:api
    ;;
  *)
    echo "Unsupported SERVICE_MODE: $MODE"
    echo "Use SERVICE_MODE=api, SERVICE_MODE=worker, or SERVICE_MODE=all"
    exit 1
    ;;
esac
