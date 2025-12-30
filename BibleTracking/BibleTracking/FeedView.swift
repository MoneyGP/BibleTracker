
import SwiftUI

struct FeedView: View {
    @State private var posts: [Post] = []
    @State private var isLoading = true
    @State private var errorMessage: String? = nil
    
    // Web App Colors (Approximate)
    let cardBackground = Color(red: 0.1, green: 0.1, blue: 0.12)
    let appBackground = Color.black
    
    var body: some View {
        NavigationView {
            ZStack {
                appBackground.ignoresSafeArea()
                
                if isLoading {
                    ProgressView()
                        .tint(.white)
                } else if let error = errorMessage {
                    // Error State (Keep existing)
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.orange)
                        Text(error).foregroundColor(.gray).padding()
                        Button("Retry") {
                            isLoading = true
                            errorMessage = nil
                            Task { await fetchFeed() }
                        }
                    }
                } else {
                    // Success State - Full Width ScrollView
                    ScrollView {
                        LazyVStack(spacing: 24) {
                            ForEach(posts) { post in
                                VStack(alignment: .leading, spacing: 16) {
                                    // Header
                                    HStack {
                                        Circle()
                                            .fill(LinearGradient(colors: [.gray.opacity(0.3), .gray.opacity(0.1)], startPoint: .topLeading, endPoint: .bottomTrailing))
                                            .frame(width: 44, height: 44)
                                            .overlay(
                                                Text(String(post.profiles?.username?.prefix(1) ?? "?"))
                                                    .font(.system(size: 18, weight: .bold))
                                                    .foregroundColor(.white)
                                            )
                                        
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(post.profiles?.username ?? "Unknown")
                                                .font(.headline)
                                                .foregroundColor(.white)
                                            
                                            Text(post.created_at.formatted(date: .abbreviated, time: .shortened))
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                        }
                                        
                                        Spacer()
                                        
                                        // Menu/Options could go here
                                    }
                                    
                                    // Content
                                    if let content = post.content, !content.isEmpty {
                                        Text(content)
                                            .font(.body)
                                            .foregroundColor(Color(white: 0.9))
                                            .lineSpacing(4)
                                    }
                                    
                                    // Image
                                    if let imageUrl = post.image_url {
                                        AsyncImage(url: URL(string: imageUrl)) { phase in
                                            switch phase {
                                            case .empty:
                                                Rectangle()
                                                    .fill(Color.white.opacity(0.05))
                                                    .frame(height: 300)
                                                    .cornerRadius(12)
                                            case .success(let image):
                                                image
                                                    .resizable()
                                                    .scaledToFill()
                                                    .frame(maxHeight: 400) // Taller checks
                                                    .clipped()
                                                    .cornerRadius(12)
                                            case .failure:
                                                EmptyView()
                                            @unknown default:
                                                EmptyView()
                                            }
                                        }
                                    }
                                    
                                    // Action Bar (Like/Comment placeholders)
                                    HStack(spacing: 20) {
                                        Button(action: {}) {
                                            HStack(spacing: 6) {
                                                Image(systemName: "heart")
                                                Text("Like")
                                            }
                                        }
                                        
                                        Button(action: {}) {
                                            HStack(spacing: 6) {
                                                Image(systemName: "bubble.right")
                                                Text("Comment")
                                            }
                                        }
                                        
                                        Spacer()
                                    }
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                    .padding(.top, 8)
                                }
                                .padding(20)
                                .background(cardBackground)
                                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                                .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 5)
                                .padding(.horizontal, 16) // Side margins
                            }
                        }
                        .padding(.top, 16)
                        .padding(.bottom, 100) // Space for TabBar
                    }
                    .refreshable {
                        await fetchFeed()
                    }
                }
            }
            .navigationTitle("Feed")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(appBackground, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
        .task {
            await fetchFeed()
        }
    }
    
    func fetchFeed() async {
        do {
            let posts: [Post] = try await supabase
                .from("posts")
                .select("*, profiles(*)")
                .order("created_at", ascending: false)
                .limit(50)
                .execute()
                .value
            
            withAnimation {
                self.posts = posts
                self.isLoading = false
            }
        } catch {
            print("Error fetching feed: \(error)")
            // Force onto main thread just in case, though SwiftUI usually handles it
            DispatchQueue.main.async {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }
}
