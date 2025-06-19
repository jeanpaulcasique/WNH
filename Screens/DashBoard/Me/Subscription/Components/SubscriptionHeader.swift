import SwiftUI

struct SubscriptionHeader: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "crown.fill")
                .font(.system(size: 60))
                .foregroundColor(.appYellow)
            
            Text("Unlock Premium Features")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.appYellow)
                .multilineTextAlignment(.center)
            
            Text("Get unlimited access to all features and premium content")
                .font(.system(size: 16))
                .foregroundColor(.appWhite.opacity(0.8))
                .multilineTextAlignment(.center)
        }
        .padding(.top, 20)
    }
} 