
import Foundation

struct Profile: Codable, Identifiable {
    var id: UUID
    var username: String?
    var full_name: String?
    var avatar_url: String?
    var streak_count: Int? // Added for flame overlay
    
    enum CodingKeys: String, CodingKey {
        case id, username, full_name, avatar_url, streak_count
    }
}

struct Post: Codable, Identifiable {
    var id: UUID // API sends UUID string
    var user_id: UUID
    var caption: String? // Changed from 'content' to match DB
    var image_url: String?
    var reading_ref: String? // Added to match text column
    var created_at: Date
    var date: String? // YYYY-MM-DD
    var profiles: Profile? 
    var reactions: [String: Int]?
    // var likes: [Like]? // (Optional)
    
    enum CodingKeys: String, CodingKey {
        case id, user_id, caption, image_url, reading_ref, created_at, date, profiles, reactions
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(UUID.self, forKey: .id)
        user_id = try container.decode(UUID.self, forKey: .user_id)
        caption = try? container.decode(String.self, forKey: .caption)
        image_url = try? container.decode(String.self, forKey: .image_url)
        reading_ref = try? container.decode(String.self, forKey: .reading_ref)
        date = try? container.decode(String.self, forKey: .date)
        
        // Handle Date
        let dateString = try container.decode(String.self, forKey: .created_at)
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let d = formatter.date(from: dateString) {
            created_at = d
        } else {
            let fallback = ISO8601DateFormatter()
            created_at = fallback.date(from: dateString) ?? Date()
        }
        
        profiles = try? container.decode(Profile.self, forKey: .profiles)
        reactions = try? container.decode([String: Int].self, forKey: .reactions)
    }
}

struct Comment: Codable, Identifiable {
    var id: Int
    var post_id: UUID
    var user_id: UUID
    var content: String
    var created_at: Date
    var profiles: Profile? // Joined author info
}

struct Like: Codable, Identifiable {
    var id: UUID
    var user_id: UUID
    var post_id: UUID
}

// MARK: - Streak Logic
struct StreakLogic {
    static func calculate(dates: [String]) -> Int {
        let uniqueDates = Set(dates).sorted(by: >) // Descending
        
        guard !uniqueDates.isEmpty else { return 0 }
        
        let today = Date()
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)!
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let todayStr = formatter.string(from: today)
        let yesterdayStr = formatter.string(from: yesterday)
        
        // 1. Check valid start
        let lastPostDate = uniqueDates[0]
        if lastPostDate != todayStr && lastPostDate != yesterdayStr {
            return 0
        }
        
        // 2. Count consecutive
        var streak = 1
        var currentDate = formatter.date(from: lastPostDate)!
        
        for i in 1..<uniqueDates.count {
            let prevDateStr = uniqueDates[i]
            guard let prevDate = formatter.date(from: prevDateStr) else { continue }
            
            let expectedDate = Calendar.current.date(byAdding: .day, value: -1, to: currentDate)!
            let expectedStr = formatter.string(from: expectedDate)
            
            if prevDateStr == expectedStr {
                streak += 1
                currentDate = prevDate
            } else {
                break
            }
        }
        
        return streak
    }
}
