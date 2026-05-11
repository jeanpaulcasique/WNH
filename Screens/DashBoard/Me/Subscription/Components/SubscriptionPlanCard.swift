import Foundation
import SwiftUI

// MARK: - SubscriptionPlan Model
struct SubscriptionPlan: Identifiable, Codable {
    let id: String
    let name: String
    let description: String
    var price: Double
    var currency: String
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
            return LanguageManager.localizedString("per month")
        case .threeMonths:
            return LanguageManager.localizedString("for 3 months")
        case .yearly:
            return LanguageManager.localizedString("per year")
        }
    }
}

enum SubscriptionPeriod: String, Codable, CaseIterable {
    case free = "free"
    case monthly = "monthly"
    case threeMonths = "three_months"
    case yearly = "yearly"
}

struct SubscriptionPlanCard: View {
    let plan: SubscriptionPlan
    let isSelected: Bool
    let isCurrentPlan: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(LanguageManager.localizedString(plan.name))
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.appWhite)
                            
                            if plan.isPopular {
                                Text("POPULAR")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(.black)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 2)
                                    .background(Color.appYellow)
                                    .cornerRadius(4)
                            }
                            
                            Spacer()
                        }
                        
                        Text(LanguageManager.localizedString(plan.description))
                            .font(.system(size: 14))
                            .foregroundColor(.appWhite.opacity(0.8))
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing) {
                        if isCurrentPlan {
                            Text("CURRENT")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.green)
                        } else {
                            Text(plan.priceText)
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.appYellow)
                            
                            if !plan.periodText.isEmpty {
                                Text(plan.periodText)
                                    .font(.system(size: 12))
                                    .foregroundColor(.appWhite.opacity(0.6))
                            }
                        }
                    }
                }
                
                if plan.savings > 0 {
                    HStack {
                        Text("Save \(plan.savings)%")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.green)
                        Spacer()
                    }
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(
                                isSelected ? Color.appYellow :
                                isCurrentPlan ? Color.green : Color.clear,
                                lineWidth: 2
                            )
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}
