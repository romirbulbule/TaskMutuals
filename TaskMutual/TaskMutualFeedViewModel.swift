//
//  TaskMutualFeedViewModel.swift
//  TaskMutual
//
//  Created by Romir Bulbule on 9/28/25.
//


import Foundation

struct TaskPost: Identifiable {
    let id = UUID()
    let title: String
    let description: String

    init(title: String, description: String) {
        self.title = title
        self.description = description
    }
}

class TaskMutualFeedViewModel: ObservableObject {
    @Published var posts: [TaskPost] = []
    func addPost(title: String, description: String) {
        posts.insert(TaskPost(title: title, description: description), at: 0)
    }
}












