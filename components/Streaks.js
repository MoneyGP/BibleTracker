
import { useState, useEffect } from 'react';
import { supabase } from '@/lib/supabaseClient';
import Card from './Card';

export default function Streaks() {
    const [members, setMembers] = useState([]);
    const [loading, setLoading] = useState(true);

    useEffect(() => {
        fetchGroupData();
    }, []);

    const fetchGroupData = async () => {
        try {
            // 1. Fetch all profiles
            const { data: profiles, error: profileError } = await supabase
                .from('profiles')
                .select('id, username, avatar_url');

            if (profileError) throw profileError;
            if (!profiles) return;

            // 2. Fetch all posts (we need dates)
            const { data: posts, error: postError } = await supabase
                .from('posts')
                .select('user_id, date, created_at')
                .order('date', { ascending: false });

            if (postError) throw postError;

            // 3. Process Streaks
            const memberStats = profiles.map(user => {
                const userPosts = posts.filter(p => p.user_id === user.id);

                // Get unique sorted dates (YYYY-MM-DD)
                const dates = [...new Set(userPosts.map(p => {
                    return p.date || p.created_at.split('T')[0];
                }))].sort((a, b) => new Date(b) - new Date(a)); // Descending

                const streak = calculateStreak(dates);

                return {
                    id: user.id,
                    name: user.username || 'User',
                    avatar: user.avatar_url,
                    streak
                };
            });

            // Sort by streak (highest first)
            memberStats.sort((a, b) => b.streak - a.streak);

            setMembers(memberStats);
        } catch (error) {
            console.error('Error fetching streaks:', error);
        } finally {
            setLoading(false);
        }
    };

    const calculateStreak = (sortedDates) => {
        if (sortedDates.length === 0) return 0;

        const today = new Date();
        const yesterday = new Date();
        yesterday.setDate(yesterday.getDate() - 1);

        const todayStr = today.toISOString().split('T')[0];
        const yesterdayStr = yesterday.toISOString().split('T')[0];

        // Check if the streak is active (must have posted today or yesterday)
        const lastPost = sortedDates[0];
        if (lastPost !== todayStr && lastPost !== yesterdayStr) {
            return 0;
        }

        let currentStreak = 1;
        let currentDate = new Date(lastPost);

        for (let i = 1; i < sortedDates.length; i++) {
            const prevDate = new Date(sortedDates[i]);

            // Expected previous date is 1 day before currentDate
            const expectedDate = new Date(currentDate);
            expectedDate.setDate(expectedDate.getDate() - 1);
            const expectedStr = expectedDate.toISOString().split('T')[0];
            const prevStr = sortedDates[i];

            if (prevStr === expectedStr) {
                currentStreak++;
                currentDate = prevDate;
            } else {
                break; // Gap found
            }
        }

        return currentStreak;
    };

    if (loading) return null;
    if (members.length === 0) return null;

    return (
        <Card style={{ marginBottom: '24px' }}>
            <h3 style={{ fontSize: '1.1rem', marginBottom: '16px' }}>Group Streaks</h3>
            <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(140px, 1fr))', gap: '12px' }}>
                {members.map(member => (
                    <div key={member.id} style={{
                        background: 'rgba(255,255,255,0.05)',
                        borderRadius: '12px',
                        padding: '12px',
                        display: 'flex',
                        flexDirection: 'column',
                        alignItems: 'center',
                        gap: '8px',
                        border: member.streak > 0 ? '1px solid rgba(255, 165, 0, 0.3)' : '1px solid transparent'
                    }}>
                        <div style={{ position: 'relative' }}>
                            <div style={{
                                width: '40px', height: '40px', borderRadius: '50%',
                                background: 'var(--glass-border)', color: 'var(--text-main)',
                                display: 'flex', alignItems: 'center', justifyContent: 'center',
                                fontSize: '1rem', fontWeight: 'bold',
                                overflow: 'hidden'
                            }}>
                                {member.avatar ? (
                                    <img src={member.avatar} alt={member.name} style={{ width: '100%', height: '100%', objectFit: 'cover' }} />
                                ) : (
                                    member.name[0].toUpperCase()
                                )}
                            </div>
                            {member.streak > 0 && (
                                <div style={{
                                    position: 'absolute',
                                    bottom: '-4px', right: '-4px',
                                    fontSize: '1.2rem',
                                    filter: 'drop-shadow(0 0 4px rgba(255,100,0,0.5))'
                                }}>
                                    🔥
                                </div>
                            )}
                        </div>

                        <div style={{ textAlign: 'center' }}>
                            <div style={{ fontSize: '0.9rem', fontWeight: '600' }}>{member.name}</div>
                            <div style={{ fontSize: '0.8rem', color: member.streak > 0 ? '#ffaa00' : 'var(--text-muted)' }}>
                                {member.streak} day{member.streak !== 1 ? 's' : ''}
                            </div>
                        </div>
                    </div>
                ))}
            </div>
        </Card>
    );
}
