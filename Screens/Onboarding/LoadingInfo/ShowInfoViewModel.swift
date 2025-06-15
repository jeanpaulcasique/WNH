import Foundation
import SwiftUI


// MARK: - ProfileSection Model
struct ProfileSection {
    let id: Int
    let title: String
    let icon: String
    let color: Color
    let items: [(key: String, value: String)]
}

// MARK: - ShowInfoViewModel
class ShowInfoViewModel: ObservableObject {
    @Published var progress: Double = 0.0
    @Published var visibleSections: Int = 0
    @Published var isPulsing: Bool = true
    @Published var isCoachWorking: Bool = true
    @Published var showDashboardButton: Bool = false
    @Published var profileSections: [ProfileSection] = []
    @Published var isGeneratingPlan: Bool = true
    @Published var planGenerationProgress: Double = 0.0
    
    private let generationSteps = [
        "Analyzing your physical profile...",
        "Processing your fitness goals...",
        "Customizing workout intensity...",
        "Selecting optimal exercises...",
        "Creating nutrition plan...",
        "Finalizing your program..."
    ]
    @Published var currentGenerationStep: String = ""
    @Published var currentStepIndex: Int = 0
   
    func loadData() {
        // Load all user data
        let gender = UserDefaults.standard.string(forKey: "gender") ?? "Not Set"
        let height = getFormattedHeight()
        let weight = UserDefaults.standard.value(forKey: "selectedWeightKg") as? Double ?? 0.0
        let targetWeight = UserDefaults.standard.value(forKey: "selectedTarget") as? Double ?? 0.0
        let goal = UserDefaults.standard.string(forKey: "selectedLevelActivity") ?? "Not Set"
        let workoutLocation = UserDefaults.standard.string(forKey: "selectedWorkoutLocation") ?? "At the Gym"
        let workoutLevel = UserDefaults.standard.string(forKey: "selectedWorkoutLevel") ?? "Not Set"
        let activityLevel = UserDefaults.standard.string(forKey: "selectedLevelActivity") ?? "Not Set"
        let dietType = UserDefaults.standard.string(forKey: "selectedDietType") ?? "Not Set"
        let birthYear = UserDefaults.standard.string(forKey: "selectedBirthYear") ?? "Not Set"
        
        // Calculate age
        let currentYear = Calendar.current.component(.year, from: Date())
        let age = birthYear != "Not Set" ? "\(currentYear - (Int(birthYear) ?? currentYear)) years" : "Not Set"
        
        // Organize data into sections
        profileSections = [
            ProfileSection(
                id: 0,
                title: "Physical Profile",
                icon: "person.fill",
                color: .blue,
                items: [
                    ("Gender", gender),
                    ("Age", age),
                    ("Height", height),
                    ("Current Weight", String(format: "%.1f kg", weight))
                ]
            ),
            ProfileSection(
                id: 1,
                title: "Fitness Goals",
                icon: "target",
                color: .red,
                items: [
                    ("Primary Goal", goal),
                    ("Target Weight", String(format: "%.1f kg", targetWeight)),
                    ("Activity Level", activityLevel)
                ]
            ),
            ProfileSection(
                id: 2,
                title: "Workout Preferences",
                icon: "dumbbell.fill",
                color: .orange,
                items: [
                    ("Workout Location", workoutLocation),
                    ("Fitness Level", workoutLevel),
                    ("Equipment Access", "Full Gym Access")
                ]
            ),
            ProfileSection(
                id: 3,
                title: "Nutrition Plan",
                icon: "leaf.fill",
                color: .green,
                items: [
                    ("Diet Type", dietType),
                    ("Meal Prep", "Professional Guidance"),
                    ("Supplements", "Personalized Stack")
                ]
            )
        ]
    }
    
    private func getFormattedHeight() -> String {
        if let heightCm = UserDefaults.standard.value(forKey: "selectedHeightCm") as? Int {
            return "\(heightCm) cm"
        } else if let heightFt = UserDefaults.standard.value(forKey: "selectedHeightFt") as? Int,
                  let heightInch = UserDefaults.standard.value(forKey: "selectedHeightInch") as? Int {
            return "\(heightFt) ft \(heightInch) in"
        }
        return "Not Set"
    }

    func startProfileAnalysis() {
        isGeneratingPlan = true
        currentStepIndex = 0
        
        // Start generation steps
        for i in 0..<generationSteps.count {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 1.0) { [weak self] in
                guard let self = self else { return }
                withAnimation(.easeInOut(duration: 0.5)) {
                    self.currentGenerationStep = self.generationSteps[i]
                    self.currentStepIndex = i
                    self.planGenerationProgress = Double(i + 1) / Double(self.generationSteps.count)
                }
            }
        }
        
        // After generation, show sections progressively
        DispatchQueue.main.asyncAfter(deadline: .now() + Double(generationSteps.count) * 1.0 + 1.0) {
            withAnimation(.easeInOut(duration: 0.8)) {
                self.isGeneratingPlan = false
                self.isCoachWorking = false
            }
            
            self.startRevealingSections()
        }
    }
    
    private func startRevealingSections() {
        for i in 0..<profileSections.count {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.6) { [weak self] in
                guard let self = self else { return }
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    self.visibleSections += 1
                    self.progress = Double(self.visibleSections) / Double(self.profileSections.count)
                }
                
                // Haptic feedback for each section
                let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                impactFeedback.impactOccurred()
            }
        }
        
        // Show dashboard button after all sections
        DispatchQueue.main.asyncAfter(deadline: .now() + Double(profileSections.count) * 0.6 + 1.0) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                self.showDashboardButton = true
                self.isPulsing = false
            }
            
            // Strong haptic feedback for completion
            let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
            impactFeedback.impactOccurred()
        }
    }
}
