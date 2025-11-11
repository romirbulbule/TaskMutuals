//
//  PostTaskView.swift
//  TaskMutual
//
//  Created by Romir Bulbule on 9/27/25.
//

import SwiftUI

struct PostTaskView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var userVM: UserViewModel
    @State private var title = ""
    @State private var description = ""
    @State private var budgetText = ""
    @State private var location = ""
    @State private var selectedCategory: ServiceCategory?
    @State private var deadline: Date = Date().addingTimeInterval(86400 * 7) // Default: 1 week from now
    @State private var estimatedDuration = ""
    @State private var showCategoryPicker = false
    @State private var showLimitAlert = false
    @State private var showSubscriptionUpgrade = false

    var onPost: (String, String, Double?, String?, ServiceCategory?, Date?, String?) -> Void

    // Check if user can post based on subscription limits
    private var canPost: Bool {
        guard var subscription = userVM.profile?.subscription,
              let userType = userVM.profile?.userType else {
            return true // No subscription yet, allow posting
        }
        subscription.resetIfNeeded()
        return subscription.canPostTask(userType: userType)
    }

    private var remainingTasks: Int? {
        guard var subscription = userVM.profile?.subscription,
              let userType = userVM.profile?.userType else {
            return nil
        }
        subscription.resetIfNeeded()
        return subscription.remainingTasks(userType: userType)
    }

    var isFormValid: Bool {
        !title.isEmpty && !description.isEmpty && selectedCategory != nil && !location.isEmpty
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Subscription Status Banner (if free tier)
                    if let subscription = userVM.profile?.subscription, subscription.tier == .free {
                        if let remaining = remainingTasks {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("\(remaining) tasks remaining this month")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(.white)

                                    if remaining <= 2 {
                                        Text("Upgrade to Premium for unlimited tasks")
                                            .font(.system(size: 12))
                                            .foregroundColor(.white.opacity(0.9))
                                    }
                                }

                                Spacer()

                                Button(action: {
                                    showSubscriptionUpgrade = true
                                }) {
                                    Text("Upgrade")
                                        .font(.system(size: 13, weight: .semibold))
                                        .foregroundColor(Theme.accent)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(Color.white)
                                        .cornerRadius(8)
                                }
                            }
                            .padding()
                            .background(
                                LinearGradient(
                                    colors: [Theme.accent, Theme.accent.opacity(0.8)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(12)
                        }
                    }

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
                        // Check subscription limit before posting
                        if !canPost {
                            showLimitAlert = true
                            return
                        }

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

                        // Increment subscription task counter
                        if var subscription = userVM.profile?.subscription {
                            subscription.tasksPostedThisMonth += 1
                            userVM.updateSubscription(subscription)
                        }

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
            .alert("Task Limit Reached", isPresented: $showLimitAlert) {
                Button("Upgrade to Premium") {
                    showSubscriptionUpgrade = true
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("You've reached your monthly limit of 7 tasks. Upgrade to Premium for unlimited task posts!")
            }
            .sheet(isPresented: $showSubscriptionUpgrade) {
                SubscriptionView()
                    .environmentObject(userVM)
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






