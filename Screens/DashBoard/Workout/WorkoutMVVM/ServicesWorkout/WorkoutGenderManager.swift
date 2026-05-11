import SwiftUI

/// Manager que maneja la lógica específica por género para workouts
class WorkoutGenderManager: ObservableObject {
    
    // MARK: - Published Properties
    @Published var userManager: UserManager
    
    // MARK: - Initialization
    
    init(userManager: UserManager = UserManager()) {
        self.userManager = userManager
    }
    
    // MARK: - Gender-Based Workout Methods
    
    /// Mensaje de bienvenida personalizado para el workout según género
    var workoutWelcomeMessage: String {
        switch userManager.userProfile.genderEnum {
        case .female:
            return LanguageManager.localizedString("Ready to build strength and confidence? Let's crush this workout! 💪")
        case .male:
            return LanguageManager.localizedString("Ready to build power and endurance? Let's dominate this workout! 🔥")
        case .other:
            return LanguageManager.localizedString("Ready to build your best self? Let's rock this workout! ⭐")
        case .notSet:
            return LanguageManager.localizedString("Ready to get stronger? Let's start this workout! 💪")
        }
    }
    
    /// Intensidad recomendada según género
    var recommendedIntensity: String {
        switch userManager.userProfile.genderEnum {
        case .female:
            return LanguageManager.localizedString("Focus on form and gradual progression")
        case .male:
            return LanguageManager.localizedString("Push your limits while maintaining form")
        case .other, .notSet:
            return LanguageManager.localizedString("Find your comfortable challenge level")
        }
    }
    
    /// Duración recomendada de workout según género
    var recommendedWorkoutDuration: Int {
        let baseDuration: Int
        switch userManager.userProfile.genderEnum {
        case .female:
            baseDuration = 35 // Mujeres suelen preferir workouts más largos pero menos intensos
        case .male:
            baseDuration = 45 // Hombres suelen preferir workouts más intensos pero más cortos
        case .other, .notSet:
            baseDuration = 40
        }
        
        // Ajustar por nivel de actividad
        switch userManager.userProfile.activityLevelEnum {
        case .sedentary: return baseDuration - 10
        case .lightlyActive: return baseDuration - 5
        case .active: return baseDuration
        case .veryActive: return baseDuration + 10
        case .notSet: return baseDuration
        }
    }
    
    /// Ejercicios recomendados según género
    var recommendedExercises: [String] {
        switch userManager.userProfile.genderEnum {
        case .female:
            return [
                "Squats with proper form",
                "Push-ups (modified if needed)",
                "Planks for core strength",
                "Glute bridges for posterior chain"
            ]
        case .male:
            return [
                "Compound movements",
                "Progressive overload",
                "Functional strength",
                "Mobility work"
            ]
        case .other, .notSet:
            return [
                "Full body movements",
                "Balance exercises",
                "Flexibility work",
                "Strength building"
            ]
        }
    }
    
    /// Mensaje de motivación durante el workout según género
    func getWorkoutMotivationMessage(for exercise: String) -> String {
        switch userManager.userProfile.genderEnum {
        case .female:
            return "You're building incredible strength with \(exercise)! Keep going! 💪"
        case .male:
            return "You're crushing \(exercise)! Push through! 🔥"
        case .other, .notSet:
            return "You're doing amazing with \(exercise)! Stay strong! ⭐"
        }
    }
    
    /// Configuración de descanso según género
    var restTimeConfiguration: (short: Int, medium: Int, long: Int) {
        switch userManager.userProfile.genderEnum {
        case .female:
            return (short: 30, medium: 60, long: 90) // Mujeres suelen necesitar más tiempo de recuperación
        case .male:
            return (short: 45, medium: 90, long: 120) // Hombres suelen tener más masa muscular, necesitan más descanso
        case .other, .notSet:
            return (short: 40, medium: 75, long: 105)
        }
    }
    
    /// Calorías quemadas estimadas según género
    func estimatedCaloriesBurned(for duration: Int, intensity: String) -> Int {
        let baseCalories: Double
        switch userManager.userProfile.genderEnum {
        case .female:
            baseCalories = 6.0 // Mujeres suelen quemar menos calorías por minuto
        case .male:
            baseCalories = 8.0 // Hombres suelen quemar más calorías por minuto
        case .other, .notSet:
            baseCalories = 7.0
        }
        
        let intensityMultiplier: Double
        switch intensity.lowercased() {
        case "low": intensityMultiplier = 0.7
        case "medium": intensityMultiplier = 1.0
        case "high": intensityMultiplier = 1.3
        default: intensityMultiplier = 1.0
        }
        
        return Int(baseCalories * Double(duration) * intensityMultiplier)
    }
    
    /// Mensaje de logro post-workout según género
    func getPostWorkoutMessage(caloriesBurned: Int, duration: Int) -> String {
        switch userManager.userProfile.genderEnum {
        case .female:
            return "Incredible! You burned \(caloriesBurned) calories in \(duration) minutes. Your strength is growing! 💪"
        case .male:
            return "Amazing! You burned \(caloriesBurned) calories in \(duration) minutes. You're getting stronger! 🔥"
        case .other, .notSet:
            return "Fantastic! You burned \(caloriesBurned) calories in \(duration) minutes. You're making progress! ⭐"
        }
    }
    
    /// Navegación condicional post-workout según género
    func getPostWorkoutNextStep() -> String {
        switch userManager.userProfile.genderEnum {
        case .female:
            return "RecoveryAndStretching"
        case .male:
            return "ProgressTracking"
        case .other, .notSet:
            return "GeneralProgress"
        }
    }
} 
