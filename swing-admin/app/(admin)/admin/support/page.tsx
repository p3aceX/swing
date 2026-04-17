"use client";

import { useMemo, useState } from "react";
import { useSearchParams } from "next/navigation";
import type { ColumnDef } from "@tanstack/react-table";
import { DataTable } from "@/components/admin/data-table";
import { PaginationBar } from "@/components/admin/pagination-bar";
import { PageHeader } from "@/components/admin/page-header";
import { FilterBar } from "@/components/admin/filter-bar";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Textarea } from "@/components/ui/textarea";
import { Sheet, SheetContent, SheetHeader, SheetTitle, SheetTrigger } from "@/components/ui/sheet";
import {
  Dialog,
  DialogContent,
  DialogFooter,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from "@/components/ui/dialog";
import {
  useSupportTicketsQuery,
  useSupportTicketQuery,
  useAddSupportMessageMutation,
  useResolveSupportTicketMutation,
  useCloseSupportTicketMutation,
} from "@/lib/queries";
import { formatDate, timeAgo } from "@/lib/utils";
import type { SupportTicketRecord } from "@/lib/api";

function priorityVariant(priority: string): "destructive" | "warning" | "outline" {
  if (priority === "URGENT") return "destructive";
  if (priority === "HIGH") return "warning";
  return "outline";
}

function statusVariant(status: string): "success" | "outline" | "warning" | "default" {
  if (status === "RESOLVED") return "success";
  if (status === "CLOSED") return "outline";
  if (status === "IN_PROGRESS") return "warning";
  return "outline";
}

function TicketDetailSheet({ ticket }: { ticket: SupportTicketRecord }) {
  const [message, setMessage] = useState("");
  const [resolution, setResolution] = useState("");
  const [resolveOpen, setResolveOpen] = useState(false);

  const detail = useSupportTicketQuery(ticket.id);
  const addMessage = useAddSupportMessageMutation();
  const resolve = useResolveSupportTicketMutation();
  const close = useCloseSupportTicketMutation();

  const isClosed = ticket.status === "CLOSED" || ticket.status === "RESOLVED";

  return (
    <SheetContent className="flex w-full max-w-2xl flex-col gap-0 p-0">
      <SheetHeader className="border-b px-6 py-4">
        <SheetTitle className="text-base">{ticket.subject}</SheetTitle>
        <div className="flex flex-wrap gap-2">
          <Badge variant={statusVariant(ticket.status)}>{ticket.status}</Badge>
          <Badge variant={priorityVariant(ticket.priority)}>{ticket.priority}</Badge>
          <Badge variant="outline">{ticket.category}</Badge>
        </div>
        <div className="text-sm text-muted-foreground">
          {ticket.user.name ?? "Unknown"} &bull; {ticket.user.phone ?? "N/A"} &bull; {formatDate(ticket.createdAt)}
        </div>
      </SheetHeader>

      {/* Messages */}
      <div className="flex-1 overflow-y-auto px-6 py-4 space-y-3">
        {detail.isLoading && <div className="text-sm text-muted-foreground">Loading messages...</div>}
        {detail.data?.messages.map((msg) => (
          <div
            key={msg.id}
            className={`rounded-lg p-3 text-sm ${msg.isFromSupport ? "ml-8 bg-primary/10 text-primary" : "mr-8 bg-muted"}`}
          >
            <div className="font-medium mb-1">{msg.isFromSupport ? "Support" : ticket.user.name ?? "User"}</div>
            <div>{msg.message}</div>
            <div className="mt-1 text-xs text-muted-foreground">{timeAgo(msg.createdAt)}</div>
          </div>
        ))}
        {detail.data?.messages.length === 0 && (
          <div className="text-sm text-muted-foreground">No messages yet.</div>
        )}
      </div>

      {/* Reply */}
      {!isClosed && (
        <div className="border-t px-6 py-4 space-y-3">
          <Textarea
            placeholder="Type a reply..."
            value={message}
            onChange={(e) => setMessage(e.target.value)}
            className="min-h-[80px]"
          />
          <div className="flex gap-2 flex-wrap">
            <Button
              size="sm"
              disabled={!message.trim() || addMessage.isPending}
              onClick={() => {
                addMessage.mutate({ id: ticket.id, message: message.trim() });
                setMessage("");
              }}
            >
              {addMessage.isPending ? "Sending..." : "Send Reply"}
            </Button>

            <Dialog open={resolveOpen} onOpenChange={setResolveOpen}>
              <DialogTrigger asChild>
                <Button size="sm" variant="success" disabled={ticket.status === "RESOLVED"}>
                  Resolve
                </Button>
              </DialogTrigger>
              <DialogContent>
                <DialogHeader>
                  <DialogTitle>Resolve Ticket</DialogTitle>
                </DialogHeader>
                <Textarea
                  placeholder="Resolution summary..."
                  value={resolution}
                  onChange={(e) => setResolution(e.target.value)}
                  className="min-h-[100px]"
                />
                <DialogFooter>
                  <Button variant="outline" onClick={() => setResolveOpen(false)}>
                    Cancel
                  </Button>
                  <Button
                    variant="success"
                    disabled={!resolution.trim() || resolve.isPending}
                    onClick={() => {
                      resolve.mutate({ id: ticket.id, resolution: resolution.trim() });
                      setResolveOpen(false);
                    }}
                  >
                    {resolve.isPending ? "Resolving..." : "Confirm Resolve"}
                  </Button>
                </DialogFooter>
              </DialogContent>
            </Dialog>

            <Button
              size="sm"
              variant="outline"
              disabled={ticket.status === "CLOSED" || close.isPending}
              onClick={() => close.mutate(ticket.id)}
            >
              {close.isPending ? "Closing..." : "Close Ticket"}
            </Button>
          </div>
        </div>
      )}
    </SheetContent>
  );
}

export default function SupportPage() {
  const searchParams = useSearchParams();
  const page = Number(searchParams.get("page") ?? "1");
  const status = searchParams.get("status") ?? "";
  const priority = searchParams.get("priority") ?? "";
  const category = searchParams.get("category") ?? "";

  const query = useSupportTicketsQuery({
    page,
    limit: 25,
    status: status || undefined,
    priority: priority || undefined,
    category: category || undefined,
  });

  const columns = useMemo<ColumnDef<SupportTicketRecord>[]>(
    () => [
      {
        header: "ID",
        cell: ({ row }) => <span className="font-mono text-xs">{row.original.id.slice(0, 8)}&hellip;</span>,
      },
      {
        header: "User",
        cell: ({ row }) => (
          <div>
            <div className="font-medium">{row.original.user.name ?? "Unknown"}</div>
            <div className="text-xs text-muted-foreground">{row.original.user.phone ?? "N/A"}</div>
          </div>
        ),
      },
      { header: "Category", cell: ({ row }) => <Badge variant="outline">{row.original.category}</Badge> },
      { header: "Subject", accessorKey: "subject" },
      {
        header: "Priority",
        cell: ({ row }) => (
          <Badge variant={priorityVariant(row.original.priority)}>{row.original.priority}</Badge>
        ),
      },
      {
        header: "Status",
        cell: ({ row }) => (
          <Badge variant={statusVariant(row.original.status)}>{row.original.status}</Badge>
        ),
      },
      { header: "Created", cell: ({ row }) => formatDate(row.original.createdAt) },
      {
        header: "Actions",
        cell: ({ row }) => (
          <Sheet>
            <SheetTrigger asChild>
              <Button size="sm" variant="outline">
                View
              </Button>
            </SheetTrigger>
            <TicketDetailSheet ticket={row.original} />
          </Sheet>
        ),
      },
    ],
    [],
  );

  return (
    <div className="space-y-6">
      <PageHeader title="Support Tickets" description="Triage, respond to, and resolve user support requests." />
      <FilterBar
        searchPlaceholder="Support filters by status and priority"
        selects={[
          {
            key: "status",
            value: status,
            placeholder: "Filter by status",
            options: ["OPEN", "IN_PROGRESS", "RESOLVED", "CLOSED"].map((v) => ({ value: v, label: v })),
          },
          {
            key: "priority",
            value: priority,
            placeholder: "Filter by priority",
            options: ["LOW", "MEDIUM", "HIGH", "URGENT"].map((v) => ({ value: v, label: v })),
          },
          {
            key: "category",
            value: category,
            placeholder: "Filter by category",
            options: ["GENERAL", "PAYMENT", "MATCH", "ACADEMY", "ARENA", "COACH", "ACCOUNT", "OTHER"].map((v) => ({
              value: v,
              label: v,
            })),
          },
        ]}
      />
      {query.isError && (
        <div className="rounded-xl border border-destructive bg-destructive/10 p-4 text-sm text-destructive">
          Failed to load tickets: {(query.error as Error)?.message ?? "Unknown error"}
        </div>
      )}
      <div className="rounded-xl border bg-card">
        <DataTable columns={columns} data={query.isLoading ? [] : (query.data?.tickets ?? [])} />
        {query.isLoading && <div className="p-8 text-center text-sm text-muted-foreground">Loading...</div>}
      </div>
      <PaginationBar page={page} limit={25} total={query.data?.total ?? 0} />
    </div>
  );
}
