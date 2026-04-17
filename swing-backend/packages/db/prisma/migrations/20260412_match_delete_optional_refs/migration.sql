-- Keep optional performance reviews when their linked app match is deleted.
ALTER TABLE "performance_match_reviews" DROP CONSTRAINT IF EXISTS "performance_match_reviews_matchId_fkey";
ALTER TABLE "performance_match_reviews" ADD CONSTRAINT "performance_match_reviews_matchId_fkey"
  FOREIGN KEY ("matchId") REFERENCES "Match"("id") ON DELETE SET NULL ON UPDATE CASCADE;
