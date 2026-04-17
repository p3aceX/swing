"use client";

import {
  flexRender,
  getCoreRowModel,
  getSortedRowModel,
  useReactTable,
  type ColumnDef,
  type SortingState,
} from "@tanstack/react-table";
import { useMemo, useState } from "react";
import { ArrowUpDown } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";

export function DataTable<TData>({
  columns,
  data,
}: {
  columns: ColumnDef<TData>[];
  data: TData[];
}) {
  const [sorting, setSorting] = useState<SortingState>([]);

  const enhancedColumns = useMemo(
    () =>
      columns.map((column, index) => {
        if (typeof column.header !== "string") {
          return {
            ...column,
            id: column.id ?? `col_${index}`,
          };
        }

        const headerLabel = column.header;
        return {
          ...column,
          id: column.id ?? `col_${index}`,
          header: ({ column: tableColumn }: any) => (
            <Button
              variant="ghost"
              className="-ml-3 h-auto px-3 py-1 text-sm font-medium"
              onClick={() => tableColumn.toggleSorting(tableColumn.getIsSorted() === "asc")}
            >
              {headerLabel}
              <ArrowUpDown className="ml-2 h-3.5 w-3.5" />
            </Button>
          ),
        };
      }),
    [columns],
  );

  const table = useReactTable({
    data,
    columns: enhancedColumns,
    getCoreRowModel: getCoreRowModel(),
    getSortedRowModel: getSortedRowModel(),
    onSortingChange: setSorting,
    state: { sorting },
  });

  return (
    <div className="overflow-x-auto">
    <Table>
      <TableHeader>
        {table.getHeaderGroups().map((headerGroup) => (
          <TableRow key={headerGroup.id}>
            {headerGroup.headers.map((header) => (
              <TableHead key={header.id}>
                {header.isPlaceholder ? null : flexRender(header.column.columnDef.header, header.getContext())}
              </TableHead>
            ))}
          </TableRow>
        ))}
      </TableHeader>
      <TableBody>
        {table.getRowModel().rows.map((row) => (
          <TableRow key={row.id}>
            {row.getVisibleCells().map((cell) => (
              <TableCell key={cell.id}>{flexRender(cell.column.columnDef.cell, cell.getContext())}</TableCell>
            ))}
          </TableRow>
        ))}
      </TableBody>
    </Table>
    </div>
  );
}
