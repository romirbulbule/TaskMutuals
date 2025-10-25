//
//  ContentView.swift
//  TaskMutual
//
//  Created by Romir Bulbule on 9/22/25.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var userVM: UserViewModel
    
    var body: some View {
        RootSwitcherView()
            .environmentObject(authViewModel)
            .environmentObject(userVM)
    }
}
