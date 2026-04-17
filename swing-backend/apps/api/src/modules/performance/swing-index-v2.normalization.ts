export function safeDivide(a: number | null | undefined, b: number | null | undefined, fallback = 0) {
  // Defensive fallback: any invalid numerator/denominator resolves to a safe finite value.
  if (typeof a !== 'number' || !Number.isFinite(a)) return fallback
  if (typeof b !== 'number' || !Number.isFinite(b) || b === 0) return fallback
  return a / b
}

export function clampScore0to100(value: number | null | undefined) {
  if (typeof value !== 'number' || !Number.isFinite(value)) return 0
  return Math.max(0, Math.min(100, value))
}

export function normalizeHigherBetter(
  value: number | null | undefined,
  min: number,
  max: number,
) {
  if (typeof value !== 'number' || !Number.isFinite(value)) return null
  if (!Number.isFinite(min) || !Number.isFinite(max) || max <= min) return clampScore0to100(value)
  return clampScore0to100(((value - min) / (max - min)) * 100)
}

export function normalizeLowerBetter(
  value: number | null | undefined,
  min: number,
  max: number,
) {
  if (typeof value !== 'number' || !Number.isFinite(value)) return null
  if (!Number.isFinite(min) || !Number.isFinite(max) || max <= min) return clampScore0to100(value)
  return clampScore0to100(((max - value) / (max - min)) * 100)
}
