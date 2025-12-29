import { useState } from 'react';
import Button from './Button';

export default function ReactionBar({ itemId, initialReactions = {}, onReact }) {
    // initialReactions: { '❤️': 2, '🙏': 5 }
    const [reactions, setReactions] = useState(initialReactions);
    const [userReaction, setUserReaction] = useState(null);

    const handleReact = (emoji) => {
        const newReactions = { ...reactions };

        if (userReaction === emoji) {
            // Toggle off
            newReactions[emoji] = Math.max(0, (newReactions[emoji] || 0) - 1);
            setUserReaction(null);
        } else {
            // Toggle on (and potentially switch)
            if (userReaction) {
                newReactions[userReaction] = Math.max(0, (newReactions[userReaction] || 0) - 1);
            }
            newReactions[emoji] = (newReactions[emoji] || 0) + 1;
            setUserReaction(emoji);
        }

        setReactions(newReactions);
        if (onReact) onReact(itemId, newReactions);
    };

    const emojis = ['❤️', '🙏', '🔥', '📖'];

    return (
        <div style={{ display: 'flex', gap: '8px', marginTop: '12px' }}>
            {emojis.map(emoji => (
                <button
                    key={emoji}
                    onClick={() => handleReact(emoji)}
                    style={{
                        background: userReaction === emoji ? 'hsla(var(--hue-primary), var(--sat-primary), var(--lum-primary), 0.2)' : 'transparent',
                        border: userReaction === emoji ? '1px solid var(--primary)' : '1px solid transparent',
                        borderRadius: '16px',
                        padding: '4px 8px',
                        fontSize: '0.9rem',
                        color: userReaction === emoji ? 'var(--primary)' : 'var(--text-muted)',
                        display: 'flex',
                        alignItems: 'center',
                        gap: '4px',
                        transition: 'all 0.2s ease',
                        cursor: 'pointer'
                    }}
                >
                    <span>{emoji}</span>
                    <span style={{ fontSize: '0.8rem' }}>{reactions[emoji] || 0}</span>
                </button>
            ))}
        </div>
    );
}
