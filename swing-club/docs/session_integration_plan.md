# Session Integration Plan (Phase 1)

## Goal
Make Sessions a first-class, fully connected ERP module with complete route wiring, navigation entry points, and operational workflows (list, detail, report, attendance quality).

## Scope for This Phase
- Route integration
- Navigation integration
- Screen/Provider correctness
- ERP readiness baseline for sessions

## Implementation Plan

1. Wire missing routes in `lib/router.dart`
- Add:
  - `GoRoute(path: '/sessions', builder: ...)`
  - `GoRoute(path: '/sessions/:sessionId', builder: ...)`
  - `GoRoute(path: '/sessions/report', builder: ...)`
- Import:
  - `session_list_screen.dart`
  - `session_detail_screen.dart`
  - `attendance_report_screen.dart`

2. Add navigation entry points to Sessions
- Home: add a visible quick action/card to open `/sessions`
- Batch detail: add CTA to view filtered sessions for that batch (via query param or extra)
- Optional (if preferred): replace dead `MoreScreen` entry with Sessions

3. Align route usage and argument flow
- Ensure all current `context.push('/sessions/...')` match registered route patterns
- Add optional filter transport for batch/date range

4. Harden Session list behavior
- Validate empty/error states and refresh path
- Keep date-range and batch filtering stable after pull-to-refresh
- Add explicit create-session entry placeholder if backend create endpoint is not ready

5. Harden Session detail behavior
- Confirm `LIVE` polling is safe and cancellable
- Handle absent attendance gracefully
- Add status transitions UX placeholders if mutation APIs are unavailable

6. Harden Attendance report behavior
- Validate summary math and null safety
- Add export placeholder action (CSV/PDF) behind disabled or feature-flagged UI if API missing

7. ERP baseline checks for Sessions module
- Attendance exception indicators (low attendance threshold)
- Batch-level attendance trend hook points
- Coach-wise attendance drilldown hook points

8. Testing and QA
- Add widget tests for route resolution:
  - `/sessions`
  - `/sessions/:id`
  - `/sessions/report`
- Smoke test auth redirect behavior does not block authenticated session navigation
- Run `dart analyze lib` and fix session-related issues

## Deliverables
- Connected routes and working navigation for all sessions screens
- No dead route references for sessions
- Stable list/detail/report flows with refresh and filter behavior
- Documented API gaps as TODOs with exact endpoint contracts

## Out of Scope (Next Phase)
- Session creation/edit/cancel APIs and UI
- Attendance marking mutations
- Auto-scheduling engine
- Advanced analytics/export backend

## Execution Order
1. Router wiring
2. Navigation entry points
3. Session list/detail/report hardening
4. Tests + analyzer cleanup
5. Demo checklist
