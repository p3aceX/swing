"use client";

import { useRouter, useSearchParams } from "next/navigation";
import { Button } from "@/components/ui/button";

export function PaginationBar({ page, limit, total }: { page: number; limit: number; total: number }) {
  const router = useRouter();
  const searchParams = useSearchParams();
  const totalPages = Math.max(1, Math.ceil(total / limit));

  const navigate = (nextPage: number) => {
    const params = new URLSearchParams(searchParams.toString());
    params.set("page", String(nextPage));
    router.push(`?${params.toString()}`);
  };

  return (
    <div className="flex items-center justify-between border-t pt-4">
      <div className="text-xs text-muted-foreground sm:text-sm">
        Pg {page}/{totalPages} • {total}
        <span className="hidden sm:inline"> records</span>
      </div>
      <div className="flex gap-2">
        <Button size="sm" variant="outline" onClick={() => navigate(page - 1)} disabled={page <= 1}>
          Previous
        </Button>
        <Button size="sm" variant="outline" onClick={() => navigate(page + 1)} disabled={page >= totalPages}>
          Next
        </Button>
      </div>
    </div>
  );
}
