import SwiftUI
import Combine

// MARK: - WorkoutLevel Model
struct WorkoutLevel {
    let id: Int
    let title: String
    let subtitle: String
    let description: String
    let duration: String
    let frequency: String
    let icon: String
    let color: Color
    let intensity: String
    let benefits: [String]
}

// MARK: - WorkoutLevelViewModel
class WorkoutLevelViewModel: ObservableObject {
    @Published var selectedIndex: Int? {
        didSet {
            UserDefaults.standard.set(selectedIndex, forKey: "workoutLevelSelection")
        }
    }
    @Published var isNextButtonDisabled: Bool = false
    @Published var isLoading: Bool = false
    
    let workoutLevels = [
        WorkoutLevel(
            id: 0,
            title: "Beginner",
            subtitle: "Easy to start",
            description: "Perfect for getting into fitness habits without overwhelming yourself",
            duration: "15-25 min",
            frequency: "3-4 days/week",
            icon: "figure.walk",
            color: .green,
            intensity: "Low Impact",
            benefits: ["Build foundation", "Create healthy habits", "Low injury risk"]
        ),
        WorkoutLevel(
            id: 1,
            title: "Intermediate",
            subtitle: "Break a light sweat",
            description: "Balanced workouts that challenge you while staying manageable",
            duration: "25-35 min",
            frequency: "4-5 days/week",
            icon: "figure.run",
            color: .orange,
            intensity: "Moderate",
            benefits: ["Improve strength", "Boost endurance", "Visible progress"]
        ),
        WorkoutLevel(
            id: 2,
            title: "Advanced",
            subtitle: "A bit challenging",
            description: "High-intensity sessions for experienced fitness enthusiasts",
            duration: "35-50 min",
            frequency: "5-6 days/week",
            icon: "figure.strengthtraining.traditional",
            color: .red,
            intensity: "High Impact",
            benefits: ["Maximum results", "Peak performance", "Elite conditioning"]
        )
    ]
    
    var selectedLevel: WorkoutLevel? {
        guard let index = selectedIndex else { return nil }
        return workoutLevels[index]
    }
    
    init() {
        if let savedSelection = UserDefaults.standard.value(forKey: "workoutLevelSelection") as? Int {
            self.selectedIndex = savedSelection
        } else {
            self.selectedIndex = 0
        }
    }
    
    func selectLevel(at index: Int) {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            selectedIndex = index
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
