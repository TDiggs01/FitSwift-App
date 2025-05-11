//
//  ProfileBannerView.swift
//  FitSwift
//
//  Created by csuftitan on 5/12/25.
//

import SwiftUI
import PhotosUI

struct ProfileBannerView: View {
    let userName: String
    let profileImage: String
    
    @State private var selectedItem: PhotosPickerItem?
    @State private var userProfileImage: UIImage?
    @State private var showingImagePicker = false
    
    var body: some View {
        HStack(spacing: 15) {
            // Profile Image with tap gesture to change
            ZStack {
                if let userProfileImage {
                    // Show user's selected image if available
                    Image(uiImage: userProfileImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 50, height: 50)
                        .clipShape(Circle())
                } else {
                    // Show default system image if no custom image
                    Image(systemName: profileImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 50)
                        .foregroundColor(.white)
                }
            }
            .frame(width: 50, height: 50)
            .padding(10)
            .background(Color.fitSwiftRed)
            .clipShape(Circle())
            .shadow(radius: 2)
            .onTapGesture {
                showingImagePicker = true
            }
            .photosPicker(isPresented: $showingImagePicker, selection: $selectedItem, matching: .images)
            .onChange(of: selectedItem) { newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self),
                       let image = UIImage(data: data) {
                        await MainActor.run {
                            userProfileImage = image
                            // Here you would typically save this image to UserDefaults or your data store
                            saveProfileImage(image)
                        }
                    }
                }
            }
            
            // User Info
            VStack(alignment: .leading, spacing: 4) {
                Text("Welcome back")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                Text(userName)
                    .font(.title2)
                    .fontWeight(.bold)
            }
            
            Spacer()
            
            // Settings Button
            Button {
                print("Settings tapped")
            } label: {
                Image(systemName: "gearshape.fill")
                    .font(.title2)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        .padding(.horizontal)
        .onAppear {
            // Load saved profile image when view appears
            loadProfileImage()
        }
    }
    
    // Save profile image to UserDefaults
    private func saveProfileImage(_ image: UIImage) {
        if let imageData = image.jpegData(compressionQuality: 0.8) {
            UserDefaults.standard.set(imageData, forKey: "userProfileImage")
        }
    }
    
    // Load profile image from UserDefaults
    private func loadProfileImage() {
        if let imageData = UserDefaults.standard.data(forKey: "userProfileImage"),
           let image = UIImage(data: imageData) {
            userProfileImage = image
        }
    }
}

#Preview {
    ProfileBannerView(userName: "John Doe", profileImage: "person.crop.circle.fill")
        .preferredColorScheme(.light)
}
