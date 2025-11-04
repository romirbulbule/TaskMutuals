//
//  AuthViewModel.swift
//  TaskMutual
//
//  Created by Romir Bulbule on 9/22/25.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

class AuthViewModel: ObservableObject {
    @Published var currentUser: User? = nil
    @Published var isNewUser: Bool = false
    @Published var authError: String?
    private var handle: AuthStateDidChangeListenerHandle?
    private let db = Firestore.firestore()
    
    var isLoggedIn: Bool {
        return currentUser != nil && currentUser?.isEmailVerified == true
    }

    init() {
        handle = Auth.auth().addStateDidChangeListener { [weak self] (auth: Auth, user: User?) in
            DispatchQueue.main.async {
                self?.currentUser = user
            }
        }
    }

    deinit {
        if let handle = handle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }

    // MARK: - Sign Up
    func signUp(email: String, password: String, completion: @escaping (Bool) -> Void) {
        authError = nil
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.authError = self?.userFriendlyError(for: error.localizedDescription)
                    completion(false)
                } else {
                    self?.sendVerificationEmail()
                    self?.isNewUser = true
                    completion(true)
                }
            }
        }
    }

    func sendVerificationEmail() {
        // Configure action code settings for better email links
        let actionCodeSettings = ActionCodeSettings()
        actionCodeSettings.handleCodeInApp = false // Open in browser, not app

        // This makes the link more iOS-friendly and clickable
        // You can customize this URL to your own domain if you have one
        // For now, Firebase will use the default but with better formatting
        actionCodeSettings.setIOSBundleID(Bundle.main.bundleIdentifier ?? "com.taskmutual.app")

        Auth.auth().currentUser?.sendEmailVerification(with: actionCodeSettings) { [weak self] error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.authError = self?.userFriendlyError(for: error.localizedDescription)
                }
            }
        }
    }

    // MARK: - Sign In
    func signIn(email: String, password: String, completion: @escaping (Bool) -> Void) {
        authError = nil
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                if let error = error {
                    self.authError = self.userFriendlyError(for: error.localizedDescription)
                    completion(false)
                } else if let user = Auth.auth().currentUser {
                    user.reload { reloadError in
                        if user.isEmailVerified {
                            self.db.collection("users").document(user.uid).getDocument { snapshot, _ in
                                DispatchQueue.main.async {
                                    self.isNewUser = !(snapshot?.exists ?? false)
                                    completion(true)
                                }
                            }
                        } else {
                            self.authError = "Please verify your email before logging in."
                            try? Auth.auth().signOut()
                            completion(false)
                        }
                    }
                }
            }
        }
    }

    func sendPasswordReset(email: String, completion: @escaping (Bool, String?) -> Void) {
        // Configure action code settings for better email links
        let actionCodeSettings = ActionCodeSettings()
        actionCodeSettings.handleCodeInApp = false // Open in browser, not app
        actionCodeSettings.setIOSBundleID(Bundle.main.bundleIdentifier ?? "com.taskmutual.app")

        Auth.auth().sendPasswordReset(withEmail: email, actionCodeSettings: actionCodeSettings) { error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(false, self.userFriendlyError(for: error.localizedDescription))
                } else {
                    completion(true, nil)
                }
            }
        }
    }

    func signOut() {
        do {
            try Auth.auth().signOut()
            self.currentUser = nil
            self.isNewUser = false
        } catch {
            print("Error signing out: \(error)")
            self.authError = "Failed to sign out. Please try again."
        }
    }

    // MARK: - POWERFUL DELETE: Requires password for security!
    // Deletes ALL user data: profile, tasks, chats, messages, responses, storage, and auth account
    func deleteAccountAndAllData(userVM: UserViewModel, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
        // Use the comprehensive deletion from UserViewModel
        userVM.deleteAccountAndAllData(password: password) { [weak self] result in
            switch result {
            case .success:
                DispatchQueue.main.async {
                    self?.currentUser = nil
                    self?.isNewUser = false
                }
                // Sign out locally
                do { try Auth.auth().signOut() } catch {}
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    // MARK: - Friendly error message
    private func userFriendlyError(for code: String) -> String {
        if code.contains("malformed") || code.contains("expired") || code.contains("invalid") {
            return "Your email or password is incorrect, or your account does not exist."
        } else if code.contains("email") && code.contains("badly formatted") {
            return "That email address is invalid."
        } else if code.contains("network") {
            return "Network error. Please try again."
        } else if code.contains("verify your email") {
            return "Please check your inbox and verify your email before logging in."
        } else if code.contains("password is invalid") || code.contains("wrong-password") {
            return "Incorrect password. Please try again."
        } else if code.contains("user-not-found") {
            return "No account exists for this email."
        } else if code.contains("too-many requests") {
            return "Too many attempts. Please wait and try again."
        }
        return code
    }
}

