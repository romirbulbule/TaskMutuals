//
//  ForgotPasswordView.swift
//  TaskMutual
//
//  Created by Romir Bulbule on 10/24/25.
//


import SwiftUI

struct ForgotPasswordView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.presentationMode) var presentationMode
    
    @State private var email = ""
    @State private var message = ""
    @State private var isSuccess = false
    @State private var isLoading = false

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()
            
            VStack(spacing: 28) {
                Text("Reset Password")
                    .font(.largeTitle)
                    .foregroundColor(.white)
                    .padding(.top, 40)
                
                Text("Enter your email address and we'll send you a link to reset your password.")
                    .foregroundColor(.white.opacity(0.85))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)
                
                TextField("Email", text: $email)
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)
                    .padding()
                    .background(Color.white.opacity(0.33))
                    .foregroundColor(.black)
                    .font(.system(size: 18, weight: .medium))
                    .cornerRadius(10)
                    .padding(.horizontal, 30)

                if !message.isEmpty {
                    Text(message)
                        .foregroundColor(isSuccess ? .green : .red)
                        .font(.subheadline)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                }

                Button(action: handlePasswordReset) {
                    if isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Theme.accent)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    } else {
                        Text("Send Reset Link")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Theme.accent)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .disabled(email.isEmpty)
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

    private func handlePasswordReset() {
        isLoading = true
        authViewModel.sendPasswordReset(email: email) { success, error in
            isLoading = false
            if success {
                message = "Password reset link sent! Check your email."
                isSuccess = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    presentationMode.wrappedValue.dismiss()
                }
            } else {
                message = error ?? "Failed to send reset link."
                isSuccess = false
            }
        }
    }
}
