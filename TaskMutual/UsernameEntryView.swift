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
    @ObservedObject var userVM: UserViewModel
    @State private var username = ""
    @State private var error = ""
    var onFinish: () -> Void

    var body: some View {
        VStack(spacing: 32) {
            Text("Pick a Unique Username")
                .font(.title2)
                .bold()
            TextField("Username", text: $username)
                .autocapitalization(.none)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
            Button("Finish Setup") {
                userVM.createOrUpdateProfile(
                    firstName: firstName,
                    lastName: lastName,
                    username: username
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

