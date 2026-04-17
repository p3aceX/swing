ALTER TYPE "UserRole" ADD VALUE IF NOT EXISTS 'BUSINESS_OWNER';

CREATE TABLE IF NOT EXISTS "business_accounts" (
  "id" TEXT NOT NULL,
  "userId" TEXT NOT NULL,
  "businessName" TEXT NOT NULL,
  "contactName" TEXT,
  "phone" TEXT,
  "email" TEXT,
  "city" TEXT,
  "state" TEXT,
  "address" TEXT,
  "pincode" TEXT,
  "gstNumber" TEXT,
  "panNumber" TEXT,
  "onboardingComplete" BOOLEAN NOT NULL DEFAULT false,
  "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updatedAt" TIMESTAMP(3) NOT NULL,

  CONSTRAINT "business_accounts_pkey" PRIMARY KEY ("id")
);

CREATE UNIQUE INDEX IF NOT EXISTS "business_accounts_userId_key" ON "business_accounts"("userId");
CREATE INDEX IF NOT EXISTS "business_accounts_city_idx" ON "business_accounts"("city");

ALTER TABLE "business_accounts"
  ADD CONSTRAINT "business_accounts_userId_fkey"
  FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE "CoachProfile" ADD COLUMN IF NOT EXISTS "businessAccountId" TEXT;
CREATE UNIQUE INDEX IF NOT EXISTS "CoachProfile_businessAccountId_key" ON "CoachProfile"("businessAccountId");
ALTER TABLE "CoachProfile"
  ADD CONSTRAINT "CoachProfile_businessAccountId_fkey"
  FOREIGN KEY ("businessAccountId") REFERENCES "business_accounts"("id") ON DELETE SET NULL ON UPDATE CASCADE;

ALTER TABLE "Academy" ADD COLUMN IF NOT EXISTS "businessAccountId" TEXT;
CREATE INDEX IF NOT EXISTS "Academy_businessAccountId_idx" ON "Academy"("businessAccountId");
ALTER TABLE "Academy"
  ADD CONSTRAINT "Academy_businessAccountId_fkey"
  FOREIGN KEY ("businessAccountId") REFERENCES "business_accounts"("id") ON DELETE SET NULL ON UPDATE CASCADE;

ALTER TABLE "Arena" ADD COLUMN IF NOT EXISTS "businessAccountId" TEXT;
CREATE INDEX IF NOT EXISTS "Arena_businessAccountId_idx" ON "Arena"("businessAccountId");
ALTER TABLE "Arena"
  ADD CONSTRAINT "Arena_businessAccountId_fkey"
  FOREIGN KEY ("businessAccountId") REFERENCES "business_accounts"("id") ON DELETE SET NULL ON UPDATE CASCADE;

ALTER TABLE "stores" ADD COLUMN IF NOT EXISTS "businessAccountId" TEXT;
CREATE INDEX IF NOT EXISTS "stores_businessAccountId_idx" ON "stores"("businessAccountId");
ALTER TABLE "stores"
  ADD CONSTRAINT "stores_businessAccountId_fkey"
  FOREIGN KEY ("businessAccountId") REFERENCES "business_accounts"("id") ON DELETE SET NULL ON UPDATE CASCADE;
