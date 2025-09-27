//
//  ViewModel.swift
//  TaskMutual
//
//  Created by Romir Bulbule on 9/27/25.
//


import SwiftUI

class TaskMutualsFeedViewModel: ObservableObject {
    @Published var posts: [TaskMutualPost] = [
        TaskMutualPost(title: "Need help moving boxes", description: "Downtown, $20 reward"),
        TaskMutualPost(title: "Math tutoring", description: "1 hour, $15 reward")
    ]

    func addPost(title: String, description: String) {
        posts.insert(TaskMutualPost(title: title, description: description), at: 0)
    }
}












