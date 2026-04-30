"use client";

import { useRef, useState, useEffect, useCallback } from "react";

export default function PhotoCarousel({ photos, alt }: { photos: string[]; alt: string }) {
  const trackRef = useRef<HTMLDivElement>(null);
  const [current, setCurrent] = useState(0);
  const pausedRef = useRef(false);

  // Track current slide via IntersectionObserver
  useEffect(() => {
    const track = trackRef.current;
    if (!track) return;
    const slides = Array.from(track.children) as HTMLElement[];
    const obs = new IntersectionObserver(
      (entries) => {
        entries.forEach((e) => {
          if (e.isIntersecting) {
            setCurrent(slides.indexOf(e.target as HTMLElement));
          }
        });
      },
      { root: track, threshold: 0.6 },
    );
    slides.forEach((s) => obs.observe(s));
    return () => obs.disconnect();
  }, [photos.length]);

  const goTo = useCallback((idx: number) => {
    const track = trackRef.current;
    if (!track) return;
    track.scrollTo({ left: idx * track.clientWidth, behavior: "smooth" });
  }, []);

  // Auto-advance every 4 seconds, pause on hover/touch
  useEffect(() => {
    if (photos.length <= 1) return;
    const interval = setInterval(() => {
      if (pausedRef.current) return;
      setCurrent((c) => {
        const next = (c + 1) % photos.length;
        goTo(next);
        return next;
      });
    }, 4000);
    return () => clearInterval(interval);
  }, [photos.length, goTo]);

  const pause = useCallback(() => { pausedRef.current = true; }, []);
  const resume = useCallback(() => { pausedRef.current = false; }, []);

  if (photos.length === 0) {
    return (
      <div style={{
        width: "100%", height: "100%",
        background: "repeating-linear-gradient(135deg, oklch(0.32 0.04 140) 0 14px, oklch(0.28 0.04 140) 14px 28px)",
      }} />
    );
  }

  if (photos.length === 1) {
    // eslint-disable-next-line @next/next/no-img-element
    return <img src={photos[0]} alt={alt} style={{ width: "100%", height: "100%", objectFit: "cover", display: "block" }} />;
  }

  return (
    <div
      style={{ position: "relative", width: "100%", height: "100%" }}
      onMouseEnter={pause}
      onMouseLeave={resume}
      onTouchStart={pause}
      onTouchEnd={resume}
    >
      {/* Scroll track */}
      <div
        ref={trackRef}
        style={{
          display: "flex",
          overflowX: "auto",
          scrollSnapType: "x mandatory",
          height: "100%",
          scrollbarWidth: "none",
          msOverflowStyle: "none",
        }}
        className="scrollbar-none"
      >
        {photos.map((url, i) => (
          // eslint-disable-next-line @next/next/no-img-element
          <img
            key={url}
            src={url}
            alt={`${alt} ${i + 1}`}
            style={{
              flex: "0 0 100%",
              scrollSnapAlign: "start",
              objectFit: "cover",
              width: "100%",
              height: "100%",
            }}
          />
        ))}
      </div>

      {/* Dot indicators */}
      <div style={{
        position: "absolute", bottom: 14, left: "50%",
        transform: "translateX(-50%)",
        display: "flex", gap: 5, zIndex: 3,
      }}>
        {photos.map((_, i) => (
          <button
            key={i}
            onClick={() => { pause(); goTo(i); setTimeout(resume, 3000); }}
            style={{
              width: i === current ? 18 : 6, height: 6,
              borderRadius: 999, border: "none", padding: 0, cursor: "pointer",
              background: "white",
              opacity: i === current ? 1 : 0.45,
              transition: "all 0.2s",
            }}
          />
        ))}
      </div>

      {/* Arrow buttons — desktop only */}
      {current > 0 && (
        <button
          onClick={() => { pause(); goTo(current - 1); setTimeout(resume, 3000); }}
          style={{
            position: "absolute", top: "50%", left: 12,
            transform: "translateY(-50%)", zIndex: 3,
            width: 36, height: 36, borderRadius: "50%", border: "none",
            background: "rgba(0,0,0,0.45)", color: "white",
            display: "none", placeItems: "center", cursor: "pointer",
          }}
          className="lg:grid"
        >
          ‹
        </button>
      )}
      {current < photos.length - 1 && (
        <button
          onClick={() => { pause(); goTo(current + 1); setTimeout(resume, 3000); }}
          style={{
            position: "absolute", top: "50%", right: 12,
            transform: "translateY(-50%)", zIndex: 3,
            width: 36, height: 36, borderRadius: "50%", border: "none",
            background: "rgba(0,0,0,0.45)", color: "white",
            display: "none", placeItems: "center", cursor: "pointer",
          }}
          className="lg:grid"
        >
          ›
        </button>
      )}
    </div>
  );
}
