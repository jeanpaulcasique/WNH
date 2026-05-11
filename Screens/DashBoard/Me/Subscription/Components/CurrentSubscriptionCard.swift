import SwiftUI

struct CurrentSubscriptionCard: View {
    let currentStatus: SubscriptionStatus
    let onCancelSubscription: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Current Subscription")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.appYellow)
                Spacer()
            }
            
            VStack(spacing: 12) {
                subscriptionStatusCard
                
                if currentStatus.tier != .free {
                    cancelSubscriptionButton
                }
            }
        }
    }
    
    private var subscriptionStatusCard: some View {
        VStack(spacing: 16) {
            subscriptionHeader
            Divider()
                .background(Color.appWhite.opacity(0.2))
            subscriptionDetails
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
    
    private var subscriptionHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(currentStatus.tier.rawValue.capitalized)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.appWhite)
                
                if currentStatus.isActive {
                    Text("Active")
                        .font(.system(size: 14))
                        .foregroundColor(.green)
                } else {
                    Text("Inactive")
                        .font(.system(size: 14))
                        .foregroundColor(.red)
                }
            }
            
            Spacer()
            
            Circle()
                .fill(currentStatus.isActive ? .green : .gray)
                .frame(width: 12, height: 12)
        }
    }
    
    private var subscriptionDetails: some View {
        VStack(spacing: 12) {
            subscriptionDetailRow(
                title: "Start Date:",
                value: currentStatus.startDate,
                isDate: true
            )
            
            subscriptionDetailRow(
                title: "Expiration Date:",
                value: currentStatus.expirationDate,
                isDate: true
            )
            
            subscriptionDetailRow(
                title: "Days Remaining:",
                value: "\(currentStatus.daysRemaining) days",
                isHighlighted: true
            )
            
            if currentStatus.autoRenew {
                subscriptionDetailRow(
                    title: "Auto-Renew:",
                    value: "Enabled",
                    isHighlighted: true
                )
            }
        }
    }
    
    private func subscriptionDetailRow(title: String, value: Any, isDate: Bool = false, isHighlighted: Bool = false) -> some View {
        HStack {
            Text(LanguageManager.localizedString(title))
                .font(.system(size: 14))
                .foregroundColor(.appWhite.opacity(0.7))
            
            Spacer()
            
            if isDate {
                Text(value as! Date, style: .date)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.appWhite)
            } else {
                Text(value as! String)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(isHighlighted ? .appYellow : .appWhite)
            }
        }
    }
    
    private var cancelSubscriptionButton: some View {
        Button(action: onCancelSubscription) {
            Text("Cancel Subscription")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.red)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.red.opacity(0.1))
                .cornerRadius(12)
        }
    }
}

