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
import { useGigsQuery, useToggleGigFeaturedMutation } from "@/lib/queries";
import { formatDate, paiseToInr, formatCurrencyInr } from "@/lib/utils";
import type { GigRecord } from "@/lib/api";

export default function GigsPage() {
  const searchParams = useSearchParams();
  const page = Number(searchParams.get("page") ?? "1");
  const search = searchParams.get("search") ?? "";

  const query = useGigsQuery({ page, limit: 25, search: search || undefined });
  const toggleFeatured = useToggleGigFeaturedMutation();

  const columns = useMemo<ColumnDef<GigRecord>[]>(
    () => [
      { header: "Title", accessorKey: "title" },
      {
        header: "Coach",
        cell: ({ row }) => (
          <div>
            <div className="font-medium">{row.original.coach.user.name}</div>
            <div className="text-xs text-muted-foreground">{row.original.coach.user.phone}</div>
          </div>
        ),
      },
      { header: "City", cell: ({ row }) => String(row.original.city ?? "N/A") },
      {
        header: "Price",
        cell: ({ row }) => formatCurrencyInr(paiseToInr(row.original.pricePaise)),
      },
      { header: "Bookings", cell: ({ row }) => String(row.original.totalBookings) },
      {
        header: "Rating",
        cell: ({ row }) => <span className="font-medium">{Number(row.original.rating).toFixed(1)}</span>,
      },
      {
        header: "Featured",
        cell: ({ row }) => (
          <Badge variant={row.original.isFeatured ? "success" : "outline"}>
            {row.original.isFeatured ? "Featured" : "Standard"}
          </Badge>
        ),
      },
      {
        header: "Active",
        cell: ({ row }) => (
          <Badge variant={row.original.isActive ? "success" : "outline"}>
            {row.original.isActive ? "Active" : "Inactive"}
          </Badge>
        ),
      },
      { header: "Created", cell: ({ row }) => formatDate(row.original.createdAt) },
      {
        header: "Actions",
        cell: ({ row }) => (
          <Button
            size="sm"
            variant={row.original.isFeatured ? "outline" : "secondary"}
            disabled={toggleFeatured.isPending}
            onClick={() => toggleFeatured.mutate(row.original.id)}
          >
            {row.original.isFeatured ? "Unfeature" : "Feature"}
          </Button>
        ),
      },
    ],
    [toggleFeatured],
  );

  return (
    <div className="space-y-6">
      <PageHeader title="Gig Listings" description="Browse and feature coach gig listings across the platform." />
      <FilterBar searchPlaceholder="Search by gig title" selects={[]} />
      {query.isError && (
        <div className="rounded-xl border border-destructive bg-destructive/10 p-4 text-sm text-destructive">
          Failed to load gigs: {(query.error as Error)?.message ?? "Unknown error"}
        </div>
      )}
      <div className="rounded-xl border bg-card">
        <DataTable columns={columns} data={query.isLoading ? [] : (query.data?.gigs ?? [])} />
        {query.isLoading && <div className="p-8 text-center text-sm text-muted-foreground">Loading...</div>}
      </div>
      <PaginationBar page={page} limit={25} total={query.data?.total ?? 0} />
    </div>
  );
}
