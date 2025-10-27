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

    @State private var showDeleteConfirmation = false
    @State private var showLogoutConfirmation = false
    @State private var isDeletingAccount = false

    // New for password prompt
    @State private var showPasswordPrompt = false
    @State private var password = ""
    @State private var deleteErrorMessage = ""
    @State private var showDeleteSuccess = false

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    if let profile = userVM.profile {
                        // Profile Header
                        VStack(spacing: 12) {
                            Circle()
                                .fill(Theme.accent)
                                .frame(width: 100, height: 100)
                                .overlay(
                                    Text("\(profile.firstName.prefix(1))\(profile.lastName.prefix(1))")
                                        .font(.system(size: 36, weight: .bold))
                                        .foregroundColor(.white)
                                )
                            
                            Text("\(profile.firstName) \(profile.lastName)")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Text("@\(profile.username)")
                                .font(.headline)
                                .foregroundColor(.white.opacity(0.8))
                        }
                        .padding(.top, 40)
                        
                        // Account Actions
                        VStack(spacing: 16) {
                            Button(action: { showLogoutConfirmation = true }) {
                                HStack {
                                    Image(systemName: "arrow.right.square")
                                    Text("Log Out")
                                    Spacer()
                                }
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.white.opacity(0.15))
                                .foregroundColor(.white)
                                .cornerRadius(12)
                            }
                            
                            Button(action: { showDeleteConfirmation = true }) {
                                HStack {
                                    Image(systemName: "trash")
                                    Text("Delete Account")
                                    Spacer()
                                }
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.red.opacity(0.2))
                                .foregroundColor(.red)
                                .cornerRadius(12)
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 32)
                    }

                    if !deleteErrorMessage.isEmpty {
                        Text(deleteErrorMessage)
                            .foregroundColor(.red)
                            .padding(.horizontal)
                            .multilineTextAlignment(.center)
                    }
                    
                    Spacer()
                }
            }
        }
        .alert("Log Out?", isPresented: $showLogoutConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Log Out", role: .destructive) {
                authViewModel.signOut()
            }
        } message: {
            Text("Are you sure you want to log out?")
        }
        // Step 1: Ask if sure, then present password prompt
        .alert("Delete Account?", isPresented: $showDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Continue", role: .destructive) {
                showPasswordPrompt = true
            }
        } message: {
            Text("This will permanently delete your account and all associated data. This action cannot be undone.")
        }
        // Step 2: Prompt for password
        .alert("Confirm Deletion", isPresented: $showPasswordPrompt, actions: {
            SecureField("Password", text: $password)
            Button("Delete", role: .destructive) {
                handleDeleteAccount()
            }
            Button("Cancel", role: .cancel) { password = "" }
        }, message: {
            Text("Please enter your password to confirm account deletion.")
        })
        // Step 3: Success message
        .alert("Account Deleted", isPresented: $showDeleteSuccess) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Your account was deleted successfully. You have been signed out.")
        }
        .overlay {
            if isDeletingAccount {
                ZStack {
                    Color.black.opacity(0.5).ignoresSafeArea()
                    VStack(spacing: 16) {
                        ProgressView()
                            .scaleEffect(1.5)
                        Text("Deleting account...")
                            .foregroundColor(.white)
                    }
                    .padding(32)
                    .background(Color.black.opacity(0.8))
                    .cornerRadius(16)
                }
            }
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
                // Optionally reset navigation/root here!
            case .failure(let error):
                deleteErrorMessage = error.localizedDescription
            }
        }
    }
}
