import SwiftUI
import Foundation
import Combine

// MARK: - Models
struct SubscriptionPlan: Identifiable, Codable {
    let id: String
    let name: String
    let description: String
    let price: Double
    let currency: String
    let period: SubscriptionPeriod
    let isPopular: Bool
    let savings: Int // Percentage saved compared to monthly
    let features: [String]
    
    var priceText: String {
        if price == 0 {
            return "Free"
        }
        return String(format: "$%.2f", price)
    }
    
    var periodText: String {
        switch period {
        case .free:
            return ""
        case .monthly:
            return "per month"
        case .yearly:
            return "per year"
        case .lifetime:
            return "one time"
        }
    }
}

enum SubscriptionPeriod: String, Codable, CaseIterable {
    case free = "free"
    case monthly = "monthly"
    case yearly = "yearly"
    case lifetime = "lifetime"
}

struct CurrentSubscription: Codable {
    let id: String
    let name: String
    let isActive: Bool
    let expirationDate: Date
    let autoRenewal: Bool
}

struct PremiumFeature {
    let title: String
    let description: String
    let icon: String
}

// MARK: - SubscriptionViewModel
final class SubscriptionViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var availablePlans: [SubscriptionPlan] = []
    @Published var currentPlan: CurrentSubscription = CurrentSubscription(
        id: "free",
        name: "Free Plan",
        isActive: false,
        expirationDate: Date(),
        autoRenewal: false
    )
    @Published var selectedPlan: SubscriptionPlan?
    @Published var isLoading = false
    @Published var showAlert = false
    @Published var alertMessage = ""
    
    // MARK: - Private Properties
    private let userDefaults = UserDefaults.standard
    private let subscriptionKey = "user_subscription"
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Constants
    let premiumFeatures: [PremiumFeature] = [
        PremiumFeature(
            title: "Unlimited Workouts",
            description: "Access to all workout plans and exercises",
            icon: "figure.strengthtraining.traditional"
        ),
        PremiumFeature(
            title: "Personal Coach",
            description: "1-on-1 coaching sessions and support",
            icon: "person.fill.checkmark"
        ),
        PremiumFeature(
            title: "Advanced Analytics",
            description: "Detailed progress tracking and insights",
            icon: "chart.line.uptrend.xyaxis"
        ),
        PremiumFeature(
            title: "Meal Planning",
            description: "Custom meal plans based on your goals",
            icon: "fork.knife"
        ),
        PremiumFeature(
            title: "Ad-Free Experience",
            description: "Enjoy the app without any interruptions",
            icon: "eye.slash.fill"
        ),
        PremiumFeature(
            title: "Priority Support",
            description: "Get help when you need it most",
            icon: "headphones"
        )
    ]
    
    // MARK: - Initialization
    init() {
        setupAvailablePlans()
        loadCurrentSubscription()
    }
    
    // MARK: - Public Methods
    func loadSubscriptionData() {
        isLoading = true
        
        // Simulate API call
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.loadCurrentSubscription()
            self.isLoading = false
        }
    }
    
    func selectPlan(_ plan: SubscriptionPlan) {
        selectedPlan = plan
        generateHapticFeedback()
    }
    
    func purchaseSelectedPlan() {
        guard let plan = selectedPlan else { return }
        
        isLoading = true
        
        // Simulate purchase process
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.processPurchase(plan: plan)
        }
    }
    
    func restorePurchases() {
        isLoading = true
        
        // Simulate restore process
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.showAlert(message: "No previous purchases found to restore.")
            self.isLoading = false
        }
    }
    
    func cancelSubscription() {
        // This would typically involve calling your backend API
        showAlert(message: "Please contact support to cancel your subscription.")
    }
    
    // MARK: - Private Methods
    private func setupAvailablePlans() {
        availablePlans = [
            SubscriptionPlan(
                id: "free",
                name: "Free",
                description: "Basic features to get started",
                price: 0.0,
                currency: "USD",
                period: .free,
                isPopular: false,
                savings: 0,
                features: [
                    "3 workout plans",
                    "Basic tracking",
                    "Community access"
                ]
            ),
            SubscriptionPlan(
                id: "monthly",
                name: "Monthly Pro",
                description: "Full access to all premium features",
                price: 9.99,
                currency: "USD",
                period: .monthly,
                isPopular: false,
                savings: 0,
                features: [
                    "Unlimited workouts",
                    "Personal coaching",
                    "Advanced analytics",
                    "Meal planning",
                    "Ad-free experience"
                ]
            ),
            SubscriptionPlan(
                id: "yearly",
                name: "Yearly Pro",
                description: "Best value - Save 58% with annual billing",
                price: 49.99,
                currency: "USD",
                period: .yearly,
                isPopular: true,
                savings: 58,
                features: [
                    "Everything in Monthly Pro",
                    "Priority support",
                    "Exclusive content",
                    "Early access to features"
                ]
            ),
            SubscriptionPlan(
                id: "lifetime",
                name: "Lifetime Pro",
                description: "One-time payment for lifetime access",
                price: 199.99,
                currency: "USD",
                period: .lifetime,
                isPopular: false,
                savings: 0,
                features: [
                    "Everything in Yearly Pro",
                    "Lifetime updates",
                    "VIP support",
                    "Exclusive community"
                ]
            )
        ]
        
        // Set initial selection to the popular plan
        selectedPlan = availablePlans.first { $0.isPopular }
    }
    
    private func loadCurrentSubscription() {
        if let data = userDefaults.data(forKey: subscriptionKey),
           let subscription = try? JSONDecoder().decode(CurrentSubscription.self, from: data) {
            currentPlan = subscription
        }
    }
    
    private func saveCurrentSubscription(_ subscription: CurrentSubscription) {
        if let data = try? JSONEncoder().encode(subscription) {
            userDefaults.set(data, forKey: subscriptionKey)
        }
    }
    
    private func processPurchase(plan: SubscriptionPlan) {
        // Simulate successful purchase
        let expirationDate: Date
        
        switch plan.period {
        case .free:
            expirationDate = Date()
        case .monthly:
            expirationDate = Calendar.current.date(byAdding: .month, value: 1, to: Date()) ?? Date()
        case .yearly:
            expirationDate = Calendar.current.date(byAdding: .year, value: 1, to: Date()) ?? Date()
        case .lifetime:
            expirationDate = Calendar.current.date(byAdding: .year, value: 100, to: Date()) ?? Date()
        }
        
        let newSubscription = CurrentSubscription(
            id: plan.id,
            name: plan.name,
            isActive: plan.period != .free,
            expirationDate: expirationDate,
            autoRenewal: plan.period == .monthly || plan.period == .yearly
        )
        
        currentPlan = newSubscription
        saveCurrentSubscription(newSubscription)
        
        isLoading = false
        showAlert(message: "Successfully subscribed to \(plan.name)!")
        
        // Reset selection
        selectedPlan = nil
        
        generateHapticFeedback(style: .medium)
    }
    
    private func showAlert(message: String) {
        alertMessage = message
        showAlert = true
    }
    
    private func generateHapticFeedback(style: UIImpactFeedbackGenerator.FeedbackStyle = .light) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
    
    // MARK: - Computed Properties
    var hasActiveSubscription: Bool {
        return currentPlan.isActive && currentPlan.expirationDate > Date()
    }
    
    var subscriptionStatusText: String {
        if hasActiveSubscription {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            return "Active until \(formatter.string(from: currentPlan.expirationDate))"
        } else {
            return "No active subscription"
        }
    }
}

// MARK: - Extensions
extension SubscriptionViewModel {
    
    // Helper methods for external use
    func isFeatureUnlocked(_ feature: String) -> Bool {
        return hasActiveSubscription
    }
    
    func requiresPremium(for feature: String, completion: @escaping (Bool) -> Void) {
        if hasActiveSubscription {
            completion(true)
        } else {
            completion(false)
            showAlert(message: "This feature requires a premium subscription.")
        }
    }
}
