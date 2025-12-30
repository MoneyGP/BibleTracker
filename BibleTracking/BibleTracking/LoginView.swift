
import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    @EnvironmentObject var authManager: AuthManager
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Logo or Title
                VStack(spacing: 8) {
                    Image(systemName: "book.closed.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                    Text("Bible Tracker")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                .padding(.bottom, 40)
                
                // Form
                VStack(spacing: 16) {
                    TextField("Email", text: $email)
                        .padding()
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(12)
                        .foregroundColor(.white)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                    
                    SecureField("Password", text: $password)
                        .padding()
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(12)
                        .foregroundColor(.white)
                }
                .padding(.horizontal)
                
                if let error = errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.caption)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                Button(action: handleLogin) {
                    if isLoading {
                        ProgressView().tint(.white)
                    } else {
                        Text("Sign In")
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                }
                .padding(.horizontal)
                .disabled(isLoading)
            }
        }
    }
    
    func handleLogin() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                try await authManager.signIn(email: email, password: password)
                // Success is handled by AuthManager listening to stats
            } catch {
                errorMessage = error.localizedDescription
                isLoading = false
            }
        }
    }
}
