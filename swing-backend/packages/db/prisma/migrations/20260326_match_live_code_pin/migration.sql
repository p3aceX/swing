-- AlterTable: Match
ALTER TABLE "Match" ADD COLUMN "liveCode" TEXT,
ADD COLUMN "livePin" TEXT;

-- CreateIndex
CREATE UNIQUE INDEX "Match_liveCode_key" ON "Match"("liveCode");

-- AlterTable: Tournament
ALTER TABLE "Tournament" ADD COLUMN "livePin" TEXT;
