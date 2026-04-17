import Credentials from "next-auth/providers/credentials";
import { z } from "zod";

const API_BASE_URL = process.env.NEXT_PUBLIC_API_BASE_URL ?? "http://localhost:3000";

const credentialsSchema = z.object({
  email: z.string().email(),
  password: z.string().min(6),
});

export const authConfig = {
  secret:
    process.env.NEXTAUTH_SECRET ??
    (process.env.NODE_ENV === "development" ? "swing-admin-dev-secret-change-me" : undefined),
  session: { strategy: "jwt" as const },
  pages: {
    signIn: "/login",
  },
  providers: [
    Credentials({
      name: "Admin Credentials",
      credentials: {
        email: { label: "Email", type: "email" },
        password: { label: "Password", type: "password" },
      },
      authorize: async (credentials) => {
        const parsed = credentialsSchema.safeParse(credentials);
        if (!parsed.success) return null;

        const { email, password } = parsed.data;

        const response = await fetch(`${API_BASE_URL}/admin/auth/login`, {
          method: "POST",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify({ email, password }),
        });

        const payload = await response.json().catch(() => null);
        if (!response.ok || !payload?.data) return null;

        const { user, accessToken } = payload.data;
        if (!["SWING_ADMIN", "SWING_SUPPORT"].includes(user.role)) return null;

        return {
          id: user.id,
          name: user.name,
          email: user.email,
          roles: [user.role],
          activeRole: user.role,
          backendAccessToken: accessToken,
          backendRefreshToken: "",
        };
      },
    }),
  ],
  callbacks: {
    jwt: async ({ token, user }: any) => {
      if (user) {
        token.roles = user.roles;
        token.activeRole = user.activeRole;
        token.backendAccessToken = user.backendAccessToken;
        token.backendRefreshToken = user.backendRefreshToken;
      }
      return token;
    },
    session: async ({ session, token }: any) => {
      if (session.user) {
        session.user.id = token.sub;
        session.user.roles = token.roles ?? [];
        session.user.activeRole = token.activeRole;
      }
      session.backendAccessToken = token.backendAccessToken;
      session.backendRefreshToken = token.backendRefreshToken;
      return session;
    },
    authorized: async ({ auth }: any) => !!auth,
  },
};
