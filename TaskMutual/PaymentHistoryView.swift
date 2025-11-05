//
//  PaymentHistoryView.swift
//  TaskMutual
//
//  View for displaying user's payment history
//

import SwiftUI

struct PaymentHistoryView: View {
    @EnvironmentObject var userVM: UserViewModel
    @Environment(\.presentationMode) var presentationMode

    @State private var payments: [Payment] = []
    @State private var isLoading = true
    @State private var errorMessage = ""

    private let paymentService = PaymentService()

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
                    Text("Payment History")
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
                } else if payments.isEmpty {
                    Spacer()
                    VStack(spacing: 16) {
                        Image(systemName: "doc.text.magnifyingglass")
                            .font(.system(size: 60))
                            .foregroundColor(.white.opacity(0.5))
                        Text("No payment history")
                            .font(.title3)
                            .foregroundColor(.white.opacity(0.7))
                    }
                    Spacer()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(payments) { payment in
                                PaymentHistoryCard(payment: payment, currentUserId: userVM.profile?.id ?? "")
                            }
                        }
                        .padding()
                    }
                }
            }
        }
        .onAppear {
            loadPaymentHistory()
        }
    }

    private func loadPaymentHistory() {
        guard let userId = userVM.profile?.id else {
            errorMessage = "Unable to load payment history"
            isLoading = false
            return
        }

        paymentService.fetchPaymentHistory(userId: userId) { result in
            isLoading = false
            switch result {
            case .success(let fetchedPayments):
                self.payments = fetchedPayments
            case .failure(let error):
                self.errorMessage = "Failed to load payments: \(error.localizedDescription)"
            }
        }
    }
}

struct PaymentHistoryCard: View {
    let payment: Payment
    let currentUserId: String

    var isReceived: Bool {
        payment.payeeId == currentUserId
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(payment.taskTitle)
                        .font(.headline)
                        .foregroundColor(.white)

                    HStack(spacing: 4) {
                        Image(systemName: isReceived ? "arrow.down.circle.fill" : "arrow.up.circle.fill")
                            .foregroundColor(isReceived ? .green : .orange)
                        Text(isReceived ? "Received from @\(payment.payerUsername)" : "Paid to @\(payment.payeeUsername)")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.7))
                    }
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text(isReceived ? payment.formattedProviderAmount : payment.formattedAmount)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(isReceived ? .green : .white)

                    StatusBadge(status: payment.status)
                }
            }

            Divider().background(Color.white.opacity(0.2))

            HStack {
                Text(formatDate(payment.createdAt))
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.5))

                Spacer()

                if let method = payment.paymentMethod {
                    HStack(spacing: 4) {
                        Image(systemName: paymentMethodIcon(method))
                            .font(.caption)
                        Text(method.displayName)
                            .font(.caption)
                    }
                    .foregroundColor(.white.opacity(0.6))
                }
            }
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(12)
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    private func paymentMethodIcon(_ method: PaymentMethod) -> String {
        switch method {
        case .card: return "creditcard.fill"
        case .applePay: return "applelogo"
        case .googlePay: return "g.circle.fill"
        }
    }
}

struct StatusBadge: View {
    let status: PaymentStatus

    var body: some View {
        Text(status.displayName)
            .font(.caption)
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(statusColor)
            .cornerRadius(6)
    }

    private var statusColor: Color {
        switch status {
        case .pending: return .orange
        case .processing: return .blue
        case .completed: return .green
        case .failed: return .red
        case .refunded: return .gray
        }
    }
}

#Preview {
    PaymentHistoryView()
        .environmentObject(UserViewModel())
}
