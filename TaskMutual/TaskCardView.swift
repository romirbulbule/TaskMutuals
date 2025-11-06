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
    var currentUserType: UserType?
    var onEdit: () -> Void
    var onDelete: () -> Void
    var onReport: () -> Void
    var onRespond: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Title and Status
            HStack {
                Text(task.title)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                    .lineLimit(2)
                Spacer()
                // Status badge
                Text(task.status.displayName)
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(statusColor.opacity(0.2))
                    .foregroundColor(statusColor)
                    .cornerRadius(6)
            }

            // Category and Location
            HStack(spacing: 12) {
                if let category = task.category {
                    HStack(spacing: 4) {
                        Image(systemName: category.icon)
                            .font(.caption)
                        Text(category.rawValue)
                            .font(.caption)
                    }
                    .foregroundColor(.secondary)
                }

                if let location = task.location {
                    HStack(spacing: 4) {
                        Image(systemName: "mappin.circle.fill")
                            .font(.caption)
                        Text(location)
                            .font(.caption)
                            .lineLimit(1)
                    }
                    .foregroundColor(.secondary)
                }
            }

            // Description
            Text(task.description)
                .font(.body)
                .foregroundColor(.primary)
                .lineLimit(3)
                .multilineTextAlignment(.leading)

            // Budget, Responses, and Date
            HStack {
                if let budget = task.budget {
                    Text("$\(Int(budget))")
                        .font(.headline)
                        .foregroundColor(Theme.accent)
                }

                Spacer()

                if !task.responses.isEmpty {
                    HStack(spacing: 4) {
                        Image(systemName: "bubble.left.fill")
                            .font(.caption2)
                        Text("\(task.responses.count)")
                            .font(.caption)
                    }
                    .foregroundColor(.blue)
                }

                Text(task.timestamp, style: .date)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .padding(.top, 4)

            // Deadline (if exists)
            if let deadline = task.deadline {
                HStack(spacing: 4) {
                    Image(systemName: "clock.fill")
                        .font(.caption2)
                    Text("Due: \(deadline, style: .date)")
                        .font(.caption2)
                }
                .foregroundColor(.orange)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color(UIColor.secondarySystemBackground))
        )
        .shadow(color: Color.black.opacity(0.07), radius: 7, x: 0, y: 2)
        .contextMenu {
            // Only show context menu for service seekers (task creators)
            if task.creatorUserId == currentUserId && currentUserType == .lookingForServices {
                contextMenuButtons
            }
        }
    }

    var statusColor: Color {
        switch task.status {
        case .open: return .blue
        case .assigned: return .orange
        case .inProgress: return .purple
        case .completed: return .green
        case .cancelled: return .red
        }
    }

    @ViewBuilder
    var contextMenuButtons: some View {
        // Only service seekers can edit/delete their own tasks
        if task.creatorUserId == currentUserId && currentUserType == .lookingForServices {
            Button("Edit", action: onEdit)
            Button("Delete", action: onDelete)
        } else {
            // Service providers can only respond to tasks
            Button("Report", action: onReport)
            
            // Only show Respond button if user hasn't already responded
            if !task.hasUserResponded(userId: currentUserId) {
                Button("Respond", action: onRespond)
            } else {
                Button("View Your Response") {
                    // Could navigate to view their existing response
                }
                .disabled(true)
            }
        }
    }
}

