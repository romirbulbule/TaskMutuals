//
//  AppDelegate.swift
//  TaskMutual
//
//  Handles Firebase Cloud Messaging setup and APNs token registration
//

import UIKit
import FirebaseCore
import FirebaseMessaging
import FirebaseAuth
import FirebaseFirestore

class AppDelegate: NSObject, UIApplicationDelegate, MessagingDelegate {

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {

        // Register for remote notifications
        UNUserNotificationCenter.current().delegate = NotificationManager.shared

        // Set messaging delegate
        Messaging.messaging().delegate = self

        // Register for remote notifications
        application.registerForRemoteNotifications()

        return true
    }

    // MARK: - APNs Token Registration

    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        // Pass device token to Firebase
        Messaging.messaging().apnsToken = deviceToken
        print("✅ APNs token registered with Firebase")
    }

    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        print("❌ Failed to register for remote notifications: \(error.localizedDescription)")
    }

    // MARK: - MessagingDelegate

    func messaging(
        _ messaging: Messaging,
        didReceiveRegistrationToken fcmToken: String?
    ) {
        guard let fcmToken = fcmToken else { return }

        print("✅ FCM Token: \(fcmToken)")

        // Save token to Firestore
        saveFCMToken(fcmToken)
    }

    private func saveFCMToken(_ token: String) {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("⚠️ No user logged in, cannot save FCM token")
            return
        }

        let db = Firestore.firestore()
        db.collection("users").document(userId).setData([
            "fcmToken": token,
            "fcmTokenUpdatedAt": Date()
        ], merge: true) { error in
            if let error = error {
                print("❌ Error saving FCM token: \(error.localizedDescription)")
            } else {
                print("✅ FCM token saved to Firestore")
            }
        }
    }

    // MARK: - Handle Remote Notifications

    func application(
        _ application: UIApplication,
        didReceiveRemoteNotification userInfo: [AnyHashable: Any],
        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    ) {
        // Let NotificationManager handle the notification
        NotificationManager.shared.handleRemoteNotification(userInfo: userInfo)
        completionHandler(.newData)
    }
}
