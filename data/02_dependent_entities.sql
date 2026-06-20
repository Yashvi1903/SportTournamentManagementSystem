
-- ============================================================================
-- 02_seed_dependent_entities.sql
-- Seed data for dependent entities: SportType, Rules, Player, Team, Match
-- 
-- PREREQUISITE: Must be run AFTER 01_seed_core_entities.sql
-- 
-- References from core entities:
--   Person:     P001 - P030
--   Sports:     S001 (Cricket), S002 (Football), S003 (Basketball),
--               S004 (Tennis), S005 (Badminton), S006 (Athletics),
--               S007 (Table Tennis), S008 (Volleyball)
--   Tournament: T001 - T006
--   Venue:      V001 - V008
--   Referee:    R001 - R008
--   Coach:      C001 - C010
--   Player:     P001 - P025 (subset of Person)
--
-- Tournament date ranges:
--   T001: 2024-03-01 to 2024-03-15  (Spring 2024)
--   T002: 2024-06-01 to 2024-06-20  (Summer 2024)
--   T003: 2024-09-15 to 2024-09-30  (Fall 2024)
--   T004: 2024-12-01 to 2024-12-15  (Winter 2024)
--   T005: 2025-03-10 to 2025-03-25  (Spring 2025)
--   T006: 2025-06-05 to 2025-06-25  (Summer 2025)
-- ============================================================================

BEGIN;

-- ============================================================================
-- 1. SportType (8 rows)
-- ============================================================================
INSERT INTO SportType (sport_id, type) VALUES
    ('S001', 'team'),         -- Cricket
    ('S002', 'team'),         -- Football
    ('S003', 'team'),         -- Basketball
    ('S004', 'individual'),   -- Tennis
    ('S005', 'individual'),   -- Badminton
    ('S006', 'individual'),   -- Athletics
    ('S007', 'individual'),   -- Table Tennis
    ('S008', 'team');         -- Volleyball


-- ============================================================================
-- 2. Rules (~20 rows) — 2-3 rules per sport
-- ============================================================================
INSERT INTO Rules (sport_id, rule_no, rules) VALUES
    -- Cricket (S001) — 3 rules
    ('S001', 1, 'Each team bats for a maximum of 20 overs in a T20 format match.'),
    ('S001', 2, 'A bowler may bowl a maximum of 4 overs per innings.'),
    ('S001', 3, 'A no-ball results in a free hit on the following delivery.'),

    -- Football (S002) — 3 rules
    ('S002', 1, 'Each match consists of two halves of 45 minutes each with a 15-minute break.'),
    ('S002', 2, 'A maximum of 5 substitutions are allowed per team per match.'),
    ('S002', 3, 'Offside rule applies: a player is offside if nearer to the opponents goal line than both the ball and the second-last opponent.'),

    -- Basketball (S003) — 3 rules
    ('S003', 1, 'Each game consists of four quarters of 10 minutes each.'),
    ('S003', 2, 'A player is disqualified after committing 5 personal fouls.'),
    ('S003', 3, 'The shot clock resets to 24 seconds after each change of possession.'),

    -- Tennis (S004) — 2 rules
    ('S004', 1, 'Matches are played as best of 3 sets; a tiebreak is played at 6-6 in each set.'),
    ('S004', 2, 'A player must win by at least 2 points in a tiebreak and 2 games in a set.'),

    -- Badminton (S005) — 2 rules
    ('S005', 1, 'A match is played as best of 3 games, each game played to 21 points.'),
    ('S005', 2, 'If the score reaches 29-all, the player who scores the 30th point wins the game.'),

    -- Athletics (S006) — 3 rules
    ('S006', 1, 'A false start results in immediate disqualification of the offending athlete.'),
    ('S006', 2, 'In field events, each athlete is allowed a maximum of 3 attempts in the final round.'),
    ('S006', 3, 'Athletes must remain within their designated lane during track events of 400m or less.'),

    -- Table Tennis (S007) — 2 rules
    ('S007', 1, 'Each game is played to 11 points; a player must win by at least 2 points.'),
    ('S007', 2, 'Service alternates every 2 points; at deuce (10-10), service alternates every point.'),

    -- Volleyball (S008) — 2 rules
    ('S008', 1, 'A team wins a set by reaching 25 points with a minimum 2-point lead; the fifth set is played to 15.'),
    ('S008', 2, 'Each team is allowed a maximum of 3 consecutive touches before the ball must cross the net.');


-- ============================================================================
-- 3. Player (25 rows) — player_id = P001 to P025
-- ============================================================================
INSERT INTO Player (player_id, height, weight, blood_group, joining_year) VALUES
    ('P001', 175, 72, 'O+',  2018),
    ('P002', 182, 78, 'A+',  2019),
    ('P003', 168, 65, 'B+',  2018),
    ('P004', 190, 88, 'AB+', 2020),
    ('P005', 178, 74, 'O-',  2019),
    ('P006', 165, 60, 'A-',  2021),
    ('P007', 185, 82, 'B-',  2020),
    ('P008', 172, 68, 'O+',  2022),
    ('P009', 180, 76, 'A+',  2019),
    ('P010', 170, 63, 'B+',  2023),
    ('P011', 188, 85, 'AB-', 2020),
    ('P012', 176, 70, 'O+',  2021),
    ('P013', 163, 58, 'A+',  2022),
    ('P014', 195, 95, 'B+',  2019),
    ('P015', 174, 71, 'O-',  2023),
    ('P016', 181, 77, 'AB+', 2020),
    ('P017', 169, 64, 'A-',  2022),
    ('P018', 186, 83, 'B-',  2021),
    ('P019', 177, 73, 'O+',  2022),
    ('P020', 192, 90, 'A+',  2019),
    ('P021', 166, 61, 'B+',  2023),
    ('P022', 183, 79, 'AB+', 2020),
    ('P023', 171, 67, 'O-',  2022),
    ('P024', 189, 86, 'A-',  2021),
    ('P025', 173, 69, 'O+',  2022);


-- ============================================================================
-- 4. Team (12 rows) — 3 teams per TEAM sport
-- ============================================================================
INSERT INTO Team (team_id, sport_id, team_name, college_name, captain_id) VALUES
    -- Cricket (S001)
    ('TM001', 'S001', 'Thunder Strikers',   'Delhi University',          NULL),
    ('TM002', 'S001', 'Royal Challengers',   'Mumbai University',         NULL),
    ('TM003', 'S001', 'Storm Riders',        'Bangalore University',      NULL),

    -- Football (S002)
    ('TM004', 'S002', 'Red Wolves',          'Pune University',           NULL),
    ('TM005', 'S002', 'Blue Hawks',          'Chennai University',        NULL),
    ('TM006', 'S002', 'Golden Eagles',       'Kolkata University',        NULL),

    -- Basketball (S003)
    ('TM007', 'S003', 'Sky Dunkers',         'Hyderabad University',      NULL),
    ('TM008', 'S003', 'Court Kings',         'Jaipur University',         NULL),
    ('TM009', 'S003', 'Hoop Warriors',       'Lucknow University',        NULL),

    -- Volleyball (S008)
    ('TM010', 'S008', 'Net Blazers',         'Ahmedabad University',      NULL),
    ('TM011', 'S008', 'Spike Masters',       'Chandigarh University',     NULL),
    ('TM012', 'S008', 'Block Titans',        'Bhopal University',         NULL);


-- ============================================================================
-- 5. Match (24 rows)
-- ============================================================================
INSERT INTO Match (match_id, sport_id, tournament_id, venue_id, referee_id, date, time,duration, match_type) VALUES
    ('M001', 'S001', 'T001', 'V001', 'R001', '2024-03-02', '09:00:00', 8, 'group'),
('M002', 'S001', 'T001', 'V002', 'R002', '2024-03-05', '14:00:00', 8, 'semifinal'),
('M003', 'S001', 'T001', 'V003', 'R003', '2024-03-10', '18:00:00', 9, 'final'),

('M004', 'S002', 'T001', 'V004', 'R004', '2024-03-03', '09:00:00', 4, 'group'),
('M005', 'S002', 'T001', 'V005', 'R005', '2024-03-07', '14:00:00', 4, 'semifinal'),
('M006', 'S002', 'T001', 'V006', 'R006', '2024-03-12', '18:00:00', 5, 'final'),

('M007', 'S003', 'T002', 'V007', 'R007', '2024-06-02', '09:00:00', 3, 'group'),
('M008', 'S003', 'T002', 'V008', 'R008', '2024-06-06', '14:00:00', 3, 'quarterfinal'),
('M009', 'S003', 'T002', 'V001', 'R001', '2024-06-10', '18:00:00', 4, 'final'),

('M010', 'S004', 'T002', 'V002', 'R002', '2024-06-03', '09:00:00', 4, 'group'),
('M011', 'S004', 'T002', 'V003', 'R003', '2024-06-08', '14:00:00', 4, 'semifinal'),
('M012', 'S004', 'T002', 'V004', 'R004', '2024-06-15', '18:00:00', 5, 'final'),

('M013', 'S005', 'T003', 'V005', 'R005', '2024-09-16', '09:00:00', 3, 'group'),
('M014', 'S005', 'T003', 'V006', 'R006', '2024-09-20', '14:00:00', 3, 'semifinal'),
('M015', 'S005', 'T003', 'V007', 'R007', '2024-09-25', '18:00:00', 4, 'final'),

('M016', 'S006', 'T003', 'V008', 'R008', '2024-09-17', '09:00:00', 5, 'group'),
('M017', 'S006', 'T003', 'V001', 'R001', '2024-09-22', '14:00:00', 5, 'semifinal'),
('M018', 'S006', 'T003', 'V002', 'R002', '2024-09-28', '18:00:00', 6, 'final'),

('M019', 'S007', 'T004', 'V003', 'R003', '2024-12-02', '09:00:00', 3, 'group'),
('M020', 'S007', 'T004', 'V004', 'R004', '2024-12-06', '14:00:00', 3, 'quarterfinal'),
('M021', 'S007', 'T004', 'V005', 'R005', '2024-12-10', '18:00:00', 4, 'final'),

('M022', 'S008', 'T004', 'V006', 'R006', '2024-12-03', '09:00:00', 3, 'group'),
('M023', 'S008', 'T004', 'V007', 'R007', '2024-12-08', '14:00:00', 3, 'semifinal'),
('M024', 'S008', 'T004', 'V008', 'R008', '2024-12-13', '18:00:00', 4, 'final');

COMMIT;
-- ============================================================================
