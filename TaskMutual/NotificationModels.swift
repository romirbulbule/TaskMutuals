//
//  NotificationModels.swift
//  TaskMutual
//
//  Models for in-app and push notifications
//

import Foundation
import FirebaseFirestore

// MARK: - Notification Type
enum NotificationType: String, Codable {
    case newResponse = "new_response"
    case responseAccepted = "response_accepted"
    case taskCompleted = "task_completed"
    case newMessage = "new_message"
    case paymentReceived = "payment_received"
    case newRating = "new_rating"

    var icon: String {
        switch self {
        case .newResponse: return "bubble.left.fill"
        case .responseAccepted: return "checkmark.circle.fill"
        case .taskCompleted: return "flag.checkered"
        case .newMessage: return "envelope.fill"
        case .paymentReceived: return "dollarsign.circle.fill"
        case .newRating: return "star.fill"
        }
    }

    var color: String {
        switch self {
        case .newResponse: return "blue"
        case .responseAccepted: return "green"
        case .taskCompleted: return "purple"
        case .newMessage: return "orange"
        case .paymentReceived: return "green"
        case .newRating: return "yellow"
        }
    }
}

// MARK: - Notification Model
struct AppNotification: Identifiable, Codable, Equatable {
    @DocumentID var id: String?
    var userId: String // Recipient of the notification
    var type: NotificationType
    var title: String
    var body: String
    var createdAt: Date = Date()
    var isRead: Bool = false

    // Optional reference IDs
    var taskId: String?
    var chatId: String?
    var paymentId: String?
    var ratingId: String?

    // Sender info
    var senderUserId: String?
    var senderUsername: String?

    // Custom Equatable implementation (needed for @DocumentID)
    static func == (lhs: AppNotification, rhs: AppNotification) -> Bool {
        return lhs.id == rhs.id &&
               lhs.userId == rhs.userId &&
               lhs.type == rhs.type &&
               lhs.isRead == rhs.isRead
    }
}

// MARK: - Helper Extensions
extension AppNotification {
    var timeAgo: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: createdAt, relativeTo: Date())
    }
}
