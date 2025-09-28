//
//  TaskMutualApp.swift
//  TaskMutual
//
//  Created by Romir Bulbule on 9/22/25.
//

import SwiftUI
import FirebaseCore

@main
struct TaskMutualApp: App {
    @StateObject private var authViewModel = AuthViewModel()
    @State private var showSplash = true

    init() { FirebaseApp.configure() }

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
                ContentView()
                    .environmentObject(authViewModel)
            }
        }
    }
}
