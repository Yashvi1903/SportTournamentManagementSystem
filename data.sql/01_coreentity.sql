-- ============================================================================
-- Sport Tournament Database — Core Entity Seed Data
--
-- This file contains INSERT statements for all CORE (strong) entities that
-- have NO foreign key dependencies. Must be loaded FIRST.
--
-- Tables seeded:
--   1. Person       (30 rows)  P001-P030
--   2. Organizer    (10 rows)  O001-O010
--   3. Tournament   ( 6 rows)  T001-T006
--   4. Sponsors     ( 8 rows)  SP001-SP008
--   5. Sports       ( 8 rows)  S001-S008
--   6. Equipments   (15 rows)  E001-E015
--   7. Coach        (10 rows)  C001-C010
--   8. Venue        ( 8 rows)  V001-V008
--   9. Referee      ( 8 rows)  R001-R008


BEGIN;

-- ============================================================================
-- 1. Person  (person_id, person_name, gender, dob, email_id, contact_no)
-- ============================================================================
INSERT INTO Person (person_id, person_name, gender, dob, email_id, contact_no) VALUES
('P001', 'Aarav Sharma',        'male',   '1998-03-15', 'aarav.sharma@gmail.com',        '9876543210'),
('P002', 'Priya Patel',         'female', '1999-07-22', 'priya.patel@outlook.com',       '9123456780'),
('P003', 'Rohan Mehta',         'male',   '1997-11-05', 'rohan.mehta@yahoo.com',         '9988776655'),
('P004', 'Ananya Reddy',        'female', '2000-01-30', 'ananya.reddy@gmail.com',        '9871234567'),
('P005', 'Vikram Singh',        'male',   '1996-06-18', 'vikram.singh@hotmail.com',      '9765432109'),
('P006', 'Sneha Iyer',          'female', '2001-09-12', 'sneha.iyer@gmail.com',          '9654321098'),
('P007', 'Arjun Nair',          'male',   '1998-12-01', 'arjun.nair@outlook.com',        '9543210987'),
('P008', 'Kavya Joshi',         'female', '2002-04-25', 'kavya.joshi@gmail.com',         '9432109876'),
('P009', 'Rahul Verma',         'male',   '1995-08-14', 'rahul.verma@yahoo.com',         '9321098765'),
('P010', 'Meera Kulkarni',      'female', '2000-02-28', 'meera.kulkarni@gmail.com',      '9210987654'),
('P011', 'Aditya Deshmukh',     'male',   '1999-05-10', 'aditya.deshmukh@outlook.com',   '9109876543'),
('P012', 'Ishita Gupta',        'female', '2001-10-08', 'ishita.gupta@gmail.com',        '9012345678'),
('P013', 'Karthik Menon',       'male',   '1997-03-22', 'karthik.menon@yahoo.com',       '8976543210'),
('P014', 'Divya Chauhan',       'female', '2003-07-17', 'divya.chauhan@gmail.com',       '8765432109'),
('P015', 'Siddharth Rao',       'male',   '1996-11-29', 'siddharth.rao@hotmail.com',     '8654321098'),
('P016', 'Pooja Mishra',        'female', '2000-06-04', 'pooja.mishra@gmail.com',        '8543210987'),
('P017', 'Nikhil Bhat',         'male',   '1998-09-20', 'nikhil.bhat@outlook.com',       '8432109876'),
('P018', 'Riya Saxena',         'female', '2002-01-15', 'riya.saxena@gmail.com',         '8321098765'),
('P019', 'Manish Tiwari',       'male',   '1994-04-07', 'manish.tiwari@yahoo.com',       '8210987654'),
('P020', 'Neha Kapoor',         'female', '2001-12-11', 'neha.kapoor@gmail.com',         '8109876543'),
('P021', 'Amit Pandey',         'male',   '1999-02-19', 'amit.pandey@hotmail.com',       '7976543210'),
('P022', 'Shruti Das',          'female', '2003-08-03', 'shruti.das@gmail.com',          '7865432109'),
('P023', 'Varun Hegde',         'male',   '1997-10-26', 'varun.hegde@outlook.com',       '7754321098'),
('P024', 'Anjali Srinivasan',   'female', '2000-05-14', 'anjali.srini@gmail.com',        '7643210987'),
('P025', 'Deepak Thakur',       'male',   '1995-07-09', 'deepak.thakur@yahoo.com',       '7532109876'),
('P026', 'Tanvi Bhatt',         'female', '2004-03-21', 'tanvi.bhatt@gmail.com',         '7421098765'),
('P027', 'Akash Pillai',        'male',   '1998-06-30', 'akash.pillai@hotmail.com',      '7310987654'),
('P028', 'Sanya Agarwal',       'female', '2001-11-16', 'sanya.agarwal@gmail.com',       '7209876543'),
('P029', 'Neel Banerjee',       'other',  '1993-01-25', 'neel.banerjee@outlook.com',     '7198765432'),
('P030', 'Ravi Krishnan',       'male',   '2005-09-08', 'ravi.krishnan@gmail.com',       '7087654321');


-- ============================================================================
-- 2. Organizer  (member_id, member_name, email_id, contact_no)
-- ============================================================================
INSERT INTO Organizer (member_id, member_name, email_id, contact_no) VALUES
('O001', 'Rajesh Kumar',          'rajesh.kumar@sportsfed.org',     '9876001001'),
('O002', 'Sunita Deshpande',      'sunita.deshpande@sportsfed.org', '9876001002'),
('O003', 'Manoj Pillai',          'manoj.pillai@eventpro.in',       '9876001003'),
('O004', 'Geeta Raman',           'geeta.raman@eventpro.in',        '9876001004'),
('O005', 'Suresh Nambiar',        'suresh.nambiar@tourneyorg.com',  '9876001005'),
('O006', 'Lakshmi Venkatesh',     'lakshmi.v@tourneyorg.com',       '9876001006'),
('O007', 'Prakash Jha',           'prakash.jha@sportsfed.org',      '9876001007'),
('O008', 'Anita Goswami',         'anita.goswami@eventpro.in',      '9876001008'),
('O009', 'Dinesh Choudhary',      'dinesh.choud@tourneyorg.com',    '9876001009'),
('O010', 'Revathi Subramaniam',   'revathi.s@sportsfed.org',        '9876001010');


-- ============================================================================
-- 3. Tournament  (tournament_id, tournament_name, tournament_year, season,
--                 start_date, end_date)
-- ============================================================================
INSERT INTO Tournament (tournament_id, tournament_name, tournament_year, season, start_date, end_date) VALUES
('T001', 'Inter-College Cricket Championship 2024', 2024, 'winter',  '2024-01-15', '2024-01-28'),
('T002', 'National Sports Fest 2024',               2024, 'spring',  '2024-03-10', '2024-03-24'),
('T003', 'Summer Athletics Invitational 2024',      2024, 'summer',  '2024-06-01', '2024-06-15'),
('T004', 'Autumn Multi-Sport League 2024',          2024, 'fall',    '2024-09-15', '2024-09-30'),
('T005', 'All-India University Games 2025',         2025, 'spring',  '2025-02-05', '2025-02-18'),
('T006', 'Winter Badminton Open 2025',              2025, 'winter',  '2025-12-01', '2025-12-14');


-- ============================================================================
-- 4. Sponsors  (sponsor_id, name, contact_no, company)
-- ============================================================================
INSERT INTO Sponsors (sponsor_id, name, contact_no, company) VALUES
('SP001', 'Amit Verma',      '9800100001', 'Nike India'),
('SP002', 'Priya Mehta',     '9800100002', 'Adidas Sports'),
('SP003', 'Rahul Kapoor',    '9800100003', 'Puma India'),
('SP004', 'Sunita Rao',      '9800100004', 'Red Bull India'),
('SP005', 'Manoj Das',       '9800100005', 'Gatorade India'),
('SP006', 'Kavita Nair',     '9800100006', 'Star Sports'),
('SP007', 'Deepak Sharma',   '9800100007', 'Decathlon India'),
('SP008', 'Meena Joshi',     '9800100008', 'Tata Motors Sports');


-- ============================================================================
-- 5. Sports  (sport_id, sport_name)
-- ============================================================================
INSERT INTO Sports (sport_id, sport_name) VALUES
('S001', 'Cricket'),
('S002', 'Football'),
('S003', 'Basketball'),
('S004', 'Tennis'),
('S005', 'Badminton'),
('S006', 'Athletics'),
('S007', 'Table Tennis'),
('S008', 'Volleyball');


-- ============================================================================
-- 6. Equipments  (equipment_id, equipment_name, number, condition)

-- ============================================================================
INSERT INTO Equipments (equipment_id, equipment_name, number, condition) VALUES
('E001', 'Cricket Bat',             20, 'new'),
('E002', 'Cricket Ball (Red)',      50, 'good'),
('E003', 'Cricket Stumps Set',      10, 'new'),
('E004', 'Football',                30, 'good'),
('E005', 'Football Goal Net',        4, 'fair'),
('E006', 'Basketball',              25, 'new'),
('E007', 'Basketball Hoop Net',      6, 'good'),
('E008', 'Tennis Racket',           16, 'good'),
('E009', 'Tennis Ball (Can of 3)',   40, 'new'),
('E010', 'Badminton Racket',        20, 'new'),
('E011', 'Shuttlecock (Box of 12)', 30, 'good'),
('E012', 'Athletics Javelin',        8, 'fair'),
('E013', 'Table Tennis Paddle',     12, 'good'),
('E014', 'Table Tennis Ball',       60, 'new'),
('E015', 'Volleyball',              18, 'poor');


-- ============================================================================
-- 7. Coach  (coach_id, coach_name, contact_no, specification)
-- ============================================================================
INSERT INTO Coach (coach_id, coach_name, contact_no, specification) VALUES
('C001', 'Mahendra Dhoni',      '9900110001', 'Cricket Coach'),
('C002', 'Bhaichung Bhutia',    '9900110002', 'Football Coach'),
('C003', 'Satnam Singh',        '9900110003', 'Basketball Coach'),
('C004', 'Ramesh Krishnan',     '9900110004', 'Tennis Coach'),
('C005', 'Pullela Gopichand',   '9900110005', 'Badminton Coach'),
('C006', 'Neeraj Chopra',       '9900110006', 'Athletics Coach'),
('C007', 'Sharath Kamal',       '9900110007', 'Table Tennis Coach'),
('C008', 'Jimmy George',        '9900110008', 'Volleyball Coach'),
('C009', 'Harinder Sandhu',     '9900110009', 'Fitness Trainer'),
('C010', 'Sunita Sharma',       '9900110010', 'Strength and Conditioning');


-- ============================================================================
-- 8. Venue  (venue_id, venue_name, location, capacity)
--    capacity > 0
-- ============================================================================
INSERT INTO Venue (venue_id, venue_name, location, capacity) VALUES
('V001', 'Main Stadium',              'University Campus, Delhi',       25000),
('V002', 'Indoor Sports Complex',     'Sports Hub, Mumbai',              5000),
('V003', 'Tennis Court A',            'Racquet Club, Bangalore',          800),
('V004', 'Tennis Court B',            'Racquet Club, Bangalore',          800),
('V005', 'Athletics Ground',          'National Centre, Chennai',       15000),
('V006', 'Basketball Arena',          'Sports City, Hyderabad',          3000),
('V007', 'Badminton Hall',            'Gopichand Academy, Hyderabad',    2000),
('V008', 'Multi-Purpose Sports Hall', 'University Campus, Pune',         4000);


-- ============================================================================
-- 9. Referee  (referee_id, referee_name, contact_no)
--    NOTE: DDL has NO email_id column
-- ============================================================================
INSERT INTO Referee (referee_id, referee_name, contact_no) VALUES
('R001', 'Sundaram Ravi',     '9700220001'),
('R002', 'Harpreet Kaur',     '9700220002'),
('R003', 'Mohan Das',         '9700220003'),
('R004', 'Fatima Sheikh',     '9700220004'),
('R005', 'Anil Chettri',      '9700220005'),
('R006', 'Deepa Nair',        '9700220006'),
('R007', 'Rajiv Bose',        '9700220007'),
('R008', 'Swathi Reddy',      '9700220008');


COMMIT;

-- ============================================================================
