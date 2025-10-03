//
//  FeedView.swift
//  TaskMutual
//
//  Created by Romir Bulbule on 9/30/25.
//

import SwiftUI
import FirebaseFirestore

// MARK: Your Task Model
struct Task: Identifiable, Codable, Equatable {
    @DocumentID var id: String?
    var title: String
    var description: String
    var timestamp: Date = Date()
}

// MARK: - FeedView
import SwiftUI

struct FeedView: View {
    @StateObject private var tasksVM = TasksViewModel()
    @State private var showPostTaskSheet = false
    @State private var showEditTaskSheet = false
    @State private var showResponseSheet = false
    @State private var selectedTask: Task?

    var body: some View {
        NavigationView {
            ZStack {
                Theme.background.ignoresSafeArea()
                List {
                    ForEach(tasksVM.tasks) { task in
                        TaskCardView(
                            task: task,
                            onEdit: {
                                selectedTask = task
                                showEditTaskSheet = true
                            },
                            onDelete: { tasksVM.removeTask(task) },
                            onReport: { /* implement report logic here */ },
                            onRespond: {
                                selectedTask = task
                                showResponseSheet = true
                            }
                        )
                        .listRowSeparator(.hidden)
                        .listRowBackground(Theme.background)
                    }
                }
                .listStyle(.plain)
                .background(Theme.background)
            }
            .navigationTitle("Tasks")
            .navigationBarItems(leading:
                Button(action: { showPostTaskSheet = true }) {
                    Image(systemName: "plus")
                        .font(.title2)
                        .foregroundColor(Theme.accent)
                }
            )
            .sheet(isPresented: $showPostTaskSheet) {
                PostTaskView { title, description in
                    tasksVM.addTask(title: title, description: description)
                    showPostTaskSheet = false
                }
            }
            .sheet(isPresented: $showEditTaskSheet) {
                if let selectedTask = selectedTask {
                    EditTaskView(post: selectedTask) { updatedTitle, updatedDescription in
                        tasksVM.updateTask(selectedTask, title: updatedTitle, description: updatedDescription)
                        showEditTaskSheet = false
                    }
                } else {
                    EmptyView()
                }
            }
            .sheet(isPresented: $showResponseSheet) {
                if let selectedTask = selectedTask {
                    ResponseView(post: selectedTask) { sentMessage in
                        // TODO: handle response
                        showResponseSheet = false
                    }
                } else {
                    EmptyView()
                }
            }
        }
        .background(Theme.background.ignoresSafeArea())
    }
}
