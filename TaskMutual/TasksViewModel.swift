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
        print("📋 TasksViewModel: setUserProfile called with userType: \(profile?.userType?.rawValue ?? "nil")")
        self.currentUserProfile = profile
        // Re-fetch tasks with proper filtering when profile is set
        fetchTasks()
    }

    func fetchTasks() {
        // Remove old listener
        listener?.remove()

        print("📋 TasksViewModel: fetchTasks called, currentUserType: \(currentUserType?.rawValue ?? "nil")")

        // IMPORTANT: Fetch ALL tasks and filter client-side
        // This handles backwards compatibility for tasks without creatorUserType
        listener = db.collection("tasks")
            .order(by: "timestamp", descending: true)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }

                if let error = error {
                    print("❌ Error fetching tasks: \(error.localizedDescription)")
                    return
                }

                guard let docs = snapshot?.documents else {
                    print("📋 No task documents found")
                    return
                }

                // Parse all tasks
                let allTasks = docs.compactMap { try? $0.data(as: Task.self) }
                print("📋 Fetched \(allTasks.count) total tasks from Firestore")

                // Filter based on current user type
                if let userType = self.currentUserType {
                    let filteredTasks: [Task]

                    if userType == .lookingForServices {
                        // Service seekers see THEIR OWN tasks (the ones they posted)
                        print("📋 Filtering tasks: showing own tasks for service seeker")
                        filteredTasks = allTasks.filter { task in
                            task.creatorUserId == self.currentUserId
                        }
                    } else {
                        // Service providers see tasks FROM service seekers (tasks they can respond to)
                        print("📋 Filtering tasks: showing service seeker tasks for service provider")
                        filteredTasks = allTasks.filter { task in
                            if let creatorType = task.creatorUserType {
                                return creatorType == UserType.lookingForServices.rawValue
                            } else {
                                // For backwards compatibility: include tasks without userType
                                print("⚠️ Task '\(task.title)' has no creatorUserType - including it")
                                return true
                            }
                        }
                    }

                    print("📋 Showing \(filteredTasks.count) filtered tasks")
                    self.tasks = filteredTasks
                } else {
                    // If user hasn't set their type yet, show all tasks
                    print("📋 No user type set - showing all \(allTasks.count) tasks")
                    self.tasks = allTasks
                }
            }
    }

    func addTask(
        title: String,
        description: String,
        budget: Double?,
        location: String?,
        category: ServiceCategory?,
        deadline: Date?,
        estimatedDuration: String?
    ) {
        // Validate that user has a type set
        guard let userType = currentUserType else {
            print("❌ Cannot create task: user type not set!")
            return
        }

        print("📋 Creating task with creatorUserType: \(userType.rawValue)")

        let newTask = Task(
            title: title,
            description: description,
            creatorUserId: currentUserId,
            creatorUsername: currentUsername,
            creatorUserType: userType.rawValue,
            timestamp: Date(),
            responses: [],
            isArchived: false,
            budget: budget,
            location: location,
            category: category,
            status: .open,
            deadline: deadline,
            estimatedDuration: estimatedDuration,
            assignedProviderId: nil,
            assignedProviderUsername: nil
        )

        do {
            _ = try db.collection("tasks").addDocument(from: newTask)
            print("✅ Task created successfully - Category: \(category?.rawValue ?? "none"), Location: \(location ?? "none"), Budget: $\(budget ?? 0)")
        } catch {
            print("❌ Error adding task: \(error)")
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

    func addResponse(to task: Task, message: String, quotedPrice: Double?, completion: ((Bool) -> Void)? = nil) {
        guard let id = task.id else { 
            completion?(false)
            return 
        }
        
        // Check if user has already responded to this task
        let hasAlreadyResponded = task.responses.contains { response in
            response.fromUserId == currentUserId
        }
        
        if hasAlreadyResponded {
            print("❌ User has already responded to this task")
            completion?(false)
            return
        }
        
        let newResponse = Response(
            fromUserId: currentUserId,
            fromUsername: currentUsername,
            message: message,
            timestamp: Date(),
            quotedPrice: quotedPrice,
            isAccepted: false
        )
        do {
            let encoded = try Firestore.Encoder().encode(newResponse)
            db.collection("tasks").document(id).updateData([
                "responses": FieldValue.arrayUnion([encoded])
            ]) { error in
                if let error = error {
                    print("Error adding response: \(error)")
                    completion?(false)
                } else {
                    if let price = quotedPrice {
                        print("✅ Response added with quote: $\(price)")
                    } else {
                        print("✅ Response added without quote")
                    }
                    completion?(true)
                }
            }
        } catch {
            print("Error encoding response: \(error)")
            completion?(false)
        }
    }

    func hasUserRespondedToTask(_ task: Task, userId: String? = nil) -> Bool {
        let userIdToCheck = userId ?? currentUserId
        return task.responses.contains { response in
            response.fromUserId == userIdToCheck
        }
    }

    deinit {
        listener?.remove()
    }
}
