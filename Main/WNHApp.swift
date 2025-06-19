// MARK: - Model/Theme/AppTheme.swift
import SwiftUI

struct AppTheme {
    // MARK: - Brand Colors (Always consistent)
    static let primary = Color(red: 255/255, green: 204/255, blue: 0/255)     // Yellow
    static let background = Color(red: 0/255, green: 0/255, blue: 0/255)      // Black
    static let surface = Color(red: 28/255, green: 28/255, blue: 30/255)      // Dark Gray
    static let onPrimary = Color(red: 0/255, green: 0/255, blue: 0/255)       // Black on Yellow
    static let onBackground = Color(red: 255/255, green: 255/255, blue: 255/255) // White
    static let accent = Color(red: 255/255, green: 159/255, blue: 10/255)     // Orange accent
    
    // MARK: - Semantic Colors
    static let textPrimary = Color(red: 255/255, green: 255/255, blue: 255/255)
    static let textSecondary = Color(red: 174/255, green: 174/255, blue: 178/255)
    static let textTertiary = Color(red: 99/255, green: 99/255, blue: 102/255)
    
    // MARK: - Status Colors
    static let success = Color(red: 52/255, green: 199/255, blue: 89/255)
    static let warning = Color(red: 255/255, green: 149/255, blue: 0/255)
    static let error = Color(red: 255/255, green: 59/255, blue: 48/255)
    static let info = Color(red: 0/255, green: 122/255, blue: 255/255)
    
    // MARK: - Background Gradients
    static let primaryGradient = LinearGradient(
        colors: [background, surface, background],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let cardGradient = LinearGradient(
        colors: [surface.opacity(0.6), surface.opacity(0.3)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

// MARK: - Color Extension (Backward compatibility)
extension Color {
    // 🔥 COLORES PRINCIPALES - SIEMPRE CONSISTENTES
    static let appBlack = Color(red: 0/255, green: 0/255, blue: 0/255)
    static let appWhite = Color(red: 255/255, green: 255/255, blue: 255/255)
    static let appYellow = Color(red: 255/255, green: 204/255, blue: 0/255)
    
    // Nuevos colores semánticos usando AppTheme
    static let appSurface = AppTheme.surface
    static let appTextPrimary = AppTheme.textPrimary
    static let appTextSecondary = AppTheme.textSecondary
    static let appAccent = AppTheme.accent
    static let appSuccess = AppTheme.success
    static let appWarning = AppTheme.warning
    static let appError = AppTheme.error
}

// MARK: - WNHApp.swift (Actualizado para forzar fondo negro)
import SwiftUI

@main
struct WNHApp: App {
    @StateObject private var progressViewModel = ProgressViewModel()
    @StateObject private var sessionManager = UserSessionManager()
    @StateObject private var dietViewModel = DietViewModel()

    var body: some Scene {
        WindowGroup {
            ZStack {
                // Fondo negro con gradiente
                LinearGradient(
                    colors: [Color.appBlack, Color.gray.opacity(0.3), Color.appBlack],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                Group {
                    if sessionManager.isLoggedIn {
                        DashboardView()
                            .environmentObject(dietViewModel)
                            .onAppear {
                                dietViewModel.startWaterRemindersThreeTimes()
                            }
                    } else {
                        LoginView(viewModel: LoginViewModel())
                    }
                }
            }
            .environmentObject(progressViewModel)
            .environmentObject(sessionManager)
            .preferredColorScheme(.dark)
        }
    }
}

// MARK: - Ejemplo de Vista CON problema de fondo (ANTES)
struct ProblematicView: View {
    var body: some View {
        VStack {
            Text("Esta vista no tiene fondo negro")
                .foregroundColor(.white)
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
