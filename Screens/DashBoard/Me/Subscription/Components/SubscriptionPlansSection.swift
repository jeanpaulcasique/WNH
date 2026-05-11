// MARK: - SubscriptionPlansSection.swift - Corregido
import SwiftUI

struct SubscriptionPlansSection: View {
    let availablePlans: [SubscriptionPlan]
    let selectedPlan: SubscriptionPlan?
    let currentTier: String
    let isLoading: Bool
    let onPlanSelected: (SubscriptionPlan) -> Void
    let onSubscribe: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Choose Your Plan")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.appYellow)
                Spacer()
            }
            
            ForEach(availablePlans) { plan in
                SubscriptionPlanCard(
                    plan: plan,
                    isSelected: selectedPlan?.id == plan.id,
                    isCurrentPlan: currentTier == plan.id
                ) {
                    onPlanSelected(plan)
                }
            }
            
            if let selectedPlan = selectedPlan,
               selectedPlan.id != currentTier,
               selectedPlan.id != "free" {
                subscribeButton(for: selectedPlan)
            }
        }
    }
    
    // MARK: - Subviews
    private func subscribeButton(for plan: SubscriptionPlan) -> some View {
        Button(action: onSubscribe) {
            HStack {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .black))
                        .scaleEffect(0.8)
                } else {
                    Text("\(LanguageManager.localizedString("Subscribe to")) \(LanguageManager.localizedString(plan.name))")
                        .font(.system(size: 18, weight: .semibold))
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(Color.appYellow)
            .foregroundColor(.black)
            .cornerRadius(12)
        }
        .disabled(isLoading)
    }
}
