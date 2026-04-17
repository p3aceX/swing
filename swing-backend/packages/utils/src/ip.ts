import { RANK_THRESHOLDS } from '@swing/types'

export type SwingRankKey = keyof typeof RANK_THRESHOLDS

export function getRankFromIp(totalIp: number): SwingRankKey {
  if (totalIp >= RANK_THRESHOLDS.LEGEND) return 'LEGEND'
  if (totalIp >= RANK_THRESHOLDS.NATIONAL) return 'NATIONAL'
  if (totalIp >= RANK_THRESHOLDS.STATE) return 'STATE'
  if (totalIp >= RANK_THRESHOLDS.DISTRICT) return 'DISTRICT'
  if (totalIp >= RANK_THRESHOLDS.CLUB_RANK) return 'CLUB_RANK'
  return 'GULLY'
}

export const getRankFromXp = getRankFromIp
