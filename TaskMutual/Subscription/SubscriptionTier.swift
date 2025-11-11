//
//  SubscriptionTier.swift
//  TaskMutual
//
//  Split subscription model for different user types
//

import Foundation

enum SubscriptionTier: String, Codable {
    case free = "free"
    case seekerPremium = "seeker_premium"          // For service seekers
    case providerVerified = "provider_verified"    // One-time verification
    case providerPro = "provider_pro"              // Annual pro tier

    var displayName: String {
        switch self {
        case .free: return "Free"
        case .seekerPremium: return "Premium"
        case .providerVerified: return "Verified Provider"
        case .providerPro: return "Pro Provider"
        }
    }

    var price: Double {
        switch self {
        case .free: return 0.0
        case .seekerPremium: return 14.99          // Monthly
        case .providerVerified: return 49.99       // One-time
        case .providerPro: return 149.99           // Annual
        }
    }

    var isRecurring: Bool {
        switch self {
        case .free, .providerVerified: return false
        case .seekerPremium, .providerPro: return true
        }
    }

    var billingPeriod: String {
        switch self {
        case .free, .providerVerified: return "one-time"
        case .seekerPremium: return "monthly"
        case .providerPro: return "yearly"
        }
    }

    // Task posting limits based on user type
    func taskLimitPerMonth(for userType: UserType) -> Int? {
        switch (self, userType) {
        case (.free, .lookingForServices):
            return 7  // Service seekers: 7 tasks/month
        case (.seekerPremium, .lookingForServices):
            return nil  // Unlimited for premium seekers
        case (_, .providingServices):
            return nil  // Service providers: Always unlimited posting
        default:
            return 7
        }
    }

    // Platform fee percentage (only for service providers earning money)
    func platformFeePercentage(for userType: UserType) -> Double {
        // Service seekers don't pay platform fees (they're hiring, not earning)
        guard userType == .providingServices else { return 0.0 }

        switch self {
        case .free, .seekerPremium:
            return 0.15  // 15% for free/unverified providers
        case .providerVerified:
            return 0.12  // 12% for verified providers
        case .providerPro:
            return 0.10  // 10% for pro providers
        }
    }

    // Features list for display
    func features(for userType: UserType) -> [String] {
        if userType == .lookingForServices {
            // Features for service seekers
            switch self {
            case .free:
                return [
                    "7 task posts per month",
                    "Basic task matching",
                    "Chat with service providers",
                    "No platform fees (you're hiring)"
                ]
            case .seekerPremium:
                return [
                    "Unlimited task posts",
                    "Priority task matching",
                    "Featured task listings",
                    "Advanced task analytics",
                    "Priority support",
                    "No platform fees (you're hiring)"
                ]
            default:
                return ["N/A"]
            }
        } else {
            // Features for service providers
            switch self {
            case .free:
                return [
                    "Unlimited task browsing",
                    "Unlimited applications",
                    "Basic profile",
                    "Chat with clients",
                    "15% transaction fee"
                ]
            case .providerVerified:
                return [
                    "✓ Verified badge",
                    "Featured profile",
                    "Priority in search results",
                    "12% transaction fee (3% savings)",
                    "One-time payment"
                ]
            case .providerPro:
                return [
                    "✓ Pro badge",
                    "Premium featured profile",
                    "Top priority in search",
                    "10% transaction fee (5% savings)",
                    "Advanced analytics",
                    "Priority support",
                    "Annual billing"
                ]
            default:
                return ["N/A"]
            }
        }
    }

    // Get badge icon for display
    var badgeIcon: String? {
        switch self {
        case .free, .seekerPremium:
            return nil
        case .providerVerified:
            return "checkmark.seal.fill"
        case .providerPro:
            return "crown.fill"
        }
    }
}

// Track user's subscription and usage
struct SubscriptionInfo: Codable {
    var tier: SubscriptionTier
    var startDate: Date
    var expiryDate: Date?  // For recurring subscriptions
    var tasksPostedThisMonth: Int
    var completedTasksThisMonth: Int  // For tracking provider activity
    var lastResetDate: Date

    init(tier: SubscriptionTier = .free) {
        self.tier = tier
        self.startDate = Date()
        self.expiryDate = nil
        self.tasksPostedThisMonth = 0
        self.completedTasksThisMonth = 0
        self.lastResetDate = Date()
    }

    // Check if subscription is active
    func isActive(userType: UserType) -> Bool {
        // Free tier is always active
        if tier == .free { return true }

        // One-time purchases (providerVerified) never expire
        if tier == .providerVerified { return true }

        // Recurring subscriptions need valid expiry
        guard let expiry = expiryDate else { return false }
        return Date() < expiry
    }

    // Check if user can post more tasks
    func canPostTask(userType: UserType) -> Bool {
        guard let limit = tier.taskLimitPerMonth(for: userType) else {
            return true  // Unlimited
        }
        return tasksPostedThisMonth < limit
    }

    // Get remaining tasks for this month
    func remainingTasks(userType: UserType) -> Int? {
        guard let limit = tier.taskLimitPerMonth(for: userType) else {
            return nil  // Unlimited
        }
        return max(0, limit - tasksPostedThisMonth)
    }

    // Calculate platform fee for a completed task
    func calculatePlatformFee(amount: Double, userType: UserType) -> Double {
        return amount * tier.platformFeePercentage(for: userType)
    }

    // Check if monthly counters should be reset
    mutating func resetIfNeeded() {
        let calendar = Calendar.current
        let now = Date()

        // Check if we're in a new month
        if !calendar.isDate(now, equalTo: lastResetDate, toGranularity: .month) {
            tasksPostedThisMonth = 0
            completedTasksThisMonth = 0
            lastResetDate = now
        }
    }
}
