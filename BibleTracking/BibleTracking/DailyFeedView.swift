
import SwiftUI

struct DailyFeedView: View {
    @State private var selectedDate = Date()
    @State private var posts: [Post] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    // Calendar Logic
    @State private var weekOffset = 0
    let calendar = Calendar.current
    
    var currentWeekDays: [Date] {
        guard let startOfWeek = calendar.date(byAdding: .weekOfYear, value: weekOffset, to: Date()) else { return [] }
        // Find Sunday (or start of week)
        let sunday = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: startOfWeek))!
        return (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: sunday) }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    
                    // --- Calendar Strip ---
                    VStack(spacing: 12) {
                        // Month/Year Header
                        HStack {
                            Text(currentWeekDays.first?.formatted(.dateTime.month().year()) ?? "")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            Spacer()
                            HStack(spacing: 20) {
                                Button(action: { weekOffset -= 1 }) {
                                    Image(systemName: "chevron.left").foregroundColor(.white)
                                }
                                Button(action: { weekOffset = 0; selectedDate = Date() }) {
                                    Text("Today").font(.caption).fontWeight(.bold).foregroundColor(.white)
                                }
                                Button(action: { weekOffset += 1 }) {
                                    Image(systemName: "chevron.right").foregroundColor(.white)
                                }
                            }
                        }
                        .padding(.horizontal)
                        
                        // Days Row
                        HStack(spacing: 0) {
                            ForEach(currentWeekDays, id: \.self) { date in
                                let isSelected = calendar.isDate(date, inSameDayAs: selectedDate)
                                Button(action: {
                                    selectedDate = date
                                    Task { await fetchPosts() }
                                }) {
                                    VStack(spacing: 8) {
                                        Text(date.formatted(.dateTime.weekday(.abbreviated).locale(Locale(identifier: "en_US"))).uppercased())
                                            .font(.caption2)
                                            .fontWeight(.bold)
                                            .foregroundColor(isSelected ? .black : .gray)
                                        
                                        Text(date.formatted(.dateTime.day()))
                                            .font(.headline)
                                            .fontWeight(.bold)
                                            .foregroundColor(isSelected ? .black : .white)
                                        
                                        // Dot for "Has Reading" or "Has Posts"?
                                        Circle()
                                            .fill(isSelected ? Color.black : Color.clear)
                                            .frame(width: 4, height: 4)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(isSelected ? Color.white : Color.clear)
                                    .cornerRadius(12)
                                }
                            }
                        }
                        .padding(.horizontal, 8)
                    }
                    .padding(.bottom, 16)
                    .background(Color(red: 0.1, green: 0.1, blue: 0.12))
                    
                    // Today's Reading Card
                    let reading = ReadingPlan.getReading(for: selectedDate)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Reading for \(selectedDate.formatted(.dateTime.weekday().day().month()))")
                            .font(.title2)
                            .bold()
                            .foregroundColor(.white)
                        
                        HStack {
                            Image(systemName: "book.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.blue)
                            
                            VStack(alignment: .leading) {
                                Text(reading?.reading ?? "Rest Day / No Plan")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                Text("Tap to read passage")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(16)
                        .onTapGesture {
                            // Could open Bible text in future
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                    
                    // --- Feed Content ---
                    if isLoading {
                        Spacer()
                        ProgressView().tint(.white)
                        Spacer()
                    } else if posts.isEmpty {
                        Spacer()
                        VStack(spacing: 16) {
                            Image(systemName: "text.bubble")
                                .font(.system(size: 40))
                                .foregroundColor(.gray)
                            Text("No posts for this day")
                                .foregroundColor(.gray)
                            // Prompt to be the first logic here
                        }
                        Spacer()
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 24) {
                                ForEach(posts) { post in
                                    PostCardView(post: post)
                                }
                            }
                            .padding(.top, 16)
                            .padding(.bottom, 40)
                        }
                        .refreshable {
                            await fetchPosts()
                        }
                    }
                }
            }
            .navigationBarHidden(true)
        }
        .task {
            await fetchPosts()
        }
    }
    
    func fetchPosts() async {
        isLoading = true
        errorMessage = nil
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateString = formatter.string(from: selectedDate)
        
        do {
            // Filter by the 'date' column in database
            let fetchedPosts: [Post] = try await supabase
                .from("posts")
                .select("*, profiles(*)")
                .eq("date", value: dateString) // Exact match on day
                .order("created_at", ascending: false)
                .execute()
                .value
            
            self.posts = fetchedPosts
            self.isLoading = false
        } catch {
            print("Error fetching posts for \(dateString): \(error)")
            self.errorMessage = error.localizedDescription
            self.isLoading = false // Don't block UI on error, just show empty
        }
    }
}

// Extracted for cleaner file
struct PostCardView: View {
    let post: Post
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                if let avatar = post.profiles?.avatar_url, let url = URL(string: avatar) {
                    AsyncImage(url: url) { img in
                        img.resizable().scaledToFill()
                    } placeholder: {
                        Color.gray
                    }
                    .frame(width: 44, height: 44)
                    .clipShape(Circle())
                } else {
                    Circle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 44, height: 44)
                        .overlay(
                            Text(String(post.profiles?.username?.prefix(1) ?? "?"))
                                .font(.headline)
                                .foregroundColor(.white)
                        )
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(post.profiles?.username ?? "Unknown")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text(post.created_at.formatted(date: .omitted, time: .shortened))
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
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
                    if let image = phase.image {
                        image.resizable().scaledToFill().cornerRadius(12)
                    } else if phase.error != nil {
                        Color.red.opacity(0.2).frame(height: 200).cornerRadius(12)
                    } else {
                        Color.white.opacity(0.1).frame(height: 200).cornerRadius(12)
                    }
                }
            }
            
            // Reactions
            HStack(spacing: 20) {
                Button(action: {}) {
                    HStack(spacing: 6) {
                        Image(systemName: "heart")
                        Text("\(post.reactions?["❤️"] ?? 0)")
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
        }
        .padding()
        .background(Color(red: 0.1, green: 0.1, blue: 0.12)) // Card BG
        .cornerRadius(20)
        .padding(.horizontal)
    }
}
