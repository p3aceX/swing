export function getRankAdjacentTiers(rank: string): string[] {
  const ranks = ['GULLY', 'CLUB_RANK', 'DISTRICT', 'STATE', 'NATIONAL', 'LEGEND']
  const idx = ranks.indexOf(rank)
  if (idx === -1) return [rank]
  const adjacent: string[] = [rank]
  if (idx > 0) adjacent.push(ranks[idx - 1])
  if (idx < ranks.length - 1) adjacent.push(ranks[idx + 1])
  return adjacent
}
