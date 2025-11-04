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
    @State private var quotedPriceText: String = ""
    var onSend: (String, Double?) -> Void
    @State private var didSend = false
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    if didSend {
                        VStack(spacing: 16) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.green)
                            Text("Your response was sent!")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundColor(.green)
                            Button("Done") {
                                presentationMode.wrappedValue.dismiss()
                            }
                            .padding()
                        }
                        .padding(.top, 40)
                    } else {
                        // Task Details Card
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Task Details")
                                .font(.headline)
                                .foregroundColor(.primary)

                            Divider()

                            Text(post.title)
                                .font(.title3)
                                .fontWeight(.semibold)

                            if let category = post.category {
                                HStack {
                                    Image(systemName: category.icon)
                                    Text(category.rawValue)
                                }
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            }

                            if let location = post.location {
                                HStack {
                                    Image(systemName: "mappin.circle.fill")
                                    Text(location)
                                }
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            }

                            if let budget = post.budget {
                                HStack {
                                    Image(systemName: "dollarsign.circle.fill")
                                    Text("Client Budget: $\(Int(budget))")
                                        .fontWeight(.medium)
                                }
                                .font(.subheadline)
                                .foregroundColor(Theme.accent)
                            }

                            Text(post.description)
                                .font(.body)
                                .foregroundColor(.primary)
                                .padding(.top, 4)
                        }
                        .padding()
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(12)

                        // Response Form
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Your Response")
                                .font(.headline)
                                .foregroundColor(.primary)

                            // Quoted Price
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Your Quote (Optional)")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                HStack {
                                    Text("$")
                                        .foregroundColor(.primary)
                                    TextField(post.budget != nil ? "\(Int(post.budget!))" : "Enter amount", text: $quotedPriceText)
                                        .keyboardType(.decimalPad)
                                        .foregroundColor(.primary)
                                }
                                .padding()
                                .background(Color(UIColor.secondarySystemBackground))
                                .cornerRadius(10)
                            }

                            // Message
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Message *")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                TextEditor(text: $message)
                                    .frame(height: 120)
                                    .padding(8)
                                    .background(Color(UIColor.secondarySystemBackground))
                                    .cornerRadius(10)
                                    .foregroundColor(.primary)
                            }

                            Button(action: {
                                let price = Double(quotedPriceText)
                                onSend(message, price)
                                didSend = true
                            }) {
                                Text("Send Response")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                                    .background(message.isEmpty ? Color.gray : Theme.accent)
                                    .cornerRadius(12)
                            }
                            .disabled(message.isEmpty)
                        }
                        .padding()
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(12)
                    }
                }
                .padding()
            }
            .navigationTitle("Respond to Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            .background(Theme.background)
        }
    }
}

