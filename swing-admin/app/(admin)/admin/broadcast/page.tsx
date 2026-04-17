"use client";

import { useForm } from "react-hook-form";
import { PageHeader } from "@/components/admin/page-header";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Textarea } from "@/components/ui/textarea";
import { Button } from "@/components/ui/button";
import { useBroadcastMutation } from "@/lib/queries";

type FormValues = {
  title: string;
  body: string;
  roles: string;
  userIds: string;
};

export default function BroadcastPage() {
  const mutation = useBroadcastMutation();
  const form = useForm<FormValues>({
    defaultValues: { title: "", body: "", roles: "", userIds: "" },
  });

  return (
    <div className="space-y-6">
      <PageHeader title="Broadcast Notification" description="Send a push notification to selected users, roles, or everyone." />
      <Card className="max-w-3xl">
        <CardHeader>
          <CardTitle>Compose Broadcast</CardTitle>
        </CardHeader>
        <CardContent>
          <form
            className="space-y-4"
            onSubmit={form.handleSubmit((values) =>
              mutation.mutate({
                title: values.title,
                body: values.body,
                roles: values.roles ? values.roles.split(",").map((item) => item.trim()) : undefined,
                userIds: values.userIds ? values.userIds.split(",").map((item) => item.trim()) : undefined,
              }),
            )}
          >
            <div className="space-y-2">
              <Label>Title</Label>
              <Input {...form.register("title", { required: true })} />
            </div>
            <div className="space-y-2">
              <Label>Body</Label>
              <Textarea {...form.register("body", { required: true })} />
            </div>
            <div className="grid gap-4 md:grid-cols-2">
              <div className="space-y-2">
                <Label>Roles</Label>
                <Input placeholder="COACH,PLAYER" {...form.register("roles")} />
              </div>
              <div className="space-y-2">
                <Label>User IDs</Label>
                <Input placeholder="id1,id2" {...form.register("userIds")} />
              </div>
            </div>
            <Button disabled={mutation.isPending}>{mutation.isPending ? "Sending..." : "Send Broadcast"}</Button>
          </form>
        </CardContent>
      </Card>
    </div>
  );
}
