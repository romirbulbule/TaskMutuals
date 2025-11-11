//
//  NotificationManager.swift
//  TaskMutual
//
//  Manages local and push notifications for the app
//

import Foundation
import UserNotifications
import UIKit
import SwiftUI

// Data model for in-app notification banner
struct InAppNotificationData: Identifiable {
    let id = UUID()
    let senderName: String
    let message: String
    let chatId: String
    let senderId: String
    let profileImageURL: String?
}

class NotificationManager: NSObject, ObservableObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationManager()

    @Published var hasPermission = false
    @Published var currentBanner: InAppNotificationData?

    private override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
        checkPermission()
    }

    // Request notification permission
    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            DispatchQueue.main.async {
                self.hasPermission = granted
                if granted {
                    print("✅ Notification permission granted")
                } else if let error = error {
                    print("❌ Notification permission error: \(error)")
                }
            }
        }
    }

    // Check current permission status
    func checkPermission() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.hasPermission = settings.authorizationStatus == .authorized
            }
        }
    }

    // Send local notification for new message
    func sendMessageNotification(from senderName: String, message: String, chatId: String, senderId: String, profileImageURL: String? = nil) {
        let content = UNMutableNotificationContent()
        content.title = senderName
        content.body = message
        content.sound = .default
        content.badge = NSNumber(value: UIApplication.shared.applicationIconBadgeNumber + 1)
        content.userInfo = [
            "chatId": chatId,
            "senderId": senderId,
            "senderName": senderName,
            "profileImageURL": profileImageURL ?? ""
        ]

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil // Deliver immediately
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Error sending notification: \(error)")
            } else {
                print("✅ Notification sent for message from \(senderName)")
            }
        }
    }

    // Show in-app notification banner
    func showInAppBanner(senderName: String, message: String, chatId: String, senderId: String, profileImageURL: String? = nil) {
        DispatchQueue.main.async {
            // Trigger haptic feedback
            HapticsManager.shared.success()

            // Show banner
            self.currentBanner = InAppNotificationData(
                senderName: senderName,
                message: message,
                chatId: chatId,
                senderId: senderId,
                profileImageURL: profileImageURL
            )

            print("✅ Showing in-app banner for message from \(senderName)")
        }
    }

    // Dismiss in-app banner
    func dismissBanner() {
        DispatchQueue.main.async {
            self.currentBanner = nil
        }
    }

    // MARK: - UNUserNotificationCenterDelegate

    // Handle notification when app is in foreground
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        let userInfo = notification.request.content.userInfo

        // Extract notification data
        let senderName = userInfo["senderName"] as? String ?? "Someone"
        let message = notification.request.content.body
        let chatId = userInfo["chatId"] as? String ?? ""
        let senderId = userInfo["senderId"] as? String ?? ""
        let profileImageURL = userInfo["profileImageURL"] as? String

        // Show custom in-app banner instead of system notification
        showInAppBanner(
            senderName: senderName,
            message: message,
            chatId: chatId,
            senderId: senderId,
            profileImageURL: profileImageURL
        )

        // Don't show system notification banner (we're showing custom one)
        completionHandler([.sound, .badge])
    }

    // Handle notification tap (when app in background)
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo

        // TODO: Navigate to chat when notification is tapped
        // This will be handled by the app's navigation system

        print("📱 User tapped notification for chat: \(userInfo["chatId"] ?? "")")
        completionHandler()
    }

    // Update app badge count
    func updateBadgeCount(_ count: Int) {
        DispatchQueue.main.async {
            UIApplication.shared.applicationIconBadgeNumber = count
        }
    }

    // Clear all notifications
    func clearAllNotifications() {
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        updateBadgeCount(0)
    }

    // Clear notifications for specific chat
    func clearNotifications(for chatId: String) {
        UNUserNotificationCenter.current().getDeliveredNotifications { notifications in
            let identifiers = notifications
                .filter { ($0.request.content.userInfo["chatId"] as? String) == chatId }
                .map { $0.request.identifier }

            UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: identifiers)
        }
    }
}
