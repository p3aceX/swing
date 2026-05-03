# swing-club Flutter App — Screen Implementation Prompt

## Context

`swing-club` is the **Academy Owner / Club Manager** Flutter app. Authentication (Firebase phone 2FA) and business registration are already implemented. This prompt covers all screens that come after registration.

Backend base URL: `{{BASE_URL}}`
Auth: JWT Bearer token in `Authorization` header (refreshed via `/auth/refresh`)

---

## App Architecture

- **State management**: Riverpod
- **Navigation**: go_router
- **UI**: Flat, edge-to-edge, no cards/borders/shadows/glass — plain surfaces, dividers only where necessary
- **All amounts** are stored in **paise** (integer). Display by dividing by 100 (₹).
- **Academy context**: After registration, user has an `academyId`. Store it globally. Every subsequent API call uses it.

---

## Post-Auth Flow

After successful biz login + academy creation via `/biz/academy`, navigate to **Home Dashboard**. The app shell has a bottom nav with 4 tabs:

1. Home (Dashboard)
2. Students
3. Sessions
4. More (Coaches, Fees, Inventory, Announcements, Settings)

---

## Screens

---

### 1. Home Dashboard

**Route**: `/home`
**API**: `GET /academy/my`

**Purpose**: Overview of academy health at a glance.

**Data to display**:
- Academy name, logo, city, planTier badge
- Stats row: `totalStudents`, `totalCoaches`, `totalBatches`
- Today's sessions (call `GET /academy/:id/sessions?from=today&to=today`)
- Pending fees count (from `GET /academy/:id/fee-payments` filter by status=PENDING)
- Quick action buttons: Add Student, Create Session, New Announcement

**UI Notes**:
- Stats in a horizontal row of 3 plain number+label tiles
- Today's sessions as a flat list — session type, batch name, coach name, time
- No decorative containers; use background color contrast and typography hierarchy only

---

### 2. Batches

**Route**: `/batches`
**APIs**:
- `GET /academy/:id/batches` — list batches
- `POST /academy/:id/batches` — create batch
- `PATCH /academy/:id/batches/:batchId` — update batch

#### 2a. Batch List Screen
- Flat list of active batches
- Each row: batch name, age group, student count, primary coach name
- FAB to create new batch
- Tap → Batch Detail

#### 2b. Batch Detail Screen
**Route**: `/batches/:batchId`

Sections (use a tab or scrollable sections):

**Info tab**:
- Name, ageGroup, sport, maxStudents, description
- Edit inline via PATCH

**Schedule tab**:
- List of `BatchSchedule` items (dayOfWeek label, startTime–endTime, groundNote)
- Add schedule: `POST /academy/:id/batches/:batchId/schedules`
  - Fields: dayOfWeek (0-6, shown as Mon–Sun), startTime (HH:mm), endTime (HH:mm), groundNote (optional)
- Delete: `DELETE /academy/:id/batches/:batchId/schedules/:scheduleId`

**Students tab**:
- List enrollments for this batch (filter from `GET /academy/:id/students` or use enrollment list)
- Each row: student name, enrollment status badge, fee status badge
- Tap → Student Detail

**Coaches tab**:
- `POST /academy/:id/batches/:batchId/coaches` — assign a coach (pick from academy's coach list)
- Show assigned coaches with isHeadCoach flag

#### 2c. Create/Edit Batch Bottom Sheet
Fields:
- name (required)
- ageGroup (text, e.g. "U-14", "Open")
- maxStudents (number, default 20)
- sport (dropdown: CRICKET, FOOTBALL, etc.)
- description (multiline)

---

### 3. Students

**Route**: `/students`
**APIs**:
- `GET /academy/:id/students?page=&limit=` — paginated list
- `POST /academy/:id/batches/:batchId/students` — enroll student
- `PATCH /academy/:id/students/:enrollmentId` — update enrollment

#### 3a. Student List Screen
- Paginated flat list with infinite scroll
- Search bar (client-side filter by name)
- Filter chips: All / Active / Trial / Overdue Fees
- Each row: student name, batch name, fee status badge, enrollment status
- FAB → Enroll Student flow

#### 3b. Enroll Student Flow (Multi-step bottom sheet or screen)

**Step 1 — Find Student**:
- Phone number input
- On submit: backend looks up by phone. If found, pre-fills name.

**Step 2 — Batch & Trial**:
- Batch picker (dropdown from `GET /academy/:id/batches`)
- isTrial toggle
- If trial: trialEndsAt date picker

**Step 3 — Fee Setup**:
- feeAmountPaise (number input, display as ₹)
- feeFrequency (dropdown: MONTHLY / QUARTERLY / ANNUAL / ONE_TIME)
- initialPaymentPaise (optional)
- initialPaymentMode (CASH / UPI / CARD / BANK_TRANSFER / CHEQUE)

**Step 4 — Student Details** (optional but recommended):
- bloodGroup
- aadhaarLast4
- dateOfBirth (date picker)
- city
- emergencyContactName + emergencyContactPhone

**API call**: `POST /academy/:id/batches/:batchId/students`

#### 3c. Student Detail Screen
**Route**: `/students/:enrollmentId`

Sections:

**Profile**:
- Name, phone, batch, enrollment status, trial badge if applicable
- bloodGroup, DOB, city, emergency contact
- Edit via PATCH

**Fee Status**:
- Current fee amount, frequency, feeStatus badge
- Button: "Record Payment" → opens Record Payment sheet
- Button: "Send Reminder" → `POST /academy/:id/fee-payments/:paymentId/remind`

**Attendance**:
- Quick stats: sessions attended / total sessions in current month
- Redirect to attendance report filtered by student

**Actions**:
- Change batch (PATCH enrollmentId with new batchId)
- Mark as Inactive / Paused (PATCH enrollmentStatus)
- Add internal remarks (PATCH notes / internalRemarks)

---

### 4. Sessions

**Route**: `/sessions`
**APIs**:
- `GET /academy/:id/sessions?from=&to=&batchId=` — filtered sessions
- `GET /academy/:id/attendance-report?from=&to=&batchId=` — detailed report

#### 4a. Session List Screen
- Date range selector (default: current week)
- Filter by batch (dropdown)
- Flat list: session type, batch, coach, date+time, status badge (LIVE / COMPLETED / CANCELLED)
- Tap → Session Detail

#### 4b. Session Detail Screen
**Route**: `/sessions/:sessionId`

- Session type, batch name, coach name, scheduled time, duration
- Location (if set)
- Status badge
- Attendance list: each student with their status (PRESENT / LATE / ABSENT / etc.)
- If LIVE: show real-time attendance (poll or socket)
- Notes field

#### 4c. Attendance Report Screen
**Route**: `/attendance-report`

- Date range + batch filter
- Summary stats: total sessions, average attendance %, students at risk (<70%)
- Per-student table: name | sessions present | sessions total | %
- Color code: green (≥80%), amber (60–79%), red (<60%)
- Export option (future)

---

### 5. Coaches

**Route**: `/coaches`
**APIs**:
- Coach list: part of `GET /academy/my` or `GET /academy/:id` (coaches relation)
- `POST /academy/:id/coaches` — invite coach by phone
- `PATCH /academy/:id/coaches/:coachLinkId` — update role or deactivate

#### 5a. Coach List Screen
- List of active coaches linked to academy
- Each row: coach name, isHeadCoach badge, assigned batches
- FAB → Invite Coach

#### 5b. Invite Coach Bottom Sheet
- Phone number input
- isHeadCoach toggle
- On submit: `POST /academy/:id/coaches` with `{phone, isHeadCoach}`
- Show success with coach name if found

#### 5c. Coach Detail (in-app)
- Coach profile info (bio, specializations, experienceYears)
- Assigned batches list
- Compensation setup → Compensation Sheet:
  - compensationType dropdown (FIXED_MONTHLY / PER_SESSION / PER_BATCH / REVENUE_SHARE)
  - Amount fields depending on type
  - payoutCycle (MONTHLY / FORTNIGHTLY)
  - `POST /payroll/compensation` (or check payroll routes)
- Deactivate button → PATCH isActive=false

---

### 6. Fee Management

**Route**: `/fees`
**APIs**:
- `GET /academy/:id/fee-payments?page=&limit=` — all payments
- `POST /academy/:id/fee-payments` — record payment
- `POST /academy/:id/fee-structures` — create fee structure
- `GET /academy/:id/fee-payments` — list (filter by status for pending)

#### 6a. Fee Overview Screen
Tabs:
- **Payments**: paginated list of all payments — student name, amount, date, mode, status badge
- **Pending**: filter status=PENDING — student name, due amount, due date, "Remind" button
- **Structures**: list of FeeStructure templates — name, amount, frequency, batch (if any)

#### 6b. Record Payment Bottom Sheet
Fields:
- Student picker (search by name from enrolled students)
- amountPaise (₹ input)
- paymentMode (CASH / UPI / CARD / BANK_TRANSFER / CHEQUE)
- notes (optional)
- paidAt (date picker, default today)

**API**: `POST /academy/:id/fee-payments`

#### 6c. Create Fee Structure Sheet
Fields:
- name
- amountPaise (₹)
- frequency (MONTHLY / QUARTERLY / ANNUAL / ONE_TIME)
- batchId (optional — pick from batch list)
- dueDayOfMonth (1–28, optional)

**API**: `POST /academy/:id/fee-structures`

---

### 7. Announcements

**Route**: `/announcements`
**API**: `POST /academy/:id/announcements`

#### 7a. Announcement List
- List of past announcements: title, date, isPinned indicator
- FAB → Create Announcement

#### 7b. Create Announcement Screen
Fields:
- title (required)
- body (multiline, required)
- targetGroup (default ALL)
- isPinned toggle
- sentVia multi-select (PUSH / SMS / EMAIL)

**API**: `POST /academy/:id/announcements`

---

### 8. Inventory

**Route**: `/inventory`
**APIs**:
- `GET /academy/:id/inventory`
- `POST /academy/:id/inventory`

#### 8a. Inventory List
- Flat list: name, category, quantity, condition badge (GOOD=green, FAIR=amber, POOR/DAMAGED=red)
- Filter by category
- FAB → Add Item

#### 8b. Add Inventory Item Sheet
Fields:
- name (required)
- category (text or enum if defined)
- quantity (number)
- condition (GOOD / FAIR / POOR / DAMAGED)
- purchasedAt (date picker)
- cost (₹)
- notes

**API**: `POST /academy/:id/inventory`

---

### 9. Academy Profile & Settings

**Route**: `/settings`
**APIs**:
- `GET /academy/my` — load current academy
- `PUT /academy/:id` — update academy

#### 9a. Academy Profile Screen
- Editable fields: name, description, tagline, phone, email, websiteUrl, foundedYear
- Address section: address, city, state, pincode
- Logo upload (if storage integrated)
- planTier display (read-only badge with upgrade CTA)
- Save button → `PUT /academy/:id`

#### 9b. App Settings
- Account info (from `/biz/me`)
- Logout → revoke token via `/auth/logout`, clear local state, navigate to login

---

## Navigation Map

```
Login (done) → Biz Registration (done) → Academy Creation (done)
  ↓
Home Dashboard
  ├── Batch List → Batch Detail (Info / Schedule / Students / Coaches)
  ├── Student List → Enroll Flow → Student Detail
  ├── Session List → Session Detail
  ├── Attendance Report
  └── More
       ├── Coaches → Coach Detail
       ├── Fees → Record Payment / Create Structure
       ├── Announcements → Create
       ├── Inventory → Add Item
       └── Settings → Academy Profile / Logout
```

---

## Data Notes

- All timestamps from API are ISO 8601 UTC. Display in local time using `intl` package.
- Paise → Rupees: `(paise / 100).toStringAsFixed(2)` and prefix with `₹`.
- `dayOfWeek` integer: 0=Sunday, 1=Monday … 6=Saturday. Map to short labels.
- Pagination: default `limit=20`, use `page` param. Implement infinite scroll.
- On 401: refresh token, retry once, then logout.

---

## Error Handling

- API errors return `{statusCode, message}`. Show a snackbar with `message`.
- Network errors: show a retry option in-place (not a full-screen error for list items).
- Form validation: validate before API call; show inline field errors.
