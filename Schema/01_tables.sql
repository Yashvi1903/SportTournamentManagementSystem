-- ============================================================
-- Sport Tournament Database — Final DDL (PostgreSQL)
-- ============================================================

-- ------------------------------------------------------------
-- HOW TO CREATE AND CONNECT TO THE DATABASE
-- ------------------------------------------------------------
-- Step 1: Open your terminal and login to PostgreSQL as superuser
--         psql -U postgres
--
-- Step 2: Create the database
--         CREATE DATABASE SportTournamentDB;
--
-- Step 3: Connect to the newly created database
--         \c SportTournamentDB
--
-- Step 4: Run this entire SQL file to create all tables
--         to SportTournamentDB, just paste and run this file.
--
-- Step 5: Verify all tables were created successfully
--         \dt
--
-- Optional: To drop and recreate the database fresh
--         DROP DATABASE IF EXISTS SportTournamentDB;
--         CREATE DATABASE SportTournamentDB;
--         \c SportTournamentDB
-- ------------------------------------------------------------


-- ============================================================
-- 1. STRONG ENTITIES (no FK dependencies)
-- ============================================================

CREATE TABLE Person (
    person_id   VARCHAR(10)  PRIMARY KEY,
    person_name VARCHAR(100) NOT NULL,
    gender      VARCHAR(10)  NOT NULL
                    CHECK (LOWER(gender) IN ('male', 'female', 'other')),
    dob         DATE         NOT NULL,
    email_id    VARCHAR(100) NOT NULL UNIQUE
                    CHECK (email_id ~ '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'),
    contact_no  VARCHAR(10)  NOT NULL
                    CHECK (contact_no ~ '^[0-9]{10}$')
);

-- ────────────────────────────────────────────────────────────

CREATE TABLE Organizer (
    member_id   VARCHAR(10)  PRIMARY KEY,
    member_name VARCHAR(100) NOT NULL,
    email_id    VARCHAR(100) NOT NULL UNIQUE
                    CHECK (email_id ~ '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'),
    contact_no  VARCHAR(10)  NOT NULL
                    CHECK (contact_no ~ '^[0-9]{10}$')
);

-- ────────────────────────────────────────────────────────────

CREATE TABLE Tournament (
    tournament_id   VARCHAR(10)  PRIMARY KEY,
    tournament_name VARCHAR(100) NOT NULL,
    tournament_year INT          NOT NULL
                        CHECK (tournament_year BETWEEN 2000 AND 2100),
    season          VARCHAR(20)  NOT NULL
                        CHECK (LOWER(season) IN ('fall', 'spring', 'summer', 'winter')),
    start_date      DATE         NOT NULL,
    end_date        DATE         NOT NULL,
    CONSTRAINT chk_tournament_dates CHECK (end_date >= start_date)
);

-- ────────────────────────────────────────────────────────────

CREATE TABLE Sponsors (
    sponsor_id VARCHAR(10)  PRIMARY KEY,
    name       VARCHAR(100) NOT NULL,
    contact_no VARCHAR(10)  NOT NULL
                   CHECK (contact_no ~ '^[0-9]{10}$'),
    company    VARCHAR(100) NOT NULL
);

-- ────────────────────────────────────────────────────────────

CREATE TABLE Sports (
    sport_id   VARCHAR(10)  PRIMARY KEY,
    sport_name VARCHAR(100) NOT NULL UNIQUE
);

-- ────────────────────────────────────────────────────────────

CREATE TABLE Equipments (
    equipment_id   VARCHAR(10)  PRIMARY KEY,
    equipment_name VARCHAR(100) NOT NULL,
    number         INT          NOT NULL
                       CHECK (number >= 0),
    condition      VARCHAR(50)  NOT NULL
                       CHECK (LOWER(condition) IN ('new', 'good', 'fair', 'poor'))
);

-- ────────────────────────────────────────────────────────────

CREATE TABLE Coach (
    coach_id      VARCHAR(10)  PRIMARY KEY,
    coach_name    VARCHAR(100) NOT NULL,
    contact_no    VARCHAR(10)  NOT NULL
                      CHECK (contact_no ~ '^[0-9]{10}$'),
    specification VARCHAR(100)
);

-- ────────────────────────────────────────────────────────────

CREATE TABLE Venue (
    venue_id   VARCHAR(10)  PRIMARY KEY,
    venue_name VARCHAR(100) NOT NULL,
    location   VARCHAR(255),
    capacity   INT
                   CHECK (capacity > 0)
);

-- ────────────────────────────────────────────────────────────

CREATE TABLE Referee (
    referee_id   VARCHAR(10)  PRIMARY KEY,
    referee_name VARCHAR(100) NOT NULL,
    contact_no   VARCHAR(10)  NOT NULL
                     CHECK (contact_no ~ '^[0-9]{10}$')
);


-- ============================================================
-- 2. SportType — separate table (1:1 with Sports)
-- ============================================================

CREATE TABLE SportType (
    sport_id VARCHAR(10) PRIMARY KEY,
    type     VARCHAR(20) NOT NULL
                 CHECK (LOWER(type) IN ('individual', 'team')),
    CONSTRAINT fk_sporttype_sport
        FOREIGN KEY (sport_id) REFERENCES Sports(sport_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);


-- ============================================================
-- 3. Rules — weak entity under Sports
--    Composite PK (sport_id, rule_no): rule numbers restart per sport
-- ============================================================

CREATE TABLE Rules (
    sport_id VARCHAR(10) NOT NULL,
    rule_no  INT         NOT NULL,
    rules    TEXT        NOT NULL,
    PRIMARY KEY (sport_id, rule_no),
    CONSTRAINT fk_rules_sport
        FOREIGN KEY (sport_id) REFERENCES Sports(sport_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);


-- ============================================================
-- 4. IS-A: Player is a subtype of Person
-- ============================================================

CREATE TABLE Player (
    player_id    VARCHAR(10)  PRIMARY KEY,
    height       NUMERIC(5,2) NOT NULL
                     CHECK (height > 0),
    weight       NUMERIC(5,2) NOT NULL
                     CHECK (weight > 0),
    blood_group  VARCHAR(5)
                     CHECK (blood_group IN ('A+','A-','B+','B-','O+','O-','AB+','AB-')),
    joining_year INT          NOT NULL
                     CHECK (joining_year BETWEEN 1990 AND 2100),
    college_name VARCHAR(100),
    CONSTRAINT fk_player_person
        FOREIGN KEY (player_id) REFERENCES Person(person_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);


-- ============================================================
-- 5. ENTITIES WITH FK DEPENDENCIES
-- ============================================================

-- Team depends on Sports and Player (captain)
CREATE TABLE Team (
    team_id      VARCHAR(10)  PRIMARY KEY,
    team_name    VARCHAR(100) NOT NULL,
    college_name VARCHAR(100),
    sport_id     VARCHAR(10)  NOT NULL,
    captain_id   VARCHAR(10),
    CONSTRAINT uq_team_name_college
        UNIQUE (team_name, college_name),
    CONSTRAINT fk_team_sport
        FOREIGN KEY (sport_id) REFERENCES Sports(sport_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT fk_team_captain
        FOREIGN KEY (captain_id) REFERENCES Player(player_id)
        ON DELETE SET NULL
        ON UPDATE CASCADE
);

-- ────────────────────────────────────────────────────────────

-- Match depends on Sports, Tournament, Venue, Referee
CREATE TABLE Match (
    match_id      VARCHAR(10) PRIMARY KEY,
    sport_id      VARCHAR(10) NOT NULL,
    tournament_id VARCHAR(10) NOT NULL,
    venue_id      VARCHAR(10),
    referee_id    VARCHAR(10),
    date          DATE        NOT NULL,
    time          TIME        NOT NULL,
    duration      INT
                      CHECK (duration > 0),
    match_type    VARCHAR(20) NOT NULL
                      CHECK (LOWER(match_type) IN ('group','quarterfinal','semifinal','final')),
    CONSTRAINT fk_match_sport
        FOREIGN KEY (sport_id) REFERENCES Sports(sport_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT fk_match_tournament
        FOREIGN KEY (tournament_id) REFERENCES Tournament(tournament_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT fk_match_venue
        FOREIGN KEY (venue_id) REFERENCES Venue(venue_id)
        ON DELETE SET NULL
        ON UPDATE CASCADE,
    CONSTRAINT fk_match_referee
        FOREIGN KEY (referee_id) REFERENCES Referee(referee_id)
        ON DELETE SET NULL
        ON UPDATE CASCADE
);

-- ────────────────────────────────────────────────────────────

-- Result depends on Match, Team, Player
-- Exactly one of winner_team_id / winner_player_id must be filled
-- based on winner_type — enforced via CHECK constraint
CREATE TABLE Result (
    result_id        VARCHAR(10)  PRIMARY KEY,
    match_id         VARCHAR(10)  NOT NULL UNIQUE,
    winner_type      VARCHAR(10)  NOT NULL
                         CHECK (LOWER(winner_type) IN ('team', 'individual')),
    winner_team_id   VARCHAR(10),
    winner_player_id VARCHAR(10),
    score_detail     VARCHAR(255),
    outcome          VARCHAR(10)  NOT NULL
                         CHECK (LOWER(outcome) IN ('win', 'loss', 'draw')),
    CONSTRAINT fk_result_match
        FOREIGN KEY (match_id) REFERENCES Match(match_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT fk_result_winner_team
        FOREIGN KEY (winner_team_id) REFERENCES Team(team_id)
        ON DELETE SET NULL
        ON UPDATE CASCADE,
    CONSTRAINT fk_result_winner_player
        FOREIGN KEY (winner_player_id) REFERENCES Player(player_id)
        ON DELETE SET NULL
        ON UPDATE CASCADE,
    CONSTRAINT chk_winner_consistency CHECK (
        (LOWER(winner_type) = 'team'
            AND winner_team_id   IS NOT NULL
            AND winner_player_id IS NULL)
        OR
        (LOWER(winner_type) = 'individual'
            AND winner_player_id IS NOT NULL
            AND winner_team_id   IS NULL)
    )
);


-- ============================================================
-- 6. BRIDGE / RELATIONSHIP TABLES
-- ============================================================

-- Organizer - Tournament  (M:N — organizes_tournament)
CREATE TABLE OrganizeTournament (
    member_id     VARCHAR(10) NOT NULL,
    tournament_id VARCHAR(10) NOT NULL,
    role          VARCHAR(30) NOT NULL
                      CHECK (LOWER(role) IN (
                          'coordinator','manager','assistant','volunteer'
                      )),
    department    VARCHAR(50) NOT NULL
                      CHECK (LOWER(department) IN (
                          'logistics','operations','marketing','finance',
                          'refereeing','medical','hospitality','technical','volunteers'
                      )),
    PRIMARY KEY (member_id, tournament_id),
    CONSTRAINT fk_ot_organizer
        FOREIGN KEY (member_id) REFERENCES Organizer(member_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT fk_ot_tournament
        FOREIGN KEY (tournament_id) REFERENCES Tournament(tournament_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

-- ────────────────────────────────────────────────────────────

-- Person - Tournament  (M:N — has tournament pass)
CREATE TABLE PersonPass (
    person_id         VARCHAR(10) NOT NULL,
    tournament_id     VARCHAR(10) NOT NULL,
    pass_type         VARCHAR(10) NOT NULL
                          CHECK (LOWER(pass_type) IN ('gold','silver','regular')),
    pass_number       VARCHAR(20) NOT NULL,
    registration_date DATE        NOT NULL DEFAULT CURRENT_DATE,
    PRIMARY KEY (person_id, tournament_id),
    CONSTRAINT fk_pp_person
        FOREIGN KEY (person_id) REFERENCES Person(person_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT fk_pp_tournament
        FOREIGN KEY (tournament_id) REFERENCES Tournament(tournament_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

-- ────────────────────────────────────────────────────────────

-- Person - Match  (M:N — view)
CREATE TABLE PersonViewMatch (
    person_id   VARCHAR(10) NOT NULL,
    match_id    VARCHAR(10) NOT NULL,
    seat_number VARCHAR(10),
    PRIMARY KEY (person_id, match_id),
    CONSTRAINT fk_pvm_person
        FOREIGN KEY (person_id) REFERENCES Person(person_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT fk_pvm_match
        FOREIGN KEY (match_id) REFERENCES Match(match_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

-- ────────────────────────────────────────────────────────────

-- Sponsors - Tournament  (M:N — funds)
CREATE TABLE SponsorsTournament (
    sponsor_id    VARCHAR(10)    NOT NULL,
    tournament_id VARCHAR(10)    NOT NULL,
    budget        NUMERIC(12, 2) NOT NULL
                      CHECK (budget >= 0),
    PRIMARY KEY (sponsor_id, tournament_id),
    CONSTRAINT fk_st_sponsor
        FOREIGN KEY (sponsor_id) REFERENCES Sponsors(sponsor_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT fk_st_tournament
        FOREIGN KEY (tournament_id) REFERENCES Tournament(tournament_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

-- ────────────────────────────────────────────────────────────

-- Sports - Equipments  (M:N — requires)
CREATE TABLE SportEquipments (
    sport_id     VARCHAR(10) NOT NULL,
    equipment_id VARCHAR(10) NOT NULL,
    PRIMARY KEY (sport_id, equipment_id),
    CONSTRAINT fk_se_sport
        FOREIGN KEY (sport_id) REFERENCES Sports(sport_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT fk_se_equipment
        FOREIGN KEY (equipment_id) REFERENCES Equipments(equipment_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

-- ────────────────────────────────────────────────────────────

-- Player - Sports  (M:N — played_by)
-- level and experience_years are relationship attributes
CREATE TABLE PlayerSport (
    player_id        VARCHAR(10) NOT NULL,
    sport_id         VARCHAR(10) NOT NULL,
    level            VARCHAR(20) NOT NULL
                         CHECK (LOWER(level) IN (
                             'beginner','intermediate','advanced','professional'
                         )),
    experience_years INT         NOT NULL
                         CHECK (experience_years >= 0),
    PRIMARY KEY (player_id, sport_id),
    CONSTRAINT fk_ps_player
        FOREIGN KEY (player_id) REFERENCES Player(player_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT fk_ps_sport
        FOREIGN KEY (sport_id) REFERENCES Sports(sport_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

-- ────────────────────────────────────────────────────────────

-- Player - Match  (M:N — plays)
CREATE TABLE PlayerPlaysMatch (
    player_id VARCHAR(10) NOT NULL,
    match_id  VARCHAR(10) NOT NULL,
    PRIMARY KEY (player_id, match_id),
    CONSTRAINT fk_ppm_player
        FOREIGN KEY (player_id) REFERENCES Player(player_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT fk_ppm_match
        FOREIGN KEY (match_id) REFERENCES Match(match_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

-- ────────────────────────────────────────────────────────────

-- Player - Team  (M:N — contains)
-- join_date and end_date are relationship attributes
CREATE TABLE PlayerTeam (
    player_id VARCHAR(10) NOT NULL,
    team_id   VARCHAR(10) NOT NULL,
    join_date DATE        NOT NULL,
    end_date  DATE,
    PRIMARY KEY (player_id, team_id),
    CONSTRAINT chk_pt_dates
        CHECK (end_date IS NULL OR end_date >= join_date),
    CONSTRAINT fk_pt_player
        FOREIGN KEY (player_id) REFERENCES Player(player_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT fk_pt_team
        FOREIGN KEY (team_id) REFERENCES Team(team_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

-- ────────────────────────────────────────────────────────────

-- Team - Coach  (M:N — Trains)
-- join_date and end_date are relationship attributes
CREATE TABLE TeamCoach (
    team_id   VARCHAR(10) NOT NULL,
    coach_id  VARCHAR(10) NOT NULL,
    join_date DATE        NOT NULL,
    end_date  DATE,
    PRIMARY KEY (team_id, coach_id),
    CONSTRAINT chk_tc_dates
        CHECK (end_date IS NULL OR end_date >= join_date),
    CONSTRAINT fk_tc_team
        FOREIGN KEY (team_id) REFERENCES Team(team_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT fk_tc_coach
        FOREIGN KEY (coach_id) REFERENCES Coach(coach_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

-- ────────────────────────────────────────────────────────────

-- Team - Match  (M:N — played_by)
CREATE TABLE TeamPlaysMatch (
    team_id  VARCHAR(10) NOT NULL,
    match_id VARCHAR(10) NOT NULL,
    score    INT         NOT NULL DEFAULT 0
                 CHECK (score >= 0),
    PRIMARY KEY (team_id, match_id),
    CONSTRAINT fk_tpm_team
        FOREIGN KEY (team_id) REFERENCES Team(team_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT fk_tpm_match
        FOREIGN KEY (match_id) REFERENCES Match(match_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

-- ────────────────────────────────────────────────────────────

-- PlayerStatistics — weak entity (records relationship)
-- Composite PK: (player_id, match_id)
-- status_type = 'numeric' → status_value must be filled
-- status_type = 'outcome' → status_value must be NULL,
--                            status_name stores 'win'/'lose'/'draw'
CREATE TABLE PlayerStatistics (
    player_id    VARCHAR(10) NOT NULL,
    match_id     VARCHAR(10) NOT NULL,
    status_type  VARCHAR(10) NOT NULL
                     CHECK (LOWER(status_type) IN ('numeric', 'outcome')),
    status_name  VARCHAR(50) NOT NULL,
    status_value INT
                     CHECK (status_value IS NULL OR status_value >= 0),
    PRIMARY KEY (player_id, match_id),
    CONSTRAINT chk_ps_numeric
        CHECK (
            (LOWER(status_type) = 'numeric' AND status_value IS NOT NULL)
            OR
            (LOWER(status_type) = 'outcome' AND status_value IS NULL
                AND LOWER(status_name) IN ('win', 'lose', 'draw'))
        ),
    CONSTRAINT fk_pstat_player
        FOREIGN KEY (player_id) REFERENCES Player(player_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT fk_pstat_match
        FOREIGN KEY (match_id) REFERENCES Match(match_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

-- ────────────────────────────────────────────────────────────

-- TeamStatistics — weak entity (has relationship)
-- Composite PK: (team_id, match_id)
-- Same logic as PlayerStatistics
CREATE TABLE TeamStatistics (
    team_id      VARCHAR(10) NOT NULL,
    match_id     VARCHAR(10) NOT NULL,
    status_type  VARCHAR(10) NOT NULL
                     CHECK (LOWER(status_type) IN ('numeric', 'outcome')),
    status_name  VARCHAR(50) NOT NULL,
    status_value INT
                     CHECK (status_value IS NULL OR status_value >= 0),
    PRIMARY KEY (team_id, match_id),
    CONSTRAINT chk_ts_numeric
        CHECK (
            (LOWER(status_type) = 'numeric' AND status_value IS NOT NULL)
            OR
            (LOWER(status_type) = 'outcome' AND status_value IS NULL
                AND LOWER(status_name) IN ('win', 'lose', 'draw'))
        ),
    CONSTRAINT fk_tstat_team
        FOREIGN KEY (team_id) REFERENCES Team(team_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT fk_tstat_match
        FOREIGN KEY (match_id) REFERENCES Match(match_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);


-- ============================================================
-- END OF DDL
-- ============================================================