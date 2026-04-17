import { notFound } from "next/navigation";
import { getMatch } from "@/lib/api";
import type { MatchPageData } from "../match-page-client";
import CommentaryPageClient from "./commentary-page-client";

export const dynamic = "force-dynamic";

export default async function MatchCommentaryPage({
  params,
}: {
  params: Promise<{ id: string }>;
}) {
  const { id } = await params;
  const match = (await getMatch(id)) as MatchPageData | null;

  if (!match) notFound();

  return <CommentaryPageClient match={match} />;
}
