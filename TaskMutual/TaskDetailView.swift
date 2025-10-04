//
//  TaskDetailView.swift
//  TaskMutual
//
//  Created by Romir Bulbule on 10/3/25.
//


import SwiftUI

struct TaskDetailView: View {
    var task: Task

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(task.title)
                    .font(.title2)
                    .fontWeight(.bold)
                Text(task.description)
                    .font(.body)
                Divider()
                Text("Responses (\(task.responses.count))")
                    .font(.headline)
                if task.responses.isEmpty {
                    Text("No responses yet.")
                        .foregroundColor(.gray)
                        .italic()
                } else {
                    ForEach(task.responses) { response in
                        VStack(alignment: .leading, spacing: 8) {
                            Text(response.message)
                                .padding()
                                .background(Color.gray.opacity(0.09))
                                .cornerRadius(8)
                            HStack {
                                Text("From: \(response.fromUserId)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text(response.timestamp, style: .relative)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.bottom, 8)
                    }
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(20)
            .shadow(color: Color.black.opacity(0.04), radius: 7, x: 0, y: 2)
            .padding()
        }
        .background(Theme.background.ignoresSafeArea())
        .navigationTitle("Task Details")
    }
}
