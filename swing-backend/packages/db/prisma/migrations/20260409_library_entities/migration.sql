-- ============================================================
-- Migration: 20260409_library_entities
-- Creates: LibraryStatus enum, drill_library_items,
--          fitness_exercises, nutrition_items, nutrition_recipes
-- ============================================================

-- LibraryStatus enum
DO $$ BEGIN
  CREATE TYPE "LibraryStatus" AS ENUM ('DRAFT', 'REVIEW', 'PUBLISHED', 'ARCHIVED');
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

-- drill_library_items
CREATE TABLE IF NOT EXISTS "drill_library_items" (
  "id"              TEXT NOT NULL,
  "createdById"     TEXT,
  "updatedById"     TEXT,
  "name"            TEXT NOT NULL,
  "slug"            TEXT NOT NULL,
  "description"     TEXT,

  "category"        TEXT,
  "skillArea"       TEXT,
  "subSkill"        TEXT,
  "roleTags"        TEXT[] NOT NULL DEFAULT '{}',
  "goalTags"        TEXT[] NOT NULL DEFAULT '{}',
  "formatTags"      TEXT[] NOT NULL DEFAULT '{}',
  "equipmentTags"   TEXT[] NOT NULL DEFAULT '{}',
  "bodyAreaTags"    TEXT[] NOT NULL DEFAULT '{}',
  "levelTags"       TEXT[] NOT NULL DEFAULT '{}',
  "roleSpecificity" TEXT,
  "recommendedFor"  TEXT[] NOT NULL DEFAULT '{}',

  "difficulty"      TEXT NOT NULL DEFAULT 'BEGINNER',
  "durationMins"    INTEGER,
  "targetUnit"      TEXT,
  "targetValue"     DOUBLE PRECISION,
  "sets"            INTEGER,
  "repsPerSet"      INTEGER,
  "restSeconds"     INTEGER,
  "intensityLevel"  TEXT,
  "recoveryLoad"    TEXT,
  "fatigueImpact"   TEXT,

  "handedness"      TEXT,
  "minAge"          INTEGER,
  "maxAge"          INTEGER,

  "instructions"    JSONB,
  "coachingCues"    TEXT[] NOT NULL DEFAULT '{}',
  "commonMistakes"  TEXT[] NOT NULL DEFAULT '{}',
  "successCriteria" TEXT[] NOT NULL DEFAULT '{}',
  "contraNotes"     TEXT[] NOT NULL DEFAULT '{}',

  "videoUrl"        TEXT,
  "thumbnailUrl"    TEXT,

  "sourceType"      TEXT DEFAULT 'SWING',
  "sourceRef"       TEXT,

  "status"          "LibraryStatus" NOT NULL DEFAULT 'DRAFT',
  "isPublic"        BOOLEAN NOT NULL DEFAULT false,
  "isActive"        BOOLEAN NOT NULL DEFAULT true,
  "sortOrder"       INTEGER NOT NULL DEFAULT 0,
  "usageCount"      INTEGER NOT NULL DEFAULT 0,
  "publishedAt"     TIMESTAMP(3),
  "createdAt"       TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updatedAt"       TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

  CONSTRAINT "drill_library_items_pkey" PRIMARY KEY ("id")
);

CREATE UNIQUE INDEX IF NOT EXISTS "drill_library_items_slug_key" ON "drill_library_items"("slug");
CREATE INDEX IF NOT EXISTS "drill_library_items_status_category_idx" ON "drill_library_items"("status", "category");

-- fitness_exercises
CREATE TABLE IF NOT EXISTS "fitness_exercises" (
  "id"               TEXT NOT NULL,
  "createdById"      TEXT,
  "updatedById"      TEXT,
  "name"             TEXT NOT NULL,
  "slug"             TEXT NOT NULL,
  "description"      TEXT,

  "category"         TEXT,
  "subCategory"      TEXT,
  "goalTags"         TEXT[] NOT NULL DEFAULT '{}',
  "bodyAreaTags"     TEXT[] NOT NULL DEFAULT '{}',
  "roleTags"         TEXT[] NOT NULL DEFAULT '{}',
  "levelTags"        TEXT[] NOT NULL DEFAULT '{}',
  "formatTags"       TEXT[] NOT NULL DEFAULT '{}',
  "equipmentTags"    TEXT[] NOT NULL DEFAULT '{}',
  "recommendedFor"   TEXT[] NOT NULL DEFAULT '{}',
  "avoidIfTags"      TEXT[] NOT NULL DEFAULT '{}',

  "durationMins"     INTEGER,
  "sets"             INTEGER,
  "reps"             INTEGER,
  "repsPerSide"      INTEGER,
  "holdSeconds"      INTEGER,
  "restSeconds"      INTEGER,
  "coolDownSeconds"  INTEGER,
  "targetUnit"       TEXT,
  "targetValue"      DOUBLE PRECISION,

  "intensityLevel"   TEXT,
  "readinessMin"     INTEGER,
  "readinessMax"     INTEGER,
  "fatigueImpact"    TEXT,
  "recoveryLoad"     TEXT,

  "instructions"     JSONB,
  "coachingCues"     TEXT[] NOT NULL DEFAULT '{}',
  "commonMistakes"   TEXT[] NOT NULL DEFAULT '{}',
  "contraNotes"      TEXT[] NOT NULL DEFAULT '{}',
  "progressionNotes" TEXT,
  "regressionNotes"  TEXT,

  "videoUrl"         TEXT,
  "thumbnailUrl"     TEXT,

  "status"           "LibraryStatus" NOT NULL DEFAULT 'DRAFT',
  "isPublic"         BOOLEAN NOT NULL DEFAULT false,
  "isActive"         BOOLEAN NOT NULL DEFAULT true,
  "sortOrder"        INTEGER NOT NULL DEFAULT 0,
  "usageCount"       INTEGER NOT NULL DEFAULT 0,
  "publishedAt"      TIMESTAMP(3),
  "createdAt"        TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updatedAt"        TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

  CONSTRAINT "fitness_exercises_pkey" PRIMARY KEY ("id")
);

CREATE UNIQUE INDEX IF NOT EXISTS "fitness_exercises_slug_key" ON "fitness_exercises"("slug");
CREATE INDEX IF NOT EXISTS "fitness_exercises_status_category_idx" ON "fitness_exercises"("status", "category");

-- nutrition_items
CREATE TABLE IF NOT EXISTS "nutrition_items" (
  "id"                   TEXT NOT NULL,
  "createdById"          TEXT,
  "updatedById"          TEXT,
  "name"                 TEXT NOT NULL,
  "slug"                 TEXT NOT NULL,
  "description"          TEXT,

  "category"             TEXT,
  "subCategory"          TEXT,
  "goalTags"             TEXT[] NOT NULL DEFAULT '{}',
  "timingTags"           TEXT[] NOT NULL DEFAULT '{}',
  "dietTags"             TEXT[] NOT NULL DEFAULT '{}',
  "allergenTags"         TEXT[] NOT NULL DEFAULT '{}',
  "cuisineTags"          TEXT[] NOT NULL DEFAULT '{}',
  "recommendedFor"       TEXT[] NOT NULL DEFAULT '{}',
  "avoidIfTags"          TEXT[] NOT NULL DEFAULT '{}',

  "servingQty"           DOUBLE PRECISION,
  "servingUnit"          TEXT,
  "frequencyNote"        TEXT,
  "prepTimeMins"         INTEGER,
  "bestWindowMinsBefore" INTEGER,
  "bestWindowMinsAfter"  INTEGER,

  "calories"             DOUBLE PRECISION,
  "proteinG"             DOUBLE PRECISION,
  "carbsG"               DOUBLE PRECISION,
  "fatG"                 DOUBLE PRECISION,
  "fiberG"               DOUBLE PRECISION,
  "sugarG"               DOUBLE PRECISION,
  "sodiumMg"             DOUBLE PRECISION,
  "potassiumMg"          DOUBLE PRECISION,
  "waterMl"              DOUBLE PRECISION,

  "hydrationScore"       DOUBLE PRECISION,
  "recoveryScore"        DOUBLE PRECISION,
  "energyScore"          DOUBLE PRECISION,
  "digestibility"        TEXT,

  "matchDaySafe"         BOOLEAN NOT NULL DEFAULT false,
  "heavyMeal"            BOOLEAN NOT NULL DEFAULT false,
  "suitabilityNotes"     TEXT,

  "status"               "LibraryStatus" NOT NULL DEFAULT 'DRAFT',
  "isPublic"             BOOLEAN NOT NULL DEFAULT false,
  "isActive"             BOOLEAN NOT NULL DEFAULT true,
  "sortOrder"            INTEGER NOT NULL DEFAULT 0,
  "usageCount"           INTEGER NOT NULL DEFAULT 0,
  "publishedAt"          TIMESTAMP(3),
  "createdAt"            TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updatedAt"            TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

  CONSTRAINT "nutrition_items_pkey" PRIMARY KEY ("id")
);

CREATE UNIQUE INDEX IF NOT EXISTS "nutrition_items_slug_key" ON "nutrition_items"("slug");
CREATE INDEX IF NOT EXISTS "nutrition_items_status_category_idx" ON "nutrition_items"("status", "category");

-- nutrition_recipes
CREATE TABLE IF NOT EXISTS "nutrition_recipes" (
  "id"              TEXT NOT NULL,
  "nutritionItemId" TEXT NOT NULL,
  "title"           TEXT NOT NULL,
  "description"     TEXT,
  "ingredients"     JSONB,
  "instructions"    JSONB,
  "prepTimeMins"    INTEGER,
  "cookTimeMins"    INTEGER,
  "totalTimeMins"   INTEGER,
  "serves"          INTEGER,
  "videoUrl"        TEXT,
  "thumbnailUrl"    TEXT,
  "isPrimary"       BOOLEAN NOT NULL DEFAULT false,
  "status"          "LibraryStatus" NOT NULL DEFAULT 'DRAFT',
  "createdAt"       TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updatedAt"       TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

  CONSTRAINT "nutrition_recipes_pkey" PRIMARY KEY ("id"),
  CONSTRAINT "nutrition_recipes_nutritionItemId_fkey"
    FOREIGN KEY ("nutritionItemId") REFERENCES "nutrition_items"("id") ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS "nutrition_recipes_nutritionItemId_idx" ON "nutrition_recipes"("nutritionItemId");
