//
//  DisputeService.swift
//  TaskMutual
//
//  Service for managing task disputes
//

import Foundation
import FirebaseFirestore

class DisputeService {
    private let db = Firestore.firestore()

    // MARK: - Create Dispute
    func createDispute(
        taskId: String,
        taskTitle: String,
        reason: DisputeReason,
        description: String,
        reporterId: String,
        reporterUsername: String,
        respondentId: String,
        respondentUsername: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        let dispute = Dispute(
            taskId: taskId,
            taskTitle: taskTitle,
            reason: reason,
            description: description,
            reporterId: reporterId,
            reporterUsername: reporterUsername,
            respondentId: respondentId,
            respondentUsername: respondentUsername
        )

        do {
            let disputeData = try Firestore.Encoder().encode(dispute)
            db.collection("disputes").addDocument(data: disputeData) { error in
                DispatchQueue.main.async {
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        // Update task status to indicate dispute
                        self.markTaskAsDisputed(taskId: taskId)
                        completion(.success(()))
                    }
                }
            }
        } catch {
            DispatchQueue.main.async {
                completion(.failure(error))
            }
        }
    }

    // MARK: - Mark Task as Disputed
    private func markTaskAsDisputed(taskId: String) {
        db.collection("tasks").document(taskId).updateData([
            "status": TaskStatus.cancelled.rawValue // Or create a new "disputed" status
        ]) { error in
            if let error = error {
                print("❌ Failed to update task status: \(error.localizedDescription)")
            }
        }
    }

    // MARK: - Fetch Disputes for User
    func fetchDisputesForUser(userId: String, completion: @escaping (Result<[Dispute], Error>) -> Void) {
        // Fetch disputes where user is either reporter or respondent
        db.collection("disputes")
            .whereField("reporterId", isEqualTo: userId)
            .order(by: "createdAt", descending: true)
            .getDocuments { snapshot, error in
                if let error = error {
                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                    return
                }

                var disputes: [Dispute] = []

                if let documents = snapshot?.documents {
                    for doc in documents {
                        if let dispute = try? doc.data(as: Dispute.self) {
                            disputes.append(dispute)
                        }
                    }
                }

                // Also fetch disputes where user is respondent
                self.db.collection("disputes")
                    .whereField("respondentId", isEqualTo: userId)
                    .order(by: "createdAt", descending: true)
                    .getDocuments { snapshot2, error2 in
                        if let error2 = error2 {
                            DispatchQueue.main.async {
                                completion(.failure(error2))
                            }
                            return
                        }

                        if let documents = snapshot2?.documents {
                            for doc in documents {
                                if let dispute = try? doc.data(as: Dispute.self) {
                                    // Avoid duplicates
                                    if !disputes.contains(where: { $0.id == dispute.id }) {
                                        disputes.append(dispute)
                                    }
                                }
                            }
                        }

                        // Sort by date
                        disputes.sort { $0.createdAt > $1.createdAt }

                        DispatchQueue.main.async {
                            completion(.success(disputes))
                        }
                    }
            }
    }

    // MARK: - Fetch Dispute for Task
    func fetchDisputeForTask(taskId: String, completion: @escaping (Result<Dispute?, Error>) -> Void) {
        db.collection("disputes")
            .whereField("taskId", isEqualTo: taskId)
            .limit(to: 1)
            .getDocuments { snapshot, error in
                DispatchQueue.main.async {
                    if let error = error {
                        completion(.failure(error))
                        return
                    }

                    if let doc = snapshot?.documents.first {
                        if let dispute = try? doc.data(as: Dispute.self) {
                            completion(.success(dispute))
                        } else {
                            completion(.success(nil))
                        }
                    } else {
                        completion(.success(nil))
                    }
                }
            }
    }

    // MARK: - Update Dispute Status
    func updateDisputeStatus(
        disputeId: String,
        status: DisputeStatus,
        resolutionNotes: String? = nil,
        refundIssued: Bool = false,
        refundAmount: Double? = nil,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        var updateData: [String: Any] = [
            "status": status.rawValue
        ]

        if status == .resolved || status == .closed {
            updateData["resolvedAt"] = Timestamp(date: Date())
        }

        if let notes = resolutionNotes {
            updateData["resolutionNotes"] = notes
        }

        if refundIssued {
            updateData["refundIssued"] = true
            if let amount = refundAmount {
                updateData["refundAmount"] = amount
            }
        }

        db.collection("disputes").document(disputeId).updateData(updateData) { error in
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
