//
//  SearchView.swift
//  TaskMutual
//
//  Created by Romir Bulbule on 9/30/25.
//


import SwiftUI

extension View {
    // Custom placeholder appearance for TextField
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content) -> some View {
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}

struct SearchView: View {
    @State private var query: String = ""
    @State private var results: [Task] = []

    var body: some View {
        NavigationView {
            VStack(spacing: 18) {
                // TextField with visible placeholder
                TextField("", text: $query)
                    .placeholder(when: query.isEmpty) {
                        Text("Search tasks...")
                            .foregroundColor(.white)
                            .font(.body)
                    }
                    .padding()
                    .background(Color.white.opacity(0.15))
                    .cornerRadius(10)
                    .foregroundColor(.white)
                    .padding(.horizontal)

                List {
                    ForEach(results) { task in
                        VStack(alignment: .leading) {
                            Text(task.title)
                                .font(.headline)
                                .foregroundColor(Theme.accent)
                            Text(task.description)
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.8))
                        }
                        .padding(.vertical, 4)
                        .background(Theme.background)
                    }
                }
                .listStyle(.plain)
                .background(Theme.background)
            }
            .background(Theme.background)
            .navigationTitle("Search")
            .foregroundColor(.white)
        }
        .background(Theme.background.ignoresSafeArea())
    }
}
