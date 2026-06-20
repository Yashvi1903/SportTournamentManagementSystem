-- ============================================================
-- Must be run AFTER 02_dependent_entities.sql
--
-- Tables seeded (in order):
--   1.  OrganizeTournament
--   2.  PersonPass
--   3.  SponsorsTournament
--   4.  SportEquipments
--   5.  PlayerSport
--   6.  PlayerTeam
--   7.  PlayerPlaysMatch
--   8.  TeamPlaysMatch
--   9.  TeamCoach
--   10. PersonViewMatch
--   11. Result
--   12. PlayerStatistics
--   13. TeamStatistics
--
-- ============================================================

-- ============================================================
-- 1. OrganizeTournament (~15 rows)
-- ============================================================
INSERT INTO OrganizeTournament (member_id, tournament_id, role, department) VALUES
('O001', 'T001', 'coordinator', 'operations'),
('O002', 'T001', 'manager', 'logistics'),
('O003', 'T001', 'assistant', 'refereeing'),
('O001', 'T002', 'coordinator', 'operations'),
('O004', 'T002', 'manager', 'marketing'),
('O005', 'T002', 'volunteer', 'hospitality'),
('O002', 'T003', 'coordinator', 'operations'),
('O006', 'T003', 'manager', 'finance'),
('O007', 'T003', 'assistant', 'medical'),
('O003', 'T004', 'coordinator', 'logistics'),
('O008', 'T004', 'manager', 'technical'),
('O004', 'T005', 'coordinator', 'operations'),
('O009', 'T005', 'assistant', 'volunteers'),
('O005', 'T006', 'coordinator', 'marketing'),
('O010', 'T006', 'manager', 'hospitality');


-- ============================================================
-- 2. PersonPass (~20 rows)
-- ============================================================
INSERT INTO PersonPass (person_id, tournament_id, pass_type, pass_number, registration_date) VALUES
('P001', 'T001', 'gold',    'PASS001', '2024-03-10'),
('P002', 'T001', 'silver',  'PASS002', '2024-03-12'),
('P003', 'T001', 'regular', 'PASS003', '2024-03-15'),
('P005', 'T001', 'gold',    'PASS004', '2024-04-01'),
('P006', 'T002', 'silver',  'PASS005', '2024-06-05'),
('P007', 'T002', 'gold',    'PASS006', '2024-06-10'),
('P008', 'T002', 'regular', 'PASS007', '2024-06-12'),
('P009', 'T002', 'silver',  'PASS008', '2024-07-01'),
('P010', 'T003', 'gold',    'PASS009', '2024-09-05'),
('P011', 'T003', 'silver',  'PASS010', '2024-09-10'),
('P013', 'T003', 'regular', 'PASS011', '2024-09-15'),
('P015', 'T003', 'gold',    'PASS012', '2024-10-01'),
('P016', 'T004', 'silver',  'PASS013', '2024-12-05'),
('P018', 'T004', 'regular', 'PASS014', '2024-12-10'),
('P019', 'T005', 'gold',    'PASS015', '2025-03-05'),
('P020', 'T005', 'silver',  'PASS016', '2025-03-10'),
('P021', 'T005', 'regular', 'PASS017', '2025-04-01'),
('P022', 'T006', 'gold',    'PASS018', '2025-06-05'),
('P024', 'T006', 'silver',  'PASS019', '2025-06-10'),
('P026', 'T001', 'regular', 'PASS020', '2024-03-20');


-- ============================================================
-- 3. SponsorsTournament (~15 rows)
-- ============================================================
INSERT INTO SponsorsTournament (sponsor_id, tournament_id, budget) VALUES
('SP001', 'T001', 500000.00),
('SP002', 'T001', 300000.00),
('SP003', 'T002', 750000.00),
('SP004', 'T002', 200000.00),
('SP001', 'T003', 600000.00),
('SP005', 'T003', 450000.00),
('SP006', 'T004', 350000.00),
('SP002', 'T004', 280000.00),
('SP007', 'T005', 900000.00),
('SP003', 'T005', 400000.00),
('SP008', 'T005', 150000.00),
('SP004', 'T006', 550000.00),
('SP006', 'T006', 320000.00),
('SP001', 'T006', 700000.00),
('SP008', 'T002', 180000.00);


-- ============================================================
-- 4. SportEquipments (~20 rows)
-- ============================================================
INSERT INTO SportEquipments (sport_id, equipment_id) VALUES
-- Cricket (S001)
('S001', 'E001'),   -- bat
('S001', 'E002'),   -- ball
('S001', 'E003'),   -- gloves
('S001', 'E004'),   -- helmet
-- Football (S002)
('S002', 'E005'),   -- football
('S002', 'E006'),   -- goal net
('S002', 'E007'),   -- shin guards
-- Basketball (S003)
('S003', 'E008'),   -- basketball
('S003', 'E009'),   -- hoop/backboard
-- Tennis (S004)
('S004', 'E010'),   -- tennis racket
('S004', 'E002'),   -- ball (shared)
-- Badminton (S005)
('S005', 'E011'),   -- badminton racket
('S005', 'E012'),   -- shuttlecock
-- Athletics (S006)
('S006', 'E013'),   -- stopwatch
('S006', 'E014'),   -- hurdles
-- Table Tennis (S007)
('S007', 'E015'),   -- table tennis paddle
('S007', 'E002'),   -- ball (shared)
-- Volleyball (S008)
('S008', 'E005'),   -- volleyball (shared ball category)
('S008', 'E006'),   -- net (shared net category)
('S008', 'E003');   -- knee pads (shared gloves/pads category)


-- ============================================================
-- 5. PlayerSport (~35 rows)
-- ============================================================
INSERT INTO PlayerSport (player_id, sport_id, level, experience_years) VALUES
-- Cricket (S001): P001-P005
('P001', 'S001', 'professional', 10),
('P002', 'S001', 'advanced', 7),
('P003', 'S001', 'intermediate', 4),
('P004', 'S001', 'advanced', 6),
('P005', 'S001', 'beginner', 1),
-- Football (S002): P004-P008 (P004,P005 overlap with Cricket)
('P004', 'S002', 'professional', 8),
('P005', 'S002', 'intermediate', 3),
('P006', 'S002', 'advanced', 6),
('P007', 'S002', 'intermediate', 4),
('P008', 'S002', 'beginner', 2),
-- Basketball (S003): P007-P011 (P007,P008 overlap with Football)
('P007', 'S003', 'advanced', 5),
('P008', 'S003', 'intermediate', 3),
('P009', 'S003', 'professional', 9),
('P010', 'S003', 'advanced', 6),
('P011', 'S003', 'beginner', 1),
-- Tennis (S004): P010-P013 (P010 overlaps with Basketball)
('P010', 'S004', 'professional', 8),
('P011', 'S004', 'intermediate', 3),
('P012', 'S004', 'advanced', 5),
('P013', 'S004', 'beginner', 1),
-- Badminton (S005): P013-P016 (P013 overlaps with Tennis)
('P013', 'S005', 'advanced', 6),
('P014', 'S005', 'professional', 10),
('P015', 'S005', 'intermediate', 4),
('P016', 'S005', 'beginner', 2),
-- Athletics (S006): P016-P019 (P016 overlaps with Badminton)
('P016', 'S006', 'intermediate', 3),
('P017', 'S006', 'professional', 11),
('P018', 'S006', 'advanced', 7),
('P019', 'S006', 'beginner', 1),
-- Table Tennis (S007): P019-P022 (P019 overlaps with Athletics)
('P019', 'S007', 'advanced', 5),
('P020', 'S007', 'professional', 9),
('P021', 'S007', 'intermediate', 3),
('P022', 'S007', 'beginner', 1),
-- Volleyball (S008): P022-P025 (P022 overlaps with Table Tennis)
('P022', 'S008', 'advanced', 6),
('P023', 'S008', 'professional', 8),
('P024', 'S008', 'intermediate', 4),
('P025', 'S008', 'beginner', 2);


-- ============================================================
-- 6. PlayerTeam (~30 rows)
-- ============================================================
INSERT INTO PlayerTeam (player_id, team_id, join_date, end_date) VALUES
-- Cricket Team TM001 (4 players)
('P001', 'TM001', '2023-01-15', NULL),
('P002', 'TM001', '2023-02-01', NULL),
('P003', 'TM001', '2023-03-10', NULL),
('P004', 'TM001', '2023-04-01', NULL),
-- Cricket Team TM002 (4 players)
('P002', 'TM002', '2023-06-01', NULL),
('P003', 'TM002', '2023-06-15', NULL),
('P004', 'TM002', '2023-07-01', NULL),
('P005', 'TM002', '2023-07-15', NULL),
-- Cricket Team TM003 (3 players)
('P001', 'TM003', '2023-09-01', NULL),
('P005', 'TM003', '2023-09-15', NULL),
('P003', 'TM003', '2023-10-01', NULL),
-- Football Team TM004 (4 players)
('P004', 'TM004', '2023-01-20', NULL),
('P005', 'TM004', '2023-02-10', NULL),
('P006', 'TM004', '2023-03-01', NULL),
('P007', 'TM004', '2023-03-15', NULL),
-- Football Team TM005 (3 players)
('P006', 'TM005', '2023-05-01', NULL),
('P007', 'TM005', '2023-05-15', NULL),
('P008', 'TM005', '2023-06-01', NULL),
-- Football Team TM006 (3 players)
('P004', 'TM006', '2023-08-01', NULL),
('P005', 'TM006', '2023-08-15', NULL),
('P008', 'TM006', '2023-09-01', NULL),
-- Basketball Team TM007 (4 players)
('P007', 'TM007', '2022-11-01', NULL),
('P008', 'TM007', '2022-11-15', NULL),
('P009', 'TM007', '2022-12-01', NULL),
('P010', 'TM007', '2023-01-01', NULL),
-- Basketball Team TM008 (3 players)
('P009', 'TM008', '2023-03-01', NULL),
('P010', 'TM008', '2023-03-15', NULL),
('P011', 'TM008', '2023-04-01', NULL),
-- Basketball Team TM009 (3 players)
('P007', 'TM009', '2023-06-01', NULL),
('P008', 'TM009', '2023-06-15', NULL),
('P011', 'TM009', '2023-07-01', NULL),
-- Volleyball Team TM010 (4 players)
('P022', 'TM010', '2023-02-01', NULL),
('P023', 'TM010', '2023-02-15', NULL),
('P024', 'TM010', '2023-03-01', NULL),
('P025', 'TM010', '2023-03-15', NULL),
-- Volleyball Team TM011 (3 players)
('P022', 'TM011', '2023-05-01', NULL),
('P023', 'TM011', '2023-05-15', NULL),
('P024', 'TM011', '2023-06-01', NULL),
-- Volleyball Team TM012 (3 players)
('P023', 'TM012', '2023-08-01', NULL),
('P024', 'TM012', '2023-08-15', NULL),
('P025', 'TM012', '2023-09-01', NULL);


-- ============================================================
-- 7. PlayerPlaysMatch (~40 rows)
-- ============================================================
INSERT INTO PlayerPlaysMatch (player_id, match_id) VALUES
-- Cricket matches M001-M003 (players registered for S001: P001-P005)
('P001', 'M001'),
('P002', 'M001'),
('P003', 'M001'),
('P004', 'M001'),
('P001', 'M002'),
('P002', 'M002'),
('P004', 'M002'),
('P005', 'M002'),
('P001', 'M003'),
('P003', 'M003'),
('P005', 'M003'),
-- Football matches M004-M006 (players registered for S002: P004-P008)
('P004', 'M004'),
('P005', 'M004'),
('P006', 'M004'),
('P007', 'M004'),
('P006', 'M005'),
('P007', 'M005'),
('P008', 'M005'),
('P004', 'M006'),
('P005', 'M006'),
('P008', 'M006'),
-- Basketball matches M007-M009 (players registered for S003: P007-P011)
('P007', 'M007'),
('P008', 'M007'),
('P009', 'M007'),
('P010', 'M007'),
('P009', 'M008'),
('P010', 'M008'),
('P011', 'M008'),
('P007', 'M009'),
('P008', 'M009'),
('P011', 'M009'),
-- Tennis matches M010-M012 (players registered for S004: P010-P013)
('P010', 'M010'),
('P012', 'M010'),
('P011', 'M011'),
('P013', 'M011'),
('P010', 'M012'),
('P013', 'M012'),
-- Badminton matches M013-M015 (players registered for S005: P013-P016)
('P013', 'M013'),
('P014', 'M013'),
('P014', 'M014'),
('P015', 'M014'),
('P015', 'M015'),
('P016', 'M015'),
-- Athletics matches M016-M018 (players registered for S006: P016-P019)
('P016', 'M016'),
('P017', 'M016'),
('P018', 'M016'),
('P017', 'M017'),
('P018', 'M017'),
('P019', 'M017'),
('P016', 'M018'),
('P017', 'M018'),
('P019', 'M018'),
-- Table Tennis matches M019-M021 (players registered for S007: P019-P022)
('P019', 'M019'),
('P020', 'M019'),
('P020', 'M020'),
('P021', 'M020'),
('P021', 'M021'),
('P022', 'M021'),
-- Volleyball matches M022-M024 (players registered for S008: P022-P025)
('P022', 'M022'),
('P023', 'M022'),
('P024', 'M022'),
('P025', 'M022'),
('P022', 'M023'),
('P023', 'M023'),
('P024', 'M023'),
('P023', 'M024'),
('P024', 'M024'),
('P025', 'M024');


-- ============================================================
-- 8. TeamPlaysMatch (~24 rows)
-- ============================================================
INSERT INTO TeamPlaysMatch (team_id, match_id, score) VALUES
-- Cricket matches
('TM001', 'M001', 245),
('TM002', 'M001', 230),
('TM002', 'M002', 198),
('TM003', 'M002', 210),
('TM001', 'M003', 275),
('TM003', 'M003', 260),
-- Football matches
('TM004', 'M004', 3),
('TM005', 'M004', 1),
('TM005', 'M005', 2),
('TM006', 'M005', 2),
('TM004', 'M006', 4),
('TM006', 'M006', 0),
-- Basketball matches
('TM007', 'M007', 98),
('TM008', 'M007', 85),
('TM008', 'M008', 76),
('TM009', 'M008', 80),
('TM007', 'M009', 102),
('TM009', 'M009', 95),
-- Volleyball matches
('TM010', 'M022', 25),
('TM011', 'M022', 21),
('TM011', 'M023', 18),
('TM012', 'M023', 25),
('TM010', 'M024', 23),
('TM012', 'M024', 25);


-- ============================================================
-- 9. TeamCoach (~12 rows)
-- ============================================================
INSERT INTO TeamCoach (team_id, coach_id, join_date, end_date) VALUES
('TM001', 'C001', '2022-06-01', NULL),
('TM002', 'C002', '2022-07-15', NULL),
('TM003', 'C003', '2022-09-01', NULL),
('TM004', 'C004', '2022-05-01', NULL),
('TM005', 'C005', '2022-08-01', NULL),
('TM006', 'C004', '2023-01-01', NULL),
('TM007', 'C006', '2022-10-01', NULL),
('TM008', 'C007', '2022-11-15', NULL),
('TM009', 'C006', '2023-03-01', NULL),
('TM010', 'C008', '2022-12-01', NULL),
('TM011', 'C009', '2023-02-01', NULL),
('TM012', 'C010', '2023-04-01', NULL);


-- ============================================================
-- 10. PersonViewMatch (~30 rows)
-- ============================================================
INSERT INTO PersonViewMatch (person_id, match_id, seat_number) VALUES
-- Non-player spectators (P026-P030) watching various matches
('P026', 'M001', 'A1'),
('P026', 'M004', 'B3'),
('P026', 'M010', 'C5'),
('P027', 'M002', 'A2'),
('P027', 'M007', 'D1'),
('P027', 'M013', NULL),
('P028', 'M003', 'A5'),
('P028', 'M005', 'B7'),
('P028', 'M016', NULL),
('P029', 'M006', 'C2'),
('P029', 'M008', 'D4'),
('P029', 'M019', 'E1'),
('P030', 'M009', 'A8'),
('P030', 'M014', NULL),
('P030', 'M022', 'F2'),
-- Players watching matches of OTHER sports
('P001', 'M004', 'G1'),   
('P002', 'M007', 'G2'),   
('P006', 'M010', 'G3'),   
('P009', 'M013', NULL),   
('P012', 'M016', 'G5'),   
('P014', 'M019', 'G6'),   
('P017', 'M022', NULL),   
('P020', 'M001', 'G8'),   
('P023', 'M007', 'G9'),   
('P025', 'M004', NULL),   
('P003', 'M019', 'H1'),   
('P015', 'M022', 'H2'),   
('P018', 'M002', 'H3'),   
('P021', 'M005', 'H4'),   
('P011', 'M024', 'H5');   


-- ============================================================
-- 11. Result (~20 rows)
-- ============================================================
INSERT INTO Result (result_id, match_id, winner_type, winner_team_id, winner_player_id, outcome) VALUES
-- Cricket (team sport) M001-M003
('RES001', 'M001', 'team', 'TM001', NULL, 'win'),         
('RES002', 'M002', 'team', 'TM003', NULL, 'win'),         
('RES003', 'M003', 'team', 'TM001', NULL, 'win'),         
-- Football (team sport) M004-M006
('RES004', 'M004', 'team', 'TM004', NULL, 'win'),         
('RES005', 'M005', 'team', NULL, NULL, 'draw'),            
('RES006', 'M006', 'team', 'TM004', NULL, 'win'),         
-- Basketball (team sport) M007-M009
('RES007', 'M007', 'team', 'TM007', NULL, 'win'),         
('RES008', 'M008', 'team', 'TM009', NULL, 'win'),        
('RES009', 'M009', 'team', 'TM007', NULL, 'win'),        
-- Tennis (individual sport) M010-M012
('RES010', 'M010', 'individual', NULL, 'P010', 'win'),   
('RES011', 'M011', 'individual', NULL, 'P011', 'win'),   
('RES012', 'M012', 'individual', NULL, 'P010', 'win'),  
('RES013', 'M013', 'individual', NULL, 'P014', 'win'), 
('RES014', 'M014', 'individual', NULL, 'P014', 'win'), 
('RES015', 'M015', 'individual', NULL, 'P015', 'win'), 
-- Athletics (individual sport) M016-M018
('RES016', 'M016', 'individual', NULL, 'P017', 'win'), 
('RES017', 'M017', 'individual', NULL, 'P017', 'win'), 
('RES018', 'M018', 'individual', NULL, 'P017', 'win'), 
('RES019', 'M019', 'individual', NULL, 'P020', 'win'), 
('RES020', 'M020', 'individual', NULL, 'P020', 'win'); 


INSERT INTO Result (result_id, match_id, winner_type, winner_team_id, winner_player_id, outcome) VALUES
('RES021', 'M021', 'individual', NULL, 'P021', 'win'),    
('RES022', 'M022', 'team', 'TM010', NULL, 'win'),         
('RES023', 'M023', 'team', 'TM012', NULL, 'win'),         
('RES024', 'M024', 'team', 'TM012', NULL, 'win');         


-- ============================================================
-- 12. PlayerStatistics (~25 rows)

-- ============================================================
INSERT INTO PlayerStatistics (player_id, match_id, status_type, status_name, status_value) VALUES
-- Cricket match stats
('P001', 'M001', 'numeric', 'runs', 85),
('P002', 'M001', 'numeric', 'runs', 62),
('P004', 'M001', 'numeric', 'runs', 45),
('P001', 'M002', 'numeric', 'runs', 110),
('P005', 'M002', 'numeric', 'runs', 33),
-- Football match stats
('P004', 'M004', 'numeric', 'goals', 2),
('P006', 'M004', 'numeric', 'goals', 1),
('P007', 'M005', 'numeric', 'goals', 1),
('P008', 'M005', 'numeric', 'goals', 0),
-- Basketball match stats
('P009', 'M007', 'numeric', 'points', 32),
('P010', 'M007', 'numeric', 'points', 24),
('P011', 'M008', 'numeric', 'points', 18),
-- Tennis match stats (outcome based)
('P010', 'M010', 'outcome', 'win', NULL),
('P012', 'M010', 'outcome', 'lose', NULL),
('P011', 'M011', 'outcome', 'win', NULL),
('P013', 'M011', 'outcome', 'lose', NULL),
-- Badminton match stats
('P014', 'M013', 'outcome', 'win', NULL),
('P013', 'M013', 'outcome', 'lose', NULL),
('P015', 'M015', 'outcome', 'win', NULL),
-- Athletics match stats
('P017', 'M016', 'numeric', 'time_seconds', 10),
('P018', 'M016', 'numeric', 'time_seconds', 11),
('P017', 'M017', 'numeric', 'time_seconds', 9),
-- Table Tennis match stats
('P020', 'M019', 'outcome', 'win', NULL),
('P019', 'M019', 'outcome', 'lose', NULL),
-- Volleyball match stats
('P023', 'M022', 'numeric', 'points', 15);


-- ============================================================
-- 13. TeamStatistics (~15 rows)
-- ============================================================
INSERT INTO TeamStatistics (team_id, match_id, status_type, status_name, status_value) VALUES
-- Cricket
('TM001', 'M001', 'outcome', 'win', NULL),
('TM002', 'M001', 'outcome', 'lose', NULL),
('TM003', 'M002', 'outcome', 'win', NULL),
('TM001', 'M003', 'outcome', 'win', NULL),
('TM003', 'M003', 'outcome', 'lose', NULL),
-- Football
('TM004', 'M004', 'numeric', 'goals', 3),
('TM005', 'M004', 'numeric', 'goals', 1),
('TM005', 'M005', 'outcome', 'draw', NULL),
('TM006', 'M005', 'outcome', 'draw', NULL),
('TM004', 'M006', 'numeric', 'goals', 4),
-- Basketball
('TM007', 'M007', 'numeric', 'points', 98),
('TM008', 'M007', 'numeric', 'points', 85),
('TM009', 'M008', 'outcome', 'win', NULL),
-- Volleyball
('TM010', 'M022', 'numeric', 'sets_won', 3),
('TM011', 'M022', 'numeric', 'sets_won', 1);


-- ============================================================
-- UPDATE Team captains
-- ============================================================
UPDATE Team SET captain_id = 'P001' WHERE team_id = 'TM001';
UPDATE Team SET captain_id = 'P004' WHERE team_id = 'TM002';
UPDATE Team SET captain_id = 'P001' WHERE team_id = 'TM003';
UPDATE Team SET captain_id = 'P004' WHERE team_id = 'TM004';
UPDATE Team SET captain_id = 'P006' WHERE team_id = 'TM005';
UPDATE Team SET captain_id = 'P005' WHERE team_id = 'TM006';
UPDATE Team SET captain_id = 'P007' WHERE team_id = 'TM007';
UPDATE Team SET captain_id = 'P009' WHERE team_id = 'TM008';
UPDATE Team SET captain_id = 'P007' WHERE team_id = 'TM009';
UPDATE Team SET captain_id = 'P022' WHERE team_id = 'TM010';
UPDATE Team SET captain_id = 'P023' WHERE team_id = 'TM011';
UPDATE Team SET captain_id = 'P024' WHERE team_id = 'TM012';

-- ============================================================
