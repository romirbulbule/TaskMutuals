//
//  MainTabView.swift
//  TaskMutual
//
//  Created by Romir Bulbule on 9/30/25.
//

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var userVM: UserViewModel
    @EnvironmentObject var tasksVM: TasksViewModel

    var body: some View {
        TabView {
            FeedView()
                .environmentObject(userVM)
                .environmentObject(tasksVM)
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Feed")
                }
            SearchView()
                .tabItem {
                    Image(systemName: "magnifyingglass")
                    Text("Search")
                }
            ChatView()
                .environmentObject(userVM)
                .tabItem {
                    Label("Chat", systemImage: "message")
                }
            ProfileView()
                .environmentObject(userVM)
                .tabItem {
                    Image(systemName: "person.crop.circle")
                    Text("Profile")
                }
        }
    }
}
