import SwiftUI
import UIKit

// MARK: - WeightViewModel
class WeightViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var selectedWeightKg: Double {
        didSet {
            UserDefaults.standard.set(selectedWeightKg, forKey: "selectedWeightKg")
            updateHealthBenefitMessage()
        }
    }
    
    @Published var isKgSelected: Bool {
        didSet {
            UserDefaults.standard.set(isKgSelected, forKey: "isKgSelected")
        }
    }
    
    @Published var healthBenefitMessage: String = ""
    @Published var showWeightAnimation: Bool = false
    @Published var showBMIDisplay: Bool = false
    @Published var isNextButtonDisabled: Bool = false
    @Published var isNextButtonLoading: Bool = false
    @Published var scaleRotation: Double = 0
    @Published var scaleScale: Double = 1.0
    @Published var weightChanging: Bool = false
    
    // MARK: - Constants
    private let kgMinWeight: Double = 30
    private let kgMaxWeight: Double = 200
    private let lbMinWeight: Double = 66
    private let lbMaxWeight: Double = 440
    private let conversionFactor: Double = 2.20462
    
    // MARK: - Computed Properties
    var selectedWeightLb: Double {
        get { selectedWeightKg * conversionFactor }
        set { selectedWeightKg = newValue / conversionFactor }
    }
    
    var weightInPreferredUnit: Double {
        isKgSelected ? selectedWeightKg : selectedWeightLb
    }
    
    var formattedPrimaryWeight: String {
        String(format: "%.1f", weightInPreferredUnit)
    }
    
    var primaryWeightUnit: String {
        isKgSelected ? "kg" : "lb"
    }
    
    var formattedSecondaryWeight: String {
        if isKgSelected {
            let pounds = selectedWeightKg * conversionFactor
            return String(format: "%.1f", pounds)
        } else {
            let kg = selectedWeightLb / conversionFactor
            return String(format: "%.1f", kg)
        }
    }
    
    var secondaryWeightUnit: String {
        isKgSelected ? "lb" : "kg"
    }
    
    var weightRangeText: String {
        isKgSelected ? "30-200 kg" : "66-440 lb"
    }
    
    var primaryWeightUnitName: String {
        isKgSelected ? "Kilograms" : "Pounds"
    }
    
    var secondaryWeightUnitName: String {
        isKgSelected ? "Pounds" : "Kilograms"
    }

    // MARK: - Initialization
    init() {
        if let savedWeight = UserDefaults.standard.value(forKey: "selectedWeightKg") as? Double {
            self.selectedWeightKg = savedWeight
        } else {
            self.selectedWeightKg = 70.0
        }
        
        if let savedUnit = UserDefaults.standard.value(forKey: "isKgSelected") as? Bool {
            self.isKgSelected = savedUnit
        } else {
            self.isKgSelected = true
        }
        
        updateHealthBenefitMessage()
    }

    // MARK: - BMI Calculations
    func calculateBMI(heightInCm: Double) -> Double {
        let heightInM = heightInCm / 100
        return selectedWeightKg / (heightInM * heightInM)
    }
    
    func getBMICategory(bmi: Double) -> String {
        switch bmi {
        case ..<18.5: return "Underweight"
        case 18.5..<25: return "Normal"
        case 25..<30: return "Overweight"
        default: return "Obese"
        }
    }
    
    func getBMIColor(bmi: Double) -> Color {
        switch bmi {
        case ..<18.5: return .cyan
        case 18.5..<25: return .green
        case 25..<30: return .orange
        default: return .red
        }
    }
    
    func getFormattedBMI(heightInCm: Double) -> String {
        let bmi = calculateBMI(heightInCm: heightInCm)
        return String(format: "%.1f", bmi)
    }
    
    // MARK: - Weight Management
    func toggleUnit() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            if isKgSelected {
                let currentKg = selectedWeightKg
                isKgSelected = false
                selectedWeightLb = currentKg * conversionFactor
            } else {
                let currentLb = selectedWeightLb
                isKgSelected = true
                selectedWeightKg = currentLb / conversionFactor
            }
            validateWeightRange()
        }
    }

    func updateWeight(newWeight: Double) {
        let clampedWeight = clampWeight(newWeight)
        if isKgSelected {
            selectedWeightKg = clampedWeight
        } else {
            selectedWeightLb = clampedWeight
        }
    }
    
    private func clampWeight(_ weight: Double) -> Double {
        if isKgSelected {
            return max(kgMinWeight, min(kgMaxWeight, weight))
        } else {
            return max(lbMinWeight, min(lbMaxWeight, weight))
        }
    }
    
    private func validateWeightRange() {
        selectedWeightKg = max(kgMinWeight, min(kgMaxWeight, selectedWeightKg))
    }

    // MARK: - Slider Logic
    func getSliderProgress() -> Double {
        if isKgSelected {
            return (selectedWeightKg - kgMinWeight) / (kgMaxWeight - kgMinWeight)
        } else {
            return (selectedWeightLb - lbMinWeight) / (lbMaxWeight - lbMinWeight)
        }
    }
    
    func getThumbOffset() -> CGFloat {
        let progress = getSliderProgress()
        return CGFloat((progress - 0.5) * 280) // Approximate slider width
    }
    
    func updateWeightFromSlider(translation: CGFloat) {
        let sensitivity: Double = isKgSelected ? 0.5 : 1.0
        let change = Double(translation) * sensitivity * 0.01
        
        if isKgSelected {
            let newWeight = max(kgMinWeight, min(kgMaxWeight, selectedWeightKg + change))
            updateWeight(newWeight: newWeight)
        } else {
            let newWeight = max(lbMinWeight, min(lbMaxWeight, selectedWeightLb + change))
            updateWeight(newWeight: newWeight / conversionFactor)
        }
    }
    
    // MARK: - Animation Management
    func setupAnimations() {
        // Show weight display after a moment
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                self.showWeightAnimation = true
            }
        }
        
        // Show BMI display after weight
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                self.showBMIDisplay = true
            }
        }
    }
    
    func triggerScaleReaction() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            scaleRotation = Double.random(in: -2...2)
            scaleScale = 1.05
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                self.scaleRotation = 0
                self.scaleScale = 1.0
            }
        }
    }
    
    func setWeightChanging(_ isChanging: Bool) {
        weightChanging = isChanging
        if isChanging {
            triggerScaleReaction()
        }
    }
    
    // MARK: - Health Benefits
    func updateHealthBenefitMessage() {
        let weightLossPercentage = ((85.0 - selectedWeightKg) / 85.0) * 100
        healthBenefitMessage = """
        Great choice!
        You will lose \(String(format: "%.1f", weightLossPercentage))% of body weight
        You will gain continuous health benefits:
        - Lower blood lipids and blood pressure
        - Boost your metabolism
        """
    }
    
    // MARK: - Navigation Logic
    func proceedToNext(progressViewModel: ProgressViewModel, completion: @escaping () -> Void) {
        withAnimation(.easeInOut(duration: 0.5)) {
            progressViewModel.advanceProgress()
        }
        generateHapticFeedback()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            completion()
        }
    }
    
    func goBack(progressViewModel: ProgressViewModel, completion: @escaping () -> Void) {
        progressViewModel.decreaseProgress()
        completion()
    }
    
    // MARK: - Haptic Feedback
    func generateHapticFeedback(style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
    
    // MARK: - Validation
    func isValidWeight() -> Bool {
        if isKgSelected {
            return selectedWeightKg >= kgMinWeight && selectedWeightKg <= kgMaxWeight
        } else {
            return selectedWeightLb >= lbMinWeight && selectedWeightLb <= lbMaxWeight
        }
    }
    
    // MARK: - Unit Selection Logic
    func selectKgUnit() {
        if !isKgSelected {
            toggleUnit()
        }
        generateHapticFeedback()
    }
    
    func selectLbUnit() {
        if isKgSelected {
            toggleUnit()
        }
        generateHapticFeedback()
    }
    
    // MARK: - Weight Benefits Data
    func getWeightBenefits() -> [WeightBenefit] {
        return [
            WeightBenefit(
                icon: "chart.line.uptrend.xyaxis",
                title: "Progress Tracking",
                description: "Monitor your fitness journey with accurate measurements",
                color: .blue
            ),
            WeightBenefit(
                icon: "heart.circle.fill",
                title: "Health Insights",
                description: "BMI calculations and health risk assessments",
                color: .red
            ),
            WeightBenefit(
                icon: "target",
                title: "Goal Setting",
                description: "Set realistic weight targets based on your profile",
                color: .purple
            )
        ]
    }
    
    // MARK: - BMI Categories for Sheet
    func getBMICategories(userCategory: String) -> [BMICategory] {
        return [
            BMICategory(
                range: "< 18.5",
                category: "Underweight",
                color: .cyan,
                isUserCategory: userCategory == "Underweight"
            ),
            BMICategory(
                range: "18.5 - 24.9",
                category: "Normal",
                color: .green,
                isUserCategory: userCategory == "Normal"
            ),
            BMICategory(
                range: "25.0 - 29.9",
                category: "Overweight",
                color: .orange,
                isUserCategory: userCategory == "Overweight"
            ),
            BMICategory(
                range: "30.0+",
                category: "Obese",
                color: .red,
                isUserCategory: userCategory == "Obese"
            )
        ]
    }
    
    // MARK: - Calculation Data for BMI Sheet
    func getCalculationData(userHeight: Double) -> [CalculationData] {
        return [
            CalculationData(
                label: "Height",
                value: String(format: "%.1f cm", userHeight),
                icon: "ruler.fill"
            ),
            CalculationData(
                label: "Weight",
                value: String(format: "%.1f kg", selectedWeightKg),
                icon: "scalemass.fill"
            ),
            CalculationData(
                label: "BMI Formula",
                value: "Weight ÷ (Height²)",
                icon: "function"
            )
        ]
    }
}

// MARK: - Supporting Data Structures
struct WeightBenefit {
    let icon: String
    let title: String
    let description: String
    let color: Color
}

struct BMICategory {
    let range: String
    let category: String
    let color: Color
    let isUserCategory: Bool
}

struct CalculationData {
    let label: String
    let value: String
    let icon: String
}
