"use client";

import Link from "next/link";
import { useMemo, useState } from "react";
import { useSearchParams } from "next/navigation";
import { Plus } from "lucide-react";
import type { ColumnDef } from "@tanstack/react-table";
import { DataTable } from "@/components/admin/data-table";
import { PaginationBar } from "@/components/admin/pagination-bar";
import { PageHeader } from "@/components/admin/page-header";
import { FilterBar } from "@/components/admin/filter-bar";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import {
  Dialog,
  DialogContent,
  DialogFooter,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from "@/components/ui/dialog";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import {
  useArenasQuery,
  useVerifyArenaMutation,
  useToggleSwingArenaMutation,
  useVenuesFullQuery,
} from "@/lib/queries";
import { formatDate } from "@/lib/utils";
import type { ArenaRecord, VenueFullRecord } from "@/lib/api";

const ARENA_GRADES = ["GULLY", "CLUB", "DISTRICT", "ELITE"] as const;

function VerifyArenaDialog({ arenaId, onVerify }: { arenaId: string; onVerify: (id: string, grade: string) => void }) {
  const [grade, setGrade] = useState<string>("");
  const [open, setOpen] = useState(false);

  return (
    <Dialog open={open} onOpenChange={setOpen}>
      <DialogTrigger asChild>
        <Button size="sm" variant="success">Verify</Button>
      </DialogTrigger>
      <DialogContent>
        <DialogHeader>
          <DialogTitle>Verify Arena</DialogTitle>
        </DialogHeader>
        <div className="space-y-4 py-2">
          <div className="space-y-2">
            <label className="text-sm font-medium">Arena Grade</label>
            <Select value={grade} onValueChange={setGrade}>
              <SelectTrigger>
                <SelectValue placeholder="Select grade" />
              </SelectTrigger>
              <SelectContent>
                {ARENA_GRADES.map((g) => (
                  <SelectItem key={g} value={g}>{g}</SelectItem>
                ))}
              </SelectContent>
            </Select>
          </div>
        </div>
        <DialogFooter>
          <Button variant="outline" onClick={() => setOpen(false)}>Cancel</Button>
          <Button variant="success" disabled={!grade}
            onClick={() => { onVerify(arenaId, grade); setOpen(false); }}>
            Confirm
          </Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  );
}

export default function ArenasPage() {
  const searchParams = useSearchParams();
  const page = Number(searchParams.get("page") ?? "1");
  const search = searchParams.get("search") ?? "";
  const city = searchParams.get("city") ?? "";

  const arenasQuery = useArenasQuery({ page, limit: 25, search: search || undefined, city: city || undefined });
  const venuesQuery = useVenuesFullQuery(search || undefined);
  const verifyMutation = useVerifyArenaMutation();
  const toggleSwingMutation = useToggleSwingArenaMutation();

  const arenaColumns = useMemo<ColumnDef<ArenaRecord>[]>(
    () => [
      {
        header: "Name",
        cell: ({ row }) => (
          <div className="space-y-1">
            <div className="font-medium">{row.original.name}</div>
            <div className="flex flex-wrap gap-3 text-xs">
              <Link href={`/admin/arenas/${row.original.id}`} className="font-medium text-primary hover:underline">
                View
              </Link>
              <Link href={`/admin/arenas/${row.original.id}?mode=edit`} className="font-medium text-primary hover:underline">
                Edit
              </Link>
            </div>
          </div>
        ),
      },
      { header: "City", cell: ({ row }) => String(row.original.city ?? "N/A") },
      { header: "State", cell: ({ row }) => String(row.original.state ?? "N/A") },
      { header: "Owner", cell: ({ row }) => row.original.owner?.user?.name ?? "Unknown" },
      { header: "Owner Phone", cell: ({ row }) => row.original.owner?.user?.phone ?? "N/A" },
      {
        header: "Grade",
        cell: ({ row }) => <Badge variant="outline">{row.original.arenaGrade ?? "Ungraded"}</Badge>,
      },
      {
        header: "Swing Arena",
        cell: ({ row }) => (
          <Badge variant={row.original.isSwingArena ? "success" : "outline"}>
            {row.original.isSwingArena ? "Yes" : "No"}
          </Badge>
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
      { header: "Created", cell: ({ row }) => formatDate(row.original.createdAt) },
      {
        header: "Actions",
        cell: ({ row }) => (
          <div className="flex flex-wrap gap-2">
            {!row.original.isVerified ? (
              <VerifyArenaDialog
                arenaId={row.original.id}
                onVerify={(id, grade) => verifyMutation.mutate({ id, arenaGrade: grade })}
              />
            ) : (
              <Badge variant="success" className="px-3 py-1">Verified</Badge>
            )}
            <Button
              size="sm"
              variant={row.original.isSwingArena ? "outline" : "secondary"}
              disabled={toggleSwingMutation.isPending}
              onClick={() => toggleSwingMutation.mutate(row.original.id)}
            >
              {row.original.isSwingArena ? "Remove Swing" : "Set Swing"}
            </Button>
          </div>
        ),
      },
    ],
    [verifyMutation, toggleSwingMutation],
  );

  const venueColumns = useMemo<ColumnDef<VenueFullRecord>[]>(
    () => [
      { header: "Name", accessorKey: "name" },
      { header: "City", cell: ({ row }) => row.original.city ?? "—" },
      { header: "Address", cell: ({ row }) => row.original.address ?? "—" },
      {
        header: "Aliases",
        cell: ({ row }) =>
          row.original.aliases.length > 0
            ? row.original.aliases.join(", ")
            : "—",
      },
      {
        header: "Matches Played",
        cell: ({ row }) => (
          <Badge variant="outline">{row.original._count?.matches ?? 0}</Badge>
        ),
      },
      { header: "Added", cell: ({ row }) => formatDate(row.original.createdAt) },
    ],
    [],
  );

  return (
    <div className="space-y-6">
      <PageHeader
        title="Arenas & Venues"
        description="Manage registered arenas and match venues."
        action={
          <Button asChild>
            <Link href="/admin/arenas/new">
              <Plus className="mr-2 h-4 w-4" />
              Create Arena
            </Link>
          </Button>
        }
      />
      <FilterBar searchPlaceholder="Search by name or city" selects={[]} />

      <Tabs defaultValue="arenas">
        <TabsList>
          <TabsTrigger value="arenas">
            Arenas
            {arenasQuery.data && (
              <span className="ml-1.5 text-xs text-muted-foreground">({arenasQuery.data.total})</span>
            )}
          </TabsTrigger>
          <TabsTrigger value="venues">
            Match Venues
            {venuesQuery.data && (
              <span className="ml-1.5 text-xs text-muted-foreground">({venuesQuery.data.length})</span>
            )}
          </TabsTrigger>
        </TabsList>

        <TabsContent value="arenas" className="mt-4 space-y-4">
          {arenasQuery.isError && (
            <div className="rounded-xl border border-destructive bg-destructive/10 p-4 text-sm text-destructive">
              Failed to load arenas: {(arenasQuery.error as Error)?.message ?? "Unknown error"}
            </div>
          )}
          <div className="rounded-xl border bg-card overflow-x-auto">
            <DataTable columns={arenaColumns} data={arenasQuery.isLoading ? [] : (arenasQuery.data?.arenas ?? [])} />
            {arenasQuery.isLoading && (
              <div className="p-8 text-center text-sm text-muted-foreground">Loading...</div>
            )}
          </div>
          <PaginationBar page={page} limit={25} total={arenasQuery.data?.total ?? 0} />
        </TabsContent>

        <TabsContent value="venues" className="mt-4 space-y-4">
          <p className="text-sm text-muted-foreground">
            Venues are lightweight location records created when a match is set up. They are separate from registered Arenas on the platform.
          </p>
          {venuesQuery.isError && (
            <div className="rounded-xl border border-destructive bg-destructive/10 p-4 text-sm text-destructive">
              Failed to load venues: {(venuesQuery.error as Error)?.message ?? "Unknown error"}
            </div>
          )}
          <div className="rounded-xl border bg-card overflow-x-auto">
            <DataTable columns={venueColumns} data={venuesQuery.isLoading ? [] : (venuesQuery.data ?? [])} />
            {venuesQuery.isLoading && (
              <div className="p-8 text-center text-sm text-muted-foreground">Loading...</div>
            )}
            {!venuesQuery.isLoading && (venuesQuery.data?.length ?? 0) === 0 && (
              <div className="p-8 text-center text-sm text-muted-foreground">No match venues found.</div>
            )}
          </div>
        </TabsContent>
      </Tabs>
    </div>
  );
}
