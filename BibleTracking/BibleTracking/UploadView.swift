
import SwiftUI
import PhotosUI

struct UploadView: View {
    let reading: String
    @State private var caption = ""
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImage: Image?
    @State private var uiImage: UIImage?
    @State private var isLoading = false
    @State private var errorMessage: String?
    @Environment(\.dismiss) var dismiss
    
    @EnvironmentObject var authManager: AuthManager
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                Text("Post Reading")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.top)
                
                Text(reading)
                    .font(.headline)
                    .foregroundColor(.blue)
                
                // Image Picker
                PhotosPicker(selection: $selectedItem, matching: .images) {
                    if let selectedImage {
                        selectedImage
                            .resizable()
                            .scaledToFill()
                            .frame(height: 300)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
                            )
                    } else {
                        ZStack {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white.opacity(0.05))
                                .frame(height: 300)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.white.opacity(0.1), lineWidth: 1, dash: [5])
                                )
                            
                            VStack(spacing: 12) {
                                Image(systemName: "camera.fill")
                                    .font(.system(size: 40))
                                    .foregroundColor(.blue)
                                Text("Tap to select photo")
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                }
                .onChange(of: selectedItem) { newItem in
                    Task {
                        if let data = try? await newItem?.loadTransferable(type: Data.self),
                           let image = UIImage(data: data) {
                            self.uiImage = image
                            self.selectedImage = Image(uiImage: image)
                        }
                    }
                }
                
                // Caption
                TextField("Write a caption...", text: $caption)
                    .padding()
                    .background(Color.white.opacity(0.05))
                    .cornerRadius(12)
                    .foregroundColor(.white)
                
                // Submit Button
                Button(action: uploadPost) {
                    if isLoading {
                        ProgressView().tint(.white)
                    } else {
                        Text("Post")
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(uiImage == nil ? Color.gray.opacity(0.3) : Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                }
                .disabled(uiImage == nil || isLoading)
                
                if let error = errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.caption)
                }
            }
            .padding()
        }
        .background(Color.black.ignoresSafeArea())
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
                
                // Note: Using standard storage upload (assuming bucket 'posts' exists)
                try await supabase.storage.from("posts").upload(
                    path: fileName,
                    file: imageData,
                    options: FileOptions(contentType: "image/jpeg")
                )
                
                let publicUrl = try supabase.storage.from("posts").getPublicUrl(path: fileName)
                
                // 2. Insert Post Record
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"
                let dateStr = formatter.string(from: Date())
                
                let newPost = PostWrapper(
                   user_id: user.id,
                   content: caption.isEmpty ? nil : caption,
                   image_url: publicUrl.absoluteString,
                   date: dateStr
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
struct PostWrapper: Encodable {
    let user_id: UUID
    let content: String?
    let image_url: String?
    let date: String
}
