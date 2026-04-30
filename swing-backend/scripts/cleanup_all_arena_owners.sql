-- ─────────────────────────────────────────────────────────────────────────────
-- Cleanup: delete ALL arena owners and every row linked to them
-- Safe to run multiple times (DELETEs are no-ops if rows don't exist)
-- Run inside a transaction — inspect the final SELECT before committing
-- ─────────────────────────────────────────────────────────────────────────────

BEGIN;

DO $$
BEGIN

  -- 1. Leaf: booking add-ons and payments (depend on SlotBooking)
  DELETE FROM "SlotBookingAddon"
  WHERE "bookingId" IN (
    SELECT sb.id FROM "SlotBooking" sb
    JOIN "Arena" a ON a.id = sb."arenaId"
    JOIN "ArenaOwnerProfile" aop ON aop.id = a."ownerId"
  );

  DELETE FROM "Payment"
  WHERE "slotBookingId" IN (
    SELECT sb.id FROM "SlotBooking" sb
    JOIN "Arena" a ON a.id = sb."arenaId"
    JOIN "ArenaOwnerProfile" aop ON aop.id = a."ownerId"
  );

  -- 2. Bookings and monthly passes
  DELETE FROM "SlotBooking"
  WHERE "arenaId" IN (SELECT id FROM "Arena" WHERE "ownerId" IN (SELECT id FROM "ArenaOwnerProfile"));

  DELETE FROM "MonthlyPass"
  WHERE "arenaId" IN (SELECT id FROM "Arena" WHERE "ownerId" IN (SELECT id FROM "ArenaOwnerProfile"));

  -- 3. Unit children (pricing rules, time blocks, addons)
  DELETE FROM "PricingRule"
  WHERE "unitId" IN (
    SELECT au.id FROM "ArenaUnit" au
    JOIN "Arena" a ON a.id = au."arenaId"
    WHERE a."ownerId" IN (SELECT id FROM "ArenaOwnerProfile")
  );

  DELETE FROM "ArenaTimeBlock"
  WHERE "arenaId" IN (SELECT id FROM "Arena" WHERE "ownerId" IN (SELECT id FROM "ArenaOwnerProfile"));

  DELETE FROM "ArenaAddon"
  WHERE "arenaId" IN (SELECT id FROM "Arena" WHERE "ownerId" IN (SELECT id FROM "ArenaOwnerProfile"));

  -- 4. Null out self-referencing parent, then delete units
  UPDATE "ArenaUnit" SET "parentUnitId" = NULL
  WHERE "arenaId" IN (SELECT id FROM "Arena" WHERE "ownerId" IN (SELECT id FROM "ArenaOwnerProfile"));

  DELETE FROM "ArenaUnit"
  WHERE "arenaId" IN (SELECT id FROM "Arena" WHERE "ownerId" IN (SELECT id FROM "ArenaOwnerProfile"));

  -- 5. Arena-level children
  DELETE FROM "ArenaManager"
  WHERE "arenaId" IN (SELECT id FROM "Arena" WHERE "ownerId" IN (SELECT id FROM "ArenaOwnerProfile"));

  DELETE FROM "Review"
  WHERE "arenaId" IN (SELECT id FROM "Arena" WHERE "ownerId" IN (SELECT id FROM "ArenaOwnerProfile"));

  -- 6. Notifications for arena owner users
  DELETE FROM "Notification"
  WHERE "userId" IN (SELECT "userId" FROM "ArenaOwnerProfile");

  -- 7. Arenas
  DELETE FROM "Arena"
  WHERE "ownerId" IN (SELECT id FROM "ArenaOwnerProfile");

  -- 8. Owner profiles
  DELETE FROM "ArenaOwnerProfile";

  -- 9. Strip ARENA_OWNER role from all users who had it
  UPDATE "User"
  SET roles = ARRAY_REMOVE(roles, 'ARENA_OWNER'::"UserRole")
  WHERE 'ARENA_OWNER' = ANY(roles);

  RAISE NOTICE 'All arena owners and linked data deleted.';

END $$;

-- Sanity check — should return 0 rows
SELECT COUNT(*) AS remaining_arena_owners FROM "ArenaOwnerProfile";
SELECT COUNT(*) AS remaining_arenas         FROM "Arena";

-- If counts are 0 → COMMIT
-- If something looks wrong → ROLLBACK
