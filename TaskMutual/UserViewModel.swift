//
//  UserViewModel.swift
//  TaskMutual
//
//  Created by Romir Bulbule on 10/4/25.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage
import UIKit

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
    
    // For chat user search:
    @Published var searchText: String = ""
    @Published var allUsers: [UserProfile] = []
    
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
            var bioValue = self.profile?.bio ?? ""
            if let newBio = self.profile?.bio { bioValue = newBio }
            
            let profile = UserProfile(
                id: userID,
                firstName: firstName,
                lastName: lastName,
                username: username,
                dateOfBirth: dateOfBirth,
                bio: bioValue, // If your UserProfile includes bio in its Codable
                profileImageURL: self.profile?.profileImageURL // Keep avatar if editing
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
    
    // MARK: - Edit Profile (for name, username, bio in-app editing)
    func updateProfile(name: String, username: String, bio: String, completion: (() -> Void)? = nil) {
        guard let profile = self.profile else { completion?(); return }
        var firstName = ""
        var lastName = ""
        let parts = name.split(separator: " ")
        if !parts.isEmpty {
            firstName = String(parts[0])
            if parts.count > 1 {
                lastName = parts[1...].joined(separator: " ")
            }
        }
        let dateOfBirth = profile.dateOfBirth
        
        // This will trigger your username collision logic
        createOrUpdateProfile(
            firstName: firstName,
            lastName: lastName,
            username: username,
            dateOfBirth: dateOfBirth
        ) { result in
            // Always update the local bio value and Firestore, even if other data failed
            DispatchQueue.main.async {
                self.profile?.firstName = firstName
                self.profile?.lastName = lastName
                self.profile?.username = username
                self.profile?.bio = bio
            }
            if let userId = profile.id {
                self.db.collection("users").document(userId).updateData(["bio": bio]) { _ in
                    completion?()
                }
            } else {
                completion?()
            }
        }
    }
    
    func updateBio(_ bio: String, completion: @escaping () -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        db.collection("users").document(userId).updateData([
            "bio": bio
        ]) { error in
            if error == nil {
                // Update local copy if needed
                DispatchQueue.main.async {
                    self.profile?.bio = bio
                }
            }
            completion()
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
    
    // ==== ADDED FOR CHAT SEARCH ===========
    /// Fetch all users except the logged-in user, for chat/search
    func fetchAllUsers() {
        guard let currentUserID = auth.currentUser?.uid else { return }
        db.collection("users").getDocuments { [weak self] snapshot, error in
            guard let documents = snapshot?.documents else { return }
            DispatchQueue.main.async {
                self?.allUsers = documents.compactMap { doc in
                    let user = try? doc.data(as: UserProfile.self)
                    return (user?.id == currentUserID) ? nil : user
                }
            }
        }
    }
    
    /// Returns filtered user list for search UI
    var filteredUsers: [UserProfile] {
        if searchText.isEmpty {
            return allUsers
        } else {
            return allUsers.filter { $0.username.lowercased().contains(searchText.lowercased()) }
        }
    }
    
    // Upload profile image
    func uploadProfileImage(_ image: UIImage, completion: @escaping (Result<String, Error>) -> Void) {
        guard let currentUser = Auth.auth().currentUser else {
            completion(.failure(NSError(domain: "AuthError", code: 0, userInfo: [NSLocalizedDescriptionKey: "No authenticated user"])))
            return
        }
        
        // Convert image to data
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            completion(.failure(NSError(domain: "ImageError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not convert image to data"])))
            return
        }
        
        // Create storage reference
        let storage = Storage.storage()
        let storageRef = storage.reference()
        let profileImageRef = storageRef.child("profileimages/\(currentUser.uid).jpg")
        
        // Upload the image
        profileImageRef.putData(imageData, metadata: nil) { metadata, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            // Get the download URL
            profileImageRef.downloadURL { url, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let downloadURL = url else {
                    completion(.failure(NSError(domain: "StorageError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to get download URL"])))
                    return
                }
                
                // Update the user's profile in Firestore with the download URL
                let db = Firestore.firestore()
                db.collection("users").document(currentUser.uid).updateData([
                    "profileImageURL": downloadURL.absoluteString
                ]) { error in
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        // Update local profile
                        DispatchQueue.main.async {
                            self.profile?.profileImageURL = downloadURL.absoluteString
                        }
                        completion(.success(downloadURL.absoluteString))
                    }
                }
            }
        }
    }
}
