import "next-auth";

declare module "next-auth" {
  interface Session {
    backendAccessToken?: string;
    backendRefreshToken?: string;
    user: {
      id?: string;
      name?: string | null;
      email?: string | null;
      roles?: string[];
      activeRole?: string;
    };
  }

  interface User {
    roles?: string[];
    activeRole?: string;
    backendAccessToken?: string;
    backendRefreshToken?: string;
  }
}

declare module "@auth/core/jwt" {
  interface JWT {
    roles?: string[];
    activeRole?: string;
    backendAccessToken?: string;
    backendRefreshToken?: string;
  }
}
