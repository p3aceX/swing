-- Reset legacy business profile data so Swing-Biz can rebuild profiles through
-- the new BusinessAccount-first onboarding flow.
TRUNCATE TABLE
  "Academy",
  "AcademyOwnerProfile",
  "CoachProfile",
  "Arena",
  "ArenaOwnerProfile",
  "ArenaManager"
CASCADE;

UPDATE "User"
SET
  "roles" = array_remove(
    array_remove(
      array_remove(
        array_remove("roles", 'COACH'::"UserRole"),
        'ACADEMY_OWNER'::"UserRole"
      ),
      'ARENA_OWNER'::"UserRole"
    ),
    'ARENA_MANAGER'::"UserRole"
  ),
  "activeRole" = 'BUSINESS_OWNER'::"UserRole"
WHERE "activeRole" IN (
  'COACH'::"UserRole",
  'ACADEMY_OWNER'::"UserRole",
  'ARENA_OWNER'::"UserRole",
  'ARENA_MANAGER'::"UserRole"
);
