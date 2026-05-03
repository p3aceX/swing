import { NextRequest, NextResponse } from "next/server";

const API = (
  process.env.NEXT_PUBLIC_API_BASE_URL ||
  process.env.API_BASE_URL ||
  "https://swing-backend-nbid5gga4q-el.a.run.app"
).replace(/\/$/, "");

export async function GET(
  req: NextRequest,
  { params }: { params: Promise<{ arenaId: string }> }
) {
  const { arenaId } = await params;
  const date = req.nextUrl.searchParams.get("date") ?? "";
  const durationMins = req.nextUrl.searchParams.get("durationMins") ?? "60";
  const includeAvailability = req.nextUrl.searchParams.get("includeAvailability") ?? "true";

  try {
    const url = `${API}/arenas/${encodeURIComponent(arenaId)}/booking-context?date=${encodeURIComponent(date)}&durationMins=${encodeURIComponent(durationMins)}&includeAvailability=${encodeURIComponent(includeAvailability)}`;
    const res = await fetch(url, { cache: "no-store" });
    const body = await res.json();
    return NextResponse.json(body, { status: res.status });
  } catch {
    return NextResponse.json(
      { success: false, error: "Failed to fetch booking context" },
      { status: 502 }
    );
  }
}
