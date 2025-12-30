
import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authManager: AuthManager
    
    var body: some View {
        Group {
            if authManager.isLoading {
                ZStack {
                    Color.black.ignoresSafeArea()
                    ProgressView().tint(.white)
                }
            } else if authManager.isAuthenticated {
                TabView {
                    DailyFeedView()
                        .tabItem {
                            Label("Today", systemImage: "book.fill")
                        }
                    
                    // Profile/Logout Tab
                    Button("Sign Out") {
                        Task { await authManager.signOut() }
                    }
                    .tabItem {
                        Label("Profile", systemImage: "person.circle")
                    }
                }
                .accentColor(.white)
                .preferredColorScheme(.dark)
            } else {
                LoginView()
            }
        }
    }
}
