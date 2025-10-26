//
//  RootSwitcherView.swift
//  TaskMutual
//
//  Created by Romir Bulbule on 10/4/25.
//

import SwiftUI
import FirebaseAuth

struct RootSwitcherView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var userVM: UserViewModel

    @State private var waitingForVerification = false
    @State private var hasShownSplash = false
    @State private var emailJustVerified = false
    @State private var minLoadingTimeReached = false

    var body: some View {
        ZStack {
            let _ = print("🔍 RootSwitcher - isLoggedIn: \(authViewModel.isLoggedIn), profile: \(userVM.profile?.username ?? "nil"), isLoadingProfile: \(userVM.isLoadingProfile)")

            // Splash screen always when starting the app
            if !hasShownSplash {
                SplashScreen()
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            hasShownSplash = true
                        }
                    }
            }
            // Loading profile after login/sign-up ONLY IF still loading profile
            else if authViewModel.isLoggedIn && (userVM.isLoadingProfile || !minLoadingTimeReached) {
                CustomLoadingView()
                    .onAppear {
                        // Only start the timer once per loading event
                        if !minLoadingTimeReached {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                minLoadingTimeReached = true
                                print("Timer fired!")
                            }
                        }
                    }
            }
            // Email verification waiting
            else if waitingForVerification {
                EmailVerificationWaitingView(
                    onVerified: {
                        emailJustVerified = true
                        waitingForVerification = false
                    },
                    onCancel: {
                        try? Auth.auth().signOut()
                        waitingForVerification = false
                        emailJustVerified = false
                    }
                )
            }
            // Profile setup flow
            else if (emailJustVerified || authViewModel.isLoggedIn) && userVM.profile == nil {
                ProfileSetupView()
                    .onAppear {
                        if !emailJustVerified {
                            userVM.fetchUserProfile()
                        }
                    }
            }
            // Login for not-logged in users
            else if !authViewModel.isLoggedIn {
                LoginView(
                    onEmailVerificationNeeded: {
                        waitingForVerification = true
                    }
                )
            }
            // Main app only if logged in and profile loaded
            else {
                MainTabView()
            }
        }
        .onChange(of: authViewModel.isLoggedIn) { isLoggedIn in
            if isLoggedIn {
                // New login or fetch: reset for next loading session
                minLoadingTimeReached = false
                userVM.fetchUserProfile()
            } else {
                // Reset when logged out
                minLoadingTimeReached = false
                emailJustVerified = false
                waitingForVerification = false
            }
        }
    }
}
