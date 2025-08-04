// MARK: - WNHApp.swift (Actualizado para forzar fondo negro)
import SwiftUI

@main
struct WNHApp: App {
    // ✅ OPTIMIZACIÓN: Solo inicializar ViewModels esenciales
    @StateObject private var sessionManager = UserSessionManager()
    
    // ✅ OPTIMIZACIÓN: Lazy loading de ViewModels pesados
    @State private var dietViewModel: DietViewModel?

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
                                    }
                                    dietViewModel?.startWaterRemindersThreeTimes()
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
                
                
                // 🔧 TEMPORAL: Resetear solo onboarding para testing (quitar en producción)
                #if DEBUG
                // sessionManager.resetOnboarding() // Descomenta esta línea si quieres forzar el onboarding
                #endif
            }
        }
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
