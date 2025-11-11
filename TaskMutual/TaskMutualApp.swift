//
//  TaskMutualApp.swift
//  TaskMutual
//
//  Created by Romir Bulbule on 9/22/25.
//

import SwiftUI
import FirebaseCore
import FirebaseAuth  // ← Added this import for Auth.auth()

@main
struct TaskMutualApp: App {
    @StateObject private var authViewModel = AuthViewModel()
    @StateObject private var userVM = UserViewModel()
    @StateObject private var tasksVM = TasksViewModel()
    @ObservedObject private var notificationManager = NotificationManager.shared
    @State private var showSplash = true

    init() {
        FirebaseApp.configure()

        // Configure RevenueCat for In-App Purchases
        PurchaseManager.configure()  // Uncomment after adding RevenueCat package

        UITabBar.appearance().barTintColor = UIColor(named: "AppBackground")
        UITabBar.appearance().backgroundColor = UIColor(named: "AppBackground")
        UITabBar.appearance().unselectedItemTintColor = UIColor.white.withAlphaComponent(0.5)
        UITabBar.appearance().tintColor = UIColor.white
    }
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                if showSplash {
                    SplashScreen()
                        .environmentObject(authViewModel)
                        .environmentObject(userVM)
                        .environmentObject(tasksVM)
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                showSplash = false
                            }
                        }
                } else {
                    RootSwitcherView()
                        .environmentObject(authViewModel)
                        .environmentObject(userVM)
                        .environmentObject(tasksVM)
                        .onAppear {
                            // Request notification permissions
                            NotificationManager.shared.requestPermission()
                        }
                        .onChange(of: userVM.profile) { profile in
                            // Update TasksViewModel with user profile for filtering
                            tasksVM.setUserProfile(profile)
                        }
                }

                // In-app notification banner overlay
                if let bannerData = NotificationManager.shared.currentBanner {
                    InAppNotificationBanner(
                        data: bannerData,
                        onTap: {
                            // Navigate to chat
                            navigateToChat(chatId: bannerData.chatId)
                        },
                        onDismiss: {
                            NotificationManager.shared.dismissBanner()
                        }
                    )
                    .zIndex(999) // Ensure banner appears above everything
                }
            }
        }
    }

    // Navigate to chat when banner is tapped
    private func navigateToChat(chatId: String) {
        // Post notification to trigger navigation
        NotificationCenter.default.post(
            name: NSNotification.Name("NavigateToChat"),
            object: nil,
            userInfo: ["chatId": chatId]
        )
        NotificationManager.shared.dismissBanner()
    }
}


