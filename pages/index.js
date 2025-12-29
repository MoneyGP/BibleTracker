import { useState, useEffect } from 'react';
import Link from 'next/link';
import Layout from '@/components/Layout';
import Card from '@/components/Card';
import Button from '@/components/Button';
import FeedItem from '@/components/FeedItem';
import Streaks from '@/components/Streaks';
import Auth from '@/components/Auth';
import { useAuth } from '@/contexts/AuthContext';
import { supabase } from '@/lib/supabaseClient';
import { fullPlan } from '@/data/fullPlan';
// mockFeed is no longer needed, we'll fetch real data

export default function Home() {
  const { user, loading } = useAuth();
  const [reading, setReading] = useState(null);
  const [feed, setFeed] = useState([]);

  useEffect(() => {
    const fetchFeed = async () => {
      const { data, error } = await supabase
        .from('posts')
        .select(`
              *,
              profiles(username, avatar_url)
          `)
        .order('created_at', { ascending: false });

      if (error) console.error('Error fetching feed:', error);
      if (data) {
        console.log('Fetched feed:', data);
        setFeed(data);
      }
    };

    // Load reading from FULL PLAN using today's date
    const todayStr = new Date().toISOString().split('T')[0];
    const found = fullPlan.find(p => p.date === todayStr);
    setReading(found || fullPlan[0]); // Fallback

    if (user) {
      fetchFeed();
    }
  }, [user]);



  if (loading) return <Layout><div style={{ padding: 20 }}>Loading...</div></Layout>;
  if (!user) return <Layout><Auth /></Layout>;
  if (!reading) return <Layout><div style={{ padding: 20 }}>Loading Plan...</div></Layout>;

  return (
    <Layout>
      <header style={{ marginBottom: '32px', display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
        <div>
          <h1 className="text-gradient" style={{ fontSize: '2rem', marginBottom: '8px' }}>Bible Tracker</h1>
          <p style={{ color: 'var(--text-muted)' }}>{(() => {
            const [y, m, d] = reading.date.split('-').map(Number);
            return new Date(y, m - 1, d).toLocaleDateString(undefined, { weekday: 'long', month: 'long', day: 'numeric', year: 'numeric' });
          })()}</p>
        </div>
        <div style={{ display: 'flex', gap: '8px' }}>
          <Link href="/profile" passHref>
            <Button variant="glass" style={{ width: '40px', height: '40px', padding: 0, borderRadius: '50%' }}>
              👤
            </Button>
          </Link>
          <Link href="/calendar" passHref>
            <Button variant="glass" style={{ width: '40px', height: '40px', padding: 0, borderRadius: '50%' }}>
              📅
            </Button>
          </Link>
        </div>
      </header>

      <section style={{ marginBottom: '40px' }}>
        <h2 style={{ fontSize: '1.2rem', marginBottom: '16px' }}>Today's Reading</h2>
        <Card style={{ background: 'linear-gradient(135deg, var(--bg-color-alt), var(--glass-bg))' }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', marginBottom: '24px' }}>
            <div>
              <div style={{ fontSize: '0.9rem', color: 'var(--primary)', marginBottom: '4px', textTransform: 'uppercase', letterSpacing: '1px' }}>Day {reading.day}</div>
              <div style={{ fontSize: '1.8rem', fontWeight: 'bold' }}>{reading.reading}</div>
            </div>
            <div style={{
              background: 'hsla(var(--hue-primary), var(--sat-primary), var(--lum-primary), 0.1)',
              color: 'var(--primary)', padding: '4px 12px', borderRadius: '12px', fontSize: '0.8rem', fontWeight: '600'
            }}>
              20 min
            </div>
          </div>

          <Link href={`/upload?reading=${encodeURIComponent(reading.reading)}`} passHref>
            <Button variant="primary" style={{ width: '100%' }}>Mark as Read & Upload</Button>
          </Link>
        </Card>
      </section>

      <Streaks />

      <section>
        <h2 style={{ fontSize: '1.2rem', marginBottom: '16px' }}>Group Feed</h2>
        {feed.length === 0 && <p style={{ color: 'var(--text-muted)' }}>No posts yet. Be the first!</p>}
        {feed.map(item => (
          <FeedItem key={item.id} item={item} />
        ))}
      </section>
    </Layout>
  );
}
