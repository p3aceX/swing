"use client";

import { useMemo } from "react";
import { useSearchParams } from "next/navigation";
import type { ColumnDef } from "@tanstack/react-table";
import { DataTable } from "@/components/admin/data-table";
import { PaginationBar } from "@/components/admin/pagination-bar";
import { PageHeader } from "@/components/admin/page-header";
import { FilterBar } from "@/components/admin/filter-bar";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Avatar } from "@/components/ui/avatar";
import { Sheet, SheetContent, SheetHeader, SheetTitle, SheetTrigger } from "@/components/ui/sheet";
import { useCoachesQuery, useVerifyCoachMutation } from "@/lib/queries";
import { formatDate } from "@/lib/utils";
import type { CoachRecord } from "@/lib/api";

export default function CoachesPage() {
  const searchParams = useSearchParams();
  const page = Number(searchParams.get("page") ?? "1");
  const search = searchParams.get("search") ?? "";

  const query = useCoachesQuery({ page, limit: 25, search: search || undefined });
  const verifyMutation = useVerifyCoachMutation();

  const columns = useMemo<ColumnDef<CoachRecord>[]>(
    () => [
      {
        header: "Coach",
        cell: ({ row }) => (
          <div className="flex items-center gap-3">
            <Avatar name={row.original.user.name} />
            <div>
              <div className="font-medium">{row.original.user.name}</div>
              <div className="text-xs text-muted-foreground">{row.original.id.slice(0, 8)}&hellip;</div>
            </div>
          </div>
        ),
      },
      { header: "Phone", cell: ({ row }) => row.original.user.phone },
      { header: "City", cell: ({ row }) => String(row.original.city ?? "N/A") },
      {
        header: "Experience",
        cell: ({ row }) => `${row.original.experienceYears} yr${row.original.experienceYears !== 1 ? "s" : ""}`,
      },
      { header: "Sessions", cell: ({ row }) => String(row.original.totalSessions) },
      {
        header: "Rating",
        cell: ({ row }) => (
          <span className="font-medium">{Number(row.original.rating).toFixed(1)}</span>
        ),
      },
      {
        header: "Verified",
        cell: ({ row }) => (
          <Badge variant={row.original.isVerified ? "success" : "warning"}>
            {row.original.isVerified ? "Verified" : "Unverified"}
          </Badge>
        ),
      },
      { header: "Joined", cell: ({ row }) => formatDate(row.original.createdAt) },
      {
        header: "Actions",
        cell: ({ row }) => (
          <div className="flex gap-2">
            {row.original.isVerified ? (
              <Button
                size="sm"
                variant="outline"
                disabled={verifyMutation.isPending}
                onClick={() => verifyMutation.mutate({ id: row.original.id, isVerified: false })}
              >
                Unverify
              </Button>
            ) : (
              <Button
                size="sm"
                variant="success"
                disabled={verifyMutation.isPending}
                onClick={() => verifyMutation.mutate({ id: row.original.id, isVerified: true })}
              >
                Verify
              </Button>
            )}
            <Sheet>
              <SheetTrigger asChild>
                <Button size="sm" variant="outline">
                  Details
                </Button>
              </SheetTrigger>
              <SheetContent className="max-w-xl">
                <SheetHeader>
                  <SheetTitle>{row.original.user.name}</SheetTitle>
                </SheetHeader>
                <div className="mt-6 grid gap-3 text-sm">
                  {Object.entries(row.original).map(([key, value]) => (
                    <div key={key} className="rounded-lg border p-3">
                      <strong>{key}</strong>
                      <div className="mt-1 break-all text-muted-foreground">
                        {typeof value === "object" ? JSON.stringify(value, null, 2) : String(value)}
                      </div>
                    </div>
                  ))}
                </div>
              </SheetContent>
            </Sheet>
          </div>
        ),
      },
    ],
    [verifyMutation],
  );

  return (
    <div className="space-y-6">
      <PageHeader title="Coaches" description="Review, verify, and manage coach profiles." />
      <FilterBar searchPlaceholder="Search by name or phone" selects={[]} />
      {query.isError && (
        <div className="rounded-xl border border-destructive bg-destructive/10 p-4 text-sm text-destructive">
          Failed to load coaches: {(query.error as Error)?.message ?? "Unknown error"}
        </div>
      )}
      <div className="rounded-xl border bg-card overflow-x-auto">
        <DataTable columns={columns} data={query.isLoading ? [] : (query.data?.coaches ?? [])} />
        {query.isLoading && <div className="p-8 text-center text-sm text-muted-foreground">Loading...</div>}
      </div>
      <PaginationBar page={page} limit={25} total={query.data?.total ?? 0} />
    </div>
  );
}
