export const readingPlan = [
    { day: 362, date: '2025-12-28', reading: 'Revelation 1-5' },
    { day: 363, date: '2025-12-29', reading: 'Revelation 6-10' },
    { day: 364, date: '2025-12-30', reading: 'Revelation 11-14' },
    { day: 365, date: '2025-12-31', reading: 'Revelation 15-22' },
    { day: 1, date: '2026-01-01', reading: 'Genesis 1-3' },
    { day: 2, date: '2026-01-02', reading: 'Genesis 4-7' },
];

export const getTodaysReading = () => {
    const today = new Date().toISOString().split('T')[0];
    return readingPlan.find(p => p.date === today) || readingPlan[0];
};
