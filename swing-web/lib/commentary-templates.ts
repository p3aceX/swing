// ─── Commentary Templates ─────────────────────────────────────────────────────
//
// Every template may use these placeholders:
//   {batter}    — name of the batter on strike
//   {bowler}    — name of the bowler
//   {fielder}   — name of the fielder (for caught / stumped / run-out)
//   {dismissed} — name of the dismissed batter
//   {zone}      — human-readable field zone (e.g. "mid-wicket")
//   {runs}      — number of runs (for multi-run templates)
//
// Selection is deterministic: we hash the ball ID so the same ball always gets
// the same commentary line across refreshes.

// ─── Deterministic pick ───────────────────────────────────────────────────────

function simpleHash(s: string): number {
  let h = 0;
  for (let i = 0; i < s.length; i++) {
    h = (Math.imul(31, h) + s.charCodeAt(i)) >>> 0;
  }
  return h;
}

export function pick<T>(ballId: string, arr: T[]): T {
  return arr[simpleHash(ballId) % arr.length];
}

// ─── Zone display names ───────────────────────────────────────────────────────

const ZONE_LABELS: Record<string, string> = {
  "fine-leg": "fine leg",
  "fine-leg-in": "backward fine leg",
  "square-leg": "square leg",
  "square-leg-in": "backward square leg",
  "mid-wicket": "mid-wicket",
  "mid-wicket-in": "mid-wicket",
  "mid-on": "mid-on",
  "mid-on-in": "straight",
  "mid-off": "mid-off",
  "mid-off-in": "mid-off",
  "extra-cover": "extra cover",
  "extra-cover-in": "the covers",
  "cover": "cover",
  "cover-in": "the inner cover region",
  "point": "point",
  "point-in": "square of the wicket",
  "third-man": "third man",
  "third-man-in": "backward point",
};

export function zoneLabel(zone?: string | null): string {
  return (zone && ZONE_LABELS[zone]) ?? "the field";
}

// ─── Template banks ───────────────────────────────────────────────────────────

// DOT BALL
const DOT_GENERIC = [
  "{bowler} hits a good length — {batter} defends solidly.",
  "Tight line from {bowler}, pushed to {zone} — dot ball.",
  "In the corridor, {batter} plays and misses outside off.",
  "{bowler} beats {batter} in the air — dot ball.",
  "Jams it out to {zone} — no run.",
  "Bowled on a good length, {batter} blocks it dead.",
  "{batter} leaves it alone outside off — good discipline.",
  "Swings and misses! Outside edge just clears the keeper.",
  "Keeps it out watchfully — {batter} staying patient.",
  "Fires it in full and straight — jammed out.",
  "Short and on the stumps, {batter} sways out of the way.",
  "Flighted up, {batter} defends it solidly back down the track.",
  "Good ball from {bowler} — no room offered, {batter} can't score.",
  "Cramps {batter} for room — pushed to {zone}, no run.",
  "Right in the blockhole — {batter} digs it out.",
  "Angling in from {bowler}, {batter} defends to the on side.",
  "Nipped back sharply — hits the front pad, inside edge to {zone}.",
  "{bowler} lands it on a length, {batter} plays it to {zone} — no run.",
];

// SINGLE
const SINGLE_BY_ZONE: Record<string, string[]> = {
  "fine-leg":     ["{batter} tickles it to fine leg — single.", "Glanced fine, they scamper through for one.", "Fine glance off the hip, one run."],
  "fine-leg-in":  ["{batter} glances it into the leg side — quick single.", "Worked off the pads to backward fine leg — one."],
  "square-leg":   ["Turned off the hips to square leg — single.", "Flicked square, {batter} and partner run through."],
  "square-leg-in":["Nudged to backward square leg — one run.", "Clip to the leg side, single taken."],
  "mid-wicket":   ["Clipped to mid-wicket — easy single.", "Pushed to mid-wicket, they jog through for one."],
  "mid-wicket-in":["Worked to mid-wicket — quick single.", "Flicked into the leg side, one run."],
  "mid-on":       ["Pushed straight to mid-on — single.", "Driven down the ground for one."],
  "mid-on-in":    ["Pushed to mid-on — they run a single.", "Driven to mid-on, quick single."],
  "mid-off":      ["Driven to mid-off — one run.", "Quick single to mid-off, good running."],
  "mid-off-in":   ["Punched to mid-off — single.", "Driven back down the wicket for one."],
  "extra-cover":  ["Punched to extra cover — single.", "Driven wide of extra cover for one."],
  "extra-cover-in":["Pushed into the covers — single.", "Drives into the covers, they run."],
  "cover":        ["Driven to cover — single.", "Pushed to cover, quick single taken."],
  "cover-in":     ["Punched to the inner cover ring — single.", "Driven firmly but straight to cover — one."],
  "point":        ["Pushed to point — easy single.", "Cuts it softly to point for one."],
  "point-in":     ["Worked square on the off side — single.", "Nudged to point, they jog through."],
  "third-man":    ["Guided to third man — single.", "Edges to third man, they run one."],
  "third-man-in": ["Steered to backward point — single.", "Late cut to backward point for one."],
};

const SINGLE_GENERIC = [
  "Worked away for a single.",
  "Nudged into the gap for one — good running.",
  "{batter} pushes to {zone} — single.",
  "Dabs it down to {zone} — one run.",
  "Clips it off the pads — single.",
  "Rotates the strike, one run.",
  "Pushes {bowler} to {zone} — single.",
  "Steered to {zone} for one.",
];

// DOUBLE
const DOUBLE_GENERIC = [
  "Driven into the gap at {zone} — two runs! Great running.",
  "Pushed into the outfield, {batter} turns back for two.",
  "Placed to {zone} — they run hard for two.",
  "Two! Good running between the wickets from {batter}.",
  "Drilled to {zone}, fielder fumbles — two taken.",
  "Worked into the gap at {zone} — comfortable two.",
  "Punched to {zone} — {batter} and partner run two.",
];

// TRIPLE
const TRIPLE_GENERIC = [
  "Three! Superb running between the wickets.",
  "Driven hard to the deep, three runs!",
  "Placed to the boundary but short — {batter} hustles for three.",
  "Great placement to {zone}, they run three!",
  "Excellent running! Three taken.",
];

// FOUR — generic fallback
const FOUR_GENERIC = [
  "FOUR! Cracked to the fence — excellent timing from {batter}.",
  "{batter} finds the gap perfectly — races away for four!",
  "FOUR MORE! Brilliant placement, {bowler} has no answer.",
  "Pierced the field to {zone} — boundary!",
  "Timed to perfection — four!",
  "{batter} hits through {zone} — four runs!",
  "Raced away to the fence! {batter} is in fine touch.",
  "Gets into position and dispatches it to {zone} — FOUR!",
];

const FOUR_BY_ZONE: Record<string, string[]> = {
  "fine-leg":     ["FOUR! Tickled away to fine leg — boundary!", "Glanced to fine leg — races away for four!", "Flicked fine, reaches the rope!"],
  "fine-leg-in":  ["Clipped to backward fine leg — four!", "Glanced finely past the keeper — boundary!"],
  "square-leg":   ["FOUR! Pulled hard to square leg — boundary!", "Whipped off the pads, squares the boundary!", "Flat pull to square leg — FOUR!"],
  "square-leg-in":["Swivelled and pulled to backward square — FOUR!", "Clipped to backward square leg — boundary!"],
  "mid-wicket":   ["FOUR! Swept magnificently to mid-wicket!", "Clipped off the toes, races to mid-wicket — boundary!", "Lashes it to the mid-wicket rope — FOUR!"],
  "mid-wicket-in":["FOUR! Whipped to mid-wicket — beautiful timing!", "Driven straight past mid-on — boundary!"],
  "mid-on":       ["Driven straight past the bowler — FOUR!", "Lofted straight — bounces twice before the rope!", "Drives down the ground — FOUR!"],
  "mid-on-in":    ["FOUR! Straight drive — elegant from {batter}!", "Driven straight, beats mid-on — boundary!"],
  "mid-off":      ["FOUR! Driven crisply through mid-off!", "Full, {batter} drives over mid-off — boundary!", "Belts it past mid-off for four!"],
  "mid-off-in":   ["Driven firmly past mid-off — FOUR!", "Punches back past {bowler} — four!"],
  "extra-cover":  ["FOUR! Through extra cover — gorgeous drive!", "Leaning into the drive, races to extra cover boundary!", "Extra cover — perfectly bisected for FOUR!"],
  "extra-cover-in":["FOUR! Driven wide of mid-off into the cover gap!", "Leans and drives — through extra cover for four!"],
  "cover":        ["FOUR! Through the covers — exquisite!", "Cover drive — textbook! Races to the fence!", "FOUR! Drives through the covers with absolute ease."],
  "cover-in":     ["FOUR! Punched through the inner cover region!", "Drives firmly through cover — boundary!"],
  "point":        ["FOUR! Cut hard past point — boundary!", "Square cut — races to the point boundary!", "Late cut, flies past point — FOUR!"],
  "point-in":     ["FOUR! Slashes square, beats point — boundary!", "Cuts hard, pierces the gap at point — four!"],
  "third-man":    ["FOUR! Nicked to third man — boundary!", "Edges wide of gully — races to third man for FOUR!", "Feathered to third man — boundary!"],
  "third-man-in": ["FOUR! Late cut to backward point — boundary!", "Dabs to backward point — races away for four!"],
};

// SIX — generic fallback
const SIX_GENERIC = [
  "SIX! INTO THE STANDS! {batter} is on fire!",
  "MAXIMUM! Clears the rope with ease!",
  "HUGE SIX! Back of a length and still hit for maximum!",
  "{batter} sends {bowler} into the crowd — SIX!",
  "Over the fielder and over the rope — SIX!",
  "SIX! Launches {bowler} into the stands!",
  "Dances down and swings — GONE! Six!",
];

const SIX_BY_ZONE: Record<string, string[]> = {
  "fine-leg":     ["SIX! Heaved to fine leg — over the rope!", "Top-edged but it sails over fine leg for SIX!"],
  "fine-leg-in":  ["SIX over square fine leg! Massive hit!"],
  "square-leg":   ["SIX! Slog sweep to deep square leg — maximum!", "Muscled over square leg — SIX!", "HOISTED over square leg — that's in the stands!"],
  "square-leg-in":["SIX! Ramps it over backward square — maximum!"],
  "mid-wicket":   ["SIX! Flat six over mid-wicket — {batter} is timing it perfectly!", "Pulled mightily over mid-wicket — MAXIMUM!", "HUGE pull over mid-wicket — six!"],
  "mid-wicket-in":["SIX over mid-wicket — {batter} takes on the short ball!"],
  "mid-on":       ["STRAIGHT SIX! Launched over {bowler}'s head!", "Six straight! Lofted down the ground — lands in the stands!", "Driven straight over mid-on — MAXIMUM!"],
  "mid-on-in":    ["SIX! Driven over mid-on — what a shot!", "Long-on boundary — SIX! Straight as an arrow."],
  "mid-off":      ["SIX over long-off! Massive swing from {batter}!", "OVER EXTRA COVER — SIX! That's gone into the stands!", "Launched over mid-off — MAXIMUM!"],
  "mid-off-in":   ["SIX over long-off — {batter} was waiting for that!", "Drives it over mid-off — clears the rope easily!"],
  "extra-cover":  ["SIX over extra cover! Fearless cricket!", "Launched over the cover fielder — SIX!", "OVER EXTRA COVER — absolutely creamed!"],
  "extra-cover-in":["SIX! Driven over extra cover — {batter} is in sublime form!"],
  "cover":        ["SIX over cover! Who hits it over cover?!", "Launched over cover — SIX! Unbelievable power!", "SIX over extra cover — fearless batting!"],
  "cover-in":     ["SIX! Over the cover region — flat and hard!"],
  "point":        ["SIX! Ramps it over the backward point fielder — maximum!", "Unconventional but brilliant — six over point!"],
  "point-in":     ["SIX! Ramps it over backward point — what a scoop!"],
  "third-man":    ["SIX! Ramps it over third man — brilliant improvisation!", "Scoops it over fine leg — SIX!"],
  "third-man-in": ["SIX over backward point — SIX! Unorthodox but brilliant!"],
};

// WIDE
const WIDE_TEMPLATES = [
  "Way down the leg side — wide.",
  "Arm ball drifts too far across — wide called.",
  "Too wide outside off, the umpire signals.",
  "Slides past the tramline — umpire's finger goes up.",
  "Down leg, keeper can't reach it — wide.",
  "Pitched outside the tramline, {bowler} will be disappointed.",
  "Fired down leg — wide signalled.",
  "Down the leg side, {batter} leaves it — wide.",
];

// NO_BALL
const NO_BALL_TEMPLATES = [
  "Front foot no-ball! {bowler} overstepped — free hit coming!",
  "Free hit next ball — {bowler} overstepped.",
  "No-ball! {bowler} gives away a free delivery.",
  "Lands well past the crease — no-ball called.",
  "{bowler} oversteps — free hit for {batter}!",
  "No-ball! Height umpire calls it — too high.",
];

// BYE
const BYE_TEMPLATES = [
  "Beat the bat and the keeper — byes!",
  "Keeper fails to collect — byes added.",
  "Spills past the stumps — byes taken.",
  "Slips through the keeper's gloves — byes!",
];

// LEG BYE
const LEG_BYE_TEMPLATES = [
  "Deflects off the pad — leg bye.",
  "Hits the thigh pad, they run for a leg bye.",
  "Strikes the body, rolls away — leg byes.",
  "Off the pads and away — leg bye taken.",
];

// WICKET — BOWLED
const BOWLED_TEMPLATES = [
  "BOWLED! The timber is shattered — {dismissed} has to go!",
  "Through the gate! Middle stump cartwheels — {dismissed} bowled!",
  "Clean bowled! {bowler} curves one through {dismissed}!",
  "Magnificently bowled! Sneaks under the bat of {dismissed}!",
  "CASTLED! {dismissed} has no answer — bowled by {bowler}!",
  "What a delivery! Off stump uprooted by {bowler}!",
  "The stumps are flying! {dismissed} is bowled!",
  "Clips the top of off stump — {dismissed} is bowled!",
  "Pitches on middle, nips back — {dismissed} is bowled!",
  "Full and straight, crashes into the stumps — {dismissed} is bowled!",
  "Inswinger! Hits the base of leg stump — {dismissed} is bowled!",
  "Through the defence! {dismissed} is clean bowled by {bowler}.",
];

// WICKET — CAUGHT
const CAUGHT_TEMPLATES = [
  "CAUGHT! {fielder} takes a sharp catch — {dismissed} has to go!",
  "Edges it! {fielder} pouches it — {dismissed} caught!",
  "Skies it! Easy catch for {fielder} — {dismissed} is gone!",
  "Feathered edge! {fielder} takes it comfortably — {dismissed} caught!",
  "Caught and bowled! {bowler} takes a sharp return catch — {dismissed} is out!",
  "Holes out to {fielder} — {dismissed} caught in the deep!",
  "Chips straight to {fielder} — {dismissed} walked!",
  "Thick outside edge, {fielder} holds a stunning catch — {dismissed} out!",
  "Top edge spirals up — {fielder} under it — CAUGHT! {dismissed} is out!",
  "Lofted drive didn't have the pace — {fielder} holds it — {dismissed} caught!",
  "Miscues the pull — {fielder} settles under it — {dismissed} is out!",
  "{dismissed} hits it hard but straight to {fielder} — caught!",
];

// WICKET — CAUGHT (no fielder known)
const CAUGHT_NO_FIELDER_TEMPLATES = [
  "CAUGHT! {dismissed} edges and the catch is taken!",
  "Flies off the edge — {dismissed} is caught!",
  "Top edge — {dismissed} is caught in the deep!",
  "Hole out! {dismissed} doesn't time it and is caught!",
  "Hit straight to the fielder — {dismissed} is caught!",
];

// WICKET — LBW
const LBW_TEMPLATES = [
  "LBW! Plumb in front — {dismissed} has to go!",
  "Crashes into the pad! Full and straight — {dismissed} is LBW!",
  "HUGE appeal — given! {dismissed} is LBW to {bowler}!",
  "Nips back sharply, hits the front pad — {dismissed} is out LBW!",
  "Trapped in front! {bowler} gets the breakthrough — LBW!",
  "Slides back in, {dismissed} misses — LBW!",
  "Sweeps but misses — hit on the pad, finger goes up — {dismissed} LBW!",
  "Low full toss, cannons into the pad — {dismissed} is LBW!",
];

// WICKET — RUN_OUT
const RUN_OUT_TEMPLATES = [
  "RUN OUT! Direct hit — {dismissed} is short of the crease!",
  "Sent back too late — {dismissed} is run out! Terrible mix-up!",
  "Direct hit from {fielder}! What an arm — {dismissed} is run out!",
  "Caught in the middle — {dismissed} has nowhere to dive!",
  "Miscommunication! {dismissed} run out — what a waste!",
  "Brilliant pick-up and throw by {fielder} — {dismissed} run out!",
  "DIRECT HIT! {dismissed} is run out — superb fielding!",
  "Dived but couldn't make it — {dismissed} run out!",
];

const RUN_OUT_NO_FIELDER_TEMPLATES = [
  "RUN OUT! Direct hit — {dismissed} is short!",
  "Sent back — {dismissed} is run out! Catastrophic mix-up!",
  "Run out! {dismissed} caught short — brilliant fielding!",
];

// WICKET — STUMPED
const STUMPED_TEMPLATES = [
  "STUMPED! Down the track and missed — {fielder} does the rest! {dismissed} is out!",
  "Dances out, beaten in flight — {dismissed} is stumped!",
  "Goes for the big shot, misses, {fielder} whips the bails off — {dismissed} stumped!",
  "Steps out and plays all around it — {fielder} whips the bails off — STUMPED!",
  "Stumped! {dismissed} was miles out of the crease!",
  "Quick stumping by {fielder} — {dismissed} had no chance!",
];

// WICKET — HIT_WICKET
const HIT_WICKET_TEMPLATES = [
  "HIT WICKET! {dismissed} disturbs the stumps with the backswing — what bad luck!",
  "{dismissed} backs onto the stumps — hit wicket!",
  "Dislodges the bails with the backswing — hit wicket for {dismissed}!",
  "HIT WICKET! {dismissed} loses balance and hits the stumps!",
];

// ─── Public API ───────────────────────────────────────────────────────────────

export type BallCtx = {
  ballId: string;
  batter: string;
  bowler: string;
  fielder?: string | null;
  dismissed?: string | null;
  outcome: string;
  runs: number;
  isWicket: boolean;
  dismissalType?: string | null;
  wagonZone?: string | null;
};

export function generateCommentary(ctx: BallCtx): { title: string; detail: string } {
  const { ballId, batter, bowler, fielder, dismissed, outcome, runs, isWicket, dismissalType, wagonZone } = ctx;
  const zone = zoneLabel(wagonZone);

  function fill(t: string): string {
    return t
      .replace(/\{batter\}/g, batter)
      .replace(/\{bowler\}/g, bowler)
      .replace(/\{fielder\}/g, fielder ?? "the fielder")
      .replace(/\{dismissed\}/g, dismissed ?? batter)
      .replace(/\{zone\}/g, zone)
      .replace(/\{runs\}/g, String(runs));
  }

  let title: string;
  let detail: string;

  if (isWicket) {
    title = "WICKET!";
    let pool: string[];
    switch (dismissalType) {
      case "BOWLED":
        pool = BOWLED_TEMPLATES;
        break;
      case "CAUGHT":
        pool = fielder ? CAUGHT_TEMPLATES : CAUGHT_NO_FIELDER_TEMPLATES;
        break;
      case "LBW":
        pool = LBW_TEMPLATES;
        break;
      case "RUN_OUT":
        pool = fielder ? RUN_OUT_TEMPLATES : RUN_OUT_NO_FIELDER_TEMPLATES;
        break;
      case "STUMPED":
        pool = STUMPED_TEMPLATES;
        break;
      case "HIT_WICKET":
        pool = HIT_WICKET_TEMPLATES;
        break;
      case "RETIRED_HURT":
        return { title: "Retired Hurt", detail: `${batter} retires hurt.` };
      case "RETIRED_OUT":
        return { title: "Retired Out", detail: `${batter} retires out.` };
      default:
        pool = [`${dismissed ?? batter} is out — ${(dismissalType ?? "out").replace(/_/g, " ").toLowerCase()}.`];
    }
    detail = fill(pick(ballId, pool));
    return { title, detail };
  }

  switch (outcome) {
    case "WIDE":
      return { title: "Wide", detail: fill(pick(ballId, WIDE_TEMPLATES)) };
    case "NO_BALL":
      return { title: "No Ball", detail: fill(pick(ballId, NO_BALL_TEMPLATES)) };
    case "BYE":
      return { title: `${runs} Bye${runs !== 1 ? "s" : ""}`, detail: fill(pick(ballId, BYE_TEMPLATES)) };
    case "LEG_BYE":
      return { title: `${runs} Leg Bye${runs !== 1 ? "s" : ""}`, detail: fill(pick(ballId, LEG_BYE_TEMPLATES)) };
    case "SIX": {
      const pool = (wagonZone ? SIX_BY_ZONE[wagonZone] : undefined) ?? SIX_GENERIC;
      return { title: "SIX!", detail: fill(pick(ballId, pool)) };
    }
    case "FOUR": {
      const pool = (wagonZone ? FOUR_BY_ZONE[wagonZone] : undefined) ?? FOUR_GENERIC;
      return { title: "FOUR!", detail: fill(pick(ballId, pool)) };
    }
    case "TRIPLE":
      return { title: "3 Runs!", detail: fill(pick(ballId, TRIPLE_GENERIC)) };
    case "DOUBLE":
      return { title: "2 Runs", detail: fill(pick(ballId, DOUBLE_GENERIC)) };
    case "SINGLE": {
      const zonePool = wagonZone ? SINGLE_BY_ZONE[wagonZone] : undefined;
      const pool = zonePool ?? SINGLE_GENERIC;
      return { title: "1 Run", detail: fill(pick(ballId, pool)) };
    }
    case "DOT":
    default: {
      if (runs === 0) {
        return { title: "Dot", detail: fill(pick(ballId, DOT_GENERIC)) };
      }
      // Fallback for any runs > 0
      if (runs >= 6) return { title: "SIX!", detail: fill(pick(ballId, SIX_GENERIC)) };
      if (runs === 4) return { title: "FOUR!", detail: fill(pick(ballId, FOUR_GENERIC)) };
      if (runs === 3) return { title: "3 Runs!", detail: fill(pick(ballId, TRIPLE_GENERIC)) };
      if (runs === 2) return { title: "2 Runs", detail: fill(pick(ballId, DOUBLE_GENERIC)) };
      return { title: "1 Run", detail: fill(pick(ballId, SINGLE_GENERIC)) };
    }
  }
}
