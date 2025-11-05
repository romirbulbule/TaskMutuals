//
//  Dispute.swift
//  TaskMutual
//
//  Models for task dispute resolution
//

import Foundation
import FirebaseFirestore

// MARK: - Dispute Status
enum DisputeStatus: String, Codable {
    case open = "open"
    case underReview = "under_review"
    case resolved = "resolved"
    case closed = "closed"

    var displayName: String {
        switch self {
        case .open: return "Open"
        case .underReview: return "Under Review"
        case .resolved: return "Resolved"
        case .closed: return "Closed"
        }
    }

    var color: String {
        switch self {
        case .open: return "orange"
        case .underReview: return "blue"
        case .resolved: return "green"
        case .closed: return "gray"
        }
    }
}

// MARK: - Dispute Reason
enum DisputeReason: String, Codable, CaseIterable {
    case taskNotCompleted = "task_not_completed"
    case poorQuality = "poor_quality"
    case noShow = "no_show"
    case paymentIssue = "payment_issue"
    case communication = "communication_issue"
    case other = "other"

    var displayName: String {
        switch self {
        case .taskNotCompleted: return "Task Not Completed"
        case .poorQuality: return "Poor Quality Work"
        case .noShow: return "Provider No-Show"
        case .paymentIssue: return "Payment Issue"
        case .communication: return "Communication Issue"
        case .other: return "Other"
        }
    }
}

// MARK: - Dispute Model
struct Dispute: Identifiable, Codable, Equatable {
    @DocumentID var id: String?
    var taskId: String
    var taskTitle: String
    var reason: DisputeReason
    var description: String
    var status: DisputeStatus = .open
    var createdAt: Date = Date()
    var resolvedAt: Date?

    // Parties involved
    var reporterId: String // Person filing the dispute
    var reporterUsername: String
    var respondentId: String // Person the dispute is against
    var respondentUsername: String

    // Resolution
    var resolutionNotes: String?
    var refundIssued: Bool = false
    var refundAmount: Double?

    // Custom Equatable implementation (needed for @DocumentID)
    static func == (lhs: Dispute, rhs: Dispute) -> Bool {
        return lhs.id == rhs.id &&
               lhs.taskId == rhs.taskId &&
               lhs.status == rhs.status
    }
}

// MARK: - Dispute Extensions
extension Dispute {
    var timeAgo: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: createdAt, relativeTo: Date())
    }
}
