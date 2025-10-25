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
                // Splash animation/logo
                Image("AppLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: animate ? 140 : 100, height: animate ? 140 : 100)
                    .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
                    .shadow(color: Color.black.opacity(0.1), radius: animate ? 10 : 8)
            }
        }
        .onAppear {
            showContent = true
            withAnimation(.easeInOut(duration: 0.8)) {
                animate = true
            }
        }
    }
}













