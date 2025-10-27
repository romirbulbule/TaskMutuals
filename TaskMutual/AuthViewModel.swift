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
        Auth.auth().currentUser?.sendEmailVerification { [weak self] error in
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
        Auth.auth().sendPasswordReset(withEmail: email) { error in
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
    func deleteAccountAndAllData(userVM: UserViewModel, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let user = Auth.auth().currentUser,
              let email = user.email else {
            completion(.failure(NSError(domain: "No user found", code: 0)))
            return
        }

        // 0: Re-authenticate
        let credential = EmailAuthProvider.credential(withEmail: email, password: password)
        user.reauthenticate(with: credential) { [weak self] _, reauthError in
            if let reauthError = reauthError {
                completion(.failure(reauthError))
                return
            }
            guard let self = self else { return }
            let uid = user.uid

            // 1: Fetch username
            self.db.collection("users").document(uid).getDocument { document, _ in
                guard let document = document,
                      let userData = document.data(),
                      let username = userData["username"] as? String else {
                    completion(.failure(NSError(domain: "User doc not found", code: 0)))
                    return
                }
                let batch = self.db.batch()
                // 2: Delete user doc and username mapping
                batch.deleteDocument(self.db.collection("users").document(uid))
                batch.deleteDocument(self.db.collection("usernames").document(username.lowercased()))
                // ... add other batch deletions for user-owned data as needed

                // 3: Commit batch deletion
                batch.commit { batchError in
                    if let batchError = batchError {
                        completion(.failure(batchError))
                        return
                    }
                    // 4: Delete Firebase Auth account
                    user.delete { deleteError in
                        if let deleteError = deleteError {
                            completion(.failure(deleteError))
                        } else {
                            DispatchQueue.main.async {
                                userVM.clearProfile()
                                self.currentUser = nil
                                self.isNewUser = false
                            }
                            // 5: Sign out locally
                            do { try Auth.auth().signOut() } catch {}
                            completion(.success(()))
                        }
                    }
                }
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

