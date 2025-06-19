import SwiftUI

// MARK: - ViewModifier para Fondo Negro con Gradiente
struct BlackGradientBackgroundModifier: ViewModifier {
    func body(content: Content) -> some View {
        ZStack {
            // Fondo negro con gradiente
            LinearGradient(
                colors: [Color.appBlack, Color.gray.opacity(0.3), Color.appBlack],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            content
        }
        .preferredColorScheme(.dark)
    }
}

// MARK: - ViewModifier para Consistencia General
struct AppThemeModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(AppTheme.background.ignoresSafeArea())
            .foregroundColor(.appTextPrimary)
            .preferredColorScheme(.dark)
    }
}

// MARK: - Extensiones de View
extension View {
    /// Aplica el fondo negro con gradiente a cualquier vista
    func blackGradientBackground() -> some View {
        modifier(BlackGradientBackgroundModifier())
    }
    
    /// Aplica el tema general de la app
    func appThemed() -> some View {
        modifier(AppThemeModifier())
    }
} 