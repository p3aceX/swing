import type { Metadata } from "next";
import ScorerClient from "./_scorer-client";

export const metadata: Metadata = {
  title: "Scoring",
  robots: { index: false, follow: false },
};

export default async function ScoringPage({
  params,
}: {
  params: Promise<{ matchId: string }>;
}) {
  const { matchId } = await params;
  return <ScorerClient matchId={matchId} />;
}
