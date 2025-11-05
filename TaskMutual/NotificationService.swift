//
//  NotificationService.swift
//  TaskMutual
//
//  Service for managing push notifications and in-app notifications
//

import Foundation
import FirebaseFirestore
import UserNotifications

class NotificationService: ObservableObject {
    private let db = Firestore.firestore()
    @Published var notifications: [AppNotification] = []
    @Published var unreadCount: Int = 0

    private var listener: ListenerRegistration?

    // MARK: - Request Push Notification Permission
    func requestPushNotificationPermission(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("❌ Push notification permission error: \(error.localizedDescription)")
                    completion(false)
                } else {
                    print(granted ? "✅ Push notifications authorized" : "❌ Push notifications denied")
                    completion(granted)
                }
            }
        }
    }

    // MARK: - Create Notification
    func createNotification(
        userId: String,
        type: NotificationType,
        title: String,
        body: String,
        taskId: String? = nil,
        chatId: String? = nil,
        paymentId: String? = nil,
        ratingId: String? = nil,
        senderUserId: String? = nil,
        senderUsername: String? = nil,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        let notification = AppNotification(
            userId: userId,
            type: type,
            title: title,
            body: body,
            taskId: taskId,
            chatId: chatId,
            paymentId: paymentId,
            ratingId: ratingId,
            senderUserId: senderUserId,
            senderUsername: senderUsername
        )

        do {
            let notificationData = try Firestore.Encoder().encode(notification)
            db.collection("notifications").addDocument(data: notificationData) { error in
                DispatchQueue.main.async {
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        // Send local push notification
                        self.sendLocalPushNotification(title: title, body: body)
                        completion(.success(()))
                    }
                }
            }
        } catch {
            DispatchQueue.main.async {
                completion(.failure(error))
            }
        }
    }

    // MARK: - Send Local Push Notification
    private func sendLocalPushNotification(title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Failed to send local notification: \(error.localizedDescription)")
            }
        }
    }

    // MARK: - Fetch Notifications for User
    func startListeningToNotifications(userId: String) {
        // Remove existing listener
        listener?.remove()

        listener = db.collection("notifications")
            .whereField("userId", isEqualTo: userId)
            .order(by: "createdAt", descending: true)
            .limit(to: 50)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }

                if let error = error {
                    print("❌ Error fetching notifications: \(error.localizedDescription)")
                    return
                }

                var fetchedNotifications: [AppNotification] = []

                if let documents = snapshot?.documents {
                    for doc in documents {
                        if let notification = try? doc.data(as: AppNotification.self) {
                            fetchedNotifications.append(notification)
                        }
                    }
                }

                DispatchQueue.main.async {
                    self.notifications = fetchedNotifications
                    self.unreadCount = fetchedNotifications.filter { !$0.isRead }.count
                }
            }
    }

    // MARK: - Mark Notification as Read
    func markAsRead(notificationId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        db.collection("notifications").document(notificationId).updateData([
            "isRead": true
        ]) { error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
        }
    }

    // MARK: - Mark All Notifications as Read
    func markAllAsRead(userId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        db.collection("notifications")
            .whereField("userId", isEqualTo: userId)
            .whereField("isRead", isEqualTo: false)
            .getDocuments { snapshot, error in
                if let error = error {
                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                    return
                }

                let batch = self.db.batch()

                snapshot?.documents.forEach { doc in
                    batch.updateData(["isRead": true], forDocument: doc.reference)
                }

                batch.commit { error in
                    DispatchQueue.main.async {
                        if let error = error {
                            completion(.failure(error))
                        } else {
                            completion(.success(()))
                        }
                    }
                }
            }
    }

    // MARK: - Delete Notification
    func deleteNotification(notificationId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        db.collection("notifications").document(notificationId).delete { error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
        }
    }

    // MARK: - Cleanup
    deinit {
        listener?.remove()
    }

    // MARK: - Helper Methods for Common Notifications

    func notifyNewResponse(taskId: String, taskTitle: String, taskCreatorId: String, responderUsername: String, responderUserId: String) {
        createNotification(
            userId: taskCreatorId,
            type: .newResponse,
            title: "New Response",
            body: "@\(responderUsername) responded to your task: \(taskTitle)",
            taskId: taskId,
            senderUserId: responderUserId,
            senderUsername: responderUsername
        ) { _ in }
    }

    func notifyResponseAccepted(taskId: String, taskTitle: String, providerId: String, seekerUsername: String, seekerUserId: String) {
        createNotification(
            userId: providerId,
            type: .responseAccepted,
            title: "Response Accepted!",
            body: "@\(seekerUsername) accepted your response for: \(taskTitle)",
            taskId: taskId,
            senderUserId: seekerUserId,
            senderUsername: seekerUsername
        ) { _ in }
    }

    func notifyTaskCompleted(taskId: String, taskTitle: String, providerId: String, seekerUsername: String) {
        createNotification(
            userId: providerId,
            type: .taskCompleted,
            title: "Task Completed",
            body: "\(taskTitle) has been marked as completed by @\(seekerUsername)",
            taskId: taskId
        ) { _ in }
    }

    func notifyNewMessage(chatId: String, recipientId: String, senderUsername: String, senderUserId: String, messagePreview: String) {
        createNotification(
            userId: recipientId,
            type: .newMessage,
            title: "New Message",
            body: "@\(senderUsername): \(messagePreview)",
            chatId: chatId,
            senderUserId: senderUserId,
            senderUsername: senderUsername
        ) { _ in }
    }

    func notifyPaymentReceived(paymentId: String, amount: Double, providerId: String, payerUsername: String) {
        createNotification(
            userId: providerId,
            type: .paymentReceived,
            title: "Payment Received",
            body: "You received $\(Int(amount)) from @\(payerUsername)",
            paymentId: paymentId
        ) { _ in }
    }

    func notifyNewRating(ratingId: String, rating: Int, providerId: String, reviewerUsername: String) {
        createNotification(
            userId: providerId,
            type: .newRating,
            title: "New Rating",
            body: "@\(reviewerUsername) rated you \(rating) stars",
            ratingId: ratingId
        ) { _ in }
    }
}
