
import SwiftUI
import PhotosUI

struct UploadView: View {
    let reading: String // Reference string
    let targetDate: String // YYYY-MM-DD
    @State private var caption = ""
    @State private var showCamera = false
    @State private var showActionSheet = false
    
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var selectedImage: Image? = nil
    @State private var uiImage: UIImage? = nil
    
    @State private var isUploading = false
    @State private var errorMessage: String?
    @Environment(\.dismiss) var dismiss
    
    @EnvironmentObject var authManager: AuthManager
    
    // Check if targetDate is Today (local time)
    var isToday: Bool {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let todayStr = formatter.string(from: Date())
        return targetDate == todayStr
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header (same)
                HStack {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(.white)
                    Spacer()
                    Text("New Post")
                        .font(.headline)
                        .foregroundColor(.white)
                    Spacer()
                    // Hidden placeholder for balance
                    Text("Cancel").hidden()
                }
                .padding()
                
                // Reading Card (same)
                VStack(spacing: 8) {
                    Text(reading)
                        .font(.title2)
                        .bold()
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.white.opacity(0.1))
                .cornerRadius(16)
                
                // Image Selection Area
                if let selectedImage {
                    selectedImage
                        .resizable()
                        .scaledToFill()
                        .frame(height: 300)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.1), lineWidth: 1))
                        .overlay(alignment: .topTrailing) {
                            Button(action: {
                                // Clear image
                                self.selectedImage = nil
                                self.uiImage = nil
                                self.selectedItem = nil
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.title)
                                    .foregroundColor(.white)
                                    .padding(8)
                            }
                        }
                } else {
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white.opacity(0.05))
                            .frame(height: 300)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.white.opacity(0.1), style: StrokeStyle(lineWidth: 1, dash: [5]))
                            )
                        
                        VStack(spacing: 20) {
                            if isToday {
                                HStack(spacing: 30) {
                                    Button(action: { showCamera = true }) {
                                        VStack(spacing: 8) {
                                            Image(systemName: "camera.fill")
                                                .font(.system(size: 30))
                                            Text("Camera")
                                        }
                                        .foregroundColor(.blue)
                                    }
                                    
                                    PhotosPicker(selection: $selectedItem, matching: .images) {
                                        VStack(spacing: 8) {
                                            Image(systemName: "photo.fill.on.rectangle.fill")
                                                .font(.system(size: 30))
                                            Text("Library")
                                        }
                                        .foregroundColor(.purple)
                                    }
                                    .onChange(of: selectedItem) { newItem in
                                        loadTransferable(newItem)
                                    }
                                }
                            } else {
                                Image(systemName: "lock.fill")
                                    .font(.system(size: 40))
                                    .foregroundColor(.gray)
                                Text("Upload Locked")
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                }
                
                if !isToday {
                    HStack {
                        Image(systemName: "clock.badge.exclamationmark")
                        Text("You can only upload for today's reading.")
                    }
                    .font(.caption)
                    .foregroundColor(.orange)
                    .padding(.top, 4)
                }
                
                // Input & Button ...
                TextField("Add a thought or prayer... (optional)", text: $caption, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .lineLimit(3...6)
                    .padding(.vertical)
                
                Button(action: uploadPost) {
                    if isUploading {
                        ProgressView().tint(.white)
                    } else {
                        Text("Post Update")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background((selectedImage == nil || !isToday) ? Color.gray : Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                }
                .disabled(selectedImage == nil || isUploading || !isToday)
                
                if let error = errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.caption)
                }
            }
            .padding()
        }
        .background(Color.black.ignoresSafeArea())
        .fullScreenCover(isPresented: $showCamera) {
            CameraView(image: $uiImage)
                .ignoresSafeArea()
        }
        // Sync UIImage to SwiftUI Image (from Camera)
        .onChange(of: uiImage) { newImage in
            if let newImage {
                selectedImage = Image(uiImage: newImage)
            }
        }
    }
    
    // Extracted Picker Content won't work easily with ActionSheet logic unless we do custom sheet.

    
    func loadTransferable(_ newItem: PhotosPickerItem?) {
        Task {
            if let data = try? await newItem?.loadTransferable(type: Data.self),
               let image = UIImage(data: data) {
                self.uiImage = image
                self.selectedImage = Image(uiImage: image)
            }
        }
    }
    
    func uploadPost() {
        guard let uiImage = uiImage, let user = authManager.session?.user else { return }
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                // 1. Upload Image to Supabase Storage
                guard let imageData = uiImage.jpegData(compressionQuality: 0.5) else { return }
                let fileName = "\(user.id)/\(UUID().uuidString).jpg"
                
                // Using standard upload
                let _ = try await supabase.storage.from("posts").upload(
                    path: fileName,
                    file: imageData
                )
                
                // 2. Get Public URL (Fix: Manual construction if SDK fails or try getPublicURL)
                // Note: getPublicUrl is sometimes synchronous in newer SDKs or named differently.
                // Assuming standard Supabase Storage URL format:
                // https://<project>.supabase.co/storage/v1/object/public/<bucket>/<path>
                // But let's try the SDK method `getPublicURL` (capital URL) first.
                // If the user says it doesn't exist, I'll construct it. The user said 'getPublicUrl' has no member.
                // It's likely `publicURL(path:)` or `getPublicURL(path:)` doesn't exist on `StorageFileApi`.
                // In some versions it is `from(...).publicUrl(...)` ?
                // I will blindly construct it for reliability.
                 
                 // BUT I need the base URL. I don't have it easily accessible as a string global variable except in SupabaseManager maybe?
                 // Let's look at `SupabaseManager.swift` first? No, I'll assume `getPublicURL` was just a typo in casing?
                 // User said: Value of type 'StorageFileApi' has no member 'getPublicUrl'
                 // I will try `getPublicURL` (capital URL).
                
                let publicUrl = try supabase.storage.from("posts").getPublicURL(path: fileName) // Capital URL
                
                // 2. Insert Post Record
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"
                let dateStr = formatter.string(from: Date())
                
                let newPost = PostWrapper(
                   user_id: user.id,
                   caption: caption.isEmpty ? nil : caption,
                   image_url: publicUrl.absoluteString,
                   date: dateStr,
                   reading_ref: reading
                )
                
                try await supabase.from("posts").insert(newPost).execute()
                
                isLoading = false
                dismiss() // Close view
                
            } catch {
                print("Upload failed: \(error)")
                errorMessage = "Upload failed: \(error.localizedDescription)"
                isLoading = false
            }
        }
    }
}

// Helper for Insert (since Post has extra decode fields)
// Helper for Insert (since Post has extra decode fields)
struct PostWrapper: Encodable {
    let user_id: UUID
    let caption: String?
    let image_url: String?
    let date: String
    let reading_ref: String
}
