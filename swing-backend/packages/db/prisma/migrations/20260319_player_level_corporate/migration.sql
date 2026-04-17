DO $$ BEGIN
  ALTER TYPE "PlayerLevel" ADD VALUE 'CORPORATE' AFTER 'CLUB';
EXCEPTION
  WHEN duplicate_object THEN null;
END $$;
