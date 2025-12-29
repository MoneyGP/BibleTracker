export default function Card({ children, className = '', style = {} }) {
    return (
        <div
            className={`glass-panel ${className}`}
            style={{
                padding: '24px',
                borderRadius: 'var(--radius-md)',
                marginBottom: '20px',
                ...style
            }}
        >
            {children}
        </div>
    );
}
