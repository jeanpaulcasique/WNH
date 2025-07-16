import Foundation

/// UserDefaultManager centraliza y documenta todas las claves y accesos a UserDefaults de la app.
struct UserDefaultManager {
    // MARK: - Onboarding & Estado de usuario
    static var isLoggedIn: Bool {
        get { UserDefaults.standard.bool(forKey: Keys.isLoggedIn) }
        set { UserDefaults.standard.set(newValue, forKey: Keys.isLoggedIn) }
    }
    static var hasCompletedOnboarding: Bool {
        get { UserDefaults.standard.bool(forKey: Keys.hasCompletedOnboarding) }
        set { UserDefaults.standard.set(newValue, forKey: Keys.hasCompletedOnboarding) }
    }
    static var isFirstTime: Bool {
        get { UserDefaults.standard.bool(forKey: Keys.isFirstTime) }
        set { UserDefaults.standard.set(newValue, forKey: Keys.isFirstTime) }
    }
    // MARK: - Perfil
    static var gender: String? {
        get { UserDefaults.standard.string(forKey: Keys.gender) }
        set { UserDefaults.standard.set(newValue, forKey: Keys.gender) }
    }
    static var birthYear: String? {
        get { UserDefaults.standard.string(forKey: Keys.birthYear) }
        set { UserDefaults.standard.set(newValue, forKey: Keys.birthYear) }
    }
    static var heightCm: Int? {
        get { UserDefaults.standard.value(forKey: Keys.heightCm) as? Int }
        set { UserDefaults.standard.set(newValue, forKey: Keys.heightCm) }
    }
    static var heightFt: Int? {
        get { UserDefaults.standard.value(forKey: Keys.heightFt) as? Int }
        set { UserDefaults.standard.set(newValue, forKey: Keys.heightFt) }
    }
    static var heightInch: Int? {
        get { UserDefaults.standard.value(forKey: Keys.heightInch) as? Int }
        set { UserDefaults.standard.set(newValue, forKey: Keys.heightInch) }
    }
    static var weightKg: Double? {
        get { UserDefaults.standard.object(forKey: Keys.weightKg) as? Double }
        set { UserDefaults.standard.set(newValue, forKey: Keys.weightKg) }
    }
    static var targetWeightKg: Double? {
        get { UserDefaults.standard.object(forKey: Keys.targetWeightKg) as? Double }
        set { UserDefaults.standard.set(newValue, forKey: Keys.targetWeightKg) }
    }
    static var desiredBodyImage: String? {
        get { UserDefaults.standard.string(forKey: Keys.desiredBodyImage) }
        set { UserDefaults.standard.set(newValue, forKey: Keys.desiredBodyImage) }
    }
    // MARK: - Preferencias y selección
    static var selectedGoal: String? {
        get { UserDefaults.standard.string(forKey: Keys.selectedGoal) }
        set { UserDefaults.standard.set(newValue, forKey: Keys.selectedGoal) }
    }
    static var selectedTarget: String? {
        get { UserDefaults.standard.string(forKey: Keys.selectedTarget) }
        set { UserDefaults.standard.set(newValue, forKey: Keys.selectedTarget) }
    }
    static var selectedDietType: String? {
        get { UserDefaults.standard.string(forKey: Keys.selectedDietType) }
        set { UserDefaults.standard.set(newValue, forKey: Keys.selectedDietType) }
    }
    static var selectedLevelActivity: String? {
        get { UserDefaults.standard.string(forKey: Keys.selectedLevelActivity) }
        set { UserDefaults.standard.set(newValue, forKey: Keys.selectedLevelActivity) }
    }
    static var selectedWorkoutLevel: String? {
        get { UserDefaults.standard.string(forKey: Keys.selectedWorkoutLevel) }
        set { UserDefaults.standard.set(newValue, forKey: Keys.selectedWorkoutLevel) }
    }
    static var selectedHowOften: String? {
        get { UserDefaults.standard.string(forKey: Keys.selectedHowOften) }
        set { UserDefaults.standard.set(newValue, forKey: Keys.selectedHowOften) }
    }
    static var selectedEquipmentType: String? {
        get { UserDefaults.standard.string(forKey: Keys.selectedEquipmentType) }
        set { UserDefaults.standard.set(newValue, forKey: Keys.selectedEquipmentType) }
    }
    static var selectedEquipmentIndex: Int? {
        get { UserDefaults.standard.value(forKey: Keys.selectedEquipmentIndex) as? Int }
        set { UserDefaults.standard.set(newValue, forKey: Keys.selectedEquipmentIndex) }
    }
    static var selectedWorkoutLocation: String? {
        get { UserDefaults.standard.string(forKey: Keys.selectedWorkoutLocation) }
        set { UserDefaults.standard.set(newValue, forKey: Keys.selectedWorkoutLocation) }
    }
    static var workoutLocationIndex: Int? {
        get { UserDefaults.standard.value(forKey: Keys.workoutLocationIndex) as? Int }
        set { UserDefaults.standard.set(newValue, forKey: Keys.workoutLocationIndex) }
    }
    // MARK: - Estadísticas
    static var totalWorkouts: Int {
        get { UserDefaults.standard.integer(forKey: Keys.totalWorkouts) }
        set { UserDefaults.standard.set(newValue, forKey: Keys.totalWorkouts) }
    }
    static var currentStreak: Int {
        get { UserDefaults.standard.integer(forKey: Keys.currentStreak) }
        set { UserDefaults.standard.set(newValue, forKey: Keys.currentStreak) }
    }
    static var achievedGoals: Int {
        get { UserDefaults.standard.integer(forKey: Keys.achievedGoals) }
        set { UserDefaults.standard.set(newValue, forKey: Keys.achievedGoals) }
    }
    // MARK: - BMI y salud
    static var currentBMI: Double? {
        get { UserDefaults.standard.object(forKey: Keys.currentBMI) as? Double }
        set { UserDefaults.standard.set(newValue, forKey: Keys.currentBMI) }
    }
    static var kilosToLose: Double? {
        get { UserDefaults.standard.object(forKey: Keys.kilosToLose) as? Double }
        set { UserDefaults.standard.set(newValue, forKey: Keys.kilosToLose) }
    }
    // MARK: - Subscripción
    static var subscriptionPlan: String? {
        get { UserDefaults.standard.string(forKey: Keys.subscriptionPlan) }
        set { UserDefaults.standard.set(newValue, forKey: Keys.subscriptionPlan) }
    }
    static var subscriptionExpirationDate: Date? {
        get { UserDefaults.standard.object(forKey: Keys.subscriptionExpirationDate) as? Date }
        set { UserDefaults.standard.set(newValue, forKey: Keys.subscriptionExpirationDate) }
    }
    static var isSubscriptionActive: Bool {
        get { UserDefaults.standard.bool(forKey: Keys.isSubscriptionActive) }
        set { UserDefaults.standard.set(newValue, forKey: Keys.isSubscriptionActive) }
    }
    // MARK: - Claves
    private struct Keys {
        static let isLoggedIn = "isLoggedIn"
        static let hasCompletedOnboarding = "hasCompletedOnboarding"
        static let isFirstTime = "isFirstTime"
        static let gender = "gender"
        static let birthYear = "selectedBirthYear"
        static let heightCm = "selectedHeightCm"
        static let heightFt = "selectedHeightFt"
        static let heightInch = "selectedHeightInch"
        static let weightKg = "selectedWeightKg"
        static let targetWeightKg = "selectedTargetWeight"
        static let desiredBodyImage = "desiredBodyImage"
        static let selectedGoal = "selectedGoal"
        static let selectedTarget = "selectedTarget"
        static let selectedDietType = "selectedDietType"
        static let selectedLevelActivity = "selectedLevelActivity"
        static let selectedWorkoutLevel = "selectedWorkoutLevel"
        static let selectedHowOften = "selectedHowOften"
        static let selectedEquipmentType = "selectedEquipmentType"
        static let selectedEquipmentIndex = "selectedEquipmentIndex"
        static let selectedWorkoutLocation = "selectedWorkoutLocation"
        static let workoutLocationIndex = "workoutLocationIndex"
        static let totalWorkouts = "total_workouts"
        static let currentStreak = "current_streak"
        static let achievedGoals = "achieved_goals"
        static let currentBMI = "currentBMI"
        static let kilosToLose = "kilosToLose"
        static let subscriptionPlan = "subscription_plan"
        static let subscriptionExpirationDate = "subscription_expiration_date"
        static let isSubscriptionActive = "is_subscription_active"
    }
} 