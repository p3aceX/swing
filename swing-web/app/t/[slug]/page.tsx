import { notFound } from "next/navigation";
import { getTournament, getTournamentMatches, getTournamentStandings } from "@/lib/api";
import TournamentPage from "./tournament-page";

export const dynamic = "force-dynamic";

export async function generateMetadata({ params }: { params: Promise<{ slug: string }> }) {
  const { slug } = await params;
  const t = await getTournament(slug);
  if (!t) return { title: "Tournament | Swing Cricket" };
  return {
    title: `${t.name} | Swing Cricket`,
    description: t.description ?? `Follow ${t.name} live — scores, brackets & highlights on Swing Cricket`,
    openGraph: {
      title: t.name,
      images: t.coverUrl ? [t.coverUrl] : t.logoUrl ? [t.logoUrl] : [],
    },
  };
}

export default async function Page({ params }: { params: Promise<{ slug: string }> }) {
  const { slug } = await params;

  const [tournament, matches, standings] = await Promise.all([
    getTournament(slug),
    getTournamentMatches(slug),
    getTournamentStandings(slug),
  ]);

  if (!tournament) notFound();

  return (
    <TournamentPage
      tournament={tournament}
      matches={matches ?? []}
      standings={standings ?? []}
    />
  );
}
