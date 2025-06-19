import SwiftUI

struct FeatureCard: View {
    let feature: PremiumFeature
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: feature.icon)
                .font(.system(size: 32))
                .foregroundColor(.appYellow)
            
            Text(feature.title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.appWhite)
                .multilineTextAlignment(.center)
            
            Text(feature.description)
                .font(.system(size: 12))
                .foregroundColor(.appWhite.opacity(0.7))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 140)
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
} 
