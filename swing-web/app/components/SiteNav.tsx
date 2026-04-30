"use client";

import { useState, useEffect } from "react";

type Props = {
  /** Extra action rendered on the right, e.g. a "Book a slot" CTA */
  rightAction?: React.ReactNode;
};

export default function SiteNav({ rightAction }: Props) {
  const [theme, setTheme] = useState<"dark" | "light">("dark");

  // Sync with <html data-theme>
  useEffect(() => {
    const stored = localStorage.getItem("swingTheme") as "dark" | "light" | null;
    const initial = stored ?? "dark";
    setTheme(initial);
    document.documentElement.setAttribute("data-theme", initial);
  }, []);

  function toggleTheme() {
    const next = theme === "dark" ? "light" : "dark";
    setTheme(next);
    localStorage.setItem("swingTheme", next);
    document.documentElement.setAttribute("data-theme", next);
  }

  return (
    <>
      <style>{`
        .sw-nav {
          position: sticky; top: 0; left: 0; right: 0; z-index: 50;
          padding: 10px 0;
          backdrop-filter: blur(14px);
          -webkit-backdrop-filter: blur(14px);
          background: color-mix(in oklab, var(--bg, #F4F2EB) 70%, transparent);
          border-bottom: 1px solid var(--line, rgba(10,11,10,0.10));
        }
        .sw-nav-inner {
          max-width: 1240px; margin: 0 auto; padding: 0 32px;
          display: flex; align-items: center; justify-content: space-between; gap: 24px;
        }
        .sw-brand {
          display: flex; align-items: center; gap: 10px;
          text-decoration: none; color: var(--fg, #0A0B0A);
          flex-shrink: 0;
        }
        .sw-brand-logo {
          width: 32px; height: 32px;
          display: inline-flex; align-items: center; justify-content: center;
          transition: transform .4s cubic-bezier(.34,1.56,.64,1);
        }
        .sw-brand-logo img { width: 32px; height: 32px; object-fit: contain; display: block; }
        .sw-brand-logo .logo-light { display: none; }
        [data-theme="light"] .sw-brand-logo .logo-dark { display: none; }
        [data-theme="light"] .sw-brand-logo .logo-light { display: block; }
        .sw-brand:hover .sw-brand-logo { transform: rotate(-12deg) scale(1.05); }
        .sw-brand-word {
          font-weight: 800; font-style: italic;
          letter-spacing: -0.045em; font-size: 22px; line-height: 1;
        }
        .sw-nav-links {
          display: flex; gap: 24px; align-items: center;
        }
        .sw-nav-links a {
          font-size: 13px; color: var(--mute, rgba(10,11,10,0.55)); font-weight: 500;
          transition: color .15s; text-decoration: none;
        }
        .sw-nav-links a:hover { color: var(--fg, #0A0B0A); }
        .sw-nav-right { display: flex; gap: 10px; align-items: center; }
        .sw-theme-btn {
          width: 38px; height: 38px; border-radius: 999px;
          background: var(--card, rgba(10,11,10,0.03));
          border: 1px solid var(--line, rgba(10,11,10,0.10));
          display: flex; align-items: center; justify-content: center;
          cursor: pointer; color: var(--fg, #0A0B0A);
          transition: background .15s, transform .2s;
          flex-shrink: 0;
        }
        .sw-theme-btn:hover { background: var(--line); transform: rotate(20deg); }
        .sw-theme-btn svg { width: 16px; height: 16px; }
        .sw-theme-btn .sun { display: none; }
        [data-theme="light"] .sw-theme-btn .sun { display: block; }
        [data-theme="light"] .sw-theme-btn .moon { display: none; }
        .sw-nav-cta {
          font-size: 13px; font-weight: 600; padding: 10px 18px;
          border-radius: 999px; background: var(--accent, #2BA84A);
          color: var(--accent-ink, #fff);
          white-space: nowrap; text-decoration: none;
          border: none; cursor: pointer;
          transition: transform .15s;
          display: inline-block;
        }
        .sw-nav-cta:hover { transform: translateY(-1px); }
        [data-theme="dark"] .sw-nav {
          background: #0A0B0A;
        }
        @media (max-width: 980px) {
          .sw-nav-links { display: none; }
          .sw-nav-inner { padding: 0 16px; }
        }
      `}</style>

      <nav className="sw-nav">
        <div className="sw-nav-inner">
          <a href="https://swingcricketapp.com" className="sw-brand">
            <span className="sw-brand-logo" aria-hidden="true">
              {/* eslint-disable-next-line @next/next/no-img-element */}
              <img className="logo-dark" src="/assets/logo-dark.png" alt="" width={32} height={32} />
              {/* eslint-disable-next-line @next/next/no-img-element */}
              <img className="logo-light" src="/assets/logo-light.png" alt="" width={32} height={32} />
            </span>
            <span className="sw-brand-word">Swing</span>
          </a>

          <div className="sw-nav-links">
            <a href="https://swingcricketapp.com#player">Player</a>
            <a href="https://swingcricketapp.com#biz">Biz</a>
            <a href="https://swingcricketapp.com#live">Live</a>
            <a href="https://swingcricketapp.com#points">Rewards</a>
            <a href="https://swingcricketapp.com#download">Download</a>
          </div>

          <div className="sw-nav-right">
            <button className="sw-theme-btn" onClick={toggleTheme} aria-label="Toggle theme">
              <svg className="moon" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth={2}>
                <path d="M21 12.79A9 9 0 1 1 11.21 3 7 7 0 0 0 21 12.79z"/>
              </svg>
              <svg className="sun" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth={2}>
                <circle cx="12" cy="12" r="4"/>
                <path d="M12 2v2M12 20v2M4.93 4.93l1.41 1.41M17.66 17.66l1.41 1.41M2 12h2M20 12h2M4.93 19.07l1.41-1.41M17.66 6.34l1.41-1.41"/>
              </svg>
            </button>

            {rightAction ?? (
              <a href="https://swingcricketapp.com#download" className="sw-nav-cta">
                Get Swing
              </a>
            )}
          </div>
        </div>
      </nav>
    </>
  );
}
