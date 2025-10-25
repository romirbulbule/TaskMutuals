//
//  UsernameEntryView.swift
//  TaskMutual
//
//  Created by Romir Bulbule on 10/4/25.
//

import SwiftUI

struct UsernameEntryView: View {
    let firstName: String
    let lastName: String
    let dateOfBirth: Date  // ← Add this
    @ObservedObject var userVM: UserViewModel
    var onFinish: () -> Void

    @State private var username: String
    @State private var error = ""

    init(
        firstName: String,
        lastName: String,
        username: String,
        dateOfBirth: Date,  // ← Add this
        userVM: UserViewModel,
        onFinish: @escaping () -> Void
    ) {
        self.firstName = firstName
        self.lastName = lastName
        self._username = State(initialValue: username)
        self.dateOfBirth = dateOfBirth  // ← Add this
        self.userVM = userVM
        self.onFinish = onFinish
    }

    var body: some View {
        VStack(spacing: 32) {
            Text("Pick a Unique Username")
                .font(.title2).bold()
            TextField("Username", text: $username)
                .autocapitalization(.none)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
            Button("Finish Setup") {
                userVM.createOrUpdateProfile(
                    firstName: firstName,
                    lastName: lastName,
                    username: username,
                    dateOfBirth: dateOfBirth  // ← Add this
                ) { result in
                    switch result {
                    case .success:
                        error = ""
                        userVM.fetchUserProfile()
                        onFinish()
                    case .failure(let err):
                        error = err.localizedDescription
                    }
                }
            }
            .disabled(username.isEmpty)
            if !error.isEmpty {
                Text(error).foregroundColor(.red)
            }
        }
        .padding()
    }
}

