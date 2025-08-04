import Foundation
import HealthKit

// MARK: - Modelo de Progreso Diario Completo
struct DailyProgress: Codable, Identifiable {
    let id = UUID()
    let date: Date
    
    // Datos de actividad física
    var steps: Int
    var heartRate: HeartRateData
    var caloriesBurned: Int
    var activeMinutes: Int
    
    // Datos de peso y objetivo
    var currentWeight: Double?
    var targetWeight: Double?
    var weightProgress: Double?
    
    // Metadatos
    let createdAt: Date
    var updatedAt: Date
    
    init(date: Date, steps: Int = 0, heartRate: HeartRateData = HeartRateData(), caloriesBurned: Int = 0, activeMinutes: Int = 0) {
        self.date = date
        self.steps = steps
        self.heartRate = heartRate
        self.caloriesBurned = caloriesBurned
        self.activeMinutes = activeMinutes
        self.createdAt = Date()
        self.updatedAt = Date()
    }
    
    // MARK: - Computed Properties
    
    var dateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
    
    var dayOfWeek: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: date)
    }
    
    var isToday: Bool {
        Calendar.current.isDateInToday(date)
    }
    
    var isYesterday: Bool {
        Calendar.current.isDateInYesterday(date)
    }
    
    // MARK: - Métodos de Cálculo
    
    /// Calcula el progreso de pasos (basado en meta de 10,000 pasos)
    var stepsProgress: Double {
        let dailyGoal = 10000
        return min(Double(steps) / Double(dailyGoal), 1.0)
    }
    
    /// Calcula el progreso de calorías (basado en meta de 500 calorías activas)
    var caloriesProgress: Double {
        let dailyGoal = 500
        return min(Double(caloriesBurned) / Double(dailyGoal), 1.0)
    }
    
    /// Calcula el progreso de actividad (basado en meta de 30 minutos activos)
    var activityProgress: Double {
        let dailyGoal = 30
        return min(Double(activeMinutes) / Double(dailyGoal), 1.0)
    }
    
    /// Calcula el progreso de peso hacia el objetivo
    var weightProgressPercentage: Double {
        guard let current = currentWeight, let target = targetWeight else { return 0.0 }
        
        let userProfile = UserProfile.loadFromUserDefaults()
        let goal = userProfile.goal.lowercased()
        
        if goal.contains("perder") || goal.contains("lose") {
            // Para pérdida de peso
            let startWeight = userProfile.weightKg
            let totalToLose = startWeight - target
            let alreadyLost = startWeight - current
            return min(alreadyLost / totalToLose, 1.0)
        } else if goal.contains("ganar") || goal.contains("gain") {
            // Para ganancia de peso
            let startWeight = userProfile.weightKg
            let totalToGain = target - startWeight
            let alreadyGained = current - startWeight
            return min(alreadyGained / totalToGain, 1.0)
        } else {
            // Para mantenimiento
            return 0.5
        }
    }
    
    /// Calcula el peso restante para el objetivo
    var weightRemaining: Double {
        guard let current = currentWeight, let target = targetWeight else { return 0.0 }
        return abs(target - current)
    }
    
    /// Calcula el peso perdido/ganado desde el inicio
    var weightChange: Double {
        guard let current = currentWeight else { return 0.0 }
        let userProfile = UserProfile.loadFromUserDefaults()
        return current - userProfile.weightKg
    }
    
    // MARK: - Métodos de Actualización
    
    mutating func updateSteps(_ newSteps: Int) {
        self.steps = newSteps
        self.updatedAt = Date()
    }
    
    mutating func updateHeartRate(_ newHeartRate: HeartRateData) {
        self.heartRate = newHeartRate
        self.updatedAt = Date()
    }
    
    mutating func updateCaloriesBurned(_ newCalories: Int) {
        self.caloriesBurned = newCalories
        self.updatedAt = Date()
    }
    
    mutating func updateActiveMinutes(_ newMinutes: Int) {
        self.activeMinutes = newMinutes
        self.updatedAt = Date()
    }
    
    mutating func updateWeight(_ newWeight: Double) {
        self.currentWeight = newWeight
        self.updatedAt = Date()
    }
    
    mutating func updateTargetWeight(_ newTarget: Double) {
        self.targetWeight = newTarget
        self.updatedAt = Date()
    }
}

// MARK: - Datos de Ritmo Cardíaco
struct HeartRateData: Codable {
    var current: Int?
    var average: Int?
    var min: Int?
    var max: Int?
    var resting: Int?
    var samples: [HeartRateSample] = []
    
    init(current: Int? = nil, average: Int? = nil, min: Int? = nil, max: Int? = nil, resting: Int? = nil) {
        self.current = current
        self.average = average
        self.min = min
        self.max = max
        self.resting = resting
    }
    
    /// Calcula el promedio del ritmo cardíaco
    mutating func calculateAverage() {
        guard !samples.isEmpty else { return }
        let total = samples.reduce(0) { $0 + $1.value }
        self.average = total / samples.count
    }
    
    /// Calcula el ritmo cardíaco mínimo y máximo
    mutating func calculateMinMax() {
        guard !samples.isEmpty else { return }
        let values = samples.map { $0.value }
        self.min = values.min()
        self.max = values.max()
    }
}

// MARK: - Muestra de Ritmo Cardíaco
struct HeartRateSample: Codable {
    let timestamp: Date
    let value: Int
    let source: String
    
    init(timestamp: Date, value: Int, source: String = "Apple Watch") {
        self.timestamp = timestamp
        self.value = value
        self.source = source
    }
}

// MARK: - Estadísticas Semanales
struct WeeklyProgressStats {
    let weekStartDate: Date
    let weekEndDate: Date
    let dailyProgress: [DailyProgress]
    
    var totalSteps: Int {
        dailyProgress.reduce(0) { $0 + $1.steps }
    }
    
    var averageSteps: Int {
        guard !dailyProgress.isEmpty else { return 0 }
        return totalSteps / dailyProgress.count
    }
    
    var totalCaloriesBurned: Int {
        dailyProgress.reduce(0) { $0 + $1.caloriesBurned }
    }
    
    var averageCaloriesBurned: Int {
        guard !dailyProgress.isEmpty else { return 0 }
        return totalCaloriesBurned / dailyProgress.count
    }
    
    var averageHeartRate: Int {
        let heartRates = dailyProgress.compactMap { $0.heartRate.average }
        guard !heartRates.isEmpty else { return 0 }
        return heartRates.reduce(0, +) / heartRates.count
    }
    
    var totalActiveMinutes: Int {
        dailyProgress.reduce(0) { $0 + $1.activeMinutes }
    }
    
    var averageActiveMinutes: Int {
        guard !dailyProgress.isEmpty else { return 0 }
        return totalActiveMinutes / dailyProgress.count
    }
    
    var weightProgress: Double {
        let progresses = dailyProgress.compactMap { $0.weightProgress }
        guard !progresses.isEmpty else { return 0.0 }
        return progresses.reduce(0, +) / Double(progresses.count)
    }
    
    var completionRate: Double {
        let completedDays = dailyProgress.filter { $0.steps >= 10000 }.count
        return Double(completedDays) / Double(dailyProgress.count)
    }
}

// MARK: - Extensión para Cálculo de Calorías
extension DailyProgress {
    /// Calcula calorías quemadas basadas en pasos y ritmo cardíaco
    static func calculateCaloriesBurned(steps: Int, heartRate: HeartRateData, weight: Double) -> Int {
        // Fórmula mejorada basada en MET (Metabolic Equivalent of Task)
        let averageHeartRate = heartRate.average ?? 70
        let restingHeartRate = heartRate.resting ?? 60
        
        // Calcular intensidad basada en la diferencia entre ritmo cardíaco actual y en reposo
        let heartRateIntensity = Double(averageHeartRate - restingHeartRate) / Double(restingHeartRate)
        
        // MET base para caminar (varía según intensidad)
        let baseMET = 3.5 // MET para caminar a paso normal
        let intensityMET = baseMET * (1.0 + heartRateIntensity)
        
        // Calcular calorías por paso
        let caloriesPerStep = (intensityMET * weight * 0.001) / 1000 // Aproximación
        
        // Calorías totales
        let totalCalories = Int(Double(steps) * caloriesPerStep)
        
        return max(totalCalories, 0)
    }
} 