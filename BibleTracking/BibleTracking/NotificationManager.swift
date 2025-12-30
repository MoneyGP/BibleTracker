import SwiftUI
import UserNotifications
import Supabase

@MainActor
class NotificationManager: ObservableObject {
    static let shared = NotificationManager()
    @Published var socialNotificationsEnabled = true
    
    private var realtimeChannel: RealtimeChannel?
    
    init() {
        // Request permissions on init or when enabled
        requestPermission()
    }
    
    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Notification permission error: \(error)")
            }
        }
    }
    
    func startListening() async {
        guard socialNotificationsEnabled else { return }
        
        let channel = supabase.channel("public:posts")
        
        let insertions = channel.postgresChange(
            AnyAction.self,
            schema: "public",
            table: "posts",
            filter: nil // Listen to all inserts
        )
        
        do {
            await channel.subscribe()
            self.realtimeChannel = channel
            
            // Handle Incoming Events
            for await event in insertions {
                switch event {
                case .insert(let record):
                    handleNewPost(record)
                default: break
                }
            }
        } catch {
            print("Realtime error: \(error)")
        }
    }
    
    func stopListening() async {
        if let channel = realtimeChannel {
            await supabase.removeChannel(channel)
        }
    }
    
    private func handleNewPost(_ record: AnyAction.Record) {
        // Parse record to check author
        // record is [String: AnyJSON]
        
        guard let myId = AuthManager.shared.session?.user.id else { return }
        
        // simple parsing
        if let userIdStr = record["user_id"]?.stringValue,
           let userId = UUID(uuidString: userIdStr),
           userId != myId {
            
            // It's someone else!
            showNotification(title: "New Reading Posted", body: "Someone just shared a new reading update!")
        }
    }
    
    func showNotification(title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil // Deliver immediately
        )
        
        UNUserNotificationCenter.current().add(request)
    }
}
