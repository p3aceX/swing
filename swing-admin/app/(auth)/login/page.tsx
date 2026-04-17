"use client";

import Image from "next/image";
import { useState, useEffect } from "react";
import { signIn, useSession } from "next-auth/react";
import { useRouter } from "next/navigation";
import { useForm } from "react-hook-form";
import { z } from "zod";
import { zodResolver } from "@hookform/resolvers/zod";
import { ArrowRight } from "lucide-react";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Button } from "@/components/ui/button";
import logoMain from "@/assets/logo-main.png";

const formSchema = z.object({
  email: z.string().email("Enter a valid admin email."),
  password: z.string().min(6, "Password must be at least 6 characters."),
});

type FormValues = z.infer<typeof formSchema>;

export default function LoginPage() {
  const router = useRouter();
  const { status } = useSession();
  const [error, setError] = useState<string | null>(null);
  const form = useForm<FormValues>({
    resolver: zodResolver(formSchema),
    defaultValues: {
      email: "",
      password: "",
    },
  });

  // Already logged in — go straight to dashboard
  useEffect(() => {
    if (status === "authenticated") router.replace("/admin");
  }, [status, router]);

  const onSubmit = form.handleSubmit(async (values) => {
    setError(null);
    const result = await signIn("credentials", {
      ...values,
      redirect: false,
    });

    if (result?.error) {
      setError("Login failed. Verify Firebase email/password and admin role.");
      return;
    }

    router.push("/admin");
    router.refresh();
  });

  return (
    <div className="relative min-h-screen overflow-hidden bg-[#040605] text-white">
      <div className="absolute inset-0 bg-[radial-gradient(circle_at_top,rgba(34,197,94,0.16),transparent_30%),radial-gradient(circle_at_bottom_right,rgba(22,101,52,0.18),transparent_28%),linear-gradient(180deg,#020303_0%,#060907_55%,#030403_100%)]" />
      <div className="absolute left-1/2 top-24 h-56 w-56 -translate-x-1/2 rounded-full bg-emerald-500/10 blur-3xl" />

      <div className="relative flex min-h-screen items-center justify-center px-4 py-8 sm:px-6">
        <div className="w-full max-w-md rounded-[2rem] border border-white/10 bg-white/[0.04] p-6 shadow-[0_30px_80px_rgba(0,0,0,0.55)] backdrop-blur-xl sm:p-8">
          <div className="flex flex-col items-center text-center">
            <div className="rounded-[1.5rem] border border-white/10 bg-white/[0.05] p-3 shadow-[0_18px_40px_rgba(0,0,0,0.35)]">
              <Image
                src={logoMain}
                alt="Swing"
                priority
                className="h-14 w-14 object-contain sm:h-16 sm:w-16"
              />
            </div>
            <div className="mt-5 text-[11px] font-medium uppercase tracking-[0.32em] text-emerald-200/80">Swing Admin</div>
            <h1 className="mt-3 text-3xl font-semibold tracking-tight text-white sm:text-[2rem]">Welcome back</h1>
            <p className="mt-3 max-w-xs text-sm leading-6 text-white/58">Quiet systems create confident game days.</p>
          </div>

          <form className="mt-8 space-y-4" onSubmit={onSubmit}>
            <div className="space-y-2">
              <Label htmlFor="email" className="sr-only">
                Email
              </Label>
              <Input
                id="email"
                type="email"
                autoComplete="email"
                placeholder="Email"
                disabled={form.formState.isSubmitting}
                className="h-12 rounded-2xl border-white/10 bg-white/[0.03] px-4 text-white placeholder:text-white/30 focus-visible:ring-emerald-400"
                {...form.register("email")}
              />
              {form.formState.errors.email ? (
                <div className="text-sm text-red-300">{form.formState.errors.email.message}</div>
              ) : null}
            </div>

            <div className="space-y-2">
              <Label htmlFor="password" className="sr-only">
                Password
              </Label>
              <Input
                id="password"
                type="password"
                autoComplete="current-password"
                placeholder="Password"
                disabled={form.formState.isSubmitting}
                className="h-12 rounded-2xl border-white/10 bg-white/[0.03] px-4 text-white placeholder:text-white/30 focus-visible:ring-emerald-400"
                {...form.register("password")}
              />
              {form.formState.errors.password ? (
                <div className="text-sm text-red-300">{form.formState.errors.password.message}</div>
              ) : null}
            </div>

            {error ? (
              <div className="rounded-2xl border border-red-400/20 bg-red-500/10 px-4 py-3 text-sm text-red-200">
                {error}
              </div>
            ) : null}

            <Button
              type="submit"
              size="lg"
              disabled={form.formState.isSubmitting}
              className="h-12 w-full rounded-2xl bg-emerald-500 text-black shadow-[0_16px_36px_rgba(34,197,94,0.25)] hover:bg-emerald-400"
            >
              <span>{form.formState.isSubmitting ? "Signing in..." : "Enter"}</span>
              {!form.formState.isSubmitting ? <ArrowRight className="ml-2 h-4 w-4" /> : null}
            </Button>
          </form>

          <div className="mt-6 text-center text-xs uppercase tracking-[0.24em] text-white/28">Arenas • Matches • Events</div>
        </div>
      </div>
    </div>
  );
}
