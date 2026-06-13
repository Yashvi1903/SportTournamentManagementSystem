-- ============================================================================
-- Sport Tournament Database — Analytical and Operational Queries (PostgreSQL)



-- Query 1: Full Player Profiles with Age
-- Retrieves all players with their personal details, calculating age from dob,
-- and sorting alphabetically by name.
SELECT 
    p.person_id AS player_id,
    p.person_name,
    p.gender,
    EXTRACT(YEAR FROM AGE(p.dob)) AS age,
    pl.blood_group,
    pl.college_name,
    pl.height AS height_cm,
    pl.weight AS weight_kg,
    pl.joining_year
FROM Player pl
JOIN Person p ON pl.player_id = p.person_id
ORDER BY p.person_name;


-- Query 2: Sports and Types
-- Lists all sports and whether they are individual or team sports.
SELECT 
    s.sport_id,
    s.sport_name,
    st.type AS sport_type
FROM Sports s
JOIN SportType st ON s.sport_id = st.sport_id
ORDER BY st.type, s.sport_name;


-- Query 3: Low-Quality or Poor Condition Equipment Report
-- Identifies equipment in 'poor' or 'fair' condition that may need replacement or repair.
SELECT 
    equipment_id,
    equipment_name,
    number AS quantity,
    condition
FROM Equipments
WHERE LOWER(condition) IN ('poor', 'fair')
ORDER BY quantity DESC;


-- Query 4: Detailed Match Schedule
-- Fetches full schedule information for all matches, including sport name,
-- tournament name, venue details, referee name, date, time, and match type.
SELECT 
    m.match_id,
    s.sport_name,
    t.tournament_name,
    v.venue_name,
    v.location AS venue_location,
    r.referee_name AS official_name,
    m.date AS match_date,
    m.time AS match_time,
    m.match_type
FROM Match m
JOIN Sports s ON m.sport_id = s.sport_id
JOIN Tournament t ON m.tournament_id = t.tournament_id
LEFT JOIN Venue v ON m.venue_id = v.venue_id
LEFT JOIN Referee r ON m.referee_id = r.referee_id
ORDER BY m.date, m.time;


-- Query 5: Active Team Rosters with Captains
-- Retrieves team rosters including the players currently in each team and the team captain.
SELECT 
    t.team_name,
    s.sport_name,
    cap.person_name AS captain_name,
    p.person_name AS member_name,
    pt.join_date
FROM Team t
JOIN PlayerTeam pt ON t.team_id = pt.team_id
JOIN Person p ON pt.player_id = p.person_id
JOIN Sports s ON t.sport_id = s.sport_id
LEFT JOIN Person cap ON t.captain_id = cap.person_id
WHERE pt.end_date IS NULL
ORDER BY s.sport_name, t.team_name, p.person_name;


-- Query 6: Coaches and Their Assigned Teams
-- Lists all active coaching assignments, detailing which coach is training which team and for which sport.
SELECT 
    c.coach_name,
    c.specification AS coach_specialty,
    t.team_name,
    s.sport_name,
    tc.join_date AS coaching_start_date
FROM TeamCoach tc
JOIN Coach c ON tc.coach_id = c.coach_id
JOIN Team t ON tc.team_id = t.team_id
JOIN Sports s ON t.sport_id = s.sport_id
WHERE tc.end_date IS NULL
ORDER BY c.coach_name;


-- Query 7: Tournament Sponsors Detail
-- Lists all sponsors, the companies they represent, the tournament they sponsored, and the budget they contributed.
SELECT 
    t.tournament_name,
    sp.company AS sponsor_company,
    sp.name AS contact_person,
    st.budget AS sponsored_amount
FROM SponsorsTournament st
JOIN Sponsors sp ON st.sponsor_id = sp.sponsor_id
JOIN Tournament t ON st.tournament_id = t.tournament_id
ORDER BY t.tournament_name, st.budget DESC;



-- Query 8: Total Sponsorship Budget per Tournament
-- Calculates the total sponsored budget collected for each tournament.
SELECT 
    t.tournament_id,
    t.tournament_name,
    COUNT(st.sponsor_id) AS total_sponsors,
    COALESCE(SUM(st.budget), 0.00) AS total_sponsorship_raised
FROM Tournament t
LEFT JOIN SponsorsTournament st ON t.tournament_id = st.tournament_id
GROUP BY t.tournament_id, t.tournament_name
ORDER BY total_sponsorship_raised DESC;


-- Query 9: Average Height and Weight of Athletes by Sport
-- Finds average physical attributes of players grouped by sport.
SELECT 
    s.sport_name,
    ROUND(AVG(pl.height), 2) AS avg_height_cm,
    ROUND(AVG(pl.weight), 2) AS avg_weight_kg,
    COUNT(pl.player_id) AS active_athlete_count
FROM Sports s
JOIN PlayerSport ps ON s.sport_id = ps.sport_id
JOIN Player pl ON ps.player_id = pl.player_id
GROUP BY s.sport_name
ORDER BY avg_height_cm DESC;


-- Query 10: Match Hosting Count by Venue
-- Ranks venues based on the number of matches hosted, showing location and capacity.
SELECT 
    v.venue_name,
    v.location,
    v.capacity,
    COUNT(m.match_id) AS total_matches_hosted
FROM Venue v
LEFT JOIN Match m ON v.venue_id = m.venue_id
GROUP BY v.venue_id, v.venue_name, v.location, v.capacity
ORDER BY total_matches_hosted DESC, v.venue_name;



-- Query 11: Match Result Summary (Handles Team and Individual Winner Types)
-- Generates a complete report of match outcomes. Resolves winner names from 
-- either the Team or Person (Player) table depending on whether it's a team/individual sport.
SELECT 
    r.result_id,
    m.match_id,
    s.sport_name,
    t.tournament_name,
    m.match_type,
    r.winner_type,
    CASE 
        WHEN LOWER(r.winner_type) = 'team' THEN COALESCE(t_win.team_name, 'No Team / Draw')
        WHEN LOWER(r.winner_type) = 'individual' THEN COALESCE(p_win.person_name, 'No Player / Draw')
        ELSE 'N/A'
    END AS winner_name,
    COALESCE(r.score_detail, 'N/A') AS match_score,
    r.outcome
FROM Result r
JOIN Match m ON r.match_id = m.match_id
JOIN Sports s ON m.sport_id = s.sport_id
JOIN Tournament t ON m.tournament_id = t.tournament_id
LEFT JOIN Team t_win ON r.winner_team_id = t_win.team_id
LEFT JOIN Person p_win ON r.winner_player_id = p_win.person_id
ORDER BY m.date;


-- Query 12: Player Performance Statistics Leaderboard
-- Lists top performing athletes with numeric records (such as runs, goals, points).
SELECT 
    p.person_name AS player_name,
    s.sport_name,
    ps.status_name AS statistic,
    SUM(ps.status_value) AS aggregate_value,
    COUNT(ps.match_id) AS matches_played
FROM PlayerStatistics ps
JOIN Person p ON ps.player_id = p.person_id
JOIN Match m ON ps.match_id = m.match_id
JOIN Sports s ON m.sport_id = s.sport_id
WHERE ps.status_type = 'numeric'
GROUP BY p.person_name, s.sport_name, ps.status_name
ORDER BY aggregate_value DESC;


-- Query 13: Multi-Sport Athletes Report
-- Lists all players registered for more than one sport, showing which sports they play.
SELECT 
    p.person_name AS athlete_name,
    COUNT(ps.sport_id) AS total_sports_played,
    STRING_AGG(s.sport_name, ', ' ORDER BY s.sport_name) AS list_of_sports
FROM PlayerSport ps
JOIN Person p ON ps.player_id = p.person_id
JOIN Sports s ON ps.sport_id = s.sport_id
GROUP BY p.person_id, p.person_name
HAVING COUNT(ps.sport_id) > 1
ORDER BY total_sports_played DESC, p.person_name;


-- Query 14: Pass Registration Summary by Tournament
-- Pivots registration details to show counts of Gold, Silver, and Regular passes per tournament.
SELECT 
    t.tournament_name,
    COUNT(CASE WHEN LOWER(pp.pass_type) = 'gold' THEN 1 END) AS gold_passes_sold,
    COUNT(CASE WHEN LOWER(pp.pass_type) = 'silver' THEN 1 END) AS silver_passes_sold,
    COUNT(CASE WHEN LOWER(pp.pass_type) = 'regular' THEN 1 END) AS regular_passes_sold,
    COUNT(pp.person_id) AS total_passes_issued
FROM Tournament t
LEFT JOIN PersonPass pp ON t.tournament_id = pp.tournament_id
GROUP BY t.tournament_id, t.tournament_name
ORDER BY total_passes_issued DESC;


-- Query 15: Spectator List for Main Stadium matches
-- Lists the names and contact details of spectators who watched matches at the 'Main Stadium' and their seats.
SELECT 
    v.venue_name,
    m.date AS match_date,
    s.sport_name,
    p.person_name AS spectator_name,
    p.email_id AS spectator_email,
    COALESCE(pvm.seat_number, 'General Admission') AS seat_no
FROM PersonViewMatch pvm
JOIN Person p ON pvm.person_id = p.person_id
JOIN Match m ON pvm.match_id = m.match_id
JOIN Venue v ON m.venue_id = v.venue_id
JOIN Sports s ON m.sport_id = s.sport_id
WHERE v.venue_name = 'Main Stadium'
ORDER BY m.date, seat_no;

-- some practice query 
-- Category A: Easy Queries (Filtering, Sorting, and Single-Table Operations)
-- Retrieve the names, emails, and date of birth of all female people in the Person table, sorted by name.
-- List all distinct college names represented by players in the Player table.
-- Find all organizers in the Organizer table whose contact number starts with '9876'.
-- Retrieve all coaches from the Coach table who have 'Coach' in their specification.
-- List all sports from the Sports table sorted in alphabetical order.
-- Retrieve all equipment in the Equipments table that is in either 'poor' or 'fair' condition.
-- Show all tournament passes in the PersonPass table of type 'gold'.
-- Find all venues in the Venue table with a capacity of more than 5,000 spectators.
-- List all matches in the Match table scheduled to take place in the year 2024.
-- Find all sponsors in the Sponsors table who represent companies with 'India' in their name.
-- Category B: Intermediate Queries (Joins, Aggregations, and Grouping)
-- List all matches showing the match ID, the name of the sport played, and the name of the tournament.
-- Find the total number of players registered from each college.
-- Retrieve a list of all active teams along with the names of their captains.
-- Calculate the total budget sponsored for each tournament.
-- Find the average height and weight of players for each blood group.
-- List the coach name, team name, and sport name for all active coaches (where end_date IS NULL in TeamCoach).
-- Find the total number of matches hosted by each venue.
-- List all equipment items alongside the names of the sports that require them (using SportEquipments).
-- Count how many gold, silver, and regular passes have been issued for each tournament.
-- List the rules of all sports that are classified as 'individual' sports.
-- Category C: Advanced Queries (Subqueries, CTEs, Window Functions, and Complex Logic)
-- Identify players who participate in both individual and team sports (referencing PlayerSport and SportType).
-- Find the player(s) who have played the maximum number of matches.
-- Retrieve a complete match report showing:
-- Match ID
-- Sport Name
-- Tournament Name
-- Winner Type (Team or Individual)
-- Winner Name (displaying the team name if a team won, or the player name if an individual won)
-- Score Detail
-- Outcome
-- List all spectators (Person name and email) who have viewed matches of at least 3 different sports.
-- Find the tournament that received the highest total sponsored budget and display the tournament name and the budget.
-- List all players whose height is greater than the average height of all players in their primary sport.
-- Find matches where the outcome was a 'draw' and list the teams involved, the sport, and the match date.
-- For each team sport match, list the name of both teams that played and their respective scores from the match.
-- Rank all players in the 'Athletics' sport based on their best numeric statistic values (e.g. lowest time in seconds) using a window function.
-- List the names of organizers who have organized tournaments in all seasons (Fall, Spring, Summer, Winter).