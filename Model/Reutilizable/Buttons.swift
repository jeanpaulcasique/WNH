import SwiftUI

// MARK: - Next Button (usando la implementación existente)
struct NextButton: View {
    let title: String
    let action: () -> Void
    @Binding var isLoading: Bool
    @Binding var isDisabled: Bool

    var body: some View {
        Button(action: {
            if !isDisabled {
                isDisabled = true
                isLoading = true
                action()
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    isDisabled = false
                    isLoading = false
                }
            }
        }) {
            ZStack {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .black))
                } else {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.black)
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.yellow)
            .cornerRadius(10)
            .shadow(color: Color.gray.opacity(0.4), radius: 5, x: 0, y: 5)
        }
        .padding(.horizontal, 20)
        .disabled(isDisabled)
    }
}

// MARK: - Back Button
struct BackButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            action()
        }) {
            HStack(spacing: 8) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.appYellow)
                
                Text("Back")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.appYellow)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.appYellow.opacity(0.3), lineWidth: 1)
                    )
            )
        }
    }
}

// MARK: - Primary Button
struct PrimaryButton: View {
    let title: String
    let icon: String?
    let isEnabled: Bool
    let action: () -> Void
    
    init(
        title: String,
        icon: String? = nil,
        isEnabled: Bool = true,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.isEnabled = isEnabled
        self.action = action
    }
    
    var body: some View {
        Button(action: {
            if isEnabled {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                action()
            }
        }) {
            HStack(spacing: 8) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.appWhite)
                }
                
                Text(title)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.appWhite)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        isEnabled ?
                        LinearGradient(
                            colors: [.appYellow, .appYellow.opacity(0.8)],
                            startPoint: .leading,
                            endPoint: .trailing
                        ) :
                        LinearGradient(
                            colors: [Color.gray.opacity(0.3), Color.gray.opacity(0.2)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
            )
        }
        .disabled(!isEnabled)
        .scaleEffect(isEnabled ? 1.0 : 0.98)
        .animation(.spring(response: 0.2, dampingFraction: 0.8), value: isEnabled)
    }
} 

// MARK: - Unit Selector Button (reutilizable)
public struct UnitSelectorButton: View {
    let title: String
    let subtitle: String
    let isSelected: Bool
    let color: Color
    let action: () -> Void
    
    public init(title: String, subtitle: String, isSelected: Bool, color: Color, action: @escaping () -> Void) {
        self.title = title
        self.subtitle = subtitle
        self.isSelected = isSelected
        self.color = color
        self.action = action
    }
    
    public var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 24))
                    .foregroundColor(isSelected ? color : Color.black.opacity(0.2))
                
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(isSelected ? .black : .black.opacity(0.7))
                
                Text(subtitle)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(isSelected ? color : Color.black.opacity(0.5))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.gray.opacity(isSelected ? 0.15 : 0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(isSelected ? color.opacity(0.6) : Color.gray.opacity(0.3), lineWidth: isSelected ? 2 : 1)
                    )
            )
            .scaleEffect(isSelected ? 1.02 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
        }
        .buttonStyle(PlainButtonStyle())
    }
} 