import SwiftUI
import Combine

// MARK: - Diet Info Card Types
enum DietInfoCardType {
    case tip
    case advertisement
    case purchaseLink
    case article
    case promotion
}

// MARK: - Diet Info Card Data Model
struct DietInfoCard: Identifiable {
    let id = UUID()
    let type: DietInfoCardType
    let title: String
    let content: String
    let icon: String?
    let color: Color
    let actionURL: String?
    let isNew: Bool
    let priority: Int // For ordering
    
    // For advertisements and purchases
    let imageURL: String?
    let price: String?
    let discountPercentage: Double?
    let callToAction: String?
    
    init(
        type: DietInfoCardType = .tip,
        title: String,
        content: String,
        icon: String? = nil,
        color: Color = .appYellow,
        actionURL: String? = nil,
        isNew: Bool = false,
        priority: Int = 0,
        imageURL: String? = nil,
        price: String? = nil,
        discountPercentage: Double? = nil,
        callToAction: String? = nil
    ) {
        self.type = type
        self.title = title
        self.content = content
        self.icon = icon
        self.color = color
        self.actionURL = actionURL
        self.isNew = isNew
        self.priority = priority
        self.imageURL = imageURL
        self.price = price
        self.discountPercentage = discountPercentage
        self.callToAction = callToAction
    }
}

// MARK: - Diet Info Card ViewModel
class DietInfoCardModel: ObservableObject {
    @Published var cards: [DietInfoCard] = []
    @Published var currentTipIndex = 0
    @Published var animateTip = false
    @Published var showAdvertisements = false
    @Published var selectedCard: DietInfoCard?
    
    private var cancellables = Set<AnyCancellable>()
    private var tipTimer: Timer?
    
    // MARK: - Initialization
    init() {
        setupDefaultTips()
        startTipAnimation()
    }
    
    deinit {
        tipTimer?.invalidate()
    }
    
    // MARK: - Setup Methods
    private func setupDefaultTips() {
        let defaultTips = [
            DietInfoCard(
                type: .tip,
                title: "Hydration Tip",
                content: "¡Mantén tu cuerpo hidratado! Bebe agua antes de cada comida.",
                icon: "drop.fill",
                color: .cyan,
                priority: 1
            ),
            DietInfoCard(
                type: .tip,
                title: "Protein Power",
                content: "Come proteínas magras en cada comida para mantener la masa muscular.",
                icon: "flame.fill",
                color: .orange,
                priority: 2
            ),
            DietInfoCard(
                type: .tip,
                title: "Colorful Plate",
                content: "Incluye vegetales de colores en tu plato para obtener más nutrientes.",
                icon: "leaf.fill",
                color: .green,
                priority: 3
            ),
            DietInfoCard(
                type: .tip,
                title: "Meal Planning",
                content: "Planifica tus comidas con anticipación para evitar decisiones impulsivas.",
                icon: "calendar",
                color: .blue,
                priority: 4
            ),
            DietInfoCard(
                type: .tip,
                title: "Mindful Eating",
                content: "Mastica lentamente y disfruta cada bocado para mejor digestión.",
                icon: "heart.fill",
                color: .pink,
                priority: 5
            ),
            DietInfoCard(
                type: .tip,
                title: "Breakfast Importance",
                content: "¡No te saltes el desayuno! Es la comida más importante del día.",
                icon: "sunrise.fill",
                color: .yellow,
                priority: 6
            ),
            DietInfoCard(
                type: .tip,
                title: "Healthy Fats",
                content: "Incluye grasas saludables como aguacate y nueces en tu dieta.",
                icon: "nut.fill",
                color: .brown,
                priority: 7
            ),
            DietInfoCard(
                type: .tip,
                title: "Portion Control",
                content: "Controla las porciones usando platos más pequeños.",
                icon: "scalemass.fill",
                color: .purple,
                priority: 8
            ),
            DietInfoCard(
                type: .tip,
                title: "Home Cooking",
                content: "Cocina en casa más seguido para controlar ingredientes y calorías.",
                icon: "house.fill",
                color: .indigo,
                priority: 9
            ),
            DietInfoCard(
                type: .tip,
                title: "Listen to Your Body",
                content: "¡Escucha a tu cuerpo! Come cuando tengas hambre, para cuando estés satisfecho.",
                icon: "ear.fill",
                color: .mint,
                priority: 10
            )
        ]
        
        cards = defaultTips.sorted { $0.priority < $1.priority }
    }
    
    // MARK: - Animation Methods
    private func startTipAnimation() {
        animateTip = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.animateTip = true
        }
        startTipTimer()
    }
    
    private func startTipTimer() {
        tipTimer?.invalidate()
        tipTimer = Timer.scheduledTimer(withTimeInterval: 15.0, repeats: false) { [weak self] _ in
            withAnimation(.spring(response: 0.7, dampingFraction: 0.7)) {
                self?.animateTip = false
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                let isLast = self?.currentTipIndex == (self?.cards.count ?? 0) - 1
                if isLast {
                    Timer.scheduledTimer(withTimeInterval: 60.0, repeats: false) { _ in
                        self?.currentTipIndex = 0
                        self?.animateTip = true
                        self?.startTipTimer()
                    }
                } else {
                    self?.currentTipIndex = (self?.currentTipIndex ?? 0) + 1
                    self?.animateTip = true
                    self?.startTipTimer()
                }
            }
        }
    }
    
    // MARK: - Public Methods
    func addAdvertisementCard(_ card: DietInfoCard) {
        cards.append(card)
        cards.sort { $0.priority < $1.priority }
    }
    
    func addPurchaseLinkCard(_ card: DietInfoCard) {
        cards.append(card)
        cards.sort { $0.priority < $1.priority }
    }
    
    func selectCard(_ card: DietInfoCard) {
        selectedCard = card
        handleCardAction(card)
    }
    
    private func handleCardAction(_ card: DietInfoCard) {
        switch card.type {
        case .tip:
            // Just show the tip, no action needed
            break
        case .advertisement:
            // Handle advertisement click
            if let url = card.actionURL {
                openURL(url)
            }
        case .purchaseLink:
            // Handle purchase link click
            if let url = card.actionURL {
                openURL(url)
            }
        case .article:
            // Handle article click
            if let url = card.actionURL {
                openURL(url)
            }
        case .promotion:
            // Handle promotion click
            if let url = card.actionURL {
                openURL(url)
            }
        }
    }
    
    private func openURL(_ urlString: String) {
        guard let url = URL(string: urlString) else { return }
        UIApplication.shared.open(url)
    }
    
    // MARK: - Computed Properties
    var tipCards: [DietInfoCard] {
        cards.filter { $0.type == .tip }
    }
    
    var advertisementCards: [DietInfoCard] {
        cards.filter { $0.type == .advertisement }
    }
    
    var purchaseCards: [DietInfoCard] {
        cards.filter { $0.type == .purchaseLink }
    }
    
    var currentTip: DietInfoCard? {
        guard currentTipIndex < tipCards.count else { return tipCards.first }
        return tipCards[currentTipIndex]
    }
}
