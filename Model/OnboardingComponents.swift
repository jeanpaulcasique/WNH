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

// MARK: - Selection Card Base
struct SelectionCard<Content: View>: View {
    let isSelected: Bool
    let color: Color
    let action: () -> Void
    let content: Content
    
    init(
        isSelected: Bool,
        color: Color,
        action: @escaping () -> Void,
        @ViewBuilder content: () -> Content
    ) {
        self.isSelected = isSelected
        self.color = color
        self.action = action
        self.content = content()
    }
    
    var body: some View {
        VStack(spacing: 16) {
            content
        }
        .frame(maxWidth: .infinity)
        .frame(height: 160)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.gray.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            isSelected ? color.opacity(0.6) : Color.gray.opacity(0.3),
                            lineWidth: isSelected ? 2 : 1
                        )
                )
        )
        .scaleEffect(isSelected ? 1.02 : 1.0)
        .animation(.spring(response: 0.2, dampingFraction: 0.8), value: isSelected)
        .onTapGesture {
            // Haptic feedback inmediato
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            action()
        }
    }
}

// MARK: - Icon Card
struct IconCard: View {
    let icon: String
    let title: String
    let isSelected: Bool
    let color: Color
    let action: () -> Void
    
    var body: some View {
        SelectionCard(isSelected: isSelected, color: color, action: action) {
            VStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(
                            isSelected ?
                            color.opacity(0.3) :
                            Color.gray.opacity(0.1)
                        )
                        .frame(width: 80, height: 80)
                    
                    Image(systemName: icon)
                        .font(.system(size: 40))
                        .foregroundColor(isSelected ? color : .appWhite.opacity(0.6))
                    
                    if isSelected {
                        Circle()
                            .stroke(color, lineWidth: 3)
                            .frame(width: 80, height: 80)
                    }
                }
                
                Text(title)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(isSelected ? .appWhite : .appWhite.opacity(0.7))
                
                if isSelected {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 14))
                            .foregroundColor(.green)
                        
                        Text("Selected")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.green)
                    }
                }
            }
        }
    }
}

// MARK: - Onboarding Header
struct OnboardingHeader: View {
    let icon: String
    let title: String
    let subtitle: String?
    let progressViewModel: ProgressViewModel
    
    init(
        icon: String,
        title: String,
        subtitle: String? = nil,
        progressViewModel: ProgressViewModel
    ) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self.progressViewModel = progressViewModel
    }
    
    var body: some View {
        VStack(spacing: 20) {
            ProgressBarWithIcons(progressViewModel: progressViewModel)
                .padding(.top, 10)
            
            VStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 50))
                    .foregroundColor(.appYellow)
                
                Text(title)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.appYellow)
                    .multilineTextAlignment(.center)
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.system(size: 16))
                        .foregroundColor(.appWhite.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                }
            }
            .padding(.top, 20)
        }
        .padding(.horizontal, 20)
    }
}

// MARK: - Onboarding Navigation
struct OnboardingNavigation<Destination: View>: View {
    let title: String
    let isEnabled: Bool
    let isLoading: Bool
    let isDisabled: Bool
    let action: () -> Void
    let destination: Destination
    let isActive: Binding<Bool>
    
    init(
        title: String,
        isEnabled: Bool,
        isLoading: Binding<Bool>,
        isDisabled: Binding<Bool>,
        action: @escaping () -> Void,
        destination: Destination,
        isActive: Binding<Bool>
    ) {
        self.title = title
        self.isEnabled = isEnabled
        self.isLoading = isLoading.wrappedValue
        self.isDisabled = isDisabled.wrappedValue
        self.action = action
        self.destination = destination
        self.isActive = isActive
    }
    
    var body: some View {
        VStack {
            if isEnabled {
                NextButton(
                    title: title,
                    action: action,
                    isLoading: .constant(isLoading),
                    isDisabled: .constant(isDisabled)
                )
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isEnabled)
            }
            
            NavigationLink(
                destination: destination,
                isActive: isActive
            ) {
                EmptyView()
            }
            .hidden()
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
    }
}

// MARK: - Onboarding Layout
struct OnboardingLayout<Content: View>: View {
    let progressViewModel: ProgressViewModel
    let header: OnboardingHeader
    let navigation: OnboardingNavigation<AnyView>
    let content: Content
    
    init(
        progressViewModel: ProgressViewModel,
        header: OnboardingHeader,
        navigation: OnboardingNavigation<AnyView>,
        @ViewBuilder content: () -> Content
    ) {
        self.progressViewModel = progressViewModel
        self.header = header
        self.navigation = navigation
        self.content = content()
    }
    
    var body: some View {
        VStack(spacing: 0) {
            header
            
            VStack(spacing: 20) {
                content
            }
            .padding(.top, 30)
            
            Spacer()
            
            navigation
        }
        .background(OnboardingBackground())
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
    }
}

// MARK: - Back Button
struct OnboardingBackButton: View {
    let progressViewModel: ProgressViewModel
    let presentationMode: DismissAction
    
    var body: some View {
        Button(action: {
            progressViewModel.decreaseProgress()
            presentationMode.dismiss()
        }) {
            Image(systemName: "chevron.left")
                .foregroundColor(.appYellow)
                .font(.system(size: 18))
        }
    }
}

// MARK: - Section Header
struct SectionHeader: View {
    let title: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.appYellow)
            Spacer()
        }
        .padding(.horizontal, 20)
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