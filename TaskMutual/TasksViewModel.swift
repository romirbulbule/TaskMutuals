//
//  TasksViewModel.swift
//  TaskMutual
//
//  Created by Romir Bulbule on 10/2/25.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

class TasksViewModel: ObservableObject {
    @Published var tasks: [Task] = []
    private var db = Firestore.firestore()
    private var listener: ListenerRegistration?

    // Current user's profile (set by app after login)
    var currentUserProfile: UserProfile?

    // Uses cached username set by UserService after login
    var currentUserId: String {
        Auth.auth().currentUser?.uid ?? ""
    }
    var currentUsername: String {
        UserDefaults.standard.string(forKey: "username") ?? "Unknown"
    }
    var currentUserType: UserType? {
        currentUserProfile?.userType
    }

    init() {
        fetchTasks()
    }

    func setUserProfile(_ profile: UserProfile?) {
        self.currentUserProfile = profile
        // Re-fetch tasks with proper filtering when profile is set
        fetchTasks()
    }

    func fetchTasks() {
        // Remove old listener
        listener?.remove()

        guard let userType = currentUserType else {
            // If user hasn't set their type yet, show all tasks
            listener = db.collection("tasks")
                .order(by: "timestamp", descending: true)
                .addSnapshotListener { snapshot, error in
                    guard let docs = snapshot?.documents else { return }
                    self.tasks = docs.compactMap { try? $0.data(as: Task.self) }
                }
            return
        }

        // Determine which user type to show tasks from (opposite of current user)
        let targetUserType: UserType = (userType == .lookingForServices) ? .providingServices : .lookingForServices

        // Fetch tasks from users with opposite user type
        listener = db.collection("tasks")
            .whereField("creatorUserType", isEqualTo: targetUserType.rawValue)
            .order(by: "timestamp", descending: true)
            .addSnapshotListener { snapshot, error in
                guard let docs = snapshot?.documents else { return }
                self.tasks = docs.compactMap { try? $0.data(as: Task.self) }
            }
    }

    func addTask(title: String, description: String) {
        let newTask = Task(
            title: title,
            description: description,
            creatorUserId: currentUserId,
            creatorUsername: currentUsername,
            creatorUserType: currentUserType?.rawValue,
            timestamp: Date(),
            responses: []
        )
        do {
            _ = try db.collection("tasks").addDocument(from: newTask)
        } catch {
            print("Error adding task: \(error)")
        }
    }

    func removeTask(_ task: Task) {
        guard let id = task.id else { return }
        db.collection("tasks").document(id).delete()
    }

    func updateTask(_ task: Task, title: String, description: String) {
        guard let id = task.id else { return }
        db.collection("tasks").document(id).setData([
            "title": title,
            "description": description,
            "creatorUserId": task.creatorUserId,
            "creatorUsername": task.creatorUsername,
            "timestamp": Date()
        ], merge: true)
    }

    func addResponse(to task: Task, message: String, completion: (() -> Void)? = nil) {
        guard let id = task.id else { return }
        let newResponse = Response(
            fromUserId: currentUserId,
            fromUsername: currentUsername,
            message: message,
            timestamp: Date()
        )
        do {
            let encoded = try Firestore.Encoder().encode(newResponse)
            db.collection("tasks").document(id).updateData([
                "responses": FieldValue.arrayUnion([encoded])
            ]) { error in
                if let error = error {
                    print("Error adding response: \(error)")
                }
                completion?()
            }
        } catch {
            print("Error encoding response: \(error)")
            completion?()
        }
    }

    deinit {
        listener?.remove()
    }
}
