import SwiftUI

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
        .animation(.easeOut(duration: 0.15), value: isSelected)
        .onTapGesture {
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

// MARK: - Info Card
struct InfoCard: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 50, height: 50)
                
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(color)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.appWhite)
                
                Text(description)
                    .font(.system(size: 14))
                    .foregroundColor(.appWhite.opacity(0.7))
                    .lineLimit(2)
            }
            
            Spacer()
        }
        .padding(16)
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
    }
}

// MARK: - Expandable Selection Card
struct ExpandableSelectionCard<Header: View, Expanded: View>: View {
    let isSelected: Bool
    let color: Color
    let action: () -> Void
    let header: Header
    let expandedContent: Expanded

    init(
        isSelected: Bool,
        color: Color,
        action: @escaping () -> Void,
        @ViewBuilder header: () -> Header,
        @ViewBuilder expandedContent: () -> Expanded
    ) {
        self.isSelected = isSelected
        self.color = color
        self.action = action
        self.header = header()
        self.expandedContent = expandedContent()
    }

    var body: some View {
        VStack(spacing: 0) {
            header
                .padding(20)
            if isSelected {
                VStack(spacing: 12) {
                    Divider()
                        .background(color.opacity(0.3))
                    expandedContent
                        .padding(.horizontal, 20)
                        .padding(.bottom, 16)
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.gray.opacity(isSelected ? 0.15 : 0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            isSelected ? color.opacity(0.6) : Color.gray.opacity(0.3),
                            lineWidth: isSelected ? 2 : 1
                        )
                )
        )
        .scaleEffect(isSelected ? 1.02 : 1.0)
        .shadow(
            color: isSelected ? color.opacity(0.3) : Color.clear,
            radius: isSelected ? 12 : 0,
            x: 0,
            y: 6
        )
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
        .onTapGesture {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            action()
        }
        .buttonStyle(PlainButtonStyle())
    }
} 