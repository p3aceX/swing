import { z } from "zod";

export const MATCH_TYPES = [
  "ACADEMY",
  "TOURNAMENT",
  "CORPORATE",
  "RANKED",
  "FRIENDLY",
] as const;

export const MATCH_FORMATS = [
  "T10",
  "T20",
  "ONE_DAY",
  "TWO_INNINGS",
  "TEST",
  "BOX_CRICKET",
  "CUSTOM",
] as const;

export const MATCH_STATUSES = [
  "SCHEDULED",
  "TOSS_DONE",
  "IN_PROGRESS",
  "COMPLETED",
  "ABANDONED",
] as const;

export const BALL_TYPES = [
  "LEATHER",
  "TENNIS",
  "RUBBER",
  "TAPE",
  "CORK",
  "OTHER",
] as const;

export const TOSS_SIDES = ["A", "B"] as const;
export const TOSS_DECISIONS = ["BAT", "BOWL"] as const;

export const BALL_OUTCOMES = [
  "DOT",
  "SINGLE",
  "DOUBLE",
  "TRIPLE",
  "FOUR",
  "FIVE",
  "SIX",
  "WIDE",
  "NO_BALL",
  "WICKET",
  "BYE",
  "LEG_BYE",
] as const;

export const DISMISSAL_TYPES = [
  "BOWLED",
  "CAUGHT",
  "LBW",
  "RUN_OUT",
  "STUMPED",
  "HIT_WICKET",
  "RETIRED_HURT",
  "RETIRED_OUT",
  "OBSTRUCTING_FIELD",
  "NOT_OUT",
] as const;

export const TOURNAMENT_FORMATS = [
  "LEAGUE",
  "KNOCKOUT",
  "GROUP_STAGE_KNOCKOUT",
  "DOUBLE_ELIMINATION",
  "SUPER_LEAGUE",
  "SERIES",
] as const;

export const HOST_TOURNAMENT_MATCH_FORMATS = [
  "T10",
  "T20",
  "ONE_DAY",
  "TEST",
  "HUNDRED",
  "CUSTOM",
] as const;

export const EVENT_TYPES = [
  "SIXER_KING",
  "FASTEST_50",
  "HIGHEST_SCORE",
  "BEST_BOWLING",
  "RELAY_CRICKET",
  "CUSTOM",
] as const;

export const EVENT_STATUSES = [
  "UPCOMING",
  "LIVE",
  "COMPLETED",
  "CANCELLED",
] as const;

export const createMatchRequestSchema = z.object({
  matchType: z.enum(MATCH_TYPES),
  format: z.enum(MATCH_FORMATS),
  teamAName: z.string().min(1),
  teamBName: z.string().min(1),
  teamAPlayerIds: z.array(z.string()).default([]),
  teamBPlayerIds: z.array(z.string()).default([]),
  teamACaptainId: z.string().optional(),
  teamBCaptainId: z.string().optional(),
  teamAViceCaptainId: z.string().optional(),
  teamBViceCaptainId: z.string().optional(),
  teamAWicketKeeperId: z.string().optional(),
  teamBWicketKeeperId: z.string().optional(),
  hasImpactPlayer: z.boolean().optional(),
  ballType: z.enum(BALL_TYPES).optional(),
  scheduledAt: z.string(),
  venueName: z.string().optional(),
  facilityId: z.string().optional(),
  academyId: z.string().optional(),
  tournamentId: z.string().optional(),
});

export const adminCreateMatchRequestSchema = z.object({
  matchType: z.enum(MATCH_TYPES),
  format: z.enum(MATCH_FORMATS),
  teamAName: z.string().min(1),
  teamBName: z.string().min(1),
  teamAPlayerIds: z.array(z.string()).optional(),
  teamBPlayerIds: z.array(z.string()).optional(),
  teamACaptainId: z.string().optional(),
  teamBCaptainId: z.string().optional(),
  scheduledAt: z.string(),
  venueName: z.string().optional(),
  venueCity: z.string().optional(),
  customOvers: z.number().int().min(1).max(100).optional(),
  testDays: z.number().int().min(1).max(10).optional(),
  oversPerDay: z.number().int().min(1).max(200).optional(),
  academyId: z.string().optional(),
  tournamentId: z.string().optional(),
  overlayPackId: z.string().optional(),
  round: z.string().optional(),
  hasImpactPlayer: z.boolean().optional(),
});

export const tossRequestSchema = z.object({
  tossWonBy: z.enum(TOSS_SIDES),
  tossDecision: z.enum(TOSS_DECISIONS),
});

export const recordBallRequestSchema = z.object({
  overNumber: z.number().min(0),
  ballNumber: z.number().min(1),
  batterId: z.string(),
  nonBatterId: z.string().optional(),
  bowlerId: z.string(),
  fielderId: z.string().optional(),
  outcome: z.enum(BALL_OUTCOMES),
  runs: z.number().min(0).default(0),
  extras: z.number().min(0).default(0),
  isWicket: z.boolean().default(false),
  dismissalType: z.enum(DISMISSAL_TYPES).optional(),
  dismissedPlayerId: z.string().optional(),
  switchEnds: z.boolean().optional(),
  wagonZone: z.string().optional(),
  tags: z.array(z.string()).default([]),
  isOfflineEntry: z.boolean().default(false),
});

export const updateBallRequestSchema = z.object({
  outcome: z.enum(BALL_OUTCOMES).optional(),
  runs: z.number().min(0).optional(),
  extras: z.number().min(0).optional(),
  isWicket: z.boolean().optional(),
  dismissalType: z.enum(DISMISSAL_TYPES).nullable().optional(),
  dismissedPlayerId: z.string().nullable().optional(),
  fielderId: z.string().nullable().optional(),
  wagonZone: z.string().nullable().optional(),
});

export const completeMatchRequestSchema = z.object({
  winnerId: z.enum(["A", "B", "DRAW", "TIE", "ABANDONED"]),
  winMargin: z.string().optional(),
});

export const inningsStateRequestSchema = z.object({
  strikerId: z.string().nullable().optional(),
  nonStrikerId: z.string().nullable().optional(),
  bowlerId: z.string().nullable().optional(),
});

export const createTournamentRequestSchema = z.object({
  name: z.string().min(2).max(120),
  description: z.string().max(500).optional(),
  format: z.enum(MATCH_FORMATS),
  tournamentFormat: z.enum(TOURNAMENT_FORMATS).optional(),
  sport: z.string().optional(),
  startDate: z.string(),
  endDate: z.string().optional(),
  venueName: z.string().max(120).optional(),
  city: z.string().max(60).optional(),
  maxTeams: z.number().int().min(2).max(128).optional(),
  seriesMatchCount: z.number().int().min(1).max(15).optional(),
  groupCount: z.number().int().min(1).max(16).optional(),
  pointsForWin: z.number().int().min(0).optional(),
  pointsForLoss: z.number().int().min(0).optional(),
  pointsForTie: z.number().int().min(0).optional(),
  pointsForNoResult: z.number().int().min(0).optional(),
  entryFee: z.number().int().min(0).optional(),
  prizePool: z.string().max(120).optional(),
  rules: z.string().max(2000).optional(),
  isPublic: z.boolean().optional(),
  academyId: z.string().optional(),
  overlayPackId: z.string().optional(),
  logoUrl: z.string().url().optional(),
  coverUrl: z.string().url().optional(),
  slug: z.string().min(2).max(80).optional(),
});

export const createHostedTournamentRequestSchema = z.object({
  name: z.string().min(1).max(120),
  format: z.enum(HOST_TOURNAMENT_MATCH_FORMATS),
  tournamentFormat: z.enum(TOURNAMENT_FORMATS).optional(),
  startDate: z.string(),
  endDate: z.string().optional(),
  city: z.string().max(60).optional(),
  venueName: z.string().max(120).optional(),
  maxTeams: z.number().int().min(2).max(128).optional(),
  entryFee: z.number().int().min(0).optional(),
  prizePool: z.string().max(120).optional(),
  description: z.string().max(500).optional(),
  isPublic: z.boolean().optional(),
});

export const createEventRequestSchema = z.object({
  name: z.string().min(1).max(120),
  eventType: z.enum(EVENT_TYPES).optional(),
  description: z.string().max(1000).optional(),
  venueName: z.string().max(120).optional(),
  city: z.string().max(60).optional(),
  scheduledAt: z.string().optional(),
  isPublic: z.boolean().optional(),
  maxParticipants: z.number().int().min(2).max(512).optional(),
  rules: z.string().max(2000).optional(),
  prizePool: z.string().max(120).optional(),
});

export const updateEventRequestSchema = z.object({
  name: z.string().min(1).max(120).optional(),
  eventType: z.enum(EVENT_TYPES).optional(),
  description: z.string().max(1000).nullable().optional(),
  venueName: z.string().max(120).nullable().optional(),
  city: z.string().max(60).nullable().optional(),
  scheduledAt: z.string().nullable().optional(),
  isPublic: z.boolean().optional(),
  maxParticipants: z.number().int().min(2).max(512).nullable().optional(),
  rules: z.string().max(2000).nullable().optional(),
  prizePool: z.string().max(120).nullable().optional(),
  status: z.enum(EVENT_STATUSES).optional(),
});

export type MatchType = (typeof MATCH_TYPES)[number];
export type MatchFormat = (typeof MATCH_FORMATS)[number];
export type MatchStatus = (typeof MATCH_STATUSES)[number];
export type BallType = (typeof BALL_TYPES)[number];
export type TossSide = (typeof TOSS_SIDES)[number];
export type TossDecision = (typeof TOSS_DECISIONS)[number];
export type BallOutcome = (typeof BALL_OUTCOMES)[number];
export type DismissalType = (typeof DISMISSAL_TYPES)[number];
export type TournamentFormat = (typeof TOURNAMENT_FORMATS)[number];
export type EventType = (typeof EVENT_TYPES)[number];
export type EventStatus = (typeof EVENT_STATUSES)[number];

export type CreateMatchRequest = z.infer<typeof createMatchRequestSchema>;
export type AdminCreateMatchRequest = z.infer<
  typeof adminCreateMatchRequestSchema
>;
export type TossRequest = z.infer<typeof tossRequestSchema>;
export type RecordBallRequest = z.infer<typeof recordBallRequestSchema>;
export type UpdateBallRequest = z.infer<typeof updateBallRequestSchema>;
export type CompleteMatchRequest = z.infer<typeof completeMatchRequestSchema>;
export type InningsStateRequest = z.infer<typeof inningsStateRequestSchema>;
export type CreateTournamentRequest = z.infer<
  typeof createTournamentRequestSchema
>;
export type CreateHostedTournamentRequest = z.infer<
  typeof createHostedTournamentRequestSchema
>;
export type CreateEventRequest = z.infer<typeof createEventRequestSchema>;
export type UpdateEventRequest = z.infer<typeof updateEventRequestSchema>;
