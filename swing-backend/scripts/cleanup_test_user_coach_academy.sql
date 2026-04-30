-- ─────────────────────────────────────────────────────────────────────────────
-- Cleanup: remove coach & academy profile data for test user +917977690545
-- Safe to run multiple times (all DELETEs are no-ops if rows don't exist)
-- Run inside a transaction so you can ROLLBACK if something looks wrong
-- ─────────────────────────────────────────────────────────────────────────────

BEGIN;

-- 1. Resolve user ID
DO $$
DECLARE
  v_user_id        TEXT;
  v_coach_id       TEXT;
  v_academy_owner  TEXT;
BEGIN

  SELECT id INTO v_user_id
  FROM "User"
  WHERE phone IN ('7977690545', '+917977690545', '917977690545')
  LIMIT 1;

  IF v_user_id IS NULL THEN
    RAISE EXCEPTION 'User not found for phone 7977690545';
  END IF;

  RAISE NOTICE 'Found user: %', v_user_id;

  -- ── Coach profile cleanup ────────────────────────────────────────────────

  SELECT id INTO v_coach_id FROM "CoachProfile" WHERE "userId" = v_user_id;

  IF v_coach_id IS NOT NULL THEN
    RAISE NOTICE 'Cleaning CoachProfile: %', v_coach_id;

    -- deepest children first (OneOnOneSlot cascades when profile is deleted)
    DELETE FROM "OneOnOneBooking"  WHERE "coachId" = v_coach_id;
    DELETE FROM "OneOnOneProfile"  WHERE "coachId" = v_coach_id;

    DELETE FROM "CoachPayoutRecord"    WHERE "coachId" = v_coach_id;
    DELETE FROM "CoachCompensation"    WHERE "coachId" = v_coach_id;

    DELETE FROM "GigBooking"  WHERE "coachId" = v_coach_id;
    DELETE FROM "GigSlot"     WHERE "coachId" = v_coach_id;
    DELETE FROM "GigPackage"  WHERE "gigListingId" IN (SELECT id FROM "GigListing" WHERE "coachId" = v_coach_id);
    DELETE FROM "GigListing"  WHERE "coachId" = v_coach_id;

    DELETE FROM "ReportCard"           WHERE "coachId" = v_coach_id;
    DELETE FROM "CoachFeedback"        WHERE "coachId" = v_coach_id;
    DELETE FROM "DrillAssignment"      WHERE "coachId" = v_coach_id;
    DELETE FROM "Drill"                WHERE "createdById" = v_user_id;
    DELETE FROM "PlayerSessionSignal"  WHERE "coachId" = v_coach_id;
    DELETE FROM "StudentSessionLog"    WHERE "coachId" = v_coach_id;
    DELETE FROM "SessionLog"           WHERE "coachId" = v_coach_id;
    DELETE FROM "SessionAttendance"    WHERE "sessionId" IN (
      SELECT id FROM "PracticeSession" WHERE "coachId" = v_coach_id
    );
    DELETE FROM "PracticeSession"      WHERE "coachId" = v_coach_id;
    DELETE FROM "SessionSchedule"      WHERE "coachId" = v_coach_id;
    DELETE FROM "AcademyCoach"         WHERE "coachId" = v_coach_id;

    DELETE FROM "CoachProfile"         WHERE id = v_coach_id;
    RAISE NOTICE 'CoachProfile deleted.';
  ELSE
    RAISE NOTICE 'No CoachProfile found — skipping.';
  END IF;

  -- ── Academy owner cleanup ────────────────────────────────────────────────

  SELECT id INTO v_academy_owner
  FROM "AcademyOwnerProfile" WHERE "userId" = v_user_id;

  IF v_academy_owner IS NOT NULL THEN
    RAISE NOTICE 'Cleaning AcademyOwnerProfile: %', v_academy_owner;

    -- delete all academies owned (likely none for a test user)
    DELETE FROM "AcademyCoach"         WHERE "academyId" IN (SELECT id FROM "Academy" WHERE "ownerId" = v_academy_owner);
    DELETE FROM "FeePayment"           WHERE "academyId" IN (SELECT id FROM "Academy" WHERE "ownerId" = v_academy_owner);
    DELETE FROM "FeeStructure"         WHERE "academyId" IN (SELECT id FROM "Academy" WHERE "ownerId" = v_academy_owner);
    DELETE FROM "AcademyEnrollment"    WHERE "academyId" IN (SELECT id FROM "Academy" WHERE "ownerId" = v_academy_owner);
    DELETE FROM "Batch"                WHERE "academyId" IN (SELECT id FROM "Academy" WHERE "ownerId" = v_academy_owner);
    DELETE FROM "SessionAttendance"    WHERE "sessionId" IN (
      SELECT id FROM "PracticeSession"
      WHERE "academyId" IN (SELECT id FROM "Academy" WHERE "ownerId" = v_academy_owner)
    );
    DELETE FROM "PracticeSession"      WHERE "academyId" IN (SELECT id FROM "Academy" WHERE "ownerId" = v_academy_owner);
    DELETE FROM "SessionSchedule"      WHERE "academyId" IN (SELECT id FROM "Academy" WHERE "ownerId" = v_academy_owner);
    DELETE FROM "Announcement"         WHERE "academyId" IN (SELECT id FROM "Academy" WHERE "ownerId" = v_academy_owner);
    DELETE FROM "InventoryItem"        WHERE "academyId" IN (SELECT id FROM "Academy" WHERE "ownerId" = v_academy_owner);
    DELETE FROM "Curriculum"           WHERE "academyId" IN (SELECT id FROM "Academy" WHERE "ownerId" = v_academy_owner);
    DELETE FROM "CoachCompensation"    WHERE "academyId" IN (SELECT id FROM "Academy" WHERE "ownerId" = v_academy_owner);
    DELETE FROM "CoachPayoutRecord"    WHERE "academyId" IN (SELECT id FROM "Academy" WHERE "ownerId" = v_academy_owner);
    DELETE FROM "SkillMatrixSnapshot"  WHERE "academyId" IN (SELECT id FROM "Academy" WHERE "ownerId" = v_academy_owner);
    DELETE FROM "SessionTypeConfig"    WHERE "academyId" IN (SELECT id FROM "Academy" WHERE "ownerId" = v_academy_owner);
    DELETE FROM "SkillArea"            WHERE "academyId" IN (SELECT id FROM "Academy" WHERE "ownerId" = v_academy_owner);
    DELETE FROM "WatchFlag"            WHERE "academyId" IN (SELECT id FROM "Academy" WHERE "ownerId" = v_academy_owner);
    DELETE FROM "Academy"              WHERE "ownerId" = v_academy_owner;

    DELETE FROM "AcademyOwnerProfile"  WHERE id = v_academy_owner;
    RAISE NOTICE 'AcademyOwnerProfile deleted.';
  ELSE
    RAISE NOTICE 'No AcademyOwnerProfile found — skipping.';
  END IF;

  -- ── Remove COACH / ACADEMY_OWNER from user roles array ──────────────────

  UPDATE "User"
  SET roles = ARRAY_REMOVE(ARRAY_REMOVE(roles, 'COACH'::"UserRole"), 'ACADEMY_OWNER'::"UserRole")
  WHERE id = v_user_id;

  RAISE NOTICE 'User roles cleaned. Done.';

END $$;

-- Inspect result before committing
SELECT id, phone, roles, "activeRole" FROM "User"
WHERE phone IN ('7977690545', '+917977690545', '917977690545');

-- If everything looks right → COMMIT
-- If something is wrong   → ROLLBACK
COMMIT;
