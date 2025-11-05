//
//  DisputesView.swift
//  TaskMutual
//
//  View for displaying user's disputes
//

import SwiftUI

struct DisputesView: View {
    @EnvironmentObject var userVM: UserViewModel
    @Environment(\.presentationMode) var presentationMode

    @State private var disputes: [Dispute] = []
    @State private var isLoading = true
    @State private var errorMessage = ""

    private let disputeService = DisputeService()

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(Theme.accent)
                    }
                    Spacer()
                    Text("My Disputes")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.white)
                    Spacer()
                    Spacer().frame(width: 20)
                }
                .padding()

                if isLoading {
                    Spacer()
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    Spacer()
                } else if !errorMessage.isEmpty {
                    Spacer()
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding()
                    Spacer()
                } else if disputes.isEmpty {
                    Spacer()
                    VStack(spacing: 16) {
                        Image(systemName: "checkmark.shield")
                            .font(.system(size: 60))
                            .foregroundColor(.white.opacity(0.5))
                        Text("No disputes")
                            .font(.title3)
                            .foregroundColor(.white.opacity(0.7))
                        Text("You haven't filed any disputes")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.5))
                    }
                    Spacer()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(disputes) { dispute in
                                DisputeCard(dispute: dispute, currentUserId: userVM.profile?.id ?? "")
                            }
                        }
                        .padding()
                    }
                }
            }
        }
        .onAppear {
            loadDisputes()
        }
    }

    private func loadDisputes() {
        guard let userId = userVM.profile?.id else {
            errorMessage = "Unable to load disputes"
            isLoading = false
            return
        }

        disputeService.fetchDisputesForUser(userId: userId) { result in
            isLoading = false
            switch result {
            case .success(let fetchedDisputes):
                self.disputes = fetchedDisputes
            case .failure(let error):
                self.errorMessage = "Failed to load disputes: \(error.localizedDescription)"
            }
        }
    }
}

struct DisputeCard: View {
    let dispute: Dispute
    let currentUserId: String

    var isReporter: Bool {
        dispute.reporterId == currentUserId
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(dispute.taskTitle)
                        .font(.headline)
                        .foregroundColor(.white)

                    if isReporter {
                        Text("Dispute against @\(dispute.respondentUsername)")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.7))
                    } else {
                        Text("Dispute filed by @\(dispute.reporterUsername)")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.7))
                    }
                }

                Spacer()

                DisputeStatusBadge(status: dispute.status)
            }

            // Reason
            HStack {
                Image(systemName: "exclamationmark.circle.fill")
                    .foregroundColor(.orange)
                Text(dispute.reason.displayName)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
            }

            // Description
            Text(dispute.description)
                .font(.body)
                .foregroundColor(.white.opacity(0.9))
                .lineLimit(3)

            // Resolution (if resolved)
            if dispute.status == .resolved || dispute.status == .closed {
                Divider().background(Color.white.opacity(0.2))

                VStack(alignment: .leading, spacing: 4) {
                    if let notes = dispute.resolutionNotes {
                        Text("Resolution:")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.green)
                        Text(notes)
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.8))
                    }

                    if dispute.refundIssued, let amount = dispute.refundAmount {
                        HStack {
                            Image(systemName: "dollarsign.circle.fill")
                                .foregroundColor(.green)
                            Text("Refund issued: $\(Int(amount))")
                                .font(.caption)
                                .foregroundColor(.green)
                        }
                    }
                }
            }

            // Timestamp
            HStack {
                Text(dispute.timeAgo)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.5))

                if let resolvedAt = dispute.resolvedAt {
                    Spacer()
                    Text("Resolved: \(formatDate(resolvedAt))")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.5))
                }
            }
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(12)
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

struct DisputeStatusBadge: View {
    let status: DisputeStatus

    var body: some View {
        Text(status.displayName)
            .font(.caption)
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(statusColor)
            .cornerRadius(6)
    }

    private var statusColor: Color {
        switch status {
        case .open: return .orange
        case .underReview: return .blue
        case .resolved: return .green
        case .closed: return .gray
        }
    }
}

#Preview {
    DisputesView()
        .environmentObject(UserViewModel())
}
