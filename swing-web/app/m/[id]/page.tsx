import type { Metadata } from "next";
import { notFound } from "next/navigation";
import { getMatch } from "@/lib/api";
import MatchPageClient, { type MatchPageData } from "./match-page-client";

export const dynamic = "force-dynamic";

function buildMatchMeta(match: MatchPageData) {
  const teamA = match.teamMeta?.A?.name ?? match.teamAName;
  const teamB = match.teamMeta?.B?.name ?? match.teamBName;
  const versus = `${teamA} vs ${teamB}`;

  // Score summary line
  let scoreLine = "";
  if (match.innings && match.innings.length > 0) {
    const parts = match.innings.map((inn) => {
      const team = inn.battingTeam === match.teamAName ? teamA : teamB;
      const overs = inn.isCompleted
        ? `${inn.totalOvers} ov`
        : `${inn.totalOvers} ov*`;
      return `${team} ${inn.totalRuns}/${inn.totalWickets} (${overs})`;
    });
    scoreLine = parts.join(" • ");
  }

  // Result / status line
  let statusLine = "";
  if (match.status === "COMPLETED" && match.winnerId) {
    const winner =
      match.winnerId === match.teamAName ? teamA : teamB;
    statusLine = match.winMargin
      ? `${winner} won by ${match.winMargin}`
      : `${winner} won`;
  } else if (match.status === "LIVE") {
    statusLine = "🔴 LIVE now";
  } else if (match.status === "SCHEDULED") {
    statusLine = "Match coming up";
  }

  const title = `${versus} — ${statusLine || match.status}`;
  const descParts = [scoreLine, statusLine].filter(Boolean);
  const description = descParts.length
    ? `${descParts.join(" | ")} — Follow live on Swing Cricket.`
    : `${versus} — Follow live scores, ball-by-ball commentary and highlights on Swing Cricket.`;

  return { title, description, teamA, teamB, scoreLine, statusLine };
}

export async function generateMetadata({
  params,
}: {
  params: Promise<{ id: string }>;
}): Promise<Metadata> {
  const { id } = await params;
  const match = (await getMatch(id)) as MatchPageData | null;
  if (!match) return { title: "Match Not Found" };

  const { title, description, teamA, teamB } = buildMatchMeta(match);
  const url = `https://www.swingcricketapp.com/m/${id}`;

  return {
    title,
    description,
    openGraph: {
      title,
      description,
      url,
      type: "website",
      images: [
        {
          url: `/api/og/match/${id}`,
          width: 1200,
          height: 630,
          alt: `${teamA} vs ${teamB}`,
        },
      ],
    },
    twitter: {
      card: "summary_large_image",
      title,
      description,
    },
  };
}

export default async function MatchPage({
  params,
}: {
  params: Promise<{ id: string }>;
}) {
  const { id } = await params;
  const match = (await getMatch(id)) as MatchPageData | null;

  if (!match) notFound();

  return <MatchPageClient match={match} />;
}
