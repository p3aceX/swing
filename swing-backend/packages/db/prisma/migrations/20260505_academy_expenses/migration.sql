CREATE TYPE "ExpenseCategory" AS ENUM ('SALARY','EQUIPMENT','MAINTENANCE','INFRASTRUCTURE','MARKETING','UTILITIES','OTHER');

CREATE TABLE IF NOT EXISTS "AcademyExpense" (
  "id"          TEXT NOT NULL DEFAULT gen_random_uuid(),
  "academyId"   TEXT NOT NULL,
  "createdBy"   TEXT NOT NULL,
  "category"    "ExpenseCategory" NOT NULL,
  "description" TEXT NOT NULL,
  "amountPaise" INTEGER NOT NULL,
  "date"        TIMESTAMP(3) NOT NULL,
  "payee"       TEXT,
  "receiptUrl"  TEXT,
  "createdAt"   TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updatedAt"   TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT "AcademyExpense_pkey" PRIMARY KEY ("id"),
  CONSTRAINT "AcademyExpense_academyId_fkey" FOREIGN KEY ("academyId") REFERENCES "Academy"("id") ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE INDEX IF NOT EXISTS "AcademyExpense_academyId_idx" ON "AcademyExpense"("academyId");
CREATE INDEX IF NOT EXISTS "AcademyExpense_date_idx"      ON "AcademyExpense"("date");
