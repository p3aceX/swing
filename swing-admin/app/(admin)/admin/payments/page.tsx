"use client";

import { useMemo } from "react";
import { useSearchParams } from "next/navigation";
import type { ColumnDef } from "@tanstack/react-table";
import { DataTable } from "@/components/admin/data-table";
import { FilterBar } from "@/components/admin/filter-bar";
import { PageHeader } from "@/components/admin/page-header";
import { PaginationBar } from "@/components/admin/pagination-bar";
import { Badge } from "@/components/ui/badge";
import { usePaymentsQuery } from "@/lib/queries";
import type { PaymentRecord } from "@/lib/api";
import { formatCurrencyInr, formatDate, paiseToInr } from "@/lib/utils";

export default function PaymentsPage() {
  const searchParams = useSearchParams();
  const page = Number(searchParams.get("page") ?? "1");
  const status = searchParams.get("status") ?? "";
  const query = usePaymentsQuery({ page, limit: 25, status: status || undefined });

  const columns = useMemo<ColumnDef<PaymentRecord>[]>(
    () => [
      { header: "Payment ID", accessorKey: "id" },
      { header: "User", cell: ({ row }) => row.original.user?.name ?? "Unknown" },
      { header: "Phone", cell: ({ row }) => row.original.user?.phone ?? "N/A" },
      { header: "Amount", cell: ({ row }) => formatCurrencyInr(paiseToInr(row.original.amountPaise)) },
      { header: "Entity", accessorKey: "entityType" },
      { header: "Created", cell: ({ row }) => formatDate(row.original.createdAt) },
      { header: "Status", cell: ({ row }) => <Badge variant={row.original.status === "COMPLETED" ? "success" : "warning"}>{row.original.status}</Badge> },
    ],
    [query.data?.payments],
  );

  return (
    <div className="space-y-6">
      <PageHeader title="Payments" description={`Total revenue ${formatCurrencyInr(paiseToInr(query.data?.totalRevenuePaise ?? 0))}.`} />
      <FilterBar
        searchPlaceholder="Payments support status filters only"
        selects={[
          {
            key: "status",
            value: status,
            placeholder: "Filter by status",
            options: ["PENDING", "COMPLETED", "FAILED", "REFUNDED", "REFUND_PENDING"].map((item) => ({ value: item, label: item })),
          },
        ]}
      />
      <div className="rounded-xl border bg-card overflow-x-auto">
        <DataTable columns={columns} data={query.data?.payments ?? []} />
      </div>
      <PaginationBar page={page} limit={25} total={query.data?.total ?? 0} />
    </div>
  );
}
