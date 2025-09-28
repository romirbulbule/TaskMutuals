//
//  TaskMutualsFeedView.swift
//  TaskMutual
//
//  Created by Romir Bulbule on 9/26/25.
//


import SwiftUI

struct TaskMutualFeedView: View {
    @StateObject private var feedVM = TaskMutualFeedViewModel()
    @State private var showingPostSheet = false

    var body: some View {
        NavigationView {
            List(feedVM.posts) { post in
                VStack(alignment: .leading) {
                    Text(post.title).font(.headline)
                    Text(post.description).font(.subheadline)
                }
                .padding(.vertical, 8)
            }
            .navigationTitle("TaskMutual Feed")
            .toolbar {
                Button(action: { showingPostSheet = true }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title)
                }
            }
            .sheet(isPresented: $showingPostSheet) {
                PostTaskView(feedVM: feedVM)
            }
        }
    }
}






