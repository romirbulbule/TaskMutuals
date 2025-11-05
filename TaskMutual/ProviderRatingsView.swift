//
//  ProviderRatingsView.swift
//  TaskMutual
//
//  View for displaying all ratings for a provider
//

import SwiftUI

struct ProviderRatingsView: View {
    let providerId: String
    let providerUsername: String

    @Environment(\.presentationMode) var presentationMode
    @State private var ratings: [Rating] = []
    @State private var ratingSummary: ProviderRatingSummary?
    @State private var isLoading = true
    @State private var errorMessage = ""

    private let ratingService = RatingService()

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(Theme.accent)
                    }
                    Spacer()
                    Text("Ratings & Reviews")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.white)
                    Spacer()
                    Spacer().frame(width: 20)
                }
                .padding()

                if isLoading {
                    Spacer()
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    Spacer()
                } else if !errorMessage.isEmpty {
                    Spacer()
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding()
                    Spacer()
                } else {
                    ScrollView {
                        VStack(spacing: 20) {
                            // Rating Summary Card
                            if let summary = ratingSummary {
                                RatingSummaryCard(
                                    summary: summary,
                                    providerUsername: providerUsername
                                )
                            } else {
                                NoRatingsCard(providerUsername: providerUsername)
                            }

                            // Individual Reviews
                            if !ratings.isEmpty {
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("Reviews (\(ratings.count))")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                        .padding(.horizontal)

                                    ForEach(ratings) { rating in
                                        RatingCard(rating: rating)
                                    }
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
        }
        .onAppear {
            loadRatings()
        }
    }

    private func loadRatings() {
        let group = DispatchGroup()
        var fetchError: Error?

        // Fetch summary
        group.enter()
        ratingService.fetchProviderRatingSummary(providerId: providerId) { result in
            switch result {
            case .success(let summary):
                self.ratingSummary = summary
            case .failure(let error):
                fetchError = error
            }
            group.leave()
        }

        // Fetch individual ratings
        group.enter()
        ratingService.fetchRatingsForProvider(providerId: providerId) { result in
            switch result {
            case .success(let fetchedRatings):
                self.ratings = fetchedRatings
            case .failure(let error):
                fetchError = error
            }
            group.leave()
        }

        group.notify(queue: .main) {
            isLoading = false
            if let error = fetchError {
                errorMessage = "Failed to load ratings: \(error.localizedDescription)"
            }
        }
    }
}

struct RatingSummaryCard: View {
    let summary: ProviderRatingSummary
    let providerUsername: String

    var body: some View {
        VStack(spacing: 16) {
            // Provider name
            Text("@\(providerUsername)")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.white)

            // Average rating display
            VStack(spacing: 8) {
                HStack(spacing: 8) {
                    Text(summary.formattedAverage)
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(.white)

                    Image(systemName: "star.fill")
                        .font(.system(size: 32))
                        .foregroundColor(.yellow)
                }

                Text("\(summary.totalRatings) rating\(summary.totalRatings == 1 ? "" : "s")")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
            }

            // Star breakdown
            VStack(spacing: 8) {
                StarBreakdownRow(stars: 5, count: summary.fiveStarCount, total: summary.totalRatings)
                StarBreakdownRow(stars: 4, count: summary.fourStarCount, total: summary.totalRatings)
                StarBreakdownRow(stars: 3, count: summary.threeStarCount, total: summary.totalRatings)
                StarBreakdownRow(stars: 2, count: summary.twoStarCount, total: summary.totalRatings)
                StarBreakdownRow(stars: 1, count: summary.oneStarCount, total: summary.totalRatings)
            }
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(12)
    }
}

struct StarBreakdownRow: View {
    let stars: Int
    let count: Int
    let total: Int

    var percentage: Double {
        total > 0 ? Double(count) / Double(total) : 0
    }

    var body: some View {
        HStack(spacing: 12) {
            Text("\(stars)")
                .foregroundColor(.white)
                .frame(width: 20)

            Image(systemName: "star.fill")
                .font(.caption)
                .foregroundColor(.yellow)

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.white.opacity(0.2))
                        .frame(height: 8)
                        .cornerRadius(4)

                    Rectangle()
                        .fill(Color.yellow)
                        .frame(width: geometry.size.width * percentage, height: 8)
                        .cornerRadius(4)
                }
            }
            .frame(height: 8)

            Text("\(count)")
                .foregroundColor(.white.opacity(0.7))
                .font(.caption)
                .frame(width: 30, alignment: .trailing)
        }
    }
}

struct NoRatingsCard: View {
    let providerUsername: String

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "star")
                .font(.system(size: 48))
                .foregroundColor(.white.opacity(0.5))

            Text("No ratings yet")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.white)

            Text("@\(providerUsername) hasn't received any ratings yet.")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
        }
        .padding(32)
        .background(Color.white.opacity(0.1))
        .cornerRadius(12)
    }
}

struct RatingCard: View {
    let rating: Rating

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("@\(rating.reviewerUsername)")
                        .font(.headline)
                        .foregroundColor(.white)

                    HStack(spacing: 4) {
                        ForEach(1...5, id: \.self) { star in
                            Image(systemName: star <= rating.rating ? "star.fill" : "star")
                                .font(.caption)
                                .foregroundColor(star <= rating.rating ? .yellow : .white.opacity(0.3))
                        }
                    }
                }

                Spacer()

                Text(formatDate(rating.createdAt))
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.5))
            }

            if let review = rating.review, !review.isEmpty {
                Text(review)
                    .foregroundColor(.white.opacity(0.9))
                    .font(.body)
            }

            Text("Task: \(rating.taskTitle)")
                .font(.caption)
                .foregroundColor(.white.opacity(0.6))
                .italic()
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(12)
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

#Preview {
    ProviderRatingsView(
        providerId: "provider1",
        providerUsername: "jane_provider"
    )
}
