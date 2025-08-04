import SwiftUI

// MARK: - Onboarding Navigation
struct OnboardingNavigation<Content: View>: View {
    
    let showBackButton: Bool
    let onBack: (() -> Void)?
    let content: Content
    
    init(
        showBackButton: Bool = true,
        onBack: (() -> Void)? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.showBackButton = showBackButton
        self.onBack = onBack
        self.content = content()
    }
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [Color.black, Color.gray.opacity(0.3)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top navigation bar
                HStack {
                    if showBackButton, let onBack = onBack {
                        BackButton(action: onBack)
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                
                // Content
                ScrollView {
                    VStack(spacing: 30) {
                        content
                    }
                    .padding(.bottom, 100) // Space for bottom button
                }
            }
        }
    }
}

// MARK: - Bottom Navigation
struct BottomNavigation<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            content
                .padding(.horizontal, 20)
                .padding(.bottom, 34) // Safe area
                .background(
                    Rectangle()
                        .fill(.ultraThinMaterial)
                        .ignoresSafeArea()
                )
        }
    }
} 