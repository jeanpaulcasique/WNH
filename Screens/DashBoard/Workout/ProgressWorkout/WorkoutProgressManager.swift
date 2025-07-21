import Foundation
import SwiftUI

// MARK: - Progress State Enum

enum ProgressState: String, Codable {
    case none
    case partial
    case complete
}

// MARK: - Day Progress Model

struct DayProgress: Codable, Identifiable {
    let id = UUID()
    let date: Date
    var exercisesCompleted: Int
    var totalExercises: Int
    var videosWatched: Int
    var totalVideos: Int
    var steps: Int
    var caloriesBurned: Double
    var heartRate: Double // <-- Propiedad añadida
    var workoutDurationMinutes: Int
    var progress: ProgressState? // Opcional para compatibilidad
    
    var completionPercentage: Double {
        let totalTasks = totalExercises + totalVideos
        if totalTasks == 0 { return 0 }
        return Double(exercisesCompleted + videosWatched) / Double(totalTasks)
    }
    
    // Inicializador completo
    init(
        date: Date,
        exercisesCompleted: Int = 0,
        totalExercises: Int = 0,
        videosWatched: Int = 0,
        totalVideos: Int = 0,
        steps: Int = 0,
        caloriesBurned: Double = 0,
        heartRate: Double = 0,
        workoutDurationMinutes: Int = 0,
        progress: ProgressState? = nil
    ) {
        self.date = date
        self.exercisesCompleted = exercisesCompleted
        self.totalExercises = totalExercises
        self.videosWatched = videosWatched
        self.totalVideos = totalVideos
        self.steps = steps
        self.caloriesBurned = caloriesBurned
        self.heartRate = heartRate
        self.workoutDurationMinutes = workoutDurationMinutes
        self.progress = progress
    }
    
    static func empty(for date: Date) -> DayProgress {
        DayProgress(
            date: date,
            exercisesCompleted: 0,
            totalExercises: 5,
            videosWatched: 0,
            totalVideos: 3,
            steps: 0,
            caloriesBurned: 0,
            heartRate: 0 // <-- Valor por defecto
        )
    }
}

// MARK: - Workout Plan

struct WorkoutPlan {
    let totalDays: Int
    let exercisesPerDay: Int
    let videosPerDay: Int
    
    static let sample = WorkoutPlan(totalDays: 20, exercisesPerDay: 10, videosPerDay: 10)
}

// MARK: - Progress Manager

class WorkoutProgressManager: ObservableObject {
    @Published var currentWeekDays: [Date] = []
    @Published var progressData: [String: DayProgress] = [:]
    
    private let userDefaults = UserDefaults.standard
    private let progressKey = "WorkoutProgressData"
    
    init() {
        setupCurrentWeek()
        loadProgress()
    }
    
    private func setupCurrentWeek() {
        let calendar = Calendar.current
        let today = Date()
        let weekday = calendar.component(.weekday, from: today)
        let daysFromMonday = (weekday == 1) ? 6 : weekday - 2
        guard let startOfWeek = calendar.date(byAdding: .day, value: -daysFromMonday, to: today) else {
            return
        }
        currentWeekDays = (0..<7).compactMap { dayOffset in
            calendar.date(byAdding: .day, value: dayOffset, to: startOfWeek)
        }
    }
    
    private func dateKey(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
    
    func loadProgress() {
        if let data = userDefaults.data(forKey: progressKey),
           let decoded = try? JSONDecoder().decode([String: DayProgress].self, from: data) {
            progressData = decoded
        }
    }
    
    func saveProgress() {
        if let encoded = try? JSONEncoder().encode(progressData) {
            userDefaults.set(encoded, forKey: progressKey)
        }
    }
    
    func getProgress(for date: Date) -> DayProgress {
        let key = dateKey(for: date)
        return progressData[key] ?? DayProgress(date: date)
    }
    
    func updateProgress(for date: Date, progress: DayProgress) {
        let key = dateKey(for: date)
        progressData[key] = progress
        saveProgress()
    }
    
    // Método para simular progreso aleatorio (para testing)
    func generateSampleData() {
        let calendar = Calendar.current
        let today = Date()
        
        for i in 0..<7 {
            if let date = calendar.date(byAdding: .day, value: -i, to: today) {
                let dateKey = self.dateKey(for: date)
                
                let exercisesCompleted = Int.random(in: 0...5)
                let videosWatched = Int.random(in: 0...3)
                let steps = Int.random(in: 2000...10000)
                let calories = Double.random(in: 100...500)
                let heartRate = Double.random(in: 60...120) // <-- Generar datos de ritmo cardíaco
                
                let progress = DayProgress(
                    date: date,
                    exercisesCompleted: exercisesCompleted,
                    totalExercises: 5,
                    videosWatched: videosWatched,
                    totalVideos: 3,
                    steps: steps,
                    caloriesBurned: calories,
                    heartRate: heartRate // <-- Asignar
                )
                
                self.progressData[dateKey] = progress
            }
        }
        
        // Actualizar la semana actual para reflejar los cambios
        self.currentWeekDays = (0..<7).map { day in
            calendar.date(byAdding: .day, value: day, to: calendar.startOfDay(for: today))!
        }
    }
}

// MARK: - Chart Data

struct ChartData: Identifiable {
    let id = UUID()
    let category: String
    let completed: Int
    let total: Int
} 