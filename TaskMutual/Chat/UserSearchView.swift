//
//  UserSearchView.swift
//  TaskMutual
//
//  Created by Romir Bulbule on 10/26/25.
//


import SwiftUI

struct UserSearchView: View {
    @ObservedObject var userVM: UserViewModel
    let onSelectUser: (UserProfile) -> Void
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            ZStack {
                Theme.background.ignoresSafeArea()
                VStack {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        TextField("Find user...", text: $userVM.searchText)
                            .textFieldStyle(PlainTextFieldStyle())
                            .foregroundColor(.primary)
                            .font(.system(size: 17))
                    }
                    .padding(10)
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .padding(.horizontal)
                    List(userVM.filteredUsers) { user in
                        Button(action: {
                            onSelectUser(user)
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            HStack {
                                Circle()
                                    .fill(Color(.systemBlue))
                                    .frame(width: 36, height: 36)
                                    .overlay(Text(user.username.prefix(1).uppercased()).foregroundColor(.white))
                                VStack(alignment: .leading) {
                                    Text(user.username)
                                        .font(.body).bold()
                                        .foregroundColor(.primary)
                                    Text(user.firstName + " " + user.lastName)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding(8)
                        }
                        .listRowSeparator(.hidden)
                        .listRowBackground(Theme.background)
                    }
                    .listStyle(.plain)
                }
                .navigationTitle("Start Chat")
                .onAppear { userVM.fetchAllUsers() }
            }
        }
    }
}
