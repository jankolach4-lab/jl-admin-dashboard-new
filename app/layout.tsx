export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="de">
      <body style={{margin: 0, fontFamily: 'Arial, sans-serif', background: '#f9fafb'}}>{children}</body>
    </html>
  )
}
