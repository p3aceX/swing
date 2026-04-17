"use client";

import { useEffect, useMemo, useRef, useState } from "react";
import { useParams, useRouter } from "next/navigation";
import {
  ArrowLeft,
  Copy,
  ExternalLink,
  RotateCcw,
  Trash2,
  Tv2,
  Radio,
  Monitor,
  Eye,
  EyeOff,
  Zap,
  Video,
  Smartphone,
  Activity,
  Wifi,
  WifiOff,
  Pencil,
} from "lucide-react";
import { toast } from "sonner";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogFooter,
} from "@/components/ui/dialog";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import {
  useMatchDetailQuery,
  useMatchPlayersQuery,
  useUpdatePlaying11Mutation,
  useQuickAddMatchPlayerMutation,
  useChangeWicketKeeperMutation,
  useRecordTossMutation,
  useStartMatchMutation,
  useCompleteMatchMutation,
  useRecordBallMutation,
  useUndoLastBallMutation,
  useUpdateBallMutation,
  useCompleteInningsMutation,
  useContinueInningsMutation,
  useEnforceFollowOnMutation,
  useStartSuperOverMutation,
  useReopenInningsMutation,
  useDeleteMatchMutation,
  useEndOfDayMutation,
  useAddHighlightMutation,
  useDeleteHighlightMutation,
  useSetMatchStreamMutation,
  useStudioSceneQuery,
  useSetStudioSceneMutation,
  useLiveSessionQuery,
} from "@/lib/queries";
import { useScoringStore } from "@/lib/useScoringStore";
import type {
  BallInput,
  BallOutcome,
  BallRecord,
  DismissalType,
  InningsRecord,
  MatchDetail,
  MatchPlayer,
} from "@/lib/api";

// ─── HLS Player ───────────────────────────────────────────────────────────────

function HlsPlayer({ url }: { url: string }) {
  const videoRef = useRef<HTMLVideoElement>(null);

  useEffect(() => {
    const video = videoRef.current;
    if (!video || !url) return;

    let hls: any;
    import("hls.js").then(({ default: Hls }) => {
      if (Hls.isSupported()) {
        hls = new Hls({ lowLatencyMode: true });
        hls.loadSource(url);
        hls.attachMedia(video);
        hls.on(Hls.Events.MANIFEST_PARSED, () => { video.play().catch(() => {}); });
      } else if (video.canPlayType("application/vnd.apple.mpegurl")) {
        video.src = url;
        video.play().catch(() => {});
      }
    });

    return () => { hls?.destroy(); };
  }, [url]);

  return (
    <div className="rounded-lg overflow-hidden bg-black aspect-video w-full">
      <video ref={videoRef} controls muted playsInline className="w-full h-full object-contain" />
    </div>
  );
}

// ─── helpers ──────────────────────────────────────────────────────────────────

const PUBLIC_WEB_BASE_URL = (
  process.env.NEXT_PUBLIC_WEB_BASE_URL ?? "https://swingcricketapp.com"
).replace(/\/$/, "");

const API_BASE_URL = (
  process.env.NEXT_PUBLIC_API_BASE_URL ?? "http://localhost:3000"
).replace(/\/$/, "");

function fmtOvers(o: number) {
  const w = Math.floor(o);
  const b = Math.round((o - w) * 10);
  return `${w}.${b}`;
}

function statusColor(s: string) {
  if (s === "IN_PROGRESS") return "bg-emerald-100 text-emerald-700";
  if (s === "COMPLETED") return "bg-blue-100 text-blue-700";
  if (s === "TOSS_DONE") return "bg-amber-100 text-amber-700";
  return "bg-muted text-muted-foreground";
}

const FORMAT_OVERS: Record<string, number> = {
  T10: 10,
  T20: 20,
  ONE_DAY: 50,
  BOX_CRICKET: 6,
  TWO_INNINGS: 90,
};

const DISMISSALS: { v: DismissalType; l: string }[] = [
  { v: "BOWLED", l: "Bowled" },
  { v: "CAUGHT", l: "Caught" },
  { v: "LBW", l: "LBW" },
  { v: "RUN_OUT", l: "Run Out" },
  { v: "STUMPED", l: "Stumped" },
  { v: "HIT_WICKET", l: "Hit Wicket" },
  { v: "RETIRED_HURT", l: "Retired Hurt" },
  { v: "OBSTRUCTING_FIELD", l: "Obstructing" },
];

// Dismissals valid on a free hit
const FREE_HIT_DISMISSALS: DismissalType[] = ["RUN_OUT", "OBSTRUCTING_FIELD"];

// ─── SVG Wagon Wheel ──────────────────────────────────────────────────────────

const ZONE_DEFS = [
  { id: "fine-leg",    label: "Fine Leg",  short: "FL", startDeg: 155, endDeg: 205 },
  { id: "square-leg", label: "Sq Leg",    short: "SL", startDeg: 205, endDeg: 245 },
  { id: "mid-wicket", label: "Mid Wkt",   short: "MW", startDeg: 245, endDeg: 280 },
  { id: "mid-on",     label: "Mid On",    short: "MO", startDeg: 280, endDeg: 315 },
  { id: "mid-off",    label: "Mid Off",   short: "Mf", startDeg: 315, endDeg: 350 },
  { id: "extra-cover",label: "Ex Cover",  short: "EC", startDeg: 350, endDeg: 25  },
  { id: "cover",      label: "Cover",     short: "CV", startDeg: 25,  endDeg: 65  },
  { id: "point",      label: "Point",     short: "PT", startDeg: 65,  endDeg: 115 },
  { id: "third-man",  label: "Third Man", short: "TM", startDeg: 115, endDeg: 155 },
];

// Radius constants
const WW_CX = 150, WW_CY = 150;
const WW_OUTER_R = 128;  // boundary
const WW_INNER_R = 70;   // 30-yard circle
const WW_PITCH_R = 26;   // pitch/stumps area

/** Extract zone string from a ball (tags or wagonZone field) */
function zoneFromBall(b: BallRecord): string | null {
  return (
    b.wagonZone ||
    b.tags?.find((t: string) => t.startsWith("zone:"))?.replace("zone:", "") ||
    null
  );
}

function getShotTarget(zoneStr: string): { x: number; y: number } {
  const isInner = zoneStr.endsWith("-in");
  const baseId = isInner ? zoneStr.slice(0, -3) : zoneStr;
  const z = ZONE_DEFS.find((z) => z.id === baseId);
  if (!z) return { x: WW_CX, y: WW_CY };
  const end = z.endDeg < z.startDeg ? z.endDeg + 360 : z.endDeg;
  const midAngle = (z.startDeg + end) / 2;
  const r = isInner
    ? WW_PITCH_R + (WW_INNER_R - WW_PITCH_R) * 0.72
    : WW_INNER_R + (WW_OUTER_R - WW_INNER_R) * 0.78;
  return polarToXY(WW_CX, WW_CY, r, midAngle);
}

function ballShotColor(b: BallRecord): string {
  if (b.isWicket) return "#ef4444";
  if (b.outcome === "SIX") return "#fbbf24";
  if (b.outcome === "FOUR") return "#22c55e";
  if (b.runs >= 1) return "#60a5fa";
  return "rgba(255,255,255,0.20)";
}


function polarToXY(cx: number, cy: number, r: number, deg: number) {
  const rad = ((deg - 90) * Math.PI) / 180;
  return { x: cx + r * Math.cos(rad), y: cy + r * Math.sin(rad) };
}

function sectorPath(
  cx: number,
  cy: number,
  r1: number,
  r2: number,
  startDeg: number,
  endDeg: number,
) {
  let end = endDeg;
  if (end < startDeg) end += 360;
  const s1 = polarToXY(cx, cy, r1, startDeg);
  const e1 = polarToXY(cx, cy, r1, end);
  const s2 = polarToXY(cx, cy, r2, startDeg);
  const e2 = polarToXY(cx, cy, r2, end);
  const large = end - startDeg > 180 ? 1 : 0;
  return [
    `M ${s1.x} ${s1.y}`,
    `A ${r1} ${r1} 0 ${large} 1 ${e1.x} ${e1.y}`,
    `L ${e2.x} ${e2.y}`,
    `A ${r2} ${r2} 0 ${large} 0 ${s2.x} ${s2.y}`,
    "Z",
  ].join(" ");
}

function labelPos(
  cx: number,
  cy: number,
  r: number,
  startDeg: number,
  endDeg: number,
) {
  const end = endDeg < startDeg ? endDeg + 360 : endDeg;
  return polarToXY(cx, cy, r, (startDeg + end) / 2);
}

function WagonWheel({
  selected = "",
  onSelect,
  onDot,
  isFreeHit = false,
  zoneTotals,
  balls = [],
}: {
  selected?: string;
  onSelect?: (z: string) => void;
  onDot?: () => void;
  isFreeHit?: boolean;
  zoneTotals?: Record<string, number>;
  balls?: BallRecord[];
}) {
  const cx = WW_CX, cy = WW_CY;
  const outerR = WW_OUTER_R, innerR = WW_INNER_R, pitchR = WW_PITCH_R;
  const interactive = !!onSelect;
  const canDot = !!onDot;

  // Determine which zone def matches current selection (for label display)
  const selectedDef = selected
    ? ZONE_DEFS.find((z) => selected === z.id || selected === `${z.id}-in`)
    : null;
  const selectedIsInner = selected.endsWith("-in");

  return (
    <div className="relative select-none">
      {/* Free Hit badge */}
      {isFreeHit && (
        <div className="absolute top-0 left-1/2 -translate-x-1/2 z-10 pointer-events-none">
          <span className="bg-yellow-400 text-yellow-900 font-black text-[9px] px-3 py-0.5 rounded-full tracking-widest uppercase shadow-lg animate-pulse">
            FREE HIT
          </span>
        </div>
      )}

      <div>
        <div>
          <svg viewBox="0 0 300 300" className="w-full max-w-[300px] mx-auto">
            <defs>
              {/* Outfield gradient */}
              <radialGradient id="ww-field" cx="50%" cy="50%" r="50%">
                <stop offset="0%"   stopColor="#1e4d23" />
                <stop offset="55%"  stopColor="#163d1b" />
                <stop offset="100%" stopColor="#0e2912" />
              </radialGradient>
              {/* Infield — lighter green ring */}
              <radialGradient id="ww-infield" cx="50%" cy="50%" r="50%">
                <stop offset="0%"  stopColor="#2d6e35" />
                <stop offset="100%" stopColor="#255c2c" />
              </radialGradient>
              {/* Pitch highlight */}
              <radialGradient id="ww-pitch-glow" cx="50%" cy="50%" r="50%">
                <stop offset="0%"  stopColor="#fff" stopOpacity="0.18" />
                <stop offset="100%" stopColor="#fff" stopOpacity="0" />
              </radialGradient>
              {/* Boundary strip */}
              <radialGradient id="ww-boundary" cx="50%" cy="50%" r="50%">
                <stop offset="85%"  stopColor="white" stopOpacity="0.06" />
                <stop offset="100%" stopColor="white" stopOpacity="0.22" />
              </radialGradient>
            </defs>

            {/* Outfield */}
            <circle cx={cx} cy={cy} r={outerR + 8} fill="url(#ww-field)" />
            {/* Boundary rope highlight */}
            <circle cx={cx} cy={cy} r={outerR + 4} fill="none"
              stroke="rgba(255,255,255,0.12)" strokeWidth={8} />

            {/* Infield ring (lighter) */}
            <circle cx={cx} cy={cy} r={innerR} fill="url(#ww-infield)" />

            {/* ── Outer sectors (outfield → no -in suffix) ── */}
            {ZONE_DEFS.map((z) => {
              const isSelected = selected === z.id;
              const d = sectorPath(cx, cy, innerR, outerR, z.startDeg, z.endDeg);
              const end = z.endDeg < z.startDeg ? z.endDeg + 360 : z.endDeg;
              const mid = (z.startDeg + end) / 2;
              // Label position: 68% into the outfield band
              const lp = polarToXY(cx, cy, innerR + (outerR - innerR) * 0.58, mid);
              const runs = zoneTotals?.[z.id] ?? 0;
              return (
                <g
                  key={`outer-${z.id}`}
                  onClick={() => interactive && onSelect!(selected === z.id ? "" : z.id)}
                  className={interactive ? "cursor-pointer" : ""}
                >
                  <path
                    d={d}
                    fill={isSelected ? "hsl(var(--primary))" : "transparent"}
                    fillOpacity={isSelected ? 0.50 : 1}
                    stroke="rgba(255,255,255,0.10)"
                    strokeWidth={0.7}
                    className={interactive ? "hover:fill-white/[0.07] transition-colors" : ""}
                  />
                  {/* Zone short label */}
                  <text
                    x={lp.x} y={lp.y - (runs > 0 ? 5 : 0)}
                    textAnchor="middle" dominantBaseline="middle"
                    fontSize={7.5} fontWeight={isSelected ? "800" : "600"}
                    fill={isSelected ? "white" : "rgba(255,255,255,0.65)"}
                    style={{ pointerEvents: "none" }}
                  >
                    {z.short}
                  </text>
                  {/* Run total (green badge) */}
                  {runs > 0 && (
                    <text
                      x={lp.x} y={lp.y + 6}
                      textAnchor="middle" dominantBaseline="middle"
                      fontSize={9.5} fontWeight="900"
                      fill={isSelected ? "white" : "#86efac"}
                      style={{ pointerEvents: "none" }}
                    >
                      {runs}
                    </text>
                  )}
                </g>
              );
            })}

            {/* ── Inner sectors (infield → -in suffix) ── */}
            {ZONE_DEFS.map((z) => {
              const innerId = `${z.id}-in`;
              const isSelected = selected === innerId;
              const d = sectorPath(cx, cy, pitchR, innerR, z.startDeg, z.endDeg);
              const end = z.endDeg < z.startDeg ? z.endDeg + 360 : z.endDeg;
              const mid = (z.startDeg + end) / 2;
              const lp = polarToXY(cx, cy, pitchR + (innerR - pitchR) * 0.58, mid);
              return (
                <g
                  key={`inner-${z.id}`}
                  onClick={() => interactive && onSelect!(selected === innerId ? "" : innerId)}
                  className={interactive ? "cursor-pointer" : ""}
                >
                  <path
                    d={d}
                    fill={isSelected ? "hsl(var(--primary))" : "transparent"}
                    fillOpacity={isSelected ? 0.60 : 1}
                    stroke="rgba(255,255,255,0.07)"
                    strokeWidth={0.5}
                    className={interactive ? "hover:fill-white/[0.10] transition-colors" : ""}
                  />
                  <text
                    x={lp.x} y={lp.y}
                    textAnchor="middle" dominantBaseline="middle"
                    fontSize={5.5} fontWeight={isSelected ? "800" : "500"}
                    fill={isSelected ? "white" : "rgba(255,255,255,0.32)"}
                    style={{ pointerEvents: "none" }}
                  >
                    {z.short}
                  </text>
                </g>
              );
            })}

            {/* Boundary circle line */}
            <circle cx={cx} cy={cy} r={outerR} fill="none"
              stroke="rgba(255,255,255,0.30)" strokeWidth={1.5}
            />
            {isFreeHit && (
              <circle cx={cx} cy={cy} r={outerR + 8} fill="none"
                stroke="#fbbf24" strokeWidth={2.5} strokeDasharray="8 5"
                className="animate-spin" style={{ animationDuration: "8s" }}
              />
            )}

            {/* 30-yard circle */}
            <circle cx={cx} cy={cy} r={innerR} fill="none"
              stroke="rgba(255,255,255,0.35)" strokeWidth={1}
              strokeDasharray="5 4"
            />

            {/* Zone separator lines (from pitchR to outerR) */}
            {ZONE_DEFS.map((z) => {
              const p1 = polarToXY(cx, cy, pitchR, z.startDeg);
              const p2 = polarToXY(cx, cy, outerR, z.startDeg);
              return (
                <line key={`sep-${z.id}`}
                  x1={p1.x} y1={p1.y} x2={p2.x} y2={p2.y}
                  stroke="rgba(255,255,255,0.10)" strokeWidth={0.7}
                />
              );
            })}

            {/* ── Played shots ── */}
            {balls.map((b, i) => {
              const zone = zoneFromBall(b);
              if (!zone) return null;
              const { x: tx, y: ty } = getShotTarget(zone);
              const color = ballShotColor(b);
              const isSix = b.outcome === "SIX";
              const isFour = b.outcome === "FOUR";
              if (isSix) {
                const cpX = (cx + tx) / 2;
                const cpY = (cy + ty) / 2 - 46;
                return (
                  <path key={i}
                    d={`M ${cx} ${cy} Q ${cpX} ${cpY} ${tx} ${ty}`}
                    stroke={color} strokeWidth={2} fill="none"
                    strokeLinecap="round" opacity={0.88}
                  />
                );
              }
              if (isFour) {
                const cpX = (cx + tx) / 2;
                const cpY = (cy + ty) / 2 - 14;
                return (
                  <path key={i}
                    d={`M ${cx} ${cy} Q ${cpX} ${cpY} ${tx} ${ty}`}
                    stroke={color} strokeWidth={1.8} fill="none"
                    strokeLinecap="round" opacity={0.82}
                  />
                );
              }
              return (
                <line key={i}
                  x1={cx} y1={cy} x2={tx} y2={ty}
                  stroke={color}
                  strokeWidth={b.runs >= 1 ? 1.5 : 0.7}
                  strokeLinecap="round" opacity={0.72}
                />
              );
            })}

            {/* Shot endpoint dots */}
            {balls.map((b, i) => {
              const zone = zoneFromBall(b);
              if (!zone) return null;
              const { x: tx, y: ty } = getShotTarget(zone);
              const color = ballShotColor(b);
              const r = b.outcome === "SIX" ? 3.5 : b.isWicket ? 4 : 2.5;
              return <circle key={`dot-${i}`} cx={tx} cy={ty} r={r} fill={color} opacity={0.92} />;
            })}

            {/* ── Pitch ── */}
            <rect x={cx - 7} y={cy - 23} width={14} height={46} rx={3}
              fill="#c8a870" opacity={0.90} />
            {/* Crease lines */}
            <line x1={cx - 7} y1={cy - 14} x2={cx + 7} y2={cy - 14}
              stroke="#a0804a" strokeWidth={0.8} />
            <line x1={cx - 7} y1={cy + 14} x2={cx + 7} y2={cy + 14}
              stroke="#a0804a" strokeWidth={0.8} />

            {/* ── DOT ball center — tappable pitch ── */}
            {canDot && (
              <circle
                cx={cx} cy={cy} r={pitchR - 1}
                fill={selected ? "rgba(255,255,255,0.10)" : "rgba(255,255,255,0.06)"}
                stroke={selected ? "rgba(255,255,255,0.35)" : "rgba(255,255,255,0.15)"}
                strokeWidth={1}
                strokeDasharray={selected ? "none" : "3 2"}
                onClick={onDot}
                className="cursor-pointer transition-all hover:fill-white/20"
              />
            )}
            {!canDot && (
              <circle cx={cx} cy={cy} r={pitchR - 1}
                fill="rgba(0,0,0,0.18)" stroke="none" />
            )}

            {/* Stumps */}
            {([-3.5, 0, 3.5] as number[]).map((dx) => (
              <g key={`st${dx}`} style={{ pointerEvents: "none" }}>
                <line x1={cx+dx} y1={cy-23} x2={cx+dx} y2={cy-14} stroke="#6b4c2a" strokeWidth={2} />
                <line x1={cx+dx} y1={cy+14} x2={cx+dx} y2={cy+23} stroke="#6b4c2a" strokeWidth={2} />
              </g>
            ))}

            {/* Center label — zone selected vs idle */}
            {canDot && !selected && (
              <g style={{ pointerEvents: "none" }}>
                <text x={cx} y={cy - 5} textAnchor="middle" dominantBaseline="middle"
                  fontSize={14} fill="rgba(255,255,255,0.55)">
                  ·
                </text>
                <text x={cx} y={cy + 7} textAnchor="middle" dominantBaseline="middle"
                  fontSize={6} fill="rgba(255,255,255,0.30)">
                  DOT
                </text>
              </g>
            )}
            {canDot && selected && selectedDef && (
              <g style={{ pointerEvents: "none" }}>
                <text x={cx} y={cy - 7} textAnchor="middle" dominantBaseline="middle"
                  fontSize={8} fontWeight="800" fill="hsl(var(--primary))">
                  {selectedDef.short}
                </text>
                <text x={cx} y={cy + 1} textAnchor="middle" dominantBaseline="middle"
                  fontSize={5.5} fill="rgba(255,255,255,0.40)">
                  {selectedIsInner ? "infield" : "outfield"}
                </text>
                <text x={cx} y={cy + 11} textAnchor="middle" dominantBaseline="middle"
                  fontSize={12} fill="rgba(255,255,255,0.70)">
                  ·
                </text>
              </g>
            )}
            {interactive && !canDot && !selected && (
              <text x={cx} y={cy} textAnchor="middle" dominantBaseline="middle"
                fontSize={7} fill="rgba(255,255,255,0.30)"
                style={{ pointerEvents: "none" }}>
                tap zone
              </text>
            )}
          </svg>
        </div>
      </div>

      {/* Legend */}
      {interactive && (
        <div className="flex items-center justify-center gap-5 mt-1.5 text-[10px] text-muted-foreground">
          <span className="flex items-center gap-1.5">
            <svg width="24" height="8">
              <rect x="0" y="1" width="24" height="6" rx="2" fill="#255c2c" />
              <line x1="0" y1="4" x2="24" y2="4" stroke="rgba(255,255,255,0.3)" strokeWidth="0.5" strokeDasharray="3 2" />
            </svg>
            Infield (30y)
          </span>
          <span className="flex items-center gap-1.5">
            <svg width="24" height="8">
              <rect x="0" y="1" width="24" height="6" rx="2" fill="#163d1b" />
            </svg>
            Outfield
          </span>
          {canDot && (
            <span className="flex items-center gap-1.5">
              <span className="w-4 h-4 rounded-full border border-white/30 flex items-center justify-center text-[9px] text-white/50">·</span>
              Tap centre = Dot
            </span>
          )}
        </div>
      )}
    </div>
  );
}

// ─── Shared BallBubble ────────────────────────────────────────────────────────

function BallBubble({
  outcome,
  runs,
  extras,
  isWicket,
  size = "md",
}: {
  outcome: string;
  runs: number;
  extras: number;
  isWicket: boolean;
  size?: "sm" | "md";
}) {
  const label = isWicket
    ? "W"
    : outcome === "WIDE"
      ? "Wd"
      : outcome === "NO_BALL"
        ? "NB"
        : outcome === "BYE"
          ? "B"
          : outcome === "LEG_BYE"
            ? "LB"
            : runs === 0
              ? "·"
              : String(runs);
  const color = isWicket
    ? "bg-red-100 text-red-700 border-red-200"
    : outcome === "SIX"
      ? "bg-emerald-100 text-emerald-700 border-emerald-200"
      : outcome === "FOUR"
        ? "bg-emerald-50 text-emerald-600 border-emerald-100"
        : ["WIDE", "NO_BALL", "BYE", "LEG_BYE"].includes(outcome)
          ? "bg-orange-50 text-orange-600 border-orange-100"
          : runs === 0
            ? "bg-muted/50 text-muted-foreground border-transparent"
            : "bg-muted text-foreground border-transparent";
  const sz = size === "sm" ? "w-6 h-6 text-[9px]" : "w-8 h-8 text-[11px]";
  return (
    <span
      className={`inline-flex items-center justify-center rounded-full font-bold border ${sz} ${color}`}
    >
      {label}
    </span>
  );
}

// ─── OverDots ─────────────────────────────────────────────────────────────────

function OverDots({
  balls,
}: {
  balls: { outcome: string; runs: number; extras: number; isWicket: boolean }[];
}) {
  // Legal balls fill positions 0-5. Extras appear as extra dots.
  const legal = balls.filter(
    (b) => b.outcome !== "WIDE" && b.outcome !== "NO_BALL",
  );
  const extras = balls.filter(
    (b) => b.outcome === "WIDE" || b.outcome === "NO_BALL",
  );

  function dotColor(b: (typeof balls)[0]) {
    if (b.isWicket) return "bg-red-500 text-white border-red-600";
    if (b.outcome === "SIX")
      return "bg-emerald-500 text-white border-emerald-600";
    if (b.outcome === "FOUR")
      return "bg-emerald-400 text-white border-emerald-500";
    if (b.outcome === "WIDE" || b.outcome === "NO_BALL")
      return "bg-orange-400 text-white border-orange-500";
    if (b.runs > 0)
      return "bg-muted-foreground/20 text-foreground border-muted-foreground/30";
    return "border-muted-foreground/30 text-muted-foreground/50";
  }

  function dotLabel(b: (typeof balls)[0]) {
    if (b.isWicket) return "W";
    if (b.outcome === "SIX") return "6";
    if (b.outcome === "FOUR") return "4";
    if (b.outcome === "WIDE") return "Wd";
    if (b.outcome === "NO_BALL") return "NB";
    if (b.runs > 0) return String(b.runs);
    return "·";
  }

  return (
    <div className="flex items-center gap-1.5">
      {Array.from({ length: 6 }).map((_, i) => {
        const b = legal[i];
        return (
          <span
            key={i}
            className={`inline-flex items-center justify-center w-8 h-8 rounded-full border-2 text-[10px] font-bold transition-all ${
              b
                ? dotColor(b)
                : "border-dashed border-muted-foreground/20 text-transparent"
            }`}
          >
            {b ? dotLabel(b) : "·"}
          </span>
        );
      })}
      {/* Extra dots for wides/no-balls beyond the 6 */}
      {extras.map((b, i) => (
        <span
          key={`x${i}`}
          className={`inline-flex items-center justify-center w-7 h-7 rounded-full border text-[9px] font-bold ${dotColor(b)}`}
        >
          {dotLabel(b)}
        </span>
      ))}
    </div>
  );
}

// ─── BatterStrip ─────────────────────────────────────────────────────────────

function BatterStrip({
  players,
  strikerId,
  nonStrikerId,
  allBalls,
  onEditStriker,
  onEditNonStriker,
  onSwap,
}: {
  players: MatchPlayer[];
  strikerId: string | null;
  nonStrikerId: string | null;
  allBalls: { batterId: string; outcome: string; runs: number }[];
  onEditStriker: () => void;
  onEditNonStriker: () => void;
  onSwap?: () => void;
}) {
  function stats(id: string | null) {
    if (!id) return { runs: 0, balls: 0, sr: 0 };
    const mine = allBalls.filter((b) => b.batterId === id);
    const runs = mine.reduce((s, b) => s + b.runs, 0);
    const balls = mine.filter(
      (b) => !["WIDE", "NO_BALL"].includes(b.outcome),
    ).length;
    return {
      runs,
      balls,
      sr: balls > 0 ? Math.round((runs / balls) * 100) : 0,
    };
  }

  function playerName(id: string | null) {
    if (!id) return null;
    return players.find((p) => p.profileId === id)?.name ?? "?";
  }

  const strikerStats = stats(strikerId);
  const nonStrikerStats = stats(nonStrikerId);

  return (
    <div className="relative">
      <div className="grid grid-cols-2 gap-2">
      {[
        {
          id: strikerId,
          name: playerName(strikerId),
          s: strikerStats,
          isStriker: true,
          onEdit: onEditStriker,
        },
        {
          id: nonStrikerId,
          name: playerName(nonStrikerId),
          s: nonStrikerStats,
          isStriker: false,
          onEdit: onEditNonStriker,
        },
      ].map(({ id, name, s, isStriker, onEdit }) => (
        <div
          key={isStriker ? "s" : "ns"}
          className={`rounded-xl border px-3 py-2.5 transition-colors ${isStriker ? "bg-primary/5 border-primary/30" : ""}`}
        >
          <div className="flex items-center gap-1 mb-0.5">
            {isStriker && (
              <span className="text-[10px] text-primary font-black">★</span>
            )}
            <p
              className={`text-sm font-semibold truncate flex-1 ${!name ? "text-muted-foreground italic text-xs" : ""}`}
            >
              {name ?? (isStriker ? "Striker" : "Non-Striker")}
            </p>
            <button
              onClick={onEdit}
              className="ml-1 text-muted-foreground/50 hover:text-muted-foreground p-0.5 rounded transition-colors"
              title={`Change ${isStriker ? "striker" : "non-striker"}`}
            >
              <svg
                width="11"
                height="11"
                viewBox="0 0 12 12"
                fill="none"
                stroke="currentColor"
                strokeWidth="1.5"
                strokeLinecap="round"
                strokeLinejoin="round"
              >
                <path d="M8.5 1.5a1.414 1.414 0 0 1 2 2L3.5 10.5 1 11l.5-2.5z" />
              </svg>
            </button>
          </div>
          {id && (
            <div className="flex items-center gap-2 text-xs text-muted-foreground">
              <span className="font-bold text-foreground">{s.runs}</span>
              <span className="text-muted-foreground/60">({s.balls})</span>
              <span className="ml-auto text-[10px]">SR {s.sr}</span>
            </div>
          )}
        </div>
      ))}
      </div>
      {onSwap && strikerId && nonStrikerId && (
        <button
          onClick={onSwap}
          className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 z-10 w-7 h-7 rounded-full bg-background border shadow-sm flex items-center justify-center text-xs font-bold text-muted-foreground hover:text-foreground hover:border-primary transition-colors"
          title="Swap strike"
        >
          ⇄
        </button>
      )}
    </div>
  );
}

// ─── Non-dismissible selection sheets ────────────────────────────────────────

function SelectionSheet({
  title,
  subtitle,
  players,
  onSelect,
  dismissible,
  onDismiss,
  wicketKeeperPlayer,
  onWicketKeeperClick,
}: {
  title: string;
  subtitle?: string;
  players: MatchPlayer[];
  onSelect: (p: MatchPlayer) => void;
  dismissible?: boolean;
  onDismiss?: () => void;
  /** The current WK — shown disabled with a note; clicking opens the change-WK dialog */
  wicketKeeperPlayer?: MatchPlayer;
  onWicketKeeperClick?: () => void;
}) {
  // Merge WK into the list if they're not already there (e.g. filtered out by lastBowler)
  const allPlayers =
    wicketKeeperPlayer &&
    !players.find((p) => p.profileId === wicketKeeperPlayer.profileId)
      ? [...players, wicketKeeperPlayer]
      : players;

  return (
    <Dialog
      open
      modal
      onOpenChange={
        dismissible
          ? (open) => {
              if (!open) onDismiss?.();
            }
          : undefined
      }
    >
      <DialogContent
        className={`max-w-sm ${dismissible ? "" : "[&>button:last-child]:hidden"}`}
        onPointerDownOutside={
          dismissible ? undefined : (e) => e.preventDefault()
        }
        onEscapeKeyDown={dismissible ? undefined : (e) => e.preventDefault()}
      >
        <DialogHeader>
          <DialogTitle>{title}</DialogTitle>
          {subtitle && (
            <p className="text-xs text-muted-foreground">{subtitle}</p>
          )}
        </DialogHeader>
        <div className="max-h-72 overflow-y-auto divide-y py-1">
          {allPlayers.map((p) => {
            const isWk = wicketKeeperPlayer?.profileId === p.profileId;
            return (
              <button
                key={p.profileId}
                onClick={() => (isWk ? onWicketKeeperClick?.() : onSelect(p))}
                className={`w-full text-left px-3 py-3 transition-colors text-sm font-medium flex items-center justify-between ${isWk ? "text-muted-foreground hover:bg-amber-50 dark:hover:bg-amber-950/20" : "hover:bg-muted"}`}
              >
                <span>{p.name}</span>
                {isWk && (
                  <span className="text-[11px] text-amber-600 font-semibold shrink-0 ml-2">
                    WK — change keeper first
                  </span>
                )}
              </button>
            );
          })}
          {allPlayers.length === 0 && (
            <p className="px-3 py-6 text-sm text-center text-muted-foreground">
              No players available
            </p>
          )}
        </div>
      </DialogContent>
    </Dialog>
  );
}

// ─── WicketSheet — multi-step ─────────────────────────────────────────────────

function WicketSheet({
  open,
  onClose,
  striker,
  nonStriker,
  fielders,
  isFreeHit,
  wicketKeeperId,
  onConfirm,
}: {
  open: boolean;
  onClose: () => void;
  striker: MatchPlayer | null;
  nonStriker: MatchPlayer | null;
  fielders: MatchPlayer[];
  isFreeHit: boolean;
  wicketKeeperId?: string;
  onConfirm: (data: {
    dismissalType: DismissalType;
    dismissedId: string;
    fielderId?: string;
    runs: number;
    isRetiredHurt: boolean;
    isSubstituteFielder?: boolean;
    switchEnds?: boolean;
  }) => void;
}) {
  const [step, setStep] = useState<1 | 2 | 3>(1);
  const [type, setType] = useState<DismissalType>("BOWLED");
  const [dismissed, setDismissed] = useState(striker?.profileId ?? "");
  const [fielder, setFielder] = useState("");
  const [runs, setRuns] = useState(0);
  const [isSubFielder, setIsSubFielder] = useState(false);
  const [switchEnds, setSwitchEnds] = useState(false);

  useEffect(() => {
    if (open) {
      setStep(1);
      setType("BOWLED");
      setFielder("");
      setRuns(0);
      setIsSubFielder(false);
      setSwitchEnds(false);
    }
  }, [open]);
  useEffect(() => {
    if (striker) setDismissed(striker.profileId);
  }, [striker]);

  // On free hit, only allow run-out and obstructing
  const validDismissals = isFreeHit
    ? DISMISSALS.filter((d) => FREE_HIT_DISMISSALS.includes(d.v))
    : DISMISSALS;

  const needsFielder = ["CAUGHT", "RUN_OUT"].includes(type);
  const isStumped = type === "STUMPED";
  const isRetiredHurt = type === "RETIRED_HURT";

  function handleNext() {
    // For STUMPED, auto-select the keeper and skip the fielder step
    if (step === 1 && isStumped) {
      if (wicketKeeperId) setFielder(wicketKeeperId);
      setStep(3);
      return;
    }
    setStep((s) => (s + 1) as 1 | 2 | 3);
  }

  function handleConfirm() {
    onConfirm({
      dismissalType: type,
      dismissedId: dismissed,
      fielderId: fielder || undefined,
      runs,
      isRetiredHurt,
      isSubstituteFielder: isSubFielder || undefined,
      switchEnds: switchEnds || undefined,
    });
  }

  return (
    <Dialog open={open} onOpenChange={(o) => !o && onClose()}>
      <DialogContent className="max-w-sm">
        <DialogHeader>
          <DialogTitle className="flex items-center gap-2">
            Wicket
            {isFreeHit && (
              <span className="text-[10px] bg-yellow-400 text-yellow-900 font-black px-2 py-0.5 rounded-full">
                FREE HIT
              </span>
            )}
            <span className="text-xs text-muted-foreground font-normal ml-auto">
              Step {isStumped ? (step === 3 ? 2 : 1) : step}/{isStumped ? 2 : 3}
            </span>
          </DialogTitle>
        </DialogHeader>

        {step === 1 && (
          <div className="space-y-3 py-1">
            <p className="text-xs font-medium text-muted-foreground">
              How out?
            </p>
            <div className="grid grid-cols-4 gap-1.5">
              {validDismissals.map((d) => (
                <button
                  key={d.v}
                  onClick={() => setType(d.v)}
                  className={`py-2.5 rounded-lg border text-xs font-semibold transition-colors ${type === d.v ? "bg-destructive text-destructive-foreground border-destructive" : "hover:bg-muted"}`}
                >
                  {d.l}
                </button>
              ))}
            </div>
            {[striker, nonStriker].filter(Boolean).length > 1 && (
              <div className="space-y-1.5">
                <p className="text-xs font-medium text-muted-foreground">
                  Batter out
                </p>
                <div className="flex rounded-lg border overflow-hidden">
                  {[striker, nonStriker].filter(Boolean).map(
                    (p) =>
                      p && (
                        <button
                          key={p.profileId}
                          onClick={() => setDismissed(p.profileId)}
                          className={`flex-1 py-2 text-sm font-medium transition-colors ${dismissed === p.profileId ? "bg-primary text-primary-foreground" : "hover:bg-muted"}`}
                        >
                          {p.name}
                        </button>
                      ),
                  )}
                </div>
              </div>
            )}
          </div>
        )}

        {step === 2 && (
          <div className="space-y-3 py-1">
            {needsFielder && (
              <div className="space-y-1.5">
                <p className="text-xs font-medium text-muted-foreground">
                  {type === "CAUGHT"
                    ? "Caught by"
                    : type === "STUMPED"
                      ? "Stumped by"
                      : "Run out (fielder)"}
                </p>
                <Select
                  value={fielder || "NONE"}
                  onValueChange={(v) => setFielder(v === "NONE" ? "" : v)}
                >
                  <SelectTrigger>
                    <SelectValue placeholder="Select fielder" />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="NONE">None / Unknown</SelectItem>
                    {fielders.map((p) => (
                      <SelectItem key={p.profileId} value={p.profileId}>
                        {p.name}
                      </SelectItem>
                    ))}
                  </SelectContent>
                </Select>
              </div>
            )}
              {(type === "CAUGHT" || type === "RUN_OUT") && (
                <label className="flex items-center gap-2 mt-1 cursor-pointer">
                  <input
                    type="checkbox"
                    checked={isSubFielder}
                    onChange={(e) => setIsSubFielder(e.target.checked)}
                    className="rounded accent-primary"
                  />
                  <span className="text-xs text-muted-foreground">
                    Substitute fielder
                  </span>
                </label>
              )}
            {isRetiredHurt && (
              <p className="text-sm text-muted-foreground bg-muted/30 rounded-lg p-3">
                Retired hurt is <strong>not</strong> a wicket. The batter will
                be removed but wickets will not increment. They may return
                later.
              </p>
            )}
            {!needsFielder && !isRetiredHurt && (
              <p className="text-sm text-muted-foreground">
                No additional details needed for {type.replace(/_/g, " ")}.
              </p>
            )}
          </div>
        )}

        {step === 3 && (
          <div className="space-y-3 py-1">
            <p className="text-xs font-medium text-muted-foreground">
              Runs completed before dismissal (0 for most wickets)
            </p>
            <div className="flex gap-2">
              {[0, 1, 2, 3].map((r) => (
                <button
                  key={r}
                  onClick={() => setRuns(r)}
                  className={`w-12 h-12 rounded-xl border-2 text-lg font-bold transition-colors ${runs === r ? "bg-primary text-primary-foreground border-primary" : "hover:bg-muted border-border"}`}
                >
                  {r}
                </button>
              ))}
            </div>
              {type === "RUN_OUT" && (
                <label className="flex items-center gap-2 mt-2 cursor-pointer">
                  <input
                    type="checkbox"
                    checked={switchEnds}
                    onChange={(e) => setSwitchEnds(e.target.checked)}
                    className="rounded accent-primary"
                  />
                  <span className="text-xs text-muted-foreground">
                    Switch ends (remaining batter crosses)
                  </span>
                </label>
              )}
          </div>
        )}

        <DialogFooter>
          {step > 1 && (
            <Button
              variant="outline"
              onClick={() => {
                // If on step 3 and STUMPED (step 2 was skipped), go back to step 1
                if (step === 3 && isStumped) {
                  setStep(1);
                } else {
                  setStep((s) => (s - 1) as 1 | 2 | 3);
                }
              }}
            >
              Back
            </Button>
          )}
          {step < 3 && <Button onClick={handleNext}>Next →</Button>}
          {step === 3 && (
            <Button variant="destructive" onClick={handleConfirm}>
              Confirm Wicket
            </Button>
          )}
        </DialogFooter>
      </DialogContent>
    </Dialog>
  );
}

// ─── NoBallSheet ──────────────────────────────────────────────────────────────

function NoBallSheet({
  open,
  onClose,
  onConfirm,
}: {
  open: boolean;
  onClose: () => void;
  onConfirm: (data: { runsType: "bat" | "bye" | "none"; runs: number }) => void;
}) {
  const [runsType, setRunsType] = useState<"bat" | "bye" | "none">("none");
  const [runs, setRuns] = useState(1);

  useEffect(() => {
    if (open) {
      setRunsType("none");
      setRuns(1);
    }
  }, [open]);

  return (
    <Dialog open={open} onOpenChange={(o) => !o && onClose()}>
      <DialogContent className="max-w-xs">
        <DialogHeader>
          <DialogTitle>No Ball — How scored?</DialogTitle>
        </DialogHeader>
        <div className="space-y-4 py-1">
          <div className="grid grid-cols-3 gap-2">
            {[
              { v: "bat" as const, l: "Off Bat" },
              { v: "bye" as const, l: "Bye" },
              { v: "none" as const, l: "No Run" },
            ].map(({ v, l }) => (
              <button
                key={v}
                onClick={() => setRunsType(v)}
                className={`py-2.5 rounded-xl border text-sm font-semibold transition-colors ${runsType === v ? "bg-primary text-primary-foreground" : "hover:bg-muted"}`}
              >
                {l}
              </button>
            ))}
          </div>
          {runsType !== "none" && (
            <div className="space-y-1.5">
              <p className="text-xs text-muted-foreground font-medium">Runs</p>
              <div className="grid grid-cols-5 gap-1.5">
                {[1, 2, 3, 4, 6].map((r) => (
                  <button
                    key={r}
                    onClick={() => setRuns(r)}
                    className={`h-10 rounded-lg border font-bold text-sm transition-colors ${runs === r ? "bg-primary text-primary-foreground" : "hover:bg-muted"}`}
                  >
                    {r}
                  </button>
                ))}
              </div>
            </div>
          )}
        </div>
        <DialogFooter>
          <Button variant="outline" onClick={onClose}>
            Cancel
          </Button>
          <Button
            onClick={() =>
              onConfirm({ runsType, runs: runsType === "none" ? 0 : runs })
            }
          >
            Record NB
          </Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  );
}

// ─── WideRunsSheet ────────────────────────────────────────────────────────────

function WideRunsSheet({
  open,
  onClose,
  onConfirm,
}: {
  open: boolean;
  onClose: () => void;
  onConfirm: (runs: number) => void;
}) {
  const [runs, setRuns] = useState(0);
  useEffect(() => {
    if (open) setRuns(0);
  }, [open]);

  return (
    <Dialog open={open} onOpenChange={(o) => !o && onClose()}>
      <DialogContent className="max-w-xs">
        <DialogHeader>
          <DialogTitle>Wide — Extra Runs?</DialogTitle>
        </DialogHeader>
        <div className="space-y-3 py-1">
          <p className="text-xs text-muted-foreground">
            Select additional runs scored off the wide (0 = just the 1 wide).
          </p>
          <div className="grid grid-cols-5 gap-1.5">
            {[0, 1, 2, 3, 4].map((r) => (
              <button
                key={r}
                onClick={() => setRuns(r)}
                className={`h-10 rounded-lg border font-bold text-sm transition-colors ${runs === r ? "bg-primary text-primary-foreground" : "hover:bg-muted"}`}
              >
                {r}
              </button>
            ))}
          </div>
        </div>
        <DialogFooter>
          <Button variant="outline" onClick={onClose}>
            Cancel
          </Button>
          <Button onClick={() => onConfirm(runs)}>Record Wd</Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  );
}

// ─── ByeRunsSheet ─────────────────────────────────────────────────────────────

function ByeRunsSheet({
  open,
  type,
  onClose,
  onConfirm,
}: {
  open: boolean;
  type: "bye" | "legBye";
  onClose: () => void;
  onConfirm: (runs: number) => void;
}) {
  const [runs, setRuns] = useState(1);
  useEffect(() => {
    if (open) setRuns(1);
  }, [open]);
  const label = type === "bye" ? "Bye" : "Leg Bye";
  return (
    <Dialog open={open} onOpenChange={(o) => !o && onClose()}>
      <DialogContent className="max-w-xs">
        <DialogHeader>
          <DialogTitle>{label} — How many runs?</DialogTitle>
        </DialogHeader>
        <div className="grid grid-cols-5 gap-1.5 py-2">
          {[1, 2, 3, 4, 5].map((r) => (
            <button
              key={r}
              onClick={() => setRuns(r)}
              className={`h-12 rounded-lg border font-bold text-lg transition-colors ${runs === r ? "bg-primary text-primary-foreground" : "hover:bg-muted"}`}
            >
              {r}
            </button>
          ))}
        </div>
        <DialogFooter>
          <Button variant="outline" onClick={onClose}>
            Cancel
          </Button>
          <Button onClick={() => onConfirm(runs)}>Record {label}</Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  );
}

// ─── ScoreHeader ──────────────────────────────────────────────────────────────

function ScoreHeader({
  matchId,
  maxOvers,
  ppOvers,
}: {
  matchId: string;
  maxOvers: number;
  ppOvers: number;
}) {
  const { data: match } = useMatchDetailQuery(matchId);
  const { data: players } = useMatchPlayersQuery(matchId);
  const store = useScoringStore();

  if (!match) return null;
  const activeInnings = match.innings.find((i) => !i.isCompleted);
  const inn1 = match.innings.find((i) => i.inningsNumber === 1);
  if (!activeInnings) return null;

  const allBalls = activeInnings.ballEvents ?? [];
  const legalCount = allBalls.filter(
    (b) => !["WIDE", "NO_BALL"].includes(b.outcome),
  ).length;
  const overNum = Math.floor(legalCount / 6);
  const ballInOver = legalCount % 6;

  // ICC fielding restriction phases
  function getPPLabel(fmt: string | undefined, over: number): string {
    if (fmt === "ONE_DAY") {
      // ODI: 3 phases across all 50 overs
      if (over < 10) return "P1"; // 2 fielders outside 30-yard circle
      if (over < 40) return "P2"; // 4 fielders outside
      return "P3"; // 5 fielders outside (overs 41-50)
    }
    // T20 (6), T10 (3), custom, etc. — use ppOvers from setup
    if (ppOvers > 0 && over < ppOvers) return "PP";
    return "";
  }
  const ppLabel = getPPLabel(match?.format, overNum);
  const inPP = ppLabel !== "";

  // Bowler current over figures
  const allP = [
    ...(players?.teamA.players ?? []),
    ...(players?.teamB.players ?? []),
  ];
  const currentBowler = allP.find((p) => p.profileId === store.currentBowlerId);
  let bowlerLine = "";
  if (currentBowler) {
    const bBalls = allBalls.filter((b) => b.bowlerId === store.currentBowlerId);
    const bLegal = bBalls.filter(
      (b) => !["WIDE", "NO_BALL"].includes(b.outcome),
    ).length;
    const bRuns = bBalls.reduce((s, b) => s + b.runs + b.extras, 0);
    const bWkts = bBalls.filter((b) => b.isWicket).length;
    bowlerLine = `${currentBowler.name.split(" ")[0]}  ${fmtOvers(bLegal / 6)}-0-${bRuns}-${bWkts}`;
  }

  // Innings 2 target line
  let targetLine = "";
  if (activeInnings.inningsNumber === 2 && inn1) {
    const target = inn1.totalRuns + 1;
    const needed = target - activeInnings.totalRuns;
    const ballsLeft = maxOvers * 6 - legalCount;
    const rrrPerOver =
      ballsLeft > 0 ? (needed / (ballsLeft / 6)).toFixed(1) : "—";
    if (needed > 0) {
      targetLine = `Target ${target}  |  Need ${needed} off ${ballsLeft} balls  |  RRR ${rrrPerOver}`;
    } else {
      targetLine = "Won!";
    }
  }

  const teamName =
    activeInnings.battingTeam === "A" ? match.teamAName : match.teamBName;

  return (
    <div className="rounded-xl border bg-card px-4 py-3 space-y-2">
      <div className="flex items-start justify-between">
        <div>
          <div className="flex items-baseline gap-2">
            <p className="text-4xl font-black tracking-tight">
              {activeInnings.totalRuns}
              <span className="text-muted-foreground text-2xl font-normal">
                /{activeInnings.totalWickets}
              </span>
            </p>
            <p className="text-sm text-muted-foreground">
              ({fmtOvers(activeInnings.totalOvers)} ov)
            </p>
            {inPP && (
              <span className="text-[10px] font-bold bg-blue-100 text-blue-700 px-1.5 py-0.5 rounded">
                {ppLabel}
              </span>
            )}
          </div>
          <p className="text-xs text-muted-foreground mt-0.5">{teamName}</p>
        </div>
        <div className="text-right text-xs text-muted-foreground space-y-0.5">
          {maxOvers > 0 && (() => {
            const ballsLeft = Math.max(0, maxOvers * 6 - legalCount);
            const ovsLeft = Math.floor(ballsLeft / 6);
            const ballsInOv = ballsLeft % 6;
            const label = ballsLeft === 0 ? 'Last over' : ovsLeft === 0 ? `${ballsInOv} ball${ballsInOv !== 1 ? 's' : ''} left` : ballsInOv === 0 ? `${ovsLeft} ov left` : `${ovsLeft}.${ballsInOv} ov left`;
            return <p>{label}</p>;
          })()}
          <p>{activeInnings.extras} extras</p>
        </div>
      </div>
      {(bowlerLine || targetLine) && (
        <p
          className={`text-xs font-medium px-2 py-1.5 rounded-lg ${targetLine ? "bg-amber-50 text-amber-800" : "bg-muted/50 text-muted-foreground font-mono"}`}
        >
          {targetLine || bowlerLine}
        </p>
      )}
    </div>
  );
}

// ─── DLS (Duckworth-Lewis-Stern) ──────────────────────────────────────────────

// Standard Edition parameters: Z0(w) and b(w) for w = 0..9 wickets
const DLS_Z0 = [100.0, 88.4, 76.1, 62.8, 48.0, 33.4, 19.8, 9.8, 3.7, 0.5];
const DLS_B = [
  0.0765, 0.0714, 0.0643, 0.0538, 0.0407, 0.0257, 0.0141, 0.0072, 0.0031,
  0.0008,
];

/** Resource % available to a team with `overs` remaining and `wickets` lost */
function dlsResource(overs: number, wickets: number): number {
  const w = Math.min(Math.max(wickets, 0), 9);
  return DLS_Z0[w] * (1 - Math.exp(-DLS_B[w] * overs));
}

/** Compute DLS target for team 2 */
function dlsComputeTarget(
  team1Score: number,
  team1Overs: number, // overs available to team 1 (not interrupted = maxOvers)
  team2Overs: number, // revised overs for team 2
  team2WicketsFallen = 0, // wickets at time of interruption (for mid-innings DLS)
  team2OversPlayed = 0, // overs played by team 2 before interruption
): number {
  const R1 = dlsResource(team1Overs, 0); // Team 1 full resource
  // Team 2 resource: from start OR remaining after interruption
  const R2_remaining = dlsResource(
    team2Overs - team2OversPlayed,
    team2WicketsFallen,
  );
  const R2_lost =
    dlsResource(team2OversPlayed, 0) -
    dlsResource(team2OversPlayed, team2WicketsFallen);
  const R2 = Math.max(0, R2_remaining - R2_lost + R2_remaining);
  // Simplified: just use straight-line reduction for common case (no wickets yet)
  const R2_simple = dlsResource(team2Overs, 0);
  const target = Math.round(team1Score * (R2_simple / R1)) + 1;
  return Math.max(target, 1);
}

function DlsDialog({
  open,
  onClose,
  maxOvers,
  match,
  currentInningsNum,
  onApply,
}: {
  open: boolean;
  onClose: () => void;
  maxOvers: number;
  match: any;
  currentInningsNum: number;
  onApply: (target: number, revisedOvers: number) => void;
}) {
  const [revisedOvers, setRevisedOvers] = useState(maxOvers);
  const [team2Wickets, setTeam2Wickets] = useState(0);
  const [team2OversPlayed, setTeam2OversPlayed] = useState(0);
  const [manualTarget, setManualTarget] = useState<number | null>(null);

  // Team 1 score (from first innings for a 2nd innings DLS scenario)
  const inn1 = match?.innings?.find((i: any) => i.inningsNumber === 1);
  const team1Score = inn1?.totalRuns ?? 0;
  const team1Overs = maxOvers;

  const dlsTarget =
    manualTarget ??
    dlsComputeTarget(
      team1Score,
      team1Overs,
      revisedOvers,
      team2Wickets,
      team2OversPlayed,
    );

  useEffect(() => {
    setRevisedOvers(maxOvers);
  }, [maxOvers]);

  if (!open) return null;
  return (
    <Dialog open onOpenChange={(o) => !o && onClose()}>
      <DialogContent className="max-w-sm">
        <DialogHeader>
          <DialogTitle>DLS / Reduced Overs</DialogTitle>
          <p className="text-xs text-muted-foreground">
            Apply Duckworth-Lewis-Stern method when overs are interrupted or
            reduced.
          </p>
        </DialogHeader>
        <div className="space-y-4 py-1">
          {/* Team 1 reference */}
          {currentInningsNum === 2 && (
            <div className="rounded-lg border bg-muted/20 px-3 py-2 text-xs space-y-0.5">
              <p className="font-semibold text-muted-foreground uppercase tracking-wide text-[10px]">
                Team 1 Score
              </p>
              <p className="font-bold text-base">
                {team1Score}{" "}
                <span className="text-muted-foreground font-normal">
                  in {team1Overs} overs
                </span>
              </p>
            </div>
          )}

          {/* Revised overs for team 2 */}
          <div className="space-y-1.5">
            <label className="text-xs font-semibold">
              Revised Overs (Team 2)
            </label>
            <div className="flex items-center gap-2">
              <button
                onClick={() => setRevisedOvers((o) => Math.max(1, o - 1))}
                className="w-8 h-8 rounded-lg border flex items-center justify-center font-bold text-lg hover:bg-muted"
              >
                −
              </button>
              <input
                type="number"
                min={1}
                max={maxOvers}
                value={revisedOvers}
                onChange={(e) =>
                  setRevisedOvers(
                    Math.max(1, Math.min(maxOvers, Number(e.target.value))),
                  )
                }
                className="flex-1 h-8 border rounded-lg text-center text-sm font-bold"
              />
              <button
                onClick={() =>
                  setRevisedOvers((o) => Math.min(maxOvers, o + 1))
                }
                className="w-8 h-8 rounded-lg border flex items-center justify-center font-bold text-lg hover:bg-muted"
              >
                +
              </button>
            </div>
          </div>

          {/* Mid-innings interruption (optional) */}
          {currentInningsNum === 2 && (
            <div className="grid grid-cols-2 gap-3">
              <div className="space-y-1.5">
                <label className="text-xs font-semibold">
                  Wickets at interruption
                </label>
                <input
                  type="number"
                  min={0}
                  max={9}
                  value={team2Wickets}
                  onChange={(e) =>
                    setTeam2Wickets(
                      Math.max(0, Math.min(9, Number(e.target.value))),
                    )
                  }
                  className="w-full h-8 border rounded-lg text-center text-sm"
                />
              </div>
              <div className="space-y-1.5">
                <label className="text-xs font-semibold">Overs played</label>
                <input
                  type="number"
                  min={0}
                  max={maxOvers}
                  value={team2OversPlayed}
                  onChange={(e) =>
                    setTeam2OversPlayed(
                      Math.max(0, Math.min(maxOvers, Number(e.target.value))),
                    )
                  }
                  className="w-full h-8 border rounded-lg text-center text-sm"
                />
              </div>
            </div>
          )}

          {/* Computed target */}
          <div className="rounded-lg border-2 border-blue-200 bg-blue-50 px-4 py-3 flex items-center justify-between">
            <div>
              <p className="text-[10px] uppercase font-bold text-blue-600 tracking-widest">
                DLS Target
              </p>
              <p className="text-2xl font-black text-blue-900">{dlsTarget}</p>
            </div>
            <div className="text-right text-xs text-blue-600 space-y-0.5">
              <p>Revised: {revisedOvers} overs</p>
              {currentInningsNum === 2 && <p>Need {dlsTarget} to win</p>}
            </div>
          </div>

          {/* Manual override */}
          <div className="space-y-1.5">
            <label className="text-xs font-semibold text-muted-foreground">
              Manual target override (optional)
            </label>
            <input
              type="number"
              min={1}
              placeholder="Leave blank to use computed"
              value={manualTarget ?? ""}
              onChange={(e) =>
                setManualTarget(e.target.value ? Number(e.target.value) : null)
              }
              className="w-full h-8 border rounded-lg text-center text-sm"
            />
          </div>
        </div>
        <DialogFooter>
          <Button variant="outline" onClick={onClose}>
            Cancel
          </Button>
          <Button onClick={() => onApply(dlsTarget, revisedOvers)}>
            Apply DLS
          </Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  );
}

// ─── Match Completed State ────────────────────────────────────────────────────

function MatchCompletedState({
  match,
  matchId,
}: {
  match: MatchDetail | null | undefined;
  matchId: string;
}) {
  const reopen = useReopenInningsMutation();
  const enforceFollowOn = useEnforceFollowOnMutation();
  const startSuperOver = useStartSuperOverMutation();
  const continueInnings = useContinueInningsMutation();

  if (!match) {
    return (
      <div className="py-16 text-center text-sm text-muted-foreground">
        Start the match from Setup tab.
      </div>
    );
  }

  // Between innings in a multi-innings match (status still IN_PROGRESS)
  const isMultiInnings = ["TWO_INNINGS", "TEST"].includes(match.format ?? "");
  const sortedInnings = [...(match.innings ?? [])].sort(
    (a, b) => b.inningsNumber - a.inningsNumber,
  );
  const lastInnings = sortedInnings[0];

  if (match.status === "IN_PROGRESS" && isMultiInnings) {
    const completedCount = (match.innings ?? []).filter((i) => i.isCompleted).length;
    const totalInnings = (match.innings ?? []).length;
    // Between innings: all innings so far are completed, waiting for next
    const allComplete = completedCount === totalInnings && totalInnings > 0;
    const inn2 = (match.innings ?? []).find((i) => i.inningsNumber === 2);
    const inn3 = (match.innings ?? []).find((i) => i.inningsNumber === 3);
    const followOnAvailable =
      allComplete && completedCount === 2 && !inn3 &&
      inn2?.isCompleted &&
      (() => {
        const inn1 = (match.innings ?? []).find((i) => i.inningsNumber === 1);
        if (!inn1 || !inn2) return false;
        const threshold = match.format === "TEST" ? 200 : 150;
        return inn1.totalRuns - inn2.totalRuns >= threshold;
      })();

    if (allComplete) {
      return (
        <div className="py-16 flex flex-col items-center gap-4 text-center">
          <p className="text-sm font-medium">
            Innings {completedCount} complete.
          </p>
          {followOnAvailable && (
            <p className="text-xs text-muted-foreground">
              Follow-on available (deficit: {(() => {
                const inn1 = (match.innings ?? []).find((i) => i.inningsNumber === 1);
                return inn1 && inn2 ? inn1.totalRuns - inn2.totalRuns : 0;
              })()} runs)
            </p>
          )}
          <div className="flex gap-2 flex-wrap justify-center">
            {followOnAvailable && (
              <Button
                size="sm"
                disabled={enforceFollowOn.isPending}
                onClick={() => enforceFollowOn.mutate(matchId)}
              >
                Enforce Follow-On
              </Button>
            )}
            <Button
              variant="outline"
              size="sm"
              disabled={continueInnings.isPending}
              onClick={() => continueInnings.mutate(matchId)}
            >
              Continue Normally →
            </Button>
          </div>
        </div>
      );
    }
  }

  if (match.status !== "COMPLETED") {
    return (
      <div className="py-16 text-center text-sm text-muted-foreground">
        Start the match from Setup tab.
      </div>
    );
  }

  const isTied = match.winMargin === "Tied";

  return (
    <div className="py-16 flex flex-col items-center gap-4 text-center">
      <p className="text-sm font-medium">Match completed.</p>
      {match.winnerId && (
        <p className="text-xs text-muted-foreground">
          Winner: {match.winnerId}
          {match.winMargin ? ` by ${match.winMargin}` : ""}
        </p>
      )}
      {isTied && (
        <p className="text-xs text-muted-foreground">Match tied</p>
      )}
      <div className="flex gap-2 flex-wrap justify-center">
        {isTied && (
          <Button
            size="sm"
            disabled={startSuperOver.isPending}
            onClick={() => startSuperOver.mutate(matchId)}
          >
            Start Super Over
          </Button>
        )}
        {lastInnings && (
          <Button
            variant="outline"
            size="sm"
            disabled={reopen.isPending}
            onClick={() => {
              if (
                confirm("Reopen the last innings and reset match to In Progress?")
              ) {
                reopen.mutate({ matchId, inningsNum: lastInnings.inningsNumber });
              }
            }}
          >
            ↩ Reopen Innings {lastInnings.inningsNumber}
          </Button>
        )}
      </div>
    </div>
  );
}

// ─── Scoring Tab ──────────────────────────────────────────────────────────────

function ScoreTab({
  matchId,
  maxOvers,
  ppOvers,
}: {
  matchId: string;
  maxOvers: number;
  ppOvers: number;
}) {
  const { data: match } = useMatchDetailQuery(matchId);
  const { data: players } = useMatchPlayersQuery(matchId);
  const recordBall = useRecordBallMutation();
  const undoBall = useUndoLastBallMutation();
  const [followOnState, setFollowOnState] = useState<{ deficit: number } | null>(null);
  const enforceFollowOnMut = useEnforceFollowOnMutation();
  const continueInningsMut = useContinueInningsMutation();
  const endInnings = useCompleteInningsMutation((deficit) => {
    setFollowOnState({ deficit });
    toast.success("Innings completed");
  });
  const endOfDay = useEndOfDayMutation();
  const deleteMut = useDeleteMatchMutation();
  const router = useRouter();
  const [deleteOpen, setDeleteOpen] = useState(false);

  const store = useScoringStore();
  const {
    strikerId,
    nonStrikerId,
    currentBowlerId,
    lastBowlerId,
    scoringBlocked,
    activeSheet,
    inSetupFlow,
    init,
    startSetupFlow,
    resetForNewInnings,
    setNonStriker,
    syncFromBackend,
    selectNextBowler,
    selectNewBatter,
    openSheet,
    closeSheet,
    setNewBatterPos,
    swapBatters,
  } = store;

  const [zone, setZone] = useState("");
  const [ready, setReady] = useState(false);
  const [isEditingPlayer, setIsEditingPlayer] = useState(false);
  const [dlsOpen, setDlsOpen] = useState(false);
  const [dlsTarget, setDlsTarget] = useState<number | null>(null);
  const [dlsRevisedOvers, setDlsRevisedOvers] = useState<number | null>(null);
  const [wkChangeOpen, setWkChangeOpen] = useState(false);
  const [wkNewId, setWkNewId] = useState("");
  const changeWk = useChangeWicketKeeperMutation();
  const [overthrowOn, setOverthrowOn] = useState(false);
  const [overthrowRuns, setOverthrowRuns] = useState(0);
  const [pendingDismissedId, setPendingDismissedId] = useState<string | null>(null);

  function editStriker() {
    setIsEditingPlayer(true);
    setNewBatterPos("striker");
    openSheet("newBatter");
  }
  function editNonStriker() {
    setIsEditingPlayer(true);
    setNewBatterPos("nonStriker");
    openSheet("newBatter");
  }
  function editBowler() {
    setIsEditingPlayer(true);
    openSheet("bowler");
  }

  // Init store — wait for match data so backend-persisted striker/bowler is available as fallback.
  // Dep on match?.id ensures this re-runs exactly once when match data first arrives (id doesn't change on refetch).
  useEffect(() => {
    const activeInnings = match?.innings.find((i: any) => !i.isCompleted);
    init(matchId, activeInnings ? {
      strikerId: activeInnings.currentStrikerId ?? null,
      nonStrikerId: activeInnings.currentNonStrikerId ?? null,
      currentBowlerId: activeInnings.currentBowlerId ?? null,
    } : undefined);
    if (match) setReady(true); // only mark ready once we have match data
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [matchId, match?.id]);

  // For innings 1: auto-open setup flow when no balls exist.
  // For innings 2+: wait for explicit "Start Innings" button — don't auto-trigger.
  // After page refresh mid-innings (balls exist but striker gone), just open new batter sheet.
  const lastInningsNumRef = useRef<number | null>(null);
  useEffect(() => {
    if (!ready) return;
    const activeInnings = match?.innings.find((i: any) => !i.isCompleted);
    if (!activeInnings) return;

    // Validate currentBowlerId against the actual bowling team — if stale localStorage
    // pointed to a player from a different team/squad, clear it and re-prompt.
    if (currentBowlerId && players) {
      const bowlingTeamRaw = activeInnings.battingTeam === "A"
        ? (players.teamB?.players ?? [])
        : (players.teamA?.players ?? []);
      const bowlerIsValid = bowlingTeamRaw.some((p: any) => p.profileId === currentBowlerId);
      if (!bowlerIsValid) {
        useScoringStore.getState().syncFromBackend(
          {
            strikerId,
            nonStrikerId,
            currentBowlerId: activeInnings.currentBowlerId ?? null,
          },
          !activeInnings.currentBowlerId, // prompt for bowler if backend also doesn't have one
        );
        return;
      }
    }

    const num = activeInnings.inningsNumber;
    const balls = activeInnings.ballEvents ?? [];
    if (lastInningsNumRef.current !== num && balls.length === 0) {
      lastInningsNumRef.current = num;
      // No auto-trigger for any innings — user clicks "Start Innings" button
      // (prevents unwanted setup re-prompt on page refresh before first ball)
    } else {
      if (lastInningsNumRef.current === null) lastInningsNumRef.current = num;

      const legalBalls = balls.filter(
        (b: any) => !["WIDE", "NO_BALL"].includes(b.outcome),
      ).length;
      const atOverBoundary = legalBalls > 0 && legalBalls % 6 === 0;

      if (activeSheet === null) {
        // End-of-over recovery: bowler picker was open when page was refreshed —
        // detected by currentBowlerId still being the same as lastBowlerId
        if (
          atOverBoundary &&
          strikerId &&
          nonStrikerId &&
          (
            !activeInnings.currentBowlerId ||
            (currentBowlerId && currentBowlerId === lastBowlerId)
          )
        ) {
          openSheet("bowler");
        }
        // Mid-innings recovery after page refresh: striker null but balls exist
        // If backend knows the striker, restore silently — don't prompt.
        // Only prompt if backend also has no striker (e.g. after a wicket, new batter not yet chosen).
        else if (balls.length > 0 && !strikerId) {
          if (activeInnings.currentStrikerId) {
            // Derive non-striker from ball history if backend doesn't have it stored
            // (backend only persists non-striker via swaps; early innings may lack it)
            let derivedNonStriker = activeInnings.currentNonStrikerId ?? null;
            if (!derivedNonStriker) {
              const dismissedSet = new Set(
                balls.filter((b: any) => b.isWicket && b.dismissalType !== "RETIRED_HURT")
                  .map((b: any) => b.dismissedPlayerId).filter(Boolean),
              );
              const activeBatters = new Set(
                balls.map((b: any) => b.batterId)
                  .filter((id: string) => id && !dismissedSet.has(id) && id !== activeInnings.currentStrikerId),
              );
              if (activeBatters.size === 1) derivedNonStriker = [...activeBatters][0] as string;
            }
            // Backend has the state — restore from it (handles cleared localStorage / cross-device)
            init(matchId, {
              strikerId: activeInnings.currentStrikerId,
              nonStrikerId: derivedNonStriker,
              currentBowlerId: activeInnings.currentBowlerId ?? null,
            });
          } else {
            const wicketsInInnings = balls.filter((b: any) => b.isWicket).length;
            if (wicketsInInnings < 10) {
              setNewBatterPos("striker");
              openSheet("newBatter");
            }
          }
        }
        // Striker is restored but non-striker is missing — derive from ball history
        else if (balls.length > 0 && strikerId && !nonStrikerId) {
          const dismissedSet = new Set(
            balls.filter((b: any) => b.isWicket && b.dismissalType !== "RETIRED_HURT")
              .map((b: any) => b.dismissedPlayerId).filter(Boolean),
          );
          const activeBatters = new Set(
            balls.map((b: any) => b.batterId)
              .filter((id: string) => id && !dismissedSet.has(id) && id !== strikerId),
          );
          if (activeBatters.size === 1) {
            setNonStriker([...activeBatters][0] as string);
          } else {
            const wicketsInInnings = balls.filter((b: any) => b.isWicket).length;
            if (wicketsInInnings < 10) {
              setNewBatterPos("nonStriker");
              openSheet("newBatter");
            }
          }
        }
      }
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [
    ready,
    match?.innings,
    players,
    strikerId,
    nonStrikerId,
    currentBowlerId,
    lastBowlerId,
    matchId,
  ]);

  const activeInnings = match?.innings.find((i) => !i.isCompleted);
  const isFreeHit = activeInnings?.isFreeHit ?? false;
  const inn1 = match?.innings.find((i) => i.inningsNumber === 1);
  const allBalls = activeInnings?.ballEvents ?? [];
  const legalCount = allBalls.filter(
    (b) => !["WIDE", "NO_BALL"].includes(b.outcome),
  ).length;
  const overNum = Math.floor(legalCount / 6);
  const ballInOver = legalCount % 6;

  // All squad players for name lookups (do NOT filter — needed for scorecard/commentary)
  const allMatchPlayers = [
    ...(players?.teamA.players ?? []),
    ...(players?.teamB.players ?? []),
  ];

  // Playing XI sets — filter squad to selected XI; fall back to full squad if XI not set
  const teamAXI = new Set(match?.teamAPlayerIds ?? []);
  const teamBXI = new Set(match?.teamBPlayerIds ?? []);
  const battingTeamXI = activeInnings?.battingTeam === "A" ? teamAXI : teamBXI;
  const bowlingTeamXI = activeInnings?.battingTeam === "A" ? teamBXI : teamAXI;

  const rawBattingPlayers =
    activeInnings?.battingTeam === "A"
      ? (players?.teamA.players ?? [])
      : (players?.teamB.players ?? []);
  const rawBowlingPlayers =
    activeInnings?.battingTeam === "A"
      ? (players?.teamB.players ?? [])
      : (players?.teamA.players ?? []);

  // Only show playing XI — prevents 12th/13th man batting or bowling
  const battingPlayers =
    battingTeamXI.size > 0
      ? rawBattingPlayers.filter((p) => battingTeamXI.has(p.profileId))
      : rawBattingPlayers;

  // Build a set of batting team profileIds to guard against data anomalies where
  // the same player appears in both team rosters (e.g. added to both squads in DB).
  // A batting-team player must never appear as a bowler.
  const battingProfileIdSet = new Set(rawBattingPlayers.map((p) => p.profileId));
  const bowlingPlayers = (
    bowlingTeamXI.size > 0
      ? rawBowlingPlayers.filter((p) => bowlingTeamXI.has(p.profileId))
      : rawBowlingPlayers
  ).filter((p) => !battingProfileIdSet.has(p.profileId));

  const thisOverBalls = useMemo(
    () =>
      allBalls.filter((b) => {
        const idx = allBalls.indexOf(b);
        const legalBefore = allBalls
          .slice(0, idx)
          .filter((x) => !["WIDE", "NO_BALL"].includes(x.outcome)).length;
        return Math.floor(legalBefore / 6) === overNum;
      }),
    [allBalls, overNum],
  );

  const zoneTotals = useMemo(() => {
    const totals: Record<string, number> = {};
    for (const b of allBalls) {
      const zone = zoneFromBall(b);
      if (zone) {
        const base = zone.replace(/-in$/, "");
        totals[base] = (totals[base] ?? 0) + b.runs;
      }
    }
    return totals;
  }, [allBalls]);

  const striker =
    allMatchPlayers.find((p) => p.profileId === strikerId) ?? null;
  const nonStriker =
    allMatchPlayers.find((p) => p.profileId === nonStrikerId) ?? null;
  const bowler =
    allMatchPlayers.find((p) => p.profileId === currentBowlerId) ?? null;

  // Fielding team = opposite of batting team
  const fieldingTeamSide = activeInnings?.battingTeam === "A" ? "B" : "A";
  const fieldingPlayers = bowlingPlayers;
  const currentWkId =
    fieldingTeamSide === "A"
      ? (players?.teamA.wicketKeeperId ?? "")
      : (players?.teamB.wicketKeeperId ?? "");
  const currentWk = fieldingPlayers.find((p) => p.profileId === currentWkId);

  if (!match || !activeInnings) {
    return <MatchCompletedState match={match} matchId={matchId} />;
  }

  function syncAuthoritativeInnings(
    innings: InningsRecord | null | undefined,
    options?: { needNewBowler?: boolean; preserveLastBowlerId?: string | null },
  ) {
    if (!innings) return;
    syncFromBackend(
      {
        strikerId: innings.currentStrikerId ?? null,
        nonStrikerId: innings.currentNonStrikerId ?? null,
        currentBowlerId: innings.currentBowlerId ?? null,
        lastBowlerId: options?.preserveLastBowlerId ?? null,
      },
      options?.needNewBowler ?? false,
    );
  }

  // Show "Start Innings" button before first ball of any innings (including innings 1 on refresh)
  const noBallsYet = (activeInnings.ballEvents ?? []).length === 0;
  if (noBallsYet && !inSetupFlow && !strikerId && !nonStrikerId) {
    const battingTeamName =
      activeInnings.battingTeam === "A" ? match.teamAName : match.teamBName;
    return (
      <div className="py-16 flex flex-col items-center gap-4 text-center">
        <p className="text-sm text-muted-foreground">
          Innings {activeInnings.inningsNumber} — {battingTeamName} to bat
        </p>
        <Button onClick={() => startSetupFlow()}>
          Start Innings {activeInnings.inningsNumber} →
        </Button>
      </div>
    );
  }

  // ── ball submission ──────────────────────────────────────────────────────

  const effectiveMaxOvers = dlsRevisedOvers ?? maxOvers;

  function submit(
    outcome: BallOutcome,
    runs: number,
    extras: number,
    extra?: Partial<BallInput>,
  ) {
    if (!strikerId || !currentBowlerId || scoringBlocked) return;
    const ot = overthrowOn ? overthrowRuns : 0; // capture overthrow at call time
    const isLegal = !["WIDE", "NO_BALL"].includes(outcome);
    const newLegalCount = isLegal ? legalCount + 1 : legalCount;
    const isEndOfOver = isLegal && newLegalCount % 6 === 0;
    const isInningsOver = isLegal && newLegalCount >= effectiveMaxOvers * 6;

    recordBall.mutate(
      {
        matchId,
        inningsNum: activeInnings!.inningsNumber,
        data: {
          batterId: strikerId,
          nonBatterId: nonStrikerId ?? undefined,
          bowlerId: currentBowlerId,
          overNumber: overNum,
          ballNumber: ballInOver + 1,
          outcome,
          runs,
          extras: extras + ot, // overthrow runs go to extras, not batsman
          isWicket: false,
          wagonZone: zone || undefined,
          ...extra,
        },
      },
      {
        onSuccess: (response) => {
          setOverthrowOn(false);
          setOverthrowRuns(0);
          setZone("");
          if (isInningsOver) {
            endInnings.mutate({
              matchId,
              inningsNum: activeInnings!.inningsNumber,
            });
            resetForNewInnings();
          } else {
            syncAuthoritativeInnings(response?.innings, {
              needNewBowler: isEndOfOver,
              preserveLastBowlerId: isEndOfOver ? currentBowlerId : undefined,
            });
          }
        },
      },
    );
  }

  function handleWicketConfirm(data: {
    dismissalType: DismissalType;
    dismissedId: string;
    fielderId?: string;
    runs: number;
    isRetiredHurt: boolean;
    isSubstituteFielder?: boolean;
    switchEnds?: boolean;
  }) {
    if (!strikerId || !currentBowlerId) return;
    closeSheet();
    const isEndOfOver = (legalCount + 1) % 6 === 0;
    const currentWickets = allBalls.filter((b) => b.isWicket).length;
    const isInningsOver =
      legalCount + 1 >= effectiveMaxOvers * 6 || currentWickets + 1 >= 10; // 10 wickets = all out
    if (data.isRetiredHurt) {
      // Not a wicket — just a DOT with retired_hurt info
      recordBall.mutate(
        {
          matchId,
          inningsNum: activeInnings!.inningsNumber,
          data: {
            batterId: strikerId,
            nonBatterId: nonStrikerId ?? undefined,
            bowlerId: currentBowlerId,
            overNumber: overNum,
            ballNumber: ballInOver + 1,
            outcome: "DOT",
            runs: 0,
            extras: 0,
            isWicket: false,
            dismissalType: "RETIRED_HURT",
            dismissedPlayerId: data.dismissedId,
            wagonZone: zone || undefined,
          },
        },
        {
          onSuccess: (response) => {
            setZone("");
            setPendingDismissedId(data.dismissedId);
            syncAuthoritativeInnings(response?.innings, {
              needNewBowler: isEndOfOver,
              preserveLastBowlerId: isEndOfOver ? currentBowlerId : undefined,
            });
          },
        },
      );
      return;
    }

    recordBall.mutate(
      {
        matchId,
        inningsNum: activeInnings!.inningsNumber,
        data: {
          batterId: strikerId,
          nonBatterId: nonStrikerId ?? undefined,
          bowlerId: currentBowlerId,
          overNumber: overNum,
          ballNumber: ballInOver + 1,
          outcome: "WICKET",
          runs: data.runs,
          extras: 0,
          isWicket: true,
          dismissalType: data.dismissalType,
          dismissedPlayerId: data.dismissedId,
          switchEnds: data.switchEnds,
          fielderId: data.fielderId,
          wagonZone: zone || undefined,
          tags: data.isSubstituteFielder ? ["sub:fielder"] : undefined,
        },
      },
      {
        onSuccess: (response) => {
          setZone("");
          setPendingDismissedId(data.dismissedId);
          if (isInningsOver) {
            endInnings.mutate({
              matchId,
              inningsNum: activeInnings!.inningsNumber,
            });
            // Reset store cleanly — useEffect will trigger setup flow for new innings
            resetForNewInnings();
            setPendingDismissedId(null);
          } else {
            syncAuthoritativeInnings(response?.innings, {
              needNewBowler: isEndOfOver,
              preserveLastBowlerId: isEndOfOver ? currentBowlerId : undefined,
            });
          }
        },
      },
    );
  }

  function handleNoBallConfirm({
    runsType,
    runs,
  }: {
    runsType: "bat" | "bye" | "none";
    runs: number;
  }) {
    if (!strikerId || !currentBowlerId) return;
    closeSheet();
    const batRuns = runsType === "bat" ? runs : 0;
    const byeRuns = runsType === "bye" ? runs : 0;
    const extraRuns = 1 + byeRuns;

    recordBall.mutate(
      {
        matchId,
        inningsNum: activeInnings!.inningsNumber,
        data: {
          batterId: strikerId,
          nonBatterId: nonStrikerId ?? undefined,
          bowlerId: currentBowlerId,
          overNumber: overNum,
          ballNumber: ballInOver + 1,
          outcome: "NO_BALL" as BallOutcome,
          runs: batRuns,
          extras: extraRuns,
          isWicket: false,
          wagonZone: zone || undefined,
        },
      },
      {
        onSuccess: (response) => {
          setZone("");
          syncAuthoritativeInnings(response?.innings);
        },
      },
    );
  }

  function handleWideConfirm(extraRuns: number) {
    if (!strikerId || !currentBowlerId) return;
    closeSheet();
    recordBall.mutate(
      {
        matchId,
        inningsNum: activeInnings!.inningsNumber,
        data: {
          batterId: strikerId,
          nonBatterId: nonStrikerId ?? undefined,
          bowlerId: currentBowlerId,
          overNumber: overNum,
          ballNumber: ballInOver + 1,
          outcome: "WIDE" as BallOutcome,
          runs: 0,
          extras: 1 + extraRuns,
          isWicket: false,
          wagonZone: zone || undefined,
        },
      },
      {
        onSuccess: (response) => {
          setZone("");
          syncAuthoritativeInnings(response?.innings);
        },
      },
    );
  }

  function handleByeConfirm(runs: number, type: "bye" | "legBye") {
    if (!strikerId || !currentBowlerId) return;
    closeSheet();
    const outcome = type === "bye" ? "BYE" : "LEG_BYE";
    const isEndOfOver = (legalCount + 1) % 6 === 0;
    const isInningsOver = legalCount + 1 >= effectiveMaxOvers * 6;
    recordBall.mutate(
      {
        matchId,
        inningsNum: activeInnings!.inningsNumber,
        data: {
          batterId: strikerId,
          nonBatterId: nonStrikerId ?? undefined,
          bowlerId: currentBowlerId,
          overNumber: overNum,
          ballNumber: ballInOver + 1,
          outcome: outcome as BallOutcome,
          runs: 0,
          extras: runs,
          isWicket: false,
          wagonZone: zone || undefined,
        },
      },
      {
        onSuccess: (response) => {
          setZone("");
          if (isInningsOver) {
            endInnings.mutate({
              matchId,
              inningsNum: activeInnings!.inningsNumber,
            });
            resetForNewInnings();
          } else {
            syncAuthoritativeInnings(response?.innings, {
              needNewBowler: isEndOfOver,
              preserveLastBowlerId: isEndOfOver ? currentBowlerId : undefined,
            });
          }
        },
      },
    );
  }

  const isBlocked = scoringBlocked || recordBall.isPending;

  // Bowler sheet players: exclude last bowler
  const bowlerPickerPlayers = bowlingPlayers.filter(
    (p) => p.profileId !== lastBowlerId,
  );
  // Players already dismissed this innings (excludes retired hurt — they can return)
  const dismissedIds = new Set(
    allBalls
      .filter((b) => b.isWicket && b.dismissalType !== "RETIRED_HURT")
      .map((b) => b.dismissedPlayerId)
      .filter(Boolean) as string[],
  );
  // New batter picker: exclude the player at the other end AND already dismissed players
  const newBatterPlayers = battingPlayers.filter((p) => {
    if (pendingDismissedId && p.profileId === pendingDismissedId) return false;
    if (dismissedIds.has(p.profileId)) return false;
    if (store.newBatterPos === "striker") return p.profileId !== nonStrikerId;
    if (store.newBatterPos === "nonStriker") return p.profileId !== strikerId;
    return true;
  });

  const isSetupFlow = store.inSetupFlow;
  const inningsLabel = `Innings ${activeInnings.inningsNumber}`;
  const newBatterTitle =
    store.newBatterPos === "striker"
      ? isSetupFlow
        ? `${inningsLabel} — Opening Batter (Striker)`
        : "New Batter — Striker End"
      : isSetupFlow
        ? `${inningsLabel} — Opening Batter (Non-Striker)`
        : "New Batter — Non-Striker End";
  const bowlerTitle = isEditingPlayer
    ? "Change Bowler"
    : isSetupFlow
      ? `${inningsLabel} — Opening Bowler`
      : `Over ${overNum + 1} — Select Bowler`;

  // Show setup prompt only at the very start of an innings (no balls yet).
  // Mid-innings state (after wicket + page refresh) is handled by auto-opening the batter sheet above.
  const needsSetup =
    ready &&
    (!strikerId || !nonStrikerId || !currentBowlerId) &&
    !scoringBlocked &&
    activeSheet === null &&
    allBalls.length === 0;

  return (
    <div className="space-y-4">
      {/* Score header */}
      <ScoreHeader matchId={matchId} maxOvers={maxOvers} ppOvers={ppOvers} />

      {/* Setup prompt — shown when batters/bowler not yet selected */}
      {needsSetup && (
        <div className="rounded-xl border border-amber-200 bg-amber-50 px-4 py-3 flex items-center justify-between gap-3">
          <div>
            <p className="text-sm font-semibold text-amber-800">
              Players not set up
            </p>
            <p className="text-xs text-amber-700 mt-0.5">
              {!strikerId || !nonStrikerId
                ? "Select openers and bowler to start"
                : "Select bowler to start"}
            </p>
          </div>
          <Button size="sm" onClick={startSetupFlow} className="shrink-0">
            Set up →
          </Button>
        </div>
      )}

      {/* Batter strip */}
      <BatterStrip
        players={allMatchPlayers}
        strikerId={strikerId}
        nonStrikerId={nonStrikerId}
        allBalls={allBalls}
        onEditStriker={editStriker}
        onEditNonStriker={editNonStriker}
        onSwap={strikerId && nonStrikerId ? swapBatters : undefined}
      />

      {/* Over dots + bowler tap */}
      <div className="rounded-xl border px-4 py-3 space-y-2">
        <div className="flex items-center justify-between mb-1">
          <span className="text-[10px] font-bold uppercase tracking-widest text-muted-foreground">
            Over {overNum + 1} · Ball {ballInOver + 1}
          </span>
          <div className="flex items-center gap-3">
            <button
              onClick={() => setWkChangeOpen(true)}
              className="flex items-center gap-1 text-[10px] text-muted-foreground hover:text-foreground font-medium"
              title="Change wicket keeper"
            >
              <RoleBadge label="WK" color="emerald" />
              {currentWk ? currentWk.name.split(" ")[0] : "Set WK"}
            </button>
            {bowler && (
              <button
                onClick={editBowler}
                className="flex items-center gap-1 text-xs text-muted-foreground hover:text-foreground font-medium"
              >
                {bowler.name.split(" ")[0]}
                <svg
                  width="10"
                  height="10"
                  viewBox="0 0 12 12"
                  fill="none"
                  stroke="currentColor"
                  strokeWidth="1.5"
                  strokeLinecap="round"
                  strokeLinejoin="round"
                >
                  <path d="M8.5 1.5a1.414 1.414 0 0 1 2 2L3.5 10.5 1 11l.5-2.5z" />
                </svg>
              </button>
            )}
          </div>
        </div>
        <OverDots balls={thisOverBalls} />
      </div>

      {/* Blocked banner */}
      {isBlocked && !recordBall.isPending && (
        <div className="rounded-xl border border-amber-200 bg-amber-50 px-4 py-3 text-xs text-amber-800 font-medium text-center">
          Select {activeSheet === "bowler" ? "next bowler" : "new batter"} to
          continue scoring
        </div>
      )}

      {/* Wagon wheel — shot placement */}
      <div className="rounded-xl border overflow-hidden">
        <div className="flex items-center justify-between px-3 py-2 border-b bg-muted/20">
          <p className="text-[10px] font-bold uppercase tracking-widest text-muted-foreground flex items-center gap-1.5">
            {zone ? (
              <>
                <span className="w-2 h-2 rounded-full bg-primary shrink-0" />
                <span className="text-primary normal-case font-semibold text-xs">
                  {ZONE_DEFS.find((z) => z.id === zone || `${z.id}-in` === zone)?.label}
                  {zone.endsWith("-in") ? " (infield)" : " (outfield)"}
                </span>
              </>
            ) : (
              <>
                <span className="w-2 h-2 rounded-full bg-muted-foreground/40 shrink-0" />
                Shot placement
              </>
            )}
            {isFreeHit && (
              <span className="ml-2 text-[10px] bg-yellow-400 text-yellow-900 font-black px-2 py-0.5 rounded-full">
                FREE HIT
              </span>
            )}
          </p>
          {zone && (
            <button
              onClick={() => setZone("")}
              className="text-[10px] text-muted-foreground hover:text-foreground px-2 py-0.5 rounded hover:bg-muted"
            >
              Clear
            </button>
          )}
        </div>
        <div className="p-2">
          <WagonWheel
            selected={zone}
            onSelect={setZone}
            isFreeHit={isFreeHit}
            zoneTotals={zoneTotals}
            balls={allBalls}
          />
        </div>
      </div>

      {/* Score panel */}
      <div
        className={`space-y-2 transition-opacity ${isBlocked ? "opacity-30 pointer-events-none" : ""}`}
      >
        {/* DOT — standalone, always enabled, no zone needed */}
        <button
          onClick={() => submit("DOT", 0, 0)}
          disabled={recordBall.isPending}
          className="w-full h-12 rounded-xl border-2 border-dashed border-muted-foreground/30 bg-muted/40 hover:bg-muted/70 font-bold text-2xl text-muted-foreground transition-all active:scale-95 disabled:opacity-40"
        >
          · Dot Ball
        </button>

        {/* Runs — require zone; inner zone only allows 1–2 */}
        <div className="rounded-xl border overflow-hidden">
          <div className="p-2.5 space-y-2">
            {(() => {
              const isInner = zone.endsWith("-in");
              const runOptions = (
                [
                  { label: "1", outcome: "SINGLE", runs: 1 },
                  { label: "2", outcome: "DOUBLE", runs: 2 },
                  { label: "3", outcome: "TRIPLE", runs: 3 },
                  { label: "4", outcome: "FOUR",   runs: 4 },
                  { label: "5", outcome: "FIVE",   runs: 5 },
                  { label: "6", outcome: "SIX",    runs: 6 },
                ] as { label: string; outcome: BallOutcome; runs: number }[]
              );
              return (
                <div className="relative">
                  <div className={`grid grid-cols-6 gap-1.5 transition-opacity ${!zone ? "opacity-20 pointer-events-none" : ""}`}>
                    {runOptions.map(({ label, outcome, runs }) => {
                      // Inner zone: 3, 4, 5, 6 not physically possible
                      const disabledByInner = isInner && runs >= 3;
                      return (
                        <button
                          key={label}
                          onClick={() => submit(outcome, runs, 0)}
                          disabled={recordBall.isPending || !zone || disabledByInner}
                          title={disabledByInner ? "Not possible from infield" : !zone ? "Tap a field zone first" : undefined}
                          className={`h-14 rounded-xl border font-bold text-xl transition-all active:scale-95 disabled:opacity-25 disabled:cursor-not-allowed ${
                            label === "4"
                              ? "bg-emerald-50 text-emerald-700 border-emerald-200 hover:bg-emerald-100"
                              : label === "6"
                                ? "bg-emerald-100 text-emerald-800 border-emerald-300 hover:bg-emerald-200"
                                : label === "5"
                                  ? "bg-amber-50 text-amber-700 border-amber-200 hover:bg-amber-100"
                                  : "hover:bg-muted/50"
                          }`}
                        >
                          {label}
                        </button>
                      );
                    })}
                  </div>
                  {!zone && (
                    <div className="absolute inset-0 flex items-center justify-center pointer-events-none">
                      <span className="text-xs font-semibold text-foreground bg-background/95 px-3 py-1.5 rounded-lg border shadow-sm">
                        ↑ Tap field to place shot
                      </span>
                    </div>
                  )}
                  {zone && zone.endsWith("-in") && (
                    <p className="text-[10px] text-muted-foreground text-center pt-1">
                      Infield — max 2 runs
                    </p>
                  )}
                </div>
              );
            })()}

            {/* Overthrow toggle */}
          <div className="flex items-center gap-1.5">
            <button
              onClick={() => { setOverthrowOn(!overthrowOn); setOverthrowRuns(0); }}
              className={`h-9 px-3 rounded-xl border text-xs font-bold transition-all active:scale-95 ${
                overthrowOn
                  ? "bg-amber-100 text-amber-700 border-amber-300"
                  : "text-muted-foreground border-muted hover:bg-muted/50"
              }`}
            >
              OT
            </button>
            {overthrowOn && (
              <>
                <span className="text-[10px] text-muted-foreground">+runs:</span>
                {[1, 2, 3, 4, 5].map((r) => (
                  <button
                    key={r}
                    onClick={() => setOverthrowRuns(overthrowRuns === r ? 0 : r)}
                    className={`w-9 h-9 rounded-xl border text-sm font-bold transition-all active:scale-95 ${
                      overthrowRuns === r
                        ? "bg-amber-200 text-amber-800 border-amber-400"
                        : "hover:bg-muted/50"
                    }`}
                  >
                    {r}
                  </button>
                ))}
                {overthrowRuns > 0 && (
                  <span className="text-xs font-semibold text-amber-700 ml-1">
                    +{overthrowRuns} OT
                  </span>
                )}
              </>
            )}
          </div>

          {/* Extras + Wicket */}
          <div className="grid grid-cols-6 gap-1.5">
            {/* Wd, NB — no zone needed */}
            <button
              onClick={() => openSheet("wideRuns")}
              disabled={recordBall.isPending}
              className="h-10 rounded-xl border text-sm font-bold text-orange-600 bg-orange-50 border-orange-200 hover:bg-orange-100 transition-all active:scale-95"
            >
              Wd
            </button>
            <button
              onClick={() => openSheet("noBall")}
              disabled={recordBall.isPending}
              className="h-10 rounded-xl border text-sm font-bold text-orange-600 bg-orange-50 border-orange-200 hover:bg-orange-100 transition-all active:scale-95"
            >
              NB
            </button>
            {/* B, LB, P5, W — require zone */}
            <button
              onClick={() => openSheet("bye")}
              disabled={recordBall.isPending || !zone}
              className={`h-10 rounded-xl border text-sm font-bold text-orange-600 bg-orange-50 border-orange-200 hover:bg-orange-100 transition-all active:scale-95 ${!zone ? "opacity-30" : ""}`}
            >
              B
            </button>
            <button
              onClick={() => openSheet("legBye")}
              disabled={recordBall.isPending || !zone}
              className={`h-10 rounded-xl border text-sm font-bold text-orange-600 bg-orange-50 border-orange-200 hover:bg-orange-100 transition-all active:scale-95 ${!zone ? "opacity-30" : ""}`}
            >
              LB
            </button>
            <button
              onClick={() => submit("DOT", 0, 5, { isPenalty: true } as any)}
              disabled={recordBall.isPending || !zone}
              title="Penalty 5 runs to batting side"
              className={`h-10 rounded-xl border text-sm font-bold text-amber-700 bg-amber-50 border-amber-200 hover:bg-amber-100 transition-all active:scale-95 ${!zone ? "opacity-30" : ""}`}
            >
              P5
            </button>
            <button
              onClick={() => openSheet("wicket")}
              disabled={recordBall.isPending || !zone}
              className={`h-10 rounded-xl border text-sm font-black text-red-600 bg-red-50 border-red-200 hover:bg-red-100 transition-all active:scale-95 ${!zone ? "opacity-30" : ""}`}
            >
              W
            </button>
          </div>
        </div>
      </div>
      </div>

      {/* DLS / Revised overs banner */}
      {dlsTarget !== null && (
        <div className="rounded-xl border border-blue-200 bg-blue-50 px-4 py-2.5 flex items-center justify-between">
          <div className="text-xs">
            <span className="font-bold text-blue-800">
              DLS Target: {dlsTarget}
            </span>
            {dlsRevisedOvers && (
              <span className="text-blue-600 ml-2">
                ({dlsRevisedOvers} overs)
              </span>
            )}
          </div>
          <button
            onClick={() => {
              setDlsTarget(null);
              setDlsRevisedOvers(null);
            }}
            className="text-[10px] text-blue-500 hover:text-blue-700"
          >
            Clear
          </button>
        </div>
      )}

      {/* Actions */}
      <div className="flex items-center gap-2 flex-wrap">
        <button
          disabled={undoBall.isPending || allBalls.length === 0}
          onClick={() =>
            undoBall.mutate(
              { matchId, inningsNum: activeInnings.inningsNumber },
              {
                onSuccess: (data: any) => {
                  const innings = data?.innings;
                  if (innings) {
                    useScoringStore.getState().syncFromBackend(
                      {
                        strikerId: innings.currentStrikerId ?? null,
                        nonStrikerId: innings.currentNonStrikerId ?? null,
                        currentBowlerId: innings.currentBowlerId ?? null,
                      },
                      data.needNewBowler ?? false,
                    );
                  }
                },
              },
            )
          }
          className="flex items-center gap-2 px-4 py-2 rounded-xl border border-amber-300 bg-amber-50 hover:bg-amber-100 text-amber-700 text-sm font-bold transition-all active:scale-95 disabled:opacity-40 disabled:cursor-not-allowed"
        >
          <RotateCcw className="w-4 h-4" /> Undo Last Ball
        </button>
        <Button
          variant="outline"
          size="sm"
          className="text-destructive border-destructive/40 hover:bg-destructive/10"
          onClick={() => setDeleteOpen(true)}
        >
          <Trash2 className="w-3.5 h-3.5 mr-1.5" /> Delete
        </Button>
        <Button
          variant="outline"
          size="sm"
          className="text-blue-600 border-blue-200 hover:bg-blue-50"
          onClick={() => setDlsOpen(true)}
        >
          DLS
        </Button>
        <div className="flex-1" />
        {match.format === "TEST" && (
          <Button
            variant="outline"
            size="sm"
            disabled={endOfDay.isPending}
            onClick={() => endOfDay.mutate(matchId)}
          >
            🌙 End Day {match.currentDay ?? 1}
            {match.testDays ? ` / ${match.testDays}` : ""}
          </Button>
        )}
        <Button
          variant="outline"
          size="sm"
          disabled={endInnings.isPending}
          onClick={() => {
            endInnings.mutate({
              matchId,
              inningsNum: activeInnings.inningsNumber,
            });
            resetForNewInnings();
          }}
        >
          End Innings →
        </Button>
      </div>

      {/* Follow-on dialog */}
      <Dialog
        open={!!followOnState}
        onOpenChange={(o) => { if (!o) setFollowOnState(null); }}
      >
        <DialogContent className="max-w-sm">
          <DialogHeader>
            <DialogTitle>Follow-On Available</DialogTitle>
          </DialogHeader>
          <p className="text-sm text-muted-foreground">
            The follow-on threshold has been met ({followOnState?.deficit} run deficit).
            Enforce follow-on so the same team bats again?
          </p>
          <DialogFooter>
            <Button
              variant="outline"
              disabled={continueInningsMut.isPending}
              onClick={() => {
                continueInningsMut.mutate(matchId, {
                  onSuccess: () => setFollowOnState(null),
                });
              }}
            >
              Continue Normally
            </Button>
            <Button
              disabled={enforceFollowOnMut.isPending}
              onClick={() => {
                enforceFollowOnMut.mutate(matchId, {
                  onSuccess: () => setFollowOnState(null),
                });
              }}
            >
              Enforce Follow-On
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>

      {/* WK change dialog */}
      <Dialog
        open={wkChangeOpen}
        onOpenChange={(o) => {
          if (!o) {
            setWkChangeOpen(false);
            setWkNewId("");
          }
        }}
      >
        <DialogContent className="max-w-sm">
          <DialogHeader>
            <DialogTitle>Change Wicket Keeper</DialogTitle>
          </DialogHeader>
          <p className="text-xs text-muted-foreground">
            Current WK:{" "}
            <span className="font-medium">{currentWk?.name ?? "Not set"}</span>
          </p>
          <Select
            value={wkNewId || "NONE"}
            onValueChange={(v) => setWkNewId(v === "NONE" ? "" : v)}
          >
            <SelectTrigger>
              <SelectValue placeholder="Select new wicket keeper" />
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="NONE">— Select player —</SelectItem>
              {fieldingPlayers.map((p) => (
                <SelectItem key={p.profileId} value={p.profileId}>
                  {p.name}
                  {p.profileId === currentWkId ? " (current WK)" : ""}
                </SelectItem>
              ))}
            </SelectContent>
          </Select>
          <DialogFooter>
            <Button
              variant="outline"
              onClick={() => {
                setWkChangeOpen(false);
                setWkNewId("");
              }}
            >
              Cancel
            </Button>
            <Button
              disabled={
                !wkNewId || wkNewId === currentWkId || changeWk.isPending
              }
              onClick={() =>
                changeWk.mutate(
                  {
                    id: matchId,
                    data: { team: fieldingTeamSide, wicketKeeperId: wkNewId },
                  },
                  {
                    onSuccess: () => {
                      setWkChangeOpen(false);
                      setWkNewId("");
                    },
                  },
                )
              }
            >
              {changeWk.isPending ? "Saving…" : "Confirm"}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>

      {/* Delete confirm */}
      <Dialog
        open={deleteOpen}
        onOpenChange={(o) => !o && setDeleteOpen(false)}
      >
        <DialogContent className="max-w-sm">
          <DialogHeader>
            <DialogTitle>Delete Match?</DialogTitle>
          </DialogHeader>
          <p className="text-sm text-muted-foreground">
            Permanently deletes the match and all ball events. Cannot be undone.
          </p>
          <DialogFooter>
            <Button variant="outline" onClick={() => setDeleteOpen(false)}>
              Cancel
            </Button>
            <Button
              variant="destructive"
              disabled={deleteMut.isPending}
              onClick={() =>
                deleteMut.mutate(matchId, {
                  onSuccess: () => router.push("/admin/matches"),
                })
              }
            >
              {deleteMut.isPending ? "Deleting…" : "Delete Match"}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>

      {/* ── Sheets ── */}

      {/* Bowler sheet — dismissible when editing, forced during setup/end-of-over */}
      {activeSheet === "bowler" && (
        <SelectionSheet
          title={bowlerTitle}
          subtitle={
            !isSetupFlow && lastBowlerId
              ? "Previous bowler cannot bowl consecutive overs"
              : undefined
          }
          players={bowlerPickerPlayers}
          onSelect={(p) => {
            setIsEditingPlayer(false);
            setPendingDismissedId(null);
            selectNextBowler(p.profileId);
          }}
          dismissible={isEditingPlayer}
          onDismiss={() => {
            setIsEditingPlayer(false);
            closeSheet();
          }}
          wicketKeeperPlayer={currentWk}
          onWicketKeeperClick={() => setWkChangeOpen(true)}
        />
      )}

      {/* New batter sheet — dismissible when editing, forced when wicket/setup */}
      {activeSheet === "newBatter" && (
        <SelectionSheet
          title={newBatterTitle}
          players={newBatterPlayers}
          onSelect={(p) => {
            setIsEditingPlayer(false);
            setPendingDismissedId(null);
            selectNewBatter(p.profileId);
          }}
          dismissible={isEditingPlayer}
          onDismiss={() => {
            setIsEditingPlayer(false);
            closeSheet();
          }}
        />
      )}

      {/* Wicket sheet */}
      <WicketSheet
        open={activeSheet === "wicket"}
        onClose={closeSheet}
        striker={striker}
        nonStriker={nonStriker}
        fielders={bowlingPlayers}
        isFreeHit={isFreeHit}
        wicketKeeperId={currentWkId}
        onConfirm={handleWicketConfirm}
      />

      {/* No ball sheet */}
      <NoBallSheet
        open={activeSheet === "noBall"}
        onClose={closeSheet}
        onConfirm={handleNoBallConfirm}
      />

      {/* Wide runs sheet */}
      <WideRunsSheet
        open={activeSheet === "wideRuns"}
        onClose={closeSheet}
        onConfirm={handleWideConfirm}
      />

      {/* Bye / Leg-bye runs sheet */}
      <ByeRunsSheet
        open={activeSheet === "bye"}
        type="bye"
        onClose={closeSheet}
        onConfirm={(runs) => handleByeConfirm(runs, "bye")}
      />
      <ByeRunsSheet
        open={activeSheet === "legBye"}
        type="legBye"
        onClose={closeSheet}
        onConfirm={(runs) => handleByeConfirm(runs, "legBye")}
      />

      {/* DLS Dialog */}
      <DlsDialog
        open={dlsOpen}
        onClose={() => setDlsOpen(false)}
        maxOvers={maxOvers}
        match={match}
        currentInningsNum={activeInnings.inningsNumber}
        onApply={(target, revisedOvers) => {
          setDlsTarget(target);
          setDlsRevisedOvers(revisedOvers);
          setDlsOpen(false);
        }}
      />
    </div>
  );
}

// ─── Setup Tab ────────────────────────────────────────────────────────────────

function RoleBadge({
  label,
  color,
}: {
  label: string;
  color: "amber" | "blue" | "emerald";
}) {
  const cls = {
    amber: "bg-amber-100 text-amber-700",
    blue: "bg-blue-100 text-blue-700",
    emerald: "bg-emerald-100 text-emerald-700",
  }[color];
  return (
    <span
      className={`text-[10px] font-bold px-1.5 py-0.5 rounded leading-none ${cls}`}
    >
      {label}
    </span>
  );
}

function SetupTab({
  matchId,
  format,
  maxOvers,
  setMaxOvers,
  ppOvers,
  setPPOvers,
}: {
  matchId: string;
  format: string;
  maxOvers: number;
  setMaxOvers: (n: number) => void;
  ppOvers: number;
  setPPOvers: (n: number) => void;
}) {
  const { data: players, isLoading } = useMatchPlayersQuery(matchId);
  const { data: match } = useMatchDetailQuery(matchId);
  const playing11Mut = useUpdatePlaying11Mutation();
  const tossMut = useRecordTossMutation();
  const startMut = useStartMatchMutation();

  const quickAddMut = useQuickAddMatchPlayerMutation();
  const addHighlightMut = useAddHighlightMutation();
  const deleteHighlightMut = useDeleteHighlightMutation();
  const [hlTitle, setHlTitle] = useState("");
  const [hlUrl, setHlUrl] = useState("");
  const [setupTab, setSetupTab] = useState("xi");
  const [selA, setSelA] = useState<Set<string>>(new Set());
  const [selB, setSelB] = useState<Set<string>>(new Set());
  const [addingFor, setAddingFor] = useState<"A" | "B" | null>(null);
  const [addName, setAddName] = useState("");
  const [addPhone, setAddPhone] = useState("");
  const [capA, setCapA] = useState("");
  const [capB, setCapB] = useState("");
  const [vcA, setVcA] = useState("");
  const [vcB, setVcB] = useState("");
  const [wkA, setWkA] = useState("");
  const [wkB, setWkB] = useState("");
  const [tossWinner, setTossWinner] = useState<"A" | "B">("A");
  const [tossDec, setTossDec] = useState<"BAT" | "BOWL">("BAT");
  const p11Initialized = useRef(false);

  // Init selections from match data ONCE — never on subsequent refetches
  // so that user deselections aren't wiped out by background query invalidations
  useEffect(() => {
    if (!match || p11Initialized.current) return;
    setSelA(new Set(match.teamAPlayerIds));
    setSelB(new Set(match.teamBPlayerIds));
    p11Initialized.current = true;
  }, [match]);

  useEffect(() => {
    if (!players) return;
    setCapA((prev) => prev || players.teamA.captainId || "");
    setCapB((prev) => prev || players.teamB.captainId || "");
    setVcA((prev) => prev || players.teamA.viceCaptainId || "");
    setVcB((prev) => prev || players.teamB.viceCaptainId || "");
    setWkA((prev) => prev || players.teamA.wicketKeeperId || "");
    setWkB((prev) => prev || players.teamB.wicketKeeperId || "");
  }, [players]);

  if (isLoading)
    return (
      <div className="py-10 text-center text-sm text-muted-foreground">
        Loading…
      </div>
    );
  if (!match || !players) return null;

  const tossWonName =
    match.tossWonBy === "A"
      ? match.teamAName
      : match.tossWonBy === "B"
        ? match.teamBName
        : null;
  const aCount = selA.size,
    bCount = selB.size;
  const rolesReady = !!capA && !!capB && !!vcA && !!vcB && !!wkA && !!wkB;
  const ready = aCount >= 11 && bCount >= 11 && rolesReady;

  return (
    <Tabs value={setupTab} onValueChange={setSetupTab}>
      <TabsList className="w-full mb-4">
        <TabsTrigger value="xi" className="flex-1">
          Playing 11
          {(aCount > 0 || bCount > 0) && (
            <span
              className={`ml-1.5 text-[10px] font-bold px-1.5 py-0.5 rounded-full ${
                ready
                  ? "bg-emerald-100 text-emerald-700"
                  : "bg-amber-100 text-amber-700"
              }`}
            >
              {aCount + bCount}/22
            </span>
          )}
        </TabsTrigger>
        <TabsTrigger value="toss" className="flex-1">
          Toss & Start
        </TabsTrigger>
        <TabsTrigger value="highlights" className="flex-1">
          Highlights
        </TabsTrigger>
      </TabsList>

      {/* ── Playing 11 ── */}
      <TabsContent value="xi" className="space-y-4 mt-0">
        {/* Overs setting */}
        <div className="rounded-xl border px-4 py-3 flex items-center gap-3">
          <span className="text-sm font-medium text-muted-foreground shrink-0">
            Max Overs
          </span>
          <div className="flex items-center gap-1.5 flex-wrap">
            {[5, 6, 10, 20, 50].map((n) => (
              <button
                key={n}
                onClick={() => setMaxOvers(n)}
                className={`w-9 h-8 rounded-lg border text-sm font-bold transition-colors ${maxOvers === n ? "bg-primary text-primary-foreground border-primary" : "hover:bg-muted"}`}
              >
                {n}
              </button>
            ))}
            <Input
              type="number"
              min={1}
              max={200}
              value={maxOvers}
              onChange={(e) => setMaxOvers(Number(e.target.value))}
              className="w-16 h-8 text-center font-bold"
            />
          </div>
        </div>

        {/* Powerplay / Fielding Restrictions */}
        <div className="rounded-xl border px-4 py-3 space-y-2">
          {format === "ONE_DAY" ? (
            // ODI: fixed 3-phase system, not editable
            <div className="space-y-1.5">
              <p className="text-sm font-medium text-muted-foreground">
                Fielding Phases (ICC ODI)
              </p>
              <div className="flex gap-2 text-xs flex-wrap">
                <span className="bg-blue-100 text-blue-700 font-bold px-2 py-1 rounded">
                  P1 · overs 1–10 · 2 outside
                </span>
                <span className="bg-sky-100 text-sky-700 font-bold px-2 py-1 rounded">
                  P2 · overs 11–40 · 4 outside
                </span>
                <span className="bg-indigo-100 text-indigo-700 font-bold px-2 py-1 rounded">
                  P3 · overs 41–50 · 5 outside
                </span>
              </div>
            </div>
          ) : (
            <div className="space-y-2">
              <div className="flex items-center gap-2">
                <span className="text-sm font-medium text-muted-foreground shrink-0">
                  Powerplay Overs
                </span>
                <span className="text-[10px] bg-blue-100 text-blue-700 font-bold px-1.5 py-0.5 rounded">
                  PP
                </span>
                <span className="text-xs text-muted-foreground ml-auto">
                  {format === "T20"
                    ? "ICC: overs 1–6"
                    : format === "T10"
                      ? "ICC: overs 1–3"
                      : "0 = disabled"}
                </span>
              </div>
              <div className="flex items-center gap-1.5 flex-wrap">
                {[0, 2, 3, 4, 6].map((n) => (
                  <button
                    key={n}
                    onClick={() => setPPOvers(n)}
                    className={`w-9 h-8 rounded-lg border text-sm font-bold transition-colors ${ppOvers === n ? "bg-blue-600 text-white border-blue-600" : "hover:bg-muted"}`}
                  >
                    {n}
                  </button>
                ))}
                <Input
                  type="number"
                  min={0}
                  max={maxOvers}
                  value={ppOvers}
                  onChange={(e) => setPPOvers(Number(e.target.value))}
                  className="w-16 h-8 text-center font-bold"
                />
              </div>
            </div>
          )}
        </div>

        {/* Team panels */}
        <div className="grid md:grid-cols-2 gap-4">
          {(["A", "B"] as const).map((side) => {
            const team = side === "A" ? players.teamA : players.teamB;
            const sel = side === "A" ? selA : selB;
            const setSel = side === "A" ? setSelA : setSelB;
            const cap = side === "A" ? capA : capB;
            const setCap = side === "A" ? setCapA : setCapB;
            const vc = side === "A" ? vcA : vcB;
            const setVc = side === "A" ? setVcA : setVcB;
            const wk = side === "A" ? wkA : wkB;
            const setWk = side === "A" ? setWkA : setWkB;
            const selP = team.players.filter((p) => sel.has(p.profileId));

            return (
              <div key={side} className="rounded-xl border overflow-hidden">
                {/* Header */}
                <div className="flex items-center justify-between px-4 py-2.5 border-b bg-muted/30">
                  <p className="text-sm font-semibold">{team.name}</p>
                  <span
                    className={`text-xs font-bold px-2 py-0.5 rounded-full ${
                      sel.size === 11
                        ? "bg-emerald-100 text-emerald-700"
                        : sel.size > 11
                          ? "bg-red-100 text-red-700"
                          : "bg-muted text-muted-foreground"
                    }`}
                  >
                    {sel.size}/11
                  </span>
                </div>

                {/* Player checklist */}
                <div className="divide-y max-h-96 overflow-y-auto">
                  {team.players.length === 0 && (
                    <p className="px-4 py-6 text-sm text-center text-muted-foreground">
                      No players in squad
                    </p>
                  )}
                  {team.players.map((p) => {
                    const isSelected = sel.has(p.profileId);
                    return (
                      <label
                        key={p.profileId}
                        className={`flex items-center gap-3 px-4 py-2.5 transition-colors cursor-pointer ${
                          isSelected
                            ? "bg-primary/5 hover:bg-primary/10"
                            : "hover:bg-muted/20"
                        }`}
                      >
                        <input
                          type="checkbox"
                          className="rounded accent-primary"
                          checked={isSelected}
                          onChange={() => {
                            const s = new Set(sel);
                            s.has(p.profileId)
                              ? s.delete(p.profileId)
                              : s.add(p.profileId);
                            setSel(s);
                          }}
                        />
                        <span
                          className={`text-sm flex-1 ${isSelected ? "font-medium" : ""}`}
                        >
                          {p.name}
                        </span>
                        <div className="flex items-center gap-1">
                          {cap === p.profileId && (
                            <RoleBadge label="C" color="amber" />
                          )}
                          {vc === p.profileId && (
                            <RoleBadge label="VC" color="blue" />
                          )}
                          {wk === p.profileId && (
                            <RoleBadge label="WK" color="emerald" />
                          )}
                        </div>
                      </label>
                    );
                  })}
                </div>

                {/* Quick-add player */}
                {addingFor === side ? (
                  <div className="px-4 py-3 border-t bg-blue-50 space-y-2">
                    <p className="text-xs font-semibold text-blue-800">
                      Add new player to squad
                    </p>
                    <Input
                      placeholder="Full name"
                      value={addName}
                      onChange={(e) => setAddName(e.target.value)}
                      className="h-8 text-sm"
                    />
                    <div className="flex gap-1.5">
                      <Input
                        placeholder="+91"
                        value="+91"
                        readOnly
                        className="h-8 text-sm w-14 text-center"
                      />
                      <Input
                        placeholder="Mobile number"
                        value={addPhone}
                        onChange={(e) =>
                          setAddPhone(
                            e.target.value.replace(/\D/g, "").slice(0, 10),
                          )
                        }
                        className="h-8 text-sm flex-1"
                        type="tel"
                        inputMode="numeric"
                      />
                    </div>
                    <div className="flex gap-2">
                      <Button
                        size="sm"
                        className="flex-1"
                        disabled={
                          addName.trim().length < 2 ||
                          addPhone.length !== 10 ||
                          quickAddMut.isPending
                        }
                        onClick={() =>
                          quickAddMut.mutate(
                            {
                              id: matchId,
                              data: {
                                team: side,
                                name: addName.trim(),
                                countryCode: "+91",
                                mobileNumber: addPhone,
                              },
                            },
                            {
                              onSuccess: () => {
                                setAddingFor(null);
                                setAddName("");
                                setAddPhone("");
                              },
                            },
                          )
                        }
                      >
                        {quickAddMut.isPending ? "Adding…" : "Add"}
                      </Button>
                      <Button
                        size="sm"
                        variant="outline"
                        onClick={() => {
                          setAddingFor(null);
                          setAddName("");
                          setAddPhone("");
                        }}
                      >
                        Cancel
                      </Button>
                    </div>
                  </div>
                ) : (
                  <button
                    onClick={() => setAddingFor(side)}
                    className="w-full flex items-center gap-2 px-4 py-2 border-t text-xs text-blue-600 hover:bg-blue-50 transition-colors"
                  >
                    <span className="text-base leading-none">+</span> Add player
                    to squad
                  </button>
                )}

                {/* Role selectors: C / VC / WK */}
                {selP.length > 0 && (
                  <div className="px-4 py-2.5 border-t bg-muted/10 space-y-2">
                    {[
                      {
                        label: "C",
                        color: "amber" as const,
                        val: cap,
                        set: setCap,
                        placeholder: "Select Captain *",
                      },
                      {
                        label: "VC",
                        color: "blue" as const,
                        val: vc,
                        set: setVc,
                        placeholder: "Select Vice Captain *",
                      },
                      {
                        label: "WK",
                        color: "emerald" as const,
                        val: wk,
                        set: setWk,
                        placeholder: "Select Wicket Keeper *",
                      },
                    ].map(({ label, color, val, set, placeholder }) => (
                      <div key={label} className="flex items-center gap-2">
                        <RoleBadge label={label} color={color} />
                        <Select
                          value={val || "NONE"}
                          onValueChange={(v) => set(v === "NONE" ? "" : v)}
                        >
                          <SelectTrigger
                            className={`h-8 text-xs flex-1 ${!val ? "border-amber-300" : ""}`}
                          >
                            <SelectValue placeholder={placeholder} />
                          </SelectTrigger>
                          <SelectContent>
                            <SelectItem value="NONE">— None —</SelectItem>
                            {selP.map((p) => (
                              <SelectItem key={p.profileId} value={p.profileId}>
                                {p.name}
                              </SelectItem>
                            ))}
                          </SelectContent>
                        </Select>
                      </div>
                    ))}
                  </div>
                )}
              </div>
            );
          })}
        </div>

        {!ready && (
          <div className="text-xs text-muted-foreground space-y-0.5">
            {(aCount !== 11 || bCount !== 11) && (
              <p className="text-center">
                {aCount !== 11 && bCount !== 11
                  ? `Select exactly 11 per team (${match.teamAName}: ${aCount}, ${match.teamBName}: ${bCount})`
                  : aCount !== 11
                    ? `${match.teamAName} needs exactly 11 (${aCount} selected)`
                    : `${match.teamBName} needs exactly 11 (${bCount} selected)`}
              </p>
            )}
            {aCount === 11 && bCount === 11 && !rolesReady && (
              <p className="text-center text-amber-600">
                Captain, Vice Captain and Wicket Keeper must be assigned for
                both teams
              </p>
            )}
          </div>
        )}
        <Button
          onClick={() =>
            playing11Mut.mutate(
              {
                id: matchId,
                data: {
                  teamAPlayerIds: Array.from(selA),
                  teamBPlayerIds: Array.from(selB),
                  teamACaptainId: capA || undefined,
                  teamBCaptainId: capB || undefined,
                  teamAViceCaptainId: vcA || undefined,
                  teamBViceCaptainId: vcB || undefined,
                  teamAWicketKeeperId: wkA || undefined,
                  teamBWicketKeeperId: wkB || undefined,
                  customOvers: maxOvers > 0 ? maxOvers : undefined,
                },
              },
              { onSuccess: () => setSetupTab("toss") },
            )
          }
          disabled={playing11Mut.isPending || !ready}
        >
          {playing11Mut.isPending ? "Saving…" : "Save Playing 11 →"}
        </Button>
      </TabsContent>

      {/* ── Toss & Start ── */}
      <TabsContent value="toss" className="space-y-4 mt-0">
        {/* Toss */}
        <div className="rounded-xl border p-4 space-y-4">
          <p className="text-sm font-semibold">Toss</p>
          {tossWonName ? (
            <p className="text-sm text-emerald-700 bg-emerald-50 rounded-lg px-3 py-2">
              🪙 {tossWonName} won the toss and chose to{" "}
              {match.tossDecision?.toLowerCase()}
            </p>
          ) : (
            <div className="space-y-3">
              <div className="grid grid-cols-2 gap-3">
                <div className="space-y-1.5">
                  <p className="text-xs text-muted-foreground font-medium">
                    Won by
                  </p>
                  <div className="flex rounded-lg border overflow-hidden">
                    {(["A", "B"] as const).map((s) => (
                      <button
                        key={s}
                        onClick={() => setTossWinner(s)}
                        className={`flex-1 py-2 text-sm font-medium transition-colors ${tossWinner === s ? "bg-primary text-primary-foreground" : "hover:bg-muted"}`}
                      >
                        {s === "A" ? match.teamAName : match.teamBName}
                      </button>
                    ))}
                  </div>
                </div>
                <div className="space-y-1.5">
                  <p className="text-xs text-muted-foreground font-medium">
                    Elected to
                  </p>
                  <div className="flex rounded-lg border overflow-hidden">
                    {(["BAT", "BOWL"] as const).map((d) => (
                      <button
                        key={d}
                        onClick={() => setTossDec(d)}
                        className={`flex-1 py-2 text-sm font-medium transition-colors ${tossDec === d ? "bg-primary text-primary-foreground" : "hover:bg-muted"}`}
                      >
                        {d === "BAT" ? "Bat" : "Bowl"}
                      </button>
                    ))}
                  </div>
                </div>
              </div>
              <Button
                size="sm"
                onClick={() =>
                  tossMut.mutate({
                    id: matchId,
                    data: { tossWonBy: tossWinner, tossDecision: tossDec },
                  })
                }
              >
                {tossMut.isPending ? "Saving…" : "Record Toss"}
              </Button>
            </div>
          )}
        </div>

        {/* Start match */}
        {match.status !== "IN_PROGRESS" && match.status !== "COMPLETED" && (
          <div className="rounded-xl border p-4 space-y-3">
            <p className="text-sm font-semibold">Start Match</p>
            {!ready && (
              <div className="rounded-lg border border-amber-200 bg-amber-50 px-3 py-2 text-xs text-amber-800 space-y-0.5">
                {aCount < 11 && (
                  <p>
                    ⚠ {match.teamAName}: {aCount}/11 players selected
                    {aCount < 11 ? ` — need ${11 - aCount} more` : ""}
                  </p>
                )}
                {bCount < 11 && (
                  <p>
                    ⚠ {match.teamBName}: {bCount}/11 players selected
                    {bCount < 11 ? ` — need ${11 - bCount} more` : ""}
                  </p>
                )}
                {aCount >= 11 && bCount >= 11 && !rolesReady && (
                  <p>⚠ Assign captain, vice-captain & wicket-keeper for both teams</p>
                )}
              </div>
            )}
            <Button
              className="w-full"
              disabled={!ready || startMut.isPending}
              onClick={() =>
                startMut.mutate({
                  matchId,
                  tournamentId: match.tournamentId ?? "",
                })
              }
            >
              {startMut.isPending ? "Starting…" : "▶ Start Match"}
            </Button>
          </div>
        )}
      </TabsContent>

      {/* ── Highlights ── */}
      <TabsContent value="highlights" className="space-y-4 mt-0">
        {/* Existing highlights */}
        <div className="rounded-xl border overflow-hidden">
          <div className="px-4 py-2.5 border-b bg-muted/30">
            <p className="text-sm font-semibold">YouTube Highlights</p>
          </div>
          <div className="divide-y">
            {!(match.highlights ?? []).length && (
              <p className="px-4 py-6 text-sm text-center text-muted-foreground">
                No highlights yet
              </p>
            )}
            {(match.highlights ?? []).map((h) => (
              <div key={h.id} className="flex items-center gap-3 px-4 py-3">
                <a
                  href={h.url}
                  target="_blank"
                  rel="noreferrer"
                  className="flex-1 text-sm font-medium hover:underline truncate"
                >
                  ▶ {h.title}
                </a>
                <Button
                  size="sm"
                  variant="ghost"
                  className="text-destructive hover:text-destructive shrink-0"
                  disabled={deleteHighlightMut.isPending}
                  onClick={() =>
                    deleteHighlightMut.mutate({
                      id: matchId,
                      highlightId: h.id,
                    })
                  }
                >
                  Remove
                </Button>
              </div>
            ))}
          </div>
        </div>

        {/* Add form */}
        <div className="rounded-xl border px-4 py-3 space-y-2">
          <p className="text-sm font-semibold">Add Highlight</p>
          <Input
            placeholder="Title (e.g. Rahul's match-winning over)"
            value={hlTitle}
            onChange={(e) => setHlTitle(e.target.value)}
          />
          <Input
            placeholder="YouTube URL (watch / youtu.be / Shorts)"
            value={hlUrl}
            onChange={(e) => setHlUrl(e.target.value)}
          />
          <Button
            size="sm"
            disabled={
              !hlTitle.trim() || !hlUrl.trim() || addHighlightMut.isPending
            }
            onClick={() =>
              addHighlightMut.mutate(
                {
                  id: matchId,
                  data: { title: hlTitle.trim(), url: hlUrl.trim() },
                },
                {
                  onSuccess: () => {
                    setHlTitle("");
                    setHlUrl("");
                  },
                },
              )
            }
          >
            {addHighlightMut.isPending ? "Adding…" : "Add Highlight"}
          </Button>
        </div>
      </TabsContent>
    </Tabs>
  );
}

// ─── Scorecard ────────────────────────────────────────────────────────────────

function ScorecardTab({ matchId }: { matchId: string }) {
  const { data: match } = useMatchDetailQuery(matchId);
  const { data: players } = useMatchPlayersQuery(matchId);
  if (!match) return null;

  const allP = [
    ...(players?.teamA.players ?? []),
    ...(players?.teamB.players ?? []),
  ];
  const name = (id: string) =>
    allP.find((p) => p.profileId === id)?.name ?? "—";

  return (
    <div className="space-y-6">
      {match.innings.map((inn) => {
        const balls = inn.ballEvents ?? [];
        const teamName =
          inn.battingTeam === "A" ? match.teamAName : match.teamBName;
        const bowlTeam =
          inn.battingTeam === "A" ? match.teamBName : match.teamAName;

        const bat = new Map<
          string,
          {
            runs: number;
            balls: number;
            fours: number;
            sixes: number;
            out: boolean;
            dismissalType?: string;
            dismissedByBowlerId?: string;
            dismissedByFielderId?: string;
          }
        >();
        const bowl = new Map<
          string,
          {
            runs: number;
            balls: number;
            wkts: number;
            wides: number;
            noBalls: number;
            maidens: number;
          }
        >();

        // Track legal balls + runs per bowler per over for maiden computation
        const bowlerOverStats = new Map<
          string,
          Map<number, { legalBalls: number; runs: number }>
        >();

        const BOWLER_CREDITED_WKTS = [
          "BOWLED",
          "CAUGHT",
          "LBW",
          "STUMPED",
          "HIT_WICKET",
        ];

        for (const b of balls) {
          // ── Batting ──────────────────────────────────────────────────────
          const bs = bat.get(b.batterId) ?? {
            runs: 0,
            balls: 0,
            fours: 0,
            sixes: 0,
            out: false,
          };
          const isLegalDelivery = !["WIDE", "NO_BALL"].includes(b.outcome);
          if (isLegalDelivery) bs.balls++;
          // Batter only scores runs on bat (not wide/bye/leg-bye extras)
          if (!["WIDE", "BYE", "LEG_BYE"].includes(b.outcome))
            bs.runs += b.runs;
          if (b.outcome === "FOUR") bs.fours++;
          if (b.outcome === "SIX") bs.sixes++;
          bat.set(b.batterId, bs);

          // Mark the actually-dismissed player as out (handles run-out of non-striker)
          if (b.isWicket) {
            const dismissedId = b.dismissedPlayerId || b.batterId;
            const dbs = bat.get(dismissedId) ?? {
              runs: 0,
              balls: 0,
              fours: 0,
              sixes: 0,
              out: false,
            };
            dbs.out = true;
            dbs.dismissalType = b.dismissalType ?? undefined;
            dbs.dismissedByBowlerId = b.bowlerId;
            dbs.dismissedByFielderId = b.fielderId ?? undefined;
            bat.set(dismissedId, dbs);
          }

          // ── Bowling ──────────────────────────────────────────────────────
          const bwl = bowl.get(b.bowlerId) ?? {
            runs: 0,
            balls: 0,
            wkts: 0,
            wides: 0,
            noBalls: 0,
            maidens: 0,
          };
          if (b.outcome === "WIDE") {
            bwl.runs += b.extras;
            bwl.wides++;
            // Wide: not a legal delivery — do NOT increment balls
          } else if (b.outcome === "NO_BALL") {
            bwl.runs += b.runs + b.extras;
            bwl.noBalls++;
            // No-ball: not a legal delivery — do NOT increment balls
          } else if (b.outcome === "BYE" || b.outcome === "LEG_BYE") {
            bwl.balls++; /* legal delivery, no runs charged to bowler */
          } else {
            bwl.runs += b.runs;
            bwl.balls++;
          }
          if (
            b.isWicket &&
            BOWLER_CREDITED_WKTS.includes(b.dismissalType ?? "")
          )
            bwl.wkts++;
          bowl.set(b.bowlerId, bwl);

          // Track per-over stats for maiden calculation (legal balls only)
          if (isLegalDelivery) {
            const overMap =
              bowlerOverStats.get(b.bowlerId) ??
              new Map<number, { legalBalls: number; runs: number }>();
            const os = overMap.get(b.overNumber) ?? { legalBalls: 0, runs: 0 };
            os.legalBalls++;
            // Byes/leg-byes don't count against bowler for maidens
            if (b.outcome !== "BYE" && b.outcome !== "LEG_BYE")
              os.runs += b.runs;
            overMap.set(b.overNumber, os);
            bowlerOverStats.set(b.bowlerId, overMap);
          }
        }

        // Compute maiden overs: complete overs (6 legal balls) with 0 runs charged to bowler
        for (const [bowlerId, overMap] of bowlerOverStats) {
          let maidens = 0;
          for (const [, os] of overMap) {
            if (os.legalBalls === 6 && os.runs === 0) maidens++;
          }
          const bwl = bowl.get(bowlerId);
          if (bwl) bwl.maidens = maidens;
        }

        // Extras breakdown
        const ext = balls.reduce(
          (a, b) => {
            if (b.outcome === "WIDE") a.wides += b.extras;
            if (b.outcome === "NO_BALL") a.noBalls += b.extras;
            if (b.outcome === "BYE") a.byes += b.extras;
            if (b.outcome === "LEG_BYE") a.legByes += b.extras;
            return a;
          },
          { wides: 0, noBalls: 0, byes: 0, legByes: 0 },
        );

        return (
          <div key={inn.id} className="space-y-3">
            <div className="flex items-center justify-between">
              <h3 className="font-bold text-sm">
                {teamName} — Inn {inn.inningsNumber}
              </h3>
              <p className="font-black text-lg">
                {inn.totalRuns}/{inn.totalWickets}
                <span className="text-muted-foreground font-normal text-sm ml-1">
                  ({fmtOvers(inn.totalOvers)} ov)
                </span>
              </p>
            </div>
            {/* Batting table */}
            <div className="rounded-xl border overflow-hidden">
              <div className="overflow-x-auto">
                <table className="w-full text-sm min-w-[420px]">
                  <thead>
                    <tr className="border-b bg-muted/30">
                      {["Batter", "R", "B", "4s", "6s", "SR"].map((h) => (
                        <th
                          key={h}
                          className={`px-3 py-2 text-[10px] font-bold uppercase tracking-wider text-muted-foreground ${h === "Batter" ? "text-left" : "text-right"}`}
                        >
                          {h}
                        </th>
                      ))}
                    </tr>
                  </thead>
                  <tbody>
                    {Array.from(bat.entries()).map(([id, s]) => {
                      // Build dismissal description
                      let dismissalInfo = "not out";
                      if (s.out && s.dismissalType) {
                        const bowlerName = s.dismissedByBowlerId
                          ? name(s.dismissedByBowlerId)
                          : "";
                        const fielderName = s.dismissedByFielderId
                          ? name(s.dismissedByFielderId)
                          : "";
                        switch (s.dismissalType) {
                          case "BOWLED":
                            dismissalInfo = `b ${bowlerName}`;
                            break;
                          case "CAUGHT":
                            dismissalInfo = `c ${fielderName} b ${bowlerName}`;
                            break;
                          case "LBW":
                            dismissalInfo = `lbw b ${bowlerName}`;
                            break;
                          case "STUMPED":
                            dismissalInfo = `st ${fielderName} b ${bowlerName}`;
                            break;
                          case "RUN_OUT":
                            dismissalInfo = fielderName
                              ? `run out (${fielderName})`
                              : "run out";
                            break;
                          case "HIT_WICKET":
                            dismissalInfo = `hit wkt b ${bowlerName}`;
                            break;
                          case "RETIRED_HURT":
                            dismissalInfo = "retired hurt";
                            break;
                          case "RETIRED_OUT":
                            dismissalInfo = "retired out";
                            break;
                          case "OBSTRUCTING_FIELD":
                            dismissalInfo = "obstructing field";
                            break;
                          default:
                            dismissalInfo = s.dismissalType
                              .replace(/_/g, " ")
                              .toLowerCase();
                        }
                      }
                      return (
                        <tr key={id} className="border-b last:border-0">
                          <td className="px-3 py-2 font-medium">
                            <div>
                              {name(id)}
                              {!s.out && (
                                <span className="text-muted-foreground text-xs">
                                  {" "}
                                  *
                                </span>
                              )}
                            </div>
                            <div className="text-[11px] text-muted-foreground">
                              {dismissalInfo}
                            </div>
                          </td>
                          <td className="px-3 py-2 text-right font-bold">
                            {s.runs}
                          </td>
                          <td className="px-3 py-2 text-right text-muted-foreground">
                            {s.balls}
                          </td>
                          <td className="px-3 py-2 text-right text-muted-foreground">
                            {s.fours}
                          </td>
                          <td className="px-3 py-2 text-right text-muted-foreground">
                            {s.sixes}
                          </td>
                          <td className="px-3 py-2 text-right text-muted-foreground">
                            {s.balls > 0
                              ? ((s.runs / s.balls) * 100).toFixed(1)
                              : "—"}
                          </td>
                        </tr>
                      );
                    })}
                  </tbody>
                </table>
              </div>
            </div>
            {/* Extras row */}
            <p className="text-xs text-muted-foreground px-1">
              Extras {inn.extras} (wd {ext.wides}, nb {ext.noBalls}, b{" "}
              {ext.byes}, lb {ext.legByes})
            </p>
            {/* Bowling table */}
            <div className="rounded-xl border overflow-hidden">
              <div className="px-4 py-2 border-b bg-muted/20">
                <p className="text-[10px] font-bold uppercase tracking-wider text-muted-foreground">
                  {bowlTeam} Bowling
                </p>
              </div>
              <div className="overflow-x-auto">
                <table className="w-full text-sm min-w-[360px]">
                  <thead>
                    <tr className="border-b bg-muted/20">
                      {["Bowler", "O", "M", "R", "W", "Eco"].map((h) => (
                        <th
                          key={h}
                          className={`px-3 py-2 text-[10px] font-bold uppercase tracking-wider text-muted-foreground ${h === "Bowler" ? "text-left" : "text-right"}`}
                        >
                          {h}
                        </th>
                      ))}
                    </tr>
                  </thead>
                  <tbody>
                    {Array.from(bowl.entries()).map(([id, s]) => {
                      // Overs: completed overs + remaining balls (e.g. 7 balls = "1.1")
                      const completedOvers = Math.floor(s.balls / 6);
                      const remainingBalls = s.balls % 6;
                      const oversDisplay = `${completedOvers}.${remainingBalls}`;
                      // Economy: runs per over, using actual legal ball count
                      const economy =
                        s.balls > 0 ? (s.runs / (s.balls / 6)).toFixed(1) : "—";
                      return (
                        <tr key={id} className="border-b last:border-0">
                          <td className="px-3 py-2.5 font-medium">
                            {name(id)}
                          </td>
                          <td className="px-3 py-2.5 text-right text-muted-foreground">
                            {oversDisplay}
                          </td>
                          <td className="px-3 py-2.5 text-right text-muted-foreground">
                            {s.maidens}
                          </td>
                          <td className="px-3 py-2.5 text-right text-muted-foreground">
                            {s.runs}
                          </td>
                          <td className="px-3 py-2.5 text-right font-bold">
                            {s.wkts}
                          </td>
                          <td className="px-3 py-2.5 text-right text-muted-foreground">
                            {economy}
                          </td>
                        </tr>
                      );
                    })}
                  </tbody>
                </table>
              </div>
            </div>
          </div>
        );
      })}
      {match.innings.length === 0 && (
        <p className="py-10 text-center text-sm text-muted-foreground">
          No innings yet.
        </p>
      )}
    </div>
  );
}

// ─── Commentary ───────────────────────────────────────────────────────────────

const BALL_OUTCOMES = ["DOT","SINGLE","DOUBLE","TRIPLE","FOUR","FIVE","SIX","WIDE","NO_BALL","WICKET","BYE","LEG_BYE"] as const;
const DISMISSAL_TYPES = ["BOWLED","CAUGHT","LBW","RUN_OUT","STUMPED","HIT_WICKET","RETIRED_HURT","OBSTRUCTING_FIELD"] as const;

function EditBallDialog({
  matchId,
  ball,
  onClose,
}: {
  matchId: string;
  ball: BallRecord & { innNum: number };
  onClose: () => void;
}) {
  const updateBall = useUpdateBallMutation();
  const [outcome, setOutcome] = useState<BallOutcome>(ball.outcome);
  const [runs, setRuns] = useState(String(ball.runs));
  const [extras, setExtras] = useState(String(ball.extras));
  const [isWicket, setIsWicket] = useState(ball.isWicket);
  const [dismissalType, setDismissalType] = useState<string>(ball.dismissalType ?? "");

  async function save() {
    await updateBall.mutateAsync({
      matchId,
      ballId: ball.id,
      data: {
        outcome,
        runs: Number(runs) || 0,
        extras: Number(extras) || 0,
        isWicket,
        dismissalType: isWicket && dismissalType ? (dismissalType as DismissalType) : null,
      },
    });
    onClose();
  }

  return (
    <Dialog open onOpenChange={(o) => !o && onClose()}>
      <DialogContent className="max-w-sm">
        <DialogHeader>
          <DialogTitle>
            Edit Ball {ball.innNum}.{ball.overNumber}.{ball.ballNumber}
          </DialogTitle>
        </DialogHeader>
        <div className="space-y-3 py-2">
          <div>
            <label className="text-xs font-medium mb-1 block">Outcome</label>
            <Select value={outcome} onValueChange={(v) => setOutcome(v as BallOutcome)}>
              <SelectTrigger><SelectValue /></SelectTrigger>
              <SelectContent>
                {BALL_OUTCOMES.map((o) => (
                  <SelectItem key={o} value={o}>{o}</SelectItem>
                ))}
              </SelectContent>
            </Select>
          </div>
          <div className="grid grid-cols-2 gap-3">
            <div>
              <label className="text-xs font-medium mb-1 block">Runs (bat)</label>
              <Input type="number" min={0} value={runs} onChange={(e) => setRuns(e.target.value)} />
            </div>
            <div>
              <label className="text-xs font-medium mb-1 block">Extras</label>
              <Input type="number" min={0} value={extras} onChange={(e) => setExtras(e.target.value)} />
            </div>
          </div>
          <label className="flex items-center gap-2 cursor-pointer">
            <input type="checkbox" checked={isWicket} onChange={(e) => setIsWicket(e.target.checked)} />
            <span className="text-sm">Wicket</span>
          </label>
          {isWicket && (
            <div>
              <label className="text-xs font-medium mb-1 block">Dismissal Type</label>
              <Select value={dismissalType} onValueChange={setDismissalType}>
                <SelectTrigger><SelectValue placeholder="Select..." /></SelectTrigger>
                <SelectContent>
                  {DISMISSAL_TYPES.map((d) => (
                    <SelectItem key={d} value={d}>{d}</SelectItem>
                  ))}
                </SelectContent>
              </Select>
            </div>
          )}
        </div>
        <DialogFooter>
          <Button variant="outline" onClick={onClose}>Cancel</Button>
          <Button onClick={save} disabled={updateBall.isPending}>Save</Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  );
}

function CommentaryTab({ matchId }: { matchId: string }) {
  const { data: match } = useMatchDetailQuery(matchId);
  const { data: players } = useMatchPlayersQuery(matchId);
  const [editingBall, setEditingBall] = useState<(BallRecord & { innNum: number }) | null>(null);
  if (!match) return null;

  const allP = [
    ...(players?.teamA.players ?? []),
    ...(players?.teamB.players ?? []),
  ];
  const name = (id: string) =>
    allP.find((p) => p.profileId === id)?.name ?? "—";
  const allBalls = match.innings.flatMap((inn) =>
    (inn.ballEvents ?? []).map((b) => ({ ...b, innNum: inn.inningsNumber })),
  );

  function line(b: (typeof allBalls)[0]) {
    if (b.isWicket)
      return `OUT! ${name(b.batterId)} — ${b.dismissalType ?? ""}. b. ${name(b.bowlerId)}`;
    if (b.outcome === "SIX")
      return `SIX! ${name(b.batterId)} launches it off ${name(b.bowlerId)}`;
    if (b.outcome === "FOUR")
      return `FOUR! ${name(b.batterId)} finds the boundary`;
    if (b.outcome === "WIDE") return `Wide by ${name(b.bowlerId)}`;
    if (b.outcome === "NO_BALL") return `No ball — ${name(b.bowlerId)}`;
    if (b.outcome === "BYE") return `${b.extras} bye(s)`;
    if (b.outcome === "LEG_BYE") return `${b.extras} leg bye(s)`;
    if (b.runs === 0) return `Dot. ${name(b.bowlerId)} to ${name(b.batterId)}`;
    return `${b.runs} run${b.runs !== 1 ? "s" : ""}. ${name(b.bowlerId)} to ${name(b.batterId)}`;
  }

  return (
    <>
      {editingBall && (
        <EditBallDialog
          matchId={matchId}
          ball={editingBall}
          onClose={() => setEditingBall(null)}
        />
      )}
      <div className="rounded-xl border divide-y">
        {[...allBalls].reverse().map((b, i) => (
          <div
            key={i}
            className="flex items-center gap-3 px-4 py-2.5 hover:bg-muted/20 group"
          >
            <span className="text-[10px] font-mono text-muted-foreground shrink-0">
              {b.innNum}.{b.overNumber}.{b.ballNumber}
            </span>
            <p
              className={`text-sm flex-1 ${b.isWicket ? "font-semibold text-red-600" : b.outcome === "SIX" || b.outcome === "FOUR" ? "font-medium text-emerald-600" : ""}`}
            >
              {line(b)}
            </p>
            <BallBubble
              outcome={b.outcome}
              runs={b.runs}
              extras={b.extras}
              isWicket={b.isWicket}
            />
            <button
              onClick={() => setEditingBall(b)}
              className="opacity-0 group-hover:opacity-100 p-1 rounded hover:bg-muted text-muted-foreground hover:text-foreground transition-opacity"
              title="Edit ball"
            >
              <Pencil className="h-3.5 w-3.5" />
            </button>
          </div>
        ))}
        {allBalls.length === 0 && (
          <p className="py-12 text-center text-sm text-muted-foreground">
            No balls yet.
          </p>
        )}
      </div>
    </>
  );
}

// ─── Over Summary (sidebar) ───────────────────────────────────────────────────

function OverSummaryPanel({ matchId }: { matchId: string }) {
  const { data: match } = useMatchDetailQuery(matchId);
  const [expandedOvers, setExpandedOvers] = useState<Set<string>>(new Set());
  const [showAllOvers, setShowAllOvers] = useState(false);

  if (!match || match.innings.length === 0) {
    return (
      <div className="rounded-xl border p-4 text-center text-xs text-muted-foreground">
        No innings yet
      </div>
    );
  }

  return (
    <div className="space-y-3">
      <p className="text-[10px] font-bold uppercase tracking-widest text-muted-foreground px-1">
        Over Summary
      </p>
      {match.innings.map((inn) => {
        const balls = inn.ballEvents ?? [];
        const teamName =
          inn.battingTeam === "A" ? match.teamAName : match.teamBName;
        const isActive = !inn.isCompleted;

        const overMap = new Map<number, typeof balls>();
        for (const b of balls) {
          if (!overMap.has(b.overNumber)) overMap.set(b.overNumber, []);
          overMap.get(b.overNumber)!.push(b);
        }
        const overs = Array.from(overMap.entries()).sort(([a], [b]) => a - b);

        // Determine which overs to show
        const currentOverNum =
          overs.length > 0 ? overs[overs.length - 1][0] : -1;
        const visibleOvers = showAllOvers ? overs : overs.slice(-6);
        const hiddenCount = overs.length - visibleOvers.length;

        return (
          <div key={inn.id} className="rounded-xl border overflow-hidden">
            <div
              className={`px-3 py-2 border-b flex items-center justify-between ${isActive ? "bg-emerald-50" : "bg-muted/30"}`}
            >
              <div>
                <p className="text-[10px] font-bold uppercase tracking-wide truncate">
                  {teamName}
                </p>
                {isActive && (
                  <p className="text-[9px] text-emerald-600 font-medium">
                    batting
                  </p>
                )}
              </div>
              <p className="text-sm font-black shrink-0 ml-2">
                {inn.totalRuns}
                <span className="text-muted-foreground font-normal text-xs">
                  /{inn.totalWickets}
                </span>
                <span className="text-[10px] text-muted-foreground font-normal ml-1">
                  ({fmtOvers(inn.totalOvers)})
                </span>
              </p>
            </div>

            {overs.length === 0 ? (
              <p className="px-3 py-4 text-xs text-center text-muted-foreground italic">
                No balls yet
              </p>
            ) : (
              <div>
                {/* Show all / hide toggle */}
                {hiddenCount > 0 && (
                  <button
                    onClick={() => setShowAllOvers(true)}
                    className="w-full px-3 py-1.5 text-[10px] text-muted-foreground hover:bg-muted/30 border-b transition-colors"
                  >
                    ↑ Show {hiddenCount} earlier over
                    {hiddenCount > 1 ? "s" : ""}
                  </button>
                )}
                {showAllOvers && hiddenCount > 0 && (
                  <button
                    onClick={() => setShowAllOvers(false)}
                    className="w-full px-3 py-1.5 text-[10px] text-muted-foreground hover:bg-muted/30 border-b transition-colors"
                  >
                    ↓ Show less
                  </button>
                )}
                <div className="divide-y">
                  {visibleOvers.map(([overNum, overBalls]) => {
                    const overRuns = overBalls.reduce(
                      (s, b) => s + b.runs + b.extras,
                      0,
                    );
                    const overWkts = overBalls.filter((b) => b.isWicket).length;
                    const isCurrentOver =
                      isActive && overNum === currentOverNum;
                    const overKey = `${inn.id}-${overNum}`;
                    const isExpanded =
                      isCurrentOver || expandedOvers.has(overKey);

                    return (
                      <div key={overNum}>
                        <button
                          onClick={() => {
                            if (isCurrentOver) return; // current over always expanded
                            const next = new Set(expandedOvers);
                            isExpanded
                              ? next.delete(overKey)
                              : next.add(overKey);
                            setExpandedOvers(next);
                          }}
                          className={`w-full flex items-center gap-2 px-3 py-2 text-left transition-colors ${isCurrentOver ? "bg-emerald-50/50" : "hover:bg-muted/20"}`}
                        >
                          <span className="text-[10px] font-mono font-bold text-muted-foreground w-8 shrink-0">
                            Ov {overNum + 1}
                          </span>
                          {!isExpanded ? (
                            // Compact: show dots inline
                            <div className="flex gap-0.5 flex-1 flex-wrap">
                              {overBalls.map((b, i) => (
                                <BallBubble
                                  key={i}
                                  size="sm"
                                  outcome={b.outcome}
                                  runs={b.runs}
                                  extras={b.extras}
                                  isWicket={b.isWicket}
                                />
                              ))}
                            </div>
                          ) : (
                            <div className="flex gap-0.5 flex-1 flex-wrap">
                              {overBalls.map((b, i) => (
                                <BallBubble
                                  key={i}
                                  size="sm"
                                  outcome={b.outcome}
                                  runs={b.runs}
                                  extras={b.extras}
                                  isWicket={b.isWicket}
                                />
                              ))}
                            </div>
                          )}
                          <div className="flex items-center gap-1 shrink-0 ml-auto">
                            {overWkts > 0 && (
                              <span className="text-[10px] font-bold text-red-600 bg-red-50 px-1 rounded">
                                {overWkts}W
                              </span>
                            )}
                            <span className="text-xs font-bold w-5 text-right">
                              {overRuns}
                            </span>
                          </div>
                        </button>
                      </div>
                    );
                  })}
                </div>
              </div>
            )}
          </div>
        );
      })}
    </div>
  );
}

// ─── Analysis Tab ─────────────────────────────────────────────────────────────

function ManhattanChart({
  balls,
  maxOvers,
}: {
  balls: BallRecord[];
  maxOvers: number;
}) {
  // Build per-over stats
  const overMap = new Map<number, { runs: number; wickets: number }>();
  for (const b of balls) {
    const o = b.overNumber ?? 0;
    const s = overMap.get(o) ?? { runs: 0, wickets: 0 };
    if (!["WIDE", "NO_BALL"].includes(b.outcome)) {
      // legal delivery
    }
    s.runs += b.runs + (b.extras ?? 0);
    if (b.isWicket) s.wickets++;
    overMap.set(o, s);
  }

  const overs = Array.from({ length: maxOvers }, (_, i) => ({
    over: i + 1,
    ...(overMap.get(i + 1) ?? { runs: 0, wickets: 0 }),
  }));

  const maxRuns = Math.max(...overs.map((o) => o.runs), 12);
  const W = 460;
  const H = 120;
  const barW = Math.max(6, Math.floor((W - 20) / maxOvers) - 2);
  const gap = Math.floor((W - 20) / maxOvers);

  return (
    <svg viewBox={`0 0 ${W} ${H + 28}`} className="w-full">
      {/* Y-axis guide lines */}
      {[0, 6, 12, 18, 24].filter((v) => v <= maxRuns + 2).map((v) => {
        const y = H - (v / maxRuns) * H + 4;
        return (
          <g key={v}>
            <line
              x1={14}
              y1={y}
              x2={W - 4}
              y2={y}
              stroke="#e5e7eb"
              strokeWidth={0.5}
            />
            <text x={10} y={y + 3} fontSize={7} fill="#9ca3af" textAnchor="end">
              {v}
            </text>
          </g>
        );
      })}
      {/* Bars */}
      {overs.map((o, i) => {
        const barH = Math.max(2, (o.runs / maxRuns) * H);
        const x = 16 + i * gap;
        const y = H - barH + 4;
        const hasWicket = o.wickets > 0;
        return (
          <g key={o.over}>
            <rect
              x={x}
              y={y}
              width={barW}
              height={barH}
              rx={2}
              fill={hasWicket ? "#ef4444" : "#3b82f6"}
              opacity={0.85}
            />
            {hasWicket && (
              <text
                x={x + barW / 2}
                y={y - 2}
                fontSize={7}
                fill="#ef4444"
                textAnchor="middle"
              >
                ×{o.wickets}
              </text>
            )}
            {/* Over number label every 5 */}
            {(o.over % 5 === 0 || o.over === 1) && (
              <text
                x={x + barW / 2}
                y={H + 14}
                fontSize={7}
                fill="#9ca3af"
                textAnchor="middle"
              >
                {o.over}
              </text>
            )}
          </g>
        );
      })}
      {/* Legend */}
      <rect x={W - 90} y={H + 18} width={8} height={6} rx={1} fill="#3b82f6" />
      <text x={W - 80} y={H + 24} fontSize={7} fill="#6b7280">
        Runs
      </text>
      <rect x={W - 50} y={H + 18} width={8} height={6} rx={1} fill="#ef4444" />
      <text x={W - 40} y={H + 24} fontSize={7} fill="#6b7280">
        Wicket over
      </text>
    </svg>
  );
}

function AnalysisTab({ matchId }: { matchId: string }) {
  const { data: match } = useMatchDetailQuery(matchId);
  const { data: players } = useMatchPlayersQuery(matchId);
  const [teamTab, setTeamTab] = useState<"A" | "B">("A");
  if (!match) return null;

  const teamAInnings = match.innings.filter((i: any) => i.battingTeam === "A");
  const teamBInnings = match.innings.filter((i: any) => i.battingTeam === "B");
  const activeInnings = teamTab === "A" ? teamAInnings : teamBInnings;
  const teamName = teamTab === "A" ? match.teamAName : match.teamBName;
  const bowlTeamName = teamTab === "A" ? match.teamBName : match.teamAName;

  const allP = [
    ...(players?.teamA.players ?? []),
    ...(players?.teamB.players ?? []),
  ];
  const name = (id: string) =>
    allP.find((p: any) => p.profileId === id)?.name ?? "—";

  // Aggregate all balls for this team's innings
  const allInnBalls: BallRecord[] = activeInnings.flatMap(
    (i: any) => i.ballEvents ?? [],
  );

  // Batting stats
  const bat = new Map<
    string,
    { runs: number; balls: number; fours: number; sixes: number; out: boolean }
  >();
  const bowl = new Map<
    string,
    { runs: number; balls: number; wkts: number; maidens: number }
  >();
  const BOWLER_CREDITED_WKTS = [
    "BOWLED",
    "CAUGHT",
    "LBW",
    "STUMPED",
    "HIT_WICKET",
  ];
  const bowlerOverStats = new Map<
    string,
    Map<number, { legalBalls: number; runs: number }>
  >();

  for (const b of allInnBalls) {
    const isLegal = !["WIDE", "NO_BALL"].includes(b.outcome);
    const bs = bat.get(b.batterId) ?? {
      runs: 0,
      balls: 0,
      fours: 0,
      sixes: 0,
      out: false,
    };
    if (isLegal) bs.balls++;
    if (!["WIDE", "BYE", "LEG_BYE"].includes(b.outcome)) bs.runs += b.runs;
    if (b.outcome === "FOUR") bs.fours++;
    if (b.outcome === "SIX") bs.sixes++;
    bat.set(b.batterId, bs);
    if (b.isWicket) {
      const dId = b.dismissedPlayerId || b.batterId;
      const dbs = bat.get(dId) ?? {
        runs: 0,
        balls: 0,
        fours: 0,
        sixes: 0,
        out: false,
      };
      dbs.out = true;
      bat.set(dId, dbs);
    }

    const bwl = bowl.get(b.bowlerId) ?? {
      runs: 0,
      balls: 0,
      wkts: 0,
      maidens: 0,
    };
    if (b.outcome === "WIDE") bwl.runs += b.extras;
    else if (b.outcome === "NO_BALL") bwl.runs += b.runs + b.extras;
    else if (b.outcome === "BYE" || b.outcome === "LEG_BYE") bwl.balls++;
    else {
      bwl.runs += b.runs;
      bwl.balls++;
    }
    if (b.isWicket && BOWLER_CREDITED_WKTS.includes(b.dismissalType ?? ""))
      bwl.wkts++;
    bowl.set(b.bowlerId, bwl);

    if (isLegal) {
      const overMap =
        bowlerOverStats.get(b.bowlerId) ??
        new Map<number, { legalBalls: number; runs: number }>();
      const os = overMap.get(b.overNumber) ?? { legalBalls: 0, runs: 0 };
      os.legalBalls++;
      if (b.outcome !== "BYE" && b.outcome !== "LEG_BYE") os.runs += b.runs;
      overMap.set(b.overNumber, os);
      bowlerOverStats.set(b.bowlerId, overMap);
    }
  }
  for (const [bowlerId, overMap] of bowlerOverStats) {
    let maidens = 0;
    for (const [, os] of overMap) {
      if (os.legalBalls === 6 && os.runs === 0) maidens++;
    }
    const bwl = bowl.get(bowlerId);
    if (bwl) bwl.maidens = maidens;
  }

  // Wagon wheel zone totals for this innings
  const wwZoneTotals: Record<string, number> = {};
  for (const b of allInnBalls) {
    const zone = zoneFromBall(b);
    if (zone) {
      const base = zone.replace(/-in$/, "");
      wwZoneTotals[base] = (wwZoneTotals[base] ?? 0) + b.runs;
    }
  }

  const maxOvers = match.customOvers ?? 20;

  return (
    <div className="space-y-5">
      {/* Team tabs */}
      <div className="flex gap-2">
        {(["A", "B"] as const).map((t) => {
          const tn = t === "A" ? match.teamAName : match.teamBName;
          return (
            <button
              key={t}
              onClick={() => setTeamTab(t)}
              className={`px-4 py-1.5 rounded-full text-sm font-medium transition-colors ${
                teamTab === t
                  ? "bg-primary text-primary-foreground"
                  : "bg-muted/50 text-muted-foreground hover:bg-muted"
              }`}
            >
              {tn}
            </button>
          );
        })}
      </div>

      {activeInnings.length === 0 ? (
        <p className="py-10 text-center text-sm text-muted-foreground">
          No innings for {teamName} yet.
        </p>
      ) : (
        <>
          {/* Manhattan chart */}
          <div className="rounded-xl border p-4">
            <p className="text-xs font-bold uppercase tracking-wider text-muted-foreground mb-3">
              {teamName} — Runs per Over
            </p>
            <ManhattanChart balls={allInnBalls} maxOvers={maxOvers} />
          </div>

          {/* Wagon wheel */}
          <div className="rounded-xl border p-4">
            <p className="text-xs font-bold uppercase tracking-wider text-muted-foreground mb-2">
              {teamName} — Shot Map
            </p>
            <WagonWheel
              zoneTotals={wwZoneTotals}
              balls={allInnBalls}
            />
          </div>

          {/* Batting table */}
          <div className="rounded-xl border overflow-hidden">
            <div className="px-4 py-2 border-b bg-muted/20">
              <p className="text-[10px] font-bold uppercase tracking-wider text-muted-foreground">
                {teamName} Batting
              </p>
            </div>
            <div className="overflow-x-auto">
              <table className="w-full text-sm min-w-[380px]">
                <thead>
                  <tr className="border-b bg-muted/30">
                    {["Batter", "R", "B", "4s", "6s", "SR"].map((h) => (
                      <th
                        key={h}
                        className={`px-3 py-2 text-[10px] font-bold uppercase tracking-wider text-muted-foreground ${h === "Batter" ? "text-left" : "text-right"}`}
                      >
                        {h}
                      </th>
                    ))}
                  </tr>
                </thead>
                <tbody>
                  {Array.from(bat.entries()).map(([id, s]) => (
                    <tr key={id} className="border-b last:border-0">
                      <td className="px-3 py-2 font-medium">
                        {name(id)}
                        {!s.out && (
                          <span className="text-muted-foreground text-xs">
                            {" "}
                            *
                          </span>
                        )}
                      </td>
                      <td className="px-3 py-2 text-right font-bold">
                        {s.runs}
                      </td>
                      <td className="px-3 py-2 text-right text-muted-foreground">
                        {s.balls}
                      </td>
                      <td className="px-3 py-2 text-right text-muted-foreground">
                        {s.fours}
                      </td>
                      <td className="px-3 py-2 text-right text-muted-foreground">
                        {s.sixes}
                      </td>
                      <td className="px-3 py-2 text-right text-muted-foreground">
                        {s.balls > 0
                          ? ((s.runs / s.balls) * 100).toFixed(1)
                          : "—"}
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </div>

          {/* Bowling table */}
          <div className="rounded-xl border overflow-hidden">
            <div className="px-4 py-2 border-b bg-muted/20">
              <p className="text-[10px] font-bold uppercase tracking-wider text-muted-foreground">
                {bowlTeamName} Bowling
              </p>
            </div>
            <div className="overflow-x-auto">
              <table className="w-full text-sm min-w-[340px]">
                <thead>
                  <tr className="border-b bg-muted/20">
                    {["Bowler", "O", "M", "R", "W", "Eco"].map((h) => (
                      <th
                        key={h}
                        className={`px-3 py-2 text-[10px] font-bold uppercase tracking-wider text-muted-foreground ${h === "Bowler" ? "text-left" : "text-right"}`}
                      >
                        {h}
                      </th>
                    ))}
                  </tr>
                </thead>
                <tbody>
                  {Array.from(bowl.entries()).map(([id, s]) => {
                    const co = Math.floor(s.balls / 6);
                    const rb = s.balls % 6;
                    const eco =
                      s.balls > 0 ? (s.runs / (s.balls / 6)).toFixed(1) : "—";
                    return (
                      <tr key={id} className="border-b last:border-0">
                        <td className="px-3 py-2.5 font-medium">{name(id)}</td>
                        <td className="px-3 py-2.5 text-right text-muted-foreground">
                          {co}.{rb}
                        </td>
                        <td className="px-3 py-2.5 text-right text-muted-foreground">
                          {s.maidens}
                        </td>
                        <td className="px-3 py-2.5 text-right text-muted-foreground">
                          {s.runs}
                        </td>
                        <td className="px-3 py-2.5 text-right font-bold">
                          {s.wkts}
                        </td>
                        <td className="px-3 py-2.5 text-right text-muted-foreground">
                          {eco}
                        </td>
                      </tr>
                    );
                  })}
                </tbody>
              </table>
            </div>
          </div>
        </>
      )}
    </div>
  );
}

// ─── Overlay Tab ──────────────────────────────────────────────────────────────

function OverlayTab({
  matchId,
  youtubeUrl: initialYoutubeUrl,
}: {
  matchId: string;
  youtubeUrl?: string | null;
}) {
  const [youtubeInput, setYoutubeInput] = useState(initialYoutubeUrl ?? "");
  const streamMut = useSetMatchStreamMutation();

  function extractYoutubeId(url: string): string | null {
    try {
      const u = new URL(url);
      if (u.hostname.includes("youtu.be"))
        return u.pathname.slice(1).split("?")[0] || null;
      const pathMatch = u.pathname.match(/\/(?:live|shorts|embed)\/([a-zA-Z0-9_-]{11})/);
      if (pathMatch) return pathMatch[1];
      return u.searchParams.get("v");
    } catch {
      return null;
    }
  }

  const youtubeId = extractYoutubeId(youtubeInput);
  const publicMatchUrl = `${PUBLIC_WEB_BASE_URL}/m/${matchId}`;

  async function saveStream() {
    if (youtubeInput && !youtubeId) {
      toast.error("Invalid YouTube URL");
      return;
    }
    streamMut.mutate({ id: matchId, youtubeUrl: youtubeInput || null });
  }
  const base = `${API_BASE_URL}/public/overlay/${matchId}/widget`;

  const views = [
    {
      label: "Standard View",
      description:
        "Transparent lower-third overlay for OBS. Use this when you want the match graphics over live video.",
      url: `${base}?view=standard`,
      tag: "BOTTOM BAR",
      tagColor: "bg-emerald-500/10 text-emerald-700 border-emerald-500/20",
    },
    {
      label: "Full Stats View",
      description:
        "Opaque full-scene scoreboard. Use as its own scene or during score updates between live shots.",
      url: `${base}?view=stats`,
      tag: "FULL SCREEN",
      tagColor: "bg-blue-500/10 text-blue-700 border-blue-500/20",
    },
    {
      label: "Drinks Break",
      description:
        "Full-scene break screen with current score. Best used during timeout or drinks.",
      url: `${base}?view=break&type=drinks`,
      tag: "BREAK SCREEN",
      tagColor: "bg-amber-500/10 text-amber-700 border-amber-500/20",
    },
    {
      label: "Innings Break",
      description:
        "Innings break screen showing both team scores. Ideal for the gap between innings.",
      url: `${base}?view=break&type=innings`,
      tag: "BREAK SCREEN",
      tagColor: "bg-amber-500/10 text-amber-700 border-amber-500/20",
    },
    {
      label: "Powerplay / After 6",
      description:
        "Powerplay end screen showing current score. Use after the 6th over.",
      url: `${base}?view=break&type=powerplay`,
      tag: "BREAK SCREEN",
      tagColor: "bg-violet-500/10 text-violet-700 border-violet-500/20",
    },
  ];

  const jsonUrl = `${API_BASE_URL}/public/overlay/${matchId}`;

  async function copyUrl(url: string, label: string) {
    try {
      await navigator.clipboard.writeText(url);
      toast.success(`${label} copied`);
    } catch {
      toast.error("Could not copy");
    }
  }

  return (
    <div className="space-y-6">
      {/* YouTube Live Stream */}
      <div className="rounded-xl border bg-card p-5 space-y-4">
        <div className="flex items-center gap-3 mb-1">
          <svg
            className="h-5 w-5 text-red-500"
            viewBox="0 0 24 24"
            fill="currentColor"
          >
            <path d="M23.495 6.205a3.007 3.007 0 00-2.088-2.088c-1.87-.501-9.396-.501-9.396-.501s-7.507-.01-9.396.501A3.007 3.007 0 00.527 6.205a31.247 31.247 0 00-.522 5.805 31.247 31.247 0 00.522 5.783 3.007 3.007 0 002.088 2.088c1.868.502 9.396.502 9.396.502s7.506 0 9.396-.502a3.007 3.007 0 002.088-2.088 31.247 31.247 0 00.5-5.783 31.247 31.247 0 00-.5-5.805zM9.609 15.601V8.408l6.264 3.602z" />
          </svg>
          <h3 className="font-semibold">YouTube Live Stream</h3>
        </div>
        <p className="text-sm text-muted-foreground">
          Paste a YouTube live stream URL to embed it on the public match page
          at{" "}
          <a
            href={publicMatchUrl}
            target="_blank"
            rel="noopener noreferrer"
            className="text-primary underline-offset-4 hover:underline font-mono text-xs"
          >
            {publicMatchUrl}
          </a>
          . Fans can watch the stream and follow live scores in one place.
        </p>
        <div className="flex items-center gap-2">
          <Input
            placeholder="https://www.youtube.com/watch?v=..."
            value={youtubeInput}
            onChange={(e) => setYoutubeInput(e.target.value)}
            className="font-mono text-sm"
          />
          <Button
            size="sm"
            onClick={saveStream}
            disabled={streamMut.isPending}
            className="shrink-0"
          >
            {streamMut.isPending ? "Saving…" : "Save"}
          </Button>
          {youtubeInput && (
            <Button
              size="sm"
              variant="ghost"
              className="shrink-0 text-destructive"
              onClick={() => {
                setYoutubeInput("");
                streamMut.mutate({ id: matchId, youtubeUrl: null });
              }}
            >
              Remove
            </Button>
          )}
        </div>
        <div className="flex items-center gap-2">
          <code className="flex-1 truncate rounded-lg bg-muted px-3 py-2 text-[11px] font-mono border">
            {publicMatchUrl}
          </code>
          <Button
            size="sm"
            variant="outline"
            className="shrink-0 gap-1.5"
            onClick={async () => {
              await navigator.clipboard.writeText(publicMatchUrl);
              toast.success("Public match URL copied");
            }}
          >
            <Copy className="h-3.5 w-3.5" />
            Copy
          </Button>
          <Button size="sm" variant="ghost" className="shrink-0" asChild>
            <a href={publicMatchUrl} target="_blank" rel="noopener noreferrer">
              <ExternalLink className="h-3.5 w-3.5" />
            </a>
          </Button>
        </div>
      </div>

      {/* OBS Overlay header */}
      <div className="rounded-xl border bg-card p-5">
        <div className="flex items-center gap-3 mb-1">
          <Tv2 className="h-5 w-5 text-muted-foreground" />
          <h3 className="font-semibold">OBS Streaming Overlay</h3>
        </div>
        <p className="text-sm text-muted-foreground">
          Add any URL below as a <strong>Browser Source</strong> in OBS Studio.
          Standard View is transparent and OBS-safe. Full Stats and Break views
          are full-scene layouts. Overlays now stream live updates with polling
          fallback.
        </p>
      </div>

      {/* View cards */}
      <div className="space-y-2">
        {views.map((v) => (
          <div key={v.url} className="rounded-xl border bg-card px-4 py-3 flex items-center gap-3">
            <div className="flex-1 min-w-0">
              <div className="flex items-center gap-2 mb-0.5">
                <span className="font-medium text-sm">{v.label}</span>
                <span className={`text-[10px] font-semibold border px-2 py-0.5 rounded-full ${v.tagColor}`}>
                  {v.tag}
                </span>
              </div>
              <p className="text-xs text-muted-foreground truncate">{v.description}</p>
            </div>
            <Button size="sm" variant="outline" className="shrink-0 gap-1.5" onClick={() => copyUrl(v.url, v.label)}>
              <Copy className="h-3.5 w-3.5" />
              Copy URL
            </Button>
            <Button size="sm" variant="ghost" className="shrink-0" asChild>
              <a href={v.url} target="_blank" rel="noopener noreferrer" title="Preview">
                <ExternalLink className="h-3.5 w-3.5" />
              </a>
            </Button>
          </div>
        ))}
      </div>

      {/* JSON API */}
      <div className="rounded-xl border bg-muted/30 p-4 space-y-2">
        <div className="flex items-center justify-between gap-3">
          <div>
            <p className="text-xs font-semibold text-foreground">JSON API</p>
            <p className="text-xs text-muted-foreground mt-0.5">For Singular.live, vMix, custom scripts. Returns live score data.</p>
          </div>
          <div className="flex items-center gap-2 shrink-0">
            <Button size="sm" variant="outline" className="gap-1.5" onClick={() => copyUrl(jsonUrl, "JSON API URL")}>
              <Copy className="h-3.5 w-3.5" />
              Copy URL
            </Button>
          </div>
        </div>
        <div className="flex items-center gap-2">
          <code className="flex-1 truncate rounded-lg bg-background px-3 py-2 text-[11px] font-mono border">
            {jsonUrl}
          </code>
        </div>
      </div>

      {/* OBS tip */}
      <div className="rounded-xl border border-dashed p-4 text-xs text-muted-foreground space-y-2">
        <p className="font-medium text-foreground">OBS Setup</p>
        <p><span className="text-foreground font-medium">Standard View</span> — Browser Source → Width <code className="bg-muted px-1 py-0.5 rounded text-[10px]">1920</code>, Height <code className="bg-muted px-1 py-0.5 rounded text-[10px]">120</code> → position at the bottom of your stream. No transparency needed.</p>
        <p><span className="text-foreground font-medium">Full Stats / Break screens</span> — Browser Source → <code className="bg-muted px-1 py-0.5 rounded text-[10px]">1920 × 1080</code>, use as a separate scene.</p>
        <p className="text-muted-foreground/70">Append <code className="bg-muted px-1 py-0.5 rounded text-[10px]">?poll=1000</code> to any URL for 1 second refresh.</p>
      </div>
    </div>
  );
}

// ─── Live Tab ─────────────────────────────────────────────────────────────────

const SCENES = [
  { value: "standard", label: "Return to Auto", desc: "Follow the default free pack driven by scoring actions", icon: Monitor },
  { value: "stats", label: "Stats Override", desc: "Force the full scoreboard scene until you switch back", icon: Tv2 },
  { value: "break", label: "Break Override", desc: "Force a drinks / innings / powerplay screen", icon: Radio },
  { value: "clean", label: "Clean Feed", desc: "No overlay — camera only", icon: EyeOff },
] as const;

const BREAK_TYPES = [
  { value: "drinks", label: "Drinks Break" },
  { value: "innings", label: "Innings Break" },
  { value: "powerplay", label: "Powerplay" },
] as const;

const DEFAULT_PACK_FLOW = [
  {
    title: "Match Intro",
    detail: "Shown after stream starts and holds until toss is recorded.",
  },
  {
    title: "Toss Result",
    detail: "Shown after toss and stays on screen until innings 1 starts.",
  },
  {
    title: "Live Score",
    detail: "Default lower-third during active play, updated ball by ball.",
  },
  {
    title: "Break States",
    detail: "Use manual override for drinks, innings break, and powerplay screens.",
  },
  {
    title: "Match Result",
    detail: "Held after the scorer completes the match.",
  },
] as const;

function getOverlayAutomationState(
  match: MatchDetail,
  activeScene: string,
  activeBreakType: string,
) {
  const breakLabel =
    BREAK_TYPES.find((item) => item.value === activeBreakType)?.label ?? "Break";

  if (activeScene === "clean") {
    return {
      title: "Manual Override: Clean Feed",
      detail: "Graphics are hidden until you return to auto mode.",
    };
  }

  if (activeScene === "stats") {
    return {
      title: "Manual Override: Stats View",
      detail: "The full-screen scoreboard is pinned until you return to auto mode.",
    };
  }

  if (activeScene === "break") {
    return {
      title: `Manual Override: ${breakLabel}`,
      detail: "A break screen is pinned until you return to auto mode.",
    };
  }

  if (match.status === "SCHEDULED") {
    return {
      title: "Auto State: Match Intro",
      detail: "This should stay visible until the scorer records the toss.",
    };
  }

  if (match.status === "TOSS_DONE") {
    return {
      title: "Auto State: Toss Result",
      detail: "This should stay visible until the scorer starts the innings.",
    };
  }

  if (match.status === "COMPLETED") {
    return {
      title: "Auto State: Match Result",
      detail: "Result scene is held after match completion.",
    };
  }

  return {
    title: "Auto State: Live Score",
    detail: "Lower-third scoring stays live, and key moments react during play.",
  };
}

function networkQualityColor(q: string) {
  if (q === "good") return "text-green-600 bg-green-500/10";
  if (q === "fair") return "text-yellow-600 bg-yellow-500/10";
  if (q === "poor") return "text-orange-600 bg-orange-500/10";
  return "text-red-600 bg-red-500/10";
}

function LiveTab({ matchId, match }: { matchId: string; match: MatchDetail }) {
  const { data: sceneData } = useStudioSceneQuery(matchId);
  const setSceneMut = useSetStudioSceneMutation();
  const streamMut = useSetMatchStreamMutation();
  const { data: session } = useLiveSessionQuery(matchId);
  const [ytUrl, setYtUrl] = useState(match.youtubeUrl ?? "");
  const [breakType, setBreakType] = useState<string>("drinks");

  const activeScene = sceneData?.scene ?? "standard";
  const activeBreakType = sceneData?.breakType ?? "drinks";
  const automationState = getOverlayAutomationState(
    match,
    activeScene,
    activeBreakType,
  );
  const overlayWidgetUrl = `${API_BASE_URL}/public/overlay/${matchId}/widget`;
  const overlayJsonUrl = `${API_BASE_URL}/public/overlay/${matchId}`;
  const publicMatchUrl = `${PUBLIC_WEB_BASE_URL}/m/${matchId}`;
  const liveCode = match.liveCode ?? null;
  const livePin = match.livePin ?? null;

  // YouTube URL from app heartbeat takes priority over manual entry
  const effectiveYtUrl = session?.youtubeUrl || match.youtubeUrl || ytUrl;

  function extractYtId(url: string): string | null {
    try {
      const u = new URL(url);
      if (u.hostname.includes("youtu.be")) return u.pathname.slice(1).split("?")[0] || null;
      const pathMatch = u.pathname.match(/\/(?:live|shorts|embed)\/([a-zA-Z0-9_-]{11})/);
      if (pathMatch) return pathMatch[1];
      return u.searchParams.get("v");
    } catch {
      return null;
    }
  }

  const ytVideoId = extractYtId(effectiveYtUrl);

  function switchScene(scene: string, bt?: string) {
    setSceneMut.mutate({ id: matchId, scene, breakType: bt ?? null });
  }

  const isActive = !!session;

  return (
    <div className="space-y-6">

      {/* ─── Swing Live Credentials ─── */}
      <div className="rounded-xl border-2 border-dashed border-primary/30 bg-primary/5 p-5 space-y-4">
        <div className="flex items-center gap-3">
          <Smartphone className="h-5 w-5 text-primary" />
          <div>
            <p className="text-sm font-semibold">Swing Live App — Access Credentials</p>
            <p className="text-xs text-muted-foreground mt-0.5">Share these with the camera operator to connect Swing Live</p>
          </div>
        </div>
        {liveCode && livePin ? (
          <div className="grid grid-cols-2 gap-3">
            <div className="rounded-lg bg-background border p-3">
              <p className="text-[10px] text-muted-foreground uppercase tracking-wider mb-1">Match ID</p>
              <div className="flex items-center justify-between gap-2">
                <code className="text-xl font-bold font-mono tracking-widest text-primary">{liveCode}</code>
                <Button size="sm" variant="ghost" className="h-7 w-7 p-0" onClick={() => { navigator.clipboard.writeText(liveCode); toast.success("Match ID copied"); }}>
                  <Copy className="h-3.5 w-3.5" />
                </Button>
              </div>
            </div>
            <div className="rounded-lg bg-background border p-3">
              <p className="text-[10px] text-muted-foreground uppercase tracking-wider mb-1">PIN</p>
              <div className="flex items-center justify-between gap-2">
                <code className="text-xl font-bold font-mono tracking-widest text-primary">{livePin}</code>
                <Button size="sm" variant="ghost" className="h-7 w-7 p-0" onClick={() => { navigator.clipboard.writeText(livePin); toast.success("PIN copied"); }}>
                  <Copy className="h-3.5 w-3.5" />
                </Button>
              </div>
            </div>
          </div>
        ) : (
          <p className="text-xs text-muted-foreground">No credentials generated — this match was created before live access was set up.</p>
        )}
      </div>

      {/* ─── Session Health ─── */}
      <div className={`rounded-xl border-2 p-5 space-y-3 ${isActive ? "border-red-500 bg-red-500/5" : "border-border"}`}>
        <div className="flex items-center justify-between">
          <h3 className="text-sm font-semibold flex items-center gap-2">
            <Activity className="h-4 w-4" />
            Stream Health
            {isActive && (
              <span className="text-xs font-medium bg-red-500/10 text-red-500 px-2 py-0.5 rounded-full flex items-center gap-1">
                <span className="w-1.5 h-1.5 bg-red-500 rounded-full animate-pulse" />
                LIVE
              </span>
            )}
          </h3>
          {isActive && session?.startedAt && (
            <span className="text-[11px] text-muted-foreground">
              Since {new Date(session.startedAt).toLocaleTimeString()}
            </span>
          )}
        </div>

        {isActive ? (
          <div className="grid grid-cols-2 sm:grid-cols-4 gap-3">
            <div className="rounded-lg bg-background border px-3 py-2 text-center">
              <p className="text-xs text-muted-foreground mb-1">Bitrate</p>
              <p className="text-lg font-bold font-mono">{session!.bitrateKbps}<span className="text-xs font-normal text-muted-foreground ml-1">kbps</span></p>
            </div>
            <div className="rounded-lg bg-background border px-3 py-2 text-center">
              <p className="text-xs text-muted-foreground mb-1">FPS</p>
              <p className="text-lg font-bold font-mono">{session!.fps}</p>
            </div>
            <div className="rounded-lg bg-background border px-3 py-2 text-center">
              <p className="text-xs text-muted-foreground mb-1">Quality</p>
              <p className="text-sm font-bold">{session!.quality}</p>
            </div>
            <div className="rounded-lg bg-background border px-3 py-2 text-center">
              <p className="text-xs text-muted-foreground mb-1">Network</p>
              <span className={`text-xs font-bold px-2 py-0.5 rounded-full ${networkQualityColor(session!.networkQuality)}`}>
                {session!.networkQuality?.toUpperCase() ?? "—"}
              </span>
            </div>
          </div>
        ) : (
          <div className="flex items-center gap-3 text-sm text-muted-foreground py-2">
            <WifiOff className="h-4 w-4 shrink-0" />
            <span>No active stream. Open Swing Live app and enter the PIN above to start streaming.</span>
          </div>
        )}
      </div>

      {/* ─── YouTube Preview ─── */}
      <div className="grid grid-cols-1 lg:grid-cols-[1fr_280px] gap-5">
        <div className="space-y-3">
          <h3 className="text-sm font-semibold flex items-center gap-2">
            <Eye className="h-3.5 w-3.5" />
            YouTube Live Preview
          </h3>
          <div className="rounded-xl border bg-black overflow-hidden aspect-video">
            {ytVideoId ? (
              <iframe
                src={`https://www.youtube.com/embed/${ytVideoId}?autoplay=0&mute=1`}
                className="w-full h-full"
                allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
                allowFullScreen
              />
            ) : (
              <div className="w-full h-full flex flex-col items-center justify-center gap-3 text-muted-foreground">
                <Tv2 className="h-10 w-10 opacity-30" />
                <p className="text-sm">No YouTube URL</p>
                <p className="text-xs opacity-60">Auto-filled by app, or paste below</p>
              </div>
            )}
          </div>

          {/* YouTube Watch URL */}
          <div className="flex gap-2">
            <Input
              placeholder="https://youtube.com/watch?v=..."
              value={ytUrl}
              onChange={(e) => setYtUrl(e.target.value)}
              className="flex-1 font-mono text-sm"
            />
            <Button size="sm" disabled={streamMut.isPending} onClick={() => streamMut.mutate({ id: matchId, youtubeUrl: ytUrl.trim() || null })}>
              Save
            </Button>
            {match.youtubeUrl && (
              <Button size="sm" variant="ghost" className="text-destructive" onClick={() => { setYtUrl(""); streamMut.mutate({ id: matchId, youtubeUrl: null }); }}>
                Remove
              </Button>
            )}
          </div>
          <p className="text-[11px] text-muted-foreground">
            Paste the YouTube watch URL so fans can watch on the public match page at{" "}
            <a href={publicMatchUrl} target="_blank" rel="noopener noreferrer" className="text-primary underline-offset-4 hover:underline font-mono">{publicMatchUrl}</a>.
            The Swing Live app sets this automatically when streaming starts.
          </p>

          {/* Overlay Preview */}
          <h3 className="text-sm font-semibold flex items-center gap-2 mt-4">
            <Monitor className="h-3.5 w-3.5" />
            Overlay Preview
            <span className="text-[10px] text-muted-foreground font-normal">(auto-switches with scene)</span>
          </h3>
          <div className="rounded-xl border overflow-hidden bg-neutral-950 aspect-video relative">
            <iframe src={overlayWidgetUrl} className="w-full h-full border-0" />
            {activeScene === "clean" && (
              <div className="absolute inset-0 flex items-center justify-center bg-black/80">
                <p className="text-white/40 text-sm font-medium">Clean Feed — No overlay</p>
              </div>
            )}
          </div>
        </div>

        {/* Right: Scene Control */}
        <div className="space-y-3">
          <div className="rounded-xl border bg-card p-4 space-y-4">
            <div className="flex items-center gap-2">
              <Zap className="h-4 w-4 text-amber-500" />
              <h3 className="text-sm font-semibold">Default Free Pack</h3>
            </div>

            <div className="rounded-lg bg-muted/40 px-3 py-3">
              <p className="text-[11px] font-medium uppercase tracking-wide text-muted-foreground">
                Current State
              </p>
              <p className="mt-2 text-sm font-semibold">{automationState.title}</p>
              <p className="mt-1 text-xs text-muted-foreground">
                {automationState.detail}
              </p>
            </div>

            <div className="space-y-2">
              {DEFAULT_PACK_FLOW.map((item) => (
                <div key={item.title} className="rounded-lg border px-3 py-2.5">
                  <p className="text-sm font-medium">{item.title}</p>
                  <p className="mt-1 text-xs text-muted-foreground">
                    {item.detail}
                  </p>
                </div>
              ))}
            </div>

            <div className="rounded-lg border border-dashed px-3 py-3">
              <p className="text-sm font-medium">Live Moments</p>
              <p className="mt-1 text-xs text-muted-foreground">
                Boundary, six, wicket, and over-to-over changes react during live scoring.
              </p>
            </div>

            <div className="rounded-lg border px-3 py-3 space-y-3">
              <div>
                <p className="text-sm font-medium">Explicit Break Actions</p>
                <p className="mt-1 text-xs text-muted-foreground">
                  Use these for drinks, innings break, and returning back to the auto flow.
                </p>
              </div>
              <div className="grid grid-cols-2 gap-2">
                <Button
                  size="sm"
                  variant={activeScene === "standard" ? "default" : "outline"}
                  onClick={() => switchScene("standard")}
                  disabled={setSceneMut.isPending}
                >
                  Resume Auto
                </Button>
                <Button
                  size="sm"
                  variant={activeScene === "break" && activeBreakType === "drinks" ? "default" : "outline"}
                  onClick={() => {
                    setBreakType("drinks");
                    switchScene("break", "drinks");
                  }}
                  disabled={setSceneMut.isPending}
                >
                  Drinks Break
                </Button>
                <Button
                  size="sm"
                  variant={activeScene === "break" && activeBreakType === "innings" ? "default" : "outline"}
                  onClick={() => {
                    setBreakType("innings");
                    switchScene("break", "innings");
                  }}
                  disabled={setSceneMut.isPending}
                >
                  Innings Break
                </Button>
                <Button
                  size="sm"
                  variant={activeScene === "break" && activeBreakType === "powerplay" ? "default" : "outline"}
                  onClick={() => {
                    setBreakType("powerplay");
                    switchScene("break", "powerplay");
                  }}
                  disabled={setSceneMut.isPending}
                >
                  Powerplay
                </Button>
              </div>
            </div>

            <div className="rounded-lg border border-dashed px-3 py-3">
              <p className="text-sm font-medium">Milestone Moments</p>
              <p className="mt-1 text-xs text-muted-foreground">
                Dedicated scorer-triggered overlay moments for <code>50</code> and <code>100</code> are not wired yet in the current admin scoring flow.
              </p>
            </div>
          </div>

          <div className="space-y-3">
            <h3 className="text-sm font-semibold">Operator Overrides</h3>
            <p className="text-xs text-muted-foreground">
              Auto mode should be the default. Use these only when production needs a forced scene.
            </p>
          </div>
          {SCENES.map((s) => {
            const Icon = s.icon;
            const isSceneActive = activeScene === s.value;
            return (
              <div key={s.value}>
                <button
                  onClick={() => switchScene(s.value === "break" ? "break" : s.value, s.value === "break" ? breakType : undefined)}
                  disabled={setSceneMut.isPending}
                  className={`w-full text-left rounded-xl border-2 p-3.5 transition-all ${
                    isSceneActive ? "border-red-500 bg-red-500/5 shadow-sm" : "border-border hover:border-foreground/20 hover:bg-muted/50"
                  }`}
                >
                  <div className="flex items-center gap-3">
                    <div className={`rounded-lg p-2 ${isSceneActive ? "bg-red-500/10 text-red-500" : "bg-muted text-muted-foreground"}`}>
                      <Icon className="h-4 w-4" />
                    </div>
                    <div className="flex-1 min-w-0">
                      <div className="font-semibold text-sm flex items-center gap-2">
                        {s.label}
                        {isSceneActive && <span className="text-[10px] font-bold text-red-500 bg-red-500/10 px-1.5 py-0.5 rounded">ACTIVE</span>}
                      </div>
                      <div className="text-xs text-muted-foreground truncate">{s.desc}</div>
                    </div>
                  </div>
                </button>
                {s.value === "break" && (
                  <div className="mt-2 ml-12 flex gap-1.5">
                    {BREAK_TYPES.map((bt) => (
                      <button
                        key={bt.value}
                        onClick={() => { setBreakType(bt.value); switchScene("break", bt.value); }}
                        className={`text-xs px-2.5 py-1 rounded-md font-medium transition-colors ${
                          isSceneActive && activeBreakType === bt.value ? "bg-red-500 text-white"
                          : breakType === bt.value && !isSceneActive ? "bg-muted text-foreground"
                          : "bg-muted/50 text-muted-foreground hover:bg-muted/80"
                        }`}
                      >
                        {bt.label}
                      </button>
                    ))}
                  </div>
                )}
              </div>
            );
          })}
          {sceneData?.updatedAt && (
            <p className="text-[11px] text-muted-foreground/60">Last changed: {new Date(sceneData.updatedAt).toLocaleTimeString()}</p>
          )}

          {/* Quick Links */}
          <div className="rounded-xl border border-dashed p-3 space-y-2 text-xs">
            <p className="font-medium text-foreground">Quick Links</p>
            <div className="flex flex-col gap-1.5">
              {[
                { label: "Overlay Widget URL", value: overlayWidgetUrl },
                { label: "JSON API URL", value: overlayJsonUrl },
                { label: "SSE Stream URL", value: `${API_BASE_URL}/public/overlay/${matchId}/stream` },
              ].map(({ label, value }) => (
                <button
                  key={label}
                  className="bg-muted hover:bg-muted/80 px-3 py-1.5 rounded-md font-medium transition-colors text-left flex items-center justify-between gap-2"
                  onClick={() => { navigator.clipboard.writeText(value); toast.success(`${label} copied`); }}
                >
                  <span className="truncate text-muted-foreground">{label}</span>
                  <Copy className="h-3 w-3 shrink-0" />
                </button>
              ))}
              <button
                className="bg-muted hover:bg-muted/80 px-3 py-1.5 rounded-md font-medium transition-colors text-left flex items-center justify-between gap-2"
                onClick={() => window.open(publicMatchUrl, "_blank")}
              >
                <span className="truncate text-muted-foreground">Public Match Page</span>
                <ExternalLink className="h-3 w-3 shrink-0" />
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}

// ─── Page ─────────────────────────────────────────────────────────────────────

export default function MatchDetailPage() {
  const { id } = useParams<{ id: string }>();
  const router = useRouter();
  const { data: match, isLoading } = useMatchDetailQuery(id);
  const completeMut = useCompleteMatchMutation();
  const deleteMut = useDeleteMatchMutation();

  const [maxOvers, setMaxOvers] = useState(20);
  const [ppOvers, setPPOvers] = useState(6);
  const [completeOpen, setCompleteOpen] = useState(false);
  const [deleteOpen, setDeleteOpen] = useState(false);
  const [winner, setWinner] = useState<"A" | "B" | "NO_RESULT">("A");

  // Default powerplay overs per ICC rules
  // ONE_DAY uses 3-phase system (P1/P2/P3) handled separately in ScoreHeader
  const FORMAT_PP: Record<string, number> = {
    T20: 6, // overs 1-6 mandatory PP
    T10: 3, // overs 1-3 mandatory PP (ICC T10 rules)
    ONE_DAY: 10, // P1 boundary (phases P1/P2/P3 shown in ScoreHeader)
    BOX_CRICKET: 2, // first 2 overs
    TWO_INNINGS: 0,
    TEST: 0,
    CUSTOM: 0, // user defines
  };

  useEffect(() => {
    if (!match?.format) return;
    // customOvers always wins — set by admin in setup tab to override tournament default
    if (match.customOvers)
      setMaxOvers(match.customOvers);
    else if (match.format === "TEST" && match.oversPerDay)
      setMaxOvers(match.oversPerDay);
    else setMaxOvers(FORMAT_OVERS[match.format] ?? 20);
    setPPOvers(FORMAT_PP[match.format] ?? 0);
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [match?.format, match?.customOvers, match?.oversPerDay]);

  if (isLoading) {
    return (
      <div className="max-w-5xl mx-auto px-4 py-8 space-y-4">
        <div className="h-8 bg-muted rounded-xl animate-pulse w-32" />
        <div className="h-24 bg-muted rounded-xl animate-pulse" />
        <div className="h-96 bg-muted rounded-xl animate-pulse" />
      </div>
    );
  }
  if (!match) {
    return (
      <div className="max-w-5xl mx-auto px-4 py-20 text-center">
        <p className="text-muted-foreground">Match not found.</p>
        <Button
          variant="outline"
          className="mt-4"
          onClick={() => router.push("/admin/matches")}
        >
          Back
        </Button>
      </div>
    );
  }

  const isLive = match.status === "IN_PROGRESS";
  const publicMatchUrl = `${PUBLIC_WEB_BASE_URL}/m/${match.id}`;

  async function copyPublicMatchUrl() {
    try {
      await navigator.clipboard.writeText(publicMatchUrl);
      toast.success("Match link copied");
    } catch {
      toast.error("Could not copy match link");
    }
  }

  return (
    <div className="max-w-5xl mx-auto px-4 py-6 space-y-5">
      {/* Top bar */}
      <div className="flex items-center justify-between">
        <Button
          variant="ghost"
          size="sm"
          onClick={() => router.push("/admin/matches")}
          className="gap-1.5 -ml-2"
        >
          <ArrowLeft className="w-4 h-4" /> Matches
        </Button>
        <div className="flex items-center gap-2">
          <a
            href={publicMatchUrl}
            target="_blank"
            rel="noopener noreferrer"
            className="text-xs text-primary underline underline-offset-2"
          >
            Live ↗
          </a>
          {isLive && (
            <Button
              size="sm"
              variant="outline"
              onClick={() => setCompleteOpen(true)}
            >
              Complete Match
            </Button>
          )}
          <Button
            size="sm"
            variant="destructive"
            onClick={() => setDeleteOpen(true)}
            className="gap-1.5"
          >
            <Trash2 className="w-3.5 h-3.5" /> Delete
          </Button>
        </div>
      </div>

      {/* Match header */}
      <div
        className={`rounded-xl border bg-card px-5 py-4 space-y-3 ${match.status === "COMPLETED" ? "border-emerald-200" : ""}`}
      >
        <div className="flex items-center gap-2 flex-wrap">
          <span
            className={`text-xs font-semibold px-2 py-0.5 rounded-full ${statusColor(match.status)}`}
          >
            {match.status}
          </span>
          <span className="text-xs text-muted-foreground">{match.format}</span>
          {match.venueName && (
            <span className="text-xs text-muted-foreground">
              📍 {match.venueName}
            </span>
          )}
        </div>
        <h1 className="text-xl font-bold leading-tight">
          {match.teamAName}{" "}
          <span className="text-muted-foreground font-normal">vs</span>{" "}
          {match.teamBName}
        </h1>
        <div className="rounded-lg border bg-muted/20 p-3 space-y-2">
          <div className="flex items-center justify-between gap-3">
            <p className="text-xs font-medium uppercase tracking-[0.18em] text-muted-foreground">
              Match URL
            </p>
            <div className="flex items-center gap-2">
              <Button
                size="sm"
                variant="ghost"
                className="h-8 gap-1.5 px-2"
                onClick={copyPublicMatchUrl}
              >
                <Copy className="h-3.5 w-3.5" />
                Copy
              </Button>
              <Button
                size="sm"
                variant="outline"
                className="h-8 gap-1.5"
                asChild
              >
                <a
                  href={publicMatchUrl}
                  target="_blank"
                  rel="noopener noreferrer"
                >
                  <ExternalLink className="h-3.5 w-3.5" />
                  Open
                </a>
              </Button>
            </div>
          </div>
          <Input
            readOnly
            value={publicMatchUrl}
            onFocus={(event) => event.currentTarget.select()}
            className="h-9 text-sm"
          />
        </div>

        {/* Winner banner */}
        {match.status === "COMPLETED" &&
          (() => {
            // Derive win margin from innings if not stored (older matches)
            const inn1 = match.innings.find((i) => i.inningsNumber === 1);
            const inn2 = match.innings.find((i) => i.inningsNumber === 2);
            let margin = match.winMargin ?? null;
            if (!margin && inn1 && inn2 && match.winnerId) {
              const inn2Team =
                inn2.battingTeam === "A" ? match.teamAName : match.teamBName;
              if (match.winnerId === inn2Team) {
                const wk = 10 - inn2.totalWickets;
                margin = `${wk} wicket${wk !== 1 ? "s" : ""}`;
              } else {
                const runs = inn1.totalRuns - inn2.totalRuns;
                margin = `${runs} run${runs !== 1 ? "s" : ""}`;
              }
            }
            return (
              <div className="rounded-lg bg-emerald-50 border border-emerald-200 px-4 py-3 flex items-center gap-3">
                <span className="text-2xl">🏆</span>
                <div>
                  {match.winnerId ? (
                    <>
                      <p className="text-sm font-black text-emerald-800">
                        {match.winnerId} won!
                      </p>
                      {margin && margin !== "Tied" && (
                        <p className="text-xs text-emerald-600">by {margin}</p>
                      )}
                    </>
                  ) : (
                    <p className="text-sm font-bold text-muted-foreground">
                      {margin === "Tied" ? "Match Tied" : "No Result"}
                    </p>
                  )}
                </div>
              </div>
            );
          })()}

        {match.innings.length > 0 && (
          <div className="flex gap-6 pt-2 border-t">
            {match.innings.map((inn) => {
              const teamName =
                inn.battingTeam === "A" ? match.teamAName : match.teamBName;
              const isWinner = match.winnerId === teamName;
              return (
                <div key={inn.id}>
                  <p className="text-[10px] text-muted-foreground uppercase tracking-wider flex items-center gap-1">
                    {teamName} Inn {inn.inningsNumber}
                    {isWinner && <span className="text-emerald-600">🏆</span>}
                  </p>
                  <p className="text-2xl font-black">
                    {inn.totalRuns}
                    <span className="text-muted-foreground font-normal text-base">
                      /{inn.totalWickets}
                    </span>
                    <span className="text-xs text-muted-foreground font-normal ml-1.5">
                      ({fmtOvers(inn.totalOvers)})
                    </span>
                  </p>
                </div>
              );
            })}
          </div>
        )}
      </div>

      {/* Main content + sidebar */}
      <div className="grid grid-cols-1 lg:grid-cols-[1fr_270px] gap-5 items-start">
        <div>
          <Tabs defaultValue={isLive ? "score" : "setup"}>
            <TabsList className="flex w-full overflow-x-auto">
              <TabsTrigger value="setup" className="flex-1 whitespace-nowrap min-w-fit">Setup</TabsTrigger>
              <TabsTrigger value="score" className="flex flex-1 items-center gap-1.5 whitespace-nowrap min-w-fit">
                Score{" "}
                {isLive && (
                  <span className="w-1.5 h-1.5 bg-emerald-500 rounded-full animate-pulse" />
                )}
              </TabsTrigger>
              <TabsTrigger value="scorecard" className="flex-1 whitespace-nowrap min-w-fit">Scorecard</TabsTrigger>
              <TabsTrigger value="commentary" className="flex-1 whitespace-nowrap min-w-fit">Commentary</TabsTrigger>
              <TabsTrigger value="analysis" className="flex-1 whitespace-nowrap min-w-fit">Analysis</TabsTrigger>
              <TabsTrigger
                value="overlay"
                className="flex flex-1 items-center gap-1.5 whitespace-nowrap min-w-fit"
              >
                <Tv2 className="h-3.5 w-3.5" />
                Overlay
              </TabsTrigger>
              <TabsTrigger
                value="studio"
                className="flex flex-1 items-center gap-1.5 whitespace-nowrap min-w-fit"
              >
                <Radio className="h-3.5 w-3.5" />
                Live
                {isLive && (
                  <span className="w-1.5 h-1.5 bg-red-500 rounded-full animate-pulse" />
                )}
              </TabsTrigger>
            </TabsList>
            <TabsContent value="setup" className="mt-5">
              <SetupTab
                matchId={id}
                format={match.format}
                maxOvers={maxOvers}
                setMaxOvers={setMaxOvers}
                ppOvers={ppOvers}
                setPPOvers={setPPOvers}
              />
            </TabsContent>
            <TabsContent value="score" className="mt-5">
              <ScoreTab matchId={id} maxOvers={maxOvers} ppOvers={ppOvers} />
            </TabsContent>
            <TabsContent value="scorecard" className="mt-5">
              <ScorecardTab matchId={id} />
            </TabsContent>
            <TabsContent value="commentary" className="mt-5">
              <CommentaryTab matchId={id} />
            </TabsContent>
            <TabsContent value="analysis" className="mt-5">
              <AnalysisTab matchId={id} />
            </TabsContent>
            <TabsContent value="overlay" className="mt-5">
              <OverlayTab matchId={id} youtubeUrl={match.youtubeUrl} />
            </TabsContent>
            <TabsContent value="studio" className="mt-5">
              <LiveTab matchId={id} match={match} />
            </TabsContent>
          </Tabs>
        </div>

        <div className="lg:sticky lg:top-6">
          <OverSummaryPanel matchId={id} />
        </div>
      </div>

      {/* Complete match */}
      <Dialog
        open={completeOpen}
        onOpenChange={(o) => !o && setCompleteOpen(false)}
      >
        <DialogContent className="max-w-sm">
          <DialogHeader>
            <DialogTitle>Complete Match</DialogTitle>
          </DialogHeader>
          <div className="py-3 space-y-3">
            <p className="text-sm text-muted-foreground">Declare the winner.</p>
            <div className="grid grid-cols-3 gap-2">
              {(["A", "B", "NO_RESULT"] as const).map((w) => (
                <button
                  key={w}
                  onClick={() => setWinner(w)}
                  className={`py-2 rounded-lg border text-sm font-semibold transition-colors ${winner === w ? "bg-primary text-primary-foreground" : "hover:bg-muted"}`}
                >
                  {w === "A"
                    ? match.teamAName
                    : w === "B"
                      ? match.teamBName
                      : "No Result"}
                </button>
              ))}
            </div>
          </div>
          <DialogFooter>
            <Button variant="outline" onClick={() => setCompleteOpen(false)}>
              Cancel
            </Button>
            <Button
              disabled={completeMut.isPending}
              onClick={() =>
                completeMut.mutate(
                  {
                    matchId: id,
                    tournamentId: match.tournamentId ?? "",
                    winner,
                  },
                  { onSuccess: () => setCompleteOpen(false) },
                )
              }
            >
              {completeMut.isPending ? "Saving…" : "Confirm"}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>

      {/* Delete match */}
      <Dialog
        open={deleteOpen}
        onOpenChange={(o) => !o && setDeleteOpen(false)}
      >
        <DialogContent className="max-w-sm">
          <DialogHeader>
            <DialogTitle>Delete Match?</DialogTitle>
          </DialogHeader>
          <p className="text-sm text-muted-foreground">
            Permanently deletes the match and all ball events. Cannot be undone.
          </p>
          <DialogFooter>
            <Button variant="outline" onClick={() => setDeleteOpen(false)}>
              Cancel
            </Button>
            <Button
              variant="destructive"
              disabled={deleteMut.isPending}
              onClick={() =>
                deleteMut.mutate(id, {
                  onSuccess: () => router.push("/admin/matches"),
                })
              }
            >
              {deleteMut.isPending ? "Deleting…" : "Delete Match"}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </div>
  );
}
