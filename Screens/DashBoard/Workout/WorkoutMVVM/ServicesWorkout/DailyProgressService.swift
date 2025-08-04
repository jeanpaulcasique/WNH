import Foundation
import HealthKit
import Combine

// MARK: - Servicio de Progreso Diario
class DailyProgressService: ObservableObject {
    
    // MARK: - Published Properties
    @Published var currentDayProgress: DailyProgress?
    @Published var weeklyProgress: [DailyProgress] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    // MARK: - Private Properties
    private let healthStore = HKHealthStore()
    private var cancellables = Set<AnyCancellable>()
    private let userDefaults = UserDefaults.standard
    
    // MARK: - HealthKit Types
    private let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
    private let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
    private let activeEnergyType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!
    private let bodyMassType = HKQuantityType.quantityType(forIdentifier: .bodyMass)!
    private let appleExerciseTimeType = HKQuantityType.quantityType(forIdentifier: .appleExerciseTime)!
    
    // MARK: - Constants
    private let dailyGoalSteps = 10000
    private let dailyGoalCalories = 500
    private let dailyGoalActiveMinutes = 30
    
    // MARK: - Initialization
    init() {
        setupHealthKit()
        loadStoredProgress()
    }
    
    // MARK: - HealthKit Setup
    private func setupHealthKit() {
        guard HKHealthStore.isHealthDataAvailable() else {
            errorMessage = "HealthKit no está disponible en este dispositivo"
            return
        }
        
        let typesToRead: Set<HKObjectType> = [
            stepType,
            heartRateType,
            activeEnergyType,
            bodyMassType,
            appleExerciseTimeType
        ]
        
        healthStore.requestAuthorization(toShare: nil, read: typesToRead) { [weak self] success, error in
            DispatchQueue.main.async {
                if success {
                    self?.startMonitoring()
                } else {
                    self?.errorMessage = "No se pudo autorizar HealthKit: \(error?.localizedDescription ?? "Error desconocido")"
                }
            }
        }
    }
    
    // MARK: - Public Methods
    
    /// Inicia el monitoreo de datos de HealthKit
    func startMonitoring() {
        fetchTodayProgress()
        fetchWeeklyProgress()
        setupObservers()
    }
    
    /// Actualiza el progreso del día actual
    func refreshTodayProgress() {
        fetchTodayProgress()
    }
    
    /// Actualiza el progreso semanal
    func refreshWeeklyProgress() {
        fetchWeeklyProgress()
    }
    
    /// Obtiene el progreso para una fecha específica
    func getProgress(for date: Date) -> DailyProgress? {
        let dateString = formatDate(date)
        return weeklyProgress.first { $0.dateString == dateString }
    }
    
    // MARK: - Private Methods
    
    private func setupObservers() {
        // Observar cambios en pasos
        let stepQuery = HKObserverQuery(sampleType: stepType, predicate: nil) { [weak self] _, _, error in
            if error == nil {
                DispatchQueue.main.async {
                    self?.fetchTodayProgress()
                }
            }
        }
        
        // Observar cambios en ritmo cardíaco
        let heartRateQuery = HKObserverQuery(sampleType: heartRateType, predicate: nil) { [weak self] _, _, error in
            if error == nil {
                DispatchQueue.main.async {
                    self?.fetchTodayProgress()
                }
            }
        }
        
        healthStore.execute(stepQuery)
        healthStore.execute(heartRateQuery)
    }
    
    private func fetchTodayProgress() {
        isLoading = true
        
        let today = Date()
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: today)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: endOfDay, options: .strictStartDate)
        
        // Fetch steps
        fetchSteps(predicate: predicate) { [weak self] steps in
            // Fetch heart rate
            self?.fetchHeartRate(predicate: predicate) { [weak self] heartRate in
                // Fetch calories
                self?.fetchCalories(predicate: predicate) { [weak self] calories in
                    // Fetch active minutes
                    self?.fetchActiveMinutes(predicate: predicate) { [weak self] activeMinutes in
                        // Fetch weight
                        self?.fetchCurrentWeight { [weak self] weight in
                            DispatchQueue.main.async {
                                self?.updateTodayProgress(
                                    steps: steps,
                                    heartRate: heartRate,
                                    calories: calories,
                                    activeMinutes: activeMinutes,
                                    weight: weight
                                )
                                self?.isLoading = false
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func fetchSteps(predicate: NSPredicate, completion: @escaping (Int) -> Void) {
        let query = HKStatisticsQuery(
            quantityType: stepType,
            quantitySamplePredicate: predicate,
            options: .cumulativeSum
        ) { _, result, error in
            let steps = result?.sumQuantity()?.doubleValue(for: HKUnit.count()) ?? 0
            completion(Int(steps))
        }
        healthStore.execute(query)
    }
    
    private func fetchHeartRate(predicate: NSPredicate, completion: @escaping (HeartRateData) -> Void) {
        let query = HKStatisticsQuery(
            quantityType: heartRateType,
            quantitySamplePredicate: predicate,
            options: [.discreteAverage, .discreteMin, .discreteMax]
        ) { _, result, error in
            var heartRateData = HeartRateData()
            
            if let average = result?.averageQuantity() {
                heartRateData.average = Int(average.doubleValue(for: HKUnit(from: "count/min")))
            }
            
            if let min = result?.minimumQuantity() {
                heartRateData.min = Int(min.doubleValue(for: HKUnit(from: "count/min")))
            }
            
            if let max = result?.maximumQuantity() {
                heartRateData.max = Int(max.doubleValue(for: HKUnit(from: "count/min")))
            }
            
            // Fetch resting heart rate
            self.fetchRestingHeartRate { restingRate in
                heartRateData.resting = restingRate
                heartRateData.calculateAverage()
                heartRateData.calculateMinMax()
                completion(heartRateData)
            }
        }
        healthStore.execute(query)
    }
    
    private func fetchRestingHeartRate(completion: @escaping (Int?) -> Void) {
        let calendar = Calendar.current
        let now = Date()
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: now)?.start ?? now
        
        let predicate = HKQuery.predicateForSamples(withStart: startOfWeek, end: now, options: .strictStartDate)
        
        let query = HKStatisticsQuery(
            quantityType: heartRateType,
            quantitySamplePredicate: predicate,
            options: .discreteMin
        ) { _, result, error in
            let restingRate = result?.minimumQuantity()?.doubleValue(for: HKUnit(from: "count/min"))
            completion(restingRate != nil ? Int(restingRate!) : nil)
        }
        healthStore.execute(query)
    }
    
    private func fetchCalories(predicate: NSPredicate, completion: @escaping (Int) -> Void) {
        let query = HKStatisticsQuery(
            quantityType: activeEnergyType,
            quantitySamplePredicate: predicate,
            options: .cumulativeSum
        ) { _, result, error in
            let calories = result?.sumQuantity()?.doubleValue(for: HKUnit.kilocalorie()) ?? 0
            completion(Int(calories))
        }
        healthStore.execute(query)
    }
    
    private func fetchActiveMinutes(predicate: NSPredicate, completion: @escaping (Int) -> Void) {
        let query = HKStatisticsQuery(
            quantityType: appleExerciseTimeType,
            quantitySamplePredicate: predicate,
            options: .cumulativeSum
        ) { _, result, error in
            let minutes = result?.sumQuantity()?.doubleValue(for: HKUnit.minute()) ?? 0
            completion(Int(minutes))
        }
        healthStore.execute(query)
    }
    
    private func fetchCurrentWeight(completion: @escaping (Double?) -> Void) {
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        let query = HKSampleQuery(
            sampleType: bodyMassType,
            predicate: nil,
            limit: 1,
            sortDescriptors: [sortDescriptor]
        ) { _, samples, error in
            let weight = samples?.first as? HKQuantitySample
            let weightValue = weight?.quantity.doubleValue(for: HKUnit.gramUnit(with: .kilo))
            completion(weightValue)
        }
        healthStore.execute(query)
    }
    
    private func fetchWeeklyProgress() {
        let calendar = Calendar.current
        let now = Date()
        let weekStart = calendar.dateInterval(of: .weekOfYear, for: now)?.start ?? now
        
        var weeklyData: [DailyProgress] = []
        let group = DispatchGroup()
        
        for dayOffset in 0..<7 {
            let date = calendar.date(byAdding: .day, value: dayOffset, to: weekStart)!
            let startOfDay = calendar.startOfDay(for: date)
            let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
            
            let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: endOfDay, options: .strictStartDate)
            
            group.enter()
            
            // Fetch all data for this day
            fetchSteps(predicate: predicate) { steps in
                self.fetchHeartRate(predicate: predicate) { heartRate in
                    self.fetchCalories(predicate: predicate) { calories in
                        self.fetchActiveMinutes(predicate: predicate) { activeMinutes in
                            let dayProgress = DailyProgress(
                                date: date,
                                steps: steps,
                                heartRate: heartRate,
                                caloriesBurned: calories,
                                activeMinutes: activeMinutes
                            )
                            weeklyData.append(dayProgress)
                            group.leave()
                        }
                    }
                }
            }
        }
        
        group.notify(queue: .main) { [weak self] in
            self?.weeklyProgress = weeklyData.sorted { $0.date < $1.date }
            self?.saveProgress()
        }
    }
    
    private func updateTodayProgress(steps: Int, heartRate: HeartRateData, calories: Int, activeMinutes: Int, weight: Double?) {
        let today = Date()
        
        if var existingProgress = currentDayProgress {
            existingProgress.updateSteps(steps)
            existingProgress.updateHeartRate(heartRate)
            existingProgress.updateCaloriesBurned(calories)
            existingProgress.updateActiveMinutes(activeMinutes)
            if let weight = weight {
                existingProgress.updateWeight(weight)
            }
            currentDayProgress = existingProgress
        } else {
            var newProgress = DailyProgress(
                date: today,
                steps: steps,
                heartRate: heartRate,
                caloriesBurned: calories,
                activeMinutes: activeMinutes
            )
            if let weight = weight {
                newProgress.updateWeight(weight)
            }
            currentDayProgress = newProgress
        }
        
        // Update target weight from user profile
        let userProfile = UserProfile.loadFromUserDefaults()
        currentDayProgress?.updateTargetWeight(userProfile.targetWeightKg ?? userProfile.weightKg)
        
        saveProgress()
    }
    
    // MARK: - Persistence
    
    private func saveProgress() {
        guard let progress = currentDayProgress else { return }
        
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(progress) {
            userDefaults.set(encoded, forKey: "todayProgress_\(progress.dateString)")
        }
        
        // Save weekly progress
        if let weeklyEncoded = try? encoder.encode(weeklyProgress) {
            userDefaults.set(weeklyEncoded, forKey: "weeklyProgress")
        }
    }
    
    private func loadStoredProgress() {
        let today = formatDate(Date())
        
        if let todayData = userDefaults.data(forKey: "todayProgress_\(today)"),
           let progress = try? JSONDecoder().decode(DailyProgress.self, from: todayData) {
            currentDayProgress = progress
        }
        
        if let weeklyData = userDefaults.data(forKey: "weeklyProgress"),
           let progress = try? JSONDecoder().decode([DailyProgress].self, from: weeklyData) {
            weeklyProgress = progress
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}

// MARK: - Extensión para Cálculos Avanzados
extension DailyProgressService {
    
    /// Calcula el progreso semanal
    func getWeeklyStats() -> WeeklyProgressStats? {
        guard !weeklyProgress.isEmpty else { return nil }
        
        let calendar = Calendar.current
        let now = Date()
        let weekStart = calendar.dateInterval(of: .weekOfYear, for: now)?.start ?? now
        let weekEnd = calendar.date(byAdding: .day, value: 6, to: weekStart)!
        
        return WeeklyProgressStats(
            weekStartDate: weekStart,
            weekEndDate: weekEnd,
            dailyProgress: weeklyProgress
        )
    }
    
    /// Calcula calorías quemadas usando la fórmula mejorada
    func calculateCaloriesBurned(steps: Int, heartRate: HeartRateData, weight: Double) -> Int {
        return DailyProgress.calculateCaloriesBurned(steps: steps, heartRate: heartRate, weight: weight)
    }
    
    /// Obtiene el progreso de peso hacia el objetivo
    func getWeightProgress() -> (current: Double, target: Double, remaining: Double, percentage: Double)? {
        guard let progress = currentDayProgress,
              let current = progress.currentWeight,
              let target = progress.targetWeight else { return nil }
        
        let remaining = abs(target - current)
        let percentage = progress.weightProgressPercentage
        
        return (current, target, remaining, percentage)
    }
} 