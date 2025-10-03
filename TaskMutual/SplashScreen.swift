//
//  SplashScreen.swift
//  TaskMutual
//
//  Created by Romir Bulbule on 9/28/25.
//

import SwiftUI

struct SplashScreen: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var animate = false
    @State private var showContent = false

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()

            if showContent {
                
                if authViewModel.isLoggedIn {
                    FeedView()
                } else {
                    LoginView()
                }
            } else {
                // Splash animation/logo
                Image("AppLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: animate ? 140 : 100, height: animate ? 140 : 100)
                    .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
                    .shadow(color: Color.black.opacity(0.18), radius: 8, x: 0, y: 4)
                    .opacity(animate ? 1.0 : 0.0)
                    .onAppear {
                        withAnimation(.easeOut(duration: 0.7)) {
                            animate = true
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) {
                            withAnimation(.easeIn(duration: 0.3)) {
                                showContent = true
                            }
                        }
                    }
            }
        }
    }
}












