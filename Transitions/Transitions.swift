import SwiftUI

struct CascadingAppearModifier: ViewModifier {
    let index: Int
    let baseDelay: Double
    let offsetY: CGFloat
    let duration: Double
    @State private var isVisible = false
    @State private var hasAppeared = false
    
    func body(content: Content) -> some View {
        content
            .opacity(isVisible ? 1 : 0)
            .offset(y: isVisible ? 0 : offsetY)
            .animation(
                .easeOut(duration: duration).delay(baseDelay * Double(index)),
                value: isVisible
            )
            .onAppear {
                guard !hasAppeared else { return }
                hasAppeared = true
                DispatchQueue.main.asyncAfter(deadline: .now() + baseDelay * Double(index)) {
                    withAnimation {
                        isVisible = true
                    }
                }
            }
    }
}

extension View {
    /// Aplica animación de aparición en cascada (fade + slide) según el índice
    func cascadingAppear(index: Int, baseDelay: Double = 0.12, offsetY: CGFloat = 40, duration: Double = 0.5) -> some View {
        self.modifier(CascadingAppearModifier(index: index, baseDelay: baseDelay, offsetY: offsetY, duration: duration))
    }
} 