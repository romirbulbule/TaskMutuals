//
//  PostTaskView.swift
//  TaskMutual
//
//  Created by Romir Bulbule on 9/27/25.
//

import SwiftUI

struct PostTaskView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var title = ""
    @State private var description = ""
    @State private var budgetText = ""
    @State private var location = ""
    @State private var selectedCategory: ServiceCategory?
    @State private var deadline: Date = Date().addingTimeInterval(86400 * 7) // Default: 1 week from now
    @State private var estimatedDuration = ""
    @State private var showCategoryPicker = false

    var onPost: (String, String, Double?, String?, ServiceCategory?, Date?, String?) -> Void

    var isFormValid: Bool {
        !title.isEmpty && !description.isEmpty && selectedCategory != nil && !location.isEmpty
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Title
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Task Title *")
                            .foregroundColor(Color.white)
                            .font(.caption)
                        TextField("e.g., Mow front and back lawn", text: $title)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(10)
                            .foregroundColor(.black)
                    }

                    // Category
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Category *")
                            .foregroundColor(Color.white)
                            .font(.caption)
                        Button(action: { showCategoryPicker = true }) {
                            HStack {
                                if let category = selectedCategory {
                                    Image(systemName: category.icon)
                                    Text(category.rawValue)
                                } else {
                                    Text("Select a category")
                                        .foregroundColor(.gray)
                                }
                                Spacer()
                                Image(systemName: "chevron.down")
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(10)
                            .foregroundColor(.black)
                        }
                    }

                    // Location
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Location *")
                            .foregroundColor(Color.white)
                            .font(.caption)
                        TextField("e.g., Boston, MA", text: $location)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(10)
                            .foregroundColor(.black)
                    }

                    // Budget
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Budget (Optional)")
                            .foregroundColor(Color.white)
                            .font(.caption)
                        HStack {
                            Text("$")
                                .foregroundColor(.black)
                            TextField("50", text: $budgetText)
                                .keyboardType(.decimalPad)
                                .foregroundColor(.black)
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                    }

                    // Description
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Description *")
                            .foregroundColor(Color.white)
                            .font(.caption)
                        ZStack(alignment: .topLeading) {
                            if description.isEmpty {
                                Text("Describe what needs to be done, any specific requirements, and when you need it completed...")
                                    .foregroundColor(.gray.opacity(0.6))
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 16)
                            }
                            TextEditor(text: $description)
                                .frame(height: 120)
                                .padding(4)
                                .scrollContentBackground(.hidden)
                        }
                        .background(Color.white)
                        .cornerRadius(10)
                        .foregroundColor(.black)
                    }

                    // Estimated Duration
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Estimated Duration (Optional)")
                            .foregroundColor(Color.white)
                            .font(.caption)
                        TextField("e.g., 2-3 hours", text: $estimatedDuration)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(10)
                            .foregroundColor(.black)
                    }

                    // Deadline
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Deadline (Optional)")
                            .foregroundColor(Color.white)
                            .font(.caption)
                        DatePicker("", selection: $deadline, in: Date()..., displayedComponents: [.date])
                            .datePickerStyle(.compact)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(10)
                            .labelsHidden()
                    }

                    Spacer()
                }
                .padding()
            }
            .navigationBarTitle("New Task", displayMode: .inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        let budget = Double(budgetText)
                        onPost(
                            title,
                            description,
                            budget,
                            location.isEmpty ? nil : location,
                            selectedCategory,
                            deadline,
                            estimatedDuration.isEmpty ? nil : estimatedDuration
                        )
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Post")
                            .frame(width: 60, height: 34)
                            .foregroundColor(.white)
                            .background(isFormValid ? Theme.accent : Color.gray)
                            .cornerRadius(8)
                    }
                    .disabled(!isFormValid)
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
            .background(Theme.background.ignoresSafeArea())
            .sheet(isPresented: $showCategoryPicker) {
                CategoryPickerView(selectedCategory: $selectedCategory)
            }
        }
    }
}

// Category Picker Sheet
struct CategoryPickerView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var selectedCategory: ServiceCategory?

    var body: some View {
        NavigationView {
            List {
                ForEach(ServiceCategory.allCases, id: \.self) { category in
                    Button(action: {
                        selectedCategory = category
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        HStack {
                            Image(systemName: category.icon)
                                .foregroundColor(Theme.accent)
                                .frame(width: 30)
                            Text(category.rawValue)
                                .foregroundColor(.primary)
                            Spacer()
                            if selectedCategory == category {
                                Image(systemName: "checkmark")
                                    .foregroundColor(Theme.accent)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Select Category")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}






