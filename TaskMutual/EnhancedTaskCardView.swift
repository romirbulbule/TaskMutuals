//
//  EnhancedTaskCardView.swift
//  TaskMutual
//
//  Enhanced task card with smooth animations and haptics
//

import SwiftUI

struct EnhancedTaskCardView: View {
    let task: Task
    let index: Int
    let onTap: (() -> Void)?

    @State private var isPressed = false
    @State private var appeared = false

    init(task: Task, index: Int = 0, onTap: (() -> Void)? = nil) {
        self.task = task
        self.index = index
        self.onTap = onTap
    }

    var body: some View {
        Button(action: {
            HapticsManager.shared.light()
            onTap?()
        }) {
            cardContent
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(AnimationPresets.buttonPress, value: isPressed)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 20)
        .onAppear {
            withAnimation(AnimationPresets.smooth.delay(Double(index) * 0.05)) {
                appeared = true
            }
        }
    }

    private var cardContent: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with title and status
            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(task.title)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .lineLimit(2)

                    // Creator info
                    HStack(spacing: 4) {
                        Image(systemName: "person.circle.fill")
                            .font(.caption2)
                        Text("@\(task.creatorUsername)")
                            .font(.caption)
                    }
                    .foregroundColor(.white.opacity(0.7))
                }

                Spacer()

                // Status badge with animation
                TaskStatusBadge(status: task.status)
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
                    .foregroundColor(.white.opacity(0.8))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(Color.white.opacity(0.15))
                    )
                }

                if let location = task.location {
                    HStack(spacing: 4) {
                        Image(systemName: "mappin.circle.fill")
                            .font(.caption)
                        Text(location)
                            .font(.caption)
                            .lineLimit(1)
                    }
                    .foregroundColor(.white.opacity(0.8))
                }
            }

            // Description
            Text(task.description)
                .font(.body)
                .foregroundColor(.white.opacity(0.9))
                .lineLimit(3)
                .multilineTextAlignment(.leading)

            Divider()
                .background(Color.white.opacity(0.2))

            // Bottom row with budget, responses, deadline
            HStack(spacing: 16) {
                // Budget
                if let budget = task.budget {
                    HStack(spacing: 4) {
                        Image(systemName: "dollarsign.circle.fill")
                            .font(.system(size: 16))
                        Text("$\(Int(budget))")
                            .font(.headline)
                    }
                    .foregroundColor(Theme.brandCream)
                }

                // Responses count
                if !task.responses.isEmpty {
                    HStack(spacing: 4) {
                        Image(systemName: "bubble.left.fill")
                            .font(.caption)
                        Text("\(task.responses.count)")
                            .font(.caption)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.blue)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(Color.blue.opacity(0.2))
                    )
                }

                Spacer()

                // Deadline
                if let deadline = task.deadline {
                    HStack(spacing: 4) {
                        Image(systemName: "clock.fill")
                            .font(.caption2)
                        Text(deadline, style: .relative)
                            .font(.caption2)
                    }
                    .foregroundColor(.orange)
                }

                // Date posted
                Text(task.timestamp, style: .relative)
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.5))
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.1))
                .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 5)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
    }
}

// Reusable task status badge with animation
private struct TaskStatusBadge: View {
    let status: TaskStatus
    @State private var appeared = false

    var body: some View {
        Text(status.displayName)
            .font(.caption2)
            .fontWeight(.bold)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(
                Capsule()
                    .fill(statusColor.opacity(0.3))
            )
            .foregroundColor(statusColor)
            .scaleEffect(appeared ? 1.0 : 0.8)
            .opacity(appeared ? 1.0 : 0.0)
            .onAppear {
                withAnimation(AnimationPresets.bouncy.delay(0.1)) {
                    appeared = true
                }
            }
    }

    private var statusColor: Color {
        switch status {
        case .open: return .blue
        case .assigned: return .orange
        case .inProgress: return .purple
        case .completed: return .green
        case .cancelled: return .red
        }
    }
}

#Preview {
    ZStack {
        Theme.background.ignoresSafeArea()

        ScrollView {
            VStack(spacing: 16) {
                ForEach(0..<3, id: \.self) { index in
                    EnhancedTaskCardView(
                        task: Task(
                            id: "123",
                            title: "Clean my house",
                            description: "Need help with deep cleaning my 3-bedroom house. Looking for someone experienced.",
                            creatorUserId: "user1",
                            creatorUsername: "john_doe",
                            budget: 75,
                            location: "Boston, MA",
                            category: .cleaning
                        ),
                        index: index
                    )
                }
            }
            .padding()
        }
    }
}
