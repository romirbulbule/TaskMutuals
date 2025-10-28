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

    var body: some View {
        NavigationView {
            ZStack {
                Theme.background.ignoresSafeArea()
                VStack(spacing: 0) {

                    // Name/Header/Hamburger Bar
                    HStack(alignment: .center) {
                        Spacer(minLength: 55)
                        Text("\(userVM.profile?.firstName ?? "") \(userVM.profile?.lastName ?? "")")
                            .font(.system(size: 22, weight: .heavy))
                            .foregroundColor(.white)
                            .lineLimit(1)
                            .minimumScaleFactor(0.6)
                            .padding(.leading, 22)
                        Spacer()
                        Button(action: { showMenu.toggle() }) {
                            Image(systemName: "line.3.horizontal")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(Theme.accent)
                        }
                        .padding(.trailing, 4)
                    }
                    .padding(.top, 18)
                    .padding(.horizontal, 10)
                    .padding(.bottom, 8)

                    // Profile + stats row
                    HStack(alignment: .center, spacing: 14) {
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
                                            .frame(width: 98, height: 98)
                                            .clipShape(Circle())
                                            .overlay(Circle().stroke(Theme.accent, lineWidth: 5))
                                    default:
                                        Image(systemName: "person.crop.circle.fill")
                                            .resizable()
                                            .foregroundColor(.gray)
                                            .frame(width: 98, height: 98)
                                            .clipShape(Circle())
                                            .overlay(Circle().stroke(Theme.accent, lineWidth: 5))
                                    }
                                }
                            } else {
                                Image(systemName: "person.crop.circle.fill")
                                    .resizable()
                                    .foregroundColor(.gray)
                                    .frame(width: 98, height: 98)
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(Theme.accent, lineWidth: 5))
                            }
                        }

                        // Stats row close to image
                        HStack(spacing: 32) {
                            VStack(spacing: 2) {
                                Text("\(tasksVM.tasks.filter { $0.creatorUserId == userVM.profile?.id }.count)")
                                    .font(.system(size: 18, weight: .bold)).foregroundColor(.white)
                                Text("Tasks Posted")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.78))
                            }
                            VStack(spacing: 2) {
                                Text("\(tasksVM.tasks.filter { $0.creatorUserId == userVM.profile?.id && $0.isArchived }.count)")
                                    .font(.system(size: 18, weight: .bold)).foregroundColor(.white)
                                Text("Tasks Archived")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.78))
                            }
                        }
                        .padding(.leading, 6)

                        Spacer(minLength: 0)
                    }
                    .padding(.top, 8)
                    .padding(.bottom, 6)
                    .padding(.horizontal, 18)

                    // Bio
                    if let bio = userVM.profile?.bio, !bio.isEmpty {
                        Text(bio)
                            .font(.system(size: 18))
                            .foregroundColor(.white.opacity(0.93))
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 18)
                            .padding(.vertical, 2)
                            .padding(.top, 2)
                    }

                    // Buttons: Edit Profile (navigates), Share Profile
                    HStack(spacing: 16) {
                        NavigationLink(destination: EditProfileView().environmentObject(userVM)) {
                            Text("Edit Profile")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Theme.accent)
                                .cornerRadius(16)
                                .shadow(color: Theme.accent.opacity(0.18), radius: 4, x: 0, y: 2)
                        }
                        Button(action: {
                            // Share profile logic here
                        }) {
                            Text("Share Profile")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Theme.accent)
                                .cornerRadius(16)
                                .shadow(color: Theme.accent.opacity(0.18), radius: 4, x: 0, y: 2)
                        }
                    }
                    .padding(.horizontal, 22)
                    .padding(.top, 32)

                    Spacer()
                }
                if showMenu { settingsMenu }
                if isDeletingAccount { deletingOverlay }
            }
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
        .navigationViewStyle(StackNavigationViewStyle())
    }

    private var settingsMenu: some View {
        Group {
            Color.black.opacity(0.5)
                .ignoresSafeArea()
                .onTapGesture { showMenu = false }
            VStack(spacing: 24) {
                Text("Account Settings")
                    .font(.headline)
                    .foregroundColor(.white)
                NavigationLink(destination: EditProfileView().environmentObject(userVM)) {
                    HStack {
                        Image(systemName: "person.crop.circle.badge.checkmark")
                        Text("Edit Profile")
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                }
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
    }

    private var deletingOverlay: some View {
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
