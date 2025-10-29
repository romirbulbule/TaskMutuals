//
//  EmailVerificationWaitingView.swift
//  TaskMutual
//
//  Created by Romir Bulbule on 10/24/25.
//


import SwiftUI
import FirebaseAuth

struct EmailVerificationWaitingView: View {
    var onVerified: () -> Void
    var onCancel: () -> Void
    
    @State private var isChecking = false
    @State private var errorMessage = ""

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()
            
            VStack(spacing: 28) {
                Image(systemName: "envelope.badge")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .foregroundColor(Theme.accent)
                
                Text("Verify Your Email")
                    .font(.largeTitle)
                    .foregroundColor(.white)
                
                Text("We've sent a verification link to your email. Please click the link to verify your account.")
                    .foregroundColor(.white.opacity(0.85))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)
                
                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.subheadline)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                }
                
                Button(action: checkVerification) {
                    if isChecking {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Theme.accent)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    } else {
                        Text("I've Verified My Email")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Theme.accent)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .padding(.horizontal, 30)
                
                Button("Resend Verification Email") {
                    resendVerificationEmail()
                }
                .foregroundColor(.white.opacity(0.85))
                
                Button("Cancel") {
                    onCancel()
                }
                .foregroundColor(.white.opacity(0.85))
                
                Spacer()
            }
            .padding(.top, 60)
        }
    }
    
    private func checkVerification() {
        errorMessage = ""
        isChecking = true
        
        Auth.auth().currentUser?.reload { error in
            isChecking = false
            
            if let error = error {
                errorMessage = "Failed to check verification status. Please try again."
                print("Reload error: \(error.localizedDescription)")
                return
            }
            
            if let user = Auth.auth().currentUser, user.isEmailVerified {
                // Email is verified - proceed to profile setup
                onVerified()
            } else {
                // Email is NOT verified - show error
                errorMessage = "Please verify your email before proceeding to the next step."
            }
        }
    }
    
    private func resendVerificationEmail() {
        Auth.auth().currentUser?.sendEmailVerification { error in
            if let error = error {
                errorMessage = "Failed to resend email. Please try again."
                print("Resend error: \(error.localizedDescription)")
            } else {
                errorMessage = "Verification email sent! Please check your inbox."
            }
        }
    }
}
