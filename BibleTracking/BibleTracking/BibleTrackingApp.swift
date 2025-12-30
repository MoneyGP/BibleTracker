
import SwiftUI

@main
struct BibleTrackingApp: App {
    @StateObject private var authManager = AuthManager.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(AuthManager.shared)
                .task {
                    await NotificationManager.shared.startListening()
                }
        }
    }
}
