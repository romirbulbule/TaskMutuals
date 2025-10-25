//
//  UserViewModel.swift
//  TaskMutual
//
//  Created by Romir Bulbule on 10/4/25.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

enum UserVMError: Error {
    case message(String)
}

extension UserVMError: LocalizedError {
    var errorDescription: String? {
        switch self { case .message(let text): return text }
    }
}

class UserViewModel: ObservableObject {
    @Published var profile: UserProfile?
    private let db = Firestore.firestore()
    private let auth = Auth.auth()
    
    // MARK: - Create/Update Profile
    func createOrUpdateProfile(
        firstName: String,
        lastName: String,
        username: String,
        dateOfBirth: Date,
        completion: @escaping (Result<Void, UserVMError>) -> Void
    ) {
        guard let userID = auth.currentUser?.uid else {
            completion(.failure(.message("Not logged in")))
            return
        }
        
        let lowercaseUsername = username.lowercased()
        let usersRef = db.collection("users")
        let usernamesRef = db.collection("usernames")
        
        // Check if username is already taken
        usernamesRef.document(lowercaseUsername).getDocument { document, error in
            if let error = error {
                completion(.failure(.message(error.localizedDescription)))
                return
            }
            
            // If username doc exists and belongs to someone else, it's taken
            if let document = document, document.exists,
               let existingUID = document.data()?["uid"] as? String,
               existingUID != userID {
                completion(.failure(.message("That Username already exists. Please use another one.")))
                return
            }
            
            // Create the profile
            let profile = UserProfile(
                id: userID,
                firstName: firstName,
                lastName: lastName,
                username: username,
                dateOfBirth: dateOfBirth
            )
            
            // Use a batch write to ensure atomicity
            let batch = self.db.batch()
            
            // Write to users collection
            let userRef = usersRef.document(userID)
            do {
                let userData = try Firestore.Encoder().encode(profile)
                batch.setData(userData, forDocument: userRef)
            } catch {
                completion(.failure(.message(error.localizedDescription)))
                return
            }
            
            // Reserve the username
            let usernameRef = usernamesRef.document(lowercaseUsername)
            batch.setData(["uid": userID, "username": username], forDocument: usernameRef)
            
            // Commit the batch
            // Commit the batch
            batch.commit { error in
                if let error = error {
                    completion(.failure(.message(error.localizedDescription)))
                } else {
                    // Capture profile before dispatch
                    let createdProfile = profile
                    
                    // ✅ SAVE USERNAME TO USERDEFAULTS
                    UserDefaults.standard.set(username, forKey: "username")
                    
                    // Update on main thread to trigger SwiftUI
                    DispatchQueue.main.async {
                        self.profile = createdProfile
                    }
                    completion(.success(()))
                }
            }
        }
    }
    
    // MARK: - Fetch User Profile
    func fetchUserProfile() {
        guard let userId = auth.currentUser?.uid else {
            DispatchQueue.main.async {
                self.profile = nil
            }
            return
        }
        
        DispatchQueue.main.async {
            print("🔍 RootSwitcher - isLoggedIn: \(self.auth.currentUser != nil), profile: \(self.profile?.username ?? "nil")")
        }
        
        db.collection("users").document(userId).getDocument { [weak self] snapshot, error in
            guard let self = self else { return }
            
            if let error = error {
                print("Error fetching profile: \(error)")
                DispatchQueue.main.async {
                    self.profile = nil
                }
                return
            }
            
            guard let snapshot = snapshot, snapshot.exists else {
                DispatchQueue.main.async {
                    self.profile = nil
                }
                return
            }
            
            do {
                let loadedProfile = try snapshot.data(as: UserProfile.self)
                
                // ✅ ADD THIS LINE - Save username to UserDefaults when loading profile
                UserDefaults.standard.set(loadedProfile.username, forKey: "username")
                
                DispatchQueue.main.async {
                    self.profile = loadedProfile
                }
            } catch {
                print("Error decoding profile: \(error)")
                DispatchQueue.main.async {
                    self.profile = nil
                }
            }
        }
    }

    
    // MARK: - Clear Profile
    func clearProfile() {
        self.profile = nil
    }
    
    // MARK: - Delete Account
    func deleteAccountAndProfile(completion: @escaping (Result<Void, Error>) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion(.failure(NSError(domain: "No user", code: 0)))
            return
        }
        
        db.collection("users").document(uid).getDocument { document, error in
            guard let document = document,
                  let userData = document.data(),
                  let username = userData["username"] as? String else {
                completion(.failure(NSError(domain: "Username not found", code: 0)))
                return
            }
            
            let batch = self.db.batch()
            let userRef = self.db.collection("users").document(uid)
            let usernameRef = self.db.collection("usernames").document(username.lowercased())
            batch.deleteDocument(userRef)
            batch.deleteDocument(usernameRef)
            
            batch.commit { batchError in
                if let batchError = batchError {
                    completion(.failure(batchError))
                    return
                }
                
                Auth.auth().currentUser?.delete { error in
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        DispatchQueue.main.async {
                            self.profile = nil
                        }
                        completion(.success(()))
                    }
                }
            }
        }
    }
}
