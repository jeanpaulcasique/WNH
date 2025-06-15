import SwiftUI
import Combine

// MARK: - ActivityLevel Model
struct ActivityLevel {
    let id: Int
    let title: String
    let subtitle: String
    let description: String
    let icon: String
    let color: Color
    let calorieMultiplier: String
}

// MARK: - LevelActivityViewModel
class LevelActivityViewModel: ObservableObject {
    @Published var selectedLevel: Int = 0 {
        didSet {
            saveSelectedLevel()
        }
    }
    @Published var isLoading: Bool = false
    @Published var isNextButtonDisabled: Bool = false
    
    let activityLevels = [
        ActivityLevel(
            id: 0,
            title: "Sedentary",
            subtitle: "Desk Job Lifestyle",
            description: "Little to no exercise, mostly sitting throughout the day",
            icon: "laptopcomputer",
            color: .blue,
            calorieMultiplier: "1.2x"
        ),
        ActivityLevel(
            id: 1,
            title: "Lightly Active",
            subtitle: "Some Movement",
            description: "Light exercise 1-3 days per week, some walking",
            icon: "figure.walk",
            color: .green,
            calorieMultiplier: "1.375x"
        ),
        ActivityLevel(
            id: 2,
            title: "Moderately Active",
            subtitle: "Regular Exercise",
            description: "Moderate exercise 3-5 days per week, active lifestyle",
            icon: "figure.run",
            color: .orange,
            calorieMultiplier: "1.55x"
        ),
        ActivityLevel(
            id: 3,
            title: "Very Active",
            subtitle: "High Intensity",
            description: "Hard exercise 6-7 days per week, very physical job",
            icon: "figure.strengthtraining.traditional",
            color: .red,
            calorieMultiplier: "1.725x"
        )
    ]
    
    var currentActivityLevel: ActivityLevel {
        return activityLevels[selectedLevel]
    }
    
    init() {
        if let savedLevel = UserDefaults.standard.value(forKey: "selectedActivityLevel") as? Int {
            self.selectedLevel = savedLevel
        }
    }
    
    private func saveSelectedLevel() {
        UserDefaults.standard.set(selectedLevel, forKey: "selectedActivityLevel")
        UserDefaults.standard.set(currentActivityLevel.title, forKey: "selectedLevelActivity")
        UserDefaults.standard.set(currentActivityLevel.description, forKey: "selectedLevelActivityDescription")
    }
    
    func selectLevel(_ level: Int) {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            selectedLevel = level
        }
        
        // Haptic feedback
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
