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
    @State private var showSignUp = false

    var body: some View {
        VStack(spacing: 16) {
            Text(showSignUp ? "Sign Up" : "Login")
                .font(.largeTitle)

            TextField("Email", text: $email)
                .autocapitalization(.none)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.emailAddress)

            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            if let error = authViewModel.authError {
                Text(error).foregroundColor(.red).multilineTextAlignment(.center)
            }

            Button(showSignUp ? "Sign Up" : "Login") {
                if showSignUp {
                    authViewModel.signUp(email: email, password: password)
                } else {
                    authViewModel.signIn(email: email, password: password)
                }
            }
            .padding(.top)

            Button(showSignUp ? "Already have an account? Login" : "Don't have an account? Sign Up") {
                showSignUp.toggle()
                authViewModel.authError = nil
            }
            .font(.footnote)
            .foregroundColor(.blue)
        }
        .padding()
    }
}



















