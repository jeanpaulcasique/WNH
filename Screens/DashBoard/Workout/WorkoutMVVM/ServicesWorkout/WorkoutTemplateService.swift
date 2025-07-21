import Foundation
import Combine

/// Servicio que maneja plantillas de entrenamiento y recomendaciones
class WorkoutTemplateService: ObservableObject {
    
    // MARK: - Published Properties
    @Published var availableTemplates: [WorkoutTemplate] = []
    @Published var userTemplates: [WorkoutTemplate] = []
    @Published var recommendedTemplates: [WorkoutTemplate] = []
    @Published var currentTemplate: WorkoutTemplate?
    
    // MARK: - Private Properties
    private var cancellables = Set<AnyCancellable>()
    private let userPreferencesService: UserPreferencesService
    private let progressService: ProgressService
    
    // MARK: - Initialization
    
    init(userPreferencesService: UserPreferencesService, progressService: ProgressService) {
        self.userPreferencesService = userPreferencesService
        self.progressService = progressService
        
        loadDefaultTemplates()
        loadUserTemplates()
        generateRecommendations()
    }
    
    // MARK: - Template Management
    
    /// Carga las plantillas por defecto
    private func loadDefaultTemplates() {
        availableTemplates = [
            // Beginner Templates
            WorkoutTemplate(
                id: "beginner_full_body",
                name: "Beginner Full Body",
                description: "Complete full body workout for beginners",
                difficulty: .beginner,
                duration: 30,
                exercises: [
                    TemplateExercise(name: "Push-ups", sets: 3, reps: "5-10", rest: 60),
                    TemplateExercise(name: "Squats", sets: 3, reps: "10-15", rest: 60),
                    TemplateExercise(name: "Plank", sets: 3, reps: "30 seconds", rest: 45),
                    TemplateExercise(name: "Lunges", sets: 3, reps: "10 each leg", rest: 60)
                ],
                category: .fullBody,
                equipment: [.bodyweight],
                tags: ["beginner", "full-body", "strength"]
            ),
            
            WorkoutTemplate(
                id: "beginner_upper_body",
                name: "Beginner Upper Body",
                description: "Focus on chest, back, and arms",
                difficulty: .beginner,
                duration: 25,
                exercises: [
                    TemplateExercise(name: "Push-ups", sets: 3, reps: "5-10", rest: 60),
                    TemplateExercise(name: "Diamond Push-ups", sets: 2, reps: "3-5", rest: 60),
                    TemplateExercise(name: "Superman", sets: 3, reps: "10", rest: 45),
                    TemplateExercise(name: "Arm Circles", sets: 2, reps: "20 each direction", rest: 30)
                ],
                category: .upperBody,
                equipment: [.bodyweight],
                tags: ["beginner", "upper-body", "strength"]
            ),
            
            // Intermediate Templates
            WorkoutTemplate(
                id: "intermediate_strength",
                name: "Intermediate Strength",
                description: "Build strength with compound movements",
                difficulty: .intermediate,
                duration: 45,
                exercises: [
                    TemplateExercise(name: "Bench Press", sets: 4, reps: "8-12", rest: 90),
                    TemplateExercise(name: "Squats", sets: 4, reps: "8-12", rest: 90),
                    TemplateExercise(name: "Deadlifts", sets: 3, reps: "6-8", rest: 120),
                    TemplateExercise(name: "Pull-ups", sets: 3, reps: "5-8", rest: 90),
                    TemplateExercise(name: "Overhead Press", sets: 3, reps: "8-10", rest: 75)
                ],
                category: .strength,
                equipment: [.barbell, .dumbbell],
                tags: ["intermediate", "strength", "compound"]
            ),
            
            // Advanced Templates
            WorkoutTemplate(
                id: "advanced_powerlifting",
                name: "Advanced Powerlifting",
                description: "Focus on the big three lifts",
                difficulty: .advanced,
                duration: 60,
                exercises: [
                    TemplateExercise(name: "Squats", sets: 5, reps: "5", rest: 180),
                    TemplateExercise(name: "Bench Press", sets: 5, reps: "5", rest: 180),
                    TemplateExercise(name: "Deadlifts", sets: 1, reps: "5", rest: 300),
                    TemplateExercise(name: "Accessory Work", sets: 3, reps: "8-12", rest: 90)
                ],
                category: .powerlifting,
                equipment: [.barbell, .rack],
                tags: ["advanced", "powerlifting", "strength"]
            ),
            
            // Cardio Templates
            WorkoutTemplate(
                id: "cardio_hiit",
                name: "HIIT Cardio",
                description: "High-intensity interval training",
                difficulty: .intermediate,
                duration: 20,
                exercises: [
                    TemplateExercise(name: "Burpees", sets: 8, reps: "30 seconds", rest: 30),
                    TemplateExercise(name: "Mountain Climbers", sets: 8, reps: "30 seconds", rest: 30),
                    TemplateExercise(name: "Jump Squats", sets: 8, reps: "30 seconds", rest: 30),
                    TemplateExercise(name: "High Knees", sets: 8, reps: "30 seconds", rest: 30)
                ],
                category: .cardio,
                equipment: [.bodyweight],
                tags: ["cardio", "hiit", "fat-burning"]
            )
        ]
    }
    
    /// Carga las plantillas personalizadas del usuario
    private func loadUserTemplates() {
        // Load from UserDefaults or local storage
        if let data = UserDefaults.standard.data(forKey: "userWorkoutTemplates"),
           let templates = try? JSONDecoder().decode([WorkoutTemplate].self, from: data) {
            userTemplates = templates
        }
    }
    
    /// Guarda las plantillas personalizadas del usuario
    private func saveUserTemplates() {
        if let data = try? JSONEncoder().encode(userTemplates) {
            UserDefaults.standard.set(data, forKey: "userWorkoutTemplates")
        }
    }
    
    // MARK: - Template Operations
    
    /// Crea una nueva plantilla personalizada
    func createTemplate(_ template: WorkoutTemplate) {
        let newTemplate = WorkoutTemplate(
            id: UUID().uuidString,
            name: template.name,
            description: template.description,
            difficulty: template.difficulty,
            duration: template.duration,
            exercises: template.exercises,
            category: template.category,
            equipment: template.equipment,
            tags: template.tags,
            isCustom: true,
            createdDate: Date(),
            lastUsed: template.lastUsed,
            usageCount: template.usageCount
        )
        userTemplates.append(newTemplate)
        saveUserTemplates()
        generateRecommendations()
    }
    
    /// Actualiza una plantilla existente
    func updateTemplate(_ template: WorkoutTemplate) {
        if let index = userTemplates.firstIndex(where: { $0.id == template.id }) {
            userTemplates[index] = template
            saveUserTemplates()
            generateRecommendations()
        }
    }
    
    /// Elimina una plantilla personalizada
    func deleteTemplate(_ template: WorkoutTemplate) {
        userTemplates.removeAll { $0.id == template.id }
        saveUserTemplates()
        generateRecommendations()
    }
    
    /// Duplica una plantilla
    func duplicateTemplate(_ template: WorkoutTemplate) {
        let duplicatedTemplate = WorkoutTemplate(
            id: UUID().uuidString,
            name: "\(template.name) (Copy)",
            description: template.description,
            difficulty: template.difficulty,
            duration: template.duration,
            exercises: template.exercises,
            category: template.category,
            equipment: template.equipment,
            tags: template.tags,
            isCustom: true,
            createdDate: Date(),
            lastUsed: template.lastUsed,
            usageCount: template.usageCount
        )
        userTemplates.append(duplicatedTemplate)
        saveUserTemplates()
    }
    
    // MARK: - Recommendations
    
    /// Genera recomendaciones basadas en el perfil del usuario
    private func generateRecommendations() {
        let userProfile = userPreferencesService.userProfile
        let userGoal = userPreferencesService.workoutGoal
        let userLevel = userPreferencesService.workoutLevel
        let userFrequency = userPreferencesService.workoutFrequency
        
        var recommendations: [WorkoutTemplate] = []
        
        // Filter by user level
        let levelTemplates = availableTemplates.filter { $0.difficulty == userLevel }
        
        // Filter by user goal
        let goalTemplates = levelTemplates.filter { template in
            switch userGoal {
            case .weightLoss:
                return template.tags.contains("fat-burning") || template.category == .cardio
            case .muscleGain:
                return template.tags.contains("strength") || template.category == .strength
            case .strength:
                return template.tags.contains("strength") || template.category == .powerlifting
            case .endurance:
                return template.tags.contains("cardio") || template.category == .cardio
            case .flexibility:
                return template.tags.contains("flexibility") || template.category == .yoga
            case .generalFitness:
                return template.category == .fullBody
            }
        }
        
        // Filter by available equipment
        let workoutMode = userPreferencesService.userProfile.workoutLocationEnum
        let equipmentTemplates = goalTemplates.filter { template in
            template.equipment.allSatisfy { equipment in
                switch equipment {
                case .bodyweight:
                    return true // Always available
                case .dumbbell:
                    return true // Suponemos que siempre está disponible
                case .barbell, .rack, .machine:
                    return workoutMode == .atTheGym
                default:
                    return false
                }
            }
        }
        
        // Filter by duration preference
        let durationTemplates = equipmentTemplates.filter { template in
            let preferredDuration = userPreferencesService.workoutDuration.minutes
            return template.duration <= preferredDuration + 15 // Allow some flexibility
        }
        
        recommendations = Array(durationTemplates.prefix(5))
        
        // Add user's custom templates
        recommendations.append(contentsOf: userTemplates.prefix(3))
        
        recommendedTemplates = recommendations
    }
    
    /// Obtiene recomendaciones para un objetivo específico
    func getRecommendations(for goal: WorkoutGoal) -> [WorkoutTemplate] {
        return availableTemplates.filter { template in
            switch goal {
            case .weightLoss:
                return template.tags.contains("fat-burning") || template.category == .cardio
            case .muscleGain:
                return template.tags.contains("strength") || template.category == .strength
            case .strength:
                return template.tags.contains("strength") || template.category == .powerlifting
            case .endurance:
                return template.tags.contains("cardio") || template.category == .cardio
            case .flexibility:
                return template.tags.contains("flexibility") || template.category == .yoga
            case .generalFitness:
                return template.category == .fullBody
            }
        }
    }
    
    /// Obtiene plantillas por dificultad
    func getTemplates(for difficulty: WorkoutLevelWorkout) -> [WorkoutTemplate] {
        return availableTemplates.filter { $0.difficulty == difficulty }
    }
    
    /// Obtiene plantillas por categoría
    func getTemplates(for category: WorkoutCategory) -> [WorkoutTemplate] {
        return availableTemplates.filter { $0.category == category }
    }
    
    // MARK: - Template Execution
    
    /// Inicia una plantilla de entrenamiento
    func startTemplate(_ template: WorkoutTemplate) {
        currentTemplate = template
        // Additional logic for starting a workout session
    }
    
    /// Completa una plantilla de entrenamiento
    func completeTemplate(_ template: WorkoutTemplate, completion: @escaping (Bool) -> Void) {
        // Save completion data
        let completionData = WorkoutCompletion(
            templateId: template.id,
            templateName: template.name,
            completedDate: Date(),
            duration: template.duration,
            exercises: template.exercises
        )
        saveWorkoutCompletion(completionData)
        currentTemplate = nil
        completion(true)
    }
    
    /// Guarda la completitud de un workout
    private func saveWorkoutCompletion(_ completion: WorkoutCompletion) {
        var completions = getWorkoutCompletions()
        completions.append(completion)
        
        if let data = try? JSONEncoder().encode(completions) {
            UserDefaults.standard.set(data, forKey: "workoutCompletions")
        }
    }
    
    /// Obtiene el historial de completitud de workouts
    func getWorkoutCompletions() -> [WorkoutCompletion] {
        if let data = UserDefaults.standard.data(forKey: "workoutCompletions"),
           let completions = try? JSONDecoder().decode([WorkoutCompletion].self, from: data) {
            return completions
        }
        return []
    }
}

// MARK: - Supporting Models

struct WorkoutTemplate: Identifiable, Codable {
    let id: String
    var name: String
    var description: String
    var difficulty: WorkoutLevelWorkout
    var duration: Int // minutes
    var exercises: [TemplateExercise]
    var category: WorkoutCategory
    var equipment: [WorkoutEquipment]
    var tags: [String]
    var isCustom: Bool = false
    var createdDate: Date = Date()
    var lastUsed: Date?
    var usageCount: Int = 0
}

struct TemplateExercise: Identifiable, Codable {
    let id = UUID()
    var name: String
    var sets: Int
    var reps: String
    var rest: Int // seconds
    var notes: String?
    var isOptional: Bool = false
}

struct WorkoutCompletion: Identifiable, Codable {
    let id = UUID()
    let templateId: String
    let templateName: String
    let completedDate: Date
    let duration: Int
    let exercises: [TemplateExercise]
    var actualDuration: Int?
    var notes: String?
}

enum WorkoutCategory: String, CaseIterable, Codable {
    case fullBody = "Full Body"
    case upperBody = "Upper Body"
    case lowerBody = "Lower Body"
    case strength = "Strength"
    case powerlifting = "Powerlifting"
    case cardio = "Cardio"
    case yoga = "Yoga"
    case flexibility = "Flexibility"
    case hiit = "HIIT"
    case endurance = "Endurance"
}

enum WorkoutEquipment: String, CaseIterable, Codable {
    case bodyweight = "Bodyweight"
    case dumbbell = "Dumbbell"
    case barbell = "Barbell"
    case rack = "Rack"
    case machine = "Machine"
    case resistance = "Resistance Bands"
    case kettlebell = "Kettlebell"
}

// MARK: - Extensions

extension WorkoutDuration {
    var minutes: Int {
        switch self {
        case .fifteenMinutes: return 15
        case .thirtyMinutes: return 30
        case .fortyFiveMinutes: return 45
        case .sixtyMinutes: return 60
        case .ninetyMinutes: return 90
        }
    }
} 