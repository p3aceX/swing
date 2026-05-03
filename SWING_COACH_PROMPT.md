# swing-coach Flutter App — Screen Implementation Prompt

## Context

`swing-coach` is the **Coach** Flutter app. Authentication (Firebase phone 2FA) and business registration are already implemented. This prompt covers all screens that come after registration.

Backend base URL: `{{BASE_URL}}`
Auth: JWT Bearer token in `Authorization` header (refreshed via `/auth/refresh`)

---

## App Architecture

- **State management**: Riverpod
- **Navigation**: go_router
- **UI**: Flat, edge-to-edge, no cards/borders/shadows/glass — plain surfaces, dividers only where necessary
- **All amounts** stored in **paise** (integer). Display by dividing by 100 (₹).
- **Coach context**: After registration, coach has a `CoachProfile`. Store `coachId` globally. All `/coach/*` endpoints are self-scoped (auth token identifies the coach).

---

## Post-Auth Flow

After successful biz login + coach profile creation via `/biz/coach`, navigate to **Home**. The app shell has a bottom nav with 4 tabs:

1. Home (Today)
2. Students
3. Drills
4. More (Schedules, Gigs, Earnings, Report Cards, Profile)

---

## Screens

---

### 1. Home — Today's View

**Route**: `/home`
**APIs**:
- `GET /coach/sessions?page=1&limit=10` — filter today's sessions client-side
- `GET /coach/batches` — badge count

**Purpose**: Coach's command center for the day.

**Data to display**:
- Greeting + date
- Today's sessions list (flat): time, session type, batch name, academy name, status badge
  - If session is LIVE: highlight with accent color, show "Open Attendance" button
- Active batches count + quick link
- Pending feedback count (sessions COMPLETED with no feedback logged)
- Quick actions: Start Session, Create Drill, Give Feedback

**UI Notes**:
- Session rows are the primary content — give them vertical breathing room
- No decorative containers; use `ListTile` equivalents with dividers

---

### 2. Sessions

**Route**: `/sessions`
**APIs**:
- `GET /coach/sessions?page=&limit=` — all sessions paginated
- `POST /coach/sessions` — create session
- `POST /coach/sessions/:id/cancel` — cancel
- `POST /coach/sessions/:id/generate-qr` — generate QR
- `POST /coach/sessions/:id/close-qr` — close QR
- `POST /coach/sessions/:id/attendance` — override attendance

#### 2a. Session List Screen
- Date filter (week view by default, switch to list view)
- Tabs: Upcoming / Live / Completed / Cancelled
- Each row: type label, batch, academy, date+time, duration
- FAB → Create Session
- Tap → Session Detail

#### 2b. Create Session Screen
**Route**: `/sessions/create`

Fields:
- sessionType (dropdown): PACE_NETS / SPIN_NETS / THROWDOWN / POWER_HITTING / FITNESS / FIELDING / MATCH_PRACTICE / VIDEO_REVIEW / CUSTOM
  - If CUSTOM: show `sessionTypeName` text input
- scheduledAt (date + time picker)
- durationMins (number, default 60)
- academyId (optional — pick from coach's linked academies via `GET /coach/batches` grouped by academy)
- batchId (optional — pick from batches in selected academy)
- locationName (text)
- notes (multiline, optional)
- drillPlanId (optional — pick from `GET /coach/drill-plans`)

**API**: `POST /coach/sessions`

#### 2c. Session Detail Screen
**Route**: `/sessions/:sessionId`

**Header**: Session type, batch, academy, date/time, status badge

**Actions bar** (contextual by status):
- If SCHEDULED: "Start" (update status), "Cancel" button
- If LIVE: "Generate QR", "Close QR", "Mark Complete"
- If COMPLETED: "View Attendance", "Give Feedback"

**QR Code section** (when LIVE + QR generated):
- Show QR image full-width for students to scan
- Countdown to qrExpiresAt
- "Close QR" button stops new scans

**Attendance tab**:
- List of students in batch with their current attendance status
- Status badge per student: PRESENT (green) / LATE (amber) / ABSENT (red) / EXCUSED / WALK_IN / EARLY_EXIT
- Tap student row → Override Attendance bottom sheet:
  - Status picker
  - notes field
  - `POST /coach/sessions/:id/attendance` with `{playerProfileId, status, notes}`

**Drill Plan tab** (if drillPlanId set):
- List drills in the plan with order, reps, sets

**Notes tab**:
- Session notes (read-only if COMPLETED)

---

### 3. Recurring Schedules

**Route**: `/schedules`
**APIs**:
- `GET /coach/schedules`
- `POST /coach/schedules`
- `PATCH /coach/schedules/:id`
- `POST /coach/schedules/:id/generate` — generate sessions for N weeks ahead

#### 3a. Schedule List Screen
- List of active recurring schedules
- Each row: session type, days of week (e.g. "Mon, Wed, Fri"), start time, batch name
- Toggle to activate/deactivate (PATCH isActive)
- Tap → Schedule Detail / Edit
- FAB → Create Schedule

#### 3b. Create/Edit Schedule Screen
Fields:
- sessionType (same dropdown as session)
- daysOfWeek (multi-select: Mon–Sun checkboxes)
- startTime (time picker, HH:mm)
- durationMins (number)
- academyId (optional)
- batchId (optional)

**API**: `POST /coach/schedules`

#### 3c. Generate Sessions
On Schedule Detail, button "Generate Sessions":
- Input: weeksAhead (1–8, default 2)
- `POST /coach/schedules/:id/generate` with `{weeksAhead}`
- Show success with count of sessions created

---

### 4. Students

**Route**: `/students`
**API**: `GET /coach/students` — list with attendance stats

#### 4a. Student List Screen
- List of all students across all coach's batches
- Each row: student name, batch name, attendance % (current month), signal badge (EXCELLING / ON_TRACK / NEEDS_ATTENTION / CRITICAL)
- Search by name
- Filter by batch
- Tap → Student Detail

#### 4b. Student Detail Screen
**Route**: `/students/:playerProfileId`

**Profile section**:
- Name, batch, enrollment status
- bloodGroup, DOB, city, emergency contact (read-only, from enrollment)

**Attendance section**:
- Sessions attended / total sessions (current month)
- Attendance % with color indicator

**Feedback section**:
- List of past feedback given by this coach for this student (from `/coach/feedback` or embedded in profile)
- Button: "Give Feedback" → Feedback Sheet

**Report Cards section**:
- List of published report cards (month/year, swingIndex range, attendanceRate)
- Button: "Create Report Card" → Report Card Screen

**Performance Signal** (PlayerSessionSignal):
- Latest signal: overallSignal badge
- Strengths, work-on areas (skill names)
- Follow-up in N days

---

### 5. Feedback

**Route**: Accessed from Student Detail or Session Detail
**API**: `POST /coach/feedback`

#### 5a. Give Feedback Bottom Sheet / Screen
Fields:
- playerProfileId (pre-filled if coming from student/session)
- sessionId (pre-filled if from session, otherwise optional picker)
- feedbackText (multiline required)
- tags (multi-select chips — e.g. "Footwork", "Grip", "Focus" — free text or predefined)
- isVisibleToParent toggle (default false)
- voiceNoteUrl (optional — for future voice recording integration)
- videoClipUrl + videoTimestamp (optional)

**API**: `POST /coach/feedback`

---

### 6. Report Cards

**Route**: `/report-cards`
**APIs**:
- `GET /coach/report-cards`
- `POST /coach/report-cards`
- `POST /coach/report-cards/:id/publish`

#### 6a. Report Card List Screen
- List of all report cards (all students)
- Each row: student name, month/year, swingIndex range, isPublished badge
- Filter by month/student
- FAB → Create Report Card
- Tap → Report Card Detail

#### 6b. Create Report Card Screen
**Route**: `/report-cards/create`

Fields:
- playerProfileId (student picker — search from coach's students)
- periodMonth (1–12 picker)
- periodYear (year picker)
- swingIndexStart (number 0–100)
- swingIndexEnd (number 0–100)
- attendanceRate (0.0–1.0, display as %)
- drillCompletion (0.0–1.0, display as %)
- coachNarrative (multiline — overall summary)
- strengthsNote (multiline)
- focusAreasNote (multiline)
- goalsNextMonth (multiline)

**API**: `POST /coach/report-cards`

#### 6c. Report Card Detail Screen
- All fields displayed in reading layout
- "Publish" button if not yet published → `POST /coach/report-cards/:id/publish`
  - Confirm dialog: "This will send the report card to the student's parent. Continue?"
- parentViewedAt timestamp if parent has viewed

---

### 7. Drills

**Route**: `/drills`
**APIs**:
- `GET /coach/drills`
- `POST /coach/drills`
- `GET /coach/drills/:id`
- `GET /coach/drill-plans`
- `POST /coach/drill-plans`

#### 7a. Drill Library Screen
- Grid or list of coach's drills
- Filter by: roleTags (BATSMAN / BOWLER / etc.), category, difficulty
- Each item: drill name, category badge, difficulty badge, duration, usageCount
- FAB → Create Drill
- Tap → Drill Detail

#### 7b. Create/Edit Drill Screen
**Route**: `/drills/create`

Fields:
- name (required)
- description (multiline)
- roleTags (multi-select: BATSMAN / BOWLER / ALL_ROUNDER / FIELDER / WICKET_KEEPER)
- category (TECHNIQUE / FITNESS / MENTAL / MATCH_SIMULATION)
- difficulty (BEGINNER / INTERMEDIATE / ADVANCED)
- durationMins (number)
- targetUnit (BALLS / OVERS / MINUTES / REPS / SESSIONS)
- skillArea (text — e.g. "Cover Drive", "Yorker")
- subSkill (text)
- videoUrl (optional URL input)
- isActive toggle (default true)
- isPublic toggle (share with other coaches on platform)

**API**: `POST /coach/drills`

#### 7c. Drill Detail Screen
- All drill fields displayed
- usageCount (how many sessions it's been part of)
- Edit button → same form pre-filled

#### 7d. Drill Plans

**Route**: `/drill-plans`

**List screen**:
- Coach's drill plans — name, description, item count
- FAB → Create Plan

**Create Plan Screen**:
Fields:
- name
- description
- items (add drills from library):
  - For each item: drill picker, order (auto-increment), reps, sets, notes
  - Reorderable list (drag handle)

**API**: `POST /coach/drill-plans`

---

### 8. Batches

**Route**: `/batches`
**API**: `GET /coach/batches`

#### 8a. Batch List Screen
- All batches where coach is assigned
- Each row: batch name, academy name, isHeadCoach badge, student count
- Read-only (modifications done via swing-club app by academy owner)
- Tap → Batch Detail (read-only):
  - Batch info (name, ageGroup, sport, schedule times)
  - Enrolled students list
  - Link to create a session for this batch

---

### 9. Gig Bookings

**Route**: `/gigs`
**APIs**:
- `GET /coach/gig-bookings?page=&limit=`
- `GET /coach/earnings`

#### 9a. Gig Booking List Screen
- Paginated list of all gig bookings
- Tabs: Upcoming / Completed / Cancelled
- Each row: student name, gig title, scheduled date+time, amount (₹), status badge
- Tap → Booking Detail (read-only for now)

**Booking Detail**:
- Student info, scheduled time, duration, location/meeting link
- amountPaise displayed as ₹, platformFeePaise and coachPayoutPaise
- playerGoals (what student wants to achieve)
- Status badge
- If COMPLETED: coachPostNotes field (add session notes)

#### 9b. Earnings Screen
**Route**: `/earnings`
**API**: `GET /coach/earnings`

- Total earnings (lifetime)
- Monthly breakdown: month name, amount ₹
- Flat list — month | sessions | amount
- No charts (flat data presentation only)

---

### 10. 1-on-1 Profile

**Route**: `/one-on-one`
**APIs**:
- `GET /coach/profile` — includes oneOnOneEnabled, hourlyRate
- `PUT /coach/profile` — update oneOnOneEnabled, hourlyRate, publicProfileVisible

#### 10a. 1-on-1 Settings Screen
- isEnabled toggle (maps to `oneOnOneEnabled` in coach profile)
- If enabled:
  - hourlyRate (₹ input — stored as paise)
  - locationTypes multi-select: COACH_GROUND / STUDENT_GROUND / ONLINE
  - maxPerWeek (number — max 1-on-1 sessions per week)
  - expertiseTags (chips — free text)
  - bio (multiline)
- Save → `PUT /coach/profile`

**Note**: Booking management for 1-on-1 is via `GET /1on1/bookings` (check `/1on1` routes). Show incoming booking requests if that endpoint is available.

---

### 11. Coach Profile & Settings

**Route**: `/profile`
**APIs**:
- `GET /coach/profile`
- `PUT /coach/profile`

#### 11a. Profile Screen
Editable sections:
- **Bio & Info**: bio (multiline), city, state, experienceYears
- **Specializations**: chip list (add/remove free-text specializations)
- **Certifications**: chip list (add/remove)
- **Visibility**: publicProfileVisible toggle

Save → `PUT /coach/profile`

#### 11b. App Settings
- Account info (phone from auth)
- Logout → `POST /auth/logout`, clear state, navigate to login

---

## Navigation Map

```
Login (done) → Biz Registration (done) → Coach Profile Setup (done)
  ↓
Home (Today's Sessions)
  ├── Session List
  │    ├── Create Session
  │    └── Session Detail → QR Attendance / Override / Feedback
  ├── Students
  │    └── Student Detail → Feedback Sheet / Report Card
  ├── Drills
  │    ├── Drill Library → Create Drill → Drill Detail
  │    └── Drill Plans → Create Plan
  └── More
       ├── Schedules → Create Schedule → Generate Sessions
       ├── Batches → Batch Detail
       ├── Gig Bookings → Booking Detail
       ├── Earnings
       ├── Report Cards → Create Report Card → Report Card Detail
       ├── 1-on-1 Settings
       └── Profile & Settings → Logout
```

---

## Key Interconnections with Academy (swing-club)

| Coach App Action | Academy Visibility |
|---|---|
| Coach creates a session for a batch | Academy can see it under `/academy/:id/sessions` |
| Coach marks attendance via QR or override | Academy sees attendance in attendance report |
| Coach gives student feedback | Visible to academy owner (and optionally parents) |
| Coach creates/publishes report card | Academy owner can view student progress |
| Coach accepts 1-on-1 booking linked to academy | Academy gets revenue share (academyCutPaise) |
| Academy invites coach → AcademyCoach link | Coach sees new batch in `/coach/batches` |
| Academy assigns coach to batch | Coach can create sessions for that batch |

---

## Data Notes

- All timestamps from API are ISO 8601 UTC. Display in local time.
- Paise → Rupees: divide by 100, prefix `₹`.
- `daysOfWeek` is an array of integers: 0=Sunday, 1=Monday … 6=Saturday.
- `attendanceRate` and `drillCompletion` are floats 0.0–1.0. Display as `(value * 100).round()%`.
- `swingIndex` is 0–100. Display as a number with a progress-style indicator.
- Pagination: default `limit=20`. Use `page` param. Implement infinite scroll.
- On 401: refresh token, retry once, then logout.

---

## Error Handling

- API errors return `{statusCode, message}`. Show a snackbar with `message`.
- Network errors: show a retry option inline — not a full-screen error for lists.
- Form validation: validate before API call; show inline field errors per field.
- QR generation failure: show error snackbar, allow retry.
