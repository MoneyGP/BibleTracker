import Head from 'next/head';

export default function Layout({ children, title = "Bible Tracker" }) {
  return (
    <div style={{ minHeight: '100vh', display: 'flex', flexDirection: 'column' }}>
      <Head>
        <title>{title}</title>
        <meta name="viewport" content="width=device-width, initial-scale=1" />
      </Head>
      
      <main style={{ flex: 1, padding: '20px', maxWidth: '600px', margin: '0 auto', width: '100%' }}>
        {children}
      </main>
      
      <footer style={{ 
        textAlign: 'center', 
        padding: '20px', 
        color: 'var(--text-muted)', 
        fontSize: '0.8rem',
        borderTop: '1px solid var(--glass-bg)'
      }}>
        Bible in a Year Group
      </footer>
    </div>
  );
}
