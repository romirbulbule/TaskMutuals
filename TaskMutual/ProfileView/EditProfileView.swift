//
//  EditProfileView.swift
//  TaskMutual
//
//  Created by Romir Bulbule on 10/28/25.
//


import SwiftUI

struct EditProfileView: View {
    @EnvironmentObject var userVM: UserViewModel
    @Environment(\.presentationMode) var presentationMode

    @State private var name: String = ""
    @State private var username: String = ""
    @State private var bio: String = ""
    @State private var inputImage: UIImage?
    @State private var showImagePicker = false
    let maxBioLength = 150

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()

            VStack(spacing: 26) {
                // Profile picture
                ZStack {
                    if let urlString = userVM.profile?.profileImageURL, let url = URL(string: urlString) {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 100, height: 100)
                                    .clipShape(Circle())
                            default:
                                Image(systemName: "person.crop.circle.fill")
                                    .resizable()
                                    .frame(width: 100, height: 100)
                                    .foregroundColor(.gray)
                            }
                        }
                    } else {
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .frame(width: 100, height: 100)
                            .foregroundColor(.gray)
                    }
                }

                Button(action: { showImagePicker = true }) {
                    Text("Edit profile picture")
                        .foregroundColor(Color.accentColor)
                        .font(.system(size: 16, weight: .semibold))
                }
                .sheet(isPresented: $showImagePicker) {
                    ImagePicker(image: $inputImage)
                }

                // Name field
                VStack(alignment: .leading, spacing: 6) {
                    Text("Name")
                        .font(.headline)
                        .foregroundColor(.white)
                    TextField("Name", text: $name)
                        .foregroundColor(.white)
                        .padding(12)
                        .background(Color.white.opacity(0.07))
                        .cornerRadius(10)
                        .accentColor(.accentColor)
                }

                // Username field
                VStack(alignment: .leading, spacing: 6) {
                    Text("Username")
                        .font(.headline)
                        .foregroundColor(.white)
                    TextField("Username", text: $username)
                        .foregroundColor(.white)
                        .padding(12)
                        .background(Color.white.opacity(0.07))
                        .cornerRadius(10)
                        .accentColor(.accentColor)
                }

                // Bio field
                VStack(alignment: .leading, spacing: 6) {
                    Text("Bio")
                        .font(.headline)
                        .foregroundColor(.white)
                    MultilineTextField(
                        text: $bio,
                        placeholder: "Bio",
                        minHeight: 48,
                        maxHeight: 100,
                        background: UIColor(white: 1, alpha: 0.07),
                        cornerRadius: 10
                    )
                    .frame(height: 90)
                    HStack {
                        Spacer()
                        Text("\(bio.count)/\(maxBioLength)")
                            .font(.caption2)
                            .foregroundColor(bio.count < maxBioLength ? .secondary : .red)
                            .padding(.trailing, 8)
                            .padding(.top, -6)
                    }
                }

                Spacer()

                Button("Save") {
                    userVM.updateProfile(name: name, username: username, bio: bio) {
                        if let image = inputImage {
                            userVM.uploadProfileImage(image) { _ in
                                self.presentationMode.wrappedValue.dismiss()
                            }
                        } else {
                            self.presentationMode.wrappedValue.dismiss()
                        }
                    }
                }
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.accentColor)
                .cornerRadius(16)
                .padding(.bottom, 12)
            }
            .padding(.horizontal, 22)
        }
        .onAppear {
            if let profile = userVM.profile {
                name = profile.firstName + " " + profile.lastName
                username = profile.username ?? ""
                bio = profile.bio ?? ""
            }
        }
        .navigationTitle("Edit Profile")
        .navigationBarTitleDisplayMode(.inline)
    }
}
