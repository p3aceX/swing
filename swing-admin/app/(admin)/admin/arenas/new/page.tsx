"use client";

import Link from "next/link";
import { useRouter } from "next/navigation";
import { ArrowLeft } from "lucide-react";
import { ArenaForm } from "@/components/admin/arena-form";
import { PageHeader } from "@/components/admin/page-header";
import { Button } from "@/components/ui/button";
import { useCreateArenaMutation } from "@/lib/queries";
import type { CreateArenaBody } from "@/lib/api";

export default function CreateArenaPage() {
  const router = useRouter();
  const createArenaMutation = useCreateArenaMutation();

  function handleCreate(payload: CreateArenaBody) {
    createArenaMutation.mutate(payload, {
      onSuccess: (arena) => {
        router.push(`/admin/arenas/${arena.id}`);
      },
    });
  }

  return (
    <div className="space-y-6">
      <PageHeader
        title="Create Arena"
        description="Create a new arena record aligned with the current Arena, ArenaAddon, and ArenaUnit schema."
        action={
          <Button asChild variant="outline">
            <Link href="/admin/arenas">
              <ArrowLeft className="mr-2 h-4 w-4" />
              Back to Arenas
            </Link>
          </Button>
        }
      />
      <ArenaForm
        mode="create"
        submitting={createArenaMutation.isPending}
        onSubmit={handleCreate}
      />
    </div>
  );
}
