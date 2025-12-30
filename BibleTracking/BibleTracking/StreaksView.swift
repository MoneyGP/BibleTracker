
import SwiftUI

struct MemberStats: Identifiable {
    let id: UUID
    let name: String
    let avatar: String?
    let streak: Int
}

struct StreaksView: View {
    @State private var members: [MemberStats] = []
    @State private var isLoading = true
    
    // Web App Colors
    let cardBackground = Color(red: 0.1, green: 0.1, blue: 0.12)
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                if isLoading {
                    ProgressView().tint(.white)
                } else if members.isEmpty {
                    VStack {
                        Image(systemName: "flame.slash")
                            .font(.largeTitle)
                            .foregroundColor(.gray)
                        Text("No streaks yet")
                            .foregroundColor(.gray)
                    }
                } else {
                    ScrollView {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 140))], spacing: 16) {
                            ForEach(members) { member in
                                VStack(spacing: 8) {
                                    // Avatar + Flame
                                    ZStack(alignment: .bottomTrailing) {
                                        Circle()
                                            .fill(Color.gray.opacity(0.2))
                                            .frame(width: 56, height: 56)
                                            .overlay(
                                                Group {
                                                    if let url = member.avatar, let u = URL(string: url) {
                                                        AsyncImage(url: u) { img in
                                                            img.resizable().scaledToFill()
                                                        } placeholder: {
                                                            Text(String(member.name.prefix(1))).foregroundColor(.white)
                                                        }
                                                    } else {
                                                        Text(String(member.name.prefix(1)))
                                                            .font(.title2)
                                                            .fontWeight(.bold)
                                                            .foregroundColor(.white)
                                                    }
                                                }
                                            )
                                            .clipShape(Circle())
                                        
                                        if member.streak > 0 {
                                            Text("🔥")
                                                .font(.system(size: 24))
                                                .background(Circle().fill(Color.black).frame(width: 20, height: 20)) // outline
                                                .offset(x: 4, y: 4)
                                        }
                                    }
                                    
                                    // Name
                                    Text(member.name)
                                        .font(.headline)
                                        .foregroundColor(.white)
                                    
                                    // Streak Count
                                    Text("\(member.streak) days")
                                        .font(.subheadline)
                                        .foregroundColor(member.streak > 0 ? .orange : .gray)
                                }
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(cardBackground)
                                .cornerRadius(16)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(member.streak > 0 ? Color.orange.opacity(0.3) : Color.clear, lineWidth: 1)
                                )
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Group Streaks")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
        .task {
            await calculateStreaks()
        }
    }
    
    func calculateStreaks() async {
        do {
            // 1. Fetch Profiles
            let profiles: [Profile] = try await supabase
                .from("profiles")
                .select()
                .execute()
                .value
            
            // 2. Fetch Posts (just user_id and created_at to be light)
            // Note: We reuse the Post struct but only care about minimal fields
            let posts: [Post] = try await supabase
                .from("posts")
                .select("id, user_id, created_at") 
                .execute()
                .value
            
            // 3. Logic (Ported from JS)
            var stats: [MemberStats] = []
            
            let calendar = Calendar.current
            let today = calendar.startOfDay(for: Date())
            let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
            
            for user in profiles {
                // Filter posts for this user
                let userPosts = posts.filter { $0.user_id == user.id }
                
                // Get unique dates (normalized to start of day)
                let uniqueDates = Set(userPosts.map { calendar.startOfDay(for: $0.created_at) })
                let sortedDates = Array(uniqueDates).sorted(by: >) // Descending
                
                var currentStreak = 0
                
                if let lastDate = sortedDates.first {
                    // Check if active (posted today or yesterday)
                    if lastDate == today || lastDate == yesterday {
                        currentStreak = 1
                        
                        var checkingDate = lastDate
                        // Loop backwards
                        for i in 1..<sortedDates.count {
                            let prevDate = sortedDates[i]
                            let expectedDate = calendar.date(byAdding: .day, value: -1, to: checkingDate)!
                            
                            if prevDate == expectedDate {
                                currentStreak += 1
                                checkingDate = prevDate
                            } else {
                                break
                            }
                        }
                    }
                }
                
                stats.append(MemberStats(
                    id: user.id,
                    name: user.username ?? "Unknown",
                    avatar: user.avatar_url,
                    streak: currentStreak
                ))
            }
            
            stats.sort { $0.streak > $1.streak }
            self.members = stats
            self.isLoading = false
            
        } catch {
            print("Error calculating streaks: \(error)")
            self.isLoading = false
        }
    }
}
