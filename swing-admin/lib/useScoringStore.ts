import { create } from "zustand";

export type Sheet =
  | "bowler"       // must pick next bowler (non-dismissible)
  | "newBatter"    // must pick new batter (non-dismissible)
  | "wicket"       // wicket dismissal details
  | "noBall"       // bat / bye / no run choice
  | "wideRuns"     // extra runs on a wide
  | "bye"          // bye runs picker
  | "legBye"       // leg-bye runs picker
  | null;

interface PersistedState {
  strikerId:       string | null;
  nonStrikerId:    string | null;
  currentBowlerId: string | null;
  lastBowlerId:    string | null;   // filtered out of next bowler picker
}

type BackendSyncState = Partial<PersistedState>;

interface ScoringState extends PersistedState {
  matchId:          string | null;
  scoringBlocked:   boolean;         // true while bowler/batter must be selected
  newBatterPos:     "striker" | "nonStriker";
  activeSheet:      Sheet;
  // After over+wicket we need bowler AFTER batter — queue it
  pendingBowler:    boolean;
  // Initial innings setup: striker → non-striker → bowler chain
  inSetupFlow:      boolean;
}

interface ScoringActions {
  /**
   * Call once when the scoring screen mounts.
   * Loads from localStorage first; falls back to backend-persisted state.
   */
  init: (matchId: string, backendState?: BackendSyncState) => void;

  /**
   * Begin the 3-step new-innings setup: striker → non-striker → bowler.
   * Clears all player state and opens the striker picker.
   */
  startSetupFlow: () => void;

  /** Set individual player slots */
  setStriker:    (id: string | null) => void;
  setNonStriker: (id: string | null) => void;

  /** User picked a bowler from BowlerSheet */
  selectNextBowler: (id: string) => void;

  /** User picked a new batter from NewBatterSheet */
  selectNewBatter: (id: string) => void;

  /**
   * Force-sync store from backend (bypasses localStorage).
   * Use after undo to restore the correct player state.
   */
  syncFromBackend: (state: BackendSyncState, needNewBowler?: boolean) => void;

  /**
   * Call when innings ends (by wickets or overs) so store is reset cleanly.
   * Does NOT open any sheets — the useEffect will trigger setup for the new innings.
   */
  resetForNewInnings: () => void;

  /** Open / close sheets */
  openSheet:      (sheet: NonNullable<Sheet>) => void;
  closeSheet:     () => void;

  /** Set which position the incoming batter should fill */
  setNewBatterPos: (pos: "striker" | "nonStriker") => void;

  /** Swap striker and non-striker (both present) */
  swapBatters: () => void;
}

type Store = ScoringState & ScoringActions;

// ─── Helpers ──────────────────────────────────────────────────────────────────

function lsKey(matchId: string) {
  return `swing-scorer-${matchId}`;
}

function save(state: PersistedState & { matchId: string | null }) {
  if (!state.matchId) return;
  localStorage.setItem(lsKey(state.matchId), JSON.stringify({
    strikerId:       state.strikerId,
    nonStrikerId:    state.nonStrikerId,
    currentBowlerId: state.currentBowlerId,
    lastBowlerId:    state.lastBowlerId,
  } satisfies PersistedState));
}

// ─── Store ────────────────────────────────────────────────────────────────────

export const useScoringStore = create<Store>((set, get) => ({
  // initial state
  matchId:          null,
  strikerId:        null,
  nonStrikerId:     null,
  currentBowlerId:  null,
  lastBowlerId:     null,
  scoringBlocked:   true,
  newBatterPos:     "striker",
  activeSheet:      null,
  pendingBowler:    false,
  inSetupFlow:      false,

  // ── init ──────────────────────────────────────────────────────────────────

  init: (matchId, backendState) => {
    // Try localStorage first (same device, fast)
    let persisted: Partial<PersistedState> = {};
    try {
      const raw = localStorage.getItem(lsKey(matchId));
      if (raw) persisted = JSON.parse(raw);
    } catch { /* ignore */ }

    // Backend is authoritative across devices — another client (e.g. Flutter app) may have
    // changed the striker/bowler since this browser last scored. Prefer backend when non-null;
    // only fall back to localStorage for slots the backend has no value for (e.g. waiting for
    // a new batter after a wicket). lastBowlerId is UI-only so localStorage stays primary there.
    const strikerId = backendState?.strikerId ?? persisted.strikerId ?? null;
    const nonStrikerId = backendState?.nonStrikerId ?? persisted.nonStrikerId ?? null;
    const currentBowlerId = backendState?.currentBowlerId ?? persisted.currentBowlerId ?? null;
    const lastBowlerId = persisted.lastBowlerId ?? backendState?.lastBowlerId ?? null;

    set({
      matchId,
      strikerId,
      nonStrikerId,
      currentBowlerId,
      lastBowlerId,
      scoringBlocked:  false,
      activeSheet:     null,
      pendingBowler:   false,
      inSetupFlow:     false,
    });

    // Sync backend state to localStorage so same device is up to date
    if (strikerId || nonStrikerId || currentBowlerId) {
      try {
        localStorage.setItem(lsKey(matchId), JSON.stringify({ strikerId, nonStrikerId, currentBowlerId, lastBowlerId }));
      } catch { /* ignore */ }
    }
  },

  startSetupFlow: () => {
    const { matchId } = get();
    // Clear all player state for new innings
    const cleared: PersistedState = {
      strikerId: null, nonStrikerId: null,
      currentBowlerId: null, lastBowlerId: null,
    };
    set({
      ...cleared,
      scoringBlocked: true,
      inSetupFlow:    true,
      newBatterPos:   "striker",
      activeSheet:    "newBatter",
      pendingBowler:  false,
    });
    if (matchId) localStorage.setItem(lsKey(matchId), JSON.stringify(cleared));
  },

  // ── player setters ────────────────────────────────────────────────────────

  setStriker: (id) => {
    set({ strikerId: id });
    const s = get();
    save(s);
  },

  setNonStriker: (id) => {
    set({ nonStrikerId: id });
    const s = get();
    save(s);
  },

  // ── selections ────────────────────────────────────────────────────────────

  selectNextBowler: (id) => {
    set({ currentBowlerId: id, activeSheet: null, scoringBlocked: false });
    save(get());
  },

  selectNewBatter: (id) => {
    const { newBatterPos, pendingBowler, inSetupFlow, currentBowlerId } = get();

    if (newBatterPos === "striker") {
      set({ strikerId: id });
      if (inSetupFlow) {
        // Step 2: open non-striker picker
        set({ newBatterPos: "nonStriker", activeSheet: "newBatter" });
        save(get());
        return;
      }
    } else {
      set({ nonStrikerId: id });
      if (inSetupFlow) {
        // Step 3: open bowler picker, end setup flow
        set({ inSetupFlow: false, activeSheet: "bowler" });
        save(get());
        return;
      }
    }

    if (pendingBowler || (!inSetupFlow && !currentBowlerId)) {
      set({ activeSheet: "bowler", pendingBowler: false });
    } else {
      set({ activeSheet: null, scoringBlocked: false });
    }
    save(get());
  },

  // ── backend sync (undo) ───────────────────────────────────────────────────

  syncFromBackend: (state, needNewBowler = false) => {
    const strikerId = state.strikerId ?? null;
    const nonStrikerId = state.nonStrikerId ?? null;
    const currentBowlerId = needNewBowler ? null : (state.currentBowlerId ?? null);
    const nextState: Partial<ScoringState> = {
      strikerId,
      nonStrikerId,
      currentBowlerId,
      lastBowlerId: state.lastBowlerId ?? get().lastBowlerId,
      inSetupFlow: false,
      pendingBowler: false,
    };

    if (!strikerId) {
      nextState.newBatterPos = "striker";
      nextState.scoringBlocked = true;
      nextState.activeSheet = "newBatter";
    } else if (!nonStrikerId) {
      nextState.newBatterPos = "nonStriker";
      nextState.scoringBlocked = true;
      nextState.activeSheet = "newBatter";
    } else if (needNewBowler || !currentBowlerId) {
      nextState.scoringBlocked = true;
      nextState.activeSheet = "bowler";
    } else {
      nextState.scoringBlocked = false;
      nextState.activeSheet = null;
    }

    set(nextState);
    save(get());
  },

  // ── innings reset ─────────────────────────────────────────────────────────

  resetForNewInnings: () => {
    const { matchId } = get();
    const cleared: PersistedState = {
      strikerId: null, nonStrikerId: null,
      currentBowlerId: null, lastBowlerId: null,
    };
    set({
      ...cleared,
      scoringBlocked: true,
      activeSheet: null,
      pendingBowler: false,
      inSetupFlow: false,
    });
    if (matchId) localStorage.setItem(lsKey(matchId), JSON.stringify(cleared));
  },

  // ── sheets ────────────────────────────────────────────────────────────────

  openSheet:      (sheet) => set({ activeSheet: sheet }),
  closeSheet:     ()      => set({ activeSheet: null }),
  setNewBatterPos: (pos)  => set({ newBatterPos: pos }),

  swapBatters: () => {
    const { strikerId, nonStrikerId } = get();
    set({ strikerId: nonStrikerId, nonStrikerId: strikerId });
    save(get());
  },
}));
