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
    @State private var showSplash = true

    init() {
        FirebaseApp.configure()

        UITabBar.appearance().barTintColor = UIColor(named: "BrandBackground")
        UITabBar.appearance().backgroundColor = UIColor(named: "BrandBackground")
        UITabBar.appearance().unselectedItemTintColor = UIColor.white.withAlphaComponent(0.5)
        UITabBar.appearance().tintColor = UIColor.white
    }
    
    var body: some Scene {
        WindowGroup {
            if showSplash {
                SplashScreen()
                    .environmentObject(authViewModel)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            showSplash = false
                        }
                    }
            } else {
                RootSwitcherView()
                    .environmentObject(authViewModel)
                    .environmentObject(userVM)
            }
        }
    }
}


