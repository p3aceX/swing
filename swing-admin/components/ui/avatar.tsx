import { initials, cn } from "@/lib/utils";

export function Avatar({ name, className }: { name?: string | null; className?: string }) {
  return (
    <div className={cn("flex h-10 w-10 items-center justify-center rounded-full bg-primary/10 font-semibold text-primary", className)}>
      {initials(name)}
    </div>
  );
}
