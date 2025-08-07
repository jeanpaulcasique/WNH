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
    
    // Peso objetivo calculado (consistente con showInfo.swift)
    var targetWeightKg: Double {
        let bmi = user.bmi ?? 25.0
        let goal = user.goal.lowercased()
        let heightCm = user.resolvedHeightCm
        
        if goal.contains("perder") || goal.contains("lose") {
            // Calcular peso objetivo basado en BMI saludable
            let targetBMI: Double
            if bmi > 30 {
                targetBMI = 25.0 // Obesidad → Normal
            } else if bmi > 25 {
                // Para sobrepeso, usar un BMI más realista (23-24 en lugar de 22)
                targetBMI = 23.5 // Sobrepeso → Normal medio
            } else {
                targetBMI = 21.0 // Normal → Delgado
            }
            
            let targetWeight = targetBMI * heightM * heightM
            return max(targetWeight, currentWeightKg * 0.85) // No más del 15% de pérdida inicial
            
        } else if goal.contains("ganar") || goal.contains("gain") {
            // Ganancia de peso para músculo
            let muscleGain = min(currentWeightKg * 0.15, 10.0) // Máximo 15% o 10kg
            return currentWeightKg + muscleGain
            
        } else {
            // Mantener peso - usar fórmula más realista para hombres
            let isMale = user.gender.lowercased().contains("male")
            
            if isMale {
                // Para hombres: usar fórmula de Broca mejorada o BMI 23-24
                let brocaWeight = Double(heightCm - 100)
                let bmiWeight = 23.5 * heightM * heightM // BMI 23.5 como punto medio
                
                // Usar el promedio de ambas fórmulas para mayor precisión
                return (brocaWeight + bmiWeight) / 2
            } else {
                // Para mujeres: optimizar a BMI 22
                let optimalBMI = 22.0
                let optimalWeight = optimalBMI * heightM * heightM
                return optimalWeight
            }
        }
    }
    
    var weightToLoseKg: Double? {
        let difference = currentWeightKg - targetWeightKg
        let value = difference > 0 ? difference : nil
        UserProfile.kilosToLose = value
        return value
    }
    
    var weightToGainKg: Double? {
        let difference = targetWeightKg - currentWeightKg
        let value = difference > 0 ? difference : nil
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
            return "Your BMI is high. To reach your target weight of \(String(format: "%.1f", targetWeightKg)) kg, you need to lose \(String(format: "%.1f", toLose)) kg (\(String(format: "%.1f", toLose * 2.20462)) lb)."
        } else if let toGain = weightToGainKg {
            return "Your BMI is low. To reach your target weight of \(String(format: "%.1f", targetWeightKg)) kg, you need to gain \(String(format: "%.1f", toGain)) kg (\(String(format: "%.1f", toGain * 2.20462)) lb)."
        } else {
            return "Congratulations! You're at your target weight of \(String(format: "%.1f", targetWeightKg)) kg."
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

