//
//  ProfileSetupView.swift
//  TaskMutual
//
//  Created by Romir Bulbule on 10/24/25.
//


import SwiftUI

struct ProfileSetupView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var userVM: UserViewModel
    
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var username = ""
    @State private var dateOfBirth = Date()
    @State private var errorMessage = ""
    @State private var isLoading = false
    
    // Calculate 13 years ago for minimum age
    private var maximumDate: Date {
        Calendar.current.date(byAdding: .year, value: -13, to: Date()) ?? Date()
    }
    
    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    Text("Complete Your Profile")
                        .font(.largeTitle)
                        .foregroundColor(.white)
                        .padding(.top, 40)
                    
                    VStack(spacing: 16) {
                        TextField("First Name", text: $firstName)
                            .padding()
                            .background(Color.white.opacity(0.33))
                            .foregroundColor(.black)
                            .font(.system(size: 18, weight: .medium))
                            .cornerRadius(10)
                        
                        TextField("Last Name", text: $lastName)
                            .padding()
                            .background(Color.white.opacity(0.33))
                            .foregroundColor(.black)
                            .font(.system(size: 18, weight: .medium))
                            .cornerRadius(10)
                        
                        DatePicker("Date of Birth", selection: $dateOfBirth, in: ...maximumDate, displayedComponents: .date)
                            .padding()
                            .background(Color.white.opacity(0.33))
                            .foregroundColor(.black)
                            .font(.system(size: 18, weight: .medium))
                            .cornerRadius(10)
                            .colorScheme(.light)
                        
                        TextField("Username", text: $username)
                            .autocapitalization(.none)
                            .padding()
                            .background(Color.white.opacity(0.33))
                            .foregroundColor(.black)
                            .font(.system(size: 18, weight: .medium))
                            .cornerRadius(10)
                    }
                    .padding(.horizontal, 30)
                    
                    if !errorMessage.isEmpty {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.subheadline)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                    }
                    
                    Button(action: handleProfileCreation) {
                        if isLoading {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Theme.accent)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        } else {
                            Text("Create Profile")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Theme.accent)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                   // .disabled(firstName.isEmpty || lastName.isEmpty || username.isEmpty || isLoading)
                    .padding(.horizontal, 30)
                }
            }
        }
    }
    
    private func handleProfileCreation() {
        guard !firstName.isEmpty, !lastName.isEmpty, !username.isEmpty else {
            errorMessage = "All fields are required."
            return
        }
        errorMessage = ""
        isLoading = true
        
        print("🟢 Starting profile creation for username: \(username)")
        
        userVM.createOrUpdateProfile(
            firstName: firstName,
            lastName: lastName,
            username: username,
            dateOfBirth: dateOfBirth
        ) { result in
            isLoading = false
            print("🔵 Profile creation callback received")
            switch result {
            case .success:
                print("✅ SUCCESS - Profile created!")
                // userVM.fetchUserProfile() // REMOVE THIS LINE
                authViewModel.isNewUser = false
            case .failure(let err):
                print("❌ FAILURE - Error: \(err.localizedDescription)")
                errorMessage = err.localizedDescription
            }
        }
    }
}
