"use client";

// SVG wagon wheel — 1:1 port of the Flutter `ScoringWagonWheel`.
// 8 zones clockwise from FINE_LEG at the top, with a stylised pitch
// (bat / stumps / ball) in the inner ring. Tap a zone to score with
// that wagonZone set on the ball event.

const ZONES = [
  "FINE_LEG",
  "SQUARE_LEG",
  "MID_WICKET",
  "LONG_ON",
  "LONG_OFF",
  "COVER",
  "POINT",
  "THIRD_MAN",
] as const;

export type WagonZone = (typeof ZONES)[number];

const ZONE_LABELS: Record<WagonZone, string> = {
  FINE_LEG: "Fine\nLeg",
  SQUARE_LEG: "Sq\nLeg",
  MID_WICKET: "Mid\nWkt",
  LONG_ON: "Long\nOn",
  LONG_OFF: "Long\nOff",
  COVER: "Cover",
  POINT: "Point",
  THIRD_MAN: "3rd\nMan",
};

const SWEEP = (2 * Math.PI) / 8;

// Canvas size in SVG units — actual render size comes from the wrapping
// container's width (we keep the SVG aspect 1:1 via `viewBox`).
const SIZE = 320;
const C = SIZE / 2;
const R = C - 4;
const INNER_R = R * 0.58;
const MID_R = (R + INNER_R) / 2;

function polar(cx: number, cy: number, r: number, angle: number) {
  return { x: cx + Math.cos(angle) * r, y: cy + Math.sin(angle) * r };
}

// Build the SVG path for an annular wedge (outer ring slice) for zone i.
function wedgePath(i: number): string {
  const start = -Math.PI / 2 + i * SWEEP;
  const end = start + SWEEP;
  const p1 = polar(C, C, R, start);
  const p2 = polar(C, C, R, end);
  const p3 = polar(C, C, INNER_R, end);
  const p4 = polar(C, C, INNER_R, start);
  // Outer arc → line in → inner arc back → close
  return [
    `M ${p1.x.toFixed(2)} ${p1.y.toFixed(2)}`,
    `A ${R} ${R} 0 0 1 ${p2.x.toFixed(2)} ${p2.y.toFixed(2)}`,
    `L ${p3.x.toFixed(2)} ${p3.y.toFixed(2)}`,
    `A ${INNER_R} ${INNER_R} 0 0 0 ${p4.x.toFixed(2)} ${p4.y.toFixed(2)}`,
    "Z",
  ].join(" ");
}

function labelPos(i: number) {
  const mid = -Math.PI / 2 + i * SWEEP + SWEEP / 2;
  return polar(C, C, MID_R, mid);
}

export function WagonWheel({
  selectedZone,
  onZoneTap,
}: {
  selectedZone: WagonZone | null;
  onZoneTap: (zone: WagonZone) => void;
}) {
  return (
    <div className="mx-auto aspect-square w-full max-w-[280px]">
      <svg
        viewBox={`0 0 ${SIZE} ${SIZE}`}
        className="w-full h-full block"
        role="img"
        aria-label="Wagon wheel — tap a zone to score"
      >
        {/* Outer field */}
        <circle cx={C} cy={C} r={R} fill="#1F3A2E" />
        {/* Inner pitch ring */}
        <circle cx={C} cy={C} r={INNER_R} fill="#16241D" />

        {/* Zone wedges */}
        {ZONES.map((zone, i) => {
          const isSel = selectedZone === zone;
          return (
            <path
              key={zone}
              d={wedgePath(i)}
              fill={isSel ? "rgba(255,255,255,0.32)" : "transparent"}
              stroke="rgba(255,255,255,0.18)"
              strokeWidth={1}
              className="cursor-pointer"
              onClick={() => onZoneTap(zone)}
            />
          );
        })}

        {/* OFF / LEG watermarks */}
        <text
          x={C + INNER_R * 0.5}
          y={C - INNER_R * 0.15}
          fill="rgba(255,255,255,0.18)"
          fontSize={14}
          fontWeight={900}
          textAnchor="middle"
          dominantBaseline="middle"
          letterSpacing="2"
          style={{ pointerEvents: "none" }}
        >
          LEG
        </text>
        <text
          x={C - INNER_R * 0.5}
          y={C - INNER_R * 0.15}
          fill="rgba(255,255,255,0.18)"
          fontSize={14}
          fontWeight={900}
          textAnchor="middle"
          dominantBaseline="middle"
          letterSpacing="2"
          style={{ pointerEvents: "none" }}
        >
          OFF
        </text>

        <PitchArea />

        {/* Zone labels */}
        {ZONES.map((zone, i) => {
          const p = labelPos(i);
          const isSel = selectedZone === zone;
          const lines = ZONE_LABELS[zone].split("\n");
          return (
            <text
              key={`label-${zone}`}
              x={p.x}
              y={p.y - (lines.length - 1) * 6}
              fill={
                isSel
                  ? "rgba(255,255,255,1)"
                  : "rgba(255,255,255,0.78)"
              }
              fontSize={11}
              fontWeight={isSel ? 800 : 500}
              textAnchor="middle"
              dominantBaseline="middle"
              style={{ pointerEvents: "none" }}
            >
              {lines.map((line, j) => (
                <tspan key={j} x={p.x} dy={j === 0 ? 0 : 12}>
                  {line}
                </tspan>
              ))}
            </text>
          );
        })}

        {/* Inner ring stroke */}
        <circle
          cx={C}
          cy={C}
          r={INNER_R}
          fill="none"
          stroke="rgba(255,255,255,0.22)"
          strokeWidth={1}
        />
      </svg>
    </div>
  );
}

function PitchArea() {
  const pitchW = INNER_R * 0.13;
  const pitchH = INNER_R * 1.1;
  const halfH = pitchH / 2;
  const creaseOff = halfH * 0.7;
  return (
    <g style={{ pointerEvents: "none" }}>
      {/* Pitch strip */}
      <rect
        x={C - pitchW / 2}
        y={C - halfH}
        width={pitchW}
        height={pitchH}
        rx={2.5}
        fill="#CBA882"
      />
      {/* Crease lines */}
      {[-creaseOff, creaseOff].map((dy, i) => (
        <line
          key={i}
          x1={C - pitchW / 2 - 2}
          y1={C + dy}
          x2={C + pitchW / 2 + 2}
          y2={C + dy}
          stroke="rgba(255,255,255,0.6)"
          strokeWidth={0.8}
        />
      ))}
      {/* Bat at top (bowling end) */}
      <g transform={`translate(${C}, ${C - halfH - 10})`}>
        <rect
          x={-3.5}
          y={-2}
          width={7}
          height={13}
          rx={1.5}
          fill="rgba(255,255,255,0.5)"
        />
        <rect
          x={-1.25}
          y={-10}
          width={2.5}
          height={8}
          rx={1}
          fill="rgba(255,255,255,0.5)"
        />
      </g>
      {/* Stumps in middle */}
      <g fill="#D4A55A">
        {[-1, 0, 1].map((i) => (
          <rect
            key={i}
            x={C + i * 4 - 1.25}
            y={C - 6}
            width={2.5}
            height={16}
            rx={1}
          />
        ))}
        <rect x={C - 6} y={C - 6.4} width={12} height={1.8} rx={1} />
      </g>
      {/* Ball at bottom (batting end) */}
      <g transform={`translate(${C}, ${C + halfH + 10})`}>
        <circle r={7} fill="rgba(204,34,0,0.72)" />
        <path
          d="M -4 0 A 4 4 0 0 1 4 0"
          fill="none"
          stroke="rgba(255,255,255,0.45)"
          strokeWidth={0.9}
        />
      </g>
    </g>
  );
}

export const ZONE_LABEL: Record<WagonZone, string> = {
  FINE_LEG: "Fine Leg",
  SQUARE_LEG: "Square Leg",
  MID_WICKET: "Mid Wicket",
  LONG_ON: "Long On",
  LONG_OFF: "Long Off",
  COVER: "Cover",
  POINT: "Point",
  THIRD_MAN: "Third Man",
};
