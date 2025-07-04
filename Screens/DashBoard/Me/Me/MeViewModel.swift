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
    
    // ✅ OPTIMIZACIÓN: Control de animaciones
    @Published var isViewVisible: Bool = false
    private var animationTimer: Timer?
    
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
        // ✅ OPTIMIZACIÓN: No iniciar animación automáticamente
    }
    
    // ✅ NUEVO: Métodos para controlar animaciones
    func startRingAnimation() {
        guard isViewVisible else { return }
        
        stopRingAnimation() // Limpiar timer anterior
        
        animationTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            DispatchQueue.main.async {
                self?.ringRotation += 1
                if self?.ringRotation ?? 0 >= 360 {
                    self?.ringRotation = 0
                }
            }
        }
    }
    
    func stopRingAnimation() {
        animationTimer?.invalidate()
        animationTimer = nil
    }
    
    func viewDidAppear() {
        isViewVisible = true
        startRingAnimation()
    }
    
    func viewDidDisappear() {
        isViewVisible = false
        stopRingAnimation()
    }
    
    deinit {
        stopRingAnimation()
    }
}
