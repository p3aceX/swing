"use client";

import { useState } from "react";
import Link from "next/link";
import { usePathname } from "next/navigation";
import {
  BarChart3,
  Briefcase,
  Building2,
  CalendarDays,
  ChevronDown,
  CreditCard,
  Gauge,
  GraduationCap,
  LifeBuoy,
  Swords,
  MessageSquare,
  Settings,
  ShieldCheck,
  Target,
  Trophy,
  Users,
  Users2,
} from "lucide-react";
import { cn } from "@/lib/utils";

export const navGroups = [
  {
    label: "Overview",
    items: [{ href: "/admin", label: "Dashboard", icon: Gauge }],
  },
  {
    label: "People",
    items: [
      { href: "/admin/users", label: "Users", icon: Users },
      { href: "/admin/coaches", label: "Coaches", icon: GraduationCap },
      { href: "/admin/academies", label: "Academies", icon: Building2 },
    ],
  },
  {
    label: "Competition",
    items: [
      { href: "/admin/matches", label: "Matches", icon: Swords },
      { href: "/admin/tournaments", label: "Tournaments", icon: Trophy },
      { href: "/admin/events", label: "Events", icon: CalendarDays },
      { href: "/admin/teams", label: "Teams", icon: Users2 },
      { href: "/admin/arenas", label: "Arenas", icon: ShieldCheck },
    ],
  },
  {
    label: "Commerce",
    items: [
      { href: "/admin/payments", label: "Payments", icon: CreditCard },
      { href: "/admin/gigs", label: "Gigs", icon: Briefcase },
    ],
  },
  {
    label: "Operations",
    items: [
      { href: "/admin/analytics", label: "Analytics", icon: BarChart3 },
      { href: "/admin/support", label: "Support", icon: LifeBuoy },
      { href: "/admin/broadcast", label: "Broadcast", icon: MessageSquare },
    ],
  },
  {
    label: "System",
    items: [
      { href: "/admin/development", label: "Development", icon: Target },
      { href: "/admin/config", label: "Config", icon: Settings },
    ],
  },
];

function NavGroup({
  group,
  pathname,
  onNavigate,
}: {
  group: (typeof navGroups)[number];
  pathname: string;
  onNavigate?: () => void;
}) {
  const hasActive = group.items.some(({ href }) =>
    href === "/admin"
      ? pathname === "/admin"
      : pathname === href || pathname.startsWith(`${href}/`),
  );
  const [open, setOpen] = useState(hasActive || group.label === "Overview");

  return (
    <div>
      <button
        onClick={() => setOpen((v) => !v)}
        className="flex w-full items-center justify-between px-3 py-1 text-[10px] font-semibold uppercase tracking-widest text-muted-foreground/60 hover:text-muted-foreground transition-colors"
      >
        {group.label}
        <ChevronDown
          className={cn(
            "h-3 w-3 transition-transform duration-200",
            open ? "rotate-0" : "-rotate-90",
          )}
        />
      </button>

      <div
        className={cn(
          "grid transition-all duration-200",
          open ? "mt-1 grid-rows-[1fr]" : "grid-rows-[0fr]",
        )}
      >
        <div className="overflow-hidden">
          <div className="space-y-0.5">
            {group.items.map(({ href, label, icon: Icon }) => {
              const active =
                href === "/admin"
                  ? pathname === "/admin"
                  : pathname === href || pathname.startsWith(`${href}/`);
              return (
                <Link
                  key={href}
                  href={href}
                  onClick={onNavigate}
                  className={cn(
                    "flex items-center gap-3 rounded-lg px-3 py-2 text-sm font-medium transition-colors",
                    active
                      ? "bg-primary text-primary-foreground shadow-sm"
                      : "text-muted-foreground hover:bg-muted hover:text-foreground",
                  )}
                >
                  <Icon className="h-4 w-4 shrink-0" />
                  {label}
                </Link>
              );
            })}
          </div>
        </div>
      </div>
    </div>
  );
}

export function NavLinks({ onNavigate }: { onNavigate?: () => void }) {
  const pathname = usePathname();
  return (
    <nav className="space-y-4">
      {navGroups.map((group) => (
        <NavGroup
          key={group.label}
          group={group}
          pathname={pathname}
          onNavigate={onNavigate}
        />
      ))}
    </nav>
  );
}

export function AdminSidebar() {
  return (
    <aside className="sticky top-0 hidden h-screen w-60 shrink-0 overflow-y-auto border-r bg-card/90 px-4 py-6 backdrop-blur lg:block">
      <div className="mb-7">
        <div className="text-[10px] font-semibold uppercase tracking-[0.24em] text-primary">
          Swing Ops
        </div>
        <div className="mt-1 text-lg font-semibold">Admin Console</div>
      </div>
      <NavLinks />
    </aside>
  );
}
