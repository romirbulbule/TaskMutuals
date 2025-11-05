//
//  Rating.swift
//  TaskMutual
//
//  Model for provider ratings and reviews
//

import Foundation
import FirebaseFirestore

// MARK: - Rating Model
struct Rating: Identifiable, Codable, Equatable {
    @DocumentID var id: String?
    var taskId: String
    var taskTitle: String
    var providerId: String // The person being rated
    var providerUsername: String
    var reviewerId: String // The person giving the rating
    var reviewerUsername: String

    var rating: Int // 1-5 stars
    var review: String? // Optional text review
    var createdAt: Date = Date()

    // Custom Equatable implementation (needed for @DocumentID)
    static func == (lhs: Rating, rhs: Rating) -> Bool {
        return lhs.id == rhs.id &&
               lhs.taskId == rhs.taskId &&
               lhs.rating == rhs.rating &&
               lhs.review == rhs.review
    }
}

// MARK: - Provider Rating Summary
// Stores aggregate rating data for each provider
struct ProviderRatingSummary: Codable {
    var providerId: String
    var totalRatings: Int = 0
    var averageRating: Double = 0.0
    var fiveStarCount: Int = 0
    var fourStarCount: Int = 0
    var threeStarCount: Int = 0
    var twoStarCount: Int = 0
    var oneStarCount: Int = 0

    // Calculate new average when adding a rating
    mutating func addRating(_ stars: Int) {
        totalRatings += 1

        // Update star counts
        switch stars {
        case 5: fiveStarCount += 1
        case 4: fourStarCount += 1
        case 3: threeStarCount += 1
        case 2: twoStarCount += 1
        case 1: oneStarCount += 1
        default: break
        }

        // Recalculate average
        let total = (fiveStarCount * 5) + (fourStarCount * 4) + (threeStarCount * 3) + (twoStarCount * 2) + (oneStarCount * 1)
        averageRating = Double(total) / Double(totalRatings)
    }

    var formattedAverage: String {
        return String(format: "%.1f", averageRating)
    }
}

// MARK: - Rating Extensions
extension Rating {
    var starDisplay: String {
        return String(repeating: "⭐️", count: rating)
    }
}
