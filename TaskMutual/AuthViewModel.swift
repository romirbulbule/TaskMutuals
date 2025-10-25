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
    
    // Computed property that updates when currentUser OR isNewUser changes
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

    // MARK: - Sign Up with Email Verification
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

    // MARK: - Sign In with Email Verification Check
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
                            // ✅ Check if user has a profile in Firestore
                            self.db.collection("users").document(user.uid).getDocument { snapshot, error in
                                DispatchQueue.main.async {
                                    if let snapshot = snapshot, snapshot.exists {
                                        // Profile exists - existing user logging back in
                                        self.isNewUser = false
                                    } else {
                                        // No profile - new user needs to complete profile
                                        self.isNewUser = true
                                    }
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

    // MARK: - Password Reset (Only for verified users)
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

    // MARK: - Sign Out
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

    // MARK: - Delete Account + All User Data
    func deleteAccountAndAllData(userVM: UserViewModel, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let user = Auth.auth().currentUser else {
            completion(.failure(NSError(domain: "No user found", code: 0)))
            return
        }
        let uid = user.uid

        // Step 1: Get user data (username)
        db.collection("users").document(uid).getDocument { [weak self] document, error in
            guard let self = self,
                  let document = document,
                  let userData = document.data(),
                  let username = userData["username"] as? String else {
                completion(.failure(NSError(domain: "User doc not found", code: 0)))
                return
            }

            let batch = self.db.batch()

            // Step 2: Delete user doc
            let userRef = self.db.collection("users").document(uid)
            batch.deleteDocument(userRef)

            // Step 3: Delete username mapping
            let usernameRef = self.db.collection("usernames").document(username.lowercased())
            batch.deleteDocument(usernameRef)

            // Step 4: Delete all user's tasks
            self.db.collection("tasks").whereField("creatorUserId", isEqualTo: uid).getDocuments { snapshot, _ in
                snapshot?.documents.forEach { doc in
                    batch.deleteDocument(doc.reference)
                }

                // Step 5: Remove user's responses from ALL tasks
                self.db.collection("tasks").getDocuments { snapshot, _ in
                    guard let snapshot = snapshot else {
                        // If no tasks, skip to commit
                        self.commitBatchAndDeleteAuth(batch: batch, user: user, userVM: userVM, completion: completion)
                        return
                    }
                    
                    // For each task, filter out responses from the deleted user
                    for document in snapshot.documents {
                        guard var taskData = document.data() as? [String: Any],
                              let responses = taskData["responses"] as? [[String: Any]] else {
                            continue
                        }
                        
                        // Filter out responses from the deleted user
                        let filteredResponses = responses.filter { response in
                            guard let fromUserId = response["fromUserId"] as? String else { return true }
                            return fromUserId != uid
                        }
                        
                        // Only update if responses changed
                        if filteredResponses.count != responses.count {
                            batch.updateData(["responses": filteredResponses], forDocument: document.reference)
                        }
                    }
                    
                    // Step 6: Commit batch and delete auth
                    self.commitBatchAndDeleteAuth(batch: batch, user: user, userVM: userVM, completion: completion)
                }
            }
        }
    }
    
    // MARK: - Helper: Commit Batch and Delete Auth
    private func commitBatchAndDeleteAuth(batch: WriteBatch, user: User, userVM: UserViewModel, completion: @escaping (Result<Void, Error>) -> Void) {
        batch.commit { batchError in
            if let batchError = batchError {
                completion(.failure(batchError))
                return
            }

            // Delete Firebase Auth account
            user.delete { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    DispatchQueue.main.async {
                        userVM.clearProfile()
                        self.currentUser = nil
                        self.isNewUser = false
                    }
                    completion(.success(()))
                }
            }
        }
    }

    // MARK: - User-Friendly Error Messages
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
