//
//  LoginView.swift
//  TaskMutual
//
//  Created by Romir Bulbule on 9/22/25.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var confirmError = ""
    @State private var showSignUp = false

    var body: some View {
        VStack(spacing: 24) {
            Image("AppLogo")
                .resizable()
                .scaledToFit()
                .frame(width: 120, height: 120)
                .clipShape(RoundedRectangle(cornerRadius: 28))
                .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
                .padding(.bottom, 8)
            Text(showSignUp ? "Sign Up" : "Login")
                .font(.largeTitle)
                .foregroundColor(.white)

            VStack(spacing: 12) {
                TextField("Email", text: $email)
                    .padding()
                    .background(Color.white.opacity(0.33))
                    .foregroundColor(.black)
                    .font(.system(size: 18, weight: .medium))
                    .cornerRadius(10)
                    .submitLabel(.next)

                SecureField("Password", text: $password)
                    .padding()
                    .background(Color.white.opacity(0.33))
                    .foregroundColor(.black)
                    .font(.system(size: 18, weight: .medium))
                    .cornerRadius(10)
                    .submitLabel(showSignUp ? .next : .go)
                    .onSubmit {
                        if !showSignUp {
                            authViewModel.signIn(email: email, password: password)
                        }
                    }

                if showSignUp {
                    SecureField("Confirm Password", text: $confirmPassword)
                        .padding()
                        .background(Color.white.opacity(0.33))
                        .foregroundColor(.black)
                        .font(.system(size: 18, weight: .medium))
                        .cornerRadius(10)
                        .submitLabel(.go)
                        .onSubmit {
                            handleSignUpOrLogin()
                        }

                    if !confirmError.isEmpty {
                        Text(confirmError)
                            .foregroundColor(.red)
                            .font(.subheadline)
                            .frame(maxWidth: .infinity)
                            .multilineTextAlignment(.center)
                            .padding(.top, 6)
                    }
                }

                if let error = authViewModel.authError, !error.isEmpty {
                    Text("The Username or Password is incorrect. Please try again.")
                        .foregroundColor(.red)
                        .font(.subheadline)
                        .frame(maxWidth: .infinity)
                        .multilineTextAlignment(.center)
                        .padding(.top, 6)
                }
            }
            .padding(.horizontal, 10)

            Button(action: handleSignUpOrLogin) {
                Text(showSignUp ? "Sign Up" : "Login")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Theme.accent)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.top)

            Button(action: {
                showSignUp.toggle()
                authViewModel.authError = nil
                confirmError = ""
            }) {
                Text(showSignUp ? "Already have an account? Login" : "Don't have an account? Sign Up")
                    .font(.subheadline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .foregroundColor(.white.opacity(0.85))
            }

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.background.ignoresSafeArea())
    }

    private func handleSignUpOrLogin() {
        confirmError = ""
        if showSignUp {
            guard password == confirmPassword else {
                confirmError = "Passwords do not match."
                return
            }
            authViewModel.signUp(email: email, password: password)
        } else {
            authViewModel.signIn(email: email, password: password)
        }
    }
}








