import SwiftUI

struct OnboardingBack: View {
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            Image(systemName: "chevron.left")
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(.white)
                .frame(width: 48, height: 48)
                .background(Color(white: 0.18))
                .clipShape(Circle())
        }
    }
} 