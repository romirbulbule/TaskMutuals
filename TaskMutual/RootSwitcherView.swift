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

    var body: some View {
        ZStack {
            // DEBUG - see what's happening
                   let _ = print("🔍 RootSwitcher - isLoggedIn: \(authViewModel.isLoggedIn), profile: \(userVM.profile?.username ?? "nil")")
                   
            // 1. Splash
            if !hasShownSplash {
                SplashScreen()
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.7) {
                            hasShownSplash = true
                        }
                    }
            }
            
            // 2. Waiting for email verification
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
            
            // 3. Email just verified OR logged in without profile - show ProfileSetup
            else if (emailJustVerified || authViewModel.isLoggedIn) && userVM.profile == nil {

                ProfileSetupView()
                    .onAppear {
                        if !emailJustVerified {
                            userVM.fetchUserProfile()
                        }
                    }
            }
            
            // 4. Not logged in - show Login/SignUp
            else if !authViewModel.isLoggedIn {
                LoginView(onEmailVerificationNeeded: {
                    waitingForVerification = true
                })
            }
            
            // 5. Logged in with profile - show main app
            else {
                MainTabView()
                    .onAppear {
                        userVM.fetchUserProfile()
                    }
            }
        }
        .onChange(of: authViewModel.isLoggedIn) { isLoggedIn in
            if isLoggedIn {
                userVM.fetchUserProfile()
            } else {
                emailJustVerified = false
                waitingForVerification = false
            }
        }
    }
}
