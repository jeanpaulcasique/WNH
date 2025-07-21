import Foundation
import Combine

/// Servicio que maneja las preferencias del usuario para workouts
class UserPreferencesService: ObservableObject {
    
    // MARK: - Published Properties
    @Published var workoutPreferences: WorkoutPreferences
    @Published var notificationSettings: NotificationSettings
    @Published var userProfile: UserProfile
    
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
        get { userDefaults.double(forKey: Keys.userWeight) }
        set { 
            userDefaults.set(newValue, forKey: Keys.userWeight)
            // userProfile.weight = newValue // UserProfile no es mutable
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
        let baseWeight = 22.0 * heightInMeters * heightInMeters
        
        switch userGender {
        case .male: return baseWeight * 1.05
        case .female: return baseWeight * 0.95
        case .other, .notSet: return baseWeight
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