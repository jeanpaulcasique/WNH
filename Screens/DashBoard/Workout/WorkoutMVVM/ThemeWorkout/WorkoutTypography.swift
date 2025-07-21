import SwiftUI

/// Tipografía específica para el módulo Workout
struct WorkoutTypography {
    // MARK: - Header Typography
    static let headerTitle = Font.system(size: 16, weight: .bold)
    static let headerIcon = Font.system(size: 22, weight: .bold)
    static let headerTip = Font.system(size: 12, weight: .medium)
    
    // MARK: - Calendar Typography
    static let calendarDayNumber = Font.system(size: 16, weight: .bold)
    static let calendarDayName = Font.caption2
    
    // MARK: - Button Typography
    static let buttonText = Font.system(size: 15, weight: .medium)
    static let muscleButtonText = Font.system(size: 15, weight: .medium)
    
    // MARK: - Character Typography
    static let characterLabel = Font.system(size: 13, weight: .semibold)
    
    // MARK: - Bottom Controls Typography
    static let bottomControlText = Font.system(size: 15, weight: .medium)
    
    // MARK: - Search Typography
    static let searchText = Font.body
    static let searchResultTitle = Font.headline
    static let searchResultSubtitle = Font.caption
    static let searchResultDetail = Font.caption2
    
    // MARK: - Location Menu Typography
    static let locationMenuText = Font.system(size: 15, weight: .semibold)
    
    // MARK: - Stats Typography
    static let statsValue = Font.system(size: 20, weight: .bold)
    static let statsLabel = Font.caption
} 