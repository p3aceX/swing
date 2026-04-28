export function toSlug(text: string): string {
  return text
    .toLowerCase()
    .replace(/[^a-z0-9\s-]/g, '')
    .trim()
    .replace(/\s+/g, '-')
    .replace(/-+/g, '-')
    .replace(/^-|-$/g, '')
}

export async function generateArenaSlug(
  citySlug: string,
  baseArenaSlug: string,
  excludeId?: string,
): Promise<string> {
  const { prisma } = await import('@swing/db')
  let slug = baseArenaSlug
  let suffix = 1
  while (true) {
    const existing = await prisma.arena.findFirst({
      where: {
        citySlug,
        arenaSlug: slug,
        ...(excludeId ? { id: { not: excludeId } } : {}),
      },
    })
    if (!existing) return slug
    slug = `${baseArenaSlug}-${++suffix}`
  }
}
