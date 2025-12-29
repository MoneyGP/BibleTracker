import { useState, useEffect } from 'react';
import Link from 'next/link';
import Button from '@/components/Button';
import Layout from '@/components/Layout';
import { fullPlan } from '@/data/fullPlan';

export default function CalendarPage() {
    const [selectedMonth, setSelectedMonth] = useState(0); // Jan = 0
    const [todayStr, setTodayStr] = useState('');

    useEffect(() => {
        // Get local date string YYYY-MM-DD
        const now = new Date();
        const y = now.getFullYear();
        const m = String(now.getMonth() + 1).padStart(2, '0');
        const d = String(now.getDate()).padStart(2, '0');
        // eslint-disable-next-line react-hooks/set-state-in-effect
        setTodayStr(`${y}-${m}-${d}`);
    }, []);

    // Group plan by month (simple check of date string)
    const months = [
        'January', 'February', 'March', 'April', 'May', 'June',
        'July', 'August', 'September', 'October', 'November', 'December'
    ];

    const currentYear = 2026; // Matching generatePlan logic

    const daysInMonth = (month, year) => new Date(year, month + 1, 0).getDate();
    const getDayOfWeek = (month, year) => new Date(year, month, 1).getDay(); // 0 = Sun

    const renderCalendar = () => {
        const totalDays = daysInMonth(selectedMonth, currentYear);
        const startDay = getDayOfWeek(selectedMonth, currentYear);
        const days = [];

        // Empty cells for start padding
        for (let i = 0; i < startDay; i++) {
            days.push(<div key={`empty-${i}`} style={{ width: '100%', aspectRatio: '1' }}></div>);
        }

        // Actual days
        for (let d = 1; d <= totalDays; d++) {
            // Find plan for this day
            // Note: fullPlan.date is YYYY-MM-DD
            const dateStr = `${currentYear}-${String(selectedMonth + 1).padStart(2, '0')}-${String(d).padStart(2, '0')}`;
            const dayPlan = fullPlan.find(p => p.date === dateStr);

            const isPast = new Date(dateStr) < new Date(); // Mock check

            const dayContent = (
                <div
                    style={{
                        aspectRatio: '1',
                        background: isPast ? 'rgba(255, 255, 255, 0.05)' : 'transparent',
                        borderRadius: '8px',
                        display: 'flex',
                        flexDirection: 'column',
                        alignItems: 'center',
                        justifyContent: 'center',
                        fontSize: '0.9rem',
                        position: 'relative',
                        border: dateStr === todayStr ? '2px solid var(--primary)' : '1px solid transparent',
                        boxShadow: dateStr === todayStr ? '0 0 10px rgba(var(--primary-rgb), 0.3)' : 'none',
                        cursor: dayPlan ? 'pointer' : 'default',
                        width: '100%',
                        height: '100%'
                    }}
                >
                    <span style={{ fontWeight: 'bold' }}>{d}</span>
                    {dayPlan && (
                        <div style={{ width: '100%', display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center' }}>
                            {(() => {
                                const bookAbbreviations = {
                                    'Genesis': 'Gen', 'Exodus': 'Exo', 'Leviticus': 'Lev', 'Numbers': 'Num', 'Deuteronomy': 'Deu',
                                    'Joshua': 'Jos', 'Judges': 'Jdg', 'Ruth': 'Rut', '1 Samuel': '1Sa', '2 Samuel': '2Sa',
                                    '1 Kings': '1Ki', '2 Kings': '2Ki', '1 Chronicles': '1Ch', '2 Chronicles': '2Ch', 'Ezra': 'Ezr',
                                    'Nehemiah': 'Neh', 'Esther': 'Est', 'Job': 'Job', 'Psalms': 'Psa', 'Proverbs': 'Pro',
                                    'Ecclesiastes': 'Ecc', 'Song of Solomon': 'Son', 'Isaiah': 'Isa', 'Jeremiah': 'Jer',
                                    'Lamentations': 'Lam', 'Ezekiel': 'Eze', 'Daniel': 'Dan', 'Hosea': 'Hos', 'Joel': 'Joe',
                                    'Amos': 'Amo', 'Obadiah': 'Oba', 'Jonah': 'Jon', 'Micah': 'Mic', 'Nahum': 'Nah',
                                    'Habakkuk': 'Hab', 'Zephaniah': 'Zep', 'Haggai': 'Hag', 'Zechariah': 'Zec', 'Malachi': 'Mal',
                                    'Matthew': 'Mat', 'Mark': 'Mar', 'Luke': 'Luk', 'John': 'Joh', 'Acts': 'Act',
                                    'Romans': 'Rom', '1 Corinthians': '1Co', '2 Corinthians': '2Co', 'Galatians': 'Gal',
                                    'Ephesians': 'Eph', 'Philippians': 'Phi', 'Colossians': 'Col', '1 Thessalonians': '1Th',
                                    '2 Thessalonians': '2Th', '1 Timothy': '1Ti', '2 Timothy': '2Ti', 'Titus': 'Tit',
                                    'Philemon': 'Phm', 'Hebrews': 'Heb', 'James': 'Jam', '1 Peter': '1Pe', '2 Peter': '2Pe',
                                    '1 John': '1Jo', '2 John': '2Jo', '3 John': '3Jo', 'Jude': 'Jud', 'Revelation': 'Rev'
                                };

                                const getAbbr = (name) => bookAbbreviations[name] || name;

                                let line1, line2;

                                if (dayPlan.reading.includes(' - ')) {
                                    // Cross-book reading: "Nahum 3 - Habakkuk 2"
                                    const [part1, part2] = dayPlan.reading.split(' - ');

                                    // Parse Part 1: "Nahum 3"
                                    const p1Parts = part1.split(' ');
                                    const p1Ref = p1Parts.pop();
                                    const p1Book = getAbbr(p1Parts.join(' '));
                                    line1 = `${p1Book} ${p1Ref}`;

                                    // Parse Part 2: "Habakkuk 2"
                                    const p2Parts = part2.split(' ');
                                    const p2Ref = p2Parts.pop();
                                    const p2Book = getAbbr(p2Parts.join(' '));
                                    line2 = `${p2Book} ${p2Ref}`;
                                } else {
                                    // Standard reading: "Genesis 1-3"
                                    const parts = dayPlan.reading.split(' ');
                                    const ref = parts.pop(); // "1-3"
                                    const fullBook = parts.join(' '); // "Genesis"
                                    line1 = getAbbr(fullBook);
                                    line2 = ref; // Chapter range
                                }

                                return (
                                    <>
                                        <div style={{
                                            fontSize: '0.55rem',
                                            color: 'var(--text-muted)',
                                            whiteSpace: 'nowrap',
                                            overflow: 'hidden',
                                            maxWidth: '98%',
                                            lineHeight: '1.2'
                                        }}>
                                            {line1}
                                        </div>
                                        <div style={{
                                            fontSize: '0.55rem',
                                            fontWeight: '600',
                                            whiteSpace: 'nowrap',
                                            lineHeight: '1.2'
                                        }}>
                                            {line2}
                                        </div>
                                    </>
                                );
                            })()}
                        </div>
                    )}

                    {/* Status Dot (Mock) */}
                    {isPast && (
                        <div style={{
                            width: '4px', height: '4px', borderRadius: '50%',
                            background: 'var(--primary)', marginTop: '4px'
                        }} />
                    )}
                </div>
            );

            if (dayPlan) {
                days.push(
                    <Link key={d} href={`/upload?reading=${encodeURIComponent(dayPlan.reading)}`} style={{ display: 'block', width: '100%' }}>
                        {dayContent}
                    </Link>
                );
            } else {
                days.push(<div key={d} style={{ width: '100%' }}>{dayContent}</div>);
            }
        }


        // Fill remaining cells to reach 42 (6 rows x 7 cols)
        const totalSlots = 42;
        while (days.length < totalSlots) {
            days.push(<div key={`empty-end-${days.length}`} style={{ width: '100%', aspectRatio: '1' }}></div>);
        }

        return days;
    };

    return (
        <Layout title="Calendar">
            <div style={{ marginBottom: '20px' }}>
                <Link href="/" passHref legacyBehavior>
                    <Button variant="ghost">← Back to Dashboard</Button>
                </Link>
            </div>
            <h1 className="text-gradient" style={{ fontSize: '1.8rem', marginBottom: '24px' }}>Reading Calendar</h1>

            <div style={{ display: 'flex', flexWrap: 'wrap', gap: '8px', justifyContent: 'center', marginBottom: '24px' }}>
                {months.map((m, i) => (
                    <button
                        key={m}
                        onClick={() => setSelectedMonth(i)}
                        style={{
                            padding: '8px 16px',
                            borderRadius: '20px',
                            background: selectedMonth === i ? 'var(--primary)' : 'var(--glass-bg)',
                            color: selectedMonth === i ? 'var(--bg-color)' : 'var(--text-main)',
                            fontSize: '0.9rem',
                            whiteSpace: 'nowrap'
                        }}
                    >
                        {m}
                    </button>
                ))}
            </div>

            <div style={{
                display: 'grid',
                gridTemplateColumns: 'repeat(7, minmax(0, 1fr))',
                gridTemplateRows: 'repeat(6, minmax(0, 1fr))', // Force 6 rows, strictly valid
                gap: '8px',
                marginBottom: '40px',
                padding: '16px',
                background: 'var(--glass-bg)',
                borderRadius: 'var(--radius-md)',
                maxWidth: '600px',
                margin: '0 auto 40px auto',
                aspectRatio: '7 / 6' // Maintain overall aspect ratio approx
            }}>
                {['S', 'M', 'T', 'W', 'T', 'F', 'S'].map(d => (
                    <div key={d} style={{ textAlign: 'center', fontSize: '0.8rem', color: 'var(--text-muted)', paddingBottom: '8px' }}>{d}</div>
                ))}
                {renderCalendar()}
            </div>

        </Layout>
    );
}
