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
            let _ = print("🔍 RootSwitcher - isLoggedIn: \(authViewModel.isLoggedIn), profile: \(userVM.profile?.username ?? "nil"), userType: \(userVM.profile?.userType?.rawValue ?? "nil"), isLoadingProfile: \(userVM.isLoadingProfile), minLoadingTimeReached: \(minLoadingTimeReached)")

            // Splash screen always when starting the app
            if !hasShownSplash {
                SplashScreen()
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            hasShownSplash = true
                            print("✅ Splash done")
                        }
                    }
            }
            // Loading profile after login/sign-up ONLY IF still loading profile
            else if authViewModel.isLoggedIn && (userVM.isLoadingProfile || !minLoadingTimeReached) {
                CustomLoadingView()
                    .onAppear {
                        print("⏳ Showing loading screen - isLoadingProfile: \(userVM.isLoadingProfile), minLoadingTimeReached: \(minLoadingTimeReached)")
                        // Only start the timer once per loading event
                        if !minLoadingTimeReached {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                minLoadingTimeReached = true
                                print("✅ Timer fired! minLoadingTimeReached = true")
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
            // User type selection (after profile created but before main app)
            else if authViewModel.isLoggedIn && userVM.profile != nil && userVM.profile?.userType == nil {
                UserTypeSelectionView()
            }
            // Login for not-logged in users
            else if !authViewModel.isLoggedIn {
                LoginView(
                    onEmailVerificationNeeded: {
                        waitingForVerification = true
                    }
                )
            }
            // Main app only if logged in, profile loaded, and user type selected
            else {
                MainTabView()
            }
        }
        .onAppear {
            print("🚀 RootSwitcherView appeared - isLoggedIn: \(authViewModel.isLoggedIn)")

            // TEMPORARY FIX: Uncomment these 3 lines to sign out and start fresh
            try? Auth.auth().signOut()
            authViewModel.currentUser = nil
            userVM.clearProfile()

            // Fetch profile on app start if user is already logged in
            if authViewModel.isLoggedIn && userVM.profile == nil && !userVM.isLoadingProfile {
                print("🔄 Fetching profile on app start")
                userVM.fetchUserProfile()
            }
        }
        .onChange(of: authViewModel.isLoggedIn) { isLoggedIn in
            print("🔄 isLoggedIn changed to: \(isLoggedIn)")
            if isLoggedIn {
                // New login or fetch: reset for next loading session
                minLoadingTimeReached = false
                userVM.resetFetchState()
                userVM.fetchUserProfile()
            } else {
                // Reset when logged out
                minLoadingTimeReached = false
                emailJustVerified = false
                waitingForVerification = false
                userVM.clearProfile()
            }
        }
    }
}
