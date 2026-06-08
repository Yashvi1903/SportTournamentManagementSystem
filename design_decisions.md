# Sports Tournament Management System
## Database Design Document

**Project:** Concours — Sports Tournament Management System  
**Team:** Yashvi Patel (202403035) · Saloni Vaghela (202403048)  
**Technology:** PostgreSQL · `SportTournamentDB`  
**Version:** 2.0

---

## Table of Contents

1. [Problem Statement](#1-problem-statement)
2. [Why a Database? What Makes This Different?](#2-why-a-database-what-makes-this-different)
3. [Who Uses This System?](#3-who-uses-this-system)
4. [Core Features](#4-core-features)
5. [ER Model — Entities and Their Purpose](#5-er-model--entities-and-their-purpose)
6. [ER Model — Relationships Explained](#6-er-model--relationships-explained)
7. [Schema Overview — All 27 Tables](#7-schema-overview--all-27-tables)
8. [Key Design Choices That Make This Database Strong](#8-key-design-choices-that-make-this-database-strong)
9. [Data Integrity — How Bad Data is Prevented](#9-data-integrity--how-bad-data-is-prevented)
10. [Performance Design — Indexes](#10-performance-design--indexes)
11. [Business Rules Enforced by the Database](#11-business-rules-enforced-by-the-database)
12. [Scalability and Real-World Readiness](#12-scalability-and-real-world-readiness)

---

## 1. Problem Statement

Every year, college sports tournaments like **Concours (DA-IICT)**, Udghosh (IIT Kanpur),
Riviera (VIT), and Shaurya (IIT Kharagpur) face the same recurring problems:

- Match schedules are managed on paper, shared over WhatsApp, and updated on notice boards
- Players fill the same registration form every year, repeating identical personal details
- Results are written by referees on paper, manually typed into spreadsheets hours later
- There is no live scoreboard — spectators have no idea what is happening in another venue
- Historical data (who won last year, player statistics across seasons) simply does not exist
- Venue conflicts happen because no system checks if a ground is already booked
- Communication between organizers, coaches, and players is fragmented across multiple channels

These are not small inconveniences, they directly affect the quality of the tournament.

41.7% of surveyed participants cited "unclear or frequently changing schedules" as a major problem.

 37.5% said the lack of real-time scores negatively impacted their experience.

66.7% cited overcrowding at popular matches — a problem that venue capacity management
in a database can directly address.

This database was designed to solve all of these problems with a single, centralized system.

---

## 2. Why a Database? What Makes This Different?

### The current reality at most college tournaments

| Problem | Current Method | What Goes Wrong |
|---|---|---|
| Registration | Google Forms every year | Duplicate entries, inconsistent formats, no reuse |
| Scheduling | Excel / manual | Venue clashes, no conflict detection |
| Results | Paper → spreadsheet | Hours of delay, transcription errors |
| Standings | Manual calculation | Wrong rankings published |
| Communication | WhatsApp groups | Key updates missed, no traceability |
| Historical records | Not maintained | No player career stats, no institutional memory |

### What this database provides instead

**Single source of truth.** Every piece of tournament data : registrations, schedules,
scores, standings, venues, equipment, lives in one PostgreSQL database.


**Built-in conflict prevention.** The database structure physically prevents a team from
being registered in two places simultaneously, a venue from being double-booked, or a
match result from being entered in an inconsistent format.

**Reusable player and team profiles.** A player registers once. In future tournaments,
their profile (name, college, blood group, contact, history) is already in the system.
Coaches and referees are also permanent records, no re-entry needed each year.

**Multi-sport flexibility.** The schema is deliberately sport-agnostic. Cricket,
football, badminton, chess, arm wrestling, e-sports — any event type fits into the same
structure without schema changes. Statistics (goals, wickets, points, assists) are stored
as named rows, not fixed columns, so adding a new sport requires zero DDL changes.

**Role-specific access model.** The data is structured so that each user type sees exactly
what they need:
- A player sees their own schedule, stats.
- A referee sees the matches they are assigned to, with full player and rule data
- An organizer sees everything across all sports and venues
- A spectator sees live schedules, results, and leaderboards — no login required

**Historical records by design.** Past tournament data is never deleted. A player's
statistics from three years ago are as accessible as yesterday's match. The system is
designed with a 3–5 year data retention policy in mind (per college regulations).

---

## 3. Who Uses This System?

The system was designed around five distinct user classes, each discovered through direct
interviews and a questionnaire with real tournament participants at DA-IICT, Nirma University.

### Administrators / Organizers
The people running the tournament. They create tournaments, define rules, generate fixtures,
assign referees to matches, manage venue bookings, approve team registrations, and handle
sponsorships. They need full visibility across all data. In this system: represented by
the `Organizer` entity, linked to tournaments through `OrganizeTournament` with a
defined `role` (coordinator, manager, assistant, volunteer) and `department`
(logistics, operations, marketing, finance, refereeing, medical, hospitality, technical).

### Coaches
Team managers who care about their own team's data above all else. They register players,
manage the team roster, check the fixture schedule, and track standings and performance
over time. In this system: represented by `Coach`, linked to teams through `TeamCoach`
with temporal validity (`join_date`, `end_date`) to track coaching history.

### Referees
Officials who enter match results in real time. They need a fast, simple interface that
shows only the match they are officiating — with both teams, the rules of the sport, and
a way to record scores and statistics. In this system: represented by `Referee`, assigned
to `Match` via the `conducted_by` relationship. They interact primarily with `Result`,
`PlayerStatistics`, and `TeamStatistics`.

### Players
Students who participate. They want to see their schedule, check their stats, view their
team's position on the leaderboard, and track career progress across multiple tournaments.
In this system: `Player` is a specialization of `Person` (ISA), storing player-specific
attributes (height, weight, blood group, joining year) while inheriting identity data
(name, email, contact) from the parent `Person` entity.

### Spectators / Audience
The largest user group.
53.6% of survey respondents identified as spectators. They want
live scores, match schedules, and leaderboards without needing to log in or navigate a
complex system. In this system: any person can view matches via `PersonViewMatch`.
Spectator-specific data (pass type — gold, silver, regular) is stored in `PersonPass`.
Importantly, a Player is also allowed to watch other matches as a spectator — this is
handled by making the "view" relationship connect to `Person` (the superclass), not just
the Spectator subclass.

---

## 4. Core Features

### A. Tournament Management
Create a tournament with a name, year, season, start date, end date, and format. Define
the sports included. Schedule matches with specific dates, times, venues, and referees.
The system prevents scheduling a match outside the tournament's date range and prevents
double-booking a venue at the same time.

### B. Team and Player Registration
Teams register for a specific sport. Players join teams with a join date. The system
enforces the most critical business rule: **a player may only represent one team per
tournament** — a rule explicitly stated in the SRS Business Constraints and enforced
at the database level via a trigger.

### C. Multi-Sport Statistics
For each match, statistics can be recorded per player and per team. Rather than hardcoding
sport-specific stats (which would require schema changes for every new sport), the system
uses a flexible `status_name` / `status_value` model. Goals, wickets, assists, yellow
cards, overs bowled, rebounds — all stored as named stat rows. Adding chess rating or
e-sports kills/deaths requires zero schema changes.

### D. Results and Standings
When a referee submits a result, it records the winner (team or individual), the outcome
(win/loss/draw), and a score detail string. From this, leaderboards and standings can be
computed at any time via SQL queries or pre-built views.

### E. Pass and Access Management
Tournament passes (gold, silver, regular) are issued to any person — not just registered
spectators. A player who wants to watch matches they are not playing in, or a coach who
needs venue access, simply gets a pass. The `PersonPass` table handles this at the Person
level.

### F. Sponsorship Tracking
Sponsors are linked to tournaments with a specific budget allocation. A single sponsor
can fund multiple tournaments; a tournament can have multiple sponsors. The budget figure
lives on the `SponsorsTournament` relationship, not on either entity — correctly
representing it as a property of the sponsorship arrangement, not the sponsor or the
tournament alone.

### G. Equipment and Venue Management
Every sport requires specific equipment. The database tracks which equipment is needed
for which sport, how many units are needed, and the condition of each item
(new / good / fair / poor). Venues are tracked with name, location, and capacity —
enabling the system to warn about overcrowding (addressing the 66.7% overcrowding
complaint from the survey).

---

## 5. ER Model — Entities and Their Purpose

The ER model was built following the standard entity-relationship methodology.
Entities represent real-world objects or concepts that have an independent existence in
the tournament domain and that the system needs to store information about.

### Strong Entities

**Person**  
The central identity entity. Represents any human being who interacts with the system.
Stores name, gender, date of birth, email, and contact number. Person is the superclass
in the ISA hierarchy — Player and Spectator are specializations of Person. Every human
in the system starts as a Person record.

**Player**  
A specialization (subtype) of Person. Stores attributes that only matter for players:
height, weight, blood group, joining year, and college name. These attributes would be
meaningless for a referee or organizer — which is why they live in Player, not Person.
Player inherits the identity (person_id, name, email, contact) from Person.

**Organizer**  
Represents the people who run the tournament — committee members, coordinators,
department heads, volunteers. Stored separately from Person because organizers have
a distinct role in the system with their own access permissions, email, and contact.
An organizer can manage multiple tournaments across years.

**Tournament**  
The central scheduling entity. Represents one edition of the sports fest — with a name,
year, season, start date, and end date. Everything else in the system is anchored to
a tournament. Matches happen within a tournament. Teams participate in a tournament.
Sponsors fund a tournament. Organizers run a tournament.

**Sports**  
Represents a sport discipline offered in the tournament — cricket, football, badminton,
chess, and so on. Each sport has a unique name and a type (team or individual). Sports
is the anchor for teams (every team belongs to a sport), matches (every match is of one
sport), rules (every sport has its own rules), and equipment (every sport needs specific
equipment).

**Team**  
Represents a college team registered to play a specific sport. Stores the team name,
college name, and a reference to its captain (who is a Player). A team is tied to exactly
one sport. The same college can have multiple teams — one per sport.

**Match**  
Represents a scheduled game between two or more teams (or individual players) in a
specific sport, at a specific venue, on a specific date and time, officiated by a referee.
Match is the operational heart of the system — results, statistics, spectator views, and
player participations all connect through Match.

**Result**  
Represents the outcome of a completed match. Stores the winner (team or individual
player), the type of win (team/individual sport), the outcome (win/loss/draw), and a
score detail string. Result is a separate entity from Match because a match exists before
it is played — the result only comes into existence after it ends.

**Venue**  
Represents a physical location where matches are held. Stores venue name, location, and
capacity. Capacity is important for managing overcrowding — a direct response to the
survey finding that 66.7% of participants cited overcrowding as a major problem.

**Referee**  
Represents an officiating official assigned to conduct matches. Stores name and contact.
A referee is assigned to a match via the `conducted_by` relationship. One referee can
officiate many matches; a match has one assigned referee.

**Coach**  
Represents a team's coach or trainer. Stores name, contact, and specialization
(which sport they coach). A coach can train multiple teams over time; a team can have
multiple coaches. The `TeamCoach` junction table tracks the temporal validity of
coaching assignments with join and end dates.

**Sponsors**  
Represents an organization or company that provides financial support to a tournament.
Stores sponsor name, contact, and company name. Sponsors fund tournaments through the
`SponsorsTournament` relationship, which carries the budget amount.

**Equipments**  
Represents physical equipment used in sports. Stores equipment name, quantity, and
condition. Equipment is linked to sports through `SportEquipments` — a sport requires
certain equipment, and tracking condition enables proactive replacement.

**SportType**  
Captures whether a sport is a team sport or an individual sport. This distinction matters
for how results are recorded (team winner vs individual winner) and how statistics are
aggregated. Linked 1:1 to Sports.

### Weak Entities

**Rules**  
Represents individual rules for a sport. A rule has no meaning without its sport —
"Rule 3" of cricket is completely different from "Rule 3" of football. Rules is a weak
entity dependent on Sports, with a composite primary key `(sport_id, rule_no)`. Rule
numbers restart from 1 for each sport. This design allows individual rules to be
added, updated, or deleted without affecting other rules of the same sport.

**PlayerStatistics**  
Represents recorded statistics for a player in a specific match. Weak entity dependent on
both Player and Match. Uses a flexible `status_name / status_value` model — one row per
statistic type. Goals scored, assists, yellow cards, wickets taken — each is one row.
This design works for any sport without any schema change.

**TeamStatistics**  
Same design as PlayerStatistics but for teams. Records team-level statistics per match:
total goals, possession percentage, fouls committed, run rate — any numeric or outcome
statistic as named rows.

---

## 6. ER Model — Relationships Explained

### ISA (Specialization) — Person → Player / Spectator

Person is the superclass. Player and Spectator are subclasses.
This is an **overlapping specialization** — the same person can be both a Player
(in some sports) and a Spectator (watching other sports). The ISA is NOT disjoint.

A Player adds sport-specific physical attributes to the base Person record.
A Spectator adds pass and membership information. But the core identity — name, email,
contact, date of birth — is always stored exactly once in Person, never duplicated.

### includes — Tournament : Match (1:N)

One tournament includes many matches. Every match must belong to exactly one tournament.
**Total participation on Match** — a match cannot exist without a tournament.
**Partial participation on Tournament** — a tournament can exist before any matches are scheduled.

### played_by — Match : Team (M:N)

Many teams play in many matches. A match involves exactly two teams (for most sports);
a team plays many matches across the tournament. The `TeamPlaysMatch` junction table
carries the team's score for that match.

### plays — Player : Match (M:N)

Many players play in many matches. A player participates in the matches of their team.
`PlayerPlaysMatch` records this participation — enabling match-specific lineups.

### contains — Player : Team (M:N, with history)

A player can be on multiple teams across different tournaments. A team has many players.
The `PlayerTeam` junction table records `join_date` and `end_date` — enabling the system
to answer "who was on this team in the 2023 tournament?" Not just current membership,
but the full history.

### Trains — Coach : Team (M:N, with history)

A coach can train multiple teams. A team can have multiple coaches (head coach, fitness
coach, strategy coach). `TeamCoach` records the temporal validity of each coaching
relationship with `join_date` and `end_date`.

### played_by (PlayerSport) — Player : Sports (M:N)

A player can play multiple sports. The `PlayerSport` table records not just which sports
a player plays, but their **level** (beginner / intermediate / advanced / professional)
and **experience in years** for each sport. This enables seeding, eligibility checks, and
squad selection queries.

### funds — Sponsors : Tournament (M:N)

Sponsors fund tournaments. The `SponsorsTournament` table carries the **budget** amount —
a relationship attribute that belongs to the sponsorship arrangement, not to either entity
individually. One sponsor can fund multiple tournaments across years.

### has_tournament_pass — Person : Tournament (M:N)

Any person can have a pass for any tournament. Passes come in three tiers: gold, silver,
regular. The `PersonPass` table stores the pass type, a unique pass number, and the
registration date. This is connected to Person (not Spectator) because any person —
player, coach, referee, or general audience — may hold a pass.

### view — Person : Match (M:N)

Any person can view any match as a spectator. The `PersonViewMatch` table records this
with an optional `seat_number`. This relationship is deliberately at the **Person level**,
not the Spectator subclass level — because a player watching another sport's match is
viewing as a person, not as a registered spectator. This is one of the key design
decisions that differentiates this model from a naive implementation.

### conducted_by — Match : Referee (N:1)

Many matches can be conducted by the same referee. Each match has one assigned referee.
**Partial participation on both sides** — a match may not yet have an assigned referee
(scheduled but not assigned), and a referee may not be assigned to any upcoming match.

### held_at — Match : Venue (N:1)

Many matches are held at the same venue. Each match is held at one venue.
**Partial participation on both sides** — a match may be venue TBD, and a venue may have
no upcoming matches. When a venue is deleted, the venue reference on Match is set to NULL
(not cascaded) — the match record is preserved, only the venue link is cleared.

### organized_tournament — Organizer : Tournament (M:N)

Many organizers work on one tournament. One organizer can manage multiple tournaments.
The `OrganizeTournament` table stores their **role** (coordinator/manager/assistant/volunteer)
and **department** (logistics/operations/marketing/finance/etc.) for each tournament
they are involved in.

### requires — Sports : Equipments (M:N)

Sports require equipment. Equipment can be used across multiple sports. `SportEquipments`
tracks which equipment is needed for which sport.

### defined — Sports : Rules (1:N)

One sport has many rules. Rules are weak entities identified by (sport_id, rule_no).

### produce (Result) — Match : Result (1:1)

Each completed match produces exactly one result. The unique constraint on
`Result(match_id)` enforces this 1:1 relationship. Result is created after the match
ends — not when the match is scheduled.

---

## 7. Schema Overview — All 27 Tables

| Table | Category | Purpose |
|---|---|---|
| `Person` | Strong Entity | Base identity for all humans in the system |
| `Player` | ISA Subclass | Player-specific attributes, extends Person |
| `Organizer` | Strong Entity | Tournament organizers and committee members |
| `Tournament` | Strong Entity | Each edition of the sports fest |
| `Sports` | Strong Entity | Sport disciplines (cricket, football, etc.) |
| `SportType` | 1:1 Extension | Team vs Individual classification |
| `Rules` | Weak Entity | Individual rules per sport, numbered per sport |
| `Team` | Strong Entity | College teams registered per sport |
| `Match` | Strong Entity | Scheduled and completed games |
| `Result` | Strong Entity | Outcome of a completed match |
| `Venue` | Strong Entity | Physical match locations with capacity |
| `Referee` | Strong Entity | Match officials |
| `Coach` | Strong Entity | Team trainers and coaches |
| `Sponsors` | Strong Entity | Funding organizations |
| `Equipments` | Strong Entity | Physical equipment inventory |
| `PersonPass` | Junction (M:N) | Tournament passes for any person |
| `PersonViewMatch` | Junction (M:N) | Any person watching any match |
| `PlayerTeam` | Junction (M:N) | Player membership in teams, with history |
| `PlayerSport` | Junction (M:N) | Player skill level per sport |
| `PlayerPlaysMatch` | Junction (M:N) | Player participation in matches |
| `PlayerStatistics` | Weak Entity | Per-player per-match statistics (flexible) |
| `TeamCoach` | Junction (M:N) | Coaching assignments with history |
| `TeamPlaysMatch` | Junction (M:N) | Team scores per match |
| `TeamStatistics` | Weak Entity | Per-team per-match statistics (flexible) |
| `OrganizeTournament` | Junction (M:N) | Organizer roles per tournament |
| `SponsorsTournament` | Junction (M:N) | Sponsorship amounts per tournament |
| `SportEquipments` | Junction (M:N) | Equipment requirements per sport |

---

## 8. Key Design Choices That Make This Database Strong

### Sport-Agnostic Statistics Model

Most tournament databases hardcode sport-specific columns:
`goals INT, assists INT, yellow_cards INT, wickets INT, overs INT, rebounds INT...`

This approach breaks every time a new sport is added and leaves most columns NULL for
most sports. This system uses a flexible row-per-statistic model:

```
(player_id, match_id, status_name='goals', status_value=3)
(player_id, match_id, status_name='assists', status_value=1)
(player_id, match_id, status_name='yellow_cards', status_value=1)
```

Adding e-sports (kills, deaths, KDA ratio) or chess (rating change, time used) requires
zero schema changes. The tournament administrator simply uses a new `status_name`.

### Person → Player ISA Hierarchy (Overlapping)

Instead of storing player data and general person data in one flat table, the design uses
a proper ISA specialization. Person stores identity (name, email, contact, DOB).
Player stores sport-specific data (height, weight, blood group, joining year).

This means:
- A referee or organizer does not have NULL columns for height and blood group
- A player's identity is stored exactly once — no duplication
- The same person can be a player in one sport and a spectator in another (overlapping ISA)

### Temporal Relationships (History Tracking)

Both `PlayerTeam` and `TeamCoach` store `join_date` and `end_date`. This is not a small
detail — it means the database can answer questions like:

- "Who was on the cricket team in the 2022 tournament?"
- "Which coach trained the football team that won in 2021?"
- "Show me the complete career history of player P003"

Without temporal tracking, historical queries are impossible. The `end_date IS NULL`
pattern represents a currently active membership.

### Result Supports Both Team and Individual Sports

A single `Result` table handles cricket finals (team winner) and badminton finals
(individual winner) through a `winner_type` discriminator with a CHECK constraint
that enforces consistency: if `winner_type = 'team'`, the `winner_team_id` must be set
and `winner_player_id` must be NULL, and vice versa for individual sports.

This eliminates the need for two separate result tables with identical structure.

### Referential Integrity With Intentional Cascade Rules

Every foreign key has a deliberate ON DELETE behavior:

- `ON DELETE CASCADE` — when the parent is deleted, child data loses all meaning
  (e.g., deleting a tournament cascades to its matches, registrations, and results)
- `ON DELETE SET NULL` — when the parent is deleted, the child record still has value
  (e.g., deleting a referee sets `Match.referee_id = NULL` — the match record is preserved)

This distinction encodes real business logic into the database structure itself.

---

## 9. Data Integrity — How Bad Data is Prevented

The system enforces data quality at the database level — not just in the application.
This matters because data can enter through multiple interfaces (web app, admin tools,
direct SQL) and must be correct regardless of entry point.

| Rule | Enforcement |
|---|---|
| Valid email addresses only | `CHECK` with POSIX regex on `Person.email_id` and `Organizer.email_id` |
| Phone numbers must be exactly 10 digits | `CHECK (contact_no ~ '^[0-9]{10}$')` |
| Tournament end date must be after start date | `CHECK (end_date >= start_date)` |
| Match duration must be positive | `CHECK (duration > 0)` |
| Venue capacity must be positive | `CHECK (capacity > 0)` |
| Player joining year is realistic | `CHECK (joining_year BETWEEN 1990 AND 2100)` |
| Blood group must be valid | `CHECK IN ('A+','A-','B+','B-','O+','O-','AB+','AB-')` |
| Pass type must be valid tier | `CHECK IN ('gold','silver','regular')` |
| Match type must be a real stage | `CHECK IN ('group','quarterfinal','semifinal','final')` |
| Equipment condition must be known | `CHECK IN ('new','good','fair','poor')` |
| Stats consistency (numeric/outcome) | `CHECK` constraint on `PlayerStatistics` and `TeamStatistics` |
| Result winner consistency | `chk_winner_consistency` — team XOR individual, enforced by CHECK |
| Player team membership end date | `CHECK (end_date IS NULL OR end_date >= join_date)` |
| Team name unique per college | `UNIQUE (team_name, college_name)` — different colleges can have same team name |

---

## 10. Performance Design — Indexes

### Why indexes matter

Without indexes, every query that filters rows does a full sequential scan —
reading every row in the table regardless of how many match the filter.
For a tournament with 500 players, 50 teams, and 200 matches, a full scan is
barely noticeable. For a festival with 30,000 participants (like Riviera), it is unusable.

The indexes in this system are designed for the specific query patterns that matter most:

### The most critical index

`idx_match_tournament` on `Match(tournament_id)`

This is the single most frequently executed query in the entire system:
*"Show all matches for tournament X."*
Every fixture page, schedule view, and standings calculation starts with this filter.
Without this index, every schedule page load scans all matches in the database.

### The cascade performance indexes

When a row is deleted from a parent table, PostgreSQL must find all child rows to cascade.
Without an index on the FK column in the child table, this triggers a full table scan of
the child table for every single parent deletion.

For example: deleting a Referee without an index on `Match(referee_id)` causes PostgreSQL
to scan every row of the Match table to find matches where that referee is assigned.

Indexes on all FK columns prevent this cascade performance problem.

### Partial indexes for active records

```sql
CREATE INDEX idx_playerteam_active ON PlayerTeam(player_id) WHERE end_date IS NULL;
CREATE INDEX idx_teamcoach_active  ON TeamCoach(team_id)   WHERE end_date IS NULL;
```

These partial indexes only index currently active memberships — ignoring historical
(ended) records. The result is a smaller, faster index that perfectly serves the most
common query: "show me the current roster / current coaching staff."

### What was deliberately NOT indexed

Columns with very few distinct values (like `season` with 4 values, or `blood_group`
with 8 values) are not indexed because PostgreSQL often chooses a sequential scan
anyway for low-cardinality columns — the index would slow things down, not speed them up.

Full-text name searches (`LIKE '%text%'`) cannot use B-tree indexes at all.
If full-text search is needed, a GIN index with `pg_trgm` extension would be used instead.

---

## 11. Business Rules Enforced by the Database

These rules come directly from the SRS Business Constraints section and are enforced
at the database level — not just documented in the application.

**A player may only represent one team per tournament.**
Source: SRS Business Constraints §10 — *"A player may only represent one team per
tournament (no duplicate participation)."*
Implementation: Trigger on `PlayerTeam` INSERT that checks whether the player already
has an active team membership in the same tournament.

**Teams must register before the deadline.**
Source: SRS — *"Teams must be registered before the official registration deadline;
late entries will not be accepted."*
Implementation: `PersonPass.registration_date DEFAULT CURRENT_DATE` captures registration
timing. Trigger to enforce tournament registration deadline.

**Match date must be within tournament dates.**
A match cannot be scheduled before the tournament starts or after it ends.
Implementation: Trigger on `Match` INSERT that validates `match.date BETWEEN
tournament.start_date AND tournament.end_date`.

**No venue double-booking.**
Two matches cannot be held at the same venue at the same time.
Implementation: Trigger on `Match` INSERT that checks for conflicts on `(venue_id, date, time)`.

**Captain must be a member of the team.**
A player cannot be named captain of a team they are not on.
Implementation: CHECK at INSERT time — `captain_id` must exist in `PlayerTeam` for that team.

---

## 12. Scalability and Real-World Readiness

### Designed for growth

The current schema is validated for college-level scale (few hundred players, per SRS
assumptions). But the design choices made — indexes on all FK columns, sport-agnostic
statistics, temporal relationship tracking, no hardcoded sport-specific columns —
mean the system can scale to larger events without structural changes.

Festivals like Udghosh (IIT Kanpur, 450+ colleges, 40+ organizations) and Riviera
(VIT, 30,000+ participants) operate at 100x the scale of a single college tournament.
This schema would handle that scale with the addition of:
- BIGSERIAL/UUID primary keys (replacing VARCHAR(10) for truly large scale)
- Partitioning on `Match` and `PlayerStatistics` by tournament_id or year
- Materialized views for leaderboard queries (pre-computed, refreshed after each match)
- Connection pooling (PgBouncer) for concurrent referee and organizer access

### What the database enables that spreadsheets never could

- **Cross-tournament player career stats:** Total goals, matches played, and wins across
  every tournament a player has participated in — queryable in one SQL statement
- **Historical venue usage analysis:** Which venues are used most, which have the
  highest match durations, which need capacity expansion
- **Sponsor ROI tracking:** Budget committed per tournament, number of matches in that
  tournament, audience size (pass count) — all joinable in one query
- **Referee workload analysis:** How many matches each referee officiated, across
  which sports, in which time periods
- **Team performance trends:** Win rate over multiple seasons, goal difference improvement,
  equipment condition correlation with performance

