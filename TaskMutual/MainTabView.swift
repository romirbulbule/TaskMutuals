//
//  MainTabView.swift
//  TaskMutual
//
//  Created by Romir Bulbule on 9/30/25.
//

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var userVM: UserViewModel

    var body: some View {
        TabView {
            FeedView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Feed")
                }
            SearchView()
                .tabItem {
                    Image(systemName: "magnifyingglass")
                    Text("Search")
                }
            // Pass userVM from the shared environment.
            ChatView()
                .environmentObject(userVM)
                .tabItem {
                    Label("Chat", systemImage: "message")
                }
            ProfileView()
                .tabItem {
                    Image(systemName: "person.crop.circle")
                    Text("Profile")
                }
        }
    }
}
