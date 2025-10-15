//
//  RootSwitcherView.swift
//  TaskMutual
//
//  Created by Romir Bulbule on 10/4/25.
//

import SwiftUI

struct RootSwitcherView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var userVM: UserViewModel

    @State private var firstName = ""
    @State private var lastName = ""
    @State private var didNameEntry = false
    @State private var hasShownSplash = false

    var body: some View {
        Group {
            // Show splash only once before moving on
            if !hasShownSplash {
                SplashScreen()
                    .onAppear {
                        // Simulate splash delay, then continue
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.7) {
                            hasShownSplash = true
                        }
                    }
            }
            // Not logged in: show login
            else if !authViewModel.isLoggedIn {
                LoginView()
            }
            // New user onboarding flow
            else if authViewModel.isNewUser && userVM.profile == nil && !didNameEntry {
                NameEntryView { fname, lname in
                    firstName = fname
                    lastName = lname
                    didNameEntry = true
                }
            }
            else if authViewModel.isNewUser && userVM.profile == nil && didNameEntry {
                UsernameEntryView(
                    firstName: firstName,
                    lastName: lastName,
                    userVM: userVM,
                    onFinish: {
                        userVM.fetchUserProfile()
                        authViewModel.isNewUser = false
                        didNameEntry = false
                        firstName = ""
                        lastName = ""
                    }
                )
            }
            // Main app (feed) — load profile data in background!
            else if authViewModel.isLoggedIn {
                ContentView()
                    .onAppear {
                        userVM.fetchUserProfile()
                    }
            }
        }
        .onChange(of: authViewModel.isLoggedIn) { isLoggedIn in
            if isLoggedIn {
                didNameEntry = false
                firstName = ""
                lastName = ""
                userVM.fetchUserProfile()
            } else {
                userVM.clearProfile()
            }
        }
    }
}
