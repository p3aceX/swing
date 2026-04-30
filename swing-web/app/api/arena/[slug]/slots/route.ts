import { NextRequest, NextResponse } from "next/server";

const API = (
  process.env.NEXT_PUBLIC_API_BASE_URL ||
  process.env.API_BASE_URL ||
  "https://swing-backend-1007730655118.asia-south1.run.app"
).replace(/\/$/, "");

export async function GET(
  req: NextRequest,
  { params }: { params: Promise<{ slug: string }> }
) {
  const { slug } = await params;
  const date = req.nextUrl.searchParams.get("date") ?? "";
  try {
    const res = await fetch(
      `${API}/public/arena/p/${encodeURIComponent(slug)}/slots?date=${date}`,
      { cache: "no-store" }
    );
    const body = await res.json();
    return NextResponse.json(body, { status: res.status });
  } catch {
    return NextResponse.json(
      { success: false, error: "Failed to fetch slots" },
      { status: 502 }
    );
  }
}
