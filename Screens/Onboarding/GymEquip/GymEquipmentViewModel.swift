import SwiftUI


struct HomeEquipmentOption {
    let id: Int
    let title: String
    let subtitle: String
    let description: String
    let icon: String
    let color: Color
    let advantages: [String]
    let workoutTypes: [String]
    let equipment: String
    let difficulty: String
}

// MARK: - GymEquipmentViewModel
class GymEquipmentViewModel: ObservableObject {
    /// Opciones de equipamiento disponibles para casa
    enum EquipmentOption: Int, CaseIterable {
        case bodyweightOnly = 0
        case homeGymSetup    = 1
    }

    @Published var selectedOption: EquipmentOption? = nil {
        didSet {
            if let option = selectedOption {
                UserDefaults.standard.set(option.rawValue, forKey: "selectedEquipmentOption")
                selectedIndex = option.rawValue
                
                // Guardar información descriptiva para el dashboard
                let selectedEquipment = homeEquipmentOptions[option.rawValue]
                UserDefaults.standard.set(selectedEquipment.title, forKey: "selectedEquipmentType")
                print("🏋️‍♀️ Equipamiento guardado: \(selectedEquipment.title)")
            } else {
                UserDefaults.standard.removeObject(forKey: "selectedEquipmentOption")
                selectedIndex = nil
            }
        }
    }

    @Published var selectedIndex: Int? = nil
    @Published var isLoading: Bool = false
    @Published var isNextButtonDisabled: Bool = false
    
    let homeEquipmentOptions = [
        HomeEquipmentOption(
            id: 0,
            title: "Bodyweight Only",
            subtitle: "No Equipment Needed",
            description: "Effective workouts using only your body weight - perfect for beginners and small spaces",
            icon: "figure.strengthtraining.traditional",
            color: .blue,
            advantages: ["No equipment needed", "Anywhere, anytime", "Perfect for beginners", "Zero investment"],
            workoutTypes: ["Push-ups", "Squats", "Planks", "Burpees", "Lunges"],
            equipment: "Your body only",
            difficulty: "Beginner to Intermediate"
        ),
        HomeEquipmentOption(
            id: 1,
            title: "Home Gym Setup",
            subtitle: "Basic Equipment Available",
            description: "Enhanced workouts with basic home equipment for better results and variety",
            icon: "dumbbell.fill",
            color: .orange,
            advantages: ["More exercise variety", "Progressive overload", "Better muscle targeting", "Faster results"],
            workoutTypes: ["Weight training", "Resistance bands", "Kettlebell swings", "Dumbbell exercises"],
            equipment: "Dumbbells, bands, mat",
            difficulty: "Intermediate to Advanced"
        )
    ]
    
    var selectedEquipment: HomeEquipmentOption? {
        guard let index = selectedIndex else { return nil }
        return homeEquipmentOptions[index]
    }

    init() {
        if let raw = UserDefaults.standard.value(forKey: "selectedEquipmentOption") as? Int,
           let option = EquipmentOption(rawValue: raw) {
            self.selectedOption = option
            self.selectedIndex = raw
        }
    }

    func selectOption(_ index: Int) {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            if let option = EquipmentOption(rawValue: index) {
                self.selectedOption = option
            }
        }
        
        // Enhanced haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
    }
    
    func disableNextButtonTemporarily() {
        isNextButtonDisabled = true
        isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.isNextButtonDisabled = false
            self.isLoading = false
        }
    }
}
