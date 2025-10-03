//
//  TasksViewModel.swift
//  TaskMutual
//
//  Created by Romir Bulbule on 10/2/25.
//


import Foundation
import FirebaseFirestore

class TasksViewModel: ObservableObject {
    @Published var tasks: [Task] = []
    private var db = Firestore.firestore()
    private var listener: ListenerRegistration?

    init() { fetchTasks() }

    func fetchTasks() {
        listener = db.collection("tasks")
            .order(by: "timestamp", descending: true)
            .addSnapshotListener { snapshot, error in
                guard let docs = snapshot?.documents else { return }
                self.tasks = docs.compactMap { try? $0.data(as: Task.self) }
            }
    }

    func addTask(title: String, description: String) {
        let newTask = Task(title: title, description: description, timestamp: Date())
        do { _ = try db.collection("tasks").addDocument(from: newTask) }
        catch { print("Error adding: \(error)") }
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
            "timestamp": Date()
        ], merge: true)
    }
}
