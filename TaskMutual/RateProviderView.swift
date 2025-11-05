//
//  RateProviderView.swift
//  TaskMutual
//
//  View for rating a service provider after task completion
//

import SwiftUI

struct RateProviderView: View {
    let task: Task
    let providerId: String
    let providerUsername: String

    @EnvironmentObject var userVM: UserViewModel
    @Environment(\.presentationMode) var presentationMode

    @State private var selectedRating: Int = 5
    @State private var reviewText: String = ""
    @State private var isSubmitting = false
    @State private var errorMessage = ""
    @State private var showSuccess = false

    private let ratingService = RatingService()

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.white.opacity(0.7))
                    }
                    Spacer()
                    Text("Rate Provider")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.white)
                    Spacer()
                    Spacer().frame(width: 28)
                }
                .padding()

                ScrollView {
                    VStack(spacing: 24) {
                        // Provider Info
                        VStack(spacing: 12) {
                            Image(systemName: "person.circle.fill")
                                .font(.system(size: 60))
                                .foregroundColor(Theme.accent)

                            Text("@\(providerUsername)")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.white)

                            Text("Task: \(task.title)")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.7))
                                .multilineTextAlignment(.center)
                        }
                        .padding()

                        // Star Rating
                        VStack(spacing: 16) {
                            Text("How would you rate this provider?")
                                .font(.headline)
                                .foregroundColor(.white)

                            HStack(spacing: 20) {
                                ForEach(1...5, id: \.self) { star in
                                    Button(action: { selectedRating = star }) {
                                        Image(systemName: star <= selectedRating ? "star.fill" : "star")
                                            .font(.system(size: 36))
                                            .foregroundColor(star <= selectedRating ? .yellow : .white.opacity(0.3))
                                    }
                                }
                            }

                            Text(ratingDescription)
                                .font(.subheadline)
                                .foregroundColor(Theme.accent)
                                .fontWeight(.semibold)
                        }
                        .padding()
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(12)

                        // Review Text
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Write a review (optional)")
                                .font(.headline)
                                .foregroundColor(.white)

                            ZStack(alignment: .topLeading) {
                                if reviewText.isEmpty {
                                    Text("Share your experience with this provider...")
                                        .foregroundColor(.white.opacity(0.3))
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 16)
                                }

                                TextEditor(text: $reviewText)
                                    .frame(height: 120)
                                    .padding(8)
                                    .background(Color.white.opacity(0.1))
                                    .cornerRadius(10)
                                    .foregroundColor(.white)
                                    .scrollContentBackground(.hidden)
                            }
                        }
                        .padding()
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(12)

                        // Error Message
                        if !errorMessage.isEmpty {
                            Text(errorMessage)
                                .foregroundColor(.red)
                                .font(.subheadline)
                                .multilineTextAlignment(.center)
                                .padding()
                        }

                        // Submit Button
                        Button(action: submitRating) {
                            if isSubmitting {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Theme.accent)
                                    .cornerRadius(12)
                            } else {
                                HStack {
                                    Image(systemName: "star.fill")
                                    Text("Submit Rating")
                                        .font(.headline)
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Theme.accent)
                                .cornerRadius(12)
                            }
                        }
                        .disabled(isSubmitting)
                    }
                    .padding()
                }
            }

            // Success Overlay
            if showSuccess {
                Color.black.opacity(0.5).ignoresSafeArea()

                VStack(spacing: 20) {
                    Image(systemName: "star.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.yellow)

                    Text("Rating Submitted!")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)

                    Text("Thank you for your feedback.")
                        .foregroundColor(.white.opacity(0.8))

                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Text("Done")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Theme.accent)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal, 40)
                }
                .padding(32)
                .background(Theme.background.opacity(0.95))
                .cornerRadius(20)
                .padding(40)
            }
        }
    }

    private var ratingDescription: String {
        switch selectedRating {
        case 1: return "Poor"
        case 2: return "Fair"
        case 3: return "Good"
        case 4: return "Very Good"
        case 5: return "Excellent"
        default: return ""
        }
    }

    private func submitRating() {
        guard let taskId = task.id,
              let reviewerId = userVM.profile?.id,
              let reviewerUsername = userVM.profile?.username else {
            errorMessage = "Unable to submit rating. Please try again."
            return
        }

        isSubmitting = true
        errorMessage = ""

        let review = reviewText.isEmpty ? nil : reviewText

        ratingService.submitRating(
            taskId: taskId,
            taskTitle: task.title,
            providerId: providerId,
            providerUsername: providerUsername,
            reviewerId: reviewerId,
            reviewerUsername: reviewerUsername,
            rating: selectedRating,
            review: review
        ) { result in
            isSubmitting = false

            switch result {
            case .success:
                showSuccess = true
            case .failure(let error):
                errorMessage = "Failed to submit rating: \(error.localizedDescription)"
            }
        }
    }
}

#Preview {
    RateProviderView(
        task: Task(
            id: "123",
            title: "Clean my house",
            description: "Need help cleaning",
            creatorUserId: "user1",
            creatorUsername: "john_doe"
        ),
        providerId: "provider1",
        providerUsername: "jane_provider"
    )
    .environmentObject(UserViewModel())
}
