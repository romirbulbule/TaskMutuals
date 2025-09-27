//
//  AuthViewModel.swift
//  TaskMutual
//
//  Created by Romir Bulbule on 9/22/25.
//

import SwiftUI
import FirebaseAuth

class AuthViewModel: ObservableObject {
    @Published var user: User? = nil
    @Published var authError: String? = nil

    // Automatically listen for changes in auth state
    init() {
        self.user = Auth.auth().currentUser
        Auth.auth().addStateDidChangeListener { _, user in
            self.user = user
        }
    }

    // Sign In method
    func signIn(email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            DispatchQueue.main.async {
                if let error = error as NSError? {
                    self?.authError = self?.errorDescription(error)
                }
            }
        }
    }

    // Sign Up method
    func signUp(email: String, password: String) {
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            DispatchQueue.main.async {
                if let error = error as NSError? {
                    self?.authError = self?.errorDescription(error)
                }
            }
        }
    }

    // SIGN OUT - the member function you need
    func signOut() {
        do {
            try Auth.auth().signOut()
            self.user = nil
        } catch {
            self.authError = error.localizedDescription
        }
    }

    // User-friendly error messages
    private func errorDescription(_ error: NSError) -> String {
        guard let code = AuthErrorCode(rawValue: error.code) else {
            return error.localizedDescription
        }
        switch code {
        case .wrongPassword:
            return "The password you entered is incorrect."
        case .invalidEmail:
            return "The email address is invalid."
        case .userNotFound:
            return "No account found with that email."
        case .emailAlreadyInUse:
            return "This email is already in use."
        case .weakPassword:
            return "Your password is too weak. Please use at least 6 characters."
        case .missingEmail:
            return "Please enter your email."
        case .networkError:
            return "A network error occurred. Please try again."
        default:
            return "An error occurred. Please double-check your info and try again."
        }
    }
}

