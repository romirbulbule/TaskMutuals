//
//  Payment.swift
//  TaskMutual
//
//  Payment model for tracking transactions between service seekers and providers
//

import Foundation
import FirebaseFirestore

// MARK: - Payment Status
enum PaymentStatus: String, Codable {
    case pending = "pending"
    case processing = "processing"
    case completed = "completed"
    case failed = "failed"
    case refunded = "refunded"

    var displayName: String {
        switch self {
        case .pending: return "Pending"
        case .processing: return "Processing"
        case .completed: return "Completed"
        case .failed: return "Failed"
        case .refunded: return "Refunded"
        }
    }

    var color: String {
        switch self {
        case .pending: return "orange"
        case .processing: return "blue"
        case .completed: return "green"
        case .failed: return "red"
        case .refunded: return "gray"
        }
    }
}

// MARK: - Payment Method
enum PaymentMethod: String, Codable {
    case card = "card"
    case applePay = "apple_pay"
    case googlePay = "google_pay"

    var displayName: String {
        switch self {
        case .card: return "Card"
        case .applePay: return "Apple Pay"
        case .googlePay: return "Google Pay"
        }
    }
}

// MARK: - Payment Model
struct Payment: Identifiable, Codable, Equatable {
    @DocumentID var id: String?
    var taskId: String
    var taskTitle: String
    var amount: Double // Amount in dollars
    var platformFee: Double // TaskMutuals platform fee (e.g., 5-10%)
    var providerAmount: Double // Amount provider receives after fee

    var payerId: String // Service seeker (the one paying)
    var payerUsername: String
    var payeeId: String // Service provider (the one receiving)
    var payeeUsername: String

    var status: PaymentStatus = .pending
    var paymentMethod: PaymentMethod?
    var stripePaymentIntentId: String? // Stripe Payment Intent ID
    var stripeChargeId: String? // Stripe Charge ID

    var createdAt: Date = Date()
    var completedAt: Date?
    var failureReason: String?

    // Custom Equatable implementation (needed for @DocumentID)
    static func == (lhs: Payment, rhs: Payment) -> Bool {
        return lhs.id == rhs.id &&
               lhs.taskId == rhs.taskId &&
               lhs.amount == rhs.amount &&
               lhs.status == rhs.status
    }
}

// MARK: - Payment Extensions
extension Payment {
    // Calculate platform fee (10% default)
    static func calculateFees(amount: Double, feePercentage: Double = 0.10) -> (platformFee: Double, providerAmount: Double) {
        let fee = amount * feePercentage
        let providerAmount = amount - fee
        return (fee, providerAmount)
    }

    // Format amount as currency
    var formattedAmount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: NSNumber(value: amount)) ?? "$\(amount)"
    }

    var formattedProviderAmount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: NSNumber(value: providerAmount)) ?? "$\(providerAmount)"
    }
}
