//
//  PurchaseManager.swift
//  TaskMutual
//
//  Handles Apple In-App Purchase via RevenueCat - supports split subscription model
//

import Foundation
import RevenueCat

// MARK: - Purchase Manager
class PurchaseManager: ObservableObject {
    static let shared = PurchaseManager()

    @Published var isSubscriptionActive: Bool = false
    @Published var currentOffering: Offering?
    @Published var customerInfo: CustomerInfo?
    @Published var isLoading: Bool = false
    @Published var currentTier: SubscriptionTier? = nil

    private init() {
        // Configuration happens in TaskMutualApp
    }

    // MARK: - Configure RevenueCat
    static func configure() {
        // TODO: Replace with your RevenueCat API key from https://app.revenuecat.com
        // Get this from: RevenueCat Dashboard > Project Settings > API Keys
        Purchases.logLevel = .debug
        Purchases.configure(withAPIKey: "test_wNWLOaymQwDoySmbinuTnZtxEui")

        print("✅ RevenueCat configured")
    }

    // MARK: - Product ID Mapping
    private func productIdentifier(for tier: SubscriptionTier) -> String {
        switch tier {
        case .free:
            return ""  // Free tier has no product
        case .seekerPremium:
            return "seeker_premium_monthly"
        case .providerVerified:
            return "provider_verified_lifetime"
        case .providerPro:
            return "provider_pro_yearly"
        }
    }

    // MARK: - Entitlement Mapping
    private func entitlementIdentifier(for tier: SubscriptionTier) -> String {
        switch tier {
        case .free:
            return ""
        case .seekerPremium:
            return "seeker_premium"
        case .providerVerified:
            return "provider_verified"
        case .providerPro:
            return "provider_pro"
        }
    }

    // MARK: - Fetch Available Offerings
    func fetchOfferings() async {
        isLoading = true
        defer { isLoading = false }

        do {
            let offerings = try await Purchases.shared.offerings()
            await MainActor.run {
                self.currentOffering = offerings.current
                print("✅ Fetched offerings: \(offerings.current?.availablePackages.count ?? 0) packages")
            }
        } catch {
            print("❌ Error fetching offerings: \(error.localizedDescription)")
        }
    }

    // MARK: - Check Subscription Status
    func checkSubscriptionStatus() async {
        do {
            let customerInfo = try await Purchases.shared.customerInfo()
            await MainActor.run {
                self.customerInfo = customerInfo

                // Check which tier is active (in priority order)
                if customerInfo.entitlements["provider_pro"]?.isActive == true {
                    self.currentTier = .providerPro
                    self.isSubscriptionActive = true
                } else if customerInfo.entitlements["provider_verified"]?.isActive == true {
                    self.currentTier = .providerVerified
                    self.isSubscriptionActive = true
                } else if customerInfo.entitlements["seeker_premium"]?.isActive == true {
                    self.currentTier = .seekerPremium
                    self.isSubscriptionActive = true
                } else {
                    self.currentTier = .free
                    self.isSubscriptionActive = false
                }

                print("✅ Subscription status: \(currentTier?.displayName ?? "Free")")
            }
        } catch {
            print("❌ Error checking subscription: \(error.localizedDescription)")
            await MainActor.run {
                self.isSubscriptionActive = false
                self.currentTier = .free
            }
        }
    }

    // MARK: - Purchase Subscription Tier
    func purchaseTier(_ tier: SubscriptionTier) async throws -> SubscriptionInfo {
        guard tier != .free else {
            throw PurchaseError.noProductAvailable
        }

        let productId = productIdentifier(for: tier)
        let entitlementId = entitlementIdentifier(for: tier)

        guard let package = currentOffering?.availablePackages.first(where: { $0.storeProduct.productIdentifier == productId }) else {
            throw PurchaseError.noProductAvailable
        }

        isLoading = true
        defer { isLoading = false }

        do {
            let result = try await Purchases.shared.purchase(package: package)

            // Update local state
            await MainActor.run {
                self.customerInfo = result.customerInfo
                self.isSubscriptionActive = result.customerInfo.entitlements[entitlementId]?.isActive == true
                self.currentTier = tier
            }

            // Create subscription info for Firestore
            let expiryDate = result.customerInfo.entitlements[entitlementId]?.expirationDate

            var newSubscription = SubscriptionInfo(tier: tier)
            newSubscription.expiryDate = expiryDate
            newSubscription.startDate = Date()

            print("✅ Purchase successful! Tier: \(tier.displayName), Expiry: \(expiryDate?.description ?? "Lifetime")")

            return newSubscription

        } catch {
            print("❌ Purchase failed: \(error.localizedDescription)")
            throw error
        }
    }

    // MARK: - Restore Purchases
    func restorePurchases() async throws {
        isLoading = true
        defer { isLoading = false }

        do {
            let customerInfo = try await Purchases.shared.restorePurchases()
            await MainActor.run {
                self.customerInfo = customerInfo

                // Check which tier is active after restore
                if customerInfo.entitlements["provider_pro"]?.isActive == true {
                    self.currentTier = .providerPro
                    self.isSubscriptionActive = true
                } else if customerInfo.entitlements["provider_verified"]?.isActive == true {
                    self.currentTier = .providerVerified
                    self.isSubscriptionActive = true
                } else if customerInfo.entitlements["seeker_premium"]?.isActive == true {
                    self.currentTier = .seekerPremium
                    self.isSubscriptionActive = true
                } else {
                    self.currentTier = .free
                    self.isSubscriptionActive = false
                }
            }

            if isSubscriptionActive {
                print("✅ Purchases restored successfully: \(currentTier?.displayName ?? "Unknown")")
            } else {
                print("⚠️ No active subscriptions found")
                throw PurchaseError.noActiveSubscription
            }
        } catch {
            print("❌ Restore failed: \(error.localizedDescription)")
            throw error
        }
    }
}

// MARK: - Purchase Errors
enum PurchaseError: LocalizedError {
    case noProductAvailable
    case noActiveSubscription

    var errorDescription: String? {
        switch self {
        case .noProductAvailable:
            return "Premium subscription is not available right now. Please try again later."
        case .noActiveSubscription:
            return "No active subscription found. Please purchase Premium to continue."
        }
    }
}
