import SwiftUI

// MARK: - App Theme Colors
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

// MARK: - Color Extension (Main App Colors)
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
    static let appInfo = AppTheme.info
    
    // MARK: - Profile Specific Colors
    static let lightGold = Color(red: 1.0, green: 0.84, blue: 0.0)
    static let lightMint = Color(red: 0.0, green: 1.0, blue: 0.8)
    static let lightTeal = Color(red: 0.0, green: 0.5, blue: 0.5)
    
    // MARK: - Additional Utility Colors
    static let appGray = Color.gray
    static let appGrayLight = Color.gray.opacity(0.3)
    static let appGrayMedium = Color.gray.opacity(0.5)
    static let appGrayDark = Color.gray.opacity(0.7)
    
    // MARK: - Gradient Colors
    static let appYellowLight = appYellow.opacity(0.8)
    static let appYellowMedium = appYellow.opacity(0.6)
    static let appYellowDark = appYellow.opacity(0.4)
    static let appYellowVeryLight = appYellow.opacity(0.2)
    static let appYellowVeryDark = appYellow.opacity(0.1)
    
    // MARK: - Background Gradients
    static let appBackgroundGradient = LinearGradient(
        colors: [appBlack, appGrayLight, appBlack],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let appYellowGradient = LinearGradient(
        colors: [appYellow, appYellowLight],
        startPoint: .leading,
        endPoint: .trailing
    )
    
    static let appYellowGradientLight = LinearGradient(
        colors: [appYellowMedium, appYellowVeryLight],
        startPoint: .leading,
        endPoint: .trailing
    )
}

// MARK: - Color Utilities
extension Color {
    /// Returns a color with the specified opacity
    func withOpacity(_ opacity: Double) -> Color {
        return self.opacity(opacity)
    }
    
    /// Returns a lighter version of the color
    func lighter(by percentage: CGFloat = 0.2) -> Color {
        return self.opacity(1.0 - percentage)
    }
    
    /// Returns a darker version of the color
    func darker(by percentage: CGFloat = 0.2) -> Color {
        return self.opacity(1.0 + percentage)
    }
}
