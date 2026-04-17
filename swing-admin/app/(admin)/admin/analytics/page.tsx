"use client";

import { useMemo } from "react";
import { Pie, PieChart, ResponsiveContainer, Tooltip, Cell } from "recharts";
import { useDashboardQuery, usePaymentsQuery } from "@/lib/queries";
import { EmptyState } from "@/components/admin/empty-state";
import { PageHeader } from "@/components/admin/page-header";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { formatCurrencyInr, paiseToInr } from "@/lib/utils";

const COLORS = ["#d65a31", "#1f7a8c", "#f4a259", "#2a9d8f"];

export default function AnalyticsPage() {
  const dashboard = useDashboardQuery();
  const payments = usePaymentsQuery({ page: 1, limit: 25 });

  const bookingsBreakdown = useMemo(
    () => [
      { name: "Completed", value: dashboard.data?.bookings.completed ?? 0 },
      { name: "Pending", value: Math.max((dashboard.data?.bookings.total ?? 0) - (dashboard.data?.bookings.completed ?? 0), 0) },
    ],
    [dashboard.data],
  );

  return (
    <div className="space-y-6">
      <PageHeader title="Analytics" description="High-level commercial analytics from currently available admin endpoints." />
      <div className="grid gap-6 lg:grid-cols-2">
        <Card>
          <CardHeader>
            <CardTitle>Total Revenue</CardTitle>
          </CardHeader>
          <CardContent className="text-4xl font-semibold">
            {formatCurrencyInr(paiseToInr(payments.data?.totalRevenuePaise ?? 0))}
          </CardContent>
        </Card>
        <Card>
          <CardHeader>
            <CardTitle>Bookings Mix</CardTitle>
          </CardHeader>
          <CardContent className="h-[320px]">
            {bookingsBreakdown.some((item) => item.value > 0) ? (
              <ResponsiveContainer width="100%" height="100%">
                <PieChart>
                  <Pie data={bookingsBreakdown} dataKey="value" nameKey="name" innerRadius={72} outerRadius={110}>
                    {bookingsBreakdown.map((entry, index) => (
                      <Cell key={entry.name} fill={COLORS[index % COLORS.length]} />
                    ))}
                  </Pie>
                  <Tooltip />
                </PieChart>
              </ResponsiveContainer>
            ) : (
              <EmptyState title="No booking data" description="Bookings will appear once the backend has records." />
            )}
          </CardContent>
        </Card>
      </div>
      <EmptyState
        title="Advanced analytics pending API support"
        description="Date-range revenue, coach leaderboards, arena leaderboards, and XP distribution need dedicated analytics endpoints. The page is reserved and protected."
      />
    </div>
  );
}
