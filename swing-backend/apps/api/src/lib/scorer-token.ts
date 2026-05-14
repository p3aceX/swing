import jwt from 'jsonwebtoken'

// Short-lived bearer token issued to web scorers after they prove they
// know the match's livePin. Scoped to a single matchId so a stolen token
// for match A cannot mutate match B.
//
// Intentionally separate signing helpers from the main `lib/jwt.ts` — the
// app user JWT plumbing (refresh tokens, multi-role payload) is irrelevant
// here, and keeping them apart makes the scorer surface easy to audit and
// revoke independently if needed.

export type ScorerJwtPayload = {
  kind: 'scorer'
  matchId: string
}

const SCORER_TOKEN_TTL = '4h'

export function signScorerToken(payload: ScorerJwtPayload): string {
  return jwt.sign(payload, process.env.JWT_SECRET!, { expiresIn: SCORER_TOKEN_TTL })
}

export function verifyScorerToken(token: string): ScorerJwtPayload {
  const decoded = jwt.verify(token, process.env.JWT_SECRET!) as any
  if (!decoded || decoded.kind !== 'scorer' || typeof decoded.matchId !== 'string') {
    throw new Error('Invalid scorer token')
  }
  return { kind: 'scorer', matchId: decoded.matchId }
}
