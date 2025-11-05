//
//  RatingService.swift
//  TaskMutual
//
//  Service for handling provider ratings and reviews
//

import Foundation
import FirebaseFirestore

class RatingService {
    private let db = Firestore.firestore()

    // MARK: - Submit Rating
    func submitRating(
        taskId: String,
        taskTitle: String,
        providerId: String,
        providerUsername: String,
        reviewerId: String,
        reviewerUsername: String,
        rating: Int,
        review: String?,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        let newRating = Rating(
            taskId: taskId,
            taskTitle: taskTitle,
            providerId: providerId,
            providerUsername: providerUsername,
            reviewerId: reviewerId,
            reviewerUsername: reviewerUsername,
            rating: rating,
            review: review
        )

        do {
            let ratingData = try Firestore.Encoder().encode(newRating)
            let ratingRef = db.collection("ratings").document()

            // Use a batch to update both the rating and the summary
            let batch = db.batch()

            // Add the rating
            batch.setData(ratingData, forDocument: ratingRef)

            // Update provider's rating summary
            let summaryRef = db.collection("providerRatings").document(providerId)

            batch.setData([
                "providerId": providerId,
                "totalRatings": FieldValue.increment(Int64(1)),
                "fiveStarCount": rating == 5 ? FieldValue.increment(Int64(1)) : FieldValue.increment(Int64(0)),
                "fourStarCount": rating == 4 ? FieldValue.increment(Int64(1)) : FieldValue.increment(Int64(0)),
                "threeStarCount": rating == 3 ? FieldValue.increment(Int64(1)) : FieldValue.increment(Int64(0)),
                "twoStarCount": rating == 2 ? FieldValue.increment(Int64(1)) : FieldValue.increment(Int64(0)),
                "oneStarCount": rating == 1 ? FieldValue.increment(Int64(1)) : FieldValue.increment(Int64(0))
            ], forDocument: summaryRef, merge: true)

            batch.commit { error in
                DispatchQueue.main.async {
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        // Recalculate average rating
                        self.recalculateAverageRating(providerId: providerId) { _ in
                            completion(.success(()))
                        }
                    }
                }
            }
        } catch {
            DispatchQueue.main.async {
                completion(.failure(error))
            }
        }
    }

    // MARK: - Recalculate Average Rating
    private func recalculateAverageRating(providerId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let summaryRef = db.collection("providerRatings").document(providerId)

        summaryRef.getDocument { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = snapshot?.data(),
                  let totalRatings = data["totalRatings"] as? Int,
                  totalRatings > 0 else {
                completion(.success(()))
                return
            }

            let five = (data["fiveStarCount"] as? Int) ?? 0
            let four = (data["fourStarCount"] as? Int) ?? 0
            let three = (data["threeStarCount"] as? Int) ?? 0
            let two = (data["twoStarCount"] as? Int) ?? 0
            let one = (data["oneStarCount"] as? Int) ?? 0

            let total = (five * 5) + (four * 4) + (three * 3) + (two * 2) + (one * 1)
            let average = Double(total) / Double(totalRatings)

            summaryRef.updateData(["averageRating": average]) { error in
                DispatchQueue.main.async {
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        completion(.success(()))
                    }
                }
            }
        }
    }

    // MARK: - Fetch Provider Rating Summary
    func fetchProviderRatingSummary(providerId: String, completion: @escaping (Result<ProviderRatingSummary?, Error>) -> Void) {
        db.collection("providerRatings").document(providerId).getDocument { snapshot, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                    return
                }

                if let data = snapshot?.data(),
                   let summary = try? Firestore.Decoder().decode(ProviderRatingSummary.self, from: data) {
                    completion(.success(summary))
                } else {
                    // No ratings yet
                    completion(.success(nil))
                }
            }
        }
    }

    // MARK: - Fetch Ratings for Provider
    func fetchRatingsForProvider(providerId: String, completion: @escaping (Result<[Rating], Error>) -> Void) {
        db.collection("ratings")
            .whereField("providerId", isEqualTo: providerId)
            .order(by: "createdAt", descending: true)
            .getDocuments { snapshot, error in
                DispatchQueue.main.async {
                    if let error = error {
                        completion(.failure(error))
                        return
                    }

                    var ratings: [Rating] = []
                    if let documents = snapshot?.documents {
                        for doc in documents {
                            if let rating = try? doc.data(as: Rating.self) {
                                ratings.append(rating)
                            }
                        }
                    }

                    completion(.success(ratings))
                }
            }
    }

    // MARK: - Check if User Already Rated Task
    func hasUserRatedTask(taskId: String, reviewerId: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        db.collection("ratings")
            .whereField("taskId", isEqualTo: taskId)
            .whereField("reviewerId", isEqualTo: reviewerId)
            .limit(to: 1)
            .getDocuments { snapshot, error in
                DispatchQueue.main.async {
                    if let error = error {
                        completion(.failure(error))
                        return
                    }

                    let hasRated = !(snapshot?.documents.isEmpty ?? true)
                    completion(.success(hasRated))
                }
            }
    }
}
