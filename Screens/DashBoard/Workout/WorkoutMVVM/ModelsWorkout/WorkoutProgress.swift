import Foundation

/// Estados de progreso de un workout
enum WorkoutProgress: String, CaseIterable, Codable {
    case none = "none"
    case partial = "partial"
    case complete = "complete"
    
    var displayName: String {
        switch self {
        case .none: return "Not Started"
        case .partial: return "In Progress"
        case .complete: return "Completed"
        }
    }
    
    var percentage: Double {
        switch self {
        case .none: return 0.0
        case .partial: return 0.5
        case .complete: return 1.0
        }
    }
    
    var color: String {
        switch self {
        case .none: return "gray"
        case .partial: return "orange"
        case .complete: return "green"
        }
    }
    
    var estimatedMinutes: Int {
        switch self {
        case .none: return 0
        case .partial: return 15
        case .complete: return 30
        }
    }
}

/// Estadísticas de workout
struct WorkoutStats {
    let totalExercises: Int
    let totalMuscleGroups: Int
    let selectedMuscle: String
    let workoutMode: String
}

/// Estadísticas semanales
struct WeeklyStats {
    let totalWorkouts: Int
    let completedWorkouts: Int
    let totalMinutes: Int
    let workoutDays: Int
    let completionRate: Double
    
    var averageMinutesPerWorkout: Double {
        guard totalWorkouts > 0 else { return 0.0 }
        return Double(totalMinutes) / Double(totalWorkouts)
    }
    
    var averageMinutesPerDay: Double {
        guard workoutDays > 0 else { return 0.0 }
        return Double(totalMinutes) / Double(workoutDays)
    }
}

/// Estadísticas mensuales
struct MonthlyStats {
    let totalWorkouts: Int
    let completedWorkouts: Int
    let totalMinutes: Int
    let completionRate: Double
}

 