//
//  EditResponseView.swift
//  TaskMutual
//
//  Created by Romir Bulbule on 11/4/25.
//

import SwiftUI

struct EditResponseView: View {
    var task: Task
    var response: Response
    @State private var message: String
    @State private var quotedPriceText: String
    var onSave: (String, Double?) -> Void
    @Environment(\.presentationMode) var presentationMode
    
    init(task: Task, response: Response, onSave: @escaping (String, Double?) -> Void) {
        self.task = task
        self.response = response
        self.onSave = onSave
        _message = State(initialValue: response.message)
        _quotedPriceText = State(initialValue: response.quotedPrice != nil ? "\(Int(response.quotedPrice!))" : "")
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Task Details Card
                VStack(alignment: .leading, spacing: 12) {
                    Text("Task Details")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Divider()
                    
                    Text(task.title)
                        .font(.title3)
                        .fontWeight(.semibold)
                    
                    if let category = task.category {
                        HStack {
                            Image(systemName: category.icon)
                            Text(category.rawValue)
                        }
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    }
                    
                    if let location = task.location {
                        HStack {
                            Image(systemName: "mappin.circle.fill")
                            Text(location)
                        }
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    }
                    
                    if let budget = task.budget {
                        HStack {
                            Image(systemName: "dollarsign.circle.fill")
                            Text("Client Budget: $\(Int(budget))")
                                .fontWeight(.medium)
                        }
                        .font(.subheadline)
                        .foregroundColor(Theme.accent)
                    }
                }
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(12)
                
                // Edit Response Form
                VStack(alignment: .leading, spacing: 16) {
                    Text("Edit Your Response")
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
                            TextField(task.budget != nil ? "\(Int(task.budget!))" : "Enter amount", text: $quotedPriceText)
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
                        onSave(message, price)
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Save Changes")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(message.isEmpty ? Color.gray : Theme.accent)
                            .cornerRadius(16)
                            .shadow(color: message.isEmpty ? Color.clear : Theme.accent.opacity(0.18), radius: 4, x: 0, y: 2)
                    }
                    .disabled(message.isEmpty)
                }
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(12)
            }
            .padding()
        }
        .navigationTitle("Edit Response")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }
        .background(Theme.background.ignoresSafeArea())
    }
}

