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

    // Track if profile fetch has been attempted to prevent infinite loops
    private var hasAttemptedFetch: Bool = false

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
                bio: bioValue,
                profileImageURL: self.profile?.profileImageURL,
                userType: self.profile?.userType // IMPORTANT: Preserve user type!
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
        guard let profile = self.profile, let userId = profile.id else {
            completion?()
            return
        }

        // Just update the bio directly in Firestore - don't recreate the whole profile
        // This prevents losing userType and other fields
        db.collection("users").document(userId).updateData(["bio": bio]) { error in
            if let error = error {
                print("❌ Error updating bio: \(error.localizedDescription)")
            } else {
                print("✅ Bio updated successfully")
                // Update local copy
                DispatchQueue.main.async {
                    self.profile?.bio = bio
                }
            }
            completion?()
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

    // MARK: - Update User Type
    func updateUserType(_ userType: UserType, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            completion(.failure(NSError(domain: "Not logged in", code: 0)))
            return
        }

        db.collection("users").document(userId).updateData([
            "userType": userType.rawValue
        ]) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                // Update local copy
                DispatchQueue.main.async {
                    self.profile?.userType = userType
                }
                completion(.success(()))
            }
        }
    }
    
    // MARK: - Fetch User Profile (with debug logs/timing)
    func fetchUserProfile() {
        print("DEBUG: currentUser: \(String(describing: auth.currentUser)), uid: \(String(describing: auth.currentUser?.uid))")

        // Prevent repeated fetches when no profile exists
        if hasAttemptedFetch && profile == nil && !isLoadingProfile {
            print("⚠️ Skipping repeated profile fetch - profile doesn't exist")
            return
        }

        guard let userId = auth.currentUser?.uid else {
            DispatchQueue.main.async {
                self.profile = nil
                self.isLoadingProfile = false
                self.hasAttemptedFetch = true
            }
            return
        }

        self.isLoadingProfile = true
        self.hasAttemptedFetch = true
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
                print("No profile found for user \(userId) - user needs to complete profile setup")
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

    // Reset fetch state when needed (e.g., after profile creation or logout)
    func resetFetchState() {
        hasAttemptedFetch = false
    }
    
    func clearProfile() {
        self.profile = nil
        self.isLoadingProfile = false
        self.hasAttemptedFetch = false
    }
    
    // MARK: - Delete Account
    // MARK: - Delete Account & All User Data (Profile + Tasks + Chats + Storage)
    func deleteAccountAndAllData(password: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let user = Auth.auth().currentUser else {
            completion(.failure(NSError(domain: "No user", code: 0)))
            return
        }
        let uid = user.uid
        let db = Firestore.firestore()
        let storage = Storage.storage()

        print("🗑️ Starting complete account deletion for user: \(uid)")

        // Step 1: Fetch user profile to get username
        let userRef = db.collection("users").document(uid)
        userRef.getDocument { docSnap, _ in
            let username = (docSnap?.data()?["username"] as? String) ?? ""

            // Step 2: Delete all tasks created by user
            db.collection("tasks").whereField("creatorUserId", isEqualTo: uid).getDocuments { (tasksSnapshot, error) in
                if let error = error {
                    completion(.failure(error))
                    return
                }

                print("🗑️ Found \(tasksSnapshot?.documents.count ?? 0) tasks to delete")

                // Step 3: Delete all responses by user in OTHER users' tasks
                db.collection("tasks").getDocuments { (allTasksSnapshot, error) in
                    if let error = error {
                        completion(.failure(error))
                        return
                    }

                    var tasksWithUserResponses: [(DocumentReference, Task)] = []

                    // Find all tasks where user has responded
                    for doc in allTasksSnapshot?.documents ?? [] {
                        if var task = try? doc.data(as: Task.self),
                           task.responses.contains(where: { $0.fromUserId == uid }) {
                            // Remove this user's responses
                            task.responses.removeAll { $0.fromUserId == uid }
                            tasksWithUserResponses.append((doc.reference, task))
                        }
                    }

                    print("🗑️ Found \(tasksWithUserResponses.count) tasks with user responses to clean")

                    // Step 4: Delete all chats where user is participant
                    db.collection("chats").whereField("participants", arrayContains: uid).getDocuments { (chatsSnapshot, error) in
                        if let error = error {
                            completion(.failure(error))
                            return
                        }

                        print("🗑️ Found \(chatsSnapshot?.documents.count ?? 0) chats to delete")

                        let chatDocs = chatsSnapshot?.documents ?? []
                        let dispatchGroup = DispatchGroup()

                        // Delete all messages in each chat (subcollections)
                        for chatDoc in chatDocs {
                            dispatchGroup.enter()
                            chatDoc.reference.collection("messages").getDocuments { (messagesSnapshot, _) in
                                let messageBatch = db.batch()
                                messagesSnapshot?.documents.forEach { messageDoc in
                                    messageBatch.deleteDocument(messageDoc.reference)
                                }
                                messageBatch.commit { _ in
                                    dispatchGroup.leave()
                                }
                            }
                        }

                        dispatchGroup.notify(queue: .main) {
                            // Step 5: Create batch for all Firestore deletions
                            let batch = db.batch()

                            // Delete user's tasks
                            tasksSnapshot?.documents.forEach { doc in
                                batch.deleteDocument(doc.reference)
                            }

                            // Update tasks where user had responses (remove their responses)
                            for (docRef, updatedTask) in tasksWithUserResponses {
                                if let taskData = try? Firestore.Encoder().encode(updatedTask) {
                                    batch.setData(taskData, forDocument: docRef)
                                }
                            }

                            // Delete chat documents
                            chatDocs.forEach { chatDoc in
                                batch.deleteDocument(chatDoc.reference)
                            }

                            // Delete user profile
                            batch.deleteDocument(userRef)

                            // Delete username mapping
                            let usernameRef = db.collection("usernames").document(username.lowercased())
                            batch.deleteDocument(usernameRef)

                            // Step 6: Commit all Firestore deletions
                            batch.commit { batchError in
                                if let batchError = batchError {
                                    print("❌ Batch commit error: \(batchError)")
                                    completion(.failure(batchError))
                                    return
                                }

                                print("✅ Firestore data deleted")

                                // Step 7: Delete profile image from Storage
                                let profileImageRef = storage.reference().child("profileimages/\(uid).jpg")
                                profileImageRef.delete { storageError in
                                    // Continue even if image doesn't exist
                                    if let storageError = storageError {
                                        print("⚠️ Profile image deletion: \(storageError.localizedDescription)")
                                    } else {
                                        print("✅ Profile image deleted")
                                    }

                                    // Step 8: Re-authenticate and delete Firebase Auth account
                                    let email = user.email ?? ""
                                    let credential = EmailAuthProvider.credential(withEmail: email, password: password)
                                    user.reauthenticate(with: credential) { _, authError in
                                        if let authError = authError {
                                            print("❌ Re-auth error: \(authError)")
                                            completion(.failure(authError))
                                            return
                                        }

                                        // Final step: Delete Auth account
                                        user.delete { deleteError in
                                            if let deleteError = deleteError {
                                                print("❌ Auth deletion error: \(deleteError)")
                                                completion(.failure(deleteError))
                                            } else {
                                                print("✅ Account completely deleted")
                                                DispatchQueue.main.async {
                                                    self.profile = nil
                                                    UserDefaults.standard.removeObject(forKey: "username")
                                                }
                                                completion(.success(()))
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    
    // ==== ADDED FOR CHAT SEARCH ===========
    /// Fetch all users except the logged-in user, for chat/search
    /// Filters by opposite user type (service seekers see providers and vice versa)
    func fetchAllUsers() {
        guard let currentUserID = auth.currentUser?.uid else { return }
        guard let currentUserType = self.profile?.userType else {
            // If current user hasn't set their type yet, show all users
            db.collection("users").getDocuments { [weak self] snapshot, error in
                guard let documents = snapshot?.documents else { return }
                DispatchQueue.main.async {
                    self?.allUsers = documents.compactMap { doc in
                        let user = try? doc.data(as: UserProfile.self)
                        return (user?.id == currentUserID) ? nil : user
                    }
                }
            }
            return
        }

        // Determine which user type to fetch (opposite of current user)
        let targetUserType: UserType = (currentUserType == .lookingForServices) ? .providingServices : .lookingForServices

        // Fetch users with opposite user type
        db.collection("users")
            .whereField("userType", isEqualTo: targetUserType.rawValue)
            .getDocuments { [weak self] snapshot, error in
                guard let documents = snapshot?.documents else { return }
                DispatchQueue.main.async {
                    self?.allUsers = documents.compactMap { doc in
                        let user = try? doc.data(as: UserProfile.self)
                        // Exclude current user
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
