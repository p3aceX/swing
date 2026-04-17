"use client";

import { useState, useEffect } from "react";
import { createPortal } from "react-dom";
import { Menu, X } from "lucide-react";
import { Button } from "@/components/ui/button";
import { NavLinks } from "./sidebar";

export function MobileNav() {
  const [open, setOpen] = useState(false);
  const [mounted, setMounted] = useState(false);

  useEffect(() => {
    setMounted(true);
  }, []);

  const drawer = (
    <>
      {/* Overlay */}
      {open && (
        <div
          className="fixed inset-0 bg-black/50 lg:hidden"
          style={{ zIndex: 9998 }}
          onClick={() => setOpen(false)}
        />
      )}

      {/* Drawer */}
      <div
        className={`fixed inset-y-0 left-0 w-60 border-r bg-card shadow-xl transition-transform duration-300 ease-in-out lg:hidden ${
          open ? "translate-x-0" : "-translate-x-full"
        }`}
        style={{ zIndex: 9999 }}
      >
        <div className="flex items-center justify-between border-b px-4 py-4">
          <div>
            <div className="text-[10px] font-semibold uppercase tracking-[0.24em] text-primary">Swing Ops</div>
            <div className="text-lg font-semibold">Admin Console</div>
          </div>
          <Button variant="ghost" size="icon" onClick={() => setOpen(false)}>
            <X className="h-5 w-5" />
          </Button>
        </div>
        <div className="overflow-y-auto px-4 py-4" style={{ height: "calc(100vh - 65px)" }}>
          <NavLinks onNavigate={() => setOpen(false)} />
        </div>
      </div>
    </>
  );

  return (
    <>
      <Button
        variant="ghost"
        size="icon"
        className="lg:hidden"
        onClick={() => setOpen(true)}
        aria-label="Open navigation"
      >
        <Menu className="h-5 w-5" />
      </Button>

      {mounted && createPortal(drawer, document.body)}
    </>
  );
}
