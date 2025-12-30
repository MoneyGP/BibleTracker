
import Foundation

struct Profile: Codable, Identifiable {
    var id: UUID
    var username: String?
    var full_name: String?
    var avatar_url: String?
}

struct Post: Codable, Identifiable {
    var id: UUID // API sends UUID string
    var user_id: UUID
    var content: String?
    var image_url: String?
    var created_at: Date
    var date: String? // YYYY-MM-DD
    var profiles: Profile? 
    var reactions: [String: Int]?
    
    enum CodingKeys: String, CodingKey {
        case id, user_id, content, image_url, created_at, date, profiles, reactions
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Correctly decode UUID directly
        id = try container.decode(UUID.self, forKey: .id)
        user_id = try container.decode(UUID.self, forKey: .user_id)
        content = try? container.decode(String.self, forKey: .content)
        image_url = try? container.decode(String.self, forKey: .image_url)
        date = try? container.decode(String.self, forKey: .date)
        
        // Handle Date (Supabase sends ISO string)
        let dateString = try container.decode(String.self, forKey: .created_at)
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = formatter.date(from: dateString) {
            created_at = date
        } else {
            // Fallback for no fractional seconds
            let fallback = ISO8601DateFormatter()
            created_at = fallback.date(from: dateString) ?? Date()
        }
        
        profiles = try? container.decode(Profile.self, forKey: .profiles)
        reactions = try? container.decode([String: Int].self, forKey: .reactions)
    }
}

struct Comment: Codable, Identifiable {
    var id: Int // Comments ID is likely BigInt (Int in Swift) or UUID? The SQL says generated identity (Int)
    var post_id: UUID // Changed to UUID
    var user_id: UUID
    var content: String
    var created_at: Date
    // var profiles: Profile? (if fetching with join)
}
