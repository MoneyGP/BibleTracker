
import SwiftUI
import UserNotifications

struct ProfileView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var username: String = ""
    @State private var isEditing = false
    @State private var isLoading = false
    
    // Notifications
    @State private var notificationsEnabled = false
    @State private var reminderTime = Date()
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack(spacing: 24) {
                    
                    // Avatar & Info
                    VStack(spacing: 16) {
                        Circle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 100, height: 100)
                            .overlay(
                                Text(authManager.profile?.username?.prefix(1).uppercased() ?? "?")
                                    .font(.system(size: 40, weight: .bold))
                                    .foregroundColor(.white)
                            )
                        
                        if isEditing {
                            HStack {
                                TextField("Username", text: $username)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .autocapitalization(.none)
                                
                                Button("Save") {
                                    saveUsername()
                                }
                                .disabled(username.isEmpty || isLoading)
                            }
                            .padding(.horizontal, 40)
                        } else {
                            HStack {
                                Text(authManager.profile?.username ?? "No Username")
                                    .font(.title2)
                                    .bold()
                                    .foregroundColor(.white)
                                
                                Button(action: {
                                    username = authManager.profile?.username ?? ""
                                    isEditing = true
                                }) {
                                    Image(systemName: "pencil.circle.fill")
                                        .foregroundColor(.blue)
                                        .font(.title2)
                                }
                            }
                        }
                    }
                    .padding(.top, 40)
                    
                    List {
                        Section(header: Text("Preferences").foregroundColor(.gray)) {
                            Toggle("Daily Reading Reminder", isOn: $notificationsEnabled)
                                .onChange(of: notificationsEnabled) { enabled in
                                    if enabled {
                                        requestNotificationPermission()
                                    } else {
                                        cancelNotifications()
                                    }
                                }
                            
                            if notificationsEnabled {
                                DatePicker("Time", selection: $reminderTime, displayedComponents: .hourAndMinute)
                                    .onChange(of: reminderTime) { _ in
                                        scheduleNotification()
                                    }
                            }
                        }
                        .listRowBackground(Color(white: 0.1))
                    }
                    .scrollContentBackground(.hidden)
                    
                    
                    Spacer()
                    
                    Button(action: {
                        Task { await authManager.signOut() }
                    }) {
                        Text("Sign Out")
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red.opacity(0.8))
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                    .padding()
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear {
            Task {
                await authManager.fetchProfile()
                checkNotificationStatus()
            }
        }
    }
    
    func saveUsername() {
        isLoading = true
        Task {
            do {
                try await authManager.updateUsername(name: username)
                isEditing = false
            } catch {
                print("Error updating username: \(error)")
            }
            isLoading = false
        }
    }
    
    // MARK: - Notifications
    
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            DispatchQueue.main.async {
                self.notificationsEnabled = granted
                if granted {
                    scheduleNotification()
                }
            }
        }
    }
    
    func scheduleNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Time for the Word"
        content.body = "Keep your streak alive! Read today's passage."
        content.sound = .default
        
        let components = Calendar.current.dateComponents([.hour, .minute], from: reminderTime)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        
        let request = UNNotificationRequest(identifier: "daily_reading", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().add(request)
    }
    
    func cancelNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    func checkNotificationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.notificationsEnabled = (settings.authorizationStatus == .authorized)
                // We can't easily read back the *time* of a pending request reliably without parsing triggers,
                // so we just default to the current picker time unless we store it in UserDefaults.
                // For MVP, if authorized, we assume enabled.
            }
        }
    }
}
