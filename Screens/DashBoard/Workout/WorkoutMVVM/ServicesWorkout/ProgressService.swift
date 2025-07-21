import Foundation
import Combine

// MARK: - WorkoutProgressWorkout Enum
/// Estados de progreso de un workout
enum WorkoutProgressWorkout: String, CaseIterable, Codable {
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

/// Servicio que maneja el tracking y persistencia del progreso de workouts
class ProgressService: ObservableObject {
    
    // MARK: - Published Properties
    @Published var dailyProgress: [String: WorkoutProgressWorkout] = [:]
    @Published var weeklyStats: WeeklyStats = WeeklyStats(
        totalWorkouts: 0,
        completedWorkouts: 0,
        totalMinutes: 0,
        workoutDays: 0,
        completionRate: 0.0
    )
    @Published var currentStreak: Int = 0
    @Published var longestStreak: Int = 0
    
    // MARK: - Private Properties
    private let userDefaults = UserDefaults.standard
    private let progressKey = "workoutProgress"
    private let streakKey = "workoutStreak"
    private let longestStreakKey = "longestWorkoutStreak"
    
    // MARK: - Initialization
    
    init() {
        loadProgress()
        calculateWeeklyStats()
        calculateStreaks()
    }
    
    // MARK: - Public Methods
    
    /// Actualiza el progreso para una fecha específica
    func updateProgress(for date: Date, progress: WorkoutProgressWorkout) {
        let dateKey = dateFormatter.string(from: date)
        dailyProgress[dateKey] = progress
        saveProgress()
        calculateWeeklyStats()
        calculateStreaks()
    }
    
    /// Obtiene el progreso para una fecha específica
    func getProgress(for date: Date) -> WorkoutProgressWorkout {
        let dateKey = dateFormatter.string(from: date)
        return dailyProgress[dateKey] ?? .none
    }
    
    /// Obtiene el progreso para una semana específica
    func getWeeklyProgress(for weekStart: Date) -> [WorkoutProgressWorkout] {
        let calendar = Calendar.current
        var progress: [WorkoutProgressWorkout] = []
        
        for dayOffset in 0..<7 {
            if let date = calendar.date(byAdding: .day, value: dayOffset, to: weekStart) {
                progress.append(getProgress(for: date))
            }
        }
        
        return progress
    }
    
    /// Calcula el porcentaje de completitud para una fecha
    func getCompletionPercentage(for date: Date) -> Double {
        let progress = getProgress(for: date)
        switch progress {
        case .none: return 0.0
        case .partial: return 0.5
        case .complete: return 1.0
        }
    }
    
    /// Obtiene estadísticas del mes actual
    func getMonthlyStats() -> MonthlyStats {
        let calendar = Calendar.current
        let now = Date()
        let monthStart = calendar.dateInterval(of: .month, for: now)?.start ?? now
        
        var totalWorkouts = 0
        var completedWorkouts = 0
        var totalMinutes = 0
        
        for dayOffset in 0..<31 {
            guard let date = calendar.date(byAdding: .day, value: dayOffset, to: monthStart) else { continue }
            
            if calendar.isDate(date, equalTo: now, toGranularity: .month) {
                let progress = getProgress(for: date)
                if progress != .none {
                    totalWorkouts += 1
                    if progress == .complete {
                        completedWorkouts += 1
                    }
                    totalMinutes += progress.estimatedMinutes
                }
            }
        }
        
        return MonthlyStats(
            totalWorkouts: totalWorkouts,
            completedWorkouts: completedWorkouts,
            totalMinutes: totalMinutes,
            completionRate: totalWorkouts > 0 ? Double(completedWorkouts) / Double(totalWorkouts) : 0.0
        )
    }
    
    /// Resetea el progreso para una fecha específica
    func resetProgress(for date: Date) {
        let dateKey = dateFormatter.string(from: date)
        dailyProgress.removeValue(forKey: dateKey)
        saveProgress()
        calculateWeeklyStats()
        calculateStreaks()
    }
    
    /// Exporta el progreso como datos
    func exportProgress() -> Data? {
        let exportData = ProgressExport(
            dailyProgress: dailyProgress,
            currentStreak: currentStreak,
            longestStreak: longestStreak,
            exportDate: Date()
        )
        
        return try? JSONEncoder().encode(exportData)
    }
    
    /// Importa progreso desde datos
    func importProgress(from data: Data) -> Bool {
        guard let exportData = try? JSONDecoder().decode(ProgressExport.self, from: data) else {
            return false
        }
        
        dailyProgress = exportData.dailyProgress
        currentStreak = exportData.currentStreak
        longestStreak = exportData.longestStreak
        saveProgress()
        calculateWeeklyStats()
        
        return true
    }
    
    // MARK: - Private Methods
    
    private func loadProgress() {
        if let data = userDefaults.data(forKey: progressKey),
           let progress = try? JSONDecoder().decode([String: WorkoutProgressWorkout].self, from: data) {
            dailyProgress = progress
        }
        
        currentStreak = userDefaults.integer(forKey: streakKey)
        longestStreak = userDefaults.integer(forKey: longestStreakKey)
    }
    
    private func saveProgress() {
        if let data = try? JSONEncoder().encode(dailyProgress) {
            userDefaults.set(data, forKey: progressKey)
        }
        
        userDefaults.set(currentStreak, forKey: streakKey)
        userDefaults.set(longestStreak, forKey: longestStreakKey)
    }
    
    private func calculateWeeklyStats() {
        let calendar = Calendar.current
        let now = Date()
        let weekStart = calendar.dateInterval(of: .weekOfYear, for: now)?.start ?? now
        
        var totalWorkouts = 0
        var completedWorkouts = 0
        var totalMinutes = 0
        var workoutDays = 0
        
        for dayOffset in 0..<7 {
            guard let date = calendar.date(byAdding: .day, value: dayOffset, to: weekStart) else { continue }
            
            let progress = getProgress(for: date)
            if progress != .none {
                workoutDays += 1
                totalWorkouts += 1
                if progress == .complete {
                    completedWorkouts += 1
                }
                totalMinutes += progress.estimatedMinutes
            }
        }
        
        weeklyStats = WeeklyStats(
            totalWorkouts: totalWorkouts,
            completedWorkouts: completedWorkouts,
            totalMinutes: totalMinutes,
            workoutDays: workoutDays,
            completionRate: totalWorkouts > 0 ? Double(completedWorkouts) / Double(totalWorkouts) : 0.0
        )
    }
    
    private func calculateStreaks() {
        let calendar = Calendar.current
        let now = Date()
        var currentDate = now
        var streak = 0
        
        // Calcular streak actual
        while true {
            let progress = getProgress(for: currentDate)
            if progress != .none {
                streak += 1
                currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate) ?? currentDate
            } else {
                break
            }
        }
        
        currentStreak = streak
        
        // Actualizar longest streak si es necesario
        if currentStreak > longestStreak {
            longestStreak = currentStreak
        }
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }
}

// MARK: - Supporting Models

struct WeeklyStats {
    let totalWorkouts: Int
    let completedWorkouts: Int
    let totalMinutes: Int
    let workoutDays: Int
    let completionRate: Double
    
    var averageMinutesPerWorkout: Double {
        totalWorkouts > 0 ? Double(totalMinutes) / Double(totalWorkouts) : 0.0
    }
    
    var averageMinutesPerDay: Double {
        workoutDays > 0 ? Double(totalMinutes) / Double(workoutDays) : 0.0
    }
}

struct MonthlyStats {
    let totalWorkouts: Int
    let completedWorkouts: Int
    let totalMinutes: Int
    let completionRate: Double
    
    var averageMinutesPerWorkout: Double {
        totalWorkouts > 0 ? Double(totalMinutes) / Double(totalWorkouts) : 0.0
    }
    
    var averageWorkoutsPerWeek: Double {
        Double(totalWorkouts) / 4.33 // Promedio de semanas en un mes
    }
}

struct ProgressExport: Codable {
    let dailyProgress: [String: WorkoutProgressWorkout]
    let currentStreak: Int
    let longestStreak: Int
    let exportDate: Date
} 