import { prisma, PlayerRole, PlayerIndexSnapshot } from '@swing/db'
import { Errors } from '../../lib/errors'
import { EliteAnalyticsService } from './elite-analytics.service'
import { DevelopmentService } from '../development/development.service'
import { GigService } from '../gigs/gig.service'

const ROLE_WEIGHTS: Record<string, Record<string, number>> = {
  BATSMAN: {
    reliability: 0.35,
    power: 0.35,
    impact: 0.15,
    fielding: 0.15
  },
  BOWLER: {
    bowling: 0.50,
    power: 0.10,
    impact: 0.25,
    fielding: 0.15
  },
  ALL_ROUNDER: {
    reliability: 0.20,
    power: 0.20,
    bowling: 0.30,
    fielding: 0.15,
    impact: 0.15
  },
  WICKET_KEEPER: {
    reliability: 0.25,
    power: 0.20,
    impact: 0.25,
    fielding: 0.30
  },
  WICKET_KEEPER_BATSMAN: {
    reliability: 0.25,
    power: 0.25,
    impact: 0.25,
    fielding: 0.25
  }
}

type PlayerAxisAggregate = {
  playerId: string
  reliabilityIndex: number | null
  powerIndex: number | null
  bowlingIndex: number | null
  fieldingIndex: number | null
  impactIndex: number | null
  captaincyIndex: number | null
}

type AxisField = Exclude<keyof PlayerAxisAggregate, 'playerId'>

const AXIS_FIELD_MAP: Record<string, AxisField> = {
  reliability: 'reliabilityIndex',
  power: 'powerIndex',
  bowling: 'bowlingIndex',
  fielding: 'fieldingIndex',
  impact: 'impactIndex',
  captaincy: 'captaincyIndex'
}

const WEAKNESS_MAP: Record<string, {
  insight: string
  drillCategories: string[]
  skillAreas: string[]
  coachSpecializations: string[]
}> = {
  batting: {
    insight: "Your batting index is the biggest drag on your role score.",
    drillCategories: ['TECHNIQUE'],
    skillAreas: ['BATTING'],
    coachSpecializations: ['BATTING', 'TECHNIQUE']
  },
  bowling: {
    insight: "Your bowling needs more match impact.",
    drillCategories: ['TECHNIQUE'],
    skillAreas: ['BOWLING'],
    coachSpecializations: ['BOWLING', 'TECHNIQUE']
  },
  consistency: {
    insight: "High variance between performances is holding you back.",
    drillCategories: ['MENTAL', 'MATCH_SIMULATION'],
    skillAreas: [],
    coachSpecializations: ['MENTAL', 'BATTING', 'BOWLING']
  },
  clutch: {
    insight: "Your performance dips in pressure situations.",
    drillCategories: ['MENTAL', 'MATCH_SIMULATION'],
    skillAreas: [],
    coachSpecializations: ['MENTAL', 'PERFORMANCE']
  },
  fielding: {
    insight: "Fielding is an untapped area that could lift your index.",
    drillCategories: ['TECHNIQUE'],
    skillAreas: ['FIELDING'],
    coachSpecializations: ['FIELDING']
  },
  physical: {
    insight: "Recovery and workload management are limiting your ceiling.",
    drillCategories: ['FITNESS'],
    skillAreas: [],
    coachSpecializations: ['FITNESS', 'STRENGTH_CONDITIONING']
  }
}

export interface StandingLevel {
  value: number
  label: string
  comparedTo: number
  scope: 'CITY' | 'STATE' | 'COUNTRY'
}

export interface GrowthInsightsResult {
  isPro: boolean
  locked?: boolean
  insufficient?: boolean
  archetype: { label: string; description: string } | null
  growthVelocity: {
    trend: 'RAPIDLY_IMPROVING' | 'IMPROVING' | 'STABLE' | 'DECLINING' | 'SLIPPING' | 'INSUFFICIENT_DATA'
    deltaPercent: number
    windowMatches: number
  }
  momentum: number | null
  roleIndex: number | null
  percentile: StandingLevel | null // Legacy support
  standings: StandingLevel[] // New multi-level support
  weakness: {
    axis: string
    insight: string
    drillRecommendations: any[]
  } | null
  coachSuggestions: any[] | null
  readiness: {
    score: number
    signals: { label: string; positive: boolean }[]
  } | null
  upgradeMessage?: string
}

export class GrowthInsightsService {
  constructor(
    private eliteAnalytics: EliteAnalyticsService,
    private developmentSvc: DevelopmentService,
    private gigSvc: GigService
  ) {}

  async getInsights(userId: string): Promise<GrowthInsightsResult> {
    const profile = await prisma.playerProfile.findUnique({
      where: { userId },
      select: { 
        userId: true,
        id: true, 
        playerRole: true, 
        city: true, 
        state: true,
        locationRadius: true
      }
    })
    if (!profile) throw Errors.notFound('Player profile')

    const snapshots = await prisma.playerIndexSnapshot.findMany({
      where: { playerId: profile.id, snapshotType: 'MATCH' },
      orderBy: { snapshotDate: 'asc' }
    })

    const aggregate = await this.getCurrentAggregate(profile.id)
    const wellness = await this.eliteAnalytics.getWellnessAndPhysicality(profile.id)

    // APEX Pack Logic
    const activeSubscription = await prisma.subscription.findFirst({
      where: {
        userId: profile.userId,
        status: 'ACTIVE',
        expiresAt: { gte: new Date() },
      },
      select: {
        entityType: true,
      },
      orderBy: { createdAt: 'desc' },
    })
    const isPro = Boolean(
      activeSubscription &&
      (() => {
        const entityType = activeSubscription.entityType.toUpperCase()
        return entityType.includes('PASS') || entityType.includes('PLAYER')
      })(),
    )

    if (!aggregate || snapshots.length === 0) {
      return {
        isPro: !!isPro,
        insufficient: true,
        archetype: null,
        growthVelocity: { trend: 'INSUFFICIENT_DATA', deltaPercent: 0, windowMatches: snapshots.length },
        momentum: null, roleIndex: null, percentile: null, standings: [],
        weakness: null, coachSuggestions: [], readiness: null
      }
    }

    const role = profile.playerRole as string
    const roleIndex = this.computeRoleIndex(aggregate, role)
    
    const archetype = this.computeArchetype(aggregate)
    const growthVelocity = this.computeGrowthVelocity(snapshots, role)

    if (!isPro) {
      return {
        isPro: false,
        locked: true,
        archetype,
        growthVelocity: {
          trend: growthVelocity.trend,
          deltaPercent: 0,
          windowMatches: snapshots.length
        },
        momentum: null,
        roleIndex: null,
        percentile: null,
        standings: [],
        weakness: null,
        coachSuggestions: null,
        readiness: null,
        upgradeMessage: "Unlock your full growth profile with APEX"
      }
    }

    // Pro-only data
    const momentum = this.computeMomentum(snapshots, role)
    const standings = await this.computeMultiLevelStandings(profile.id, aggregate, role, profile.city, profile.state)
    const weaknessData = this.detectWeakness(aggregate, role)
    
    let drillRecommendations: any[] = []
    let coachSuggestions: any[] = []

    if (weaknessData) {
      drillRecommendations = await this.getDrillRecommendations(profile.playerRole as PlayerRole, weaknessData.axis)
      coachSuggestions = await this.getCoachSuggestions(profile.city, weaknessData.axis)
    }

    const readiness = await this.computeReadiness(profile.id, wellness, momentum)

    return {
      isPro: true,
      archetype,
      growthVelocity,
      momentum,
      roleIndex,
      percentile: standings[0] || null,
      standings,
      weakness: weaknessData ? {
        axis: weaknessData.axis,
        insight: weaknessData.insight,
        drillRecommendations
      } : null,
      coachSuggestions,
      readiness
    }
  }

  async getNearbyCoaches(userId: string, weaknessAxis?: string): Promise<any[]> {
    const profile = await prisma.playerProfile.findUnique({
      where: { userId },
      select: { id: true, playerRole: true, city: true }
    })
    if (!profile) throw Errors.notFound('Player profile')

    let axis = weaknessAxis
    if (!axis) {
      const aggregate = await this.getCurrentAggregate(profile.id)
      if (aggregate) {
        const weakness = this.detectWeakness(aggregate, profile.playerRole as string)
        axis = weakness?.axis
      }
    }

    return this.getCoachSuggestions(profile.city, axis, 10)
  }

  private computeRoleIndex(data: PlayerAxisAggregate | PlayerIndexSnapshot, role: string): number {
    const weights = ROLE_WEIGHTS[role]
    if (!weights) return 0

    let totalWeight = 0
    let sum = 0

    for (const [axis, weight] of Object.entries(weights)) {
      const field = AXIS_FIELD_MAP[axis]
      const val = data[field]
      if (val !== null && val !== undefined) {
        sum += val * weight
        totalWeight += weight
      }
    }

    if (totalWeight === 0) return 0
    return Math.round((sum / totalWeight) * 10) / 10
  }

  private computeMomentum(snapshots: PlayerIndexSnapshot[], role: string): number {
    const last4 = snapshots.slice(-4).reverse()
    const MOMENTUM_WEIGHTS = [0.40, 0.30, 0.20, 0.10]
    
    let totalWeight = 0
    let sum = 0

    for (let i = 0; i < last4.length; i++) {
      const weight = MOMENTUM_WEIGHTS[i]
      const rIndex = this.computeRoleIndex(last4[i], role)
      sum += rIndex * (weight || 0)
      totalWeight += (weight || 0)
    }

    if (totalWeight === 0) return 0
    return Math.round((sum / totalWeight) * 10) / 10
  }

  private computeGrowthVelocity(snapshots: PlayerIndexSnapshot[], role: string) {
    const matchSnaps = [...snapshots].reverse()
    const recent = matchSnaps.slice(0, 3)
    const previous = matchSnaps.slice(3, 6)

    if (recent.length < 2) {
      return { trend: 'INSUFFICIENT_DATA' as const, deltaPercent: 0, windowMatches: snapshots.length }
    }

    const avgRecent = recent.reduce((sum, s) => sum + this.computeRoleIndex(s, role), 0) / recent.length
    
    if (previous.length === 0) {
      const isImproving = recent.length >= 2 && this.computeRoleIndex(recent[0], role) > this.computeRoleIndex(recent[recent.length - 1], role)
      return {
        trend: isImproving ? 'IMPROVING' as const : 'STABLE' as const,
        deltaPercent: 0,
        windowMatches: snapshots.length
      }
    }

    const avgPrevious = previous.reduce((sum, s) => sum + this.computeRoleIndex(s, role), 0) / previous.length
    const deltaPercent = Math.round(((avgRecent - avgPrevious) / avgPrevious) * 100 * 10) / 10

    let trend: 'RAPIDLY_IMPROVING' | 'IMPROVING' | 'STABLE' | 'DECLINING' | 'SLIPPING'
    if (deltaPercent >= 30) trend = 'RAPIDLY_IMPROVING'
    else if (deltaPercent >= 10) trend = 'IMPROVING'
    else if (deltaPercent >= -10) trend = 'STABLE'
    else if (deltaPercent >= -30) trend = 'DECLINING'
    else trend = 'SLIPPING'

    return { trend, deltaPercent, windowMatches: snapshots.length }
  }

  private computeArchetype(aggregate: PlayerAxisAggregate) {
    const r = aggregate.reliabilityIndex ?? 0
    const bo = aggregate.bowlingIndex ?? 0
    const f = aggregate.fieldingIndex ?? 0
    const i = aggregate.impactIndex ?? 0
    const po = aggregate.powerIndex ?? 0

    if (r >= 70 && i >= 60) return { label: "Assassin", description: "Peak form, peak pressure. You score when it counts most." }
    if (r >= 70 && po >= 50) return { label: "Anchor", description: "Reliability is your superpower. You build innings." }
    if (bo >= 70 && i >= 50) return { label: "Pressure Bowler", description: "You hunt wickets when the game is on the line." }
    if (bo >= 70) return { label: "Enforcer", description: "Discipline and aggression. You control the game with the ball." }
    if (r >= 50 && bo >= 50) return { label: "War Machine", description: "You hurt teams with bat and ball. A true all-rounder." }
    if (i >= 60 && r >= 50) return { label: "Clutch Performer", description: "You show up when it matters most." }
    if (bo >= 60 && f >= 50) return { label: "Technical Specialist", description: "Precision in both disciplines. Highly reliable." }
    if (f >= 60) return { label: "Guardian", description: "Safe hands, sharp eyes. You win matches in the field." }
    if (i >= 50 && po >= 40) return { label: "Steady Hand", description: "Consistent and calm. Teams trust you." }
    
    return { label: "Rising Star", description: "Your best cricket is ahead of you." }
  }

  private async computeMultiLevelStandings(
    playerId: string, 
    aggregate: PlayerAxisAggregate, 
    role: string, 
    city: string | null,
    state: string | null
  ): Promise<StandingLevel[]> {
    const scopes: Array<'CITY' | 'STATE' | 'COUNTRY'> = ['CITY', 'STATE', 'COUNTRY']
    const results: StandingLevel[] = []

    for (const scope of scopes) {
      const where: any = { playerRole: role as any }
      if (scope === 'CITY' && city) where.city = city
      else if (scope === 'STATE' && state) where.state = state

      const peerProfiles = await prisma.playerProfile.findMany({
        where,
        select: { id: true },
      })
      const peerIds = peerProfiles.map((item) => item.id)
      const peers = await this.getCurrentAggregates(peerIds)

      if (peers.length >= (scope === 'COUNTRY' ? 1 : 3)) {
        const myRoleIndex = this.computeRoleIndex(aggregate, role)
        const lowerCount = peers.filter(p => this.computeRoleIndex(p, role) < myRoleIndex).length
        const percentile = Math.round((lowerCount / peers.length) * 100)
        
        const scopeLabel = scope === 'CITY' ? (city || 'City') : scope === 'STATE' ? (state || 'State') : 'India'
        
        results.push({
          value: percentile,
          label: `Top ${100 - percentile}% in ${scopeLabel}`,
          comparedTo: peers.length,
          scope
        })
      }
    }

    return results
  }

  private snapshotToAggregate(snapshot: PlayerIndexSnapshot): PlayerAxisAggregate {
    return {
      playerId: snapshot.playerId,
      reliabilityIndex: snapshot.reliabilityIndex,
      powerIndex: snapshot.powerIndex,
      bowlingIndex: snapshot.bowlingIndex,
      fieldingIndex: snapshot.fieldingIndex,
      impactIndex: snapshot.impactIndex,
      captaincyIndex: snapshot.captaincyIndex,
    }
  }

  private pickPreferredSnapshot(snapshots: PlayerIndexSnapshot[]): PlayerIndexSnapshot | null {
    const priorities: Array<PlayerIndexSnapshot['snapshotType']> = ['LAST_10', 'LIFETIME', 'MATCH']
    for (const snapshotType of priorities) {
      const selected = snapshots.find((snapshot) => snapshot.snapshotType === snapshotType)
      if (selected) return selected
    }
    return null
  }

  private async getCurrentAggregate(playerId: string): Promise<PlayerAxisAggregate | null> {
    const snapshots = await prisma.playerIndexSnapshot.findMany({
      where: {
        playerId,
        snapshotType: { in: ['LAST_10', 'LIFETIME', 'MATCH'] },
      },
      orderBy: [{ snapshotDate: 'desc' }, { createdAt: 'desc' }],
      take: 30,
    })

    const selected = this.pickPreferredSnapshot(snapshots)
    return selected ? this.snapshotToAggregate(selected) : null
  }

  private async getCurrentAggregates(playerIds: string[]): Promise<PlayerAxisAggregate[]> {
    if (playerIds.length === 0) return []

    const snapshots = await prisma.playerIndexSnapshot.findMany({
      where: {
        playerId: { in: playerIds },
        snapshotType: { in: ['LAST_10', 'LIFETIME', 'MATCH'] },
      },
      orderBy: [{ playerId: 'asc' }, { snapshotDate: 'desc' }, { createdAt: 'desc' }],
    })

    const grouped = new Map<string, PlayerIndexSnapshot[]>()
    for (const snapshot of snapshots) {
      const entries = grouped.get(snapshot.playerId) ?? []
      entries.push(snapshot)
      grouped.set(snapshot.playerId, entries)
    }

    const aggregates: PlayerAxisAggregate[] = []
    for (const playerId of playerIds) {
      const selected = this.pickPreferredSnapshot(grouped.get(playerId) ?? [])
      if (!selected) continue
      aggregates.push(this.snapshotToAggregate(selected))
    }

    return aggregates
  }

  private detectWeakness(aggregate: PlayerAxisAggregate, role: string) {
    const weights = ROLE_WEIGHTS[role]
    if (!weights) return null

    let lowestAxis: string | null = null
    let lowestScore = Infinity

    for (const [axis, weight] of Object.entries(weights)) {
      if (weight > 0) {
        const field = AXIS_FIELD_MAP[axis]
        const score = aggregate[field] as number | null
        if (score !== null && score !== undefined && score < lowestScore) {
          lowestScore = score
          lowestAxis = axis
        }
      }
    }

    if (!lowestAxis) return null
    return {
      axis: lowestAxis,
      ...WEAKNESS_MAP[lowestAxis]
    }
  }

  private async getDrillRecommendations(role: PlayerRole, weaknessAxis: string) {
    const weakness = WEAKNESS_MAP[weaknessAxis]
    if (!weakness) return []

    const roleTagsMatch = role === 'WICKET_KEEPER_BATSMAN'
      ? ['WICKET_KEEPER', 'BATSMAN']
      : [role]

    return prisma.drill.findMany({
      where: {
        isActive: true,
        category: { in: weakness.drillCategories as any },
        AND: weakness.skillAreas.length > 0
          ? [{ OR: [
                { skillArea: { in: weakness.skillAreas } },
                { roleTags: { isEmpty: true } }
              ]}]
          : [],
        OR: [
          { roleTags: { hasSome: roleTagsMatch as any } },
          { roleTags: { isEmpty: true } }
        ]
      },
      orderBy: { difficulty: 'asc' },
      take: 3
    })
  }

  private async getCoachSuggestions(city: string | null, weaknessAxis?: string, take = 5) {
    const specializations = weaknessAxis ? WEAKNESS_MAP[weaknessAxis]?.coachSpecializations : []

    const gigs = await prisma.gigListing.findMany({
      where: {
        isActive: true,
        ...(specializations && specializations.length > 0 ? {
          coach: {
            specializations: { hasSome: specializations }
          }
        } : {}),
        ...(city ? { coach: { city, gigEnabled: true } } : { coach: { gigEnabled: true } })
      },
      include: {
        coach: {
          include: {
            user: { select: { id: true, name: true, avatarUrl: true } }
          }
        }
      },
      orderBy: { coach: { rating: 'desc' } },
      take
    })

    return gigs.map(gig => ({
      coachId: gig.coach.id,
      name: gig.coach.user.name,
      avatarUrl: gig.coach.user.avatarUrl,
      specializations: gig.coach.specializations,
      rating: gig.coach.rating,
      totalSessions: gig.coach.totalSessions,
      gigId: gig.id,
      gigTitle: gig.title,
      sessionPricePaise: gig.pricePerSessionPaise,
      durationMins: gig.durationMins,
      sessionType: gig.sessionType,
      locationName: gig.locationName,
      distanceKm: null
    }))
  }

  private async computeReadiness(playerId: string, wellness: any, momentum: number | null) {
    const recentFacts = await prisma.matchPlayerFact.findMany({
      where: { playerId },
      orderBy: { matchDate: 'desc' },
      take: 5,
      select: { result: true }
    })

    let winStreak = 0
    for (const f of recentFacts) {
      if (f.result === 'WIN') winStreak++
      else break
    }

    const readinessScore = Math.min(100, Math.round(
      wellness.recoveryScore + (winStreak * 3) + ((momentum || 0) > 70 ? 5 : 0)
    ))

    const signals: { label: string; positive: boolean }[] = []
    if (wellness.fatigueLevel > 7) signals.push({ label: 'High fatigue detected', positive: false })
    if (wellness.fatigueLevel <= 4) signals.push({ label: 'Well rested', positive: true })
    if (winStreak >= 3) signals.push({ label: `${winStreak} match winning streak`, positive: true })
    if (momentum && momentum > 70) signals.push({ label: 'In peak form', positive: true })
    if (momentum && momentum < 40) signals.push({ label: 'Form dip — focus on basics', positive: false })

    return {
      score: readinessScore,
      signals
    }
  }
}
