import Foundation
import Combine

/// Servicio que maneja las preferencias del usuario para workouts
class UserPreferencesService: ObservableObject {
    
    // MARK: - Published Properties
    @Published var workoutPreferences: WorkoutPreferences
    @Published var notificationSettings: NotificationSettings
    @Published var userProfile: UserProfile
    @Published var currentUserWeight: Double
    
    // MARK: - Private Properties
    private let userDefaults = UserDefaults.standard
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - UserDefaults Keys
    private enum Keys {
        static let workoutPreferences = "workoutPreferences"
        static let notificationSettings = "workoutNotificationSettings"
        static let userProfile = "workoutUserProfile"
        static let selectedWorkoutMode = "selectedWorkoutMode"
        static let selectedMuscle = "selectedMuscle"
        static let userName = "userName"
        static let userWeight = "selectedWeightKg"
        static let userHeight = "selectedHeightCm"
        static let userAge = "userAge"
        static let userGender = "userGender"
        static let workoutGoal = "workoutGoal"
        static let workoutLevel = "workoutLevel"
        static let workoutFrequency = "workoutFrequency"
        static let workoutDuration = "workoutDuration"
        static let enableHeartRateMonitoring = "enableHeartRateMonitoring"
        static let enableWorkoutReminders = "enableWorkoutReminders"
        static let reminderTime = "workoutReminderTime"
        static let reminderDays = "workoutReminderDays"
    }
    
    // MARK: - Initialization
    
    init() {
        self.workoutPreferences = Self.loadWorkoutPreferences()
        self.notificationSettings = Self.loadNotificationSettings()
        self.userProfile = Self.loadUserProfile()
        self.currentUserWeight = userDefaults.double(forKey: Keys.userWeight)
        
        setupBindings()
    }
    
    // MARK: - Public Methods
    
    /// Actualiza las preferencias de workout
    func updateWorkoutPreferences(_ preferences: WorkoutPreferences) {
        workoutPreferences = preferences
        saveWorkoutPreferences()
    }
    
    /// Actualiza la configuración de notificaciones
    func updateNotificationSettings(_ settings: NotificationSettings) {
        notificationSettings = settings
        saveNotificationSettings()
    }
    
    /// Actualiza el perfil del usuario
    func updateUserProfile(_ profile: UserProfile) {
        userProfile = profile
        saveUserProfile()
    }
    
    /// Obtiene el peso del usuario
    var userWeight: Double {
        get { currentUserWeight }
        set { 
            currentUserWeight = newValue
            userDefaults.set(newValue, forKey: Keys.userWeight)
            // Actualizar el peso en UserDefaults para que se refleje en UserProfile
            userDefaults.set(newValue, forKey: "selectedWeightKg")
            // Recargar el UserProfile para que refleje los cambios
            userProfile = UserProfile()
            saveUserProfile()
        }
    }
    
    /// Obtiene la altura del usuario
    var userHeight: Double {
        get { userDefaults.double(forKey: Keys.userHeight) }
        set { 
            userDefaults.set(newValue, forKey: Keys.userHeight)
            // userProfile.height = newValue // UserProfile no es mutable
            saveUserProfile()
        }
    }
    
    /// Obtiene el nombre del usuario
    var userName: String {
        get { userDefaults.string(forKey: Keys.userName) ?? "" }
        set { 
            userDefaults.set(newValue, forKey: Keys.userName)
            // userProfile.name = newValue // UserProfile no es mutable
            saveUserProfile()
        }
    }
    
    /// Obtiene la edad del usuario
    var userAge: Int {
        get { userDefaults.integer(forKey: Keys.userAge) }
        set { 
            userDefaults.set(newValue, forKey: Keys.userAge)
            // userProfile.age = newValue // UserProfile no es mutable
            saveUserProfile()
        }
    }
    
    /// Obtiene el género del usuario
    var userGender: Gender {
        get { 
            let rawValue = userDefaults.string(forKey: Keys.userGender) ?? ""
            return Gender(rawValue: rawValue) ?? .other
        }
        set { 
            userDefaults.set(newValue.rawValue, forKey: Keys.userGender)
            // userProfile.gender = newValue // UserProfile no es mutable
            saveUserProfile()
        }
    }
    
    /// Obtiene el objetivo de workout
    var workoutGoal: WorkoutGoal {
        get { 
            let rawValue = userDefaults.string(forKey: Keys.workoutGoal) ?? ""
            return WorkoutGoal(rawValue: rawValue) ?? .generalFitness
        }
        set { 
            userDefaults.set(newValue.rawValue, forKey: Keys.workoutGoal)
            workoutPreferences.goal = newValue
            saveWorkoutPreferences()
        }
    }
    
    /// Obtiene el nivel de workout
    var workoutLevel: WorkoutLevelWorkout {
        get { 
            let rawValue = userDefaults.string(forKey: Keys.workoutLevel) ?? ""
            return WorkoutLevelWorkout(rawValue: rawValue) ?? .beginner
        }
        set { 
            userDefaults.set(newValue.rawValue, forKey: Keys.workoutLevel)
            workoutPreferences.level = newValue
            saveWorkoutPreferences()
        }
    }
    
    /// Obtiene la frecuencia de workout
    var workoutFrequency: WorkoutFrequency {
        get { 
            let rawValue = userDefaults.string(forKey: Keys.workoutFrequency) ?? ""
            return WorkoutFrequency(rawValue: rawValue) ?? .threeTimes
        }
        set { 
            userDefaults.set(newValue.rawValue, forKey: Keys.workoutFrequency)
            workoutPreferences.frequency = newValue
            saveWorkoutPreferences()
        }
    }
    
    /// Obtiene la duración de workout
    var workoutDuration: WorkoutDuration {
        get { 
            let rawValue = userDefaults.string(forKey: Keys.workoutDuration) ?? ""
            return WorkoutDuration(rawValue: rawValue) ?? .thirtyMinutes
        }
        set { 
            userDefaults.set(newValue.rawValue, forKey: Keys.workoutDuration)
            workoutPreferences.duration = newValue
            saveWorkoutPreferences()
        }
    }
    
    /// Calcula el IMC del usuario
    var bmi: Double {
        guard userHeight > 0 else { return 0 }
        let heightInMeters = userHeight / 100
        return userWeight / (heightInMeters * heightInMeters)
    }
    
    /// Obtiene la categoría del IMC
    var bmiCategory: BMICategoryWorkout {
        switch bmi {
        case ..<18.5: return .underweight
        case 18.5..<25: return .normal
        case 25..<30: return .overweight
        default: return .obese
        }
    }
    
    /// Obtiene el peso ideal basado en la altura y género
    var idealWeight: Double {
        let heightInMeters = userHeight / 100
        
        // Fórmula más precisa basada en rangos de BMI saludable
        // Para hombres: BMI 21-25 (promedio 23)
        // Para mujeres: BMI 20-24 (promedio 22)
        let baseBMI: Double
        
        switch userGender {
        case .male:
            baseBMI = 23.0 // BMI ideal para hombres
        case .female:
            baseBMI = 22.0 // BMI ideal para mujeres
        case .other, .notSet:
            baseBMI = 22.5 // Promedio general
        }
        
        return baseBMI * heightInMeters * heightInMeters
    }
    
    /// Calcula el promedio de pasos diarios recomendados basado en datos científicos
    var recommendedDailySteps: Int {
        // Base de pasos según edad y género (estudios científicos)
        let baseSteps = calculateBaseSteps()
        
        // Multiplicador por nivel de actividad
        let activityMultiplier = calculateActivityMultiplier()
        
        // Multiplicador por objetivo de fitness
        let goalMultiplier = calculateGoalMultiplier()
        
        // Multiplicador por nivel de workout
        let workoutMultiplier = calculateWorkoutMultiplier()
        
        // Multiplicador por BMI (si está fuera del rango saludable)
        let bmiMultiplier = calculateBMIMultiplier()
        
        // Cálculo final
        let recommendedSteps = Double(baseSteps) * activityMultiplier * goalMultiplier * workoutMultiplier * bmiMultiplier
        
        return Int(recommendedSteps.rounded())
    }
    
    /// Calcula los pasos base según edad y género
    private func calculateBaseSteps() -> Int {
        // Basado en estudios de la OMS y CDC
        switch userAge {
        case 18...29:
            return userGender == .male ? 10000 : 9500
        case 30...39:
            return userGender == .male ? 9500 : 9000
        case 40...49:
            return userGender == .male ? 9000 : 8500
        case 50...59:
            return userGender == .male ? 8500 : 8000
        case 60...69:
            return userGender == .male ? 8000 : 7500
        case 70...79:
            return userGender == .male ? 7500 : 7000
        case 80...:
            return userGender == .male ? 7000 : 6500
        default:
            return 8000 // Default para edades no especificadas
        }
    }
    
    /// Calcula multiplicador por nivel de actividad
    private func calculateActivityMultiplier() -> Double {
        // Basado en el nivel de actividad del usuario
        // Esto se puede obtener del onboarding o inferir del workout level
        switch workoutLevel {
        case .beginner:
            return 0.9 // Menos activo, empezando
        case .intermediate:
            return 1.0 // Actividad moderada
        case .advanced:
            return 1.15 // Muy activo
        }
    }
    
    /// Calcula multiplicador por objetivo de fitness
    private func calculateGoalMultiplier() -> Double {
        switch workoutGoal {
        case .weightLoss:
            return 1.2 // Más pasos para perder peso
        case .muscleGain:
            return 1.1 // Pasos moderados, enfoque en fuerza
        case .strength:
            return 1.0 // Pasos estándar, enfoque en fuerza
        case .endurance:
            return 1.3 // Muchos pasos para resistencia
        case .generalFitness:
            return 1.0 // Pasos estándar
        case .flexibility:
            return 0.9 // Menos pasos, más flexibilidad
        }
    }
    
    /// Calcula multiplicador por nivel de workout
    private func calculateWorkoutMultiplier() -> Double {
        switch workoutFrequency {
        case .twoTimes:
            return 0.9 // Poca frecuencia, menos pasos
        case .threeTimes:
            return 1.0 // Frecuencia estándar
        case .fourTimes:
            return 1.1
        case .fiveTimes:
            return 1.2
        case .sixTimes:
            return 1.3
        case .daily:
            return 1.4 // Entrenamiento diario, más pasos
        }
    }
    
    /// Calcula multiplicador por BMI
    private func calculateBMIMultiplier() -> Double {
        let currentBMI = bmi
        
        switch currentBMI {
        case ..<18.5: // Bajo peso
            return 0.9 // Menos pasos para evitar pérdida de peso
        case 18.5..<25: // Peso normal
            return 1.0 // Pasos estándar
        case 25..<30: // Sobrepeso
            return 1.1 // Más pasos para perder peso
        case 30..<35: // Obesidad clase I
            return 1.2 // Aún más pasos
        case 35..<40: // Obesidad clase II
            return 1.3 // Muchos pasos
        default: // Obesidad clase III
            return 1.4 // Máximo de pasos
        }
    }
    
    /// Resetea todas las preferencias a valores por defecto
    func resetToDefaults() {
        workoutPreferences = WorkoutPreferences.default
        notificationSettings = NotificationSettings.default
        userProfile = UserProfile() // UserProfile no tiene .default, usa el init()
        
        saveWorkoutPreferences()
        saveNotificationSettings()
        saveUserProfile()
    }
    
    /// Exporta las preferencias como datos
    func exportPreferences() -> Data? {
        let exportData = PreferencesExport(
            workoutPreferences: workoutPreferences,
            notificationSettings: notificationSettings,
            userProfile: userProfile,
            exportDate: Date()
        )
        
        return try? JSONEncoder().encode(exportData)
    }
    
    /// Importa preferencias desde datos
    func importPreferences(from data: Data) -> Bool {
        guard let exportData = try? JSONDecoder().decode(PreferencesExport.self, from: data) else {
            return false
        }
        
        workoutPreferences = exportData.workoutPreferences
        notificationSettings = exportData.notificationSettings
        userProfile = exportData.userProfile
        
        saveWorkoutPreferences()
        saveNotificationSettings()
        saveUserProfile()
        
        return true
    }
    
    // MARK: - Private Methods
    
    private func setupBindings() {
        // Observar cambios en las preferencias y guardar automáticamente
        $workoutPreferences
            .dropFirst()
            .sink { [weak self] _ in
                self?.saveWorkoutPreferences()
            }
            .store(in: &cancellables)
        
        $notificationSettings
            .dropFirst()
            .sink { [weak self] _ in
                self?.saveNotificationSettings()
            }
            .store(in: &cancellables)
        
        $userProfile
            .dropFirst()
            .sink { [weak self] _ in
                self?.saveUserProfile()
            }
            .store(in: &cancellables)
    }
    
    private static func loadWorkoutPreferences() -> WorkoutPreferences {
        guard let data = UserDefaults.standard.data(forKey: Keys.workoutPreferences),
              let preferences = try? JSONDecoder().decode(WorkoutPreferences.self, from: data) else {
            return WorkoutPreferences.default
        }
        return preferences
    }
    
    private static func loadNotificationSettings() -> NotificationSettings {
        guard let data = UserDefaults.standard.data(forKey: Keys.notificationSettings),
              let settings = try? JSONDecoder().decode(NotificationSettings.self, from: data) else {
            return NotificationSettings.default
        }
        return settings
    }
    
    private static func loadUserProfile() -> UserProfile {
        guard let data = UserDefaults.standard.data(forKey: Keys.userProfile),
              let profile = try? JSONDecoder().decode(UserProfile.self, from: data) else {
            return UserProfile() // UserProfile no tiene .default, usa el init()
        }
        return profile
    }
    
    private func saveWorkoutPreferences() {
        if let data = try? JSONEncoder().encode(workoutPreferences) {
            userDefaults.set(data, forKey: Keys.workoutPreferences)
        }
    }
    
    private func saveNotificationSettings() {
        if let data = try? JSONEncoder().encode(notificationSettings) {
            userDefaults.set(data, forKey: Keys.notificationSettings)
        }
    }
    
    private func saveUserProfile() {
        if let data = try? JSONEncoder().encode(userProfile) {
            userDefaults.set(data, forKey: Keys.userProfile)
        }
    }
}

// MARK: - Supporting Models

struct WorkoutPreferences: Codable {
    var goal: WorkoutGoal
    var level: WorkoutLevelWorkout
    var frequency: WorkoutFrequency
    var duration: WorkoutDuration
    var enableHeartRateMonitoring: Bool
    var enableWorkoutReminders: Bool
    var preferredWorkoutTime: Date
    
    static let `default` = WorkoutPreferences(
        goal: .generalFitness,
        level: .beginner,
        frequency: .threeTimes,
        duration: .thirtyMinutes,
        enableHeartRateMonitoring: true,
        enableWorkoutReminders: true,
        preferredWorkoutTime: Calendar.current.date(from: DateComponents(hour: 18, minute: 0)) ?? Date()
    )
}

struct NotificationSettings: Codable {
    var enableWorkoutReminders: Bool
    var reminderTime: Date
    var reminderDays: Set<Weekday>
    var enableProgressUpdates: Bool
    var enableAchievementNotifications: Bool
    
    static let `default` = NotificationSettings(
        enableWorkoutReminders: true,
        reminderTime: Calendar.current.date(from: DateComponents(hour: 18, minute: 0)) ?? Date(),
        reminderDays: [.monday, .wednesday, .friday],
        enableProgressUpdates: true,
        enableAchievementNotifications: true
    )
}



struct PreferencesExport: Codable {
    let workoutPreferences: WorkoutPreferences
    let notificationSettings: NotificationSettings
    let userProfile: UserProfile
    let exportDate: Date
}

// MARK: - Enums

enum WorkoutGoal: String, CaseIterable, Codable {
    case weightLoss = "Weight Loss"
    case muscleGain = "Muscle Gain"
    case generalFitness = "General Fitness"
    case strength = "Strength"
    case endurance = "Endurance"
    case flexibility = "Flexibility"
}



enum WorkoutFrequency: String, CaseIterable, Codable {
    case twoTimes = "2 times/week"
    case threeTimes = "3 times/week"
    case fourTimes = "4 times/week"
    case fiveTimes = "5 times/week"
    case sixTimes = "6 times/week"
    case daily = "Daily"
}

enum WorkoutDuration: String, CaseIterable, Codable {
    case fifteenMinutes = "15 minutes"
    case thirtyMinutes = "30 minutes"
    case fortyFiveMinutes = "45 minutes"
    case sixtyMinutes = "60 minutes"
    case ninetyMinutes = "90 minutes"
}



enum WorkoutLevelWorkout: String, CaseIterable, Codable {
    case beginner = "Beginner"
    case intermediate = "Intermediate"
    case advanced = "Advanced"
}

enum Weekday: String, CaseIterable, Codable {
    case monday = "Monday"
    case tuesday = "Tuesday"
    case wednesday = "Wednesday"
    case thursday = "Thursday"
    case friday = "Friday"
    case saturday = "Saturday"
    case sunday = "Sunday"
}

enum BMICategoryWorkout: String, Codable {
    case underweight = "Underweight"
    case normal = "Normal"
    case overweight = "Overweight"
    case obese = "Obese"
} 