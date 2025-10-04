//
//  FeedView.swift
//  TaskMutual
//
//  Created by Romir Bulbule on 9/30/25.
//

import SwiftUI
import FirebaseFirestore

struct FeedView: View {
    @StateObject private var tasksVM = TasksViewModel()
    @StateObject private var modalManager = ModalManager()
    @State private var showPostTaskSheet = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Theme.background.ignoresSafeArea()
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(tasksVM.tasks) { task in
                            NavigationLink(destination: TaskDetailView(task: task)) {
                                TaskCardView(
                                    task: task,
                                    onEdit: { modalManager.showEdit(for: task) },
                                    onDelete: { tasksVM.removeTask(task) },
                                    onReport: { /* implement report logic here */ },
                                    onRespond: { modalManager.showResponse(for: task) }
                                )
                                .padding(.top, 8)
                                .padding(.horizontal)
                            }
                        }
                    }
                }
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
            .sheet(isPresented: modalManager.showEditSheet) {
                if let task = modalManager.editTask {
                    EditTaskView(post: task) { updatedTitle, updatedDescription in
                        tasksVM.updateTask(task, title: updatedTitle, description: updatedDescription)
                        modalManager.closeEdit()
                    }
                }
            }
            .sheet(isPresented: modalManager.showResponseSheet) {
                if let task = modalManager.responseTask {
                    ResponseView(post: task) { sentMessage in
                        let currentUserId = "user_id_goes_here"
                        tasksVM.addResponse(to: task, fromUserId: currentUserId, message: sentMessage) {
                            modalManager.closeResponse()
                        }
                    }
                }
            }
        }
        .background(Theme.background.ignoresSafeArea())
    }
}
