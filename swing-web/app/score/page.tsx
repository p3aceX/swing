import type { Metadata } from "next";
import ScoreLoginClient from "./_login-client";

export const metadata: Metadata = {
  title: "Score a Match",
  description:
    "Enter your match ID and PIN to score a Swing match from any browser.",
  robots: { index: false, follow: false },
};

export default function ScoreLoginPage() {
  return <ScoreLoginClient />;
}
