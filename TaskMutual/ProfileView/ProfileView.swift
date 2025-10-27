//
//  ProfileView.swift
//  TaskMutual
//
//  Created by Romir Bulbule on 9/30/25.
//

import SwiftUI
import FirebaseAuth

struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var userVM: UserViewModel
    @EnvironmentObject var tasksVM: TasksViewModel

    @State private var showMenu = false
    @State private var showDeleteConfirmation = false
    @State private var showLogoutConfirmation = false
    @State private var showPasswordPrompt = false
    @State private var password = ""
    @State private var deleteErrorMessage = ""
    @State private var showDeleteSuccess = false
    @State private var isDeletingAccount = false
    @State private var bioDraft: String = ""
    @State private var isEditingBio = false
    @State private var showImagePicker = false
    @State private var inputImage: UIImage?
    @State private var updateStatus: String = ""
    @State private var isEditingProfile = false

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()
            VStack(spacing: 0) {
                // --- Top section: Profile pic, name, stats, hamburger ---
                if let profile = userVM.profile {
                    HStack(alignment: .top, spacing: 16) {
                        // Profile Picture (left)
                        Button {
                            if isEditingProfile {
                                showImagePicker = true
                            }
                        } label: {
                            ZStack {
                                if let urlString = profile.profileImageURL,
                                   let url = URL(string: urlString) {
                                    AsyncImage(url: url) { phase in
                                        switch phase {
                                        case .empty: ProgressView()
                                        case .success(let image): image.resizable()
                                        case .failure(_): Image(systemName: "person.crop.circle.fill").resizable().foregroundColor(.gray)
                                        @unknown default: Image(systemName: "person.crop.circle.fill").resizable().foregroundColor(.gray)
                                        }
                                    }
                                    .clipShape(Circle())
                                } else {
                                    Image(systemName: "person.crop.circle.fill")
                                        .resizable().foregroundColor(.gray)
                                }
                            }
                            .frame(width: 86, height: 86)
                            .overlay(Circle().stroke(Theme.accent, lineWidth: 3))
                        }
                        .disabled(!isEditingProfile)
                        .sheet(isPresented: $showImagePicker) { ImagePicker(image: $inputImage) }
                        .onChange(of: inputImage) { img in
                            if let img = img {
                                userVM.uploadProfileImage(img) { result in
                                    switch result {
                                    case .success(_): updateStatus = "Profile photo updated."
                                    case .failure(let err): updateStatus = err.localizedDescription
                                    }
                                }
                            }
                        }

                        // Name and Stats (middle/right)
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                // Name
                                Text("\(profile.firstName) \(profile.lastName)")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                Spacer()
                                // Hamburger menu aligned with name
                                Button(action: { showMenu.toggle() }) {
                                    Image(systemName: "line.3.horizontal")
                                        .font(.title2)
                                        .foregroundColor(Theme.accent)
                                }
                            }

                            // Stats row - Tasks Posted / Tasks Archived
                            HStack(spacing: 40) {
                                VStack {
                                    Text("\(tasksVM.tasks.filter { $0.creatorUserId == profile.id }.count)")
                                        .font(.title3).bold()
                                        .foregroundColor(.white)
                                    Text("Tasks Posted")
                                        .font(.caption)
                                        .foregroundColor(.white.opacity(0.7))
                                }
                                VStack {
                                    Text("\(tasksVM.tasks.filter { $0.creatorUserId == profile.id && $0.isArchived }.count)")
                                        .font(.title3).bold()
                                        .foregroundColor(.white)
                                    Text("Tasks Archived")
                                        .font(.caption)
                                        .foregroundColor(.white.opacity(0.7))
                                }
                                Spacer()
                            }
                        }
                    }
                    .padding(.top, 20)
                    .padding(.horizontal, 20)

                    // --- Bio section (full width below profile) ---
                    VStack(alignment: .leading, spacing: 8) {
                        if isEditingBio && isEditingProfile {
                            TextEditor(text: $bioDraft)
                                .frame(height: 60)
                                .background(Color.white.opacity(0.20))
                                .cornerRadius(10)
                                .foregroundColor(.black)
                            HStack {
                                Button("Cancel") {
                                    bioDraft = profile.bio ?? ""
                                    isEditingBio = false
                                }.foregroundColor(.red)
                                Spacer()
                                Button("Save") {
                                    userVM.updateBio(bioDraft) {
                                        updateStatus = "Bio updated."
                                        isEditingBio = false
                                    }
                                }
                                .bold()
                                .foregroundColor(Theme.accent)
                            }
                        } else {
                            if let bio = profile.bio, !bio.isEmpty {
                                Text(bio)
                                    .font(.body)
                                    .foregroundColor(.white.opacity(0.92))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                    }
                    .padding(.top, 12)
                    .padding(.horizontal, 20)

                    // --- Button Row ---
                    HStack(spacing: 16) {
                        Button(action: {
                            if isEditingProfile {
                                // Save profile changes
                                isEditingProfile = false
                                isEditingBio = false
                            } else {
                                // Enter edit mode
                                isEditingProfile = true
                                bioDraft = profile.bio ?? ""
                            }
                        }) {
                            Text(isEditingProfile ? "Done" : "Edit Profile")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .background(Theme.accent)
                                .cornerRadius(14)
                                .shadow(color: Theme.accent.opacity(0.18), radius: 4, x: 0, y: 2)
                        }
                        
                        if isEditingProfile {
                            Button(action: {
                                isEditingBio = true
                            }) {
                                Text("Edit Bio")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(Theme.accent)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 10)
                                    .background(Color.white.opacity(0.14))
                                    .cornerRadius(14)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14)
                                            .stroke(Theme.accent, lineWidth: 1)
                                    )
                            }
                        } else {
                            Button(action: {
                                updateStatus = "Profile shared!"
                            }) {
                                Text("Share Profile")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(Theme.accent)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 10)
                                    .background(Color.white.opacity(0.14))
                                    .cornerRadius(14)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14)
                                            .stroke(Theme.accent, lineWidth: 1)
                                    )
                                    .shadow(color: Theme.accent.opacity(0.10), radius: 2, x: 0, y: 1)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                }

                if !updateStatus.isEmpty {
                    Text(updateStatus)
                        .foregroundColor(.orange)
                        .padding(.horizontal)
                        .padding(.top, 8)
                        .multilineTextAlignment(.center)
                }

                Spacer()
            }
            // ------ Hamburger Menu Modal -------
            if showMenu {
                Color.black.opacity(0.5)
                    .ignoresSafeArea()
                    .onTapGesture { showMenu = false }
                VStack(spacing: 24) {
                    Text("Account Settings")
                        .font(.headline)
                        .foregroundColor(.white)
                    Button(action: { showLogoutConfirmation = true }) {
                        HStack {
                            Image(systemName: "arrow.right.square")
                            Text("Log Out")
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                    }
                    Button(action: { showDeleteConfirmation = true }) {
                        HStack {
                            Image(systemName: "trash")
                            Text("Delete Account")
                        }
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity)
                    }
                }
                .padding(32)
                .background(Theme.background.opacity(0.92))
                .cornerRadius(20)
                .frame(maxWidth: 320)
                .padding(.top, 80)
                .shadow(radius: 10)
            }
            if isDeletingAccount {
                ZStack {
                    Color.black.opacity(0.5).ignoresSafeArea()
                    VStack(spacing: 16) {
                        ProgressView().scaleEffect(1.5)
                        Text("Deleting account...")
                            .foregroundColor(.white)
                    }
                    .padding(32)
                    .background(Color.black.opacity(0.8))
                    .cornerRadius(16)
                }
            }
        }
        // ===== Attach all modifiers directly to ZStack here! =====
        .alert("Log Out?", isPresented: $showLogoutConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Log Out", role: .destructive) {
                authViewModel.signOut()
                showMenu = false
            }
        } message: {
            Text("Are you sure you want to log out?")
        }
        .alert("Delete Account?", isPresented: $showDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Continue", role: .destructive) {
                showPasswordPrompt = true
            }
        } message: {
            Text("This will permanently delete your account and all associated data. This action cannot be undone.")
        }
        .alert("Confirm Deletion", isPresented: $showPasswordPrompt, actions: {
            SecureField("Password", text: $password)
            Button("Delete", role: .destructive) {
                handleDeleteAccount()
            }
            Button("Cancel", role: .cancel) { password = "" }
        }, message: {
            Text("Please enter your password to confirm account deletion.")
        })
        .alert("Account Deleted", isPresented: $showDeleteSuccess) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Your account was deleted successfully. You have been signed out.")
        }
    }
    private func handleDeleteAccount() {
        isDeletingAccount = true
        deleteErrorMessage = ""
        authViewModel.deleteAccountAndAllData(userVM: userVM, password: password) { result in
            isDeletingAccount = false
            password = ""
            switch result {
            case .success:
                showDeleteSuccess = true
                showMenu = false
            case .failure(let error):
                deleteErrorMessage = error.localizedDescription
            }
        }
    }
}
