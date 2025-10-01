//
//  ResponseView.swift
//  TaskMutual
//
//  Created by Romir Bulbule on 9/30/25.
//


import SwiftUI

struct ResponseView: View {
    var post: TaskPost
    @State private var message: String = ""
    var onSend: (String) -> Void

    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Text("Responding to: \(post.title)").font(.headline)
                TextField("Type your message...", text: $message)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Button("Send") {
                    onSend(message)
                }
                .disabled(message.isEmpty)
            }
            .padding()
            .navigationTitle("Respond")
        }
    }
}
