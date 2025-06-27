import SwiftUI

// MARK: - Benefit Model
struct Benefit: Hashable {
    let text: String
    let icon: String
}

// MARK: - WorkoutLocationModel
struct WorkoutLocationModel {
    let id: Int
    let title: String
    let subtitle: String
    let description: String
    let icon: String
    let color: Color
    let features: [Benefit]
    let equipment: String
    let convenience: String
}

// MARK: - WhichPlaceViewModel
class WhichPlaceViewModel: ObservableObject {
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
        WorkoutLocationModel(
            id: 0,
            title: "At Home",
            subtitle: "Comfort & Convenience",
            description: "Train in your own space with flexibility and privacy",
            icon: "house.fill",
            color: .blue,
            features: [
                Benefit(text: "Complete privacy", icon: "lock.shield.fill"),
                Benefit(text: "No travel time", icon: "clock.fill"),
                Benefit(text: "Flexible schedule", icon: "calendar.badge.clock"),
                Benefit(text: "Weather independent", icon: "cloud.sun.fill")
            ],
            equipment: "Bodyweight & basic tools",
            convenience: "Maximum"
        ),
        WorkoutLocationModel(
            id: 1,
            title: "At the Gym",
            subtitle: "Professional Environment",
            description: "Access to premium equipment and motivating atmosphere",
            icon: "dumbbell.fill",
            color: .red,
            features: [
                Benefit(text: "Professional equipment", icon: "flame.fill"),
                Benefit(text: "Social motivation", icon: "person.2.fill"),
                Benefit(text: "Expert guidance", icon: "person.fill.questionmark"),
                Benefit(text: "Variety of tools", icon: "wrench.and.screwdriver.fill")
            ],
            equipment: "Full gym access",
            convenience: "Medium"
        ),
        WorkoutLocationModel(
            id: 2,
            title: "Outdoors",
            subtitle: "Fresh Air & Nature",
            description: "Enjoy outdoor workouts with natural scenery and fresh air",
            icon: "leaf.fill",
            color: .green,
            features: [
                Benefit(text: "Fresh air & vitamin D", icon: "sun.max.fill"),
                Benefit(text: "Natural scenery", icon: "mountain.2.fill"),
                Benefit(text: "Free open space", icon: "arrow.up.left.and.down.right.and.arrow.up.right.and.down.left"),
                Benefit(text: "Connect with nature", icon: "tree.fill")
            ],
            equipment: "Bodyweight & portable gear",
            convenience: "High"
        )
    ]
    
    var selectedLocation: WorkoutLocationModel? {
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
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
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
