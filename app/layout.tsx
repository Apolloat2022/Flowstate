import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "FlowState - Deep Work Task Manager",
  description: "Focus-driven task management with Pomodoro timer",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en">
      <body>{children}</body>
    </html>
  );
}
