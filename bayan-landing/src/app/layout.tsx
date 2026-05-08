import type { Metadata } from "next";
import { Inter } from "next/font/google";
import "./globals.css";

const inter = Inter({ subsets: ["latin", "latin-ext"] });

export const metadata: Metadata = {
  title: "بيان | منصة تعلّم القرآن الكريم الذكية",
  description: "نورٌ يضيءُ دربكَ، بيانٌ يرتلُ قلبكَ. رفيقك الذكي في رحلة الحفظ والمراجعة برواية ورش.",
  keywords: ["قرآن", "تحفيظ", "رواية ورش", "تطبيق إسلامي", "ذكاء اصطناعي", "بيان"],
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="ar" dir="rtl">
      <body className={inter.className}>{children}</body>
    </html>
  );
}
