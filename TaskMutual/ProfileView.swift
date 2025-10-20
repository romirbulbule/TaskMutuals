//
//  ProfileView.swift
//  TaskMutual
//
//  Created by Romir Bulbule on 9/30/25.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var userVM: UserViewModel

    @State private var showDeleteAlert = false
    @State private var showErrorAlert = false
    @State private var errorMessage = ""

    var body: some View {
        NavigationView {
            VStack(spacing: 28) {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .frame(width: 80, height: 80)
                    .foregroundColor(.blue)
                    .padding(.top, 32)

                if let profile = userVM.profile {
                    Text("\(profile.firstName) \(profile.lastName)").font(.title).bold()
                    Text("@\(profile.username)").font(.body).foregroundColor(.secondary)
                } else {
                    ProgressView("Loading...")
                }

                Spacer()

                Button(action: {
                    authViewModel.signOut(userVM: userVM)
                }) {
                    Text("Logout")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.horizontal)
                }
                .padding(.bottom, 24)

                // Account Deletion Button w/ confirmation and error alert
                Button(action: {
                    showDeleteAlert = true
                }) {
                    Text("Delete Account")
                        .font(.headline)
                        .foregroundColor(.red)
                }
                .padding(.bottom, 24)
                .alert("Are you sure you want to delete your account?", isPresented: $showDeleteAlert) {
                    Button("Delete", role: .destructive) {
                        handleDelete()
                    }
                    Button("Cancel", role: .cancel) {}
                } message: {
                    Text("This cannot be undone.")
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .navigationTitle("Profile")
        }
        .onAppear { userVM.fetchUserProfile() }
        .alert("Error", isPresented: $showErrorAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
    }

    func handleDelete() {
        userVM.deleteAccountAndProfile { result in
            switch result {
            case .success:
                // Profile will become nil, isLoggedIn will update as needed, RootSwitcherView will show login/splash
                DispatchQueue.main.async {
                    authViewModel.isLoggedIn = false
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    errorMessage = error.localizedDescription
                    showErrorAlert = true
                }
            }
        }
    }
}

