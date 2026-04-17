"use client";

import { useMemo } from "react";
import { Line, LineChart, ResponsiveContainer, Tooltip, XAxis, YAxis } from "recharts";
import { useDashboardQuery, useMatchesQuery, usePaymentsQuery, useUsersQuery } from "@/lib/queries";
import { PageHeader } from "@/components/admin/page-header";
import { StatCard } from "@/components/admin/stat-card";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { formatCurrencyInr, formatDate, paiseToInr, timeAgo } from "@/lib/utils";
import { Badge } from "@/components/ui/badge";
import { EmptyState } from "@/components/admin/empty-state";

export default function AdminDashboardPage() {
  const dashboard = useDashboardQuery();
  const users = useUsersQuery({ page: 1, limit: 20 });
  const matches = useMatchesQuery({ page: 1, limit: 20 });
  const payments = usePaymentsQuery({ page: 1, limit: 20, status: "COMPLETED" });

  const revenueSeries = useMemo(() => {
    const grouped = new Map<string, number>();
    for (const payment of payments.data?.payments ?? []) {
      const key = formatDate(payment.createdAt, "dd MMM");
      grouped.set(key, (grouped.get(key) ?? 0) + paiseToInr(payment.amountPaise));
    }
    return Array.from(grouped.entries()).map(([date, revenue]) => ({ date, revenue })).reverse();
  }, [payments.data]);

  const auditFeed = useMemo(() => {
    const recentUsers = (users.data?.users ?? []).slice(0, 8).map((user) => ({
      id: user.id,
      label: `${user.name || user.phone} joined the platform`,
      time: user.createdAt,
      kind: "USER",
    }));
    const recentMatches = (matches.data?.matches ?? []).slice(0, 6).map((match) => ({
      id: match.id,
      label: `Match ${match.id.slice(0, 6)} moved to ${match.status}`,
      time: match.createdAt,
      kind: "MATCH",
    }));
    return [...recentUsers, ...recentMatches]
      .sort((a, b) => +new Date(b.time) - +new Date(a.time))
      .slice(0, 20);
  }, [users.data, matches.data]);

  const data = dashboard.data;

  return (
    <div className="space-y-6">
      <PageHeader
        title="Dashboard"
        description="Platform-wide visibility for admins and support operators."
        action={
          <div className="flex gap-2">
            <Button asChild variant="outline">
              <a href="/admin/academies">Verify Pending Academies</a>
            </Button>
            <Button asChild>
              <a href="/admin/support">Open Tickets</a>
            </Button>
          </div>
        }
      />

      <div className="grid grid-cols-2 gap-4 sm:grid-cols-3 xl:grid-cols-6">
        <StatCard label="Total Users" value={String(data?.users.total ?? 0)} hint={`${data?.users.players ?? 0} players • ${data?.users.coaches ?? 0} coaches`} />
        <StatCard label="Revenue Today" value={formatCurrencyInr(paiseToInr(data?.revenue.totalPaise ?? 0))} hint="Completed payments aggregate" />
        <StatCard label="Active Matches" value={String(data?.matches.active ?? 0)} hint={`${data?.matches.total ?? 0} matches total`} />
        <StatCard label="Open Tickets" value="0" hint="Support API not available yet" />
        <StatCard label="New Signups Today" value={String((users.data?.users ?? []).filter((user) => formatDate(user.createdAt, "yyyy-MM-dd") === formatDate(new Date(), "yyyy-MM-dd")).length)} hint="From latest user records" />
        <StatCard label="Total Arenas" value={String(data?.arenas.total ?? 0)} hint={`${data?.academies.total ?? 0} academies also active`} />
      </div>

      <div className="grid gap-6 xl:grid-cols-[1.6fr_1fr]">
        <Card>
          <CardHeader>
            <CardTitle>Revenue Trend</CardTitle>
          </CardHeader>
          <CardContent className="h-[320px]">
            {revenueSeries.length ? (
              <ResponsiveContainer width="100%" height="100%">
                <LineChart data={revenueSeries}>
                  <XAxis dataKey="date" tickLine={false} axisLine={false} />
                  <YAxis tickFormatter={(value) => `₹${value}`} tickLine={false} axisLine={false} />
                  <Tooltip formatter={(value: number) => formatCurrencyInr(value)} />
                  <Line dataKey="revenue" type="monotone" stroke="hsl(var(--primary))" strokeWidth={3} dot={false} />
                </LineChart>
              </ResponsiveContainer>
            ) : (
              <EmptyState title="No revenue data" description="Completed payments will appear here once the backend has recent payment records." />
            )}
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle>Recent Audit Feed</CardTitle>
          </CardHeader>
          <CardContent className="space-y-3">
            {auditFeed.length ? (
              auditFeed.map((item) => (
                <div key={`${item.kind}-${item.id}`} className="flex items-start justify-between rounded-xl border p-3">
                  <div>
                    <Badge variant="outline" className="mb-2">
                      {item.kind}
                    </Badge>
                    <div className="text-sm font-medium">{item.label}</div>
                  </div>
                  <div className="text-xs text-muted-foreground">{timeAgo(item.time)}</div>
                </div>
              ))
            ) : (
              <EmptyState title="No recent activity" description="Recent admin-adjacent records will show up here." />
            )}
          </CardContent>
        </Card>
      </div>
    </div>
  );
}
