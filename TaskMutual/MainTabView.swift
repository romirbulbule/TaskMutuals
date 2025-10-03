//
//  MainTabView.swift
//  TaskMutual
//
//  Created by Romir Bulbule on 9/30/25.
//


import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            FeedView()
                .tabItem {
                    Image(systemName: "house.fill")
                        .foregroundColor(.white)
                    Text("Feed")
                }
            SearchView()
                .tabItem {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.white)
                    Text("Search")
                }
            ProfileView()
                .tabItem {
                    Image(systemName: "person.crop.circle")
                        .foregroundColor(.white) // Explicitly set icon color if needed
                    Text("Profile")
                }
            }
        }
    }


