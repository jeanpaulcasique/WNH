// MARK: - WNHApp.swift (Actualizado para forzar fondo negro)
import SwiftUI

@main
struct WNHApp: App {
    // ✅ OPTIMIZACIÓN: Solo inicializar ViewModels esenciales
    @StateObject private var sessionManager = UserSessionManager()
    
    // ✅ OPTIMIZACIÓN: Lazy loading de ViewModels pesados
    @State private var dietViewModel: DietViewModel?
    

    
    // AppDelegate para manejar notificaciones
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ZStack {
                // Fondo negro con gradiente
                Color.appBackgroundGradient
                    .ignoresSafeArea()
                
                Group {
                    if sessionManager.isLoggedIn {
                        if sessionManager.shouldShowOnboarding {
                            // Mostrar onboarding si el usuario no lo ha completado
                            // Por ahora, mostrar la primera vista del onboarding
                            GenderSelectionView(
                                viewModel: GenderSelectionViewModel()
                            )
                            .environmentObject(sessionManager)
                        } else {
                            // Mostrar dashboard si ya completó el onboarding
                            DashboardView()
                                .environmentObject(dietViewModel ?? DietViewModel())
                                .onAppear {
                                    // ✅ OPTIMIZACIÓN: Cargar ViewModels solo cuando se necesiten
                                    if dietViewModel == nil {
                                        dietViewModel = DietViewModel()
                                        // Solo programar notificaciones cuando se crea el ViewModel
                                        dietViewModel?.startWaterRemindersThreeTimes()
                                    }
                                    
                                    if let dietVM = dietViewModel {
                                        Task {
                                            await dietVM.loadHeavyDataIfNeeded()
                                        }
                                    }
                                }
                        }
                    } else {
                        LoginView(viewModel: LoginViewModel())
                    }
                }
            }
            .environmentObject(sessionManager)

            .preferredColorScheme(.dark)
            .onAppear {
                // ✅ La app ahora recuerda la sesión del usuario
                // sessionManager.resetUserData() // Comentado para mantener la sesión
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
                // Manejar notificaciones cuando la app se activa
                handleNotificationIfNeeded()
            }
        }
    }
    
    // MARK: - Notification Handling
    
    private func handleNotificationIfNeeded() {
        // Verificar si hay una notificación pendiente de manejar
        if let notificationData = UserDefaults.standard.object(forKey: "pendingNotification") as? [String: Any] {
            // Limpiar la notificación pendiente
            UserDefaults.standard.removeObject(forKey: "pendingNotification")
            
            // Navegar a DietView si es una notificación de agua
            if let screen = notificationData["screen"] as? String, screen == "diet" {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    // Navegar a DietView
                    navigateToDietView()
                }
            }
        }
    }
    
    private func navigateToDietView() {
        // Navegar a DietView usando NotificationCenter para comunicar con DashboardView
        NotificationCenter.default.post(
            name: Notification.Name("NavigateToDietTab"),
            object: nil
        )
        print("🚰 Notificación enviada para navegar a DietView")
    }
}

// MARK: - Ejemplo de Vista CON problema de fondo (ANTES)
struct ProblematicView: View {
    var body: some View {
        VStack {
            Text("Esta vista no tiene fondo negro")
                .foregroundColor(.appTextPrimary)
        }
        // ❌ PROBLEMA: No hay fondo definido
    }
}

// MARK: - Ejemplo de Vista CORREGIDA (DESPUÉS)
struct FixedView: View {
    var body: some View {
        VStack {
            Text("Esta vista ahora tiene fondo negro")
                .foregroundColor(.appTextPrimary)
        }
        .blackGradientBackground() // ✅ SOLUCIÓN: Aplicar el modificador
    }
}

// MARK: - Ejemplo alternativo usando ZStack manual
struct ManualFixedView: View {
    var body: some View {
        ZStack {
            // ✅ FONDO NEGRO MANUAL
            Color.appBlack
                .ignoresSafeArea(.all)
            
            VStack {
                Text("Vista con fondo negro manual")
                    .foregroundColor(.appTextPrimary)
            }
        }
    }
}

// MARK: - ViewModifier para Fondo Consistente
struct BlackBackgroundModifier: ViewModifier {
    func body(content: Content) -> some View {
        ZStack {
            // 🔥 FUERZA FONDO NEGRO EN TODA LA VISTA
            Color.appBlack
                .ignoresSafeArea(.all)
            
            content
        }
        .background(Color.appBlack)
        .preferredColorScheme(.dark)
    }
}
