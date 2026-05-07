// Canonical time-window definitions used across matchmaking.
// Player-side abstraction — arena slots stay raw (any HH:MM start), and
// helpers in this file derive a bucket from a slot's start time.
//
// Buckets are half-open ranges [startMin, endMin) measured in minutes from
// the start of the lobby's date (allowing values up to 28*60 = 1680 for
// late-night slots that bleed past midnight).

import type { MatchmakingFormat } from './matchmaking.service'

export type TimeWindow =
  | 'MORNING'
  | 'AFTERNOON'
  | 'EVENING'
  | 'NIGHT'
  | 'LATE_NIGHT'

export const TIME_WINDOWS: TimeWindow[] = [
  'MORNING',
  'AFTERNOON',
  'EVENING',
  'NIGHT',
  'LATE_NIGHT',
]

// minutes-from-midnight ranges, half-open [start, end). LATE_NIGHT extends
// past midnight into the next day; we still represent it as 23:30 → 28:00
// so a single comparison works for matches that begin late on the same date.
export const WINDOW_RANGES: Record<TimeWindow, { startMin: number; endMin: number }> = {
  MORNING:    { startMin:  6 * 60 + 30, endMin: 11 * 60 + 30 },
  AFTERNOON:  { startMin: 11 * 60 + 30, endMin: 16 * 60 + 30 },
  EVENING:    { startMin: 16 * 60 + 30, endMin: 20 * 60 + 30 },
  NIGHT:      { startMin: 20 * 60 + 30, endMin: 23 * 60 + 30 },
  LATE_NIGHT: { startMin: 23 * 60 + 30, endMin: 28 * 60 +  0 },
}

// Match formats → duration in minutes. Source of truth lives in
// matchmaking.service formatDurationMins; mirrored here to avoid a circular
// import. Keep them in sync.
export function formatDurationMins(format: MatchmakingFormat | string): number {
  switch (format) {
    case 'ODI':
    case 'Test':
      return 480
    default:
      return 240
  }
}

// Parse "HH:MM" → minutes from midnight. Returns null on malformed input.
export function slotTimeToMin(slotTime: string): number | null {
  const m = /^(\d{1,2}):(\d{2})$/.exec(slotTime)
  if (!m) return null
  const h = parseInt(m[1], 10)
  const mm = parseInt(m[2], 10)
  if (isNaN(h) || isNaN(mm) || h < 0 || h > 28 || mm < 0 || mm > 59) return null
  return h * 60 + mm
}

// Which bucket does a slot start at? Slots ending past their bucket's end are
// still tagged by their START — that's how players will search.
export function bucketForSlotTime(slotTime: string): TimeWindow | null {
  const min = slotTimeToMin(slotTime)
  if (min === null) return null
  for (const w of TIME_WINDOWS) {
    const r = WINDOW_RANGES[w]
    if (min >= r.startMin && min < r.endMin) return w
  }
  return null
}

// Half-open interval overlap: [aStart, aEnd) ∩ [bStart, bEnd) ≠ ∅
//   ⇔ aStart < bEnd  AND  bStart < aEnd
// Back-to-back ranges (one ends exactly when the next starts) do NOT
// overlap.
export function intervalsOverlap(
  aStart: number, aEnd: number,
  bStart: number, bEnd: number,
): boolean {
  return aStart < bEnd && bStart < aEnd
}

// Given a list of windows the player picked (empty = any time), return a
// single merged interval that covers all of them. Used for slot-conflict
// checks on a search request.
//
// "Any time" is a permissive whole-day band (06:30 → next-day 04:00) that
// will overlap any real match interval on the requested date.
export function unionWindowRange(windows: TimeWindow[]): { startMin: number; endMin: number } {
  if (windows.length === 0) {
    return { startMin: WINDOW_RANGES.MORNING.startMin, endMin: WINDOW_RANGES.LATE_NIGHT.endMin }
  }
  let start = Number.POSITIVE_INFINITY
  let end = Number.NEGATIVE_INFINITY
  for (const w of windows) {
    const r = WINDOW_RANGES[w]
    if (r.startMin < start) start = r.startMin
    if (r.endMin > end) end = r.endMin
  }
  return { startMin: start, endMin: end }
}

// Compute a match's [startMin, endMin) interval from its persisted slotTime
// + format. Returns null if slotTime can't be parsed.
export function matchInterval(
  slotTime: string,
  format: MatchmakingFormat | string,
): { startMin: number; endMin: number } | null {
  const start = slotTimeToMin(slotTime)
  if (start === null) return null
  return { startMin: start, endMin: start + formatDurationMins(format) }
}

// Pretty-print "HH:MM" minute count back to "10:00 AM" / "1:30 PM" for
// surfacing in error messages and UI hints.
export function formatMin(min: number): string {
  const h24 = Math.floor((min % (24 * 60)) / 60)
  const mm = min % 60
  const ampm = h24 < 12 ? 'AM' : 'PM'
  const h = h24 === 0 ? 12 : h24 > 12 ? h24 - 12 : h24
  return `${h}:${String(mm).padStart(2, '0')} ${ampm}`
}

export function formatRange(startMin: number, endMin: number): string {
  return `${formatMin(startMin)} – ${formatMin(endMin)}`
}
