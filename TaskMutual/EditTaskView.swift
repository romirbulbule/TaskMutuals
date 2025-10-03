//
//  EditTaskView.swift
//  TaskMutual
//
//  Created by Romir Bulbule on 9/30/25.
//


import SwiftUI

struct EditTaskView: View {
    var post: Task
    @State private var title: String
    @State private var description: String
    var onSave: (String, String) -> Void

    init(post: Task, onSave: @escaping (String, String) -> Void) {
        self.post = post
        self.onSave = onSave
        _title = State(initialValue: post.title)
        _description = State(initialValue: post.description)
    }

    var body: some View {
        NavigationView {
            Form {
                TextField("Task Title", text: $title)
                TextField("Description", text: $description)
            }
            .navigationTitle("Edit Task")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        onSave(title, description)
                    }
                }
            }
        }
        .background(Theme.background.ignoresSafeArea())
    }
}












