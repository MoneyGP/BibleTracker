
import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            FeedView()
                .tabItem {
                    Label("Feed", systemImage: "list.bullet")
                }
            
            StreaksView()
                .tabItem {
                    Label("Streaks", systemImage: "flame.fill")
                }
            
            Text("Upload (Coming Soon)")
                .tabItem {
                    Label("Post", systemImage: "plus.circle.fill")
                }
        }
    }
}
