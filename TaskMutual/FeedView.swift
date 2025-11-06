//
//  FeedView.swift
//  TaskMutual
//
//  Created by Romir Bulbule on 9/30/25.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct FeedView: View {
    @EnvironmentObject var userVM: UserViewModel
    @EnvironmentObject var tasksVM: TasksViewModel
    @StateObject private var modalManager = ModalManager()
    @State private var showPostTaskSheet = false
    @State private var showUserTypeError = false
    @State private var showFeedTutorial = false

    // Check if user has seen the feed tutorial
    private func hasSeenFeedTutorial() -> Bool {
        guard let userId = userVM.profile?.id else { return true }
        return UserDefaults.standard.bool(forKey: "hasSeenFeedTutorial_\(userId)")
    }

    // Determine if user can post tasks (only service seekers can post)
    var canPostTasks: Bool {
        userVM.profile?.userType == .lookingForServices
    }

    var hasUserType: Bool {
        userVM.profile?.userType != nil
    }

    var body: some View {
        NavigationView {
            ZStack {
                Theme.background.ignoresSafeArea()

                // Feed tutorial overlay
                if showFeedTutorial, let userType = userVM.profile?.userType, let userId = userVM.profile?.id {
                    FeedTutorialView(
                        userType: userType,
                        userId: userId,
                        showTutorial: $showFeedTutorial
                    )
                    .zIndex(999)
                }

                if tasksVM.tasks.isEmpty {
                    // Animated empty state
                    AnimatedEmptyState(
                        icon: canPostTasks ? "plus.circle.fill" : "tray.fill",
                        title: canPostTasks ? "No tasks yet" : "No tasks available",
                        message: canPostTasks ? "Post your first task to get started!" : "Check back later for available tasks",
                        actionTitle: canPostTasks ? "Post Task" : nil,
                        action: canPostTasks ? {
                            HapticsManager.shared.heavy()
                            withAnimation(AnimationPresets.bouncy) {
                                showPostTaskSheet = true
                            }
                        } : nil
                    )
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(Array(tasksVM.tasks.enumerated()), id: \.offset) { index, task in
                                NavigationLink(destination: TaskDetailView(task: task)
                                    .environmentObject(userVM)
                                    .environmentObject(tasksVM)
                                ) {
                                    EnhancedTaskCardView(
                                        task: task,
                                        index: index
                                    ) {
                                        // Handle tap
                                    }
                                }
                                .buttonStyle(PlainButtonStyle())
                                .padding(.horizontal)
                            }
                        }
                        .padding(.vertical, 8)
                    }
                    .refreshable {
                        HapticsManager.shared.light()
                        tasksVM.fetchTasks()
                    }
                }
            }
            .navigationTitle(canPostTasks ? "Your Tasks" : "Available Tasks")
            .navigationBarItems(leading:
                Group {
                    if canPostTasks {
                        Button(action: {
                            HapticsManager.shared.heavy()
                            if hasUserType {
                                withAnimation(AnimationPresets.bouncy) {
                                    showPostTaskSheet = true
                                }
                            } else {
                                showUserTypeError = true
                            }
                        }) {
                            Image(systemName: "plus")
                                .font(.title2)
                                .foregroundColor(Theme.accent)
                        }
                    }
                }
            )
            .sheet(isPresented: $showPostTaskSheet) {
                PostTaskView { title, description, budget, location, category, deadline, estimatedDuration in
                    tasksVM.addTask(
                        title: title,
                        description: description,
                        budget: budget,
                        location: location,
                        category: category,
                        deadline: deadline,
                        estimatedDuration: estimatedDuration
                    )
                    showPostTaskSheet = false
                }
            }
            .alert("User Type Required", isPresented: $showUserTypeError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Please set your user type in Profile settings before posting tasks.")
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
                    ResponseView(post: task) { sentMessage, quotedPrice in
                        tasksVM.addResponse(to: task, message: sentMessage, quotedPrice: quotedPrice) { success in
                            if success {
                                modalManager.closeResponse()
                            }
                            // If success is false, keep the sheet open so user knows something went wrong
                        }
                    }
                }
            }
        }
        .background(Theme.background.ignoresSafeArea())
        .onAppear {
            // Show feed tutorial if user hasn't seen it yet
            if !hasSeenFeedTutorial() && userVM.profile?.userType != nil {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    showFeedTutorial = true
                }
            }
        }
    }
}
