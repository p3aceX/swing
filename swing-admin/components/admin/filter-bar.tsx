"use client";

import { useRouter, useSearchParams } from "next/navigation";
import { Search } from "lucide-react";
import { Input } from "@/components/ui/input";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";

export function FilterBar({
  searchKey = "search",
  searchPlaceholder,
  selects = [],
}: {
  searchKey?: string;
  searchPlaceholder: string;
  selects?: Array<{ key: string; value: string; placeholder: string; options: Array<{ value: string; label: string }> }>;
}) {
  const router = useRouter();
  const searchParams = useSearchParams();

  const update = (key: string, value: string) => {
    const params = new URLSearchParams(searchParams.toString());
    if (!value || value === "ALL") params.delete(key);
    else params.set(key, value);
    params.set("page", "1");
    router.push(`?${params.toString()}`);
  };

  return (
    <div className="flex flex-col gap-3 md:flex-row md:items-center">
      <div className="relative flex-1">
        <Search className="absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
        <Input
          defaultValue={searchParams.get(searchKey) ?? ""}
          className="pl-9"
          placeholder={searchPlaceholder}
          onKeyDown={(event) => {
            if (event.key === "Enter") {
              update(searchKey, (event.target as HTMLInputElement).value);
            }
          }}
        />
      </div>
      {selects.map((select) => (
        <Select key={select.key} value={select.value || "ALL"} onValueChange={(value) => update(select.key, value)}>
          <SelectTrigger className="w-full md:w-[200px]">
            <SelectValue placeholder={select.placeholder} />
          </SelectTrigger>
          <SelectContent>
            <SelectItem value="ALL">All</SelectItem>
            {select.options.map((option) => (
              <SelectItem key={option.value} value={option.value}>
                {option.label}
              </SelectItem>
            ))}
          </SelectContent>
        </Select>
      ))}
    </div>
  );
}
