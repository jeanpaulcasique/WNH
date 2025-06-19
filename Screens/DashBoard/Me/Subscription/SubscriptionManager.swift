import Foundation
import StoreKit

// MARK: - Subscription Models
enum SubscriptionTier: String, Codable {
    case free = "free"
    case monthly = "monthly"
    case threeMonths = "three_months"
    case yearly = "yearly"
    
    var priority: Int {
        switch self {
        case .free: return 0
        case .monthly: return 1
        case .threeMonths: return 2
        case .yearly: return 3
        }
    }
}

struct SubscriptionStatus: Codable {
    let tier: SubscriptionTier
    let startDate: Date
    let expirationDate: Date
    let isActive: Bool
    let autoRenew: Bool
    let lastPaymentDate: Date?
    let paymentMethod: String?
    
    var isExpired: Bool {
        return Date() > expirationDate
    }
    
    var daysRemaining: Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: Date(), to: expirationDate)
        return components.day ?? 0
    }
}

// MARK: - Subscription Manager
class SubscriptionManager: ObservableObject {
    static let shared = SubscriptionManager()
    
    @Published private(set) var currentStatus: SubscriptionStatus
    private let userDefaults = UserDefaults.standard
    private let subscriptionKey = "subscription_status"
    
    // MARK: - Initialization
    private init() {
        if let data = userDefaults.data(forKey: subscriptionKey),
           let status = try? JSONDecoder().decode(SubscriptionStatus.self, from: data) {
            self.currentStatus = status
        } else {
            // Default free subscription
            self.currentStatus = SubscriptionStatus(
                tier: .free,
                startDate: Date(),
                expirationDate: Date().addingTimeInterval(7 * 24 * 60 * 60), // 7 days
                isActive: true,
                autoRenew: false,
                lastPaymentDate: nil,
                paymentMethod: nil
            )
            saveStatus()
        }
    }
    
    // MARK: - Public Methods
    
    /// Attempts to upgrade to a new subscription tier
    func upgradeTo(tier: SubscriptionTier) -> Bool {
        // Validate upgrade path
        guard canUpgradeTo(tier: tier) else {
            return false
        }
        
        // Calculate new expiration date
        let newExpirationDate: Date
        switch tier {
        case .free:
            newExpirationDate = Date().addingTimeInterval(7 * 24 * 60 * 60) // 7 days
        case .monthly:
            newExpirationDate = Date().addingTimeInterval(30 * 24 * 60 * 60) // 30 days
        case .threeMonths:
            newExpirationDate = Date().addingTimeInterval(90 * 24 * 60 * 60) // 90 days
        case .yearly:
            newExpirationDate = Date().addingTimeInterval(365 * 24 * 60 * 60) // 365 days
        }
        
        // Create new subscription status
        let newStatus = SubscriptionStatus(
            tier: tier,
            startDate: Date(),
            expirationDate: newExpirationDate,
            isActive: true,
            autoRenew: tier != .free,
            lastPaymentDate: Date(),
            paymentMethod: nil // Will be set when payment system is implemented
        )
        
        // Update status
        currentStatus = newStatus
        saveStatus()
        
        return true
    }
    
    /// Cancels the current subscription
    func cancelSubscription() {
        // Only allow cancellation of paid subscriptions
        guard currentStatus.tier != .free else { return }
        
        let newStatus = SubscriptionStatus(
            tier: currentStatus.tier,
            startDate: currentStatus.startDate,
            expirationDate: currentStatus.expirationDate,
            isActive: true,
            autoRenew: false,
            lastPaymentDate: currentStatus.lastPaymentDate,
            paymentMethod: currentStatus.paymentMethod
        )
        
        currentStatus = newStatus
        saveStatus()
    }
    
    /// Checks if a feature is available for the current subscription
    func isFeatureAvailable(_ feature: SubscriptionFeature) -> Bool {
        guard currentStatus.isActive && !currentStatus.isExpired else { return false }
        
        switch feature {
        case .personalizedDiets:
            return currentStatus.tier != .free
        case .personalizedWorkouts:
            return currentStatus.tier != .free
        case .advancedAnalytics:
            return currentStatus.tier != .free
        case .prioritySupport:
            return currentStatus.tier == .threeMonths || currentStatus.tier == .yearly
        case .exclusiveContent:
            return currentStatus.tier == .threeMonths || currentStatus.tier == .yearly
        case .personalizedConsultations:
            return currentStatus.tier == .yearly
        }
    }
    
    // MARK: - Private Methods
    
    private func canUpgradeTo(tier: SubscriptionTier) -> Bool {
        // Can't downgrade from paid to free
        if currentStatus.tier != .free && tier == .free {
            return false
        }
        
        // Can upgrade to any higher tier
        return tier.priority >= currentStatus.tier.priority
    }
    
    private func saveStatus() {
        if let data = try? JSONEncoder().encode(currentStatus) {
            userDefaults.set(data, forKey: subscriptionKey)
            
            // Update UserProfile
            userDefaults.set(currentStatus.tier.rawValue, forKey: "subscription_plan")
            userDefaults.set(currentStatus.expirationDate, forKey: "subscription_expiration_date")
            userDefaults.set(currentStatus.isActive, forKey: "is_subscription_active")
        }
    }
}

// MARK: - Subscription Features
enum SubscriptionFeature {
    case personalizedDiets
    case personalizedWorkouts
    case advancedAnalytics
    case prioritySupport
    case exclusiveContent
    case personalizedConsultations
}

// MARK: - Subscription Validation
extension SubscriptionManager {
    
    @MainActor
    func validateSubscription() async {
        // Check if subscription is expired
        if currentStatus.isExpired {
            // If expired and not auto-renewing, downgrade to free
            if !currentStatus.autoRenew {
                downgradeToFree()
            }
        }
    }
    
     func downgradeToFree() {
        let newStatus = SubscriptionStatus(
            tier: .free,
            startDate: Date(),
            expirationDate: Date().addingTimeInterval(7 * 24 * 60 * 60),
            isActive: true,
            autoRenew: false,
            lastPaymentDate: nil,
            paymentMethod: nil
        )
        
        currentStatus = newStatus
        saveStatus()
    }
}
