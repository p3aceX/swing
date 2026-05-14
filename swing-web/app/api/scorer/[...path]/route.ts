import { NextRequest, NextResponse } from "next/server";

// Catch-all proxy for the swing-web web scorer. Every request to
// `/api/scorer/<anything>` is forwarded verbatim to the backend at
// `/public/scorer/<anything>` so the browser never sees the backend URL.
//
// We forward the bearer token (the scorer JWT issued by POST
// /public/scorer/auth) untouched. The backend's `scorerGuard` is the
// authority on auth — this proxy is pure transport.

const API = (
  process.env.NEXT_PUBLIC_API_BASE_URL ||
  process.env.API_BASE_URL ||
  "https://swing-backend-nbid5gga4q-el.a.run.app"
).replace(/\/$/, "");

type Ctx = { params: Promise<{ path: string[] }> };

async function proxy(req: NextRequest, ctx: Ctx) {
  const { path } = await ctx.params;
  const subpath = (path ?? []).map(encodeURIComponent).join("/");
  const search = req.nextUrl.search ?? "";
  const url = `${API}/public/scorer/${subpath}${search}`;

  const headers = new Headers();
  const auth = req.headers.get("authorization");
  if (auth) headers.set("authorization", auth);
  const contentType = req.headers.get("content-type");
  if (contentType) headers.set("content-type", contentType);

  const init: RequestInit = {
    method: req.method,
    headers,
    cache: "no-store",
  };
  if (req.method !== "GET" && req.method !== "HEAD") {
    const body = await req.text();
    if (body) init.body = body;
  }

  try {
    const res = await fetch(url, init);
    const text = await res.text();
    const respHeaders = new Headers();
    const ct = res.headers.get("content-type");
    if (ct) respHeaders.set("content-type", ct);
    return new NextResponse(text, { status: res.status, headers: respHeaders });
  } catch {
    return NextResponse.json(
      { success: false, error: { code: "PROXY_ERROR", message: "Upstream unreachable" } },
      { status: 502 },
    );
  }
}

export const GET = proxy;
export const POST = proxy;
export const DELETE = proxy;
export const PATCH = proxy;
export const PUT = proxy;
