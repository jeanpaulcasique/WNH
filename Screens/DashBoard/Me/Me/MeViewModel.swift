import SwiftUI


// MARK: - Enhanced ViewModel
final class MeViewModel: ObservableObject {
    struct MeMenuItem: Identifiable {
        let id = UUID()
        let title: String
        let icon: String
        let color: Color
    }
    
    // User stats
    @Published var workoutCount: Int = 47
    @Published var streakDays: Int = 12
    @Published var userLevel: Int = 8
    @Published var isPremium: Bool = false
    @Published var ringRotation: Double = 0
    
    let accountSection: [MeMenuItem] = [
        MeMenuItem(title: "Subscription", icon: "crown.fill", color: .appYellow),
        MeMenuItem(title: "Coaches", icon: "person.2.fill", color: .blue),
        MeMenuItem(title: "Analytics", icon: "chart.bar.fill", color: .green)
    ]

    let supportSection: [MeMenuItem] = [
        MeMenuItem(title: "Write to support", icon: "headphones", color: .orange),
        MeMenuItem(title: "Tell a friend", icon: "square.and.arrow.up", color: .purple),
        MeMenuItem(title: "Rate the app", icon: "star.fill", color: .yellow),
        MeMenuItem(title: "Settings", icon: "gearshape.fill", color: .gray)
    ]
    
    init() {
        startRingAnimation()
    }
    
    private func startRingAnimation() {
        withAnimation(.linear(duration: 3.0).repeatForever(autoreverses: false)) {
            ringRotation = 360
        }
    }
}
