import Foundation
import SwiftUI
import UIKit
import FirebaseAuth
import FirebaseCore
import FirebaseFirestore
#if canImport(GoogleSignIn)
import GoogleSignIn
#endif
#if canImport(FBSDKLoginKit)
import FBSDKLoginKit
#endif

final class FirebaseAuthService {
    enum AuthServiceError: LocalizedError {
        case firebaseNotConfigured
        case sdkNotInstalled(provider: String)
        case missingClientID
        case couldNotGetPresentingViewController
        case cancelledByUser

        var errorDescription: String? {
            switch self {
            case .firebaseNotConfigured:
                return "Firebase is not configured. Add GoogleService-Info.plist to the app target."
            case .sdkNotInstalled(let provider):
                return "\(provider) SDK is not installed. The app will continue running without that provider."
            case .missingClientID:
                return "Missing Firebase clientID for Google Sign-In."
            case .couldNotGetPresentingViewController:
                return "Could not present authentication screen."
            case .cancelledByUser:
                return "Sign in was cancelled."
            }
        }
    }

    static let shared = FirebaseAuthService()

    private var authStateListener: AuthStateDidChangeListenerHandle?
    private init() {}

    var isConfigured: Bool {
        FirebaseApp.app() != nil
    }

    var currentUser: User? {
        guard isConfigured else { return nil }
        return Auth.auth().currentUser
    }

    func startAuthStateListener(
        onSignedIn: @escaping (User) -> Void,
        onSignedOut: @escaping () -> Void
    ) {
        guard isConfigured else {
            onSignedOut()
            return
        }
        stopAuthStateListener()
        authStateListener = Auth.auth().addStateDidChangeListener { _, user in
            if let user {
                onSignedIn(user)
            } else {
                onSignedOut()
            }
        }
    }

    func stopAuthStateListener() {
        guard let authStateListener else { return }
        Auth.auth().removeStateDidChangeListener(authStateListener)
        self.authStateListener = nil
    }

    func register(email: String, password: String) async throws -> User {
        guard isConfigured else {
            throw AuthServiceError.firebaseNotConfigured
        }
        return try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<User, Error>) in
            Auth.auth().createUser(withEmail: email, password: password) { result, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }

                guard let user = result?.user else {
                    continuation.resume(throwing: NSError(
                        domain: "FirebaseAuthService",
                        code: -1,
                        userInfo: [NSLocalizedDescriptionKey: "Account could not be created."]
                    ))
                    return
                }

                continuation.resume(returning: user)
            }
        }
    }

    func signIn(email: String, password: String) async throws -> User {
        guard isConfigured else {
            throw AuthServiceError.firebaseNotConfigured
        }
        return try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<User, Error>) in
            Auth.auth().signIn(withEmail: email, password: password) { result, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }

                guard let user = result?.user else {
                    continuation.resume(throwing: NSError(
                        domain: "FirebaseAuthService",
                        code: -1,
                        userInfo: [NSLocalizedDescriptionKey: "Sign in failed."]
                    ))
                    return
                }

                continuation.resume(returning: user)
            }
        }
    }

    func sendPasswordReset(email: String) async throws {
        guard isConfigured else {
            throw AuthServiceError.firebaseNotConfigured
        }
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            Auth.auth().sendPasswordReset(withEmail: email) { error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }
                continuation.resume(returning: ())
            }
        }
    }

    func signInWithApple(idToken: String, nonce: String) async throws -> User {
        guard isConfigured else {
            throw AuthServiceError.firebaseNotConfigured
        }

        let credential = OAuthProvider.credential(
            providerID: .apple,
            idToken: idToken,
            rawNonce: nonce
        )

        return try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<User, Error>) in
            Auth.auth().signIn(with: credential) { result, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }

                guard let user = result?.user else {
                    continuation.resume(throwing: NSError(
                        domain: "FirebaseAuthService",
                        code: -1,
                        userInfo: [NSLocalizedDescriptionKey: "Apple sign in failed."]
                    ))
                    return
                }

                continuation.resume(returning: user)
            }
        }
    }

    func signInWithGoogle() async throws -> User {
        guard isConfigured else {
            throw AuthServiceError.firebaseNotConfigured
        }

        #if canImport(GoogleSignIn)
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            throw AuthServiceError.missingClientID
        }
        guard let presenting = topViewController() else {
            throw AuthServiceError.couldNotGetPresentingViewController
        }

        GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientID)
        let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: presenting)

        guard let idTokenString = result.user.idToken?.tokenString else {
            throw NSError(
                domain: "FirebaseAuthService",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Could not obtain Google token."]
            )
        }

        let credential = GoogleAuthProvider.credential(
            withIDToken: idTokenString,
            accessToken: result.user.accessToken.tokenString
        )

        return try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<User, Error>) in
            Auth.auth().signIn(with: credential) { result, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }

                guard let user = result?.user else {
                    continuation.resume(throwing: NSError(
                        domain: "FirebaseAuthService",
                        code: -1,
                        userInfo: [NSLocalizedDescriptionKey: "Google sign in failed."]
                    ))
                    return
                }
                continuation.resume(returning: user)
            }
        }
        #else
        throw AuthServiceError.sdkNotInstalled(provider: "Google")
        #endif
    }

    func signInWithFacebook() async throws -> User {
        guard isConfigured else {
            throw AuthServiceError.firebaseNotConfigured
        }

        #if canImport(FBSDKLoginKit)
        guard let presenting = topViewController() else {
            throw AuthServiceError.couldNotGetPresentingViewController
        }

        let manager = LoginManager()
        let token = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<String, Error>) in
            manager.logIn(permissions: ["public_profile", "email"], from: presenting) { result, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }

                if let result = result, result.isCancelled {
                    continuation.resume(throwing: AuthServiceError.cancelledByUser)
                    return
                }

                guard let tokenString = AccessToken.current?.tokenString else {
                    continuation.resume(throwing: NSError(
                        domain: "FirebaseAuthService",
                        code: -1,
                        userInfo: [NSLocalizedDescriptionKey: "Could not obtain Facebook token."]
                    ))
                    return
                }
                continuation.resume(returning: tokenString)
            }
        }

        let credential = FacebookAuthProvider.credential(withAccessToken: token)
        return try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<User, Error>) in
            Auth.auth().signIn(with: credential) { result, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }

                guard let user = result?.user else {
                    continuation.resume(throwing: NSError(
                        domain: "FirebaseAuthService",
                        code: -1,
                        userInfo: [NSLocalizedDescriptionKey: "Facebook sign in failed."]
                    ))
                    return
                }
                continuation.resume(returning: user)
            }
        }
        #else
        throw AuthServiceError.sdkNotInstalled(provider: "Facebook")
        #endif
    }

    func signOut() throws {
        guard isConfigured else { return }
        try Auth.auth().signOut()
    }

    private func topViewController(
        base: UIViewController? = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first(where: { $0.isKeyWindow })?
            .rootViewController
    ) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            return topViewController(base: tab.selectedViewController)
        }
        if let presented = base?.presentedViewController {
            return topViewController(base: presented)
        }
        return base
    }
}

final class FirestoreUserProfileService {
    static let shared = FirestoreUserProfileService()
    private init() {}

    func upsertBasicProfile(user: User) async throws {
        guard FirebaseApp.app() != nil else { return }

        let db = Firestore.firestore()
        let payload: [String: Any] = [
            "uid": user.uid,
            "email": user.email ?? "",
            "displayName": user.displayName ?? "",
            "providerIDs": user.providerData.map { $0.providerID },
            "lastLoginAt": FieldValue.serverTimestamp(),
            "updatedAt": FieldValue.serverTimestamp()
        ]

        try await db.collection("users").document(user.uid).setData(payload, merge: true)
    }
}

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
    private let authService = FirebaseAuthService.shared
    
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

        syncAuthStateFromFirebase()
        startAuthListener()
    }

    deinit {
        authService.stopAuthStateListener()
    }
    
    // MARK: - Public Methods
    
    /// Marca al usuario como conectado.
    func login() {
        persistLoggedInState(true)
    }
    
    /// Cierra la sesión del usuario pero mantiene el progreso de onboarding.
    func logout() {
        do {
            try authService.signOut()
        } catch {
            print("Error cerrando sesion Firebase: \(error.localizedDescription)")
        }
        persistLoggedInState(false)
        // NO borramos hasCompletedOnboarding para que mantenga el progreso
        
        // Limpiar datos de autorización de HealthKit al hacer logout
        let healthKitPersistence = HealthKitPersistenceService()
        healthKitPersistence.clearAuthorizationData()
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
        
        // Limpiar datos de autorización de HealthKit
        let healthKitPersistence = HealthKitPersistenceService()
        healthKitPersistence.clearAuthorizationData()
    }

    /// Actualiza estado local al autenticar con backend.
    func handleSuccessfulAuthentication(isNewUser: Bool) {
        persistLoggedInState(true)
        if isNewUser {
            UserDefaults.standard.set(false, forKey: hasCompletedOnboardingKey)
            UserDefaults.standard.set(true, forKey: isFirstTimeKey)
            hasCompletedOnboarding = false
            isFirstTime = true
        }
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

    private func startAuthListener() {
        authService.startAuthStateListener(
            onSignedIn: { [weak self] _ in
                DispatchQueue.main.async {
                    self?.persistLoggedInState(true)
                }
            },
            onSignedOut: { [weak self] in
                DispatchQueue.main.async {
                    self?.persistLoggedInState(false)
                }
            }
        )
    }

    private func syncAuthStateFromFirebase() {
        if authService.currentUser != nil {
            persistLoggedInState(true)
        } else {
            persistLoggedInState(false)
        }
    }

    private func persistLoggedInState(_ value: Bool) {
        UserDefaults.standard.set(value, forKey: isLoggedInKey)
        isLoggedIn = value
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

/// Manager centralizado para manejar toda la lógica dependiente del género del usuario
class UserManager: ObservableObject {
    
    // MARK: - Published Properties
    @Published var userProfile: UserProfile
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // MARK: - Private Properties
    private let userDefaults = UserDefaults.standard
    
    // MARK: - Initialization
    init() {
        self.userProfile = UserProfile()
        loadUserProfile()
    }
    
    // MARK: - Gender-Based Computed Properties
    
    /// Mensaje de bienvenida personalizado según género
    var welcomeMessage: String {
        switch userProfile.genderEnum {
        case .female:
            return "Welcome, athlete! Your fitness journey is tailored specifically for women."
        case .male:
            return "Welcome, athlete! Your fitness journey is tailored specifically for men."
        case .other:
            return "Welcome! Your fitness journey is personalized for you."
        case .notSet:
            return "Welcome! Let's personalize your fitness journey."
        }
    }
    
    /// Calorías recomendadas según género, edad y actividad
    var recommendedCalories: Int {
        let baseCalories: Int
        switch userProfile.genderEnum {
        case .female:
            baseCalories = 1800
        case .male:
            baseCalories = 2200
        case .other:
            baseCalories = 2000
        case .notSet:
            baseCalories = 2000
        }
        
        // Ajustar por edad
        let ageAdjustment = ageAdjustmentFactor
        let activityAdjustment = activityLevelAdjustmentFactor
        
        return Int(Double(baseCalories) * ageAdjustment * activityAdjustment)
    }
    
    /// Factor de ajuste por edad según género
    private var ageAdjustmentFactor: Double {
        guard let age = userProfile.age else { return 1.0 }
        
        switch userProfile.genderEnum {
        case .female:
            switch age {
            case 18..<30: return 1.0
            case 30..<45: return 0.95
            case 45..<60: return 0.9
            case 60...: return 0.85
            default: return 1.0
            }
        case .male:
            switch age {
            case 18..<30: return 1.05
            case 30..<45: return 1.0
            case 45..<60: return 0.95
            case 60...: return 0.9
            default: return 1.0
            }
        case .other, .notSet:
            return 1.0
        }
    }
    
    /// Factor de ajuste por nivel de actividad según género
    private var activityLevelAdjustmentFactor: Double {
        switch userProfile.genderEnum {
        case .female:
            switch userProfile.activityLevelEnum {
            case .sedentary: return 0.9
            case .lightlyActive: return 1.0
            case .active: return 1.1
            case .veryActive: return 1.2
            case .notSet: return 1.0
            }
        case .male:
            switch userProfile.activityLevelEnum {
            case .sedentary: return 0.95
            case .lightlyActive: return 1.0
            case .active: return 1.15
            case .veryActive: return 1.25
            case .notSet: return 1.0
            }
        case .other, .notSet:
            return 1.0
        }
    }
    
    /// Peso ideal según género y altura
    var idealWeight: Double {
        let heightInMeters = Double(userProfile.resolvedHeightCm) / 100.0
        let baseWeight = 22.0 * heightInMeters * heightInMeters
        
        switch userProfile.genderEnum {
        case .female:
            return baseWeight * 0.95
        case .male:
            return baseWeight * 1.05
        case .other, .notSet:
            return baseWeight
        }
    }
    
    /// Mensaje de motivación personalizado según género
    var motivationMessage: String {
        switch userProfile.genderEnum {
        case .female:
            return "You're building strength and confidence! Every workout brings you closer to your goals."
        case .male:
            return "You're building power and endurance! Every workout makes you stronger."
        case .other:
            return "You're building your best self! Every workout is progress."
        case .notSet:
            return "You're on your way to greatness! Every workout counts."
        }
    }
    
    /// Recomendaciones de entrenamiento según género
    var workoutRecommendations: [String] {
        switch userProfile.genderEnum {
        case .female:
            return [
                "Focus on strength training 2-3 times per week",
                "Include cardio for heart health",
                "Don't skip flexibility exercises",
                "Listen to your body's recovery needs"
            ]
        case .male:
            return [
                "Balance strength and cardio training",
                "Include mobility work to prevent injury",
                "Focus on compound movements",
                "Prioritize recovery and sleep"
            ]
        case .other, .notSet:
            return [
                "Find activities you enjoy",
                "Build a consistent routine",
                "Focus on overall health",
                "Celebrate your progress"
            ]
        }
    }
    
    /// Navegación condicional según género
    func getNextScreen() -> String {
        switch userProfile.genderEnum {
        case .female:
            return "FemaleWorkoutFlow"
        case .male:
            return "MaleWorkoutFlow"
        case .other, .notSet:
            return "GeneralWorkoutFlow"
        }
    }
    
    /// Configuración de notificaciones según género
    var notificationSettings: [String: Bool] {
        switch userProfile.genderEnum {
        case .female:
            return [
                "workout_reminders": true,
                "nutrition_tips": true,
                "recovery_reminders": true,
                "progress_updates": true
            ]
        case .male:
            return [
                "workout_reminders": true,
                "strength_progress": true,
                "performance_metrics": true,
                "goal_achievements": true
            ]
        case .other, .notSet:
            return [
                "workout_reminders": true,
                "general_tips": true,
                "progress_updates": true
            ]
        }
    }
    
    // MARK: - Profile Management
    
    /// Actualiza el perfil del usuario
    func updateProfile(_ newProfile: UserProfile) {
        userProfile = newProfile
        saveUserProfile()
    }
    
    /// Actualiza el género del usuario
    func updateGender(_ gender: Gender) {
        // Aquí necesitarías hacer el género mutable en UserProfile
        // Por ahora, esto es conceptual
        saveUserProfile()
    }
    
    /// Verifica si el perfil está completo
    var isProfileComplete: Bool {
        return userProfile.genderEnum != .notSet &&
               userProfile.weightKg > 0 &&
               userProfile.resolvedHeightCm > 0 &&
               userProfile.age != nil
    }
    
    /// Obtiene el progreso de completitud del perfil
    var profileCompletionPercentage: Double {
        var completedFields = 0
        let totalFields = 5
        
        if userProfile.genderEnum != .notSet { completedFields += 1 }
        if userProfile.weightKg > 0 { completedFields += 1 }
        if userProfile.resolvedHeightCm > 0 { completedFields += 1 }
        if userProfile.age != nil { completedFields += 1 }
        if userProfile.goal != "Not Set" { completedFields += 1 }
        
        return Double(completedFields) / Double(totalFields)
    }
    
    // MARK: - Private Methods
    
    private func loadUserProfile() {
        userProfile = UserProfile()
    }
    
    private func saveUserProfile() {
        // Aquí implementarías la lógica de guardado
        // Por ahora es conceptual
    }
    
    // MARK: - Static Methods
    
    /// Carga el perfil desde UserDefaults
    static func loadFromUserDefaults() -> UserProfile {
        return UserProfile()
    }
}

// MARK: - Extensions for Gender-Specific Logic

extension UserManager {
    
    /// Obtiene el color de tema según género
    var themeColor: Color {
        switch userProfile.genderEnum {
        case .female:
            return .pink
        case .male:
            return .blue
        case .other, .notSet:
            return .purple
        }
    }
    
    /// Obtiene el icono de avatar según género
    var avatarIcon: String {
        switch userProfile.genderEnum {
        case .female:
            return "person.fill"
        case .male:
            return "person.fill"
        case .other, .notSet:
            return "person.circle.fill"
        }
    }
    
    /// Obtiene el mensaje de logro según género
    func getAchievementMessage(for achievement: String) -> String {
        switch userProfile.genderEnum {
        case .female:
            return "Amazing! You've achieved \(achievement). You're unstoppable! 💪"
        case .male:
            return "Incredible! You've achieved \(achievement). Keep pushing! 🔥"
        case .other, .notSet:
            return "Fantastic! You've achieved \(achievement). You're doing great! ⭐"
        }
    }
}
