//
//  TaskMutualsFeedView.swift
//  TaskMutual
//
//  Created by Romir Bulbule on 9/26/25.
//


import SwiftUI

struct TaskMutualsFeedView: View {
    // Example post data
    let examplePosts = [
        "Finish SwiftUI project",
        "Grocery shopping",
        "Study for midterms",
        "Gym push day"
    ]

    var body: some View {
        NavigationView {
            List(examplePosts, id: \.self) { post in
                VStack(alignment: .leading, spacing: 8) {
                    Text("TaskMutuals Print")
                        .font(.headline)
                        .foregroundColor(.blue)
                    Text(post)
                        .font(.body)
                }
                .padding(.vertical, 8)
            }
            .navigationTitle("TaskMutuals Feed")
        }
    }
}







