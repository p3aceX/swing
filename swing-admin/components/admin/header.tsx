"use client";

import { signOut, useSession } from "next-auth/react";
import { LogOut } from "lucide-react";
import { Avatar } from "@/components/ui/avatar";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { MobileNav } from "./mobile-nav";

export function AdminHeader() {
  const { data } = useSession();

  return (
    <header className="flex items-center justify-between gap-2 border-b border-border/70 bg-background/70 px-4 py-3 backdrop-blur sm:px-6 sm:py-4">
      <div className="flex items-center gap-3">
        <MobileNav />
        <div>
          <div className="hidden text-sm text-muted-foreground sm:block">Swing Platform Team</div>
          <div className="text-base font-semibold sm:text-xl">Operations Dashboard</div>
        </div>
      </div>
      <div className="flex items-center gap-2 sm:gap-4">
        <Badge variant="outline" className="hidden sm:inline-flex">
          {data?.user?.activeRole ?? "ADMIN"}
        </Badge>
        <div className="flex items-center gap-2 rounded-xl border bg-card px-2 py-1.5 sm:gap-3 sm:px-3 sm:py-2">
          <Avatar name={data?.user?.name} className="h-7 w-7 sm:h-9 sm:w-9" />
          <div className="hidden min-w-0 sm:block">
            <div className="truncate text-sm font-medium">{data?.user?.name ?? "Admin"}</div>
            <div className="truncate text-xs text-muted-foreground">{data?.user?.email}</div>
          </div>
        </div>
        <Button variant="ghost" size="icon" onClick={() => signOut({ callbackUrl: "/login" })}>
          <LogOut className="h-4 w-4" />
        </Button>
      </div>
    </header>
  );
}
