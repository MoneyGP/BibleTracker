export default function Button({ children, onClick, variant = 'primary', style = {} }) {
    const baseStyle = {
        padding: '12px 24px',
        borderRadius: 'var(--radius-full)',
        fontWeight: '600',
        fontSize: '1rem',
        transition: 'transform 0.1s ease, box-shadow 0.2s ease',
        display: 'inline-flex',
        alignItems: 'center',
        justifyContent: 'center',
        gap: '8px',
    };

    const variants = {
        primary: {
            background: 'var(--primary)',
            color: 'var(--bg-color)',
            boxShadow: '0 4px 12px var(--primary-glow)',
        },
        glass: {
            background: 'var(--glass-bg)',
            color: 'var(--text-main)',
            border: '1px solid var(--glass-border)',
            backdropFilter: 'blur(4px)',
        },
        ghost: {
            background: 'transparent',
            color: 'var(--text-muted)',
        }
    };

    return (
        <button
            onClick={onClick}
            style={{ ...baseStyle, ...variants[variant], ...style }}
            onMouseDown={(e) => e.currentTarget.style.transform = 'scale(0.96)'}
            onMouseUp={(e) => e.currentTarget.style.transform = 'scale(1)'}
            onMouseLeave={(e) => e.currentTarget.style.transform = 'scale(1)'}
        >
            {children}
        </button>
    );
}
