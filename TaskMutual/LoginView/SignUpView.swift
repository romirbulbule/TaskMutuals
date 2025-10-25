//
//  SignUpView.swift
//  TaskMutual
//
//  Created by Romir Bulbule on 10/24/25.
//


import SwiftUI

struct SignUpView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.presentationMode) var presentationMode
    var onEmailVerificationNeeded: () -> Void
    
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var error = ""
    @State private var isLoading = false

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()
            
            VStack(spacing: 28) {
                Text("Create Account")
                    .font(.largeTitle)
                    .foregroundColor(.white)
                    .padding(.top, 40)
                
                VStack(spacing: 16) {
                    TextField("Email", text: $email)
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)
                        .padding()
                        .background(Color.white.opacity(0.33))
                        .foregroundColor(.black)
                        .font(.system(size: 18, weight: .medium))
                        .cornerRadius(10)
                    
                    SecureField("Password", text: $password)
                        .padding()
                        .background(Color.white.opacity(0.33))
                        .foregroundColor(.black)
                        .font(.system(size: 18, weight: .medium))
                        .cornerRadius(10)
                    
                    SecureField("Confirm Password", text: $confirmPassword)
                        .padding()
                        .background(Color.white.opacity(0.33))
                        .foregroundColor(.black)
                        .font(.system(size: 18, weight: .medium))
                        .cornerRadius(10)
                }
                .padding(.horizontal, 30)

                if !error.isEmpty {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.subheadline)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                }

                Button(action: handleSignUp) {
                    if isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Theme.accent)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    } else {
                        Text("Sign Up")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Theme.accent)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .disabled(email.isEmpty || password.isEmpty || confirmPassword.isEmpty)
                .padding(.horizontal, 30)

                Spacer()
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(.white)
            }
        }
    }

    private func handleSignUp() {
        guard password == confirmPassword else {
            error = "Passwords do not match"
            return
        }
        guard password.count >= 6 else {
            error = "Password must be at least 6 characters"
            return
        }
        error = ""
        isLoading = true
        authViewModel.signUp(email: email, password: password) { success in
            isLoading = false
            if success {
                presentationMode.wrappedValue.dismiss()
                onEmailVerificationNeeded()
            } else if let authError = authViewModel.authError {
                error = authError
            }
        }
    }
}
