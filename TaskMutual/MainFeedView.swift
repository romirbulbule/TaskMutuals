//
//  MainFeedView.swift
//  TaskMutual
//
//  Created by Romir Bulbule on 9/23/25.
//

import SwiftUI

struct MainFeedView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showPostTask = false

    struct Task: Identifiable, Codable {
        let id: UUID
        let title: String
        let description: String

        init(id: UUID = UUID(), title: String, description: String) {
            self.id = id
            self.title = title
            self.description = description
        }
    }

    @State private var tasks: [Task] = []

    // Sample tasks (to show on first launch only)
    private let sampleTasks: [Task] = [
        Task(title: "Move a Sofa", description: "Need help moving a sofa across town. $40. Contact to negotiate time."),
        Task(title: "Yard Cleanup", description: "Looking for someone to clean leaves in backyard."),
        Task(title: "Assemble Bookshelf", description: "IKEA bookshelf, instructions included. $25.")
    ]

    var body: some View {
        VStack(spacing: 0) {
            // Post Task Button
            Button(action: {
                showPostTask = true
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
            List(tasks) { task in
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
        .sheet(isPresented: $showPostTask) {
            PostTaskView { title, description in
                tasks.append(Task(title: title, description: description))
                saveTasks() // Save after each addition
            }
            .environmentObject(authViewModel)
        }
        .onAppear {
            loadTasks()
            if tasks.isEmpty {
                tasks = sampleTasks
                saveTasks()
            }
        }
    }

    // --- Persistence Logic ---

    func saveTasks() {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(tasks) {
            UserDefaults.standard.set(data, forKey: "SavedTasks")
        }
    }

    func loadTasks() {
        guard let data = UserDefaults.standard.data(forKey: "SavedTasks") else { return }
        let decoder = JSONDecoder()
        if let loaded = try? decoder.decode([Task].self, from: data) {
            tasks = loaded
        }
    }
}












