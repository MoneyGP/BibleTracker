
import Foundation
import SwiftUI
import Supabase

@MainActor
class AuthManager: ObservableObject {
    @Published var session: Session?
    @Published var isLoading = true
    
    static let shared = AuthManager()
    
    init() {
        // Check for existing session on launch
        Task {
            do {
                self.session = try await supabase.auth.session
            } catch {
                print("No session found: \(error)")
            }
            self.isLoading = false
        }
        
        // Listen for auth changes (login/logout)
        Task {
            for await _ in supabase.auth.authStateChanges {
                do {
                    self.session = try await supabase.auth.session
                } catch {
                    self.session = nil
                }
            }
        }
    }
    
    var isAuthenticated: Bool {
        return session != nil
    }
    
    func signIn(email: String, password: String) async throws {
        _ = try await supabase.auth.signIn(email: email, password: password)
    }
    
    func signUp(email: String, password: String) async throws {
        _ = try await supabase.auth.signUp(email: email, password: password)
    }
    
    func signOut() async {
        try? await supabase.auth.signOut()
        self.session = nil
    }
}
