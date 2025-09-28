//
//  MainFeedView.swift
//  TaskMutual
//
//  Created by Romir Bulbule on 9/23/25.
//


import SwiftUI

struct MainFeedView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showFeed = false

    var body: some View {
        if showFeed {
            TaskMutualFeedView() // This is your new "Instagram-style" feed layout
                .environmentObject(authViewModel)
        } else {
            VStack(spacing: 24) {
                Text("Welcome to TaskMutual Feed!")
                    .font(.title)
                Button("Continue") {
                    showFeed = true
                }
                .buttonStyle(.borderedProminent)
                Button("Sign Out") {
                    authViewModel.signOut()
                }
                .foregroundColor(.red)
            }
            .padding()
        }
    }
}

















