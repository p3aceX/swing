import type { Metadata } from "next";
import { Geist, Geist_Mono } from "next/font/google";
import "./globals.css";

const geistSans = Geist({
  variable: "--font-geist-sans",
  subsets: ["latin"],
});

const geistMono = Geist_Mono({
  variable: "--font-geist-mono",
  subsets: ["latin"],
});

export const metadata: Metadata = {
  title: {
    default: "Swing",
    template: "%s | Swing",
  },
  description:
    "Swing is a sports ecosystem app for players, academies, coaches, facilities, organisers and broadcasters. Score matches, manage training, book venues, stream events and earn IP Points across sports.",
  metadataBase: new URL("https://www.swingcricketapp.com"),
  keywords: [
    "sports ecosystem app",
    "sports scoring app",
    "sports academy management",
    "venue booking",
    "tournament management",
    "live scoring",
    "player stats",
    "Swing app",
  ],
  authors: [{ name: "Cricverse SportsTech Pvt Ltd" }],
  alternates: {
    canonical: "/",
  },
  openGraph: {
    title: "Swing — India's sports ecosystem app.",
    description:
      "One connected app for players, academies, coaches, facilities, organisers and broadcasters across sports.",
    siteName: "Swing",
    type: "website",
    locale: "en_US",
    url: "/",
    images: [
      {
        url: "/assets/logo-light.png",
        width: 1200,
        height: 630,
        alt: "Swing",
      },
    ],
  },
  twitter: {
    card: "summary_large_image",
    title: "Swing — India's sports ecosystem app.",
    description:
      "Score, train, book, stream and manage sport on one connected ecosystem.",
    images: ["/assets/logo-light.png"],
  },
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en">
      <body
        className={`${geistSans.variable} ${geistMono.variable} antialiased`}
      >
        {children}
      </body>
    </html>
  );
}
