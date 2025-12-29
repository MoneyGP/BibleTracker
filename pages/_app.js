import "@/styles/globals.css";
import { AuthProvider } from '@/contexts/AuthContext';

import Head from 'next/head';

export default function App({ Component, pageProps }) {
  return (
    <AuthProvider>
      <Head>
        <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=0" />
        <meta name="theme-color" content="#0f172a" />
        <link rel="manifest" href="/manifest.json" />
        <link rel="icon" href="/icons/icon-192x192.png" />
        <title>Bible Tracker</title>
      </Head>
      <Component {...pageProps} />
    </AuthProvider>
  );
}
