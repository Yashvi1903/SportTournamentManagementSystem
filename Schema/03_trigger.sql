-- ============================================================
-- Sport Tournament Database — Triggers (PostgreSQL)
-- ============================================================

-- ------------------------------------------------------------
-- HOW TO RUN THIS FILE
-- ------------------------------------------------------------
-- Step 1: Connect to the database first
--         psql -U postgres -d SportTournamentDB
--
-- Step 2: Run this file after 01_tables.sql and 02_indexes.sql
--
-- NOTE: Triggers are used for rules that cannot be enforced
--       by simple CHECK constraints — such as cross-table
--       validations, auto-updates, and business logic.
-- ------------------------------------------------------------


-- ============================================================
-- TRIGGER 1: Prevent a Player from being their own Captain
--            before insert or update on Team
-- ============================================================

CREATE OR REPLACE FUNCTION fn_check_captain_is_team_member()
RETURNS TRIGGER AS $$
BEGIN
    -- Captain must exist in PlayerTeam for this team
    IF NEW.captain_id IS NOT NULL THEN
        IF NOT EXISTS (
            SELECT 1 FROM PlayerTeam
            WHERE player_id = NEW.captain_id
              AND team_id   = NEW.team_id
        ) THEN
            RAISE EXCEPTION
                'Captain (player_id = %) must be a member of team (team_id = %)',
                NEW.captain_id, NEW.team_id;
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_captain_must_be_team_member
    AFTER INSERT OR UPDATE OF captain_id ON Team
    FOR EACH ROW
    EXECUTE FUNCTION fn_check_captain_is_team_member();


-- ============================================================
-- TRIGGER 2: Prevent a Player from playing a Match whose
--            sport does not match the player's registered
--            sports in PlayerSport
-- ============================================================

CREATE OR REPLACE FUNCTION fn_check_player_sport_match()
RETURNS TRIGGER AS $$
DECLARE
    v_sport_id VARCHAR(10);
BEGIN
    -- Get the sport of the match
    SELECT sport_id INTO v_sport_id
    FROM Match
    WHERE match_id = NEW.match_id;

    -- Check player is registered for that sport
    IF NOT EXISTS (
        SELECT 1 FROM PlayerSport
        WHERE player_id = NEW.player_id
          AND sport_id  = v_sport_id
    ) THEN
        RAISE EXCEPTION
            'Player (player_id = %) is not registered for the sport of match (match_id = %)',
            NEW.player_id, NEW.match_id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_player_sport_match
    BEFORE INSERT ON PlayerPlaysMatch
    FOR EACH ROW
    EXECUTE FUNCTION fn_check_player_sport_match();


-- ============================================================
-- TRIGGER 3: Prevent a Team from playing a Match whose
--            sport does not match the team's sport
-- ============================================================

CREATE OR REPLACE FUNCTION fn_check_team_sport_match()
RETURNS TRIGGER AS $$
DECLARE
    v_match_sport VARCHAR(10);
    v_team_sport  VARCHAR(10);
BEGIN
    SELECT sport_id INTO v_match_sport
    FROM Match WHERE match_id = NEW.match_id;

    SELECT sport_id INTO v_team_sport
    FROM Team WHERE team_id = NEW.team_id;

    IF v_match_sport <> v_team_sport THEN
        RAISE EXCEPTION
            'Team (team_id = %) sport does not match the sport of match (match_id = %)',
            NEW.team_id, NEW.match_id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_team_sport_match
    BEFORE INSERT ON TeamPlaysMatch
    FOR EACH ROW
    EXECUTE FUNCTION fn_check_team_sport_match();


-- ============================================================
-- TRIGGER 4: Prevent duplicate match on same date, time,
--            and venue (no two matches at same place/time)
-- ============================================================

CREATE OR REPLACE FUNCTION fn_check_venue_conflict()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.venue_id IS NOT NULL THEN
        IF EXISTS (
            SELECT 1 FROM Match
            WHERE venue_id = NEW.venue_id
              AND date     = NEW.date
              AND time     = NEW.time
              AND match_id <> NEW.match_id
        ) THEN
            RAISE EXCEPTION
                'Venue (venue_id = %) is already booked on % at %',
                NEW.venue_id, NEW.date, NEW.time;
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_venue_conflict
    BEFORE INSERT OR UPDATE ON Match
    FOR EACH ROW
    EXECUTE FUNCTION fn_check_venue_conflict();


-- ============================================================
-- TRIGGER 5: Prevent a Referee from officiating two matches
--            at the same date and time
-- ============================================================

CREATE OR REPLACE FUNCTION fn_check_referee_conflict()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.referee_id IS NOT NULL THEN
        IF EXISTS (
            SELECT 1 FROM Match
            WHERE referee_id = NEW.referee_id
              AND date       = NEW.date
              AND time       = NEW.time
              AND match_id  <> NEW.match_id
        ) THEN
            RAISE EXCEPTION
                'Referee (referee_id = %) is already assigned to another match on % at %',
                NEW.referee_id, NEW.date, NEW.time;
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_referee_conflict
    BEFORE INSERT OR UPDATE ON Match
    FOR EACH ROW
    EXECUTE FUNCTION fn_check_referee_conflict();


-- ============================================================
-- TRIGGER 6: tournament_year must match the year of start_date
--            e.g. tournament_year = 2024 but start_date = 2025
--            should be rejected
-- ============================================================

CREATE OR REPLACE FUNCTION fn_check_tournament_year()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.tournament_year <> EXTRACT(YEAR FROM NEW.start_date) THEN
        RAISE EXCEPTION
            'tournament_year (%) does not match the year of start_date (%)',
            NEW.tournament_year, NEW.start_date;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_tournament_year
    BEFORE INSERT OR UPDATE ON Tournament
    FOR EACH ROW
    EXECUTE FUNCTION fn_check_tournament_year();


-- ============================================================
-- TRIGGER 7: A match date must fall within its tournament's
--            start_date and end_date
-- ============================================================

CREATE OR REPLACE FUNCTION fn_check_match_date_in_tournament()
RETURNS TRIGGER AS $$
DECLARE
    v_start DATE;
    v_end   DATE;
BEGIN
    SELECT start_date, end_date
    INTO v_start, v_end
    FROM Tournament
    WHERE tournament_id = NEW.tournament_id;

    IF NEW.date < v_start OR NEW.date > v_end THEN
        RAISE EXCEPTION
            'Match date (%) must be between tournament start (%) and end (%) dates',
            NEW.date, v_start, v_end;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_match_date_in_tournament
    BEFORE INSERT OR UPDATE ON Match
    FOR EACH ROW
    EXECUTE FUNCTION fn_check_match_date_in_tournament();


-- ============================================================
-- TRIGGER 8: Player's joining_year must not be before their
--            birth year (dob from Person table)
-- ============================================================

CREATE OR REPLACE FUNCTION fn_check_player_joining_year()
RETURNS TRIGGER AS $$
DECLARE
    v_birth_year INT;
BEGIN
    SELECT EXTRACT(YEAR FROM dob)
    INTO v_birth_year
    FROM Person
    WHERE person_id = NEW.player_id;

    IF NEW.joining_year < v_birth_year THEN
        RAISE EXCEPTION
            'Player joining_year (%) cannot be before birth year (%) for player_id = %',
            NEW.joining_year, v_birth_year, NEW.player_id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_player_joining_year
    BEFORE INSERT OR UPDATE ON Player
    FOR EACH ROW
    EXECUTE FUNCTION fn_check_player_joining_year();


-- ============================================================
-- TRIGGER 9: PlayerTeam join_date must not be before the
--            player's joining_year
-- ============================================================

CREATE OR REPLACE FUNCTION fn_check_playerteam_joindate()
RETURNS TRIGGER AS $$
DECLARE
    v_joining_year INT;
BEGIN
    SELECT joining_year INTO v_joining_year
    FROM Player
    WHERE player_id = NEW.player_id;

    IF EXTRACT(YEAR FROM NEW.join_date) < v_joining_year THEN
        RAISE EXCEPTION
            'PlayerTeam join_date (%) cannot be before player joining_year (%) for player_id = %',
            NEW.join_date, v_joining_year, NEW.player_id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_playerteam_joindate
    BEFORE INSERT OR UPDATE ON PlayerTeam
    FOR EACH ROW
    EXECUTE FUNCTION fn_check_playerteam_joindate();


-- ============================================================
-- TRIGGER 10: Only one Result allowed per Match
--             (UNIQUE on match_id handles this in DDL,
--              but this trigger gives a cleaner error message)
-- ============================================================

CREATE OR REPLACE FUNCTION fn_check_one_result_per_match()
RETURNS TRIGGER AS $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM Result
        WHERE match_id = NEW.match_id
          AND result_id <> NEW.result_id
    ) THEN
        RAISE EXCEPTION
            'A result already exists for match_id = %. Only one result allowed per match.',
            NEW.match_id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_one_result_per_match
    BEFORE INSERT OR UPDATE ON Result
    FOR EACH ROW
    EXECUTE FUNCTION fn_check_one_result_per_match();


-- ============================================================
-- TRIGGER 11: Winner team/player in Result must have actually
--             played in that match
-- ============================================================

CREATE OR REPLACE FUNCTION fn_check_result_winner_played()
RETURNS TRIGGER AS $$
BEGIN
    -- If winner is a team, check TeamPlaysMatch
    IF LOWER(NEW.winner_type) = 'team' AND NEW.winner_team_id IS NOT NULL THEN
        IF NOT EXISTS (
            SELECT 1 FROM TeamPlaysMatch
            WHERE match_id = NEW.match_id
              AND team_id  = NEW.winner_team_id
        ) THEN
            RAISE EXCEPTION
                'Winner team (team_id = %) did not play in match (match_id = %)',
                NEW.winner_team_id, NEW.match_id;
        END IF;
    END IF;

    -- If winner is a player, check PlayerPlaysMatch
    IF LOWER(NEW.winner_type) = 'individual' AND NEW.winner_player_id IS NOT NULL THEN
        IF NOT EXISTS (
            SELECT 1 FROM PlayerPlaysMatch
            WHERE match_id  = NEW.match_id
              AND player_id = NEW.winner_player_id
        ) THEN
            RAISE EXCEPTION
                'Winner player (player_id = %) did not play in match (match_id = %)',
                NEW.winner_player_id, NEW.match_id;
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_result_winner_played
    BEFORE INSERT OR UPDATE ON Result
    FOR EACH ROW
    EXECUTE FUNCTION fn_check_result_winner_played();


-- ============================================================
-- TRIGGER 12: Auto-set registration_date to CURRENT_DATE
--             if not provided in PersonPass
-- ============================================================

CREATE OR REPLACE FUNCTION fn_default_registration_date()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.registration_date IS NULL THEN
        NEW.registration_date := CURRENT_DATE;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_default_registration_date
    BEFORE INSERT ON PersonPass
    FOR EACH ROW
    EXECUTE FUNCTION fn_default_registration_date();


-- ============================================================
-- TRIGGER 13: Prevent a Player from registering a PersonPass
--             for a tournament that has already ended
-- ============================================================

CREATE OR REPLACE FUNCTION fn_check_pass_tournament_active()
RETURNS TRIGGER AS $$
DECLARE
    v_end_date DATE;
BEGIN
    SELECT end_date INTO v_end_date
    FROM Tournament
    WHERE tournament_id = NEW.tournament_id;

    IF CURRENT_DATE > v_end_date THEN
        RAISE EXCEPTION
            'Cannot register pass for tournament (tournament_id = %) that has already ended on %',
            NEW.tournament_id, v_end_date;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_pass_tournament_active
    BEFORE INSERT ON PersonPass
    FOR EACH ROW
    EXECUTE FUNCTION fn_check_pass_tournament_active();


-- ============================================================
-- END OF TRIGGERS
-- ============================================================