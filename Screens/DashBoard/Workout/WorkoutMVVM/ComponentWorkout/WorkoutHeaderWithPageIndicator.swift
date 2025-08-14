import SwiftUI
import Combine

// MARK: - Workout Header Card Types
enum WorkoutHeaderCardType {
    case tip
    case motivation
    case achievement
    case reminder
}

// MARK: - Workout Header Card Data Model
struct WorkoutHeaderCard: Identifiable {
    let id = UUID()
    let type: WorkoutHeaderCardType
    let title: String
    let content: String
    let icon: String?
    let color: Color
    let priority: Int
    
    init(
        type: WorkoutHeaderCardType = .tip,
        title: String,
        content: String,
        icon: String? = nil,
        color: Color = .appYellow,
        priority: Int = 0
    ) {
        self.type = type
        self.title = title
        self.content = content
        self.icon = icon
        self.color = color
        self.priority = priority
    }
}

// MARK: - Workout Header with Page Indicator ViewModel
class WorkoutHeaderWithPageIndicatorModel: ObservableObject {
    @Published var cards: [WorkoutHeaderCard] = []
    @Published var selectedIndex = 0
    @Published var autoScrollTimer: Timer?
    
    init() {
        setupDefaultCards()
    }
    
    deinit {
        autoScrollTimer?.invalidate()
    }
    
    private func setupDefaultCards() {
        let defaultCards = [
            WorkoutHeaderCard(
                type: .motivation,
                title: "¡Mantén la consistencia!",
                content: "Cada entrenamiento te acerca a tus objetivos. ¡Tú puedes!",
                icon: "figure.strengthtraining.traditional",
                color: .appYellow,
                priority: 1
            ),
            WorkoutHeaderCard(
                type: .tip,
                title: "Calentamiento Importante",
                content: "Dedica 5-10 minutos al calentamiento para prevenir lesiones.",
                icon: "flame.fill",
                color: .orange,
                priority: 2
            ),
            WorkoutHeaderCard(
                type: .achievement,
                title: "¡Excelente progreso!",
                content: "Has completado 7 días consecutivos de entrenamiento.",
                icon: "star.fill",
                color: .yellow,
                priority: 3
            ),
            WorkoutHeaderCard(
                type: .reminder,
                title: "Hidratación",
                content: "Bebe agua antes, durante y después del entrenamiento.",
                icon: "drop.fill",
                color: .cyan,
                priority: 4
            ),
            WorkoutHeaderCard(
                type: .tip,
                title: "Forma Correcta",
                content: "Enfócate en la técnica antes que en el peso. La forma es todo.",
                icon: "checkmark.circle.fill",
                color: .green,
                priority: 5
            )
        ]
        
        cards = defaultCards.sorted { $0.priority < $1.priority }
    }
    
    func startAutoScroll() {
        guard cards.count > 1 else { return }
        
        stopAutoScroll()
        
        autoScrollTimer = Timer.scheduledTimer(withTimeInterval: 4.0, repeats: true) { _ in
            DispatchQueue.main.async {
                withAnimation(.easeInOut(duration: 0.5)) {
                    if self.selectedIndex < self.cards.count - 1 {
                        self.selectedIndex += 1
                    } else {
                        self.selectedIndex = 0
                    }
                }
            }
        }
    }
    
    func stopAutoScroll() {
        autoScrollTimer?.invalidate()
        autoScrollTimer = nil
    }
}

// MARK: - Workout Header with Page Indicator View
struct WorkoutHeaderWithPageIndicator: View {
    @StateObject private var viewModel = WorkoutHeaderWithPageIndicatorModel()
    
    var body: some View {
        VStack(spacing: 0) {
            // Cards TabView for auto-scroll
            TabView(selection: $viewModel.selectedIndex) {
                ForEach(Array(viewModel.cards.enumerated()), id: \.element.id) { index, card in
                    WorkoutHeaderCardItem(card: card)
                        .frame(width: UIScreen.main.bounds.width - 40)
                        .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .frame(height: 80)
            .padding(.bottom, 0)
            
            // Custom page indicators
            if viewModel.cards.count > 1 {
                HStack(spacing: 8) {
                    ForEach(0..<viewModel.cards.count, id: \.self) { index in
                        Circle()
                            .fill(index == viewModel.selectedIndex ? Color.appYellow : Color.gray.opacity(0.3))
                            .frame(width: 6, height: 6)
                            .scaleEffect(index == viewModel.selectedIndex ? 1.2 : 1.0)
                            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: viewModel.selectedIndex)
                            .onTapGesture {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                    viewModel.selectedIndex = index
                                }
                            }
                    }
                }
                .padding(.top, 15)
                .padding(.bottom, 5)
            }
        }
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 15, style: .continuous)
                .fill(WorkoutColors.cardBackground)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 15, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [WorkoutColors.cardBorder, WorkoutColors.cardBorder.opacity(0.2), .clear],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.2
                )
        )
        .shadow(color: Color.appYellow.opacity(0.15), radius: 8, x: 0, y: 4)
        .onAppear {
            viewModel.startAutoScroll()
        }
        .onDisappear {
            viewModel.stopAutoScroll()
        }
    }
}

// MARK: - Individual Workout Header Card Item
struct WorkoutHeaderCardItem: View {
    let card: WorkoutHeaderCard
    
    var body: some View {
        HStack(spacing: 12) {
            // Icon with background circle
            if let icon = card.icon {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(card.color)
                    .frame(width: 40, height: 40)
                    .background(card.color.opacity(0.15))
                    .clipShape(Circle())
            }
            
            // Content section
            VStack(alignment: .leading, spacing: 4) {
                Text(card.title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(WorkoutColors.textAccent)
                    .lineLimit(1)
                
                Text(card.content)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(WorkoutColors.textSecondary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
            }
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

#Preview {
    WorkoutHeaderWithPageIndicator()
        .padding()
        .background(Color.black)
        .preferredColorScheme(.dark)
}
