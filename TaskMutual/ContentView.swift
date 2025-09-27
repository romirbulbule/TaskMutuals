//
//  ContentView.swift
//  TaskMutual
//
//  Created by Romir Bulbule on 9/22/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject var authViewModel = AuthViewModel()
    

    var body: some View {
        Group {
            if authViewModel.user != nil {
                MainFeedView()
                    .environmentObject(authViewModel)  // Passing the environment object DOWN
            } else {
                LoginView()
                    .environmentObject(authViewModel)  // Passing the environment object DOWN
            }
        }
    }
}
