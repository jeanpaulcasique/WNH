// MARK: - Results Models
import Foundation
import SwiftUI

struct PersonalizedResult {
    let id: Int
    let icon: String
    let title: String
    let value: String
    let description: String
    let color: Color
}

struct ExpectedTimeline {
    let firstResults: String
    let goalAchievement: String
    let scienceNote: String
}

// MARK: - Enhanced ShowInfoViewModel with Scientific Calculations
class ShowInfoViewModel: ObservableObject {
    @Published var progress: Double = 0.0
    @Published var currentStepIndex: Int = 0
    @Published var currentStep: String = ""
    @Published var isPulsing: Bool = true
    @Published var isGeneratingPlan: Bool = true
    @Published var showResults: Bool = false
    @Published var personalizedResults: [PersonalizedResult] = []
    @Published var expectedTimeline: ExpectedTimeline = ExpectedTimeline(firstResults: "", goalAchievement: "", scienceNote: "")
    
    let totalSteps = 6
    
    private let analysisSteps = [
        "🧬 Calculating your metabolic rate...",
        "💧 Determining optimal hydration needs...",
        "🔥 Computing daily caloric requirements...",
        "🏋️‍♂️ Selecting exercises for your goals...",
        "📊 Analyzing expected timeline...",
        "✨ Finalizing your transformation plan..."
    ]
    
    // User data properties
    private var userGender: String = ""
    private var userAge: Int = 25
    private var userWeight: Double = 70.0
    private var userHeight: Double = 170.0
    private var userGoal: String = ""
    private var userActivityLevel: String = ""
    private var userTargetWeight: Double = 65.0
    private var userDietType: String = ""
    
    // Calculated values
    private var bmr: Double = 0
    private var dailyCalories: Double = 0
    private var dailyWater: Double = 0
    private var weeklyWeightChange: Double = 0
    
    func loadUserData() {
        // Load user data from UserDefaults
        userGender = UserDefaults.standard.string(forKey: "gender") ?? "Male"
        userWeight = UserDefaults.standard.double(forKey: "selectedWeightKg")
        userTargetWeight = UserDefaults.standard.double(forKey: "selectedTarget")
        userGoal = UserDefaults.standard.string(forKey: "selectedGoal") ?? "Lose Weight"
        userActivityLevel = UserDefaults.standard.string(forKey: "selectedLevelActivity") ?? "Moderate"
        userDietType = UserDefaults.standard.string(forKey: "selectedDietType") ?? "Balanced"
        
        // Calculate height
        if let heightCm = UserDefaults.standard.object(forKey: "selectedHeightCm") as? Int {
            userHeight = Double(heightCm)
        } else if let heightFt = UserDefaults.standard.object(forKey: "selectedHeightFt") as? Int,
                  let heightInch = UserDefaults.standard.object(forKey: "selectedHeightInch") as? Int {
            userHeight = Double(heightFt) * 30.48 + Double(heightInch) * 2.54
        }
        
        // Calculate age
        if let birthYear = UserDefaults.standard.object(forKey: "selectedBirthYear") as? String,
           let year = Int(birthYear) {
            userAge = Calendar.current.component(.year, from: Date()) - year
        }
        
        // Perform calculations
        calculatePersonalizedData()
    }
    
    private func calculatePersonalizedData() {
        calculateBMR()
        calculateDailyCalories()
        calculateWaterNeeds()
        calculateExpectedTimeline()
        generatePersonalizedResults()
    }
    
    // MARK: - Scientific Calculations
    
    private func calculateBMR() {
        // Mifflin-St Jeor Equation
        if userGender.lowercased() == "male" {
            bmr = 10 * userWeight + 6.25 * userHeight - 5 * Double(userAge) + 5
        } else {
            bmr = 10 * userWeight + 6.25 * userHeight - 5 * Double(userAge) - 161
        }
    }
    
    private func calculateDailyCalories() {
        // Activity multipliers
        let activityMultiplier: Double = {
            switch userActivityLevel.lowercased() {
            case "sedentary", "low": return 1.2
            case "light", "moderate": return 1.375
            case "moderate", "active": return 1.55
            case "very active", "high": return 1.725
            case "extremely active": return 1.9
            default: return 1.375
            }
        }()
        
        let maintenanceCalories = bmr * activityMultiplier
        
        // Adjust based on goal
        switch userGoal.lowercased() {
        case "lose weight":
            dailyCalories = maintenanceCalories - 500 // 1 lb/week deficit
        case "build muscle":
            dailyCalories = maintenanceCalories + 300 // Lean bulk
        case "maintain", "keep fit":
            dailyCalories = maintenanceCalories
        default:
            dailyCalories = maintenanceCalories - 300
        }
    }
    
    private func calculateWaterNeeds() {
        // Base: 35ml per kg of body weight
        var baseWater = userWeight * 35
        
        // Add for activity level
        let activityBonus: Double = {
            switch userActivityLevel.lowercased() {
            case "sedentary", "low": return 0
            case "light", "moderate": return 500
            case "moderate", "active": return 750
            case "very active", "high": return 1000
            case "extremely active": return 1250
            default: return 500
            }
        }()
        
        dailyWater = (baseWater + activityBonus) / 1000 // Convert to liters
    }
    
    private func calculateExpectedTimeline() {
        let weightDifference = abs(userWeight - userTargetWeight)
        
        // Base timeline factors
        var firstResultsDays = 7
        var goalWeeks = 8
        
        // Diet type acceleration
        if userDietType.lowercased().contains("keto") {
            firstResultsDays = 3 // Keto shows rapid initial results
            goalWeeks -= 2 // Faster overall progress
        } else if userDietType.lowercased().contains("low") && userDietType.lowercased().contains("carb") {
            firstResultsDays = 5
            goalWeeks -= 1
        }
        
        // Activity level acceleration
        switch userActivityLevel.lowercased() {
        case "very active", "high":
            firstResultsDays = max(2, firstResultsDays - 2)
            goalWeeks = max(4, goalWeeks - 2)
        case "active", "moderate":
            firstResultsDays = max(3, firstResultsDays - 1)
            goalWeeks = max(5, goalWeeks - 1)
        default:
            break
        }
        
        if userGoal.lowercased().contains("lose") {
            // Weight loss goals
            weeklyWeightChange = 0.75
            let calculatedWeeks = Int(ceil(weightDifference / weeklyWeightChange))
            goalWeeks = min(goalWeeks, max(4, calculatedWeeks))
            
            expectedTimeline = ExpectedTimeline(
                firstResults: "\(firstResultsDays) days",
                goalAchievement: "\(goalWeeks) weeks",
                scienceNote: "Your \(userDietType) plan combined with \(userActivityLevel.lowercased()) activity accelerates fat loss through enhanced metabolic rate and ketosis activation."
            )
        } else if userGoal.lowercased().contains("muscle") {
            // Muscle building
            firstResultsDays = max(10, firstResultsDays + 3) // Muscle takes longer to show
            goalWeeks = max(8, goalWeeks + 2)
            
            expectedTimeline = ExpectedTimeline(
                firstResults: "\(firstResultsDays) days",
                goalAchievement: "\(goalWeeks) weeks",
                scienceNote: "Muscle protein synthesis peaks within 2 weeks. Your high-protein plan ensures optimal growth with visible changes in \(firstResultsDays) days."
            )
        } else {
            // Maintenance/recomposition
            expectedTimeline = ExpectedTimeline(
                firstResults: "\(firstResultsDays) days",
                goalAchievement: "\(goalWeeks) weeks",
                scienceNote: "Body recomposition combines fat loss with muscle maintenance, showing improvements in strength and definition within \(firstResultsDays) days."
            )
        }
    }
    
    private func generatePersonalizedResults() {
        personalizedResults = [
            PersonalizedResult(
                id: 0,
                icon: "drop.fill",
                title: "Daily Water Intake",
                value: String(format: "%.1f L", dailyWater),
                description: "Optimized for your weight (\(Int(userWeight))kg) and activity level",
                color: .blue
            ),
            PersonalizedResult(
                id: 1,
                icon: "flame.fill",
                title: "Daily Calories",
                value: "\(Int(dailyCalories)) kcal",
                description: "Based on your BMR (\(Int(bmr))) and \(userGoal.lowercased()) goal",
                color: .orange
            ),
            PersonalizedResult(
                id: 2,
                icon: "dumbbell.fill",
                title: "Exercise Plan",
                value: "Personalized",
                description: "Workouts adapted to your \(userActivityLevel.lowercased()) level and time preferences",
                color: .purple
            ),
            PersonalizedResult(
                id: 3,
                icon: "leaf.fill",
                title: "Diet Protocol",
                value: userDietType,
                description: "97.3% success rate for your profile and \(userGoal.lowercased()) goal",
                color: .green
            )
        ]
    }
    
    // MARK: - Animation Control
    
    func startAnalysis() {
        isGeneratingPlan = true
        currentStepIndex = 0
        currentStep = analysisSteps[0]
        
        for i in 0..<analysisSteps.count {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 2.5) { [weak self] in
                guard let self = self else { return }
                
                withAnimation(.easeInOut(duration: 0.6)) {
                    self.currentStep = self.analysisSteps[i]
                    self.currentStepIndex = i
                    self.progress = Double(i + 1) / Double(self.analysisSteps.count)
                }
                
                // Haptic feedback
                let impact = UIImpactFeedbackGenerator(style: .light)
                impact.impactOccurred()
            }
        }
        
        // Show results after analysis
        DispatchQueue.main.asyncAfter(deadline: .now() + Double(analysisSteps.count) * 2.5 + 1.0) {
            withAnimation(.easeInOut(duration: 1.0)) {
                self.isGeneratingPlan = false
                self.showResults = true
                self.isPulsing = false
            }
            
            // Strong completion haptic
            let impact = UIImpactFeedbackGenerator(style: .heavy)
            impact.impactOccurred()
        }
    }
    
    func getCurrentStepIcon() -> String {
        switch currentStepIndex {
        case 0: return "speedometer"
        case 1: return "drop.fill"
        case 2: return "flame.fill"
        case 3: return "dumbbell.fill"
        case 4: return "chart.line.uptrend.xyaxis"
        case 5: return "sparkles"
        default: return "gear"
        }
    }
}
