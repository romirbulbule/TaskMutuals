//
//  SearchView.swift
//  TaskMutual
//
//  Search view with text search functionality for tasks
//

import SwiftUI

extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content
    ) -> some View {
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}

struct SearchView: View {
    @EnvironmentObject var tasksVM: TasksViewModel
    @EnvironmentObject var userVM: UserViewModel
    @State private var query: String = ""
    @State private var results: [Task] = []
    @State private var isSearching = false

    var body: some View {
        NavigationView {
            ZStack {
                Theme.background.ignoresSafeArea()

                ScrollViewWithTabBar {
                    VStack(spacing: 28) {

                        // Search bar
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.black.opacity(0.6))
                            TextField("", text: $query)
                                .placeholder(when: query.isEmpty) {
                                    Text("Search tasks by title, description, or location...")
                                        .foregroundColor(.black.opacity(0.5))
                                        .font(.body)
                                }
                                .foregroundColor(.black)
                                .onChange(of: query) { newValue in
                                    performSearch(query: newValue)
                                }
                            if !query.isEmpty {
                                Button(action: {
                                    query = ""
                                    results = []
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.black.opacity(0.6))
                                }
                            }
                        }
                        .padding()
                        .background(Color.white.opacity(0.9))
                        .cornerRadius(10)
                        .padding(.horizontal)
                        .padding(.top, 8)

                        // Search results
                        if isSearching {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .padding()
                        } else if !query.isEmpty && results.isEmpty {
                            VStack(spacing: 12) {
                                Image(systemName: "magnifyingglass")
                                    .font(.system(size: 48))
                                    .foregroundColor(.white.opacity(0.5))
                                Text("No tasks found")
                                    .font(.headline)
                                    .foregroundColor(.white.opacity(0.7))
                                Text("Try searching with different keywords")
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.5))
                            }
                            .padding()
                        } else if !results.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Search Results (\(results.count))")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding(.horizontal)

                                ForEach(results) { task in
                                    NavigationLink(destination: TaskDetailView(task: task).environmentObject(userVM).environmentObject(tasksVM)) {
                                        TaskCardView(
                                            task: task,
                                            currentUserId: userVM.profile?.id ?? "",
                                            currentUserType: userVM.profile?.userType,
                                            onEdit: {},
                                            onDelete: {},
                                            onReport: {},
                                            onRespond: {}
                                        )
                                        .padding(.horizontal)
                                    }
                                }
                            }
                        }

                        // Category browsing (show when not searching)
                        if query.isEmpty {
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Browse by Category")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .padding(.horizontal)

                                ForEach(ServiceCategory.allCases, id: \.self) { category in
                                    Button(action: {
                                        searchByCategory(category)
                                    }) {
                                        HStack {
                                            Image(systemName: category.icon)
                                                .font(.system(size: 24))
                                                .foregroundColor(Theme.accent)
                                                .frame(width: 40)

                                            Text(category.rawValue)
                                                .font(.headline)
                                                .foregroundColor(.white)

                                            Spacer()

                                            Image(systemName: "chevron.right")
                                                .foregroundColor(.white.opacity(0.5))
                                        }
                                        .padding()
                                        .background(Color.white.opacity(0.1))
                                        .cornerRadius(12)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                    .padding(.bottom, 30)
                }
            }
            .navigationTitle("Search")
            .navigationBarTitleDisplayMode(.large)
        }
    }

    private func performSearch(query: String) {
        guard !query.isEmpty else {
            results = []
            return
        }

        isSearching = true

        // Simulate a short delay for search
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            let lowercasedQuery = query.lowercased()

            results = tasksVM.tasks.filter { task in
                // Don't show archived tasks in search
                guard !task.isArchived else { return false }

                // Search in title
                if task.title.lowercased().contains(lowercasedQuery) {
                    return true
                }

                // Search in description
                if task.description.lowercased().contains(lowercasedQuery) {
                    return true
                }

                // Search in location
                if let location = task.location, location.lowercased().contains(lowercasedQuery) {
                    return true
                }

                // Search in category
                if let category = task.category, category.rawValue.lowercased().contains(lowercasedQuery) {
                    return true
                }

                return false
            }

            isSearching = false
        }
    }

    private func searchByCategory(_ category: ServiceCategory) {
        query = category.rawValue
        performSearch(query: query)
    }
}

#Preview {
    SearchView()
        .environmentObject(TasksViewModel())
        .environmentObject(UserViewModel())
}
