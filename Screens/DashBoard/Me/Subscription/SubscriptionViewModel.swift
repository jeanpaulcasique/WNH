// MARK: - SubscriptionViewModel.swift - Agregar estas mejoras
import SwiftUI
import Foundation
import Combine

final class SubscriptionViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var availablePlans: [SubscriptionPlan] = []
    @Published var selectedPlan: SubscriptionPlan?
    @Published var isLoading = false
    @Published var showAlert = false
    @Published var alertMessage = ""
    // ✅ NUEVOS: Estados específicos de loading
    @Published var isPurchasing = false
    @Published var isRestoring = false
    
    // MARK: - Private Properties
    let subscriptionManager = SubscriptionManager.shared
    
    // MARK: - Constants - Mantén tus features existentes
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
    }
    
    // MARK: - Public Methods
    func loadSubscriptionData() {
        // ✅ ELIMINADO: Loading inicial innecesario
        // Los datos ya están disponibles desde la inicialización
    }
    
    func selectPlan(_ plan: SubscriptionPlan) {
        selectedPlan = plan
        generateHapticFeedback()
    }
    
    // ✅ MEJORADO: Manejo de compra con estados específicos
    func purchaseSelectedPlan() {
        guard let plan = selectedPlan else { return }
        
        isPurchasing = true
        
        // Convert plan to subscription tier
        let tier: SubscriptionTier
        switch plan.period {
        case .free:
            tier = .free
        case .monthly:
            tier = .monthly
        case .threeMonths:
            tier = .threeMonths
        case .yearly:
            tier = .yearly
        }
        
        // Simulate purchase process
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            if self.subscriptionManager.upgradeTo(tier: tier) {
                self.showAlert(message: "Successfully subscribed to \(plan.name)!")
                self.selectedPlan = nil
            } else {
                self.showAlert(message: "Unable to process subscription. Please try again.")
            }
            
            self.isPurchasing = false
        }
    }
    
    // ✅ NUEVO: Restaurar compras
    func restorePurchases() {
        isRestoring = true
        
        // Simulate restore process
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.showAlert(message: "No previous purchases found to restore.")
            self.isRestoring = false
        }
    }
    
    func cancelSubscription() {
        subscriptionManager.cancelSubscription()
        showAlert(message: "Your subscription will not renew. You'll still have access until the end of your billing period.")
    }
    
    // ✅ NUEVO: Manejo de downgrade
    func handleDowngrade(to plan: SubscriptionPlan) {
        if plan.id == "free" {
            subscriptionManager.cancelSubscription()
            selectedPlan = plan
            showAlert(message: "You'll keep premium access until your subscription expires.")
        }
    }
    
    func updateSubscriptionToFree() {
        subscriptionManager.downgradeToFree()
    }
    
    // MARK: - Private Methods
    private func setupAvailablePlans() {
        availablePlans = [
            SubscriptionPlan(
                id: "free",
                name: "Free",
                description: "7 days access to personalized diets and workouts",
                price: 0.0,
                currency: "USD",
                period: .free,
                isPopular: false,
                savings: 0,
                features: [
                    "7 days of personalized diets",
                    "7 days of personalized workouts",
                    "Basic community access",
                    "Basic progress tracking"
                ]
            ),
            SubscriptionPlan(
                id: "monthly",
                name: "Monthly Pro",
                description: "Full access to all premium features",
                price: 10.0,
                currency: "USD",
                period: .monthly,
                isPopular: false,
                savings: 0,
                features: [
                    "Unlimited personalized diets",
                    "Unlimited personalized workouts",
                    "Personal coaching",
                    "Advanced analytics",
                    "Meal planning",
                    "Ad-free experience"
                ]
            ),
            SubscriptionPlan(
                id: "three_months",
                name: "Three Months Pro",
                description: "Best value - Save 17% with quarterly billing",
                price: 25.0,
                currency: "USD",
                period: .threeMonths,
                isPopular: true,
                savings: 17,
                features: [
                    "Everything in Monthly Pro",
                    "Priority support",
                    "Exclusive content",
                    "Early access to new features",
                    "Advanced nutrition guides",
                    "Premium recipes"
                ]
            ),
            SubscriptionPlan(
                id: "yearly",
                name: "Yearly Pro",
                description: "Best value - Save 17% with annual billing",
                price: 100.0,
                currency: "USD",
                period: .yearly,
                isPopular: false,
                savings: 17,
                features: [
                    "Everything in Three Months Pro",
                    "Lifetime updates",
                    "VIP support",
                    "Exclusive community",
                    "Monthly personalized consultations",
                    "Access to exclusive events"
                ]
            )
        ]
        
        // Set initial selection to the popular plan
        selectedPlan = availablePlans.first { $0.isPopular }
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
        return subscriptionManager.currentStatus.isActive && !subscriptionManager.currentStatus.isExpired
    }
    
    var subscriptionStatusText: String {
        let status = subscriptionManager.currentStatus
        if status.isActive && !status.isExpired {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            return "Active until \(formatter.string(from: status.expirationDate))"
        } else {
            return "No active subscription"
        }
    }
}

// MARK: - Extensions
extension SubscriptionViewModel {
    
    // Helper methods for external use
    func isFeatureUnlocked(_ feature: SubscriptionFeature) -> Bool {
        return subscriptionManager.isFeatureAvailable(feature)
    }
    
    func requiresPremium(for feature: SubscriptionFeature, completion: @escaping (Bool) -> Void) {
        if subscriptionManager.isFeatureAvailable(feature) {
            completion(true)
        } else {
            completion(false)
            showAlert(message: "This feature requires a premium subscription.")
        }
    }
}
