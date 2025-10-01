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
    @State private var selectedPost: TaskPost?
    @State private var showingEditSheet = false
    @State private var showingReportAlert = false
    @State private var showingResponseSheet = false

    var body: some View {
        NavigationView {
            List {
                ForEach(feedVM.posts) { post in
                    Button(action: {
                        selectedPost = post
                        showingEditSheet = true // Show edit on tap
                    }) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(post.title)
                                .font(.headline)
                            Text(post.description)
                                .font(.subheadline)
                        }
                        .padding(.vertical, 8)
                    }
                    .buttonStyle(PlainButtonStyle()) // Looks like a regular cell, not a blue button
                    .contextMenu {
                        Button("Edit") {
                            selectedPost = post
                            showingEditSheet = true
                        }
                        Button("Delete") {
                            if let idx = feedVM.posts.firstIndex(of: post) {
                                feedVM.deletePosts(at: IndexSet(integer: idx))
                            }
                        }
                        Button("Report") {
                            feedVM.reportPost(post: post)
                            showingReportAlert = true
                        }
                        Button("Respond") {
                            selectedPost = post
                            showingResponseSheet = true
                        }
                    }
                }
                .onDelete { indexSet in
                    feedVM.deletePosts(at: indexSet)
                }
            }
            .navigationTitle("TaskMutual Feed")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingPostSheet = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title)
                    }
                }
            }
            .sheet(isPresented: $showingPostSheet) {
                PostTaskView { title, description in
                    feedVM.addPost(title: title, description: description)
                }
            }
            .sheet(isPresented: $showingEditSheet) {
                if let post = selectedPost {
                    EditTaskView(post: post) { title, description in
                        feedVM.editPost(post: post, newTitle: title, newDescription: description)
                        showingEditSheet = false
                    }
                }
            }
            .alert(isPresented: $showingReportAlert) {
                Alert(title: Text("Reported"), message: Text("You've reported this task."), dismissButton: .default(Text("OK")))
            }
            .sheet(isPresented: $showingResponseSheet) {
                if let post = selectedPost {
                    ResponseView(post: post) { message in
                        // Handle/store response as needed
                        showingResponseSheet = false
                    }
                }
            }
        }
    }
}





