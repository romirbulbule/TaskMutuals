//
//  TaskDetailView.swift
//  TaskMutual
//
//  Created by Romir Bulbule on 10/3/25.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct TaskDetailView: View {
    @EnvironmentObject var userVM: UserViewModel
    var task: Task
    @State private var showAcceptAlert = false
    @State private var selectedResponse: Response?
    @State private var showEditResponseSheet = false
    @State private var editingResponse: Response?

    var isTaskCreator: Bool {
        task.creatorUserId == Auth.auth().currentUser?.uid
    }

    var currentUserId: String {
        Auth.auth().currentUser?.uid ?? ""
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Header with Title and Status
                HStack {
                    Text(task.title)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    Spacer()
                    Text(task.status.displayName)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(statusColor.opacity(0.2))
                        .foregroundColor(statusColor)
                        .cornerRadius(8)
                }

                Text("Posted by \(task.creatorUsername)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                // Task Details Section
                VStack(alignment: .leading, spacing: 12) {
                    if let category = task.category {
                        HStack {
                            Image(systemName: category.icon)
                                .foregroundColor(Theme.accent)
                            Text(category.rawValue)
                                .fontWeight(.medium)
                        }
                    }

                    if let location = task.location {
                        HStack {
                            Image(systemName: "mappin.circle.fill")
                                .foregroundColor(Theme.accent)
                            Text(location)
                        }
                    }

                    if let budget = task.budget {
                        HStack {
                            Image(systemName: "dollarsign.circle.fill")
                                .foregroundColor(Theme.accent)
                            Text("Budget: $\(Int(budget))")
                                .fontWeight(.semibold)
                        }
                    }

                    if let deadline = task.deadline {
                        HStack {
                            Image(systemName: "clock.fill")
                                .foregroundColor(.orange)
                            Text("Due: \(deadline, style: .date)")
                        }
                    }

                    if let duration = task.estimatedDuration {
                        HStack {
                            Image(systemName: "hourglass")
                                .foregroundColor(.blue)
                            Text("Duration: \(duration)")
                        }
                    }
                }
                .font(.subheadline)

                Divider()

                // Description
                Text("Description")
                    .font(.headline)
                    .foregroundColor(.primary)
                Text(task.description)
                    .font(.body)
                    .foregroundColor(.primary)

                Divider()

                // Assigned Provider (if any)
                if let assignedUsername = task.assignedProviderUsername {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Assigned Provider")
                            .font(.headline)
                        HStack {
                            Image(systemName: "person.circle.fill")
                                .foregroundColor(Theme.accent)
                            Text(assignedUsername)
                                .fontWeight(.medium)
                        }
                    }
                    Divider()
                }

                // Responses Section
                Text("Responses (\(task.responses.count))")
                    .font(.headline)
                    .foregroundColor(.primary)

                if task.responses.isEmpty {
                    Text("No responses yet.")
                        .foregroundColor(.gray)
                        .italic()
                        .padding()
                } else {
                    ForEach(task.responses) { response in
                        ResponseCardView(
                            response: response,
                            currentUserId: currentUserId,
                            isTaskCreator: isTaskCreator,
                            canAccept: task.status == .open && isTaskCreator && response.fromUserId != currentUserId,
                            onAccept: {
                                selectedResponse = response
                                showAcceptAlert = true
                            },
                            onEdit: {
                                editingResponse = response
                                showEditResponseSheet = true
                            },
                            onDelete: {
                                deleteResponse(response)
                            }
                        )
                    }
                }
            }
            .padding()
            .background(Color(UIColor.systemBackground))
            .cornerRadius(20)
            .shadow(color: Color.black.opacity(0.04), radius: 7, x: 0, y: 2)
            .padding()
        }
        .background(Theme.background.ignoresSafeArea())
        .navigationTitle("Task Details")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showEditResponseSheet) {
            if let response = editingResponse {
                EditResponseView(
                    task: task,
                    response: response,
                    onSave: { updatedMessage, updatedPrice in
                        updateResponse(response, message: updatedMessage, quotedPrice: updatedPrice)
                        showEditResponseSheet = false
                    }
                )
            }
        }
        .alert("Accept This Provider?", isPresented: $showAcceptAlert) {
            Button("Cancel", role: .cancel) {
                selectedResponse = nil
            }
            Button("Accept") {
                if let response = selectedResponse {
                    acceptResponse(response)
                }
            }
        } message: {
            if let response = selectedResponse {
                if let price = response.quotedPrice {
                    Text("Accept \(response.fromUsername)'s offer for $\(Int(price))?")
                } else {
                    Text("Accept \(response.fromUsername) for this task?")
                }
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
    
    func encodedResponsesWithAccepted(_ acceptedId: String?) -> [Any] {
        task.responses.compactMap { r in
            var updated = r
            if let acceptedId, r.id == acceptedId {
                updated.isAccepted = true
            }
            return try? Firestore.Encoder().encode(updated)
        }
    }

    func acceptResponse(_ response: Response) {
        guard let taskId = task.id else { return }
        let db = Firestore.firestore()

        let encoded = encodedResponsesWithAccepted(response.id)

        db.collection("tasks").document(taskId).updateData([
            "status": TaskStatus.assigned.rawValue,
            "assignedProviderId": response.fromUserId,
            "assignedProviderUsername": response.fromUsername,
            "responses": encoded
        ]) { error in
            if let error = error {
                print("❌ Error accepting response: \(error)")
            } else {
                print("✅ Response accepted successfully")
            }
        }
    }

    func updateResponse(_ response: Response, message: String, quotedPrice: Double?) {
        guard let taskId = task.id else { return }
        let db = Firestore.firestore()

        let encoded: [Any] = task.responses.compactMap { r in
            var updated = r
            if r.id == response.id {
                updated.message = message
                updated.quotedPrice = quotedPrice
            }
            return try? Firestore.Encoder().encode(updated)
        }

        db.collection("tasks").document(taskId).updateData([
            "responses": encoded
        ]) { error in
            if let error = error {
                print("❌ Error updating response: \(error)")
            } else {
                print("✅ Response updated successfully")
            }
        }
    }

    func deleteResponse(_ response: Response) {
        guard let taskId = task.id else { return }
        let db = Firestore.firestore()

        let remaining: [Any] = task.responses.compactMap { r in
            guard r.id != response.id else { return nil }
            return try? Firestore.Encoder().encode(r)
        }

        db.collection("tasks").document(taskId).updateData([
            "responses": remaining
        ]) { error in
            if let error = error {
                print("❌ Error deleting response: \(error)")
            } else {
                print("🗑️ Response deleted successfully")
            }
        }
    }
}

// Response Card Component
struct ResponseCardView: View {
    var response: Response
    var currentUserId: String
    var isTaskCreator: Bool
    var canAccept: Bool
    var onAccept: () -> Void
    var onEdit: () -> Void
    var onDelete: () -> Void

    var isOwnResponse: Bool {
        response.fromUserId == currentUserId
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "person.circle.fill")
                    .foregroundColor(Theme.accent)
                Text(response.fromUsername)
                    .fontWeight(.semibold)
                Spacer()
                if response.isAccepted {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill")
                        Text("Accepted")
                    }
                    .font(.caption)
                    .foregroundColor(.green)
                }
            }

            Text(response.message)
                .foregroundColor(.primary)

            HStack {
                if let price = response.quotedPrice {
                    Text("Quote: $\(Int(price))")
                        .font(.headline)
                        .foregroundColor(Theme.accent)
                }
                Spacer()
                Text(response.timestamp, style: .relative)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            // Buttons
            HStack(spacing: 12) {
                // Accept button - only for task creator, not for their own response
                if canAccept && !response.isAccepted {
                    Button(action: onAccept) {
                        Text("Accept")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(Theme.accent)
                            .cornerRadius(8)
                    }
                }

                // Edit and Delete buttons - only for the response author (service providers), and not if already accepted
                if isOwnResponse && !response.isAccepted && !isTaskCreator {
                    Button(action: onEdit) {
                        HStack {
                            Image(systemName: "pencil")
                            Text("Edit Quote")
                        }
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(Theme.accent)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(Color(UIColor.tertiarySystemBackground))
                        .cornerRadius(8)
                    }
                    
                    Button(action: onDelete) {
                        HStack {
                            Image(systemName: "trash")
                            Text("Delete")
                        }
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(Color(UIColor.tertiarySystemBackground))
                        .cornerRadius(8)
                    }
                }
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(12)
        .padding(.bottom, 8)
    }
}
