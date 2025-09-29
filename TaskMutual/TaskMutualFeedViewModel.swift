//
//  TaskMutualFeedViewModel.swift
//  TaskMutual
//
//  Created by Romir Bulbule on 9/28/25.
//


import Foundation

struct TaskPost: Identifiable, Codable {
    let id: UUID
    let title: String
    let description: String

    init(id: UUID = UUID(), title: String, description: String) {
        self.id = id
        self.title = title
        self.description = description
    }
}

class TaskMutualFeedViewModel: ObservableObject {
    @Published var posts: [TaskPost] = []

    // Sample posts for first launch only
    private let samplePosts: [TaskPost] = [
        TaskPost(title: "Move a Sofa", description: "Need help moving a sofa across town. $40. Contact to negotiate time."),
        TaskPost(title: "Yard Cleanup", description: "Looking for someone to clean leaves in backyard."),
        TaskPost(title: "Assemble Bookshelf", description: "IKEA bookshelf, instructions included. $25.")
    ]

    init() {
        loadPosts()
        if posts.isEmpty {
            posts = samplePosts
            savePosts()
        }
    }

    func addPost(title: String, description: String) {
        posts.insert(TaskPost(title: title, description: description), at: 0)
        savePosts()
    }

    // --- Persistence Logic ---

    func savePosts() {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(posts)
            UserDefaults.standard.set(data, forKey: "SavedPosts")
        } catch {
            print("Failed to save posts: \(error)")
        }
    }

    func loadPosts() {
        guard let data = UserDefaults.standard.data(forKey: "SavedPosts") else { return }
        do {
            let decoder = JSONDecoder()
            posts = try decoder.decode([TaskPost].self, from: data)
        } catch {
            print("Failed to load posts: \(error)")
        }
    }
}












