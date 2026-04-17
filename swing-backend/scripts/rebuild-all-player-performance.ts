import { PrismaClient } from "@prisma/client";
import { PerformanceService } from "../apps/api/src/modules/performance/performance.service.ts";

const prisma = new PrismaClient();
const performanceService = new PerformanceService();

async function main() {
  const args = new Set(process.argv.slice(2));
  const skipMatchReprocess = args.has("--skip-match-reprocess");

  const completedMatches = await prisma.match.findMany({
    where: { status: "COMPLETED" },
    select: { id: true },
    orderBy: [{ completedAt: "asc" }, { scheduledAt: "asc" }],
  });

  const allPlayers = await prisma.playerProfile.findMany({
    select: { id: true },
    orderBy: { createdAt: "asc" },
  });

  let reprocessed = 0;
  let skipped = 0;
  let failed = 0;

  if (!skipMatchReprocess) {
    console.log(`Reprocessing ${completedMatches.length} completed matches...`);
    for (let i = 0; i < completedMatches.length; i += 1) {
      const match = completedMatches[i];
      try {
        const result = await performanceService.processVerifiedMatch(match.id, {
          allowUnverified: true,
        });
        if (result.processed) {
          reprocessed += 1;
        } else {
          skipped += 1;
        }
      } catch (error) {
        failed += 1;
        console.error(`Failed match ${match.id}`, error);
      }

      if ((i + 1) % 100 === 0 || i + 1 === completedMatches.length) {
        console.log(
          `Match progress ${i + 1}/${completedMatches.length} (processed=${reprocessed}, skipped=${skipped}, failed=${failed})`,
        );
      }
    }
  } else {
    console.log("Skipping match reprocess (--skip-match-reprocess).");
  }

  console.log(`Rebuilding ${allPlayers.length} players from current facts...`);
  const rebuilt = await performanceService.rebuildPlayersFromCurrentFacts(
    allPlayers.map((player) => player.id),
  );

  console.log(
    JSON.stringify(
      {
        completedMatches: completedMatches.length,
        reprocessed,
        skipped,
        failed,
        playersTotal: allPlayers.length,
        rebuiltPlayers: rebuilt.rebuiltPlayers,
        seasonId: rebuilt.seasonId,
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
