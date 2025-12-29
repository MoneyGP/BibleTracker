/* eslint-disable @next/next/no-img-element */
import Card from './Card';
import ReactionBar from './ReactionBar';

export default function FeedItem({ item }) {
    return (
        <Card className="feed-item" style={{ padding: '0', overflow: 'hidden' }}>
            <div style={{ padding: '16px', display: 'flex', alignItems: 'center', gap: '12px' }}>
                <div style={{
                    width: '32px', height: '32px', borderRadius: '50%',
                    background: 'var(--primary)', color: 'var(--bg-color)',
                    display: 'flex', alignItems: 'center', justifyContent: 'center',
                    fontWeight: 'bold', fontSize: '14px',
                    overflow: 'hidden'
                }}>
                    {(() => {
                        const profile = Array.isArray(item.profiles) ? item.profiles[0] : item.profiles;
                        return profile?.avatar_url ? (
                            <img src={profile.avatar_url} alt="User" style={{ width: '100%', height: '100%', objectFit: 'cover' }} />
                        ) : (
                            (profile?.username?.[0] || 'U').toUpperCase()
                        );
                    })()}
                </div>
                <div>
                    <div style={{ fontWeight: '600', fontSize: '14px' }}>
                        {(() => {
                            const profile = Array.isArray(item.profiles) ? item.profiles[0] : item.profiles;
                            return profile?.username || 'Unknown User';
                        })()}
                    </div>
                    <div style={{ fontSize: '12px', color: 'var(--text-muted)' }}>
                        {new Date(item.created_at).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}
                    </div>
                </div>
            </div>

            {item.image_url && (
                <div style={{ width: '100%', height: '300px', background: '#000', position: 'relative' }}>
                    <img
                        src={item.image_url}
                        alt="Reading proof"
                        style={{ width: '100%', height: '100%', objectFit: 'cover' }}
                    />
                </div>
            )}

            <div style={{ padding: '16px' }}>
                <p style={{ fontSize: '14px', lineHeight: '1.5' }}>{item.caption}</p>
                <ReactionBar
                    itemId={item.id}
                    initialReactions={item.reactions}
                    onReact={(id, reacts) => {
                        console.log(`Reacted to ${id}`, reacts);
                        // In real app, sync to backend
                    }}
                />
            </div>
        </Card>
    );
}
