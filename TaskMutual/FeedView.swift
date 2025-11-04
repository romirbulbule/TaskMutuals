//
//  FeedView.swift
//  TaskMutual
//
//  Created by Romir Bulbule on 9/30/25.
//

import SwiftUI
import FirebaseFirestore

struct FeedView: View {
    @EnvironmentObject var userVM: UserViewModel
    @EnvironmentObject var tasksVM: TasksViewModel
    @StateObject private var modalManager = ModalManager()
    @State private var showPostTaskSheet = false

    // Determine if user can post tasks (only service seekers can post)
    var canPostTasks: Bool {
        userVM.profile?.userType == .lookingForServices
    }

    var body: some View {
        NavigationView {
            ZStack {
                Theme.background.ignoresSafeArea()

                if tasksVM.tasks.isEmpty {
                    // Empty state
                    VStack(spacing: 16) {
                        Image(systemName: canPostTasks ? "plus.circle" : "tray")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)

                        Text(canPostTasks ? "No tasks yet" : "No tasks available")
                            .font(.title2)
                            .foregroundColor(.gray)

                        Text(canPostTasks ? "Post your first task!" : "Check back later for tasks to complete")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                    }
                } else {
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(tasksVM.tasks) { task in
                                NavigationLink(destination: TaskDetailView(task: task)) {
                                    TaskCardView(
                                        task: task,
                                        currentUserId: tasksVM.currentUserId,
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
            }
            .navigationTitle(canPostTasks ? "Your Tasks" : "Available Tasks")
            .navigationBarItems(leading:
                Group {
                    if canPostTasks {
                        Button(action: { showPostTaskSheet = true }) {
                            Image(systemName: "plus")
                                .font(.title2)
                                .foregroundColor(Theme.accent)
                        }
                    }
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
                        tasksVM.addResponse(to: task, message: sentMessage) {
                            modalManager.closeResponse()
                        }
                    }
                }
            }
        }
        .background(Theme.background.ignoresSafeArea())
    }
}
