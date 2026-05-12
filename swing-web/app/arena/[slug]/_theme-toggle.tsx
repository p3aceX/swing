"use client";

import { useEffect, useState } from "react";

const STORAGE_KEY = "arena-theme";

function readInitial(): "light" | "dark" {
  if (typeof window === "undefined") return "light";
  const saved = window.localStorage.getItem(STORAGE_KEY);
  if (saved === "light" || saved === "dark") return saved;
  return window.matchMedia?.("(prefers-color-scheme: dark)").matches ? "dark" : "light";
}

export default function ThemeToggle() {
  const [theme, setTheme] = useState<"light" | "dark">("light");
  const [mounted, setMounted] = useState(false);

  useEffect(() => {
    const t = readInitial();
    setTheme(t);
    setMounted(true);
    document.documentElement.setAttribute("data-theme", t);
  }, []);

  function toggle() {
    const next = theme === "dark" ? "light" : "dark";
    setTheme(next);
    document.documentElement.setAttribute("data-theme", next);
    window.localStorage.setItem(STORAGE_KEY, next);
  }

  // While SSR / pre-mount, render in "light" position so server + client
  // markup match; the effect above will move the thumb on mount if needed.
  const mode = mounted ? theme : "light";

  return (
    <button
      type="button"
      className="ms-theme"
      onClick={toggle}
      role="switch"
      aria-checked={theme === "dark"}
      aria-label="Toggle dark mode"
      data-mode={mode}
      suppressHydrationWarning
    >
      <span className="ms-theme-thumb" aria-hidden="true" />
      <span className="ms-theme-icons" aria-hidden="true">
        <span className="ms-theme-sun">
          <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="4"/><path d="M12 2v2M12 20v2M4.93 4.93l1.41 1.41M17.66 17.66l1.41 1.41M2 12h2M20 12h2M4.93 19.07l1.41-1.41M17.66 6.34l1.41-1.41"/></svg>
        </span>
        <span className="ms-theme-moon">
          <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M21 12.8A9 9 0 1 1 11.2 3a7 7 0 0 0 9.8 9.8z"/></svg>
        </span>
      </span>
    </button>
  );
}
