// MARK: - WNHApp.swift (Actualizado para forzar fondo negro)
import SwiftUI

@main
struct WNHApp: App {
    @StateObject private var sessionManager = UserSessionManager()
    @StateObject private var languageManager = LanguageManager()

    @State private var showOnboardingTransitions = false
    
    // AppDelegate para manejar notificaciones
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ZStack {
                // Fondo negro con gradiente
                Color.appBackgroundGradient
                    .ignoresSafeArea()
                
                Group {
                    if showOnboardingTransitions {
                        OnboardingTransitionsView()
                    } else {
                        appRootView
                    }
                }
            }
            .environmentObject(sessionManager)
            .environmentObject(languageManager)
            .environment(\.locale, Locale(identifier: languageManager.currentLanguage.rawValue))
            .preferredColorScheme(.dark)
            .onAppear {
                // Verificar si ya se mostraron las pantallas transicionales
                let hasSeenTransitions = UserDefaults.standard.bool(forKey: "hasSeenOnboardingTransitions")
                showOnboardingTransitions = !hasSeenTransitions
            }
            .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("OnboardingTransitionsCompleted"))) { _ in
                // Ocultar las pantallas transicionales cuando se completen
                withAnimation {
                    showOnboardingTransitions = false
                }
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

    @ViewBuilder
    private var appRootView: some View {
        if !sessionManager.isLoggedIn {
            LoginView()
        } else if sessionManager.shouldShowOnboarding {
            GenderSelectionView(viewModel: GenderSelectionViewModel())
        } else {
            DashboardView()
        }
    }
}

enum AppLanguage: String, CaseIterable, Identifiable {
    case english = "en"
    case spanish = "es"

    var id: String { rawValue }

    func displayName(for currentLanguage: AppLanguage) -> String {
        switch (self, currentLanguage) {
        case (.english, .spanish):
            return "Inglés"
        case (.spanish, .spanish):
            return "Español"
        case (.english, .english):
            return "English"
        case (.spanish, .english):
            return "Spanish"
        }
    }

    var nativeName: String {
        switch self {
        case .english:
            return "English"
        case .spanish:
            return "Español"
        }
    }
}

enum AppTextKey: String {
    case tabWorkout
    case tabDiet
    case tabTrainer
    case tabShop
    case tabMe

    case meMotivation
    case meYourProgress
    case meWorkouts
    case meCompleted
    case meStreak
    case meDays
    case meLevel
    case meFitness
    case meAccount
    case meSupportMore
    case meLogout
    case meLogoutCancel
    case meLogoutMessage
    case meUpgradePremium
    case menuSubscription
    case menuCoaches
    case menuAnalytics
    case menuWriteSupport
    case menuTellFriend
    case menuRateApp
    case menuSettings
    case comingSoon
    case comingSoonDescription

    case settingsTitle
    case settingsSubtitle
    case settingsProfile
    case settingsEditProfile
    case settingsEditProfileSubtitle
    case settingsPreferences
    case settingsLanguage
    case settingsNotifications
    case settingsNotificationsSubtitle
    case settingsDarkMode
    case settingsDarkModeSubtitle
    case settingsHealthFitness
    case settingsAppleHealth
    case settingsAppleHealthSubtitle
    case settingsSupport
    case settingsFAQ
    case settingsFAQSubtitle
    case settingsContactSupport
    case settingsContactSupportSubtitle
    case settingsAbout
    case settingsAppVersion
    case settingsLatest
    case settingsPrivacyPolicy
    case settingsPrivacyPolicySubtitle
    case settingsTerms
    case settingsTermsSubtitle

    case languageTitle
    case languageSubtitle
    case languageCurrent
    case languageSelected
    case languageInstant
}

final class LanguageManager: ObservableObject {
    static let storageKey = "appLanguageCode"

    @Published private(set) var currentLanguage: AppLanguage

    init() {
        let savedCode = UserDefaults.standard.string(forKey: Self.storageKey) ?? AppLanguage.english.rawValue
        currentLanguage = AppLanguage(rawValue: savedCode) ?? .english
    }

    func setLanguage(_ language: AppLanguage) {
        currentLanguage = language
        UserDefaults.standard.set(language.rawValue, forKey: Self.storageKey)
    }

    func text(_ key: AppTextKey) -> String {
        Self.translations[currentLanguage]?[key] ?? Self.translations[.english]?[key] ?? key.rawValue
    }

    func localized(_ key: String) -> String {
        Self.localizedString(key, language: currentLanguage)
    }

    static func localizedString(_ key: String, language: AppLanguage? = nil) -> String {
        let selectedLanguage: AppLanguage
        if let language {
            selectedLanguage = language
        } else {
            let savedCode = UserDefaults.standard.string(forKey: storageKey) ?? AppLanguage.english.rawValue
            selectedLanguage = AppLanguage(rawValue: savedCode) ?? .english
        }

        guard selectedLanguage != .english,
              let path = Bundle.main.path(forResource: selectedLanguage.rawValue, ofType: "lproj"),
              let bundle = Bundle(path: path) else {
            return key
        }

        return bundle.localizedString(forKey: key, value: key, table: nil)
    }

    func menuTitle(_ title: String) -> String {
        switch title {
        case "Subscription":
            return text(.menuSubscription)
        case "Coaches":
            return text(.menuCoaches)
        case "Analytics":
            return text(.menuAnalytics)
        case "Write to support":
            return text(.menuWriteSupport)
        case "Tell a friend":
            return text(.menuTellFriend)
        case "Rate the app":
            return text(.menuRateApp)
        case "Settings":
            return text(.menuSettings)
        default:
            return title
        }
    }

    func languageName(_ language: AppLanguage) -> String {
        language.displayName(for: currentLanguage)
    }

    private static let translations: [AppLanguage: [AppTextKey: String]] = [
        .english: [
            .tabWorkout: "Workout",
            .tabDiet: "Diet",
            .tabTrainer: "Trainer",
            .tabShop: "Shop",
            .tabMe: "Me",
            .meMotivation: "Ready to crush your fitness goals?",
            .meYourProgress: "Your Progress",
            .meWorkouts: "Workouts",
            .meCompleted: "completed",
            .meStreak: "Streak",
            .meDays: "days",
            .meLevel: "Level",
            .meFitness: "fitness",
            .meAccount: "Account",
            .meSupportMore: "Support & More",
            .meLogout: "Logout",
            .meLogoutCancel: "Cancel",
            .meLogoutMessage: "Are you sure you want to logout?",
            .meUpgradePremium: "Upgrade for premium features",
            .menuSubscription: "Subscription",
            .menuCoaches: "Coaches",
            .menuAnalytics: "Analytics",
            .menuWriteSupport: "Write to support",
            .menuTellFriend: "Tell a friend",
            .menuRateApp: "Rate the app",
            .menuSettings: "Settings",
            .comingSoon: "Coming Soon",
            .comingSoonDescription: "This feature is under development and will be available in a future update.",
            .settingsTitle: "Settings",
            .settingsSubtitle: "Customize your experience",
            .settingsProfile: "Profile",
            .settingsEditProfile: "Edit Profile",
            .settingsEditProfileSubtitle: "Update your personal information",
            .settingsPreferences: "Preferences",
            .settingsLanguage: "Language",
            .settingsNotifications: "Notifications",
            .settingsNotificationsSubtitle: "Get workout reminders",
            .settingsDarkMode: "Dark Mode",
            .settingsDarkModeSubtitle: "Always enabled for fitness focus",
            .settingsHealthFitness: "Health & Fitness",
            .settingsAppleHealth: "Apple Health",
            .settingsAppleHealthSubtitle: "Sync workouts and health data",
            .settingsSupport: "Support",
            .settingsFAQ: "FAQ",
            .settingsFAQSubtitle: "Frequently asked questions",
            .settingsContactSupport: "Contact Support",
            .settingsContactSupportSubtitle: "Get help from our team",
            .settingsAbout: "About",
            .settingsAppVersion: "App Version",
            .settingsLatest: "1.0.0 (Latest)",
            .settingsPrivacyPolicy: "Privacy Policy",
            .settingsPrivacyPolicySubtitle: "How we protect your data",
            .settingsTerms: "Terms of Service",
            .settingsTermsSubtitle: "Our terms and conditions",
            .languageTitle: "Language",
            .languageSubtitle: "Choose the language used across the app.",
            .languageCurrent: "Current language",
            .languageSelected: "Selected",
            .languageInstant: "The app updates immediately and remembers your choice."
        ],
        .spanish: [
            .tabWorkout: "Entreno",
            .tabDiet: "Dieta",
            .tabTrainer: "Entrenador",
            .tabShop: "Tienda",
            .tabMe: "Yo",
            .meMotivation: "¿Listo para romper tus metas fitness?",
            .meYourProgress: "Tu progreso",
            .meWorkouts: "Entrenos",
            .meCompleted: "completados",
            .meStreak: "Racha",
            .meDays: "días",
            .meLevel: "Nivel",
            .meFitness: "fitness",
            .meAccount: "Cuenta",
            .meSupportMore: "Soporte y más",
            .meLogout: "Cerrar sesión",
            .meLogoutCancel: "Cancelar",
            .meLogoutMessage: "¿Seguro que quieres cerrar sesión?",
            .meUpgradePremium: "Mejora para acceder a funciones premium",
            .menuSubscription: "Suscripción",
            .menuCoaches: "Coaches",
            .menuAnalytics: "Analíticas",
            .menuWriteSupport: "Escribir a soporte",
            .menuTellFriend: "Invitar a un amigo",
            .menuRateApp: "Valorar la app",
            .menuSettings: "Ajustes",
            .comingSoon: "Muy pronto",
            .comingSoonDescription: "Esta función está en desarrollo y estará disponible en una próxima actualización.",
            .settingsTitle: "Ajustes",
            .settingsSubtitle: "Personaliza tu experiencia",
            .settingsProfile: "Perfil",
            .settingsEditProfile: "Editar perfil",
            .settingsEditProfileSubtitle: "Actualiza tu información personal",
            .settingsPreferences: "Preferencias",
            .settingsLanguage: "Idioma",
            .settingsNotifications: "Notificaciones",
            .settingsNotificationsSubtitle: "Recibe recordatorios de entrenamiento",
            .settingsDarkMode: "Modo oscuro",
            .settingsDarkModeSubtitle: "Siempre activo para enfocarte en fitness",
            .settingsHealthFitness: "Salud y fitness",
            .settingsAppleHealth: "Apple Health",
            .settingsAppleHealthSubtitle: "Sincroniza entrenos y datos de salud",
            .settingsSupport: "Soporte",
            .settingsFAQ: "Preguntas frecuentes",
            .settingsFAQSubtitle: "Respuestas a las dudas comunes",
            .settingsContactSupport: "Contactar soporte",
            .settingsContactSupportSubtitle: "Recibe ayuda de nuestro equipo",
            .settingsAbout: "Acerca de",
            .settingsAppVersion: "Versión de la app",
            .settingsLatest: "1.0.0 (Actual)",
            .settingsPrivacyPolicy: "Política de privacidad",
            .settingsPrivacyPolicySubtitle: "Cómo protegemos tus datos",
            .settingsTerms: "Términos del servicio",
            .settingsTermsSubtitle: "Nuestros términos y condiciones",
            .languageTitle: "Idioma",
            .languageSubtitle: "Elige el idioma que se usará en la app.",
            .languageCurrent: "Idioma actual",
            .languageSelected: "Seleccionado",
            .languageInstant: "La app se actualiza al instante y recuerda tu elección."
        ]
    ]
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
