//
//  TaskCardView.swift
//  TaskMutual
//
//  Created by Romir Bulbule on 10/1/25.
//


import SwiftUI

struct TaskCardView: View {
    var task: Task
    var currentUserId: String
    var onEdit: () -> Void
    var onDelete: () -> Void
    var onReport: () -> Void
    var onRespond: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(task.title)
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            Text("By \(task.creatorUsername)")
                .font(.caption)
                .foregroundColor(.secondary)
            Text(task.description)
                .font(.body)
                .foregroundColor(.primary)
                .multilineTextAlignment(.leading)
            HStack {
                if !task.responses.isEmpty {
                    Text("💬 \(task.responses.count)")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
                Spacer()
                Text(task.timestamp, style: .date)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .padding(.top, 4)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color(UIColor.secondarySystemBackground))
        )
        .shadow(color: Color.black.opacity(0.07), radius: 7, x: 0, y: 2)
        .contextMenu { contextMenuButtons }
    }

    @ViewBuilder
    var contextMenuButtons: some View {
        if task.creatorUserId == currentUserId {
            Button("Edit", action: onEdit)
            Button("Delete", action: onDelete)
        } else {
            Button("Report", action: onReport)
            Button("Respond", action: onRespond)
        }
    }
}

