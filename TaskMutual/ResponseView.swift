//
//  ResponseView.swift
//  TaskMutual
//
//  Created by Romir Bulbule on 9/30/25.
//

import SwiftUI

struct ResponseView: View {
    var post: Task
    @State private var message: String = ""
    var onSend: (String) -> Void
    @State private var didSend = false

    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                if didSend {
                    Text("Your response was sent!").foregroundColor(.green)
                } else {
                    Text("Responding to: \(post.title)")
                        .font(.headline)
                        .foregroundColor(.primary)
                    TextField("Type your message...", text: $message)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .foregroundColor(.primary)
                        .background(Color(UIColor.secondarySystemBackground))
                    Button("Send") {
                        onSend(message)
                        didSend = true
                    }
                    .disabled(message.isEmpty)
                    .padding()
                }
            }
            .navigationTitle("Respond")
            .padding()
            .background(Color(UIColor.systemBackground))
        }
        .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
    }
}

