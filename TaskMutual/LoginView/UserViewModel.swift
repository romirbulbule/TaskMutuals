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
    @Published var isLoadingProfile: Bool = false
    
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
        
        usernamesRef.document(lowercaseUsername).getDocument { document, error in
            if let error = error {
                completion(.failure(.message(error.localizedDescription)))
                return
            }
            if let document = document, document.exists,
               let existingUID = document.data()?["uid"] as? String,
               existingUID != userID {
                completion(.failure(.message("That Username already exists. Please use another one.")))
                return
            }
            let profile = UserProfile(
                id: userID,
                firstName: firstName,
                lastName: lastName,
                username: username,
                dateOfBirth: dateOfBirth
            )
            let batch = self.db.batch()
            let userRef = usersRef.document(userID)
            do {
                let userData = try Firestore.Encoder().encode(profile)
                batch.setData(userData, forDocument: userRef)
            } catch {
                completion(.failure(.message(error.localizedDescription)))
                return
            }
            let usernameRef = usernamesRef.document(lowercaseUsername)
            batch.setData(["uid": userID, "username": username], forDocument: usernameRef)
            batch.commit { error in
                if let error = error {
                    completion(.failure(.message(error.localizedDescription)))
                } else {
                    let createdProfile = profile
                    UserDefaults.standard.set(username, forKey: "username")
                    DispatchQueue.main.async {
                        self.profile = createdProfile
                    }
                    completion(.success(()))
                }
            }
        }
    }
    
    // MARK: - Fetch User Profile (with debug logs/timing)
    func fetchUserProfile() {
        print("DEBUG: currentUser: \(String(describing: auth.currentUser)), uid: \(String(describing: auth.currentUser?.uid))")
        guard let userId = auth.currentUser?.uid else {
            DispatchQueue.main.async {
                self.profile = nil
                self.isLoadingProfile = false
            }
            return
        }

        self.isLoadingProfile = true
        let start = Date()
        db.collection("users").document(userId).getDocument { [weak self] snapshot, error in
            let elapsed = Date().timeIntervalSince(start)
            print("Profile loaded in \(elapsed) seconds")
            guard let self = self else { return }
            defer { DispatchQueue.main.async { self.isLoadingProfile = false } }
            if let error = error {
                print("Error fetching profile: \(error)")
                DispatchQueue.main.async {
                    self.profile = nil
                }
                return
            }
            guard let snapshot = snapshot, snapshot.exists else {
                print("No profile found for user \(userId)")
                DispatchQueue.main.async {
                    self.profile = nil
                }
                return
            }
            do {
                let loadedProfile = try snapshot.data(as: UserProfile.self)
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

    func clearProfile() {
        self.profile = nil
        self.isLoadingProfile = false
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
