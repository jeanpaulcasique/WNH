import SwiftUI

struct OnboardingNext: View {
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Text("Next")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.black)
                Image(systemName: "arrow.right")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.black)
            }
            .padding(.horizontal, 32)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 30)
                    .fill(Color.yellow)
                    .shadow(color: Color.yellow.opacity(0.25), radius: 10, x: 0, y: 4)
            )
        }
        .scaleEffect(1.0)
        .padding(.trailing, 20)
        .padding(.bottom, 20)
    }
} 