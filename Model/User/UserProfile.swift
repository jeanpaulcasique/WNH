import Foundation

// MARK: - Global Enums
enum Gender: String, CaseIterable, Codable {
    case male = "male"
    case female = "female"
    case other = "other"
    case notSet = "notSet"
}

// MARK: - Unidad de peso
enum WeightUnit: String, Codable, CaseIterable {
    case kg, lb
}

struct UserProfile: Codable {
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

    enum SubscriptionPlan: String {
        case free = "Free"
        case monthly = "Monthly Pro"
        case threeMonths = "Three Months Pro"
        case yearly = "Yearly Pro"
    }

    // Basic Profile Data
    let gender: String
    let heightCm: Int?
    let heightFt: Int?
    let heightInch: Int?
    let weightKg: Double
    let unitPreference: WeightUnit
    let targetWeightKg: Double
    let birthYear: String
    
    // Goals & Preferences
    let goal: String
    let target: String
    let dietType: String
    
    // Activity & Fitness Level
    let levelActivity: String
    let workoutLevel: String
    
    // Workout Preferences
    let workoutLocation: String
    let selectedEquipmentType: String
    
    // Body Image References
    let desiredBodyImage: String
    
    // Legacy/Additional Equipment Reference
    let equipmentPreference: String
    
    // Subscription Data
    let subscriptionPlan: String
    let subscriptionExpirationDate: Date?
    let isSubscriptionActive: Bool

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

    // Conversión de unidades
    var weightInPreferredUnit: Double {
        switch unitPreference {
        case .kg:
            return weightKg
        case .lb:
            return weightKg / 0.453592
        }
    }
    
    static func kgToLbs(_ kg: Double) -> Double {
        return kg / 0.453592
    }
    static func lbsToKg(_ lbs: Double) -> Double {
        return lbs * 0.453592
    }

    init() {
        let defaults = UserDefaults.standard
        
        // Basic Profile
        gender = defaults.string(forKey: "gender") ?? "Not Set"
        heightCm = defaults.value(forKey: "selectedHeightCm") as? Int
        heightFt = defaults.value(forKey: "selectedHeightFt") as? Int
        heightInch = defaults.value(forKey: "selectedHeightInch") as? Int
        // ✅ CORREGIDO: Leer como Double nativo para evitar fallos de casteo (NSNumber)
        let storedWeight = defaults.double(forKey: "selectedWeightKg")
        weightKg = storedWeight > 0 ? storedWeight : 70.0
        unitPreference = WeightUnit(rawValue: defaults.string(forKey: "weightUnitPreference") ?? "kg") ?? .kg
        let storedTarget = defaults.double(forKey: "selectedTargetWeight")
        targetWeightKg = storedTarget > 0 ? storedTarget : 65.0
        birthYear = defaults.string(forKey: "selectedBirthYear") ?? "Not Set"
        
        // Goals & Preferences
        goal = defaults.string(forKey: "selectedGoal") ?? "Not Set"
        target = defaults.string(forKey: "selectedTarget") ?? "Not Set"
        dietType = defaults.string(forKey: "selectedDietType") ?? "Not Set"
        
        // Activity & Fitness Level
        levelActivity = defaults.string(forKey: "selectedLevelActivity") ?? "Not Set"
        workoutLevel = defaults.string(forKey: "selectedWorkoutLevel") ?? "Not Set"
        
        // Workout Preferences
        workoutLocation = defaults.string(forKey: "selectedWorkoutLocation") ?? "Not Set"
        selectedEquipmentType = defaults.string(forKey: "selectedEquipmentType") ?? "Not Set"
        
        // Body Image References
        desiredBodyImage = defaults.string(forKey: "desiredBodyImage") ?? "Not Set"
        
        // Legacy/Additional Equipment Reference
        equipmentPreference = defaults.string(forKey: "equipmentPreference") ?? "Not Set"
        
        // Subscription Data
        subscriptionPlan = defaults.string(forKey: "subscription_plan") ?? "Free"
        subscriptionExpirationDate = defaults.object(forKey: "subscription_expiration_date") as? Date
        isSubscriptionActive = defaults.bool(forKey: "is_subscription_active")
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
    
    /// Returns a summary of the user's profile
    var profileSummary: String {
        let ageText = age != nil ? "\(age!) years old" : "Age not set"
        let heightText = resolvedHeightCm > 0 ? "\(resolvedHeightCm)cm" : "Height not set"
        let weightText = weightKg > 0 ? "\(Int(weightKg))kg" : "Weight not set"
        
        return "\(ageText), \(heightText), \(weightText)"
    }
    
    /// Returns a formatted string for the user's goal
    var goalSummary: String {
        return "Goal: \(goal) • Target: \(target)"
    }
    
    /// Returns a formatted string for the user's activity level
    var activitySummary: String {
        return "Activity: \(levelActivity) • Workout Level: \(workoutLevel)"
    }
    
    /// Returns a formatted string for the user's workout preferences
    var workoutSummary: String {
        return "Location: \(workoutLocation) • Equipment: \(selectedEquipmentType)"
    }
    
    /// Returns a formatted string for the user's diet preferences
    var dietSummary: String {
        return "Diet Type: \(dietType)"
    }
    
    /// Returns a formatted string for the user's subscription status
    var subscriptionSummary: String {
        if isSubscriptionActive {
            return "Active \(subscriptionPlan) subscription"
        } else {
            return "Free plan"
        }
    }
    
    /// Returns a complete profile summary
    var completeSummary: String {
        return """
        Profile: \(profileSummary)
        \(goalSummary)
        \(activitySummary)
        \(workoutSummary)
        \(dietSummary)
        \(subscriptionSummary)
        """
    }
    
    /// Returns a short profile summary for display
    var shortSummary: String {
        let ageText = age != nil ? "\(age!)y" : "N/A"
        let heightText = resolvedHeightCm > 0 ? "\(resolvedHeightCm)cm" : "N/A"
        let weightText = weightKg > 0 ? "\(Int(weightKg))kg" : "N/A"
        
        return "\(ageText) • \(heightText) • \(weightText) • \(goal)"
    }
    
    /// Returns a formatted string for the user's target weight
    var targetWeightSummary: String {
        let currentWeight = weightKg > 0 ? "\(Int(weightKg))kg" : "N/A"
        let targetWeight = targetWeightKg > 0 ? "\(Int(targetWeightKg))kg" : "N/A"
        
        return "Current: \(currentWeight) → Target: \(targetWeight)"
    }
    
    /// Returns a formatted string for the user's height
    var heightSummary: String {
        if let cm = heightCm, cm > 0 {
            return "\(cm)cm"
        } else if let ft = heightFt, let inch = heightInch {
            return "\(ft)'\(inch)\""
        } else {
            return "Not set"
        }
    }
    
    /// Returns a formatted string for the user's weight
    var weightSummary: String {
        return weightKg > 0 ? "\(Int(weightKg))kg" : "Not set"
    }
    
    /// Returns a formatted string for the user's age
    var ageSummary: String {
        return age != nil ? "\(age!) years" : "Not set"
    }
    
    /// Returns a formatted string for the user's gender
    var genderSummary: String {
        return genderEnum.rawValue.capitalized
    }
    
    /// Returns a formatted string for the user's birth year
    var birthYearSummary: String {
        return birthYear != "Not Set" ? birthYear : "Not set"
    }
    
    /// Returns a formatted string for the user's goal
    var goalSummaryShort: String {
        return goal != "Not Set" ? goal : "Not set"
    }
    
    /// Returns a formatted string for the user's target
    var targetSummaryShort: String {
        return target != "Not Set" ? target : "Not set"
    }
    
    /// Returns a formatted string for the user's diet type
    var dietTypeSummary: String {
        return dietType != "Not Set" ? dietType : "Not set"
    }
    
    /// Returns a formatted string for the user's activity level
    var activityLevelSummary: String {
        return levelActivity != "Not Set" ? levelActivity : "Not set"
    }
    
    /// Returns a formatted string for the user's workout level
    var workoutLevelSummary: String {
        return workoutLevel != "Not Set" ? workoutLevel : "Not set"
    }
    
    /// Returns a formatted string for the user's workout location
    var workoutLocationSummary: String {
        return workoutLocation != "Not Set" ? workoutLocation : "Not set"
    }
    
    /// Returns a formatted string for the user's equipment type
    var equipmentTypeSummary: String {
        return selectedEquipmentType != "Not Set" ? selectedEquipmentType : "Not set"
    }
    
    /// Returns a formatted string for the user's desired body image
    var desiredBodyImageSummary: String {
        return desiredBodyImage != "Not Set" ? desiredBodyImage : "Not set"
    }
    
    /// Returns a formatted string for the user's equipment preference
    var equipmentPreferenceSummary: String {
        return equipmentPreference != "Not Set" ? equipmentPreference : "Not set"
    }
    
    /// Returns a formatted string for the user's subscription plan
    var subscriptionPlanSummary: String {
        return subscriptionPlan != "Free" ? subscriptionPlan : "Free"
    }
    
    /// Returns a formatted string for the user's subscription expiration date
    var subscriptionExpirationSummary: String {
        if let expirationDate = subscriptionExpirationDate {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            return formatter.string(from: expirationDate)
        } else {
            return "No expiration date"
        }
    }
    
    /// Returns a formatted string for the user's subscription status
    var subscriptionStatusSummary: String {
        return isSubscriptionActive ? "Active" : "Inactive"
    }
    
    /// Returns a formatted string for the user's subscription details
    var subscriptionDetailsSummary: String {
        return "\(subscriptionPlanSummary) • \(subscriptionStatusSummary)"
    }
    
    /// Returns a formatted string for the user's subscription details with expiration
    var subscriptionDetailsWithExpirationSummary: String {
        if isSubscriptionActive {
            return "\(subscriptionPlanSummary) • Expires: \(subscriptionExpirationSummary)"
        } else {
            return "\(subscriptionPlanSummary) • \(subscriptionStatusSummary)"
        }
    }
    
    /// Returns a formatted string for the user's subscription details with expiration
    var subscriptionDetailsWithExpirationSummaryShort: String {
        if isSubscriptionActive {
            return "\(subscriptionPlanSummary) • \(subscriptionExpirationSummary)"
        } else {
            return "\(subscriptionPlanSummary)"
        }
    }
    
    /// Returns a formatted string for the user's subscription details with expiration
    var subscriptionDetailsWithExpirationSummaryLong: String {
        if isSubscriptionActive {
            return "\(subscriptionPlanSummary) • \(subscriptionStatusSummary) • Expires: \(subscriptionExpirationSummary)"
        } else {
            return "\(subscriptionPlanSummary) • \(subscriptionStatusSummary)"
        }
    }
    
    /// Returns a formatted string for the user's subscription details with expiration
    var subscriptionDetailsWithExpirationSummaryFull: String {
        if isSubscriptionActive {
            return "\(subscriptionPlanSummary) • \(subscriptionStatusSummary) • Expires: \(subscriptionExpirationSummary)"
        } else {
            return "\(subscriptionPlanSummary) • \(subscriptionStatusSummary) • No expiration date"
        }
    }
    
    /// Returns a formatted string for the user's subscription details with expiration
    var subscriptionDetailsWithExpirationSummaryComplete: String {
        if isSubscriptionActive {
            return "\(subscriptionPlanSummary) • \(subscriptionStatusSummary) • Expires: \(subscriptionExpirationSummary)"
        } else {
            return "\(subscriptionPlanSummary) • \(subscriptionStatusSummary) • No expiration date • Free plan"
        }
    }
    
    /// Returns a formatted string for the user's subscription details with expiration
    var subscriptionDetailsWithExpirationSummaryFinal: String {
        if isSubscriptionActive {
            return "\(subscriptionPlanSummary) • \(subscriptionStatusSummary) • Expires: \(subscriptionExpirationSummary)"
        } else {
            return "\(subscriptionPlanSummary) • \(subscriptionStatusSummary) • No expiration date • Free plan • No active subscription"
        }
    }
    
    // MARK: - Static Methods
    
    /// Carga el perfil de usuario desde UserDefaults
    static func loadFromUserDefaults() -> UserProfile {
        return UserProfile()
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

    // MARK: - Subscription Methods
    func isSubscriptionValid() -> Bool {
        guard let expirationDate = subscriptionExpirationDate else { return false }
        return isSubscriptionActive && expirationDate > Date()
    }
    
    func getSubscriptionStatus() -> String {
        if !isSubscriptionActive {
            return "Free Plan"
        }
        
        guard let expirationDate = subscriptionExpirationDate else {
            return "Free Plan"
        }
        
        if expirationDate > Date() {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            return "\(subscriptionPlan) - Active until \(formatter.string(from: expirationDate))"
        } else {
            return "Free Plan"
        }
    }
    
    // NUEVO: Guardar y exponer BMI y kilos a bajar/subir
    static var currentBMI: Double? {
        get { UserDefaults.standard.object(forKey: "currentBMI") as? Double }
        set { UserDefaults.standard.set(newValue, forKey: "currentBMI") }
    }
    static var kilosToLose: Double? {
        get { UserDefaults.standard.object(forKey: "kilosToLose") as? Double }
        set { UserDefaults.standard.set(newValue, forKey: "kilosToLose") }
    }
}
