// Simplified Bible structure for demo purposes
const bibleBooks = [
    { name: 'Genesis', chapters: 50 },
    { name: 'Exodus', chapters: 40 },
    { name: 'Leviticus', chapters: 27 },
    { name: 'Numbers', chapters: 36 },
    { name: 'Deuteronomy', chapters: 34 },
    { name: 'Joshua', chapters: 24 },
    { name: 'Judges', chapters: 21 },
    { name: 'Ruth', chapters: 4 },
    { name: '1 Samuel', chapters: 31 },
    { name: '2 Samuel', chapters: 24 },
    { name: '1 Kings', chapters: 22 },
    { name: '2 Kings', chapters: 25 },
    { name: '1 Chronicles', chapters: 29 },
    { name: '2 Chronicles', chapters: 36 },
    { name: 'Ezra', chapters: 10 },
    { name: 'Nehemiah', chapters: 13 },
    { name: 'Esther', chapters: 10 },
    { name: 'Job', chapters: 42 },
    { name: 'Psalms', chapters: 150 },
    { name: 'Proverbs', chapters: 31 },
    { name: 'Ecclesiastes', chapters: 12 },
    { name: 'Song of Solomon', chapters: 8 },
    { name: 'Isaiah', chapters: 66 },
    { name: 'Jeremiah', chapters: 52 },
    { name: 'Lamentations', chapters: 5 },
    { name: 'Ezekiel', chapters: 48 },
    { name: 'Daniel', chapters: 12 },
    { name: 'Hosea', chapters: 14 },
    { name: 'Joel', chapters: 3 },
    { name: 'Amos', chapters: 9 },
    { name: 'Obadiah', chapters: 1 },
    { name: 'Jonah', chapters: 4 },
    { name: 'Micah', chapters: 7 },
    { name: 'Nahum', chapters: 3 },
    { name: 'Habakkuk', chapters: 3 },
    { name: 'Zephaniah', chapters: 3 },
    { name: 'Haggai', chapters: 2 },
    { name: 'Zechariah', chapters: 14 },
    { name: 'Malachi', chapters: 4 },
    { name: 'Matthew', chapters: 28 },
    { name: 'Mark', chapters: 16 },
    { name: 'Luke', chapters: 24 },
    { name: 'John', chapters: 21 },
    { name: 'Acts', chapters: 28 },
    { name: 'Romans', chapters: 16 },
    { name: '1 Corinthians', chapters: 16 },
    { name: '2 Corinthians', chapters: 13 },
    { name: 'Galatians', chapters: 6 },
    { name: 'Ephesians', chapters: 6 },
    { name: 'Philippians', chapters: 4 },
    { name: 'Colossians', chapters: 4 },
    { name: '1 Thessalonians', chapters: 5 },
    { name: '2 Thessalonians', chapters: 3 },
    { name: '1 Timothy', chapters: 6 },
    { name: '2 Timothy', chapters: 4 },
    { name: 'Titus', chapters: 3 },
    { name: 'Philemon', chapters: 1 },
    { name: 'Hebrews', chapters: 13 },
    { name: 'James', chapters: 5 },
    { name: '1 Peter', chapters: 5 },
    { name: '2 Peter', chapters: 3 },
    { name: '1 John', chapters: 5 },
    { name: '2 John', chapters: 1 },
    { name: '3 John', chapters: 1 },
    { name: 'Jude', chapters: 1 },
    { name: 'Revelation', chapters: 22 }
];

export const generatePlan = () => {
    const plan = [];
    let dayCounter = 1;
    const year = 2026;

    // Flatten all chapters
    let allChapters = [];
    bibleBooks.forEach(book => {
        for (let c = 1; c <= book.chapters; c++) {
            allChapters.push(`${book.name} ${c}`);
        }
    });

    const totalChapters = allChapters.length;
    // Use floating point ratio to distribute evenly across 365 days
    const ratio = totalChapters / 365;

    // Deterministic date generation
    let currentMonth = 0; // Jan
    let currentDay = 1;
    const daysInMonth = (m) => new Date(year, m + 1, 0).getDate();

    for (let i = 0; i < 365; i++) {
        // Calculate start and end indices based on even distribution
        const startIdx = Math.floor(i * ratio);
        const endIdx = Math.floor((i + 1) * ratio);

        // Slice chapters
        // Ensure we don't miss the last chapter due to rounding by clamping endIdx on last day
        const effectiveEndIdx = (i === 364) ? totalChapters : endIdx;

        // Sometimes startIdx == endIdx if ratio < 1 (not the case here, but good safety)
        // Actually if ratio ~3.2, start=0, end=3 (indices 0,1,2). Next i=1, start=3, end=6.

        let chapters = allChapters.slice(startIdx, effectiveEndIdx);

        // If for some reason empty (rare cases in math), borrow/adjust? 
        // With ratio > 1 (~3.26), every day should have at least 3 chapters.

        let readingDisplay = "Rest / Reflection";
        if (chapters.length > 0) {
            const first = chapters[0];
            const last = chapters[chapters.length - 1];
            const firstBook = first.split(' ').slice(0, -1).join(' ');
            const lastBook = last.split(' ').slice(0, -1).join(' ');
            const firstChap = first.split(' ').pop();
            const lastChap = last.split(' ').pop();

            if (firstBook === lastBook) {
                if (firstChap === lastChap) {
                    readingDisplay = `${firstBook} ${firstChap}`;
                } else {
                    readingDisplay = `${firstBook} ${firstChap}-${lastChap}`;
                }
            } else {
                readingDisplay = `${first} - ${last}`;
            }
        }

        // Format YYYY-MM-DD
        const dateStr = `${year}-${String(currentMonth + 1).padStart(2, '0')}-${String(currentDay).padStart(2, '0')}`;

        plan.push({
            day: dayCounter++,
            date: dateStr,
            reading: readingDisplay,
            chapters: chapters
        });

        // Advance date
        currentDay++;
        if (currentDay > daysInMonth(currentMonth)) {
            currentDay = 1;
            currentMonth++;
        }
    }
    return plan;
};

export const fullPlan = generatePlan();
