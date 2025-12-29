
import { useState, useEffect } from 'react';
import { useRouter } from 'next/router';
import Layout from '@/components/Layout';
import Button from '@/components/Button';
import Card from '@/components/Card';
import { useAuth } from '@/contexts/AuthContext';
import { supabase } from '@/lib/supabaseClient';

export default function Profile() {
    const { user, loading } = useAuth();
    const router = useRouter();
    const [username, setUsername] = useState('');
    const [saving, setSaving] = useState(false);
    const [message, setMessage] = useState(null);

    useEffect(() => {
        if (user) {
            fetchProfile();
        }
    }, [user]);

    const fetchProfile = async () => {
        const { data, error } = await supabase
            .from('profiles')
            .select('username')
            .eq('id', user.id)
            .single();

        if (error) {
            console.error('Error fetching profile:', error);
        } else if (data) {
            setUsername(data.username || '');
        }
    };

    const handleSave = async (e) => {
        e.preventDefault();
        setSaving(true);
        setMessage(null);

        const { error } = await supabase
            .from('profiles')
            .update({ username, updated_at: new Date() })
            .eq('id', user.id);

        if (error) {
            setMessage({ type: 'error', text: 'Failed to update profile' });
            console.error(error);
        } else {
            setMessage({ type: 'success', text: 'Profile updated!' });
            setTimeout(() => {
                router.push('/');
            }, 1000);
        }
        setSaving(false);
    };

    if (loading) return <Layout>Loading...</Layout>;
    if (!user) {
        if (typeof window !== 'undefined') router.push('/');
        return null;
    }

    return (
        <Layout title="Edit Profile">
            <div style={{ maxWidth: '400px', margin: '0 auto' }}>
                <h1 className="text-gradient" style={{ fontSize: '1.8rem', marginBottom: '24px', textAlign: 'center' }}>
                    Your Profile
                </h1>

                <Card>
                    <form onSubmit={handleSave}>
                        <div style={{ marginBottom: '20px' }}>
                            <label style={{ display: 'block', marginBottom: '8px', fontSize: '0.9rem', color: 'var(--text-muted)' }}>
                                Email
                            </label>
                            <input
                                type="text"
                                value={user.email}
                                disabled
                                style={{
                                    width: '100%',
                                    padding: '12px',
                                    borderRadius: '12px',
                                    border: '1px solid rgba(255,255,255,0.1)',
                                    background: 'rgba(255,255,255,0.05)',
                                    color: 'var(--text-muted)',
                                    fontSize: '1rem'
                                }}
                            />
                        </div>

                        <div style={{ marginBottom: '32px' }}>
                            <label style={{ display: 'block', marginBottom: '8px', fontSize: '0.9rem', color: 'var(--text-muted)' }}>
                                Username
                            </label>
                            <input
                                type="text"
                                value={username}
                                onChange={(e) => setUsername(e.target.value)}
                                placeholder="Choose a username"
                                style={{
                                    width: '100%',
                                    padding: '12px',
                                    borderRadius: '12px',
                                    border: '1px solid rgba(255,255,255,0.2)',
                                    background: 'rgba(255,255,255,0.1)',
                                    color: '#fff',
                                    fontSize: '1rem',
                                    outline: 'none'
                                }}
                            />
                        </div>

                        {message && (
                            <div style={{
                                padding: '12px',
                                borderRadius: '8px',
                                marginBottom: '20px',
                                textAlign: 'center',
                                background: message.type === 'error' ? 'rgba(255, 100, 100, 0.2)' : 'rgba(100, 255, 100, 0.2)',
                                color: message.type === 'error' ? '#ff8888' : '#88ff88'
                            }}>
                                {message.text}
                            </div>
                        )}

                        <Button type="submit" variant="primary" style={{ width: '100%' }} disabled={saving}>
                            {saving ? 'Saving...' : 'Save Profile'}
                        </Button>
                    </form>
                </Card>


                <Card style={{ marginTop: '24px', padding: '16px' }}>
                    <h3 style={{ fontSize: '1rem', marginBottom: '12px' }}>Notifications</h3>
                    <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
                        <span style={{ fontSize: '0.9rem', color: 'var(--text-muted)' }}>Daily Reminder</span>
                        <Button
                            variant="glass"
                            style={{ fontSize: '0.8rem', padding: '6px 12px' }}
                            onClick={async () => {
                                // 1. Check for HTTPS (Required for Notifications)
                                if (!window.isSecureContext) {
                                    alert('Security Error: Notifications require HTTPS.\n\nSince you are testing via local IP (Http), the phone blocks this.\n\nIt will work once deployed to the web (Vercel/Netlify).');
                                    return;
                                }

                                // 2. Check for iOS PWA
                                if (!('Notification' in window)) {
                                    alert('To enable notifications on iPhone:\n1. Tap Share (box with arrow)\n2. Tap "Add to Home Screen"\n3. Open the app from Home Screen');
                                    return;
                                }

                                try {
                                    const permission = await Notification.requestPermission();
                                    if (permission === 'granted') {
                                        new Notification('Enabled!', { body: 'You will fail... if you do not read.' });
                                        setMessage({ type: 'success', text: 'Notifications Enabled!' });
                                    } else {
                                        setMessage({ type: 'error', text: 'Permission Denied. Check settings.' });
                                    }
                                } catch (err) {
                                    console.error(err);
                                    alert('Error requesting permission: ' + err.message);
                                }
                            }}
                        >
                            Test / Enable
                        </Button>
                    </div>
                </Card>

                <div style={{ marginTop: '24px', textAlign: 'center' }}>
                    <Button variant="ghost" onClick={() => router.push('/')}>
                        Cancel
                    </Button>
                </div>
            </div>
        </Layout>
    );
}
