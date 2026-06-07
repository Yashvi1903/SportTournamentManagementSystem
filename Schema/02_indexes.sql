-- ============================================================
-- Sport Tournament Database — Indexes (PostgreSQL)
-- ============================================================

-- ------------------------------------------------------------
-- HOW TO RUN THIS FILE
-- ------------------------------------------------------------
-- Step 1: Connect to the database first
--         psql -U postgres -d SportTournamentDB
--
-- Step 2: Run this file
--
-- NOTE: Primary Keys already have indexes auto-created
--       by PostgreSQL. These indexes are ONLY for columns
--       that are frequently used in:
--       - WHERE clauses (filtering)
--       - JOIN conditions (foreign keys)
--       - ORDER BY / GROUP BY (sorting)
-- ------------------------------------------------------------


-- ============================================================
-- 1. Person
-- ============================================================

-- Login/search by email
CREATE INDEX idx_person_email
    ON Person(email_id);

-- Search/filter by name
CREATE INDEX idx_person_name
    ON Person(person_name);


-- ============================================================
-- 2. Organizer
-- ============================================================

-- Login/search by email
CREATE INDEX idx_organizer_email
    ON Organizer(email_id);


-- ============================================================
-- 3. Tournament
-- ============================================================

-- Filter tournaments by year
CREATE INDEX idx_tournament_year
    ON Tournament(tournament_year);

-- Filter tournaments by season
CREATE INDEX idx_tournament_season
    ON Tournament(season);

-- Filter by date range (very common query)
CREATE INDEX idx_tournament_dates
    ON Tournament(start_date, end_date);


-- ============================================================
-- 4. Player
-- ============================================================

-- FK join — Player → Person (IS-A lookup)
CREATE INDEX idx_player_person
    ON Player(player_id);

-- Filter players by college
CREATE INDEX idx_player_college
    ON Player(college_name);


-- ============================================================
-- 5. Team
-- ============================================================

-- FK join — Team → Sports (very frequent)
CREATE INDEX idx_team_sport
    ON Team(sport_id);

-- FK join — Team → Player (captain lookup)
CREATE INDEX idx_team_captain
    ON Team(captain_id);

-- Search teams by college
CREATE INDEX idx_team_college
    ON Team(college_name);


-- ============================================================
-- 6. Match
-- ============================================================

-- FK join — Match → Tournament (most common join)
CREATE INDEX idx_match_tournament
    ON Match(tournament_id);

-- FK join — Match → Sports
CREATE INDEX idx_match_sport
    ON Match(sport_id);

-- FK join — Match → Venue
CREATE INDEX idx_match_venue
    ON Match(venue_id);

-- FK join — Match → Referee
CREATE INDEX idx_match_referee
    ON Match(referee_id);

-- Filter matches by date
CREATE INDEX idx_match_date
    ON Match(date);

-- Filter matches by type (group/semifinal/final etc.)
CREATE INDEX idx_match_type
    ON Match(match_type);


-- ============================================================
-- 7. Result
-- ============================================================

-- FK join — Result → Match (one result per match)
CREATE INDEX idx_result_match
    ON Result(match_id);

-- Filter results by winner type
CREATE INDEX idx_result_winner_type
    ON Result(winner_type);

-- FK join — Result → winning Team
CREATE INDEX idx_result_winner_team
    ON Result(winner_team_id);

-- FK join — Result → winning Player
CREATE INDEX idx_result_winner_player
    ON Result(winner_player_id);


-- ============================================================
-- 8. OrganizeTournament
-- ============================================================

-- FK join — find all tournaments of an organizer
CREATE INDEX idx_ot_member
    ON OrganizeTournament(member_id);

-- FK join — find all organizers of a tournament
CREATE INDEX idx_ot_tournament
    ON OrganizeTournament(tournament_id);


-- ============================================================
-- 9. PersonPass
-- ============================================================

-- FK join — find all passes of a person
CREATE INDEX idx_pp_person
    ON PersonPass(person_id);

-- FK join — find all passes for a tournament
CREATE INDEX idx_pp_tournament
    ON PersonPass(tournament_id);

-- Filter by pass type
CREATE INDEX idx_pp_pass_type
    ON PersonPass(pass_type);


-- ============================================================
-- 10. PersonViewMatch
-- ============================================================

-- FK join — find all matches a person viewed
CREATE INDEX idx_pvm_person
    ON PersonViewMatch(person_id);

-- FK join — find all viewers of a match
CREATE INDEX idx_pvm_match
    ON PersonViewMatch(match_id);


-- ============================================================
-- 11. SponsorsTournament
-- ============================================================

-- FK join — find all tournaments a sponsor funded
CREATE INDEX idx_st_sponsor
    ON SponsorsTournament(sponsor_id);

-- FK join — find all sponsors of a tournament
CREATE INDEX idx_st_tournament
    ON SponsorsTournament(tournament_id);


-- ============================================================
-- 12. SportEquipments
-- ============================================================

-- FK join — find all equipment for a sport
CREATE INDEX idx_se_sport
    ON SportEquipments(sport_id);

-- FK join — find all sports using an equipment
CREATE INDEX idx_se_equipment
    ON SportEquipments(equipment_id);


-- ============================================================
-- 13. PlayerSport
-- ============================================================

-- FK join — find all sports a player plays
CREATE INDEX idx_psport_player
    ON PlayerSport(player_id);

-- FK join — find all players of a sport
CREATE INDEX idx_psport_sport
    ON PlayerSport(sport_id);

-- Filter by level (beginner/advanced etc.)
CREATE INDEX idx_psport_level
    ON PlayerSport(level);


-- ============================================================
-- 14. PlayerPlaysMatch
-- ============================================================

-- FK join — find all matches a player played
CREATE INDEX idx_ppm_player
    ON PlayerPlaysMatch(player_id);

-- FK join — find all players in a match
CREATE INDEX idx_ppm_match
    ON PlayerPlaysMatch(match_id);


-- ============================================================
-- 15. PlayerTeam
-- ============================================================

-- FK join — find all teams a player belongs to
CREATE INDEX idx_pt_player
    ON PlayerTeam(player_id);

-- FK join — find all players in a team
CREATE INDEX idx_pt_team
    ON PlayerTeam(team_id);


-- ============================================================
-- 16. TeamCoach
-- ============================================================

-- FK join — find all coaches of a team
CREATE INDEX idx_tc_team
    ON TeamCoach(team_id);

-- FK join — find all teams a coach trains
CREATE INDEX idx_tc_coach
    ON TeamCoach(coach_id);


-- ============================================================
-- 17. TeamPlaysMatch
-- ============================================================

-- FK join — find all matches a team played
CREATE INDEX idx_tpm_team
    ON TeamPlaysMatch(team_id);

-- FK join — find all teams in a match
CREATE INDEX idx_tpm_match
    ON TeamPlaysMatch(match_id);


-- ============================================================
-- 18. PlayerStatistics
-- ============================================================

-- FK join — find all stats of a player
CREATE INDEX idx_pstat_player
    ON PlayerStatistics(player_id);

-- FK join — find all stats in a match
CREATE INDEX idx_pstat_match
    ON PlayerStatistics(match_id);

-- Filter by status type (numeric/outcome)
CREATE INDEX idx_pstat_type
    ON PlayerStatistics(status_type);


-- ============================================================
-- 19. TeamStatistics
-- ============================================================

-- FK join — find all stats of a team
CREATE INDEX idx_tstat_team
    ON TeamStatistics(team_id);

-- FK join — find all stats in a match
CREATE INDEX idx_tstat_match
    ON TeamStatistics(match_id);

-- Filter by status type (numeric/outcome)
CREATE INDEX idx_tstat_type
    ON TeamStatistics(status_type);


-- ============================================================
-- END OF INDEXES
-- ============================================================