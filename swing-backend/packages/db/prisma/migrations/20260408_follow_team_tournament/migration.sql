-- CreateEnum
CREATE TYPE "FollowTargetType" AS ENUM ('PLAYER', 'TEAM', 'TOURNAMENT');

-- CreateTable
CREATE TABLE "follows" (
    "id" TEXT NOT NULL,
    "followerId" TEXT NOT NULL,
    "targetId" TEXT NOT NULL,
    "targetType" "FollowTargetType" NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "follows_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "follows_followerId_targetId_targetType_key" ON "follows"("followerId", "targetId", "targetType");

-- CreateIndex
CREATE INDEX "follows_targetId_targetType_createdAt_idx" ON "follows"("targetId", "targetType", "createdAt");

-- AddForeignKey
ALTER TABLE "follows" ADD CONSTRAINT "follows_followerId_fkey" FOREIGN KEY ("followerId") REFERENCES "player_profiles"("id") ON DELETE CASCADE ON UPDATE CASCADE;
