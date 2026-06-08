-- ============================================================
-- Sport Tournament Database — Stored Procedures (PostgreSQL)
-- ============================================================

-- ============================================================
-- PROCEDURE 1: Register a Person for a Tournament Pass
--              Checks if tournament is active before inserting
-- ============================================================

CREATE OR REPLACE PROCEDURE sp_register_tournament_pass(
    p_person_id       VARCHAR(10),
    p_tournament_id   VARCHAR(10),
    p_pass_type       VARCHAR(10),
    p_pass_number     VARCHAR(20)
)
LANGUAGE plpgsql AS $$
DECLARE
    v_end_date DATE;
BEGIN
    -- Check tournament exists and is not ended
    SELECT end_date INTO v_end_date
    FROM Tournament
    WHERE tournament_id = p_tournament_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Tournament (tournament_id = %) does not exist', p_tournament_id;
    END IF;

    IF CURRENT_DATE > v_end_date THEN
        RAISE EXCEPTION
            'Tournament (tournament_id = %) has already ended on %',
            p_tournament_id, v_end_date;
    END IF;

    -- Insert the pass
    INSERT INTO PersonPass (
        person_id, tournament_id, pass_type, pass_number, registration_date
    ) VALUES (
        p_person_id, p_tournament_id, p_pass_type, p_pass_number, CURRENT_DATE
    );

    RAISE NOTICE 'Pass registered for person_id = % for tournament_id = %',
        p_person_id, p_tournament_id;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Failed to register pass: %', SQLERRM;
END;
$$;



-- ============================================================
-- PROCEDURE 2: Record Match Result
--              Inserts result, validates winner played
--              in the match
-- ============================================================

CREATE OR REPLACE PROCEDURE sp_record_result(
    p_result_id        VARCHAR(10),
    p_match_id         VARCHAR(10),
    p_winner_type      VARCHAR(10),
    p_winner_team_id   VARCHAR(10),
    p_winner_player_id VARCHAR(10),
    p_score_detail     VARCHAR(255),
    p_outcome          VARCHAR(10)
)
LANGUAGE plpgsql AS $$
BEGIN
    -- Check match exists
    IF NOT EXISTS (SELECT 1 FROM Match WHERE match_id = p_match_id) THEN
        RAISE EXCEPTION 'Match (match_id = %) does not exist', p_match_id;
    END IF;

    -- Check result does not already exist for this match
    IF EXISTS (SELECT 1 FROM Result WHERE match_id = p_match_id) THEN
        RAISE EXCEPTION
            'Result already exists for match_id = %', p_match_id;
    END IF;

    -- Validate winner played in the match
    IF LOWER(p_winner_type) = 'team' THEN
        IF NOT EXISTS (
            SELECT 1 FROM TeamPlaysMatch
            WHERE match_id = p_match_id AND team_id = p_winner_team_id
        ) THEN
            RAISE EXCEPTION
                'Winner team (team_id = %) did not play in match (match_id = %)',
                p_winner_team_id, p_match_id;
        END IF;
    ELSIF LOWER(p_winner_type) = 'individual' THEN
        IF NOT EXISTS (
            SELECT 1 FROM PlayerPlaysMatch
            WHERE match_id = p_match_id AND player_id = p_winner_player_id
        ) THEN
            RAISE EXCEPTION
                'Winner player (player_id = %) did not play in match (match_id = %)',
                p_winner_player_id, p_match_id;
        END IF;
    END IF;

    -- Insert result
    INSERT INTO Result (
        result_id, match_id, winner_type,
        winner_team_id, winner_player_id, score_detail, outcome
    ) VALUES (
        p_result_id, p_match_id, p_winner_type,
        p_winner_team_id, p_winner_player_id, p_score_detail, p_outcome
    );

    RAISE NOTICE 'Result recorded for match_id = %', p_match_id;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Failed to record result: %', SQLERRM;
END;
$$;


-- ============================================================
-- PROCEDURE 3: Remove a Player from a Team
--              Sets end_date instead of deleting the record
--              to preserve history
-- ============================================================

CREATE OR REPLACE PROCEDURE sp_remove_player_from_team(
    p_player_id VARCHAR(10),
    p_team_id   VARCHAR(10),
    p_end_date  DATE
)
LANGUAGE plpgsql AS $$
BEGIN
    -- Check the membership exists and is still active
    IF NOT EXISTS (
        SELECT 1 FROM PlayerTeam
        WHERE player_id = p_player_id
          AND team_id   = p_team_id
          AND end_date  IS NULL
    ) THEN
        RAISE EXCEPTION
            'No active membership found for player_id = % in team_id = %',
            p_player_id, p_team_id;
    END IF;

    -- Set end_date to mark as inactive
    UPDATE PlayerTeam
    SET end_date = p_end_date
    WHERE player_id = p_player_id
      AND team_id   = p_team_id;

    -- If this player was the captain, remove captaincy
    UPDATE Team
    SET captain_id = NULL
    WHERE team_id    = p_team_id
      AND captain_id = p_player_id;

    RAISE NOTICE 'Player % removed from team % on %', p_player_id, p_team_id, p_end_date;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Failed to remove player from team: %', SQLERRM;
END;
$$;


-- ============================================================
-- PROCEDURE 4: Assign Coach to Team
--              Validates coach and team exist,
--              then inserts into TeamCoach
-- ============================================================

CREATE OR REPLACE PROCEDURE sp_assign_coach_to_team(
    p_coach_id  VARCHAR(10),
    p_team_id   VARCHAR(10),
    p_join_date DATE
)
LANGUAGE plpgsql AS $$
BEGIN
    -- Check coach exists
    IF NOT EXISTS (SELECT 1 FROM Coach WHERE coach_id = p_coach_id) THEN
        RAISE EXCEPTION 'Coach (coach_id = %) does not exist', p_coach_id;
    END IF;

    -- Check team exists
    IF NOT EXISTS (SELECT 1 FROM Team WHERE team_id = p_team_id) THEN
        RAISE EXCEPTION 'Team (team_id = %) does not exist', p_team_id;
    END IF;

    -- Check not already assigned and active
    IF EXISTS (
        SELECT 1 FROM TeamCoach
        WHERE coach_id = p_coach_id
          AND team_id  = p_team_id
          AND end_date IS NULL
    ) THEN
        RAISE EXCEPTION
            'Coach (coach_id = %) is already actively assigned to team (team_id = %)',
            p_coach_id, p_team_id;
    END IF;

    INSERT INTO TeamCoach (team_id, coach_id, join_date)
    VALUES (p_team_id, p_coach_id, p_join_date);

    RAISE NOTICE 'Coach % assigned to team % from %', p_coach_id, p_team_id, p_join_date;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Failed to assign coach: %', SQLERRM;
END;
$$;


-- ============================================================
-- PROCEDURE 5: Add Player Statistics for a Match
--              Validates player played in the match,
--              then inserts the stat row
-- ============================================================

CREATE OR REPLACE PROCEDURE sp_add_player_statistic(
    p_player_id   VARCHAR(10),
    p_match_id    VARCHAR(10),
    p_status_type VARCHAR(10),
    p_status_name VARCHAR(50),
    p_status_value INT
)
LANGUAGE plpgsql AS $$
BEGIN
    -- Check player actually played in this match
    IF NOT EXISTS (
        SELECT 1 FROM PlayerPlaysMatch
        WHERE player_id = p_player_id
          AND match_id  = p_match_id
    ) THEN
        RAISE EXCEPTION
            'Player (player_id = %) did not play in match (match_id = %)',
            p_player_id, p_match_id;
    END IF;

    -- Validate outcome type has no numeric value
    IF LOWER(p_status_type) = 'outcome' AND p_status_value IS NOT NULL THEN
        RAISE EXCEPTION
            'status_value must be NULL when status_type is outcome';
    END IF;

    -- Validate numeric type must have a value
    IF LOWER(p_status_type) = 'numeric' AND p_status_value IS NULL THEN
        RAISE EXCEPTION
            'status_value cannot be NULL when status_type is numeric';
    END IF;

    INSERT INTO PlayerStatistics (
        player_id, match_id, status_type, status_name, status_value
    ) VALUES (
        p_player_id, p_match_id, p_status_type, p_status_name, p_status_value
    );

    RAISE NOTICE 'Statistic added for player_id = % in match_id = %',
        p_player_id, p_match_id;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Failed to add player statistic: %', SQLERRM;
END;
$$;

-- ============================================================