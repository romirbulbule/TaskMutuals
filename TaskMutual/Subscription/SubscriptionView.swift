//
//  SubscriptionView.swift
//  TaskMutual
//
//  Premium subscription upgrade screen - adapts to user type
//

import SwiftUI

struct SubscriptionView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var userVM: UserViewModel
    @StateObject private var purchaseManager = PurchaseManager.shared
    @State private var isProcessing = false
    @State private var showError = false
    @State private var errorMessage = ""

    var userType: UserType {
        userVM.profile?.userType ?? .lookingForServices
    }

    var currentTier: SubscriptionTier {
        userVM.profile?.subscription?.tier ?? .free
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 30) {
                    // Header
                    headerSection

                    // Different views based on user type
                    if userType == .lookingForServices {
                        serviceSeekerPlans
                    } else {
                        serviceProviderPlans
                    }

                    // Restore Purchases Button (for all)
                    Button(action: restorePurchases) {
                        Text("Restore Purchases")
                            .font(.system(size: 15))
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 8)

                    // Fine Print
                    finePrint
                        .padding(.bottom, 30)
                }
            }
            .background(Color(.systemBackground))
            .navigationBarTitle("Subscription", displayMode: .inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            .onAppear {
                _Concurrency.Task {
                    await purchaseManager.fetchOfferings()
                    await purchaseManager.checkSubscriptionStatus()
                }
            }
            .alert(isPresented: $showError) {
                Alert(
                    title: Text("Error"),
                    message: Text(errorMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }

    // MARK: - Header
    private var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: userType == .lookingForServices ? "star.circle.fill" : "checkmark.seal.fill")
                .font(.system(size: 60))
                .foregroundColor(Theme.accent)

            Text(userType == .lookingForServices ? "Upgrade to Premium" : "Verify Your Account")
                .font(.system(size: 28, weight: .bold))

            Text(userType == .lookingForServices
                 ? "Unlock unlimited tasks and priority matching"
                 : "Stand out with verification and lower fees")
                .font(.system(size: 16))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 20)
    }

    // MARK: - Service Seeker Plans
    private var serviceSeekerPlans: some View {
        VStack(spacing: 20) {
            // Free vs Premium Comparison
            HStack(spacing: 16) {
                planCard(tier: .free, isSelected: currentTier == .free, userType: userType)
                planCard(tier: .seekerPremium, isSelected: currentTier == .seekerPremium, userType: userType)
            }
            .padding(.horizontal)

            // Purchase Button
            if currentTier != .seekerPremium {
                Button(action: { upgradeTo(.seekerPremium) }) {
                    if isProcessing || purchaseManager.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text("Start Premium - $14.99/month")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.white)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(
                    LinearGradient(
                        colors: [Theme.accent, Theme.accent.opacity(0.8)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(16)
                .padding(.horizontal)
                .disabled(isProcessing || purchaseManager.isLoading)
            } else {
                Text("You're a Premium Member!")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(Theme.accent)
                    .padding()
            }
        }
    }

    // MARK: - Service Provider Plans
    private var serviceProviderPlans: some View {
        VStack(spacing: 20) {
            // Three-tier comparison
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    planCard(tier: .free, isSelected: currentTier == .free, userType: userType)
                    planCard(tier: .providerVerified, isSelected: currentTier == .providerVerified, userType: userType)
                    planCard(tier: .providerPro, isSelected: currentTier == .providerPro, userType: userType)
                }
                .padding(.horizontal)
            }

            // Purchase Buttons
            VStack(spacing: 12) {
                if currentTier == .free {
                    // Show both options
                    Button(action: { upgradeTo(.providerVerified) }) {
                        if isProcessing || purchaseManager.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text("Get Verified - $49.99 one-time")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(.white)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(
                        LinearGradient(
                            colors: [Color.blue, Color.blue.opacity(0.8)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(16)
                    .disabled(isProcessing || purchaseManager.isLoading)

                    Button(action: { upgradeTo(.providerPro) }) {
                        Text("Go Pro - $149.99/year")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(
                        LinearGradient(
                            colors: [Color.purple, Color.purple.opacity(0.8)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(16)
                    .disabled(isProcessing || purchaseManager.isLoading)
                } else if currentTier == .providerVerified {
                    // Show Pro upgrade option
                    Button(action: { upgradeTo(.providerPro) }) {
                        Text("Upgrade to Pro - $149.99/year")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(
                        LinearGradient(
                            colors: [Color.purple, Color.purple.opacity(0.8)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(16)
                    .disabled(isProcessing || purchaseManager.isLoading)
                } else {
                    Text("You're a Pro Member!")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.purple)
                        .padding()
                }
            }
            .padding(.horizontal)
        }
    }

    // MARK: - Plan Card
    private func planCard(tier: SubscriptionTier, isSelected: Bool, userType: UserType) -> some View {
        VStack(spacing: 16) {
            // Badge
            if tier != .free {
                Text(tier == .seekerPremium ? "POPULAR" : (tier == .providerPro ? "BEST VALUE" : "RECOMMENDED"))
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(tier == .providerPro ? Color.purple : Theme.accent)
                    .cornerRadius(12)
            } else {
                Spacer().frame(height: 23)
            }

            // Tier Name
            Text(tier.displayName)
                .font(.system(size: 20, weight: .bold))

            // Price
            VStack(spacing: 4) {
                if tier == .free {
                    Text("$0")
                        .font(.system(size: 32, weight: .bold))
                    Text("forever")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                } else {
                    Text("$\(String(format: "%.2f", tier.price))")
                        .font(.system(size: 32, weight: .bold))
                    Text(tier.billingPeriod)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
            }

            Divider()

            // Features
            VStack(alignment: .leading, spacing: 12) {
                ForEach(tier.features(for: userType).prefix(5), id: \.self) { feature in
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(tier == .providerPro ? .purple : Theme.accent)
                            .font(.system(size: 16))
                        Text(feature)
                            .font(.system(size: 13))
                            .fixedSize(horizontal: false, vertical: true)
                        Spacer()
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(20)
        .frame(width: 280)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: isSelected ? Theme.accent.opacity(0.3) : Color.black.opacity(0.1), radius: isSelected ? 15 : 5, x: 0, y: 5)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(isSelected ? Theme.accent : Color.clear, lineWidth: 2)
        )
    }

    // MARK: - Fine Print
    private var finePrint: some View {
        VStack(spacing: 8) {
            if userType == .lookingForServices {
                Text("Subscription automatically renews monthly. Cancel anytime.")
            } else {
                Text("Verified is a one-time payment. Pro renews annually. Cancel anytime.")
            }
        }
        .font(.system(size: 12))
        .foregroundColor(.secondary)
        .multilineTextAlignment(.center)
        .padding(.horizontal)
    }

    // MARK: - Upgrade Function
    private func upgradeTo(_ tier: SubscriptionTier) {
        HapticsManager.shared.medium()
        isProcessing = true

        _Concurrency.Task {
            do {
                // Purchase via Apple IAP
                let newSubscription = try await purchaseManager.purchaseTier(tier)

                // Update Firestore with subscription info
                await MainActor.run {
                    userVM.updateSubscription(newSubscription) {
                        isProcessing = false
                        HapticsManager.shared.success()

                        // Show success and dismiss
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                }
            } catch {
                await MainActor.run {
                    isProcessing = false
                    errorMessage = error.localizedDescription
                    showError = true
                    HapticsManager.shared.error()
                }
            }
        }
    }

    // MARK: - Restore Purchases
    private func restorePurchases() {
        HapticsManager.shared.light()

        _Concurrency.Task {
            do {
                try await purchaseManager.restorePurchases()

                // If subscription is active, update Firestore
                if purchaseManager.isSubscriptionActive,
                   let restoredTier = purchaseManager.currentTier {

                    var newSubscription = SubscriptionInfo(tier: restoredTier)
                    if let expiryDate = purchaseManager.customerInfo?.entitlements["premium"]?.expirationDate {
                        newSubscription.expiryDate = expiryDate
                    }

                    await MainActor.run {
                        userVM.updateSubscription(newSubscription) {
                            HapticsManager.shared.success()
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                } else {
                    await MainActor.run {
                        errorMessage = "No active subscription found to restore."
                        showError = true
                    }
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    showError = true
                    HapticsManager.shared.error()
                }
            }
        }
    }
}

#Preview {
    SubscriptionView()
        .environmentObject(UserViewModel())
}
