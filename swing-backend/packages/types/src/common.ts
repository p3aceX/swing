export interface ApiResponse<T = unknown> {
  success: boolean
  data?: T
  error?: ApiError
  meta?: PaginationMeta
}

export interface ApiError {
  code: string
  message: string
  details?: Record<string, unknown>
}

export interface PaginationMeta {
  page: number
  limit: number
  total: number
  totalPages: number
}

export interface PaginationQuery {
  page?: number
  limit?: number
}

export const IP_VALUES = {
  MATCH_WIN_RANKED: 100,
  MATCH_WIN_FRIENDLY: 50,
  MATCH_LOSS: 25,
  SESSION_PRESENT: 50,
  SESSION_LATE: 25,
  DRILL_COMPLETED: 25,
  FIFTY_RUNS: 30,
  CENTURY: 75,
  THREE_WICKET_HAUL: 30,
  FIVE_WICKET_HAUL: 75,
  REPORT_CARD_IMPROVEMENT: 10,
  NO_SHOW_PENALTY: -50,
} as const

export const XP_VALUES = IP_VALUES

export const RANK_THRESHOLDS = {
  GULLY: 0,
  CLUB_RANK: 1000,
  DISTRICT: 2500,
  STATE: 5000,
  NATIONAL: 10000,
  LEGEND: 20000,
} as const

