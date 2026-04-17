const { prisma } = require('@swing/db')

function svgDataUrl(markup) {
  return `data:image/svg+xml;charset=UTF-8,${encodeURIComponent(markup)}`
}

function initials(value, max = 2) {
  const parts = value
    .trim()
    .split(/\s+/)
    .filter(Boolean)
    .slice(0, max)
  const joined = parts.map((part) => (part[0] || '').toUpperCase()).join('')
  return joined || 'S'
}

function badgeIconUrl(name, category) {
  const palette = {
    BATTING: { bg: '#b91c1c', fg: '#ffffff' },
    BOWLING: { bg: '#1d4ed8', fg: '#ffffff' },
    FIELDING: { bg: '#047857', fg: '#ffffff' },
    ALL_ROUNDER: { bg: '#7c3aed', fg: '#ffffff' },
    FITNESS: { bg: '#c2410c', fg: '#ffffff' },
    GENERAL: { bg: '#334155', fg: '#ffffff' },
  }
  const colors = palette[category] || { bg: '#0f172a', fg: '#ffffff' }
  const label = initials(name)
  return svgDataUrl(
    `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 128 128"><rect x="8" y="8" width="112" height="112" rx="28" fill="${colors.bg}"/><path d="M64 20l10.2 20.7 22.8 3.3-16.5 16.1 3.9 22.7L64 72.1 43.6 82.8l3.9-22.7L31 44l22.8-3.3L64 20z" fill="rgba(255,255,255,0.18)"/><text x="50%" y="56%" dominant-baseline="middle" text-anchor="middle" font-family="Arial, sans-serif" font-size="34" font-weight="700" fill="${colors.fg}">${label}</text></svg>`,
  )
}

async function main() {
  const badges = await prisma.$queryRawUnsafe(
    'SELECT id, name, category FROM "Badge" WHERE "iconUrl" IS NULL',
  )

  for (const badge of badges) {
    await prisma.$executeRawUnsafe(
      'UPDATE "Badge" SET "iconUrl" = $1 WHERE id = $2',
      badgeIconUrl(badge.name, badge.category),
      badge.id,
    )
  }

  const remaining = await prisma.$queryRawUnsafe(
    'SELECT COUNT(*)::int AS count FROM "Badge" WHERE "iconUrl" IS NULL',
  )

  console.log(JSON.stringify({ updated: badges.length, remaining }, null, 2))
}

main()
  .catch((error) => {
    console.error(error)
    process.exitCode = 1
  })
  .finally(async () => {
    await prisma.$disconnect()
  })
