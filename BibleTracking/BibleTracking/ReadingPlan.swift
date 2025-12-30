
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
    static let fullPlan: [DailyReading] = [
        DailyReading(day: 362, date: "2025-12-28", reading: "Revelation 1-5"),
        DailyReading(day: 363, date: "2025-12-29", reading: "Revelation 6-10"),
        DailyReading(day: 364, date: "2025-12-30", reading: "Revelation 11-14"),
        DailyReading(day: 365, date: "2025-12-31", reading: "Revelation 15-22"),
        DailyReading(day: 1, date: "2026-01-01", reading: "Genesis 1-3"),
        DailyReading(day: 2, date: "2026-01-02", reading: "Genesis 4-7"),
        // In a real app, this list would be populated with the full JSON data.
        // For the demo, I'll generate a programmatic placeholder plan if needed, 
        // but for now I will rely on this snippet effectively. 
        // Ideally we'd load this from a JSON file in the bundle.
    ]
    
    static func getTodaysReading() -> DailyReading? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let todayStr = formatter.string(from: Date())
        
        return fullPlan.first { $0.date == todayStr } ?? fullPlan.first
    }
}
