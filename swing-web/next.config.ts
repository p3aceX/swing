import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  reactCompiler: true,
  // Hide the Next.js "N" dev-mode badge in the bottom corner.
  devIndicators: false,
  images: {
    remotePatterns: [
      { protocol: "https", hostname: "pdlqotoyxpzrylxvrmdm.supabase.co" },
    ],
  },
};

export default nextConfig;
