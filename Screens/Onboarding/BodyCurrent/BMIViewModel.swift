import SwiftUI
import Foundation

class BMIViewModel: ObservableObject {
    @Published var selectedBodyShape: BodyShape?
    private let user = UserProfile.loadFromUserDefaults()

    // BMI y categoría
    var bmi: Double {
        let value = user.bmi ?? 0.0
        UserProfile.currentBMI = value
        return value
    }
    var bmiCategory: String { user.bmiCategory }
    var bmiCategoryText: String {
        switch bmiCategory {
        case "Normal weight": return "Normal"
        case "Overweight": return "Overweight"
        case "Obese": return "Obese"
        case "Underweight": return "Underweight"
        default: return "Unknown"
        }
    }
    var bmiColor: Color {
        switch bmiCategory {
        case "Normal weight": return .green
        case "Overweight": return .yellow
        case "Obese": return .red
        case "Underweight": return .blue
        default: return .gray
        }
    }
    var bmiNeedleAngle: Double {
        let minBMI: Double = 10
        let maxBMI: Double = 40
        let clampedBMI = min(max(bmi, minBMI), maxBMI)
        return -135 + ((clampedBMI - minBMI) / (maxBMI - minBMI)) * 270
    }

    // Lógica de peso saludable
    var heightM: Double { Double(user.resolvedHeightCm) / 100.0 }
    var minHealthyWeightKg: Double { 18.5 * heightM * heightM }
    var maxHealthyWeightKg: Double { 24.9 * heightM * heightM }
    var currentWeightKg: Double { user.weightKg }
    var weightToLoseKg: Double? {
        let value = currentWeightKg > maxHealthyWeightKg ? currentWeightKg - maxHealthyWeightKg : nil
        UserProfile.kilosToLose = value
        return value
    }
    var weightToGainKg: Double? {
        let value = currentWeightKg < minHealthyWeightKg ? minHealthyWeightKg - currentWeightKg : nil
        UserProfile.kilosToLose = value
        return value
    }
    var isHealthy: Bool {
        currentWeightKg >= minHealthyWeightKg && currentWeightKg <= maxHealthyWeightKg
    }
    var healthyRangeText: String {
        "\(String(format: "%.1f", minHealthyWeightKg)) - \(String(format: "%.1f", maxHealthyWeightKg)) kg"
    }
    var motivationalMessage: String {
        if let toLose = weightToLoseKg {
            return "Your BMI is high. To reach a healthy range, you need to lose \(String(format: "%.1f", toLose)) kg (\(String(format: "%.1f", toLose * 2.20462)) lb)."
        } else if let toGain = weightToGainKg {
            return "Your BMI is low. To reach a healthy range, you need to gain \(String(format: "%.1f", toGain)) kg (\(String(format: "%.1f", toGain * 2.20462)) lb)."
        } else {
            return "Congratulations! Your weight is in the healthy BMI range."
        }
    }

    enum BodyShape: String, CaseIterable, Identifiable {
        case medium = "mediumMen"
        case flabby = "flabbyMen"
        case skinny = "skinnyMen"
        case muscular = "muscularMen"
        var id: String { self.rawValue }
    }

    // Elimina métodos de body shape y bodyCurrentImage
    init() {
    }
}

