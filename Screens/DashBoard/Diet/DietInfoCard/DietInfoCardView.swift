import SwiftUI

struct DietInfoCardView: View {
    @StateObject private var viewModel = DietInfoCardModel()
    
    @State private var selectedIndex = 0

    var body: some View {
        TabView(selection: $selectedIndex) {
            ForEach(Array(viewModel.cards.enumerated()), id: \.1.id) { index, card in
                DietInfoCardItem(card: card) {
                    viewModel.selectCard(card)
                }
                .padding(.horizontal, 2)
                .frame(maxWidth: .infinity)
                .tag(index)
            }
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
        .padding(.bottom, 12)
        .padding(.top, 5)
        .frame(height: 180)
        .onReceive(Timer.publish(every: 4, on: .main, in: .common).autoconnect()) { _ in
            withAnimation {
                selectedIndex = (selectedIndex + 1) % viewModel.cards.count
            }
        }
    }
}

// MARK: - Individual Diet Info Card Item
struct DietInfoCardItem: View {
    let card: DietInfoCard
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8) {
                // Header with icon and title
                HStack(spacing: 8) {
                    if let icon = card.icon {
                        Image(systemName: icon)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(card.color)
                    }
                    
                    Text(card.title)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.appWhite)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    if card.isNew {
                        Text("NEW")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.green)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.green.opacity(0.2))
                            .cornerRadius(4)
                    }
                }
                
                // Content
                Text(card.content)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.appWhite.opacity(0.85))
                    .multilineTextAlignment(.leading)
                    .lineLimit(3)
                
                // Footer for advertisements and purchases
                if card.type != .tip {
                    VStack(alignment: .leading, spacing: 4) {
                        if let price = card.price {
                            HStack {
                                Text(price)
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(card.color)
                                
                                if let discount = card.discountPercentage {
                                    Text("-\(Int(discount * 100))%")
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 2)
                                        .background(Color.red)
                                        .cornerRadius(4)
                                }
                                
                                Spacer()
                            }
                        }
                        
                        if let callToAction = card.callToAction {
                            Text(callToAction)
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(card.color)
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity, minHeight: getCardHeight(), maxHeight: getCardHeight())
            .background(.ultraThinMaterial)
            .cornerRadius(18)
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(
                        LinearGradient(
                            colors: [card.color.opacity(0.6), card.color.opacity(0.2), .clear],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5
                    )
            )
            .shadow(color: card.color.opacity(0.15), radius: 8, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func getCardHeight() -> CGFloat {
        switch card.type {
        case .tip:
            return 80
        case .advertisement, .purchaseLink, .article, .promotion:
            return 120
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
