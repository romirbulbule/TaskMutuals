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
    @State private var showCropView = false
    @FocusState private var bioIsFocused: Bool
    let maxBioLength = 150

    var body: some View {
        ZStack(alignment: .bottom) {
            Theme.background.ignoresSafeArea()
            VStack(spacing: 26) {

                // --------- PROFILE IMAGE BLOCK ----------
                VStack(spacing: 8) {
                    if let pickedImage = inputImage {
                        Image(uiImage: pickedImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.accentColor, lineWidth: 2.5))
                            .shadow(radius: 6)
                    } else if let urlString = userVM.profile?.profileImageURL, let url = URL(string: urlString) {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                            case .success(let image):
                                image.resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 100, height: 100)
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(Color.accentColor, lineWidth: 2.5))
                                    .shadow(radius: 6)
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
                // ---------------------------------------

                Button(action: { showImagePicker = true }) {
                    Text("Edit profile picture")
                        .foregroundColor(Color.accentColor)
                        .font(.system(size: 16, weight: .semibold))
                }
                .sheet(isPresented: $showImagePicker, onDismiss: {
                    if inputImage != nil {
                        showCropView = true
                    }
                }) {
                    ImagePicker(image: $inputImage)
                }
                .sheet(isPresented: $showCropView) {
                    CropView(
                        image: Binding(
                            get: { inputImage },
                            set: { inputImage = $0 }
                        ),
                        onSet: { cropped in
                            inputImage = cropped
                            showCropView = false
                        },
                        onChooseAnother: {
                            inputImage = nil
                            showCropView = false
                            showImagePicker = true
                        }
                    )
                }

                // Name field - grayed & uneditable
                VStack(alignment: .leading, spacing: 6) {
                    Text("Name")
                        .font(.headline)
                        .foregroundColor(.white)
                    TextField("Name", text: $name)
                        .disabled(true)
                        .foregroundColor(Color.gray.opacity(0.8))
                        .padding(12)
                        .background(Color.gray.opacity(0.15))
                        .cornerRadius(10)
                }

                // Username field - grayed & uneditable
                VStack(alignment: .leading, spacing: 6) {
                    Text("Username")
                        .font(.headline)
                        .foregroundColor(.white)
                    TextField("Username", text: $username)
                        .disabled(true)
                        .foregroundColor(Color.gray.opacity(0.8))
                        .padding(12)
                        .background(Color.gray.opacity(0.15))
                        .cornerRadius(10)
                }

                // Bio field
                VStack(alignment: .leading, spacing: 2) {
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
                    .focused($bioIsFocused)
                    .frame(height: 90)
                    HStack {
                        Spacer()
                        Text("\(bio.count)/\(maxBioLength)")
                            .font(.caption2)
                            .foregroundColor(bio.count < maxBioLength ? .white : .red)
                            .padding(.trailing, 8)
                    }
                }

                Spacer()

                Button(action: {
                    userVM.updateProfile(name: name, username: username, bio: bio) {
                        if let image = inputImage {
                            userVM.uploadProfileImage(image) { _ in
                                self.presentationMode.wrappedValue.dismiss()
                            }
                        } else {
                            self.presentationMode.wrappedValue.dismiss()
                        }
                    }
                }) {
                    Text("Save")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, minHeight: 24)
                        .padding(.vertical, 16)
                        .background(Color.accentColor)
                        .cornerRadius(16)
                }
                .padding(.bottom, 12)
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.horizontal, 22)

            // -------- Floating "Done" button over keyboard when bio is focused --------
            if bioIsFocused {
                Button(action: {
                    bioIsFocused = false
                }) {
                    Text("Done")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.accentColor)
                        .cornerRadius(16)
                        .shadow(color: Color.accentColor.opacity(0.23), radius: 6, y: 2)
                        .padding([.horizontal, .bottom], 18)
                }
                .transition(.move(edge: .bottom))
                .animation(.default, value: bioIsFocused)
            }
            // -------------------------------------------------------------------------
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
