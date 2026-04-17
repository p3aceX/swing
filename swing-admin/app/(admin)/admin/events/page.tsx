"use client";

import { useMemo } from "react";
import { useSearchParams } from "next/navigation";
import type { ColumnDef } from "@tanstack/react-table";
import { DataTable } from "@/components/admin/data-table";
import { FilterBar } from "@/components/admin/filter-bar";
import { PageHeader } from "@/components/admin/page-header";
import { PaginationBar } from "@/components/admin/pagination-bar";
import { Badge } from "@/components/ui/badge";
import { useEventsQuery } from "@/lib/queries";
import type { EventRecord } from "@/lib/api";
import { formatDate } from "@/lib/utils";

function statusVariant(
  status: string,
): "default" | "outline" | "success" | "warning" | "destructive" {
  switch (status) {
    case "COMPLETED":
      return "success";
    case "LIVE":
    case "ONGOING":
      return "warning";
    case "CANCELLED":
      return "destructive";
    default:
      return "outline";
  }
}

export default function EventsPage() {
  const searchParams = useSearchParams();
  const page = Number(searchParams.get("page") ?? "1");
  const search = searchParams.get("search") ?? "";

  const query = useEventsQuery({
    page,
    limit: 25,
    search: search || undefined,
  });

  const columns = useMemo<ColumnDef<EventRecord>[]>(
    () => [
      {
        header: "Event",
        cell: ({ row }) => (
          <div className="space-y-1">
            <div className="font-medium">{row.original.name}</div>
            {row.original.description ? (
              <div className="max-w-[320px] truncate text-xs text-muted-foreground">
                {row.original.description}
              </div>
            ) : null}
          </div>
        ),
      },
      {
        header: "Type",
        cell: ({ row }) => (
          <Badge variant="outline">{row.original.eventType}</Badge>
        ),
      },
      {
        header: "Venue",
        cell: ({ row }) => (
          <div className="space-y-0.5">
            <div>{row.original.venueName ?? "—"}</div>
            <div className="text-xs text-muted-foreground">
              {row.original.city ?? "No city"}
            </div>
          </div>
        ),
      },
      {
        header: "Scheduled",
        cell: ({ row }) =>
          row.original.scheduledAt
            ? formatDate(row.original.scheduledAt, "dd MMM yyyy, hh:mm a")
            : "—",
      },
      {
        header: "Status",
        cell: ({ row }) => (
          <Badge variant={statusVariant(row.original.status)}>
            {row.original.status}
          </Badge>
        ),
      },
      {
        header: "Visibility",
        cell: ({ row }) => (
          <Badge variant={row.original.isPublic ? "success" : "outline"}>
            {row.original.isPublic ? "Public" : "Private"}
          </Badge>
        ),
      },
      {
        header: "Created By",
        cell: ({ row }) =>
          row.original.createdByUser?.name ??
          `${row.original.createdByUserId.slice(0, 8)}...`,
      },
      {
        header: "Created",
        cell: ({ row }) => formatDate(row.original.createdAt),
      },
    ],
    [],
  );

  return (
    <div className="space-y-6">
      <PageHeader
        title="Events"
        description="Browse all events created on the platform."
        action={<></>}
      />
      <FilterBar searchPlaceholder="Search by event name, venue, or city" selects={[]} />

      {query.isError && (
        <div className="rounded-xl border border-destructive bg-destructive/10 p-4 text-sm text-destructive">
          Failed to load events: {(query.error as Error)?.message ?? "Unknown error"}
        </div>
      )}

      <div className="rounded-xl border bg-card overflow-x-auto">
        <DataTable columns={columns} data={query.isLoading ? [] : (query.data?.events ?? [])} />
        {query.isLoading && (
          <div className="p-8 text-center text-sm text-muted-foreground">Loading...</div>
        )}
        {!query.isLoading && (query.data?.events.length ?? 0) === 0 && (
          <div className="p-8 text-center text-sm text-muted-foreground">
            No events found.
          </div>
        )}
      </div>

      <PaginationBar page={page} limit={25} total={query.data?.total ?? 0} />
    </div>
  );
}
