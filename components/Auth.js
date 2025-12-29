import { useState } from 'react';
import { supabase } from '@/lib/supabaseClient';
import Button from './Button';
import Card from './Card';

export default function Auth() {
    const [loading, setLoading] = useState(false);
    const [email, setEmail] = useState('');
    const [password, setPassword] = useState('');
    const [mode, setMode] = useState('signin'); // 'signin' or 'signup'
    const [message, setMessage] = useState('');

    const handleAuth = async (e) => {
        e.preventDefault();
        setLoading(true);
        setMessage('');

        try {
            if (mode === 'signup') {
                const { data, error } = await supabase.auth.signUp({
                    email,
                    password,
                });
                if (error) throw error;

                if (data.user) {
                    // Create profile
                    const { error: profileError } = await supabase
                        .from('profiles')
                        .insert([
                            { id: data.user.id, username: email.split('@')[0] }
                        ]);
                    if (profileError) console.error('Error creating profile:', profileError);
                }

                setMessage('Account created! You may need to confirm your email.');
            } else {
                const { error } = await supabase.auth.signInWithPassword({
                    email,
                    password,
                });
                if (error) throw error;
            }
        } catch (error) {
            setMessage(error.message);
        } finally {
            setLoading(false);
        }
    };

    return (
        <div style={{ display: 'flex', justifyContent: 'center', alignItems: 'center', minHeight: '80vh' }}>
            <Card style={{ maxWidth: '400px', width: '100%', padding: '32px' }}>
                <h2 style={{ textAlign: 'center', marginBottom: '8px', fontSize: '1.5rem' }} className="text-gradient">
                    {mode === 'signin' ? 'Welcome Back' : 'Create Account'}
                </h2>
                <p style={{ textAlign: 'center', marginBottom: '24px', color: 'var(--text-muted)' }}>
                    {mode === 'signin' ? 'Sign in to track your reading' : 'Join the group to track progress'}
                </p>

                {message && <div style={{ marginBottom: '16px', padding: '12px', background: 'rgba(255,255,255,0.1)', borderRadius: '8px', fontSize: '0.9rem' }}>{message}</div>}

                <form onSubmit={handleAuth} style={{ display: 'flex', flexDirection: 'column', gap: '16px' }}>
                    <input
                        type="email"
                        placeholder="Email"
                        value={email}
                        onChange={(e) => setEmail(e.target.value)}
                        style={{
                            padding: '12px',
                            borderRadius: '8px',
                            border: '1px solid var(--glass-border)',
                            background: 'rgba(255,255,255,0.05)',
                            color: 'var(--text-main)',
                            fontSize: '1rem',
                            outline: 'none'
                        }}
                        required
                    />
                    <input
                        type="password"
                        placeholder="Password"
                        value={password}
                        onChange={(e) => setPassword(e.target.value)}
                        style={{
                            padding: '12px',
                            borderRadius: '8px',
                            border: '1px solid var(--glass-border)',
                            background: 'rgba(255,255,255,0.05)',
                            color: 'var(--text-main)',
                            fontSize: '1rem',
                            outline: 'none'
                        }}
                        required
                        minLength={6}
                    />
                    <Button type="submit" variant="primary" disabled={loading}>
                        {loading ? 'Processing...' : (mode === 'signin' ? 'Sign In' : 'Sign Up')}
                    </Button>
                </form>

                <div style={{ marginTop: '24px', textAlign: 'center', fontSize: '0.9rem' }}>
                    <span style={{ color: 'var(--text-muted)' }}>
                        {mode === 'signin' ? "Don't have an account? " : "Already have an account? "}
                    </span>
                    <button
                        onClick={() => {
                            setMode(mode === 'signin' ? 'signup' : 'signin');
                            setMessage('');
                        }}
                        style={{ background: 'none', border: 'none', color: 'var(--primary)', cursor: 'pointer', fontWeight: 'bold' }}
                    >
                        {mode === 'signin' ? 'Sign Up' : 'Sign In'}
                    </button>
                </div>
            </Card>
        </div>
    );
}
