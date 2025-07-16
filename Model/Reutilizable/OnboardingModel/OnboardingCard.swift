import SwiftUI

struct OnboardingCard<Content: View>: View {
    let content: Content
    let backgroundColor: Color
    
    init(backgroundColor: Color = .yellow, @ViewBuilder content: () -> Content) {
        self.backgroundColor = backgroundColor
        self.content = content()
    }
    
    var body: some View {
        VStack(spacing: 8) {
            content
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 18)
        .background(backgroundColor)
        .cornerRadius(24)
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(Color.black, lineWidth: 3)
        )
        .padding(.horizontal, 24)
    }
} 