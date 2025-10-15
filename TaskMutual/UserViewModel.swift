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
    
    func createOrUpdateProfile(
        firstName: String,
        lastName: String,
        username: String,
        completion: @escaping (Result<Void, UserVMError>) -> Void
    ) {
        guard let userID = auth.currentUser?.uid else {
            completion(.failure(.message("Not logged in")))
            return
        }
        let usersRef = db.collection("users")
        usersRef.whereField("username", isEqualTo: username.lowercased())
            .getDocuments { snap, error in
                if let error = error {
                    completion(.failure(.message(error.localizedDescription)))
                    return
                }
                if let snap = snap, !snap.documents.isEmpty,
                   !(snap.documents.count == 1 && snap.documents.first?.documentID == userID) {
                    completion(.failure(.message("Username already taken")))
                    return
                }
                let profile = UserProfile(id: userID, firstName: firstName, lastName: lastName, username: username)
                do {
                    try usersRef.document(userID).setData(from: profile) { error in
                        if let error = error {
                            completion(.failure(.message(error.localizedDescription)))
                        } else {
                            self.profile = profile
                            completion(.success(()))
                        }
                    }
                } catch {
                    completion(.failure(.message(error.localizedDescription)))
                }
            }
    }
    
    func fetchUserProfile() {
        guard let userID = auth.currentUser?.uid else {
            self.profile = nil
            return
        }
        db.collection("users").document(userID).getDocument { doc, error in
            if let doc = doc, doc.exists, let profile = try? doc.data(as: UserProfile.self) {
                self.profile = profile
            } else {
                self.profile = nil
            }
        }
    }
    
    func clearProfile() { self.profile = nil }
    
    // Fully updated function: deletes user, username, and auth
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
                    print("Firestore batch error: \(batchError)")
                    completion(.failure(batchError))
                    return
                }
                
                // Remove Firebase Auth account
                Auth.auth().currentUser?.delete { error in
                    if let error = error {
                        print("Auth deletion error: \(error)")
                        completion(.failure(error))
                    } else {
                        print("All user data deleted successfully.")
                        DispatchQueue.main.async { self.profile = nil }
                        completion(.success(()))
                    }
                }
            }
        }
    }
}

