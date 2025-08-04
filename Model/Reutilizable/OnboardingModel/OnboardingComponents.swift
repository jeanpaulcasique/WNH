import SwiftUI

// MARK: - Onboarding Background
struct OnboardingBackground: View {
    var body: some View {
        LinearGradient(
            colors: [Color.appBlack, Color.gray.opacity(0.3), Color.appBlack],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
}

// MARK: - Onboarding Layout
struct OnboardingLayout<Content: View>: View {
    let header: PageHeader
    let showBackButton: Bool
    let onBack: (() -> Void)?
    let content: Content
    
    init(
        header: PageHeader,
        showBackButton: Bool = true,
        onBack: (() -> Void)? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.header = header
        self.showBackButton = showBackButton
        self.onBack = onBack
        self.content = content()
    }
    
    var body: some View {
        ZStack {
            OnboardingBackground()
            
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
                
                // Header
                header
                
                // Content
                ScrollableContent {
                    VStack(spacing: 30) {
                        content
                    }
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
    }
}

// MARK: - Onboarding Navigation with Next Button
struct OnboardingNavigationWithNext: View {
    let isEnabled: Bool
    let action: () -> Void
    @State private var isLoading: Bool = false
    @State private var isDisabled: Bool = false
    var body: some View {
        BottomNavigation {
            NextButton(
                title: "Next",
                action: action,
                isLoading: $isLoading,
                isDisabled: .constant(!isEnabled)
            )
        }
    }
}

// MARK: - Back Button
struct OnboardingBackButton: View {
    let presentationMode: DismissAction
    
    var body: some View {
        Button(action: {
            presentationMode()
        }) {
            Image(systemName: "chevron.left")
                .foregroundColor(.appYellow)
                .font(.system(size: 18))
        }
    }
}

// MARK: - Success Animation
struct SelectionSuccessView: View {
    let message: String
    
    init(_ message: String = "Selection saved!") {
        self.message = message
    }
    
    var body: some View {
        VStack {
            Spacer()
            
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                
                Text(message)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.appWhite)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(Color.gray.opacity(0.9))
            .cornerRadius(25)
            .padding(.bottom, 60)
        }
    }
} 