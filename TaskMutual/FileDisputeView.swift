//
//  FileDisputeView.swift
//  TaskMutual
//
//  View for filing a dispute about a task
//

import SwiftUI

struct FileDisputeView: View {
    let task: Task
    let respondentId: String
    let respondentUsername: String

    @EnvironmentObject var userVM: UserViewModel
    @Environment(\.presentationMode) var presentationMode

    @State private var selectedReason: DisputeReason = .taskNotCompleted
    @State private var descriptionText: String = ""
    @State private var isSubmitting = false
    @State private var errorMessage = ""
    @State private var showSuccess = false

    private let disputeService = DisputeService()

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.white.opacity(0.7))
                    }
                    Spacer()
                    Text("File Dispute")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.white)
                    Spacer()
                    Spacer().frame(width: 28)
                }
                .padding()

                ScrollView {
                    VStack(spacing: 24) {
                        // Task Info
                        VStack(spacing: 12) {
                            Text("Task: \(task.title)")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)

                            Text("Filing dispute against: @\(respondentUsername)")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.7))
                        }
                        .padding()

                        // Reason Selection
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Reason for Dispute")
                                .font(.headline)
                                .foregroundColor(.white)

                            VStack(spacing: 8) {
                                ForEach(DisputeReason.allCases, id: \.self) { reason in
                                    Button(action: { selectedReason = reason }) {
                                        HStack {
                                            Text(reason.displayName)
                                                .foregroundColor(.white)

                                            Spacer()

                                            if selectedReason == reason {
                                                Image(systemName: "checkmark.circle.fill")
                                                    .foregroundColor(Theme.accent)
                                            } else {
                                                Image(systemName: "circle")
                                                    .foregroundColor(.white.opacity(0.3))
                                            }
                                        }
                                        .padding()
                                        .background(
                                            RoundedRectangle(cornerRadius: 10)
                                                .fill(Color.white.opacity(selectedReason == reason ? 0.15 : 0.05))
                                        )
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                        }
                        .padding()
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(12)

                        // Description
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Describe the Issue")
                                .font(.headline)
                                .foregroundColor(.white)

                            Text("Please provide details about what happened")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.7))

                            ZStack(alignment: .topLeading) {
                                if descriptionText.isEmpty {
                                    Text("Explain what went wrong and why you're filing this dispute...")
                                        .foregroundColor(.white.opacity(0.3))
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 16)
                                }

                                TextEditor(text: $descriptionText)
                                    .frame(height: 150)
                                    .padding(8)
                                    .background(Color.white.opacity(0.1))
                                    .cornerRadius(10)
                                    .foregroundColor(.white)
                                    .scrollContentBackground(.hidden)
                            }
                        }
                        .padding()
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(12)

                        // Warning Message
                        HStack(spacing: 12) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.orange)
                            Text("Disputes are reviewed by our team. False claims may result in account suspension.")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))
                        }
                        .padding()
                        .background(Color.orange.opacity(0.2))
                        .cornerRadius(10)

                        // Error Message
                        if !errorMessage.isEmpty {
                            Text(errorMessage)
                                .foregroundColor(.red)
                                .font(.subheadline)
                                .multilineTextAlignment(.center)
                                .padding()
                        }

                        // Submit Button
                        Button(action: submitDispute) {
                            if isSubmitting {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.red)
                                    .cornerRadius(12)
                            } else {
                                HStack {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                    Text("Submit Dispute")
                                        .font(.headline)
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(descriptionText.isEmpty ? Color.gray : Color.red)
                                .cornerRadius(12)
                            }
                        }
                        .disabled(descriptionText.isEmpty || isSubmitting)
                    }
                    .padding()
                }
            }

            // Success Overlay
            if showSuccess {
                Color.black.opacity(0.5).ignoresSafeArea()

                VStack(spacing: 20) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.green)

                    Text("Dispute Filed")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)

                    Text("Our team will review your dispute and contact you within 24-48 hours.")
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)

                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Text("Done")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Theme.accent)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal, 40)
                }
                .padding(32)
                .background(Theme.background.opacity(0.95))
                .cornerRadius(20)
                .padding(40)
            }
        }
    }

    private func submitDispute() {
        guard let taskId = task.id,
              let reporterId = userVM.profile?.id,
              let reporterUsername = userVM.profile?.username else {
            errorMessage = "Unable to file dispute. Please try again."
            return
        }

        guard !descriptionText.isEmpty else {
            errorMessage = "Please describe the issue."
            return
        }

        isSubmitting = true
        errorMessage = ""

        disputeService.createDispute(
            taskId: taskId,
            taskTitle: task.title,
            reason: selectedReason,
            description: descriptionText,
            reporterId: reporterId,
            reporterUsername: reporterUsername,
            respondentId: respondentId,
            respondentUsername: respondentUsername
        ) { result in
            isSubmitting = false

            switch result {
            case .success:
                showSuccess = true
            case .failure(let error):
                errorMessage = "Failed to file dispute: \(error.localizedDescription)"
            }
        }
    }
}

#Preview {
    FileDisputeView(
        task: Task(
            id: "123",
            title: "Clean my house",
            description: "Need help cleaning",
            creatorUserId: "user1",
            creatorUsername: "john_doe"
        ),
        respondentId: "provider1",
        respondentUsername: "jane_provider"
    )
    .environmentObject(UserViewModel())
}
