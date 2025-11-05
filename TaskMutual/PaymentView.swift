//
//  PaymentView.swift
//  TaskMutual
//
//  View for processing payments for completed tasks
//

import SwiftUI

struct PaymentView: View {
    let task: Task
    let providerUsername: String
    let providerId: String
    let amount: Double

    @EnvironmentObject var userVM: UserViewModel
    @Environment(\.presentationMode) var presentationMode

    @State private var isProcessing = false
    @State private var paymentComplete = false
    @State private var errorMessage = ""
    @State private var selectedPaymentMethod: PaymentMethod = .card

    private let paymentService = PaymentService()

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
                    Text("Payment")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.white)
                    Spacer()
                    Spacer().frame(width: 28)
                }
                .padding()
                .background(Theme.background.opacity(0.95))

                ScrollView {
                    VStack(spacing: 24) {
                        // Task Info Card
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Task Details")
                                .font(.headline)
                                .foregroundColor(.white)

                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Image(systemName: "doc.text.fill")
                                        .foregroundColor(Theme.accent)
                                    Text(task.title)
                                        .foregroundColor(.white)
                                        .fontWeight(.semibold)
                                }

                                HStack {
                                    Image(systemName: "person.fill")
                                        .foregroundColor(Theme.accent)
                                    Text("Provider: @\(providerUsername)")
                                        .foregroundColor(.white.opacity(0.8))
                                }
                            }
                        }
                        .padding()
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(12)

                        // Payment Amount Card
                        VStack(spacing: 16) {
                            Text("Payment Summary")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity, alignment: .leading)

                            VStack(spacing: 12) {
                                HStack {
                                    Text("Service Amount")
                                        .foregroundColor(.white.opacity(0.8))
                                    Spacer()
                                    Text(formatCurrency(amount))
                                        .foregroundColor(.white)
                                        .fontWeight(.semibold)
                                }

                                Divider().background(Color.white.opacity(0.3))

                                let fees = Payment.calculateFees(amount: amount)

                                HStack {
                                    Text("Platform Fee (10%)")
                                        .foregroundColor(.white.opacity(0.8))
                                        .font(.subheadline)
                                    Spacer()
                                    Text(formatCurrency(fees.platformFee))
                                        .foregroundColor(.white.opacity(0.7))
                                        .font(.subheadline)
                                }

                                HStack {
                                    Text("Provider Receives")
                                        .foregroundColor(.white.opacity(0.8))
                                        .font(.subheadline)
                                    Spacer()
                                    Text(formatCurrency(fees.providerAmount))
                                        .foregroundColor(.green)
                                        .font(.subheadline)
                                }

                                Divider().background(Color.white.opacity(0.3))

                                HStack {
                                    Text("Total")
                                        .foregroundColor(.white)
                                        .font(.title3)
                                        .fontWeight(.bold)
                                    Spacer()
                                    Text(formatCurrency(amount))
                                        .foregroundColor(Theme.accent)
                                        .font(.title2)
                                        .fontWeight(.bold)
                                }
                            }
                        }
                        .padding()
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(12)

                        // Payment Method Selection
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Payment Method")
                                .font(.headline)
                                .foregroundColor(.white)

                            VStack(spacing: 12) {
                                PaymentMethodButton(
                                    method: .card,
                                    isSelected: selectedPaymentMethod == .card,
                                    action: { selectedPaymentMethod = .card }
                                )

                                PaymentMethodButton(
                                    method: .applePay,
                                    isSelected: selectedPaymentMethod == .applePay,
                                    action: { selectedPaymentMethod = .applePay }
                                )

                                PaymentMethodButton(
                                    method: .googlePay,
                                    isSelected: selectedPaymentMethod == .googlePay,
                                    action: { selectedPaymentMethod = .googlePay }
                                )
                            }
                        }
                        .padding()
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(12)

                        // Error Message
                        if !errorMessage.isEmpty {
                            Text(errorMessage)
                                .foregroundColor(.red)
                                .font(.subheadline)
                                .multilineTextAlignment(.center)
                                .padding()
                        }

                        // Pay Button
                        Button(action: handlePayment) {
                            if isProcessing {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Theme.accent)
                                    .cornerRadius(12)
                            } else {
                                HStack {
                                    Image(systemName: "lock.fill")
                                    Text("Pay \(formatCurrency(amount))")
                                        .font(.headline)
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Theme.accent)
                                .cornerRadius(12)
                            }
                        }
                        .disabled(isProcessing)
                    }
                    .padding()
                }
            }

            // Success Overlay
            if paymentComplete {
                Color.black.opacity(0.5).ignoresSafeArea()

                VStack(spacing: 20) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.green)

                    Text("Payment Successful!")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)

                    Text("Your payment has been processed.")
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

    private func handlePayment() {
        guard let taskId = task.id,
              let userId = userVM.profile?.id,
              let username = userVM.profile?.username else {
            errorMessage = "Unable to process payment. Please try again."
            return
        }

        isProcessing = true
        errorMessage = ""

        // Create payment record
        paymentService.createPaymentRecord(
            taskId: taskId,
            taskTitle: task.title,
            amount: amount,
            payerId: userId,
            payerUsername: username,
            payeeId: providerId,
            payeeUsername: providerUsername
        ) { result in
            switch result {
            case .success(let paymentId):
                // Process the payment
                self.paymentService.processPayment(
                    paymentId: paymentId,
                    paymentMethod: self.selectedPaymentMethod
                ) { result in
                    self.isProcessing = false

                    switch result {
                    case .success:
                        self.paymentComplete = true
                    case .failure(let error):
                        self.errorMessage = "Payment failed: \(error.localizedDescription)"
                    }
                }

            case .failure(let error):
                self.isProcessing = false
                self.errorMessage = "Failed to create payment: \(error.localizedDescription)"
            }
        }
    }

    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: NSNumber(value: amount)) ?? "$\(amount)"
    }
}

struct PaymentMethodButton: View {
    let method: PaymentMethod
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: iconName)
                    .font(.system(size: 24))
                    .foregroundColor(isSelected ? Theme.accent : .white)

                Text(method.displayName)
                    .foregroundColor(.white)
                    .fontWeight(.semibold)

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(Theme.accent)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.white.opacity(isSelected ? 0.2 : 0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(isSelected ? Theme.accent : Color.clear, lineWidth: 2)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }

    private var iconName: String {
        switch method {
        case .card: return "creditcard.fill"
        case .applePay: return "applelogo"
        case .googlePay: return "g.circle.fill"
        }
    }
}

#Preview {
    PaymentView(
        task: Task(
            id: "123",
            title: "Clean my house",
            description: "Need help cleaning",
            creatorUserId: "user1",
            creatorUsername: "john_doe"
        ),
        providerUsername: "jane_provider",
        providerId: "provider1",
        amount: 75.00
    )
    .environmentObject(UserViewModel())
}
