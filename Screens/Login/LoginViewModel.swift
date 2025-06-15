import SwiftUI
import Combine

class LoginViewModel: ObservableObject {
    @Published var isLoggedIn: Bool = false
    @Published var errorMessage: String?
    @Published var showLoginOptions: Bool = false
    @Published var isLoading: Bool = false
    @Published var isLoadingLogin: Bool = false
    @Published var isDisabled: Bool = false
    @Published var navigateToFase1: Bool = false
    @Published var navigateToDashboard: Bool = false
    
    // MARK: - Login Actions
    
    /// Maneja el inicio para nuevo usuario
    func handleNewUserStart(sessionManager: UserSessionManager) {
        guard !isDisabled else { return }
        
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        isDisabled = true
        isLoading = true
        
        // Resetear cualquier dato previo
        sessionManager.resetUserData()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            sessionManager.login()
            
            // Nuevo usuario siempre va al onboarding
            print("Nuevo usuario → Navegando a Fase1")
            self.navigateToFase1 = true
            
            self.isLoading = false
            sessionManager.printCurrentState()
        }
    }
    
    /// Maneja el login para usuario existente
    func handleExistingUserLogin(sessionManager: UserSessionManager) {
        guard !isDisabled else { return }
        
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        isDisabled = true
        isLoadingLogin = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            // Verificar si hay datos de usuario guardados
            if UserDefaults.standard.bool(forKey: "hasCompletedOnboarding") {
                sessionManager.login()
                print("Usuario existente → Navegando a Dashboard")
                self.navigateToDashboard = true
            } else {
                print("No se encontraron datos de usuario previos")
                self.errorMessage = "No se encontró una sesión previa"
            }
            
            self.isLoadingLogin = false
            self.isDisabled = false
            sessionManager.printCurrentState()
        }
    }
    
    func resetButton() {
        isDisabled = false
        isLoading = false
        isLoadingLogin = false
        navigateToFase1 = false
        navigateToDashboard = false
    }
    
    func showExistingAccountOptions() {
        showLoginOptions = true
        print("Opciones de cuenta existente desplegadas")
    }
    
    func hideLoginOptions() {
        showLoginOptions = false
    }
    
    func signInWithApple(sessionManager: UserSessionManager) {
        handleSocialLogin(sessionManager: sessionManager, loginType: "Apple")
    }
    
    func signInWithGoogle(sessionManager: UserSessionManager) {
        handleSocialLogin(sessionManager: sessionManager, loginType: "Google")
    }
    
    func signInWithFacebook(sessionManager: UserSessionManager) {
        handleSocialLogin(sessionManager: sessionManager, loginType: "Facebook")
    }
    
    // MARK: - Utility Methods
    
    /// Resetea el estado de navegación
    func resetNavigationState() {
        navigateToFase1 = false
        navigateToDashboard = false
    }
    
    /// Maneja el logout completo
    func handleLogout(sessionManager: UserSessionManager) {
        // Primero reseteamos la navegación
        resetNavigationState()
        resetButton()
        
        // Luego hacemos logout y limpiamos el estado
        sessionManager.logout()
        
        print("Logout completado")
        sessionManager.printCurrentState()
    }
    
    /// Fuerza la navegación al onboarding
    func forceOnboardingFlow(sessionManager: UserSessionManager) {
        // Reset completo del usuario
        sessionManager.resetUserData()
        
        // Reset estados de navegación
        resetNavigationState()
        resetButton()
        
        // Login y forzar navegación a Fase1
        sessionManager.login()
        
        print("🔄 FORCE RESET: Navegando a Fase1/GenderSelection")
        navigateToFase1 = true
        
        // Haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
    }
    
    /// Para testing - simula un usuario existente
    func simulateExistingUser(sessionManager: UserSessionManager) {
        sessionManager.completeOnboarding()
        sessionManager.logout() // Lo deslogueamos para que pueda volver a entrar
        resetNavigationState()
        print("Simulando usuario existente")
    }
    
    func handleSocialLogin(sessionManager: UserSessionManager, loginType: String) {
        isLoading = true
        
        // Simular login social
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.isLoading = false
            
            if Bool.random() { // 50% éxito para simulación
                sessionManager.login()
                
                // Para login social, asumimos que ya tienen cuenta → ir a Dashboard
                print("Login social exitoso con \(loginType) → Navegando a Dashboard")
                self.navigateToDashboard = true
                self.hideLoginOptions()
                
                sessionManager.printCurrentState()
            } else {
                self.errorMessage = "Error en el inicio de sesión con \(loginType). Inténtalo de nuevo."
                print(self.errorMessage ?? "")
            }
        }
    }
}
