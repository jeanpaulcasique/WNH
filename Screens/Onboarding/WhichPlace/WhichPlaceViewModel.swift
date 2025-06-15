import SwiftUI

// MARK: - WorkoutLocation Model
struct WorkoutLocation {
    let id: Int
    let title: String
    let subtitle: String
    let description: String
    let icon: String
    let color: Color
    let advantages: [String]
    let equipment: String
    let convenience: String
}

// MARK: - NewScreenViewModel
class NewScreenViewModel: ObservableObject {
    @Published var selectedIndex: Int? {
        didSet {
            // Guardar tanto el índice como el título de la ubicación para el dashboard
            UserDefaults.standard.set(selectedIndex, forKey: "workoutLocationSelection")
            if let index = selectedIndex {
                let selectedLocationTitle = workoutLocations[index].title
                UserDefaults.standard.set(selectedLocationTitle, forKey: "selectedWorkoutLocation")
                print("🏋️‍♂️ Ubicación guardada: \(selectedLocationTitle)")
            }
        }
    }
    @Published var isLoading: Bool = false
    @Published var isNextButtonDisabled: Bool = false
    
    /*
     Para usar en el Dashboard:
     - UserDefaults.standard.string(forKey: "selectedWorkoutLocation")
       Retorna: "At Home", "At the Gym", o "Al aire libre"
     - UserDefaults.standard.integer(forKey: "workoutLocationIndex")
       Retorna: 0 (Home), 1 (Gym), 2 (Outdoor)
     */
    
    let workoutLocations = [
        WorkoutLocation(
            id: 0,
            title: "At Home",
            subtitle: "Comfort & Convenience",
            description: "Train in your own space with flexibility and privacy",
            icon: "house.fill",
            color: .blue,
            advantages: ["Complete privacy", "No travel time", "Flexible schedule", "Weather independent"],
            equipment: "Bodyweight & basic tools",
            convenience: "Maximum"
        ),
        WorkoutLocation(
            id: 1,
            title: "At the Gym",
            subtitle: "Professional Environment",
            description: "Access to premium equipment and motivating atmosphere",
            icon: "dumbbell.fill",
            color: .red,
            advantages: ["Professional equipment", "Social motivation", "Expert guidance", "Variety of tools"],
            equipment: "Full gym access",
            convenience: "Medium"
        ),
        WorkoutLocation(
            id: 2,
            title: "Outdoors",
            subtitle: "Fresh Air & Nature",
            description: "Enjoy outdoor workouts with natural scenery and fresh air",
            icon: "leaf.fill",
            color: .green,
            advantages: ["Fresh air & vitamin D", "Natural scenery", "Free open space", "Connect with nature"],
            equipment: "Bodyweight & portable gear",
            convenience: "High"
        )
    ]
    
    var selectedLocation: WorkoutLocation? {
        guard let index = selectedIndex else { return nil }
        return workoutLocations[index]
    }
    
    init() {
        if let savedSelection = UserDefaults.standard.value(forKey: "workoutLocationSelection") as? Int {
            self.selectedIndex = savedSelection
        }
    }
    
    func selectLocation(at index: Int) {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            selectedIndex = index
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
