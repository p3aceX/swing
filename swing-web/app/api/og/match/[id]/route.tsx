import { ImageResponse } from "next/og";
import { getMatch } from "@/lib/api";
import type { MatchPageData } from "@/app/m/[id]/match-page-client";

export const runtime = "edge";

export async function GET(
  _req: Request,
  { params }: { params: Promise<{ id: string }> }
) {
  const { id } = await params;
  const match = (await getMatch(id)) as MatchPageData | null;

  const teamA = match?.teamMeta?.A?.name ?? match?.teamAName ?? "Team A";
  const teamB = match?.teamMeta?.B?.name ?? match?.teamBName ?? "Team B";

  // Score lines
  const scoreLines =
    match?.innings?.map((inn) => {
      const team = inn.battingTeam === match.teamAName ? teamA : teamB;
      const overs = inn.isCompleted ? `${inn.totalOvers} ov` : `${inn.totalOvers} ov*`;
      return `${team}  ${inn.totalRuns}/${inn.totalWickets}  (${overs})`;
    }) ?? [];

  // Status badge
  let badge = "";
  let badgeColor = "#6b7280";
  if (match?.status === "LIVE") {
    badge = "● LIVE";
    badgeColor = "#ef4444";
  } else if (match?.status === "COMPLETED" && match.winnerId) {
    const winner = match.winnerId === match.teamAName ? teamA : teamB;
    badge = match.winMargin ? `${winner} won by ${match.winMargin}` : `${winner} won`;
    badgeColor = "#22c55e";
  } else if (match?.status === "SCHEDULED") {
    badge = "Upcoming";
    badgeColor = "#f59e0b";
  }

  const competition = match?.competition?.name ?? "Swing Cricket";

  return new ImageResponse(
    (
      <div
        style={{
          width: "1200px",
          height: "630px",
          background: "linear-gradient(135deg, #0f172a 0%, #1e293b 60%, #0f172a 100%)",
          display: "flex",
          flexDirection: "column",
          alignItems: "center",
          justifyContent: "center",
          fontFamily: "sans-serif",
          color: "#f8fafc",
          padding: "60px",
          position: "relative",
        }}
      >
        {/* Subtle field arc decoration */}
        <div
          style={{
            position: "absolute",
            bottom: "-120px",
            left: "50%",
            transform: "translateX(-50%)",
            width: "900px",
            height: "450px",
            borderRadius: "50%",
            border: "1px solid rgba(255,255,255,0.05)",
          }}
        />

        {/* Competition name */}
        <div style={{ fontSize: "22px", color: "#94a3b8", marginBottom: "20px", letterSpacing: "0.05em" }}>
          {competition.toUpperCase()}
        </div>

        {/* Teams */}
        <div
          style={{
            display: "flex",
            alignItems: "center",
            gap: "32px",
            marginBottom: "32px",
          }}
        >
          <span style={{ fontSize: "64px", fontWeight: 800, letterSpacing: "-1px" }}>{teamA}</span>
          <span style={{ fontSize: "36px", color: "#475569", fontWeight: 300 }}>vs</span>
          <span style={{ fontSize: "64px", fontWeight: 800, letterSpacing: "-1px" }}>{teamB}</span>
        </div>

        {/* Score lines */}
        {scoreLines.map((line, i) => (
          <div
            key={i}
            style={{
              fontSize: "28px",
              color: "#cbd5e1",
              marginBottom: "10px",
              letterSpacing: "0.03em",
            }}
          >
            {line}
          </div>
        ))}

        {/* Status badge */}
        {badge && (
          <div
            style={{
              marginTop: "28px",
              background: `${badgeColor}22`,
              border: `1.5px solid ${badgeColor}`,
              color: badgeColor,
              borderRadius: "999px",
              padding: "10px 28px",
              fontSize: "22px",
              fontWeight: 700,
              letterSpacing: "0.04em",
            }}
          >
            {badge}
          </div>
        )}

        {/* Footer */}
        <div
          style={{
            position: "absolute",
            bottom: "32px",
            display: "flex",
            alignItems: "center",
            gap: "10px",
            color: "#475569",
            fontSize: "20px",
          }}
        >
          🏏  swingcricketapp.com
        </div>
      </div>
    ),
    { width: 1200, height: 630 }
  );
}
