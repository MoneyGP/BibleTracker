
import SwiftUI

struct CommentsSheet: View {
    let postId: UUID
    @State private var comments: [Comment] = []
    @State private var newCommentText = ""
    @State private var isLoading = true
    @State private var isPosting = false
    @EnvironmentObject var authManager: AuthManager
    
    var body: some View {
        VStack {
            // Header
            Text("Comments")
                .font(.headline)
                .padding()
            
            // List
            if isLoading {
                ProgressView()
                Spacer()
            } else if comments.isEmpty {
                Spacer()
                Text("No comments yet")
                    .foregroundColor(.gray)
                Spacer()
            } else {
                List(comments) { comment in
                    VStack(alignment: .leading, spacing: 4) {
                        // Ideally we fetch profile info too. For now showing content.
                        // We need to join with profiles to get username.
                        Text(comment.content)
                            .font(.body)
                        Text(comment.created_at.formatted(date: .abbreviated, time: .shortened))
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                .listStyle(.plain)
            }
            
            // Input
            HStack {
                TextField("Add a comment...", text: $newCommentText)
                    .textFieldStyle(.roundedBorder)
                
                Button(action: postComment) {
                    if isPosting {
                        ProgressView()
                    } else {
                        Text("Post")
                            .bold()
                    }
                }
                .disabled(newCommentText.isEmpty || isPosting)
            }
            .padding()
            .background(Color(uiColor: .systemBackground))
        }
        .task {
            await fetchComments()
        }
    }
    
    func fetchComments() async {
        do {
            // Need to join profiles to get username? For now basic fetch.
            // Note: Comment model in Models.swift might need updating if we want profiles.
            // Let's assume basic fetch first.
            let fetched: [Comment] = try await supabase
                .from("comments")
                .select()
                .eq("post_id", value: postId)
                .order("created_at", ascending: true)
                .execute()
                .value
            
            comments = fetched
            isLoading = false
        } catch {
            print("Error fetching comments: \(error)")
            isLoading = false
        }
    }
    
    func postComment() {
        guard let user = authManager.session?.user else { return }
        isPosting = true
        
        Task {
            do {
                let newComment = CommentInsert(
                    post_id: postId,
                    user_id: user.id,
                    content: newCommentText
                )
                
                try await supabase.from("comments").insert(newComment).execute()
                
                newCommentText = ""
                await fetchComments() // Refresh
                isPosting = false
            } catch {
                print("Error posting comment: \(error)")
                isPosting = false
            }
        }
    }
}

// Helper for insertion
struct CommentInsert: Encodable {
    let post_id: UUID
    let user_id: UUID
    let content: String
}
