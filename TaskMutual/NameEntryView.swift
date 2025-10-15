//
//  NameEntryView.swift
//  TaskMutual
//
//  Created by Romir Bulbule on 10/4/25.
//


import SwiftUI

struct NameEntryView: View {
    @State private var firstName = ""
    @State private var lastName = ""
    var onNext: (_ firstName: String, _ lastName: String) -> Void

    var body: some View {
        VStack(spacing: 24) {
            Text("Enter Your Name")
                .font(.title)

            TextField("First Name", text: $firstName)
                .autocapitalization(.words)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)

            TextField("Last Name", text: $lastName)
                .autocapitalization(.words)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)

            Button("Next") {
                onNext(firstName, lastName)
            }
            .disabled(firstName.isEmpty || lastName.isEmpty)
        }
        .padding()
    }
}
