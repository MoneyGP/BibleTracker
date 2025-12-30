
import Foundation

struct Profile: Codable, Identifiable {
    var id: UUID
    var username: String?
    var full_name: String?
    var avatar_url: String?
}

struct Post: Codable, Identifiable {
    var id: Int
    var user_id: UUID
    var content: String?
    var image_url: String?
    var created_at: Date
    var profiles: Profile? 
    
    enum CodingKeys: String, CodingKey {
        case id, user_id, content, image_url, created_at, profiles
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // DEBUG: Check what keys we actually have
        // print("Keys present: \(container.allKeys.map { $0.stringValue })")
        
        // Handle ID: Try all reasonable types
        if let intId = try? container.decode(Int.self, forKey: .id) {
            id = intId
        } else if let stringId = try? container.decode(String.self, forKey: .id), let intId = Int(stringId) {
            id = intId
        } else if let doubleId = try? container.decode(Double.self, forKey: .id) {
            id = Int(doubleId) // Supabase sometimes sends big numbers as float-likes
        } else {
             // If completely missing, debug why
             print("❌ FAILED to decode ID. Keys: \(container.allKeys)")
             // Fallback to -1 or throw with better info
             if container.contains(.id) {
                 throw DecodingError.typeMismatch(Int.self, DecodingError.Context(codingPath: container.codingPath, debugDescription: "ID Present but not Int/String/Double"))
             } else {
                 throw DecodingError.keyNotFound(CodingKeys.id, DecodingError.Context(codingPath: container.codingPath, debugDescription: "Key 'id' missing"))
             }
        }
        
        user_id = try container.decode(UUID.self, forKey: .user_id)
        content = try? container.decode(String.self, forKey: .content)
        image_url = try? container.decode(String.self, forKey: .image_url)
        
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
    }
}
