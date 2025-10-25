//
//  LoginView.swift
//  TaskMutual
//
//  Created by Romir Bulbule on 9/22/25.
//

import SwiftUI
import FirebaseAuth

struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    var onEmailVerificationNeeded: () -> Void
    
    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var showSignUp = false
    @State private var showForgotPassword = false

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()
            
            VStack(spacing: 24) {
                Spacer()
                
                Image("AppLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                    .clipShape(RoundedRectangle(cornerRadius: 28))
                    .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
                
                Text("Welcome")
                    .font(.largeTitle)
                    .foregroundColor(.white)
                
                VStack(spacing: 12) {
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
                        .onSubmit { handleLogin() }
                }
                .padding(.horizontal, 10)
                
                if let error = authViewModel.authError, !error.isEmpty {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.subheadline)
                        .frame(maxWidth: .infinity)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                Button(action: handleLogin) {
                    if isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Theme.accent)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    } else {
                        Text("Login")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Theme.accent)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .disabled(email.isEmpty || password.isEmpty)
                .padding(.horizontal)
                
                Button("Forgot Password?") {
                    showForgotPassword = true
                }
                .foregroundColor(.white.opacity(0.85))
                
                Button("Don't have an account? Sign Up") {
                    showSignUp = true
                }
                .foregroundColor(.white.opacity(0.85))
                
                Spacer()
            }
        }
        .sheet(isPresented: $showSignUp) {
            SignUpView(onEmailVerificationNeeded: onEmailVerificationNeeded)
                .environmentObject(authViewModel)
        }
        .sheet(isPresented: $showForgotPassword) {
            ForgotPasswordView()
                .environmentObject(authViewModel)
        }
    }
    
    private func handleLogin() {
        isLoading = true
        authViewModel.signIn(email: email, password: password) { success in
            isLoading = false
            if success {
                authViewModel.isNewUser = false
            }
        }
    }
}








