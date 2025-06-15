import Foundation
/// Gestiona el estado de sesión del usuario y el progreso de onboarding usando UserDefaults.
/// Métodos públicos: login(), logout(), completeOnboarding(), resetUserData()
final class UserSessionManager: ObservableObject {
    @Published var isLoggedIn: Bool
    @Published var hasCompletedOnboarding: Bool
    @Published var isFirstTime: Bool
    
    // Keys para UserDefaults
    private let isLoggedInKey = "isLoggedIn"
    private let hasCompletedOnboardingKey = "hasCompletedOnboarding"
    private let isFirstTimeKey = "isFirstTime"
    
    init() {
        // Registrar valores por defecto
        UserDefaults.standard.register(defaults: [
            isLoggedInKey: false,
            hasCompletedOnboardingKey: false,
            isFirstTimeKey: true
        ])
        
        // Carga inicial
        self.isLoggedIn = UserDefaults.standard.bool(forKey: isLoggedInKey)
        self.hasCompletedOnboarding = UserDefaults.standard.bool(forKey: hasCompletedOnboardingKey)
        self.isFirstTime = UserDefaults.standard.bool(forKey: isFirstTimeKey)
    }
    
    // MARK: - Public Methods
    
    /// Marca al usuario como conectado.
    func login() {
        UserDefaults.standard.set(true, forKey: isLoggedInKey)
        isLoggedIn = true
    }
    
    /// Cierra la sesión del usuario pero mantiene el progreso de onboarding.
    func logout() {
        UserDefaults.standard.set(false, forKey: isLoggedInKey)
        isLoggedIn = false
        // NO borramos hasCompletedOnboarding para que mantenga el progreso
    }
    
    /// Marca el onboarding como completado.
    func completeOnboarding() {
        UserDefaults.standard.set(true, forKey: hasCompletedOnboardingKey)
        UserDefaults.standard.set(false, forKey: isFirstTimeKey)
        hasCompletedOnboarding = true
        isFirstTime = false
    }
    
    /// Resetea todos los datos del usuario (útil para testing o reset completo).
    func resetUserData() {
        UserDefaults.standard.set(false, forKey: isLoggedInKey)
        UserDefaults.standard.set(false, forKey: hasCompletedOnboardingKey)
        UserDefaults.standard.set(true, forKey: isFirstTimeKey)
        
        isLoggedIn = false
        hasCompletedOnboarding = false
        isFirstTime = true
        
        // También puedes limpiar otros datos del usuario aquí
        clearUserProfileData()
    }
    
    /// Resetea solo el onboarding (para forzar que vuelva a pasar por el flujo).
    func resetOnboarding() {
        UserDefaults.standard.set(false, forKey: hasCompletedOnboardingKey)
        UserDefaults.standard.set(true, forKey: isFirstTimeKey)
        hasCompletedOnboarding = false
        isFirstTime = true
    }
    
    // MARK: - Computed Properties
    
    /// Determina si el usuario debe ir al onboarding o al dashboard.
    var shouldShowOnboarding: Bool {
        return !hasCompletedOnboarding || isFirstTime
    }
    
    /// Determina si el usuario está completamente configurado.
    var isUserSetupComplete: Bool {
        return isLoggedIn && hasCompletedOnboarding
    }
    
    // MARK: - Private Methods
    
    /// Limpia todos los datos del perfil del usuario.
    private func clearUserProfileData() {
        let userDataKeys = [
            "gender", "selectedHeightCm", "selectedHeightFt", "selectedHeightInch",
            "selectedWeightKg", "selectedTargetWeight", "selectedGoal", "selectedTarget",
            "equipmentPreference", "bodyCurrentImage", "desiredBodyImage",
            "selectedBirthYear", "selectedWorkoutLevel", "selectedLevelActivity",
            "selectedHowOften", "selectedDietType", "profile_image_data",
            "total_workouts", "current_streak", "achieved_goals",
            "user_subscription", "user_referral_code"
        ]
        
        userDataKeys.forEach { key in
            UserDefaults.standard.removeObject(forKey: key)
        }
    }
    
    // MARK: - Debug Helpers
    
    /// Imprime el estado actual para debugging.
    func printCurrentState() {
        print("=== UserSessionManager State ===")
        print("isLoggedIn: \(isLoggedIn)")
        print("hasCompletedOnboarding: \(hasCompletedOnboarding)")
        print("isFirstTime: \(isFirstTime)")
        print("shouldShowOnboarding: \(shouldShowOnboarding)")
        print("isUserSetupComplete: \(isUserSetupComplete)")
        print("================================")
    }
}
