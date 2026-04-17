import { prisma } from "@swing/db";
import { PerformanceService } from "../apps/api/src/modules/performance/performance.service";

async function main() {
  const performance = new PerformanceService();
  const matches = await prisma.match.findMany({
    where: { status: "COMPLETED" },
    select: { id: true, completedAt: true },
    orderBy: [{ completedAt: "asc" }, { scheduledAt: "asc" }],
  });

  let processed = 0;
  let skipped = 0;
  let warned = 0;
  let failed = 0;

  console.log(`Found ${matches.length} completed matches.`);

  for (const match of matches) {
    try {
      const existingEventCountRows = await prisma.$queryRaw<
        Array<{ count: bigint | number | string }>
      >`
        SELECT COUNT(*)::bigint AS count
        FROM public.ip_event
        WHERE "matchId" = ${match.id}
          AND "source" = 'MATCH_ENGINE'::ip_event_source
      `;
      const existingEventCountRaw = existingEventCountRows[0]?.count ?? 0;
      const existingEventCount =
        typeof existingEventCountRaw === "bigint"
          ? Number(existingEventCountRaw)
          : typeof existingEventCountRaw === "number"
            ? existingEventCountRaw
            : Number.parseInt(String(existingEventCountRaw), 10) || 0;

      if (existingEventCount > 0) {
        skipped += 1;
        continue;
      }

      const stats = await prisma.playerMatchStats.findMany({
        where: { matchId: match.id },
        select: { runs: true, wickets: true, catches: true },
      });

      const statsMayBeEmpty =
        stats.length === 0 ||
        stats.every(
          (playerStat) =>
            playerStat.runs === 0 &&
            playerStat.wickets === 0 &&
            playerStat.catches === 0,
        );

      if (statsMayBeEmpty) {
        warned += 1;
        console.warn(
          `Stats may be empty — state rebuild may be inaccurate for matchId ${match.id}`,
        );
      }

      const result = await performance.processVerifiedMatch(match.id, {
        allowUnverified: true,
      });
      if (result.processed) {
        processed += 1;
      } else {
        failed += 1;
        console.error(
          `Failed to process match ${match.id}: ${result.reason ?? "UNKNOWN"}`,
        );
      }
    } catch (error) {
      failed += 1;
      console.error(`Failed to backfill IP for match ${match.id}`, error);
    }
  }

  console.log(
    JSON.stringify(
      {
        totalCompletedMatches: matches.length,
        processed,
        skipped,
        warned,
        failed,
      },
      null,
      2,
    ),
  );
}

main()
  .catch((error) => {
    console.error(error);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
