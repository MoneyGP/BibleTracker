import { useState, useEffect } from 'react';
import { supabase } from '@/lib/supabaseClient';
import Card from './Card';

export default function GroupProgress() {
    const [members, setMembers] = useState([]);
    const [loading, setLoading] = useState(true);

    useEffect(() => {
        fetchGroupData();
    }, []);

    const fetchGroupData = async () => {
        try {
            // 1. Fetch all profiles (users)
            const { data: profiles, error: profileError } = await supabase
                .from('profiles')
                .select('id, username, avatar_url');

            if (profileError) throw profileError;
            if (!profiles) return;

            // 2. Fetch all posts to calculate progress
            const { data: posts, error: postError } = await supabase
                .from('posts')
                .select('user_id, date, created_at');

            if (postError) throw postError;

            // 3. Process Data
            const todayStr = new Date().toISOString().split('T')[0];

            const memberStats = profiles.map(user => {
                const userPosts = posts.filter(p => p.user_id === user.id);

                // Check if they posted today
                // Note: p.date is YYYY-MM-DD from DB default
                // We'll check both date field and created_at just in case
                const completedToday = userPosts.some(p => {
                    const postDate = p.date || p.created_at.split('T')[0];
                    return postDate === todayStr;
                });

                // Calculate progress (unique days)
                const uniqueDays = new Set(userPosts.map(p => p.date || p.created_at.split('T')[0])).size;
                const progressPercent = Math.min(100, Math.round((uniqueDays / 365) * 100));

                return {
                    id: user.id,
                    name: user.username || 'User',
                    avatar: user.avatar_url,
                    completedToday,
                    progressPercent
                };
            });

            setMembers(memberStats);
        } catch (error) {
            console.error('Error fetching group progress:', error);
        } finally {
            setLoading(false);
        }
    };

    if (loading) return null; // Or a loading skeleton
    if (members.length === 0) return null; // Hide if no users

    return (
        <Card style={{ marginBottom: '24px' }}>
            <h3 style={{ fontSize: '1.1rem', marginBottom: '16px' }}>Group Progress</h3>
            <div style={{ display: 'flex', flexDirection: 'column', gap: '12px' }}>
                {members.map(member => (
                    <div key={member.id} style={{ display: 'flex', flexDirection: 'column', gap: '8px', padding: '8px 0', borderBottom: '1px solid var(--glass-border)' }}>
                        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
                            <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
                                <div style={{
                                    width: '32px', height: '32px', borderRadius: '50%',
                                    background: 'var(--glass-border)', color: 'var(--text-main)',
                                    display: 'flex', alignItems: 'center', justifyContent: 'center',
                                    fontSize: '0.8rem', fontWeight: 'bold',
                                    overflow: 'hidden'
                                }}>
                                    {member.avatar ? (
                                        <img src={member.avatar} alt={member.name} style={{ width: '100%', height: '100%', objectFit: 'cover' }} />
                                    ) : (
                                        member.name[0].toUpperCase()
                                    )}
                                </div>
                                <span>{member.name}</span>
                            </div>

                            <div style={{
                                width: '24px', height: '24px',
                                borderRadius: '50%',
                                border: member.completedToday ? 'none' : '2px solid var(--text-muted)',
                                background: member.completedToday ? 'var(--primary)' : 'transparent',
                                display: 'flex', alignItems: 'center', justifyContent: 'center',
                                color: 'var(--bg-color)',
                                fontSize: '0.8rem'
                            }}>
                                {member.completedToday && '✓'}
                            </div>
                        </div>

                        {/* Progress Bar */}
                        <div style={{ display: 'flex', alignItems: 'center', gap: '8px', paddingLeft: '44px' }}>
                            <div style={{ flex: 1, height: '6px', background: 'rgba(255,255,255,0.1)', borderRadius: '3px', overflow: 'hidden' }}>
                                <div style={{
                                    width: `${member.progressPercent}%`,
                                    height: '100%',
                                    background: 'linear-gradient(90deg, var(--primary), #ffd700)',
                                    borderRadius: '3px',
                                    transition: 'width 0.5s ease-out'
                                }} />
                            </div>
                            <div style={{ fontSize: '0.7rem', color: 'var(--text-muted)', width: '30px', textAlign: 'right' }}>
                                {member.progressPercent}%
                            </div>
                        </div>
                    </div>
                ))}
            </div>
        </Card>
    );
}
