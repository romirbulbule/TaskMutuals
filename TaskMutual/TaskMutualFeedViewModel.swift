//
//  TaskMutualFeedViewModel.swift
//  TaskMutual
//
//  Created by Romir Bulbule on 9/28/25.
//


import Foundation

struct TaskPost: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var description: String

    init(id: UUID = UUID(), title: String, description: String) {
        self.id = id
        self.title = title
        self.description = description
    }
}

class TaskMutualFeedViewModel: ObservableObject {
    @Published var posts: [TaskPost] = []

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

    func deletePosts(at offsets: IndexSet) {
        posts.remove(atOffsets: offsets)
        savePosts()
    }

    func editPost(post: TaskPost, newTitle: String, newDescription: String) {
        guard let idx = posts.firstIndex(of: post) else { return }
        posts[idx].title = newTitle
        posts[idx].description = newDescription
        savePosts()
    }

    func reportPost(post: TaskPost) {
        // For now, just print and/or mark the post; expand for real moderation!
        print("Reported \(post.title)")
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

    func savePosts() {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(posts)
            UserDefaults.standard.set(data, forKey: "SavedPosts")
        } catch {
            print("Failed to save posts: \(error)")
        }
    }
}











