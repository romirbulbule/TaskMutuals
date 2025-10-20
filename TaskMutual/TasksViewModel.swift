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

    // Uses cached username set by UserService after login
    var currentUserId: String {
        Auth.auth().currentUser?.uid ?? ""
    }
    var currentUsername: String {
        UserDefaults.standard.string(forKey: "username") ?? "Unknown"
    }

    init() {
        fetchTasks()
    }

    func fetchTasks() {
        listener = db.collection("tasks")
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
