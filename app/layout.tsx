import type { Metadata } from 'next'
import './globals.css'

export const metadata: Metadata = {
  title: 'Admin Dashboard Pro',
  description: 'Professional Admin Dashboard für Qualifizierungstool Analytics',
}

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="de">
      <head>
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" />
        <script src="https://cdn.jsdelivr.net/npm/chart.js@4"></script>
        <script src="https://cdn.jsdelivr.net/npm/date-fns@2"></script>
        <script src="https://cdn.jsdelivr.net/npm/chartjs-adapter-date-fns@3"></script>
      </head>
      <body>{children}</body>
    </html>
  )
}