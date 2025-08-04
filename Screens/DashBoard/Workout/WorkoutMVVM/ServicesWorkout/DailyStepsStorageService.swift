import Foundation
import Combine

class DailyStepsStorageService: ObservableObject {
    
    // MARK: - Published Properties
    @Published var weeklySteps: [DailySteps] = []
    @Published var monthlySteps: [DailySteps] = []
    
    // MARK: - Private Properties
    private let userDefaults = UserDefaults.standard
    private let weeklyStepsKey = "weeklyStepsData"
    private let monthlyStepsKey = "monthlyStepsData"
    
    // MARK: - Initialization
    init() {
        loadStoredSteps()
    }
    
    // MARK: - Public Methods
    
    /// Guarda los pasos del día actual
    func saveTodaySteps(_ steps: Int) {
        let today = Date()
        let todaySteps = DailySteps(date: today, steps: steps)
        
        // Actualizar pasos semanales
        updateWeeklySteps(todaySteps)
        
        // Actualizar pasos mensuales
        updateMonthlySteps(todaySteps)
        
        // Guardar en UserDefaults
        saveToUserDefaults()
    }
    
    /// Obtiene los pasos para una fecha específica
    func getStepsForDate(_ date: Date) -> Int {
        let dateString = formatDate(date)
        
        // Buscar en datos semanales
        if let weeklyStep = weeklySteps.first(where: { $0.dateString == dateString }) {
            return weeklyStep.steps
        }
        
        // Buscar en datos mensuales
        if let monthlyStep = monthlySteps.first(where: { $0.dateString == dateString }) {
            return monthlyStep.steps
        }
        
        return 0
    }
    
    /// Obtiene los pasos de la semana actual
    func getCurrentWeekSteps() -> [DailySteps] {
        let calendar = Calendar.current
        let today = Date()
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: today)?.start ?? today
        
        return weeklySteps.filter { step in
            calendar.isDate(step.date, equalTo: startOfWeek, toGranularity: .weekOfYear)
        }.sorted { $0.date < $1.date }
    }
    
    /// Obtiene el promedio de pasos de la semana
    func getWeeklyAverage() -> Int {
        let weekSteps = getCurrentWeekSteps()
        guard !weekSteps.isEmpty else { return 0 }
        
        let totalSteps = weekSteps.reduce(0) { $0 + $1.steps }
        return totalSteps / weekSteps.count
    }
    
    /// Obtiene el total de pasos de la semana
    func getWeeklyTotal() -> Int {
        let weekSteps = getCurrentWeekSteps()
        return weekSteps.reduce(0) { $0 + $1.steps }
    }
    
    /// Obtiene el objetivo diario recomendado (basado en el promedio semanal)
    func getRecommendedDailyGoal() -> Int {
        let average = getWeeklyAverage()
        if average == 0 {
            return 10000 // Objetivo por defecto
        }
        return max(average, 8000) // Mínimo 8000 pasos
    }
    
    // MARK: - Private Methods
    
    private func updateWeeklySteps(_ todaySteps: DailySteps) {
        // Remover entrada anterior del mismo día si existe
        weeklySteps.removeAll { $0.dateString == todaySteps.dateString }
        
        // Agregar nueva entrada
        weeklySteps.append(todaySteps)
        
        // Mantener solo los últimos 7 días
        let calendar = Calendar.current
        let sevenDaysAgo = calendar.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        weeklySteps = weeklySteps.filter { $0.date >= sevenDaysAgo }
        
        // Ordenar por fecha
        weeklySteps.sort { $0.date < $1.date }
    }
    
    private func updateMonthlySteps(_ todaySteps: DailySteps) {
        // Remover entrada anterior del mismo día si existe
        monthlySteps.removeAll { $0.dateString == todaySteps.dateString }
        
        // Agregar nueva entrada
        monthlySteps.append(todaySteps)
        
        // Mantener solo los últimos 30 días
        let calendar = Calendar.current
        let thirtyDaysAgo = calendar.date(byAdding: .day, value: -30, to: Date()) ?? Date()
        monthlySteps = monthlySteps.filter { $0.date >= thirtyDaysAgo }
        
        // Ordenar por fecha
        monthlySteps.sort { $0.date < $1.date }
    }
    
    private func saveToUserDefaults() {
        // Codificar y guardar datos semanales
        if let weeklyData = try? JSONEncoder().encode(weeklySteps) {
            userDefaults.set(weeklyData, forKey: weeklyStepsKey)
        }
        
        // Codificar y guardar datos mensuales
        if let monthlyData = try? JSONEncoder().encode(monthlySteps) {
            userDefaults.set(monthlyData, forKey: monthlyStepsKey)
        }
    }
    
    private func loadStoredSteps() {
        // Cargar datos semanales
        if let weeklyData = userDefaults.data(forKey: weeklyStepsKey),
           let decodedWeekly = try? JSONDecoder().decode([DailySteps].self, from: weeklyData) {
            weeklySteps = decodedWeekly
        }
        
        // Cargar datos mensuales
        if let monthlyData = userDefaults.data(forKey: monthlyStepsKey),
           let decodedMonthly = try? JSONDecoder().decode([DailySteps].self, from: monthlyData) {
            monthlySteps = decodedMonthly
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}
