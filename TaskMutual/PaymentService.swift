//
//  PaymentService.swift
//  TaskMutual
//
//  Service for handling Stripe payment integration
//  NOTE: Requires Firebase Cloud Functions or backend server for secure API key handling
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

class PaymentService {
    private let db = Firestore.firestore()

    // MARK: - Create Payment Record
    func createPaymentRecord(
        taskId: String,
        taskTitle: String,
        amount: Double,
        payerId: String,
        payerUsername: String,
        payeeId: String,
        payeeUsername: String,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        let fees = Payment.calculateFees(amount: amount)

        let payment = Payment(
            taskId: taskId,
            taskTitle: taskTitle,
            amount: amount,
            platformFee: fees.platformFee,
            providerAmount: fees.providerAmount,
            payerId: payerId,
            payerUsername: payerUsername,
            payeeId: payeeId,
            payeeUsername: payeeUsername,
            status: .pending
        )

        do {
            let paymentData = try Firestore.Encoder().encode(payment)
            let docRef = db.collection("payments").document()

            docRef.setData(paymentData) { error in
                DispatchQueue.main.async {
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        completion(.success(docRef.documentID))
                    }
                }
            }
        } catch {
            DispatchQueue.main.async {
                completion(.failure(error))
            }
        }
    }

    // MARK: - Process Payment with Stripe
    // NOTE: This should call a Firebase Cloud Function that handles Stripe API securely
    func processPayment(
        paymentId: String,
        paymentMethod: PaymentMethod,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        // Update payment status to processing
        let paymentRef = db.collection("payments").document(paymentId)

        paymentRef.updateData([
            "status": PaymentStatus.processing.rawValue,
            "paymentMethod": paymentMethod.rawValue
        ]) { error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }

            // TODO: Call Firebase Cloud Function to process Stripe payment
            // Example Cloud Function endpoint: https://us-central1-YOUR-PROJECT.cloudfunctions.net/processPayment
            //
            // The Cloud Function would:
            // 1. Create a Stripe Payment Intent
            // 2. Charge the customer
            // 3. Update the payment record in Firestore
            // 4. Return success/failure
            //
            // For now, we'll simulate a successful payment
            self.simulatePaymentProcessing(paymentId: paymentId, completion: completion)
        }
    }

    // MARK: - Simulate Payment Processing (for development)
    // TODO: Replace with actual Stripe integration via Cloud Functions
    private func simulatePaymentProcessing(
        paymentId: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        // Simulate network delay
        DispatchQueue.global().asyncAfter(deadline: .now() + 2.0) {
            let paymentRef = self.db.collection("payments").document(paymentId)

            // Simulate successful payment
            paymentRef.updateData([
                "status": PaymentStatus.completed.rawValue,
                "completedAt": Timestamp(date: Date()),
                "stripePaymentIntentId": "pi_simulated_\(UUID().uuidString)",
                "stripeChargeId": "ch_simulated_\(UUID().uuidString)"
            ]) { error in
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

    // MARK: - Fetch User's Payment History
    func fetchPaymentHistory(
        userId: String,
        completion: @escaping (Result<[Payment], Error>) -> Void
    ) {
        // Fetch payments where user is either payer or payee
        db.collection("payments")
            .whereField("payerId", isEqualTo: userId)
            .order(by: "createdAt", descending: true)
            .getDocuments { snapshot, error in
                if let error = error {
                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                    return
                }

                var payments: [Payment] = []

                // Get payments where user is payer
                if let documents = snapshot?.documents {
                    for doc in documents {
                        if let payment = try? doc.data(as: Payment.self) {
                            payments.append(payment)
                        }
                    }
                }

                // Also fetch payments where user is payee
                self.db.collection("payments")
                    .whereField("payeeId", isEqualTo: userId)
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
                                if let payment = try? doc.data(as: Payment.self) {
                                    // Avoid duplicates
                                    if !payments.contains(where: { $0.id == payment.id }) {
                                        payments.append(payment)
                                    }
                                }
                            }
                        }

                        // Sort by date
                        payments.sort { $0.createdAt > $1.createdAt }

                        DispatchQueue.main.async {
                            completion(.success(payments))
                        }
                    }
            }
    }

    // MARK: - Fetch Payment by Task ID
    func fetchPaymentForTask(
        taskId: String,
        completion: @escaping (Result<Payment?, Error>) -> Void
    ) {
        db.collection("payments")
            .whereField("taskId", isEqualTo: taskId)
            .limit(to: 1)
            .getDocuments { snapshot, error in
                DispatchQueue.main.async {
                    if let error = error {
                        completion(.failure(error))
                        return
                    }

                    if let doc = snapshot?.documents.first {
                        if let payment = try? doc.data(as: Payment.self) {
                            completion(.success(payment))
                        } else {
                            completion(.success(nil))
                        }
                    } else {
                        completion(.success(nil))
                    }
                }
            }
    }

    // MARK: - Issue Refund
    func issueRefund(
        paymentId: String,
        reason: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        // TODO: Call Firebase Cloud Function to process Stripe refund
        // For now, just update the payment status
        let paymentRef = db.collection("payments").document(paymentId)

        paymentRef.updateData([
            "status": PaymentStatus.refunded.rawValue,
            "failureReason": reason
        ]) { error in
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
