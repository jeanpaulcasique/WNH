import SwiftUI

/// Colores específicos para el módulo Workout
struct WorkoutColors {
    // MARK: - Primary Colors
    static let primary = Color.appYellow
    static let secondary = Color.appWhite
    static let background = Color.black
    
    // MARK: - Progress Colors
    static let progressRed = Color.red
    static let progressOrange = Color.orange
    static let progressGreen = Color.green
    static let progressGray = Color.gray.opacity(0.3)
    
    // MARK: - Card Colors
    static let cardBackground = Color.black.opacity(0.3)
    static let cardBorder = Color.appYellow.opacity(0.6)
    static let cardShadow = Color.appYellow.opacity(0.10)
    
    // MARK: - Text Colors
    static let textPrimary = Color.appWhite
    static let textSecondary = Color.appWhite.opacity(0.7)
    static let textAccent = Color.appYellow
    
    // MARK: - Button Colors
    static let buttonBackground = Color.black.opacity(0.85)
    static let buttonBorder = Color.appYellow.opacity(0.7)
    static let buttonShadow = Color.appYellow.opacity(0.15)
    
    // MARK: - Character Colors
    static let characterGlow = Color.appYellow.opacity(0.13)
    static let characterShadow = Color.black.opacity(0.18)
    
    // MARK: - Search Colors
    static let searchBackground = Color.white.opacity(0.08)
    static let searchText = Color.white
    static let searchPlaceholder = Color.gray
} 
