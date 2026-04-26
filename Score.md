
You are a Senior Full-Stack Engineer. Build a complete, production-ready Cricket Scoring Application from scratch using the specification below. Do NOT ask questions. Make no assumptions silently — all assumptions are stated here. Follow every instruction exactly. Every rule, edge case, data model, and flow is fully specified. Build modular, clean, well-commented, SOLID-compliant code. Handle all edge cases. Create reusable components. Add validation guards everywhere.

---

## 1. APP OVERVIEW


**Purpose:** A real-time, ball-by-ball cricket scoring application for live match officials, scorers, and organizers. Fully compliant with MCC Laws of Cricket (2022 Code), ICC Playing Conditions, and IPL Impact Player regulations.  
**Target Users:** Match scorers, tournament organizers, team managers, and spectators.  
**Core Problem Solved:** Eliminate manual scorebook errors; provide a digital, rule-enforced, real-time scoring engine for T20, ODI, Test, and custom-format matches including IPL Impact Player substitution logic.  
**Supported Platforms:** Android (primary), iOS (secondary), Web (admin/spectator view). Build as a React Native app with a Node.js/Express backend. Web admin panel built in React.js.

---

## 2. USER ROLES & PERMISSIONS

### Role 1: Scorer
- **Description:** The person entering ball-by-ball data live during a match.
- **Permissions:** Full access to live scoring workflow. Can create matches, manage teams, enter deliveries, select dismissals, manage Impact Player substitutions, undo last ball, end innings/match.
- **Accessible Screens:** All screens except Admin Dashboard.
- **Restricted Actions:** Cannot modify locked innings scorecards. Cannot edit player master data (only view).

### Role 2: Tournament Organizer / Admin
- **Description:** Sets up tournaments, manages team rosters, views all matches.
- **Permissions:** Create/edit/delete tournaments, teams, and players. View any match scorecard. Cannot enter live scoring unless also assigned as Scorer.
- **Accessible Screens:** Admin Dashboard, Tournament Management, Team Management, Player Management, Match History, All Scorecards.
- **Restricted Actions:** Cannot enter live delivery data unless assigned Scorer role for that match.

### Role 3: Spectator (Read-Only)
- **Description:** Viewers who follow live scores.
- **Permissions:** Read-only. Can view live scorecards, ball-by-ball feed, match summary.
- **Accessible Screens:** Live Scorecard, Match Summary, Ball-by-Ball Feed, Player Stats.
- **Restricted Actions:** No write access. No match setup. No scoring.

### Role 4: Captain (Optional Delegation)
- **Description:** Team captain who approves Impact Player substitutions.
- **Permissions:** Approve or reject Impact Player substitution in-app during live match.
- **Accessible Screens:** Live Match View (Impact Player panel only), Team Sheet.
- **Restricted Actions:** No scoring. No match setup.

---

## 3. COMPLETE SCREEN INVENTORY

### 3.1 Authentication Screens

**Screen: Splash Screen**
- Entry: App launch
- Exit: Login Screen (if not authenticated), Home (if token valid)
- Components: App logo, version number, loading indicator
- States: Loading, redirect

**Screen: Login Screen**
- Entry: Splash redirect or logout
- Exit: Home Screen (on success)
- Components: Email field, Password field, Login button, Forgot Password link, Register link
- Validation: Email format, password min 8 chars
- Error States: Invalid credentials, server error, network error

**Screen: Register Screen**
- Entry: Login → Register link
- Exit: Login Screen (on success)
- Components: Name, Email, Password, Confirm Password, Role selection (Scorer / Organizer), Register button
- Validation: All fields required, password match, unique email
- Error States: Email already taken, weak password

**Screen: Forgot Password Screen**
- Entry: Login → Forgot Password
- Exit: Login Screen
- Components: Email input, Submit button, success message
- Error States: Email not found

---

### 3.2 Home & Navigation Screens

**Screen: Home Dashboard**
- Entry: Post-login
- Exit: New Match, Match History, Team Management, Player Management, Settings
- Components: Quick action buttons (New Match, Resume Match), Recent Matches list, User greeting, role badge
- Empty State: "No matches yet. Start your first match."

**Screen: Match History**
- Entry: Home → Match History
- Exit: Match Summary (tap any match)
- Components: List of past matches (date, teams, result, format), search/filter bar (by date, team, format), pull-to-refresh
- Empty State: "No completed matches found."

---

### 3.3 Match Setup Screens

**Screen: New Match — Match Type Selection**
- Entry: Home → New Match
- Exit: Match Configuration
- Components: Format selector cards: T20 (20 overs), ODI (50 overs), Test, Custom
- Logic: Custom shows an overs input field (min 1, max 100)

**Screen: New Match — Match Configuration**
- Entry: Match Type Selection
- Exit: Team A Setup
- Components:
  - Ball type toggle: Hardball / Tennis
  - Powerplay overs input: PP1 Start, PP1 End (PP2 and PP3 optional, ODI only)
  - DLS toggle: Yes / No
  - Impact Player Rule toggle: Yes / No (disable if match type = Test or Custom < 10 overs)
  - Venue name (optional text input)
- Validation: PP end > PP start, PP end ≤ total overs

**Screen: Team A Setup**
- Entry: Match Configuration
- Exit: Team B Setup
- Components:
  - Team name input
  - Player list (add up to 11 players): Name, Jersey number
  - If Impact Player rule ON: Add up to 4 substitute players
  - Captain selector (from 11 players)
  - Wicket-Keeper selector (from 11 players)
  - Add Player button, Remove Player button
- Validation: Exactly 11 players in XI, captain and keeper mandatory, jersey numbers unique, no duplicate names
- Error State: "Team must have exactly 11 players before proceeding."

**Screen: Team B Setup**
- Entry: Team A Setup
- Exit: Toss Screen
- Components: Same as Team A Setup
- Validation: Same as Team A

**Screen: Toss Screen**
- Entry: Team B Setup
- Exit: Innings 1 Opening Batsmen Selection
- Components:
  - Toss winner selector (Team A / Team B radio)
  - Toss choice selector (Bat First / Bowl First radio)
  - If Impact Player ON: Two 15-player declaration panels (one per team), showing XI + 4 subs
  - Confirm Toss button
- Logic: Derives batting_team and bowling_team from winner + choice

**Screen: Opening Selection (Innings Start)**
- Entry: Toss Screen (Innings 1), Innings Break (Innings 2)
- Exit: Live Scoring Screen
- Components:
  - On-Strike Batsman selector (from batting team XI)
  - Non-Strike Batsman selector (from batting team XI, excludes on-strike)
  - Opening Bowler selector (from bowling team XI)
  - Begin Innings button
- Validation: All three must be selected. No two selectors can share the same player.

---

### 3.4 Live Scoring Screens

**Screen: Live Scoring — Delivery Screen (Core Screen)**
- Entry: Opening Selection, End of each ball
- Exit: End of Over, Wicket Dialog, Innings End, Undo confirmation
- Components:
  - Scoreboard header: Team score (Runs/Wickets), Overs (X.Y), Run Rate, Required Run Rate (Inn2 only), Target (Inn2 only)
  - FREE HIT banner (prominent, red/orange, shown when free_hit_active = TRUE)
  - Striker info card: Name, Runs, Balls, SR, 4s, 6s
  - Non-Striker info card: Name, Runs, Balls
  - Bowler info card: Name, Overs, Maidens, Runs, Wickets, Economy
  - Delivery type buttons: [Legal] [Wide] [No-Ball] [Dead Ball]
  - Runs selector: [0] [1] [2] [3] [4] [6] [Custom]
  - Extras selector (contextual): [None] [Byes] [Leg Byes]
  - Wicket button (opens Wicket Dialog)
  - Confirm Ball button (disabled until delivery type + runs selected)
  - Undo button (reverts last ball)
  - Impact Player button (visible if rule enabled and substitution not yet used by batting/bowling team)
  - Powerplay indicator: "PP1 Active" badge during powerplay overs
- Logic:
  - Delivery type selection drives which options are available
  - If Wide: extras selector hidden (all runs = wides automatically)
  - If No-Ball: +1 NB penalty auto-applied, next_free_hit flag will be set
  - Confirm Ball only enabled after minimum required inputs
- Error States: "Select delivery type before confirming", "Invalid run combination"

**Screen: Wicket Dialog (Modal)**
- Entry: Live Scoring → Wicket button
- Exit: Live Scoring (on confirm or cancel)
- Components:
  - Dismissal type list (greyed-out invalid options based on delivery type):
    - Bowled, Caught, LBW, Run Out, Stumped, Hit Wicket, Obstructing the Field, Hit Ball Twice, Timed Out, Retired Hurt, Retired Out
  - Fielder selector (for Caught, Run Out): searchable list of fielding team players
  - Which batsman run out (for Run Out): Striker / Non-Striker
  - Which end run out occurred (for Run Out): Striker's End / Non-Striker's End
  - Wicket-Keeper auto-filled (for Stumped)
  - Bowler auto-filled (for Bowled, Caught, LBW, Stumped, Hit Wicket)
  - Confirm button, Cancel button
- Validity Matrix enforced in UI:
  - Legal delivery: All types available
  - No-Ball: Only Run Out, Obstructing, Hit Ball Twice enabled
  - Free Hit: Only Run Out, Hit Wicket, Obstructing enabled
  - Wide: Only Stumped, Run Out, Obstructing enabled

**Screen: New Batsman Selection (Modal)**
- Entry: After wicket confirmed
- Exit: Live Scoring (on confirm)
- Components:
  - List of not-yet-dismissed, not-retired batting team players
  - Player tapped = selected as incoming batter
  - Confirm button
  - Impact Player substitution option (if applicable)
- Logic: Incoming batter's end determined by dismissal type (see Section 1.4 logic)

**Screen: End of Over Screen**
- Entry: 6th legal ball completed
- Exit: Live Scoring (next over)
- Components:
  - Over summary: runs scored, wickets, dot balls, boundaries
  - New Bowler selector (all fielding team players except current bowler, and anyone who has maxed their quota)
  - Impact Player substitution button (if applicable)
  - Begin Next Over button
- Validation: Must select new bowler. Cannot select same bowler as previous over. Cannot select bowler who has bowled maximum quota overs.

**Screen: Impact Player Substitution Screen (Modal)**
- Entry: Live Scoring → Impact Player button (at over end or fall of wicket)
- Exit: Live Scoring (on confirm or cancel)
- Components:
  - Validation warnings (auto-checked): already used, wrong timing, match < 10 overs
  - Outgoing Player selector: list of current XI (excluding batters currently at crease)
  - Incoming Player selector: list of declared 4-player substitute panel
  - Role badge on incoming player (Batter / Bowler / All-rounder)
  - Bowling quota display for incoming player (fresh quota, e.g. 4 overs T20)
  - Confirm Substitution button
  - Cancel button
- Logic: On confirm — remove outgoing from active XI, add incoming with fresh bowling quota, tag incoming as IMPACT PLAYER in scorecard, log over.ball timestamp

**Screen: Undo Confirmation Dialog**
- Entry: Live Scoring → Undo button
- Exit: Live Scoring (state reverted one ball)
- Components: Warning message "This will undo the last delivery. Are you sure?", Confirm, Cancel
- Logic: Restore full MatchState snapshot from last_ball_event. Only one level of undo supported.

---

### 3.5 Innings Break & Match End Screens

**Screen: Innings Break Screen**
- Entry: Innings 1 completion (all out or overs complete)
- Exit: Opening Selection (Innings 2)
- Components:
  - Innings 1 full scorecard (locked, read-only)
  - Target display: "Team B needs X runs to win"
  - Innings summary stats: highest scorer, best bowler, run rate
  - Start Innings 2 button
  - Impact Player availability reminder (if not yet used)

**Screen: Match Result Screen**
- Entry: Innings 2 completion
- Exit: Full Scorecard, Home
- Components:
  - Winner banner with team name and victory margin
  - Margin format: "Won by N wickets" or "Won by N runs" or "Match Tied"
  - Player of the Match selector (dropdown, any player from either team)
  - View Full Scorecard button
  - New Match button
  - Share button (exports scorecard as PDF/image)

---

### 3.6 Scorecard Screens

**Screen: Full Scorecard**
- Entry: Match Result, Match History item tap, Live Scoring header tap
- Exit: Back to caller
- Tabs:
  - **Innings 1 Tab:**
    - Batting card: Player Name | Dismissal | Bowler | Runs | Balls | 4s | 6s | SR
    - Extras row: Byes, Leg Byes, Wides, No-Balls, Penalty, Total
    - Total row: Team score / wickets / overs
    - Fall of Wickets: "1-23 (PlayerName, 4.3)"
    - Bowling card: Bowler | O | M | R | W | Econ | Wides | NBs
    - Powerplay summary: PP1: X/Y (runs/wickets)
  - **Innings 2 Tab:** Same structure + target achieved status
  - **Match Info Tab:** Venue, date, format, toss result, DLS status, Impact Player substitution log
- Special rendering: Impact Player tagged with ⚡ icon next to name in both batting and bowling cards

**Screen: Live Scorecard (Spectator View)**
- Entry: Shareable link or spectator login
- Exit: N/A (auto-refreshes)
- Components: Identical to Full Scorecard tabs but with auto-refresh every 10 seconds. Read-only. Shows "LIVE" badge.

---

### 3.7 Management Screens (Admin/Organizer)

**Screen: Team Management**
- Entry: Home → Teams
- Components: Team list, Add Team, Edit Team, Delete Team (if no active matches)
- Edit Team: name, players list, captain, keeper

**Screen: Player Management**
- Entry: Home → Players or Team Edit → Player
- Components: Player list, Add Player (name, jersey number, batting style, bowling style, role), Edit, Delete
- Validation: Unique jersey within team, name required

**Screen: Tournament Management**
- Entry: Home → Tournaments (Admin only)
- Components: Tournament list, Create Tournament (name, format, teams), view standings

**Screen: Settings**
- Entry: Home → Settings
- Components: Profile edit, Change Password, Notification preferences, App version, Logout

---

## 4. WORKFLOW (STEP-BY-STEP)

### 4.1 Authentication Flow
```
App Launch
  → Token valid? → Home Dashboard
  → No token / expired → Login Screen
    → Login success → Home Dashboard
    → Forgot Password → Email sent → Login Screen
    → Register → Success → Login Screen
```

### 4.2 Match Setup Flow
```
Home → New Match
  → Select Format (T20 / ODI / Test / Custom)
  → Configure Match (ball type, powerplay overs, DLS toggle, Impact Player toggle)
  → Team A Setup (name, 11 players, captain, keeper, optional 4 subs)
  → Team B Setup (same)
  → Validate both teams → errors block progression
  → Toss Screen (select winner, select choice)
    → If Impact Player ON: declare 15-player lists for both teams
  → Derive batting_team, bowling_team
  → Opening Selection (on-strike batter, non-strike batter, opening bowler)
  → Begin Innings 1 → Live Scoring Screen
```

### 4.3 Ball-by-Ball Scoring Flow (Per Delivery — 10 Steps)
```
STEP 1: BALL START STATE
  Load: striker, non-striker, bowler, score, wickets, overs, balls_this_over
  Display FREE HIT banner if free_hit_active = TRUE
  Display POWERPLAY badge if current over within PP range
  Check for pending Impact Player substitution request → process if present

STEP 2: UMPIRE SIGNAL SELECTION
  Scorer selects: [Legal | No-Ball | Wide | Dead Ball]
  IF Dead Ball → log reason → do NOT increment ball_count → return to STEP 1
  IF No-Ball → set no_ball=TRUE, next_free_hit=TRUE, auto-add +1 NB extra
  IF Wide → set wide=TRUE, auto-add +1 wide extra
  IF Legal → set legal=TRUE

STEP 3: RUN INPUT
  Scorer enters runs: [0|1|2|3|4|6|Custom]
  IF 4 → boundary_4=TRUE
  IF 6 → boundary_6=TRUE
  Custom → prompt "Overthrows?" → if YES, enter total overthrow runs
  Overthrow total = runs completed before throw + overthrow runs (boundary = 4 + pre-throw runs)

STEP 4: EXTRAS SELECTION
  IF Legal + no bat contact + runs > 0 → prompt [Byes | Leg Byes]
  IF No-Ball + no bat contact + runs > 0 → prompt [NB+Byes | NB+Leg Byes]
  IF Wide → all runs = Wides (no sub-selection)
  Update extras ledger: byes, leg_byes, wides, no_balls, penalties

STEP 5: WICKET SELECTION
  IF wicket occurred → open Wicket Dialog
  Apply dismissal validity matrix to grey-out invalid options
  Collect: dismissal_type, dismissed_player, fielder (if applicable), end (for run out)
  IF no wicket → skip to STEP 6

STEP 6: BATTER / BOWLER UPDATE
  Batsman: add bat_runs to striker.runs, increment striker.balls_faced
  IF boundary_4: striker.fours++; IF boundary_6: striker.sixes++
  Bowler runs_conceded += bat_runs + wides_penalty + nb_penalty
  Byes and Leg Byes NOT added to bowler's runs_conceded
  IF wicket (not Run Out / Retired): bowler.wickets++
  Recalculate striker.strike_rate, bowler.economy_rate
  IF wicket: mark dismissed batter with dismissal_type, dismissed_by, fielder

STEP 7: STRIKE UPDATE
  Apply rules in this priority:
    IF Caught: incoming batter always goes to striker's end (MCC 2022)
    IF Run Out (striker): incoming batter at the end where run-out occurred
    IF Run Out (non-striker): striker retains strike
    IF end of over: rotate strike (always)
    IF legal delivery: rotate if odd bat_runs; no rotate if even bat_runs (0,2,4,6)
    IF Wide/No-Ball: rotate based on completed (non-penalty) runs only
    NB penalty does NOT affect strike rotation

STEP 8: OVER COMPLETION CHECK
  IF legal delivery: ball_count++
  IF ball_count == 6:
    over_number++, reset ball_count=0
    Enforce bowler rotation (new bowler must be selected — cannot be same as last over)
    Check bowler max quota (T20=4, ODI=10): block if reached
    Rotate strike automatically
    Update powerplay status
    IF overs_completed == total_overs → Innings End

STEP 9: FREE HIT FLAG HANDLING
  IF this delivery was a No-Ball (any type) → free_hit_active = TRUE
  IF this delivery WAS the Free Hit AND was also a No-Ball or Wide → keep free_hit_active = TRUE
  IF this delivery WAS the Free Hit AND was legal → free_hit_active = FALSE

STEP 10: IMPACT PLAYER CHECK
  At end of over: prompt captain for Impact Player substitution (if rule enabled and not yet used)
  At fall of wicket: prompt captain for substitution before next batter enters
  IF substitution requested → run Impact Player validation (see Section 6.3 screen flow)
  Return to STEP 1
```

### 4.4 Innings End Flow
```
Innings End Triggered by:
  A) 10 wickets fallen (all out) — mid-over innings ends immediately
  B) Overs complete (all legal balls bowled)
  C) Target reached or exceeded (Innings 2 only — end immediately on that ball)

  → Lock innings scorecard
  → IF Innings 1: set target = innings1_score + 1 → go to Innings Break Screen
  → IF Innings 2: go to Match Result Screen
```

### 4.5 Match Result Calculation
```
  IF inn2_score > inn1_score → Inn2 batting team wins
    Margin = "by (10 - wickets_fallen_inn2) wickets"
  IF inn2_score < inn1_score → Inn1 batting team wins
    Margin = "by (inn1_score - inn2_score) runs"
  IF inn2_score == inn1_score → TIED
    IF tournament rules → proceed to Super Over
```

### 4.6 Impact Player Substitution Validation
```
  Check 1: Has this team already used their Impact Player substitution? → ERROR if YES
  Check 2: Is it start-of-over OR fall-of-wicket? → ERROR if NO
  Check 3: Is match ≥ 10 overs per side? → ERROR if NO (rule suspended)
  Check 4: Is chosen substitute in the pre-declared 4-player list? → ERROR if NO
  IF all checks pass:
    → Select outgoing player (from XI, excluding active batsmen at crease)
    → Select incoming player (from 4-player sub list)
    → Confirm
    → Remove outgoing from active XI
    → Add incoming with fresh bowling quota (T20: 4 overs, ODI: 10 overs)
    → Tag incoming as IMPACT_PLAYER in scorecard
    → Log: {team_id, innings, over_ball, trigger, outgoing_player, incoming_player}
```

---

## 5. BUSINESS LOGIC & RULES

### 5.1 Ball Classification (Must Run First on Every Delivery)
- Every delivery classified as: Legal | No-Ball | Wide | Dead Ball
- Classification drives all downstream logic. No scoring occurs before classification.
- No-Ball types: Front Foot, High Full Toss, Back Foot, Fielding Breach — all treated identically for scoring (+1 NB, free hit follows)
- Dead Ball: no score, no ball count change, logged only

### 5.2 Run Attribution Rules
- Bat runs → credited to striker's batting total
- Byes → Extras.byes (not credited to batsman, not to bowler)
- Leg Byes → Extras.leg_byes (not credited to batsman, not to bowler)
- Wides → Extras.wides (all runs including completed runs, charged to bowler)
- No-Ball penalty (+1) → Extras.no_ball_runs (charged to bowler)
- Overthrow runs: same attribution as original — if bat contact, to batsman; if bye/LB, to extras

### 5.3 Strike Rotation (Complete Rule Set)
| Event | Strike Rotates? |
|---|---|
| 0 runs | No |
| 1 run (bat) | Yes |
| 2 runs (bat) | No |
| 3 runs (bat) | Yes |
| 4 (boundary) | No |
| 6 (six) | No |
| Wide + 0 extra runs | No |
| Wide + 1 completed run | Yes |
| Wide + 2 completed runs | No |
| No-Ball + 0 bat runs | No |
| No-Ball + 1 bat run | Yes |
| No-Ball + 2 bat runs | No |
| End of Over | Yes (always) |
| Caught dismissal | New batter always to striker's end |
| Run Out (striker) | New batter at the run-out end |
| Run Out (non-striker) | Striker retains strike |
| Overthrow boundary | Count all runs; odd = rotate |

### 5.4 Dismissal Validity Matrix
| Dismissal Type | Legal Ball | No-Ball | Free Hit | Wide |
|---|---|---|---|---|
| Bowled | ✓ | ✗ | ✗ | ✗ |
| Caught | ✓ | ✗ | ✗ | ✗ |
| LBW | ✓ | ✗ | ✗ | ✗ |
| Stumped | ✓ | ✗ | ✗ | ✓ |
| Run Out | ✓ | ✓ | ✓ | ✓ |
| Hit Wicket | ✓ | ✗ | ✓ | ✗ |
| Obstructing Field | ✓ | ✓ | ✓ | ✗ |
| Hit Ball Twice | ✓ | ✓ | ✓ | ✗ |
| Timed Out | ✓ | N/A | N/A | N/A |
| Retired Out | N/A | N/A | N/A | N/A |

### 5.5 Free Hit Rules
- Free Hit is activated after ANY No-Ball delivery.
- On a Free Hit ball: only Run Out, Hit Wicket, and Obstructing the Field are valid dismissals.
- If Free Hit delivery is ALSO a No-Ball or Wide → another Free Hit follows.
- If Free Hit delivery is legal and no wicket → ball counts in over, free_hit_active = FALSE.
- Display FREE HIT banner prominently before the delivery.

### 5.6 Bowler Rules
- A bowler cannot bowl consecutive overs.
- Max quota: T20 = 4 overs, ODI = 10 overs, Test = unlimited.
- A bowler cannot complete a half-over started by another bowler.
- Byes and Leg Byes NOT charged to bowler's runs_conceded.
- Wides and No-Ball penalty ARE charged to bowler's runs_conceded.
- Wickets for bowler: Bowled, Caught, LBW, Stumped, Hit Wicket. NOT Run Out, Retired.

### 5.7 Retired Batter Rules
- Retired Hurt: Not Out. Can return to bat, but ONLY at fall of another wicket. Does not count as a wicket.
- Retired Out: Counts as dismissed. Cannot return. Counts as a wicket.
- App must maintain a retired player list and offer Retired Hurt reinstatement at each fall of wicket.

### 5.8 Impact Player Rules
- One substitution per team per match (main innings + Super Over combined).
- Allowed only at: start of over, fall of wicket, innings break.
- Incoming player has a fresh full bowling quota regardless of outgoing player's quota.
- If outgoing player was mid-over when substituted, incoming player cannot complete that over.
- Rule suspended if match is reduced to fewer than 10 overs per side.
- Scorecard must tag Impact Player with ⚡ icon.
- Both outgoing and incoming players appear in the playing XI list (12 names displayed).

### 5.9 LBW Rules (for Wicket Dialog display purposes)
- Ball must pitch in line with stumps or on the off side.
- If pitches outside leg stump: not out.
- If batsman plays a shot AND ball hits outside off stump line: not out.
- These are informational notes in the app — umpire's call is final, app records as instructed.

### 5.10 Innings End Triggers
- 10 wickets fallen: innings ends immediately on that ball, even mid-over.
- All overs bowled: innings ends.
- Target reached (Inn2): innings ends immediately on the scoring ball.

### 5.11 Overthrow Logic
- Total runs = runs completed BEFORE throw left fielder's hand + overthrow runs.
- If overthrow ball reaches boundary: 4 (boundary) + runs completed before throw.
- Attribution follows original ball attribution (bat or extras).
- Strike rotation based on TOTAL runs (odd = rotate, even = no).

### 5.12 Stumping on Wide
- Stumping IS valid on a Wide delivery (Law 22.9).
- 1 Wide penalty still awarded.
- Wicket recorded as Stumped.

### 5.13 Mankad (Non-Striker Run Out — Law 41.16)
- Legitimate dismissal as of MCC 2022. Categorized as Run Out (Non-Striker).
- No appeal required if wicket broken before delivery.
- Not No-Ball. Counted as a wicket. Attributed as "Run Out (Non-Striker)" in scorecard.

### 5.14 Incoming Batter End Rules (Post-Wicket)
- Caught: Incoming batter ALWAYS to striker's end (MCC 2022), regardless of whether batsmen crossed.
- All other dismissals: If batsmen had crossed → incoming batter to non-striker's end. If not crossed → striker's end.

---

## 6. DATA MODELS

### 6.1 User
```
User {
  user_id        : UUID (PK)
  name           : String (required)
  email          : String (unique, required)
  password_hash  : String (required)
  role           : Enum [scorer, organizer, spectator, captain]
  created_at     : Timestamp
  updated_at     : Timestamp
}
```

### 6.2 Team
```
Team {
  team_id        : UUID (PK)
  team_name      : String (required)
  created_by     : UUID (FK → User)
  created_at     : Timestamp
}
```

### 6.3 Player
```
Player {
  player_id      : UUID (PK)
  team_id        : UUID (FK → Team)
  name           : String (required)
  jersey_number  : Int (required, unique within team)
  batting_style  : Enum [right_hand, left_hand]
  bowling_style  : String (optional, e.g. "Right arm fast")
  role           : Enum [batsman, bowler, allrounder, wicketkeeper]
  created_at     : Timestamp
}
```

### 6.4 Match
```
Match {
  match_id           : UUID (PK)
  match_type         : Enum [T20, ODI, Test, Custom]
  total_overs        : Int
  ball_type          : Enum [hardball, tennis]
  venue              : String (optional)
  dls_enabled        : Boolean
  impact_player_rule : Boolean
  team_a_id          : UUID (FK → Team)
  team_b_id          : UUID (FK → Team)
  toss_winner_id     : UUID (FK → Team)
  toss_choice        : Enum [bat, bowl]
  batting_team_inn1  : UUID (FK → Team)
  bowling_team_inn1  : UUID (FK → Team)
  status             : Enum [setup, live, completed, abandoned]
  result             : String (nullable, e.g. "Team A won by 5 wickets")
  player_of_match    : UUID (FK → Player, nullable)
  created_by         : UUID (FK → User)
  created_at         : Timestamp
  completed_at       : Timestamp (nullable)
}
```

### 6.5 TeamSheet (15-player declaration for Impact Player)
```
TeamSheet {
  sheet_id       : UUID (PK)
  match_id       : UUID (FK → Match)
  team_id        : UUID (FK → Team)
  playing_xi     : UUID[] (array of 11 Player UUIDs)
  substitutes    : UUID[] (array of up to 4 Player UUIDs)
  captain_id     : UUID (FK → Player)
  keeper_id      : UUID (FK → Player)
}
```

### 6.6 Innings
```
Innings {
  innings_id         : UUID (PK)
  match_id           : UUID (FK → Match)
  innings_number     : Int (1 or 2)
  batting_team_id    : UUID (FK → Team)
  bowling_team_id    : UUID (FK → Team)
  total_score        : Int
  wickets_fallen     : Int
  overs_completed    : Float
  extras_total       : Int
  status             : Enum [in_progress, completed]
  all_out            : Boolean
  target             : Int (nullable, set after Inn1)
}
```

### 6.7 BattingEntry
```
BattingEntry {
  entry_id           : UUID (PK)
  innings_id         : UUID (FK → Innings)
  player_id          : UUID (FK → Player)
  batting_position   : Int
  runs               : Int (default 0)
  balls_faced        : Int (default 0)
  fours              : Int (default 0)
  sixes              : Int (default 0)
  strike_rate        : Float (computed: runs/balls_faced*100)
  dismissal_type     : Enum [Bowled, Caught, LBW, RunOut, Stumped, HitWicket, ObstructingField, HitBallTwice, TimedOut, RetiredHurt, RetiredOut, NotOut, DNB]
  dismissed_by       : UUID (FK → Player, nullable)
  fielder            : UUID (FK → Player, nullable)
  is_impact_player   : Boolean (default false)
  on_strike          : Boolean (live state)
  retired_status     : Enum [hurt, out, null]
}
```

### 6.8 BowlingEntry
```
BowlingEntry {
  entry_id           : UUID (PK)
  innings_id         : UUID (FK → Innings)
  player_id          : UUID (FK → Player)
  balls_bowled       : Int (default 0)
  overs_bowled       : Float (computed: balls_bowled/6)
  maidens            : Int (default 0)
  runs_conceded      : Int (default 0)
  wickets            : Int (default 0)
  economy_rate       : Float (computed)
  wides              : Int (default 0)
  no_balls           : Int (default 0)
  max_overs_quota    : Int
  is_impact_player   : Boolean (default false)
  last_over_bowled   : Int (nullable, for consecutive over check)
}
```

### 6.9 ExtrasLedger
```
ExtrasLedger {
  ledger_id      : UUID (PK)
  innings_id     : UUID (FK → Innings, unique)
  byes           : Int (default 0)
  leg_byes       : Int (default 0)
  wides          : Int (default 0)
  no_balls       : Int (default 0)
  no_ball_runs   : Int (default 0)
  penalty_runs   : Int (default 0)
  total          : Int (computed)
}
```

### 6.10 FallOfWicket
```
FallOfWicket {
  fow_id             : UUID (PK)
  innings_id         : UUID (FK → Innings)
  wicket_number      : Int
  score_at_fall      : Int
  over_at_fall       : Float
  dismissed_player   : UUID (FK → Player)
  dismissal_type     : Enum
  partnership_runs   : Int
  partnership_balls  : Int
}
```

### 6.11 BallEvent (Ball-by-Ball Log + Undo Support)
```
BallEvent {
  event_id           : UUID (PK)
  innings_id         : UUID (FK → Innings)
  over_number        : Int
  ball_number        : Int (1-6, legal ball count)
  sequence_number    : Int (absolute ball sequence including wides/no-balls)
  delivery_type      : Enum [legal, no_ball, wide, dead_ball]
  bat_runs           : Int
  extras_type        : Enum [none, byes, leg_byes, wides, no_ball]
  extras_runs        : Int
  total_runs         : Int
  boundary_4         : Boolean
  boundary_6         : Boolean
  is_overthrow       : Boolean
  overthrow_runs     : Int
  wicket_fell        : Boolean
  dismissal_type     : Enum (nullable)
  dismissed_player   : UUID (nullable)
  dismissed_by       : UUID (nullable)
  fielder            : UUID (nullable)
  free_hit_active_before : Boolean
  free_hit_active_after  : Boolean
  striker_id         : UUID
  non_striker_id     : UUID
  bowler_id          : UUID
  match_state_snapshot : JSONB (full MatchState for undo)
  created_at         : Timestamp
}
```

### 6.12 ImpactPlayerSubstitution
```
ImpactPlayerSubstitution {
  sub_id             : UUID (PK)
  match_id           : UUID (FK → Match)
  team_id            : UUID (FK → Team)
  innings_number     : Int
  over_ball          : String (e.g. "11.0")
  trigger            : Enum [wicket, start_of_over, innings_break]
  outgoing_player    : UUID (FK → Player)
  incoming_player    : UUID (FK → Player)
  incoming_role      : Enum [batter, bowler, allrounder]
  bowling_quota_remaining : Int
  created_at         : Timestamp
}
```

### 6.13 PowerplayTracker
```
PowerplayTracker {
  tracker_id         : UUID (PK)
  innings_id         : UUID (FK → Innings)
  pp1_start          : Int
  pp1_end            : Int
  pp2_start          : Int (nullable, ODI only)
  pp2_end            : Int (nullable)
  pp3_start          : Int (nullable, ODI only)
  pp3_end            : Int (nullable)
  current_pp         : Int (nullable)
  max_fielders_outside : Int
  runs_in_pp1        : Int
  wickets_in_pp1     : Int
  runs_in_pp2        : Int (nullable)
  wickets_in_pp2     : Int (nullable)
}
```

### 6.14 MatchState (Live In-Memory + Persisted)
```
MatchState {
  match_id           : UUID
  match_type         : Enum
  total_overs        : Int
  current_innings    : Int
  team_batting_id    : UUID
  team_bowling_id    : UUID
  team_score         : Int
  wickets_fallen     : Int
  overs_completed    : Int
  balls_this_over    : Int (legal balls, 0-5)
  striker_id         : UUID
  non_striker_id     : UUID
  current_bowler_id  : UUID
  previous_bowler_id : UUID (for consecutive over enforcement)
  free_hit_active    : Boolean
  target             : Int (nullable)
  innings1_score     : Int (nullable)
  powerplay          : PowerplayTracker
  extras             : ExtrasLedger
  batting_entries    : BattingEntry[]
  bowling_entries    : BowlingEntry[]
  fall_of_wickets    : FallOfWicket[]
  impact_subs        : ImpactPlayerSubstitution[]
  retired_players    : {player_id: UUID, status: 'hurt'|'out'}[]
  last_ball_event    : BallEvent (for undo)
}
```

---

## 7. API DESIGN

Base URL: `https://api.cricscorepro.com/v1`  
Authentication: JWT Bearer token on all protected routes.

### 7.1 Auth Module
```
POST   /auth/register         → {name, email, password, role} → {user, token}
POST   /auth/login            → {email, password} → {user, token}
POST   /auth/logout           → {} → {success}
POST   /auth/forgot-password  → {email} → {message}
POST   /auth/reset-password   → {token, new_password} → {success}
GET    /auth/me               → {} → {user}
```

### 7.2 Teams Module
```
GET    /teams                 → [] → [{team}]
POST   /teams                 → {team_name} → {team}
GET    /teams/:team_id        → {} → {team, players}
PUT    /teams/:team_id        → {team_name} → {team}
DELETE /teams/:team_id        → {} → {success}
GET    /teams/:team_id/players → {} → [{player}]
```

### 7.3 Players Module
```
GET    /players/:player_id    → {} → {player}
POST   /teams/:team_id/players → {name, jersey_number, batting_style, bowling_style, role} → {player}
PUT    /players/:player_id    → {name, jersey_number, ...} → {player}
DELETE /players/:player_id    → {} → {success}
```
Error codes: 409 Conflict (duplicate jersey), 404 Not Found

### 7.4 Matches Module
```
GET    /matches               → [] → [{match summary}]
POST   /matches               → {match_type, total_overs, ball_type, dls_enabled, impact_player_rule, team_a_id, team_b_id, venue} → {match}
GET    /matches/:match_id     → {} → {match full detail}
PUT    /matches/:match_id/toss → {toss_winner_id, toss_choice} → {match}
PUT    /matches/:match_id/team-sheet → {team_id, playing_xi[], substitutes[], captain_id, keeper_id} → {team_sheet}
PUT    /matches/:match_id/opening-selection → {innings_number, on_strike_id, non_strike_id, opening_bowler_id} → {innings}
GET    /matches/:match_id/state → {} → {MatchState}
PUT    /matches/:match_id/abandon → {} → {match}
```

### 7.5 Scoring Module (Core)
```
POST   /matches/:match_id/innings/:innings_id/ball
  Request: {
    delivery_type: Enum,
    bat_runs: Int,
    extras_type: Enum,
    extras_runs: Int,
    boundary_4: Boolean,
    boundary_6: Boolean,
    is_overthrow: Boolean,
    overthrow_runs: Int,
    wicket_fell: Boolean,
    dismissal_type: Enum,
    dismissed_player_id: UUID,
    dismissed_by_id: UUID,
    fielder_id: UUID,
    striker_id: UUID,
    non_striker_id: UUID,
    bowler_id: UUID
  }
  Response: {ball_event, updated_match_state}
  Errors: 400 (invalid dismissal for delivery type), 422 (validation error), 409 (innings complete)

DELETE /matches/:match_id/innings/:innings_id/ball/last (Undo)
  Response: {reverted_ball_event, restored_match_state}

POST   /matches/:match_id/innings/:innings_id/new-batsman
  Request: {incoming_player_id, incoming_end: Enum[striker, non_striker]}
  Response: {updated_match_state}

POST   /matches/:match_id/innings/:innings_id/end-over
  Request: {new_bowler_id}
  Response: {updated_match_state}
  Errors: 400 (same bowler as previous over), 400 (bowler quota exceeded)

POST   /matches/:match_id/impact-player
  Request: {team_id, outgoing_player_id, incoming_player_id, trigger: Enum}
  Response: {sub_log, updated_match_state}
  Errors: 400 (already used), 400 (invalid timing), 400 (match < 10 overs), 400 (player not in sub list)

POST   /matches/:match_id/innings/:innings_id/retire
  Request: {player_id, retire_type: Enum[hurt, out]}
  Response: {updated_match_state}

POST   /matches/:match_id/innings/:innings_id/reinstate
  Request: {player_id}
  Response: {updated_match_state}
  Errors: 400 (player is Retired Out, cannot reinstate), 400 (not at fall of wicket)
```

### 7.6 Scorecard Module
```
GET    /matches/:match_id/scorecard
  Response: {
    match_info,
    innings1: {batting[], bowling[], extras, fall_of_wickets, powerplay_summary},
    innings2: {batting[], bowling[], extras, fall_of_wickets, powerplay_summary},
    impact_subs[],
    result
  }

GET    /matches/:match_id/ball-by-ball
  Response: [{ball_event}] (ordered by sequence_number)
```

### 7.7 Tournament Module (Admin)
```
GET    /tournaments           → [{tournament}]
POST   /tournaments           → {name, format, team_ids[]} → {tournament}
GET    /tournaments/:id       → {tournament, standings}
PUT    /tournaments/:id       → {name} → {tournament}
DELETE /tournaments/:id       → {} → {success}
```

### 7.8 Standard Error Response Format
```json
{
  "error": true,
  "code": "INVALID_DISMISSAL",
  "message": "Caught dismissal is not valid on a No-Ball delivery.",
  "field": "dismissal_type"
}
```

---

## 8. TECH STACK

### Frontend (Mobile App)
- **Framework:** React Native (Expo managed workflow)
- **State Management:** Redux Toolkit + RTK Query (for API caching and real-time state)
- **Navigation:** React Navigation v6
- **UI Components:** React Native Paper + custom components
- **Real-time:** Socket.IO client (for live scorecard spectator view)
- **Storage:** AsyncStorage (for auth token, offline match state cache)
- **PDF Export:** react-native-html-to-pdf

### Frontend (Web Admin / Spectator)
- **Framework:** React.js (Vite)
- **State Management:** Redux Toolkit
- **UI:** Tailwind CSS + Headless UI
- **Real-time:** Socket.IO client

### Backend
- **Runtime:** Node.js (v20 LTS)
- **Framework:** Express.js
- **WebSockets:** Socket.IO (for live scoring broadcast)
- **Validation:** Zod (schema validation for all API inputs)
- **Auth:** JWT (jsonwebtoken) + bcrypt
- **ORM:** Prisma (with PostgreSQL)

### Database
- **Primary:** PostgreSQL (v15) — all relational match data
- **Cache:** Redis — MatchState live cache (key: `match:{match_id}:state`), refreshed on every ball
- **File Storage:** AWS S3 (for exported scorecards/PDFs)

### Infrastructure
- **Hosting:** AWS (EC2 for backend, RDS for PostgreSQL, ElastiCache for Redis)
- **CI/CD:** GitHub Actions
- **Logging:** Winston + AWS CloudWatch
- **Environment:** dotenv for config; never hardcode secrets

---

## 9. NON-FUNCTIONAL REQUIREMENTS

### Performance
- Live ball submission (POST /ball) must respond in < 500ms.
- Scorecard GET must respond in < 200ms (served from Redis cache).
- Mobile app must support offline mode: cache MatchState locally, sync when reconnected.
- Real-time spectator score updates via WebSocket within 1 second of ball confirmation.

### Security
- All routes (except /auth/login, /auth/register, /matches/:id/scorecard spectator) require JWT.
- Role-based access control (RBAC) enforced at route middleware level.
- Input sanitization on all user inputs.
- Rate limiting: 100 req/min per IP on auth endpoints; 1000 req/min per authenticated user on scoring.
- HTTPS enforced. No plain HTTP in production.
- Passwords hashed with bcrypt (salt rounds: 12).
- JWT expiry: 7 days; refresh token pattern for mobile.

### Scalability
- Stateless backend (MatchState in Redis, not in-process memory).
- Horizontal scaling ready: Node.js instances behind a load balancer.
- Socket.IO with Redis adapter for multi-instance WebSocket broadcast.

### Logging
- Log every ball event with: timestamp, match_id, innings_id, sequence_number, scorer user_id.
- Log all Impact Player substitutions.
- Log all errors with stack traces (ERROR level).
- Log API response times (INFO level).
- Do NOT log raw passwords or JWT tokens.

### Error Handling
- All async route handlers wrapped in try/catch.
- Global Express error handler returns standardized error JSON.
- Client must handle: 400 (validation), 401 (unauthorized), 403 (forbidden), 404 (not found), 409 (conflict), 422 (business rule violation), 500 (server error).
- Mobile app shows user-friendly toast messages for all errors.
- Retry logic (3 attempts, exponential backoff) for network failures on mobile.

### Data Integrity
- All ball events persisted to PostgreSQL with full match_state_snapshot (JSONB) for undo and replay.
- Database transactions used for all ball event processing (atomic: insert BallEvent + update BattingEntry + update BowlingEntry + update Innings).
- Soft deletes for matches (status = 'abandoned'), never hard delete match data.

---

## 10. CODING INSTRUCTIONS

### General
- Write modular, clean, production-ready code.
- Follow SOLID principles: Single Responsibility, Open/Closed, Liskov Substitution, Interface Segregation, Dependency Inversion.
- Every function/method must have a single, clear responsibility.
- No function longer than 50 lines. Extract helpers ruthlessly.
- Add JSDoc comments on all public functions/methods.
- No magic numbers: use named constants (e.g., `MAX_OVERS_T20 = 4`, `LEGAL_BALLS_PER_OVER = 6`).
- Use TypeScript across entire codebase (frontend and backend).

### Backend
- Separate layers: Routes → Controllers → Services → Repositories (data access).
- All business logic in Services layer. Controllers only handle HTTP request/response.
- All DB queries in Repository layer via Prisma.
- All API input validated with Zod schemas before reaching controllers.
- Scoring Engine (ScoringService) is the most critical module:
  - `classifyDelivery(input) → DeliveryClassification`
  - `calculateRuns(input, classification) → RunsResult`
  - `validateDismissal(dismissalType, deliveryType) → boolean`
  - `updateStrike(matchState, runsResult, dismissal) → StrikeResult`
  - `processOverCompletion(matchState, bowlerId) → OverResult`
  - `checkFreeHit(matchState, deliveryType) → boolean`
  - `validateImpactPlayer(matchState, teamId, subRequest) → ValidationResult`
  - `processBall(matchState, ballInput) → UpdatedMatchState` ← orchestrator
- ScoringService must be fully unit-tested.

### Frontend (React Native)
- Components in `src/components/` (reusable, dumb).
- Screens in `src/screens/` (connected to Redux).
- Business display logic in `src/hooks/` (custom hooks).
- All scoring-related state in Redux store slice: `scoringSlice`.
- Free Hit banner: always rendered in LiveScoringScreen but hidden unless `free_hit_active` is true. Use a prominent red/amber banner with animation.
- Wicket Dialog: renders dismissal options as a grid; grey out invalid options (opacity 0.3, disabled). Do not hide them — show why they are invalid on tap.
- Confirm Ball button: disabled (grey, no tap) until delivery_type AND runs are selected.
- Undo button: tappable only if `last_ball_event` exists in state.
- Scoreboard header: sticky at top of LiveScoringScreen. Never scrolls away.
- Impact Player button: badge style, tappable only if rule is enabled and this team's substitution not yet used.

### Reusable Components (Build These)
- `ScoreboardHeader` — sticky score display
- `BatsmanCard` — shows batter name, runs, balls, SR
- `BowlerCard` — shows bowler name, overs, runs, wickets, econ
- `DeliveryTypeSelector` — Legal / Wide / No-Ball / Dead Ball buttons
- `RunsSelector` — 0/1/2/3/4/6/Custom selector grid
- `ExtrasSelector` — Byes / Leg Byes / None (contextual)
- `WicketDialog` — modal with dismissal type grid + fielder selector
- `BatsmanSelector` — searchable list modal for selecting batsmen
- `BowlerSelector` — searchable list with quota display
- `ImpactPlayerModal` — full substitution flow
- `ScorecardTable` — reusable batting and bowling table
- `FallOfWicketsRow` — FoW display
- `FreeHitBanner` — animated, prominent warning banner
- `ErrorToast` — standardized error display
- `ConfirmDialog` — reusable confirm/cancel modal

### Validation Guards (Enforce These Everywhere)
- Dismissal type MUST be validated against delivery type before acceptance (server-side + client-side).
- Bowler quota MUST be checked before allowing bowler selection at end of over.
- Consecutive over rule MUST be enforced: block selecting previous over's bowler.
- Impact Player substitution MUST pass all 4 checks before execution.
- Ball count MUST NOT increment for Wide or No-Ball deliveries.
- Free Hit MUST be set after every No-Ball (any type) without exception.
- Innings MUST end immediately when 10 wickets fall, even mid-over.
- Innings MUST end immediately when target is reached in Innings 2.
- All database writes for a ball event MUST be in a single transaction.

### Testing Requirements
- Unit tests for ScoringService covering all decision table scenarios (Section 4 of this spec).
- Minimum test cases (all must pass):
  1. No-Ball + Caught → Not Out, Free Hit follows
  2. Wide + Stumping → Out, 1 Wide run
  3. Free Hit + Bowled → Not Out, ball counts, no more Free Hit
  4. Free Hit + Run Out → Out, valid
  5. Overthrow boundary (1 run before throw + boundary) → 5 runs total, strike rotates
  6. Caught (batsmen crossed) → New batter at striker's end
  7. Mankad Run Out → counted as Run Out (Non-Striker)
  8. Impact Player used twice by same team → rejected with error
  9. Impact Player in match < 10 overs → rejected
  10. Consecutive bowler → blocked
  11. 10 wickets mid-over → innings ends immediately
  12. Wide + 2 overthrow boundary → 1+2+4=7 wides, all to bowler
  13. Last ball: Caught, batsmen crossed → New batter at striker's end
  14. Retired Hurt reinstatement → only at fall of wicket
  15. Free Hit + No-Ball → another Free Hit

---

## 11. DELIVERY FORMAT EXPECTATIONS

### Project Structure
```
cricscore-pro/
├── apps/
│   ├── mobile/          (React Native / Expo)
│   └── web/             (React.js admin panel)
├── packages/
│   ├── api/             (Node.js / Express backend)
│   │   ├── src/
│   │   │   ├── routes/
│   │   │   ├── controllers/
│   │   │   ├── services/
│   │   │   │   └── ScoringService.ts  ← MOST CRITICAL
│   │   │   ├── repositories/
│   │   │   ├── middleware/
│   │   │   ├── validators/
│   │   │   └── utils/
│   │   └── prisma/
│   │       └── schema.prisma
│   └── shared/          (shared TypeScript types used by all packages)
├── docker-compose.yml
└── README.md
```

### Environment Variables Required
```
DATABASE_URL=postgresql://user:pass@localhost:5432/cricscore
REDIS_URL=redis://localhost:6379
JWT_SECRET=<strong random string>
JWT_EXPIRES_IN=7d
AWS_BUCKET_NAME=cricscore-exports
AWS_REGION=ap-south-1
PORT=3000
NODE_ENV=development
```

### README Must Include
- Local setup steps (docker-compose up, npm install, prisma migrate)
- How to run tests (npm test)
- API documentation link
- Environment variable descriptions
- Scoring engine architecture overview

---

## 12. FINAL CONSTRAINTS

- Do NOT use any deprecated libraries.
- Do NOT skip the ScoringService unit tests — they are the safety net for the scoring engine.
- Do NOT allow client-side-only validation for scoring rules — ALL rules must be enforced server-side.
- Do NOT store the full match state only in memory — persist every ball event and snapshot to PostgreSQL.
- Do NOT allow hard deletion of any match, ball event, or player involved in a match.
- Do NOT allow a bowler to be selected who has bowled the maximum overs quota.
- Do NOT allow the same bowler for consecutive overs.
- Do NOT allow Impact Player substitution outside valid triggers (over start / wicket fall).
- The scoring engine (ScoringService.processBall) is the single source of truth — no scoring logic lives in controllers, reducers, or components.
- The app must be fully usable offline for scoring (queue ball events locally, sync to server when back online).
- Build the app so it can be extended to Test match format (unlimited bowler quota, multi-day innings) with minimal changes — use format-based configuration objects, not if/else chains.

---

MASTER PROMPT END
