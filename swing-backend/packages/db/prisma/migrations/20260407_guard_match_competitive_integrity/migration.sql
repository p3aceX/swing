CREATE OR REPLACE FUNCTION validate_match_playing_xi_overlap()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
  IF EXISTS (
    SELECT 1
    FROM unnest(COALESCE(NEW."teamAPlayerIds", ARRAY[]::TEXT[])) AS team_a(player_id)
    INNER JOIN unnest(COALESCE(NEW."teamBPlayerIds", ARRAY[]::TEXT[])) AS team_b(player_id)
      ON team_a.player_id = team_b.player_id
  ) THEN
    RAISE EXCEPTION 'Match % has overlapping playing XI player IDs', COALESCE(NEW.id, '[pending]')
      USING ERRCODE = '23514';
  END IF;

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS match_playing_xi_overlap_guard ON "Match";
CREATE TRIGGER match_playing_xi_overlap_guard
BEFORE INSERT OR UPDATE OF "teamAPlayerIds", "teamBPlayerIds" ON "Match"
FOR EACH ROW
EXECUTE FUNCTION validate_match_playing_xi_overlap();

CREATE OR REPLACE FUNCTION validate_match_player_membership()
RETURNS trigger
LANGUAGE plpgsql
AS $$
DECLARE
  team_a_ids TEXT[];
  team_b_ids TEXT[];
BEGIN
  SELECT "teamAPlayerIds", "teamBPlayerIds"
  INTO team_a_ids, team_b_ids
  FROM "Match"
  WHERE id = NEW."matchId";

  IF team_a_ids IS NULL OR team_b_ids IS NULL THEN
    RAISE EXCEPTION 'Match % not found while validating player % membership', NEW."matchId", NEW."playerId"
      USING ERRCODE = '23503';
  END IF;

  IF NEW."playerId" = ANY(team_a_ids) AND NEW."playerId" = ANY(team_b_ids) THEN
    RAISE EXCEPTION 'Player % appears on both teams for match %', NEW."playerId", NEW."matchId"
      USING ERRCODE = '23514';
  END IF;

  IF NOT (NEW."playerId" = ANY(team_a_ids) OR NEW."playerId" = ANY(team_b_ids)) THEN
    RAISE EXCEPTION 'Player % is not in the playing XI for match %', NEW."playerId", NEW."matchId"
      USING ERRCODE = '23514';
  END IF;

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS match_player_facts_membership_guard ON "match_player_facts";
CREATE TRIGGER match_player_facts_membership_guard
BEFORE INSERT OR UPDATE OF "matchId", "playerId" ON "match_player_facts"
FOR EACH ROW
EXECUTE FUNCTION validate_match_player_membership();

DROP TRIGGER IF EXISTS match_player_metrics_membership_guard ON "match_player_metrics";
CREATE TRIGGER match_player_metrics_membership_guard
BEFORE INSERT OR UPDATE OF "matchId", "playerId" ON "match_player_metrics"
FOR EACH ROW
EXECUTE FUNCTION validate_match_player_membership();

DROP TRIGGER IF EXISTS match_player_index_scores_membership_guard ON "match_player_index_scores";
CREATE TRIGGER match_player_index_scores_membership_guard
BEFORE INSERT OR UPDATE OF "matchId", "playerId" ON "match_player_index_scores"
FOR EACH ROW
EXECUTE FUNCTION validate_match_player_membership();
