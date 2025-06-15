import Foundation

struct UserProfile {
    enum Gender: String {
        case male, female, other, notSet
    }
    
    enum ActivityLevel: String {
        case sedentary, lightlyActive, active, veryActive, notSet
    }
    
    enum WorkoutLocation: String {
        case atHome = "At Home"
        case atTheGym = "At the Gym"
        case outdoors = "Al aire libre"
        case notSet = "Not Set"
    }
    
    enum EquipmentType: String {
        case bodyweightOnly = "Bodyweight Only"
        case homeGymSetup = "Home Gym Setup"
        case fullGymAccess = "Full Gym Access"
        case notSet = "Not Set"
    }

    // Basic Profile Data
    let gender: String
    let heightCm: Int?
    let heightFt: Int?
    let heightInch: Int?
    let weightKg: Double
    let targetWeightKg: Double
    let birthYear: String
    
    // Goals & Preferences
    let goal: String
    let target: String
    let dietType: String
    
    // Activity & Fitness Level
    let levelActivity: String
    let workoutLevel: String
    
    // Workout Preferences - NUEVOS VALORES AÑADIDOS
    let workoutLocation: String
    let selectedEquipmentType: String
    
    // Body Image References
    let bodyCurrentImage: String
    let desiredBodyImage: String
    
    // Legacy/Additional Equipment Reference
    let equipmentPreference: String

    // Computed enums for safer handling
    var genderEnum: Gender {
        Gender(rawValue: gender.lowercased()) ?? .notSet
    }
    
    var activityLevelEnum: ActivityLevel {
        switch levelActivity.lowercased() {
        case "sedentary": return .sedentary
        case "lightly active": return .lightlyActive
        case "active": return .active
        case "very active": return .veryActive
        default: return .notSet
        }
    }
    
    var workoutLocationEnum: WorkoutLocation {
        WorkoutLocation(rawValue: workoutLocation) ?? .notSet
    }
    
    var equipmentTypeEnum: EquipmentType {
        EquipmentType(rawValue: selectedEquipmentType) ?? .notSet
    }

    init() {
        let defaults = UserDefaults.standard
        
        // Basic Profile
        gender = defaults.string(forKey: "gender") ?? "Not Set"
        heightCm = defaults.value(forKey: "selectedHeightCm") as? Int
        heightFt = defaults.value(forKey: "selectedHeightFt") as? Int
        heightInch = defaults.value(forKey: "selectedHeightInch") as? Int
        weightKg = defaults.object(forKey: "selectedWeightKg") as? Double ?? 70.0
        targetWeightKg = defaults.object(forKey: "selectedTargetWeight") as? Double ?? 65.0
        birthYear = defaults.string(forKey: "selectedBirthYear") ?? "Not Set"
        
        // Goals & Preferences
        goal = defaults.string(forKey: "selectedGoal") ?? "Not Set"
        target = defaults.string(forKey: "selectedTarget") ?? "Not Set"
        dietType = defaults.string(forKey: "selectedDietType") ?? "Not Set"
        
        // Activity & Fitness Level
        levelActivity = defaults.string(forKey: "selectedLevelActivity") ?? "Not Set"
        workoutLevel = defaults.string(forKey: "selectedWorkoutLevel") ?? "Not Set"
        
        // Workout Preferences - VALORES AÑADIDOS
        workoutLocation = defaults.string(forKey: "selectedWorkoutLocation") ?? "Not Set"
        selectedEquipmentType = defaults.string(forKey: "selectedEquipmentType") ?? "Not Set"
        
        // Body Image References
        bodyCurrentImage = defaults.string(forKey: "bodyCurrentImage") ?? "Not Set"
        desiredBodyImage = defaults.string(forKey: "desiredBodyImage") ?? "Not Set"
        
        // Legacy/Additional Equipment Reference
        equipmentPreference = defaults.string(forKey: "equipmentPreference") ?? "Not Set"
    }

    var totalHeightInCm: Int? {
        if let cm = heightCm, cm > 0 {
            return cm
        } else if let ft = heightFt, let inch = heightInch {
            return Int(Double(ft) * 30.48 + Double(inch) * 2.54)
        }
        return nil
    }

    var resolvedHeightCm: Int {
        totalHeightInCm ?? 170
    }
    
    // Computed properties for additional data access
    var workoutLocationIndex: Int {
        UserDefaults.standard.integer(forKey: "workoutLocationIndex")
    }
    
    var selectedEquipmentIndex: Int {
        UserDefaults.standard.integer(forKey: "selectedEquipmentIndex")
    }
    
    var age: Int? {
        guard let year = Int(birthYear), year > 1900 else { return nil }
        return Calendar.current.component(.year, from: Date()) - year
    }
    
    var isGymMember: Bool {
        return workoutLocationEnum == .atTheGym
    }
    
    var hasHomeEquipment: Bool {
        return equipmentTypeEnum == .homeGymSetup
    }
    
    var workoutEnvironment: String {
        switch workoutLocationEnum {
        case .atHome:
            return hasHomeEquipment ? "Home Gym" : "Home Bodyweight"
        case .atTheGym:
            return "Professional Gym"
        case .outdoors:
            return "Outdoor Training"
        case .notSet:
            return "Not Specified"
        }
    }

    func adjustmentFactor() -> Double {
        var factor = 1.0

        // Gender adjustment
        switch genderEnum {
        case .male:
            factor *= 1.1
        case .female, .other, .notSet:
            factor *= 1.0
        }

        // Age adjustment
        if let currentAge = age {
            switch currentAge {
            case 18..<30:
                factor *= 1.05
            case 30..<45:
                factor *= 1.0
            case 45..<60:
                factor *= 0.95
            case 60...:
                factor *= 0.9
            default:
                break
            }
        }

        // Weight adjustment (avoiding division by zero)
        if weightKg > 0 {
            factor *= weightKg / 70.0
        } else {
            factor *= 1.0
        }

        // Height adjustment
        factor *= Double(resolvedHeightCm) / 170.0

        // Activity level adjustment
        switch activityLevelEnum {
        case .sedentary:
            factor *= 0.9
        case .lightlyActive:
            factor *= 1.0
        case .active:
            factor *= 1.1
        case .veryActive:
            factor *= 1.2
        case .notSet:
            factor *= 1.0
        }

        return factor
    }
    
    // MARK: - Utility Methods
    
    /// Returns a formatted string for workout preferences
    var workoutPreferencesSummary: String {
        return "\(workoutLocation) • \(selectedEquipmentType) • \(workoutLevel)"
    }
    
    /// Returns BMI if height and weight are available
    var bmi: Double? {
        guard weightKg > 0, let heightCm = totalHeightInCm, heightCm > 0 else { return nil }
        let heightInMeters = Double(heightCm) / 100.0
        return weightKg / (heightInMeters * heightInMeters)
    }
    
    /// Returns BMI category
    var bmiCategory: String {
        guard let bmi = bmi else { return "Unknown" }
        
        switch bmi {
        case ..<18.5:
            return "Underweight"
        case 18.5..<25:
            return "Normal weight"
        case 25..<30:
            return "Overweight"
        default:
            return "Obese"
        }
    }

    static func loadFromUserDefaults() -> UserProfile {
        UserProfile()
    }
    
    // MARK: - Debug Helper
    func printAllValues() {
        print("=== USER PROFILE ===")
        print("Gender: \(gender)")
        print("Height: \(heightCm ?? 0) cm")
        print("Weight: \(weightKg) kg")
        print("Target Weight: \(targetWeightKg) kg")
        print("Goal: \(goal)")
        print("Activity Level: \(levelActivity)")
        print("Workout Level: \(workoutLevel)")
        print("Workout Location: \(workoutLocation)")
        print("Equipment Type: \(selectedEquipmentType)")
        print("Diet Type: \(dietType)")
        print("Birth Year: \(birthYear)")
        print("Age: \(age ?? 0)")
        print("BMI: \(bmi ?? 0.0)")
        print("Workout Environment: \(workoutEnvironment)")
        print("==================")
    }
}
