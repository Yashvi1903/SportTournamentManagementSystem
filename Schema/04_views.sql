-- ============================================================
-- Sport Tournament Database — Views (PostgreSQL)
-- ============================================================

-- ------------------------------------------------------------
-- HOW TO RUN THIS FILE
-- ------------------------------------------------------------
-- Step 1: Connect to the database first
--         psql -U postgres -d SportTournamentDB
--
-- Step 2: Run this file after SportTournamentDB_Final.sql
--         \i /path/to/view.sql
--
-- Step 3: To see all views created
--         \dv
--
-- Step 4: To query any view
--         SELECT * FROM view_name;
--
-- NOTE: Views simplify complex joins into reusable virtual
--       tables. They do not store data — they are just
--       saved SELECT queries.
-- ------------------------------------------------------------


-- ============================================================
-- VIEW 1: Full Player Profile
--         Combines Person + Player into one readable view
-- ============================================================

CREATE OR REPLACE VIEW vw_player_profile AS
    SELECT
        p.person_id,
        p.person_name,
        p.gender,
        p.dob,
        p.email_id,
        p.contact_no,
        pl.height,
        pl.weight,
        pl.blood_group,
        pl.joining_year,
        pl.college_name
    FROM Person p
    JOIN Player pl ON p.person_id = pl.player_id;


-- ============================================================
-- VIEW 2: Tournament Overview
--         Shows tournament with total matches and sponsors
-- ============================================================

CREATE OR REPLACE VIEW vw_tournament_overview AS
    SELECT
        t.tournament_id,
        t.tournament_name,
        t.tournament_year,
        t.season,
        t.start_date,
        t.end_date,
        COUNT(DISTINCT m.match_id)  AS total_matches,
        COUNT(DISTINCT st.sponsor_id) AS total_sponsors,
        COALESCE(SUM(st.budget), 0)   AS total_sponsorship
    FROM Tournament t
    LEFT JOIN Match m
        ON t.tournament_id = m.tournament_id
    LEFT JOIN SponsorsTournament st
        ON t.tournament_id = st.tournament_id
    GROUP BY
        t.tournament_id,
        t.tournament_name,
        t.tournament_year,
        t.season,
        t.start_date,
        t.end_date;




-- ============================================================
-- VIEW 3: Match Results
--         Shows result with match info, winner details,
--         and outcome
-- ============================================================

CREATE OR REPLACE VIEW vw_match_results AS
    SELECT
        r.result_id,
        m.match_id,
        m.match_type,
        m.date,
        t.tournament_name,
        s.sport_name,
        r.winner_type,
        r.outcome,
        r.score_detail,
        -- Winner team name (NULL if individual sport)
        tm.team_name      AS winner_team_name,
        -- Winner player name (NULL if team sport)
        p.person_name     AS winner_player_name
    FROM Result r
    JOIN Match      m  ON r.match_id        = m.match_id
    JOIN Tournament t  ON m.tournament_id   = t.tournament_id
    JOIN Sports     s  ON m.sport_id        = s.sport_id
    LEFT JOIN Team  tm ON r.winner_team_id  = tm.team_id
    LEFT JOIN Person p ON r.winner_player_id = p.person_id;


-- ============================================================
-- VIEW 4: Team Full Info
--         Shows team with sport name, captain name,
--         and total players
-- ============================================================

CREATE OR REPLACE VIEW vw_team_info AS
    SELECT
        tm.team_id,
        tm.team_name,
        tm.college_name,
        s.sport_name,
        p.person_name     AS captain_name,
        COUNT(pt.player_id) AS total_players
    FROM Team tm
    JOIN Sports     s  ON tm.sport_id   = s.sport_id
    LEFT JOIN Person p ON tm.captain_id = p.person_id
    LEFT JOIN PlayerTeam pt ON tm.team_id = pt.team_id
    GROUP BY
        tm.team_id,
        tm.team_name,
        tm.college_name,
        s.sport_name,
        p.person_name;


-- ============================================================
-- VIEW 5: Player's Team History
--         Shows which teams a player has been part of
--         with join and end dates
-- ============================================================

CREATE OR REPLACE VIEW vw_player_team_history AS
    SELECT
        p.person_id,
        p.person_name,
        t.team_id,
        t.team_name,
        t.college_name,
        s.sport_name,
        pt.join_date,
        pt.end_date,
        CASE
            WHEN pt.end_date IS NULL THEN 'Active'
            ELSE 'Inactive'
        END AS membership_status
    FROM PlayerTeam pt
    JOIN Person p ON pt.player_id  = p.person_id
    JOIN Team   t ON pt.team_id    = t.team_id
    JOIN Sports s ON t.sport_id    = s.sport_id;





-- ============================================================
-- VIEW 6: Active Coaches per Team
--         Shows coaches currently training a team
--         (end_date IS NULL means still active)
-- ============================================================

CREATE OR REPLACE VIEW vw_active_coaches AS
    SELECT
        t.team_id,
        t.team_name,
        t.college_name,
        s.sport_name,
        c.coach_id,
        c.coach_name,
        c.specification,
        c.contact_no,
        tc.join_date
    FROM TeamCoach tc
    JOIN Team   t ON tc.team_id  = t.team_id
    JOIN Coach  c ON tc.coach_id = c.coach_id
    JOIN Sports s ON t.sport_id  = s.sport_id
    WHERE tc.end_date IS NULL;


-- ============================================================
-- VIEW 7: Tournament Sponsors Summary
--          Shows each tournament with all its sponsors
--          and their budget contributions
-- ============================================================

CREATE OR REPLACE VIEW vw_tournament_sponsors AS
    SELECT
        t.tournament_id,
        t.tournament_name,
        t.tournament_year,
        sp.sponsor_id,
        sp.name         AS sponsor_name,
        sp.company,
        st.budget
    FROM SponsorsTournament st
    JOIN Tournament t  ON st.tournament_id = t.tournament_id
    JOIN Sponsors   sp ON st.sponsor_id    = sp.sponsor_id
    ORDER BY t.tournament_year DESC, st.budget DESC;


-- ============================================================
-- VIEW 8: Upcoming Matches
--          Shows all matches scheduled from today onwards
-- ============================================================

CREATE OR REPLACE VIEW vw_upcoming_matches AS
    SELECT
        m.match_id,
        m.date,
        m.time,
        m.match_type,
        m.duration,
        t.tournament_name,
        s.sport_name,
        v.venue_name,
        v.location      AS venue_location,
        r.referee_name
    FROM Match m
    JOIN Tournament t  ON m.tournament_id = t.tournament_id
    JOIN Sports     s  ON m.sport_id      = s.sport_id
    LEFT JOIN Venue   v ON m.venue_id     = v.venue_id
    LEFT JOIN Referee r ON m.referee_id   = r.referee_id
    WHERE m.date >= CURRENT_DATE
    ORDER BY m.date ASC, m.time ASC;



-- ============================================================