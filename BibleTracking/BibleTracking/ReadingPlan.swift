
import Foundation

struct DailyReading: Identifiable {
    let id = UUID()
    let day: Int
    let date: String
    let reading: String
    
    // Helper to get formatted date
    var dateObject: Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: date)
    }
}

struct ReadingPlan {
    static let fullPlan: [DailyReading] = generatePlan()
    
    static func getTodaysReading() -> DailyReading? {
        return getReading(for: Date())
    }
    
    static func getReading(for date: Date) -> DailyReading? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateStr = formatter.string(from: date)
        
        return fullPlan.first { $0.date == dateStr }
    }
    
    // Logic ported from data/fullPlan.js
    private static func generatePlan() -> [DailyReading] {
        struct Book { let name: String; let chapters: Int }
        let bibleBooks: [Book] = [
            Book(name: "Genesis", chapters: 50), Book(name: "Exodus", chapters: 40),
            Book(name: "Leviticus", chapters: 27), Book(name: "Numbers", chapters: 36),
            Book(name: "Deuteronomy", chapters: 34), Book(name: "Joshua", chapters: 24),
            Book(name: "Judges", chapters: 21), Book(name: "Ruth", chapters: 4),
            Book(name: "1 Samuel", chapters: 31), Book(name: "2 Samuel", chapters: 24),
            Book(name: "1 Kings", chapters: 22), Book(name: "2 Kings", chapters: 25),
            Book(name: "1 Chronicles", chapters: 29), Book(name: "2 Chronicles", chapters: 36),
            Book(name: "Ezra", chapters: 10), Book(name: "Nehemiah", chapters: 13),
            Book(name: "Esther", chapters: 10), Book(name: "Job", chapters: 42),
            Book(name: "Psalms", chapters: 150), Book(name: "Proverbs", chapters: 31),
            Book(name: "Ecclesiastes", chapters: 12), Book(name: "Song of Solomon", chapters: 8),
            Book(name: "Isaiah", chapters: 66), Book(name: "Jeremiah", chapters: 52),
            Book(name: "Lamentations", chapters: 5), Book(name: "Ezekiel", chapters: 48),
            Book(name: "Daniel", chapters: 12), Book(name: "Hosea", chapters: 14),
            Book(name: "Joel", chapters: 3), Book(name: "Amos", chapters: 9),
            Book(name: "Obadiah", chapters: 1), Book(name: "Jonah", chapters: 4),
            Book(name: "Micah", chapters: 7), Book(name: "Nahum", chapters: 3),
            Book(name: "Habakkuk", chapters: 3), Book(name: "Zephaniah", chapters: 3),
            Book(name: "Haggai", chapters: 2), Book(name: "Zechariah", chapters: 14),
            Book(name: "Malachi", chapters: 4), Book(name: "Matthew", chapters: 28),
            Book(name: "Mark", chapters: 16), Book(name: "Luke", chapters: 24),
            Book(name: "John", chapters: 21), Book(name: "Acts", chapters: 28),
            Book(name: "Romans", chapters: 16), Book(name: "1 Corinthians", chapters: 16),
            Book(name: "2 Corinthians", chapters: 13), Book(name: "Galatians", chapters: 6),
            Book(name: "Ephesians", chapters: 6), Book(name: "Philippians", chapters: 4),
            Book(name: "Colossians", chapters: 4), Book(name: "1 Thessalonians", chapters: 5),
            Book(name: "2 Thessalonians", chapters: 3), Book(name: "1 Timothy", chapters: 6),
            Book(name: "2 Timothy", chapters: 4), Book(name: "Titus", chapters: 3),
            Book(name: "Philemon", chapters: 1), Book(name: "Hebrews", chapters: 13),
            Book(name: "James", chapters: 5), Book(name: "1 Peter", chapters: 5),
            Book(name: "2 Peter", chapters: 3), Book(name: "1 John", chapters: 5),
            Book(name: "2 John", chapters: 1), Book(name: "3 John", chapters: 1),
            Book(name: "Jude", chapters: 1), Book(name: "Revelation", chapters: 22)
        ]

        var allChapters: [String] = []
        for book in bibleBooks {
            for c in 1...book.chapters {
                allChapters.append("\(book.name) \(c)")
            }
        }
        
        var plan: [DailyReading] = []
        let totalChapters = Double(allChapters.count)
        let ratio = totalChapters / 365.0
        let year = 2026
        
        let calendar = Calendar.current
        var dateComponents = DateComponents(year: year, month: 1, day: 1)
        var currentDate = calendar.date(from: dateComponents)!
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        for i in 0..<365 {
            let startIdx = Int(floor(Double(i) * ratio))
            let endIdx = Int(floor(Double(i + 1) * ratio))
            
            // Slice chapters
            let effectiveEndIdx = (i == 364) ? Int(totalChapters) : endIdx
            let dayChapters = Array(allChapters[startIdx..<effectiveEndIdx])
            
            var readingDisplay = "Rest / Reflection"
            if let first = dayChapters.first, let last = dayChapters.last {
                // Parse logic (simplified)
                if dayChapters.count == 1 {
                    readingDisplay = first
                } else {
                    readingDisplay = "\(first) - \(last)"
                }
            }
            
            plan.append(DailyReading(
                day: i + 1,
                date: formatter.string(from: currentDate),
                reading: readingDisplay
            ))
            
            // Advance Day
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }
        
        // Prefix with some 2025 dates for demo/testing since we are in Dec 2025
        plan.append(contentsOf: [
            DailyReading(day: 362, date: "2025-12-28", reading: "Revelation 1-5"),
            DailyReading(day: 363, date: "2025-12-29", reading: "Revelation 6-10"),
            DailyReading(day: 364, date: "2025-12-30", reading: "Revelation 11-14"),
            DailyReading(day: 365, date: "2025-12-31", reading: "Revelation 15-22")
        ])
        
        return plan
    }
}
