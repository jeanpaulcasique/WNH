import SwiftUI

struct DietInfoCardView: View {
    @StateObject private var viewModel = DietInfoCardModel()
    @State private var selectedIndex = 0
    @State private var autoScrollTimer: Timer?
    
    var body: some View {
        VStack(spacing: 0) {
            // Cards ScrollView with auto-scroll
            ScrollViewReader { proxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 40) { // 40 points spacing between cards
                        ForEach(Array(viewModel.cards.enumerated()), id: \.element.id) { index, card in
                            DietInfoCardItem(
                                card: card,
                                onTap: {
                                    viewModel.selectCard(card)
                                },
                                onDismiss: {
                                    viewModel.dismissCard(card)
                                }
                            )
                            .frame(width: UIScreen.main.bounds.width - 60) // Card width
                            .id(index) // Add ID for ScrollViewReader
                        }
                    }
                    .padding(.horizontal, 20)
                }
                .frame(height: 100) // Height for promotional banners
                .padding(.bottom, 0)
                .onChange(of: selectedIndex) { newIndex in
                    print("🔄 Scrolling to index: \(newIndex)")
                    // Scroll to the selected card
                    withAnimation(.easeInOut(duration: 0.5)) {
                        proxy.scrollTo(newIndex, anchor: .center)
                    }
                }
            }
            
            // Custom page indicators with proper spacing
            if viewModel.cards.count > 1 {
                HStack(spacing: 8) {
                    ForEach(0..<viewModel.cards.count, id: \.self) { index in
                        Circle()
                            .fill(index == selectedIndex ? Color.appYellow : Color.gray.opacity(0.3))
                            .frame(width: 8, height: 8)
                            .scaleEffect(index == selectedIndex ? 1.2 : 1.0)
                            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: selectedIndex)
                            .onTapGesture {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                    selectedIndex = index
                                }
                            }
                    }
                }
                .padding(.top, 30) // 30 points separation from cards
                .padding(.bottom, 8)
            }
        }
        .padding(.bottom, 0)
        .onAppear {
            print("📱 DietInfoCardView appeared")
            // Set initial page
            selectedIndex = 0
            startAutoScroll()
        }
        .onDisappear {
            stopAutoScroll()
        }
    }
    
    // MARK: - Auto Scroll Functions
    private func startAutoScroll() {
        guard viewModel.cards.count > 1 else { 
            print("⚠️ Auto-scroll: Not enough cards (\(viewModel.cards.count))")
            return 
        }
        
        print("🚀 Starting auto-scroll with \(viewModel.cards.count) cards")
        stopAutoScroll() // Clean up any existing timer
        
        autoScrollTimer = Timer.scheduledTimer(withTimeInterval: 4.0, repeats: true) { _ in
            DispatchQueue.main.async {
                print("⏰ Timer fired - Current index: \(self.selectedIndex)")
                withAnimation(.easeInOut(duration: 0.5)) {
                    if self.selectedIndex < self.viewModel.cards.count - 1 {
                        self.selectedIndex += 1
                        print("➡️ Moving to next card: \(self.selectedIndex)")
                    } else {
                        self.selectedIndex = 0 // Loop back to first card
                        print("🔄 Looping back to first card: \(self.selectedIndex)")
                    }
                }
            }
        }
        
        print("✅ Auto-scroll timer started")
    }
    
    private func stopAutoScroll() {
        autoScrollTimer?.invalidate()
        autoScrollTimer = nil
    }
}

// MARK: - Individual Diet Info Card Item
struct DietInfoCardItem: View {
    let card: DietInfoCard
    let onTap: () -> Void
    let onDismiss: (() -> Void)?
    
    init(card: DietInfoCard, onTap: @escaping () -> Void, onDismiss: (() -> Void)? = nil) {
        self.card = card
        self.onTap = onTap
        self.onDismiss = onDismiss
    }
    
    var body: some View {
        Group {
            switch card.type {
            case .promotionalBanner:
                PromotionalBannerCard(banner: card, onTap: onTap, onDismiss: onDismiss)
            default:
                // Default card design (same as nutrition cards)
                Button(action: onTap) {
                    HStack(spacing: 15) {
                        // Icon with background circle (same as nutrition cards)
                        if let icon = card.icon {
                            Image(systemName: icon)
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(card.color)
                                .frame(width: 45, height: 45)
                                .background(card.color.opacity(0.15))
                                .clipShape(Circle())
                        }
                        
                        // Content section
                        VStack(alignment: .leading, spacing: 2) {
                            // Title with NEW badge
                            HStack {
                                Text(card.title)
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.appWhite)
                                    .lineLimit(1)
                                
                                if card.isNew {
                                    Text("NEW")
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundColor(.green)
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 2)
                                        .background(Color.green.opacity(0.2))
                                        .cornerRadius(4)
                                }
                                
                                Spacer()
                            }
                            
                            // Content text
                            Text(card.content)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.appWhite.opacity(0.7))
                                .lineLimit(2)
                                .multilineTextAlignment(.leading)
                        }
                        
                        Spacer()
                        
                        // Chevron indicator (same as nutrition cards)
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.appWhite.opacity(0.5))
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(
                                LinearGradient(
                                    colors: [card.color.opacity(0.6), card.color.opacity(0.2), .clear],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1.5
                            )
                    )
                    .shadow(color: card.color.opacity(0.15), radius: 8, x: 0, y: 4)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
    

}

// MARK: - Animated Tip Card (for current tip display)
struct AnimatedTipCard: View {
    let tip: DietInfoCard
    let isAnimating: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header with icon and title
            HStack(spacing: 8) {
                if let icon = tip.icon {
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(tip.color)
                }
                
                Text(tip.title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.appWhite)
                    .lineLimit(1)
                
                Spacer()
            }
            
            // Content
            Text(tip.content)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.appWhite.opacity(0.85))
                .multilineTextAlignment(.leading)
                .lineLimit(3)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .frame(width: 280, height: 80)
        .background(.ultraThinMaterial)
        .cornerRadius(18)
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(
                    LinearGradient(
                        colors: [tip.color.opacity(0.6), tip.color.opacity(0.2), .clear],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.5
                )
        )
        .shadow(color: tip.color.opacity(0.15), radius: 8, x: 0, y: 2)
        .opacity(isAnimating ? 1 : 0)
        .scaleEffect(isAnimating ? 1 : 0.95)
        .animation(.spring(response: 0.7, dampingFraction: 0.7), value: isAnimating)
    }
}

// MARK: - Promotional Banner Card
struct PromotionalBannerCard: View {
    let banner: DietInfoCard
    let onTap: () -> Void
    let onDismiss: (() -> Void)?
    
    var body: some View {
        ZStack {
            // Main card background
            RoundedRectangle(cornerRadius: 20)
                .fill(banner.color)
                .shadow(color: banner.color.opacity(0.3), radius: 10, x: 0, y: 5)
            
            HStack(spacing: 0) {
                // Left section - Text content
                VStack(alignment: .leading, spacing: 8) {
                    Text(banner.title)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    
                    Text(banner.content)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                        .lineLimit(1)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 20)
                .padding(.trailing, 10)
                
                // Right section - Brand logo
                ZStack {
                    // Outer silver circle
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.gray.opacity(0.8), Color.white.opacity(0.9), Color.gray.opacity(0.6)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 70, height: 70)
                        .shadow(color: .black.opacity(0.2), radius: 5, x: 2, y: 2)
                    
                    // Inner red circle
                    Circle()
                        .fill(Color.red)
                        .frame(width: 55, height: 55)
                    
                    // Brand text
                    VStack(spacing: 0) {
                        Text("Ali")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                        Text("Express")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.white)
                            .italic()
                    }
                    
                    // Small plus icon
                    VStack {
                        HStack {
                            Circle()
                                .fill(Color.purple)
                                .frame(width: 20, height: 20)
                                .overlay(
                                    Image(systemName: "plus")
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundColor(.white)
                                )
                            Spacer()
                        }
                        Spacer()
                    }
                    .frame(width: 70, height: 70)
                }
                .padding(.trailing, 20)
            }
            
            // Close button (top-right)
            if banner.isDismissible {
                VStack {
                    HStack {
                        Spacer()
                        Button(action: {
                            onDismiss?()
                        }) {
                            Image(systemName: "xmark")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white.opacity(0.8))
                                .frame(width: 24, height: 24)
                                .background(Color.black.opacity(0.3))
                                .clipShape(Circle())
                        }
                    }
                    Spacer()
                }
                .padding(.top, 12)
                .padding(.trailing, 12)
            }
        }
        .frame(height: 100)
        .onTapGesture {
            onTap()
        }
    }
}

// MARK: - Advertisement Card (for future use)
struct AdvertisementCard: View {
    let advertisement: DietInfoCard
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8) {
                // Image placeholder
                if let imageURL = advertisement.imageURL {
                    AsyncImage(url: URL(string: imageURL)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Rectangle()
                            .fill(advertisement.color.opacity(0.2))
                            .overlay(
                                Image(systemName: "photo")
                                    .font(.system(size: 24))
                                    .foregroundColor(advertisement.color)
                            )
                    }
                    .frame(height: 60)
                    .clipped()
                    .cornerRadius(12)
                }
                
                // Content
                Text(advertisement.title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.appWhite)
                    .lineLimit(1)
                
                Text(advertisement.content)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.appWhite.opacity(0.7))
                    .lineLimit(2)
                
                // Call to action
                if let callToAction = advertisement.callToAction {
                    Text(callToAction)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(advertisement.color)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(advertisement.color.opacity(0.2))
                        .cornerRadius(8)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .frame(width: 280, height: 120)
            .background(.ultraThinMaterial)
            .cornerRadius(18)
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(
                        LinearGradient(
                            colors: [advertisement.color.opacity(0.6), advertisement.color.opacity(0.2), .clear],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5
                    )
            )
            .shadow(color: advertisement.color.opacity(0.15), radius: 8, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Preview
#if DEBUG
struct DietInfoCardView_Previews: PreviewProvider {
    static var previews: some View {
        DietInfoCardView()
            .preferredColorScheme(.dark)
    }
}
#endif
