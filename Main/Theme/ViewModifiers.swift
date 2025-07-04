import SwiftUI

// MARK: - ViewModifier para Fondo Negro con Gradiente
struct BlackGradientBackgroundModifier: ViewModifier {
    func body(content: Content) -> some View {
        ZStack {
            // Fondo negro con gradiente
            Color.appBackgroundGradient
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

// MARK: - Optimización de Rendimiento

/// Modificador para optimizar ScrollViews
struct OptimizedScrollViewModifier: ViewModifier {
    func body(content: Content) -> some View {
        ScrollView(showsIndicators: false) {
            content
        }
        .scrollDismissesKeyboard(.immediately)
        .scrollIndicators(.hidden)
    }
}

/// Modificador para limpiar recursos cuando la vista desaparece
struct ResourceCleanupModifier: ViewModifier {
    let cleanup: () -> Void
    
    func body(content: Content) -> some View {
        content
            .onDisappear {
                cleanup()
            }
    }
}

/// Modificador para optimizar animaciones
struct OptimizedAnimationModifier: ViewModifier {
    let isEnabled: Bool
    let animation: Animation
    
    func body(content: Content) -> some View {
        content
            .animation(isEnabled ? animation : nil, value: isEnabled)
    }
}

// MARK: - Extensiones para facilitar el uso

extension View {
    /// Aplica optimizaciones de ScrollView
    func optimizedScrollView() -> some View {
        modifier(OptimizedScrollViewModifier())
    }
    
    /// Aplica limpieza de recursos
    func withResourceCleanup(_ cleanup: @escaping () -> Void) -> some View {
        modifier(ResourceCleanupModifier(cleanup: cleanup))
    }
    
    /// Aplica animación optimizada
    func optimizedAnimation(_ animation: Animation, isEnabled: Bool = true) -> some View {
        modifier(OptimizedAnimationModifier(isEnabled: isEnabled, animation: animation))
    }
}

// MARK: - Cache Manager para optimizar cálculos pesados

class PerformanceCache {
    static let shared = PerformanceCache()
    
    private var cache: [String: Any] = [:]
    private let queue = DispatchQueue(label: "com.wnh.cache", qos: .userInitiated)
    
    private init() {}
    
    func set<T>(_ value: T, forKey key: String) {
        queue.async {
            self.cache[key] = value
        }
    }
    
    func get<T>(forKey key: String) -> T? {
        return queue.sync {
            return cache[key] as? T
        }
    }
    
    func clear() {
        queue.async {
            self.cache.removeAll()
        }
    }
    
    func remove(forKey key: String) {
        queue.async {
            self.cache.removeValue(forKey: key)
        }
    }
}

// MARK: - Memory Management Helper

class MemoryManager {
    static let shared = MemoryManager()
    
    private var activeTimers: [Timer] = []
    private var activeAnimations: [String: Bool] = [:]
    
    private init() {}
    
    func registerTimer(_ timer: Timer) {
        activeTimers.append(timer)
    }
    
    func unregisterTimer(_ timer: Timer) {
        timer.invalidate()
        activeTimers.removeAll { $0 === timer }
    }
    
    func clearAllTimers() {
        activeTimers.forEach { $0.invalidate() }
        activeTimers.removeAll()
    }
    
    func startAnimation(for key: String) {
        activeAnimations[key] = true
    }
    
    func stopAnimation(for key: String) {
        activeAnimations[key] = false
    }
    
    func clearAllAnimations() {
        activeAnimations.removeAll()
    }
} 
