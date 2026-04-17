"use client";

import { useMemo } from "react";
import { useSearchParams } from "next/navigation";
import type { ColumnDef } from "@tanstack/react-table";
import { DataTable } from "@/components/admin/data-table";
import { PaginationBar } from "@/components/admin/pagination-bar";
import { PageHeader } from "@/components/admin/page-header";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Sheet, SheetContent, SheetHeader, SheetTitle, SheetTrigger } from "@/components/ui/sheet";
import { useAcademiesQuery, useVerifyAcademyMutation } from "@/lib/queries";
import { formatDate } from "@/lib/utils";
import { FilterBar } from "@/components/admin/filter-bar";
import type { AcademyRecord } from "@/lib/api";

export default function AcademiesPage() {
  const searchParams = useSearchParams();
  const page = Number(searchParams.get("page") ?? "1");
  const verified = searchParams.get("verified") ?? "";
  const query = useAcademiesQuery({ page, limit: 25 });
  const verifyMutation = useVerifyAcademyMutation();

  const rows = useMemo(() => {
    const academies = query.data?.academies ?? [];
    if (verified === "VERIFIED") return academies.filter((academy) => Boolean(academy.verifiedAt));
    if (verified === "UNVERIFIED") return academies.filter((academy) => !academy.verifiedAt);
    return academies;
  }, [query.data, verified]);

  const columns = useMemo<ColumnDef<AcademyRecord>[]>(
    () => [
      { header: "Name", accessorKey: "name" },
      { header: "City", cell: ({ row }) => String(row.original.city ?? "N/A") },
      { header: "Owner", cell: ({ row }) => row.original.owner?.user?.name ?? "Unknown" },
      { header: "Owner Phone", cell: ({ row }) => row.original.owner?.user?.phone ?? "N/A" },
      { header: "Created", cell: ({ row }) => formatDate(row.original.createdAt) },
      {
        header: "Verified",
        cell: ({ row }) => (
          <Badge variant={row.original.verifiedAt ? "success" : "warning"}>
            {row.original.verifiedAt ? "Verified" : "Unverified"}
          </Badge>
        ),
      },
      {
        header: "Actions",
        cell: ({ row }) => (
          <div className="flex gap-2">
            {row.original.verifiedAt ? (
              <Button
                size="sm"
                variant="outline"
                disabled={verifyMutation.isPending}
                onClick={() => verifyMutation.mutate({ id: row.original.id, verify: false })}
              >
                Revoke
              </Button>
            ) : (
              <Button
                size="sm"
                variant="success"
                disabled={verifyMutation.isPending}
                onClick={() => verifyMutation.mutate({ id: row.original.id, verify: true })}
              >
                Verify
              </Button>
            )}
            <Sheet>
              <SheetTrigger asChild>
                <Button size="sm" variant="outline">
                  View Details
                </Button>
              </SheetTrigger>
              <SheetContent className="max-w-xl">
                <SheetHeader>
                  <SheetTitle>{row.original.name}</SheetTitle>
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
      <PageHeader title="Academies" description="Review academy records and owner details." />
      <FilterBar
        searchPlaceholder="Academy filters are limited to verification state"
        selects={[
          {
            key: "verified",
            value: verified,
            placeholder: "Filter verification",
            options: [
              { value: "VERIFIED", label: "Verified" },
              { value: "UNVERIFIED", label: "Unverified" },
            ],
          },
        ]}
      />
      {query.isError && (
        <div className="rounded-xl border border-destructive bg-destructive/10 p-4 text-sm text-destructive">
          Failed to load academies: {(query.error as Error)?.message ?? "Unknown error"}
        </div>
      )}
      <div className="rounded-xl border bg-card overflow-x-auto">
        <DataTable columns={columns} data={query.isLoading ? [] : rows} />
        {query.isLoading && <div className="p-8 text-center text-sm text-muted-foreground">Loading...</div>}
      </div>
      <PaginationBar page={page} limit={25} total={query.data?.total ?? 0} />
    </div>
  );
}
