//
//  MainFeedView.swift
//  TaskMutual
//
//  Created by Romir Bulbule on 9/23/25.
//

import SwiftUI
import FirebaseFirestore

struct MainFeedView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var tasksVM = TasksViewModel()
    @State private var showPostTaskSheet = false
    @State private var showEditTaskSheet = false
    @State private var showResponseSheet = false
    @State private var selectedTask: Task?

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Post Task Button
                Button(action: {
                    showPostTaskSheet = true
                }) {
                    Text("Post a Task")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Theme.accent)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.top)
                }

                // TASK FEED
                List {
                    ForEach(tasksVM.tasks) { task in
                        Button(action: {
                            selectedTask = task
                            showEditTaskSheet = true
                        }) {
                            VStack(alignment: .leading, spacing: 6) {
                                Text(task.title)
                                    .font(.headline)
                                    .foregroundColor(Theme.accent)
                                Text(task.description)
                                    .font(.subheadline)
                                    .foregroundColor(.primary)
                            }
                            .padding(.vertical, 6)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .contextMenu {
                            Button("Edit") {
                                selectedTask = task
                                showEditTaskSheet = true
                            }
                            Button("Delete") {
                                tasksVM.removeTask(task)
                            }
                            Button("Report") {
                                // implement showingReportAlert logic if needed
                            }
                            Button("Respond") {
                                selectedTask = task
                                showResponseSheet = true
                            }
                        }
                    }
                    // No onDelete for Firestore sync!
                }
                .listStyle(.plain)
                .background(Theme.background)

                // Logout Button
                Button(action: {
                    authViewModel.signOut()
                }) {
                    Text("Logout")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Theme.accent)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding([.horizontal, .bottom])
                }
            }
            .background(Theme.background.ignoresSafeArea())
            .sheet(isPresented: $showPostTaskSheet) {
                PostTaskView { title, description in
                    tasksVM.addTask(title: title, description: description)
                    showPostTaskSheet = false
                }
                .environmentObject(authViewModel)
            }
            .sheet(isPresented: $showEditTaskSheet) {
                if let task = selectedTask {
                    EditTaskView(post: task) { title, description in
                        tasksVM.updateTask(task, title: title, description: description)
                        showEditTaskSheet = false
                    }
                }
            }
            .sheet(isPresented: $showResponseSheet) {
                if let task = selectedTask {
                    ResponseView(post: task) { message in
                        // Handle response (save/send elsewhere)
                        showResponseSheet = false
                    }
                }
            }
        }
    }
}












