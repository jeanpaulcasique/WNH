import SwiftUI

struct FeaturesSection: View {
    let features: [PremiumFeature]
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Premium Features")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.appYellow)
                Spacer()
            }
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                ForEach(features, id: \.title) { feature in
                    FeatureCard(feature: feature)
                }
            }
        }
    }
}
 