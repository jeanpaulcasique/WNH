import Foundation
import HealthKit
import Combine

/// Servicio que maneja la integración con HealthKit
class HealthKitService: ObservableObject {
    
    // MARK: - Published Properties
    @Published var isAuthorized: Bool = false
    @Published var currentHeartRate: Int = 0
    @Published var authorizationStatus: HKAuthorizationStatus = .notDetermined
    @Published var lastUpdated: Date = Date()
    
    // MARK: - Private Properties
    private let healthStore = HKHealthStore()
    private var heartRateQuery: HKQuery?
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - HealthKit Types
    private let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
    private let workoutType = HKObjectType.workoutType()
    private let activeEnergyType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!
    
    // MARK: - Initialization
    
    init() {
        checkAuthorizationStatus()
    }
    
    // MARK: - Public Methods
    
    /// Solicita autorización para acceder a HealthKit
    func requestAuthorization() {
        guard HKHealthStore.isHealthDataAvailable() else {
            print("HealthKit no está disponible en este dispositivo")
            return
        }
        
        let typesToRead: Set<HKObjectType> = [
            heartRateType,
            workoutType,
            activeEnergyType
        ]
        
        let typesToWrite: Set<HKSampleType> = [
            workoutType,
            activeEnergyType
        ]
        
        healthStore.requestAuthorization(toShare: typesToWrite, read: typesToRead) { [weak self] success, error in
            DispatchQueue.main.async {
                if success {
                    self?.isAuthorized = true
                    self?.authorizationStatus = .sharingAuthorized
                    self?.startHeartRateMonitoring()
                } else {
                    self?.isAuthorized = false
                    self?.authorizationStatus = .sharingDenied
                    print("Error requesting HealthKit authorization: \(error?.localizedDescription ?? "Unknown error")")
                }
            }
        }
    }
    
    /// Inicia el monitoreo del ritmo cardíaco
    func startHeartRateMonitoring() {
        guard isAuthorized else { return }
        
        // Detener query anterior si existe
        if let existingQuery = heartRateQuery {
            healthStore.stop(existingQuery)
        }
        
        // Crear query para ritmo cardíaco en tiempo real
        let heartRateQuery = HKAnchoredObjectQuery(
            type: heartRateType,
            predicate: nil,
            anchor: nil,
            limit: HKObjectQueryNoLimit
        ) { [weak self] query, samples, deletedObjects, anchor, error in
            self?.processHeartRateSamples(samples)
        }
        
        // Configurar actualizaciones continuas
        heartRateQuery.updateHandler = { [weak self] query, samples, deletedObjects, anchor, error in
            self?.processHeartRateSamples(samples)
        }
        
        self.heartRateQuery = heartRateQuery
        healthStore.execute(heartRateQuery)
    }
    
    /// Detiene el monitoreo del ritmo cardíaco
    func stopHeartRateMonitoring() {
        if let query = heartRateQuery {
            healthStore.stop(query)
            heartRateQuery = nil
        }
    }
    
    /// Obtiene el ritmo cardíaco promedio para un período específico
    func getAverageHeartRate(from startDate: Date, to endDate: Date, completion: @escaping (Double?) -> Void) {
        guard isAuthorized else {
            completion(nil)
            return
        }
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        let query = HKStatisticsQuery(
            quantityType: heartRateType,
            quantitySamplePredicate: predicate,
            options: .discreteAverage
        ) { _, statistics, error in
            DispatchQueue.main.async {
                if let average = statistics?.averageQuantity() {
                    let heartRateUnit = HKUnit.count().unitDivided(by: .minute())
                    let averageHeartRate = average.doubleValue(for: heartRateUnit)
                    completion(averageHeartRate)
                } else {
                    completion(nil)
                }
            }
        }
        
        healthStore.execute(query)
    }
    
    /// Obtiene el ritmo cardíaco máximo para un período específico
    func getMaxHeartRate(from startDate: Date, to endDate: Date, completion: @escaping (Double?) -> Void) {
        guard isAuthorized else {
            completion(nil)
            return
        }
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        let query = HKStatisticsQuery(
            quantityType: heartRateType,
            quantitySamplePredicate: predicate,
            options: .discreteMax
        ) { _, statistics, error in
            DispatchQueue.main.async {
                if let maximum = statistics?.maximumQuantity() {
                    let heartRateUnit = HKUnit.count().unitDivided(by: .minute())
                    let maxHeartRate = maximum.doubleValue(for: heartRateUnit)
                    completion(maxHeartRate)
                } else {
                    completion(nil)
                }
            }
        }
        
        healthStore.execute(query)
    }
    
    /// Guarda un workout en HealthKit
    func saveWorkout(
        type: HKWorkoutActivityType,
        startDate: Date,
        endDate: Date,
        duration: TimeInterval,
        calories: Double,
        completion: @escaping (Bool, Error?) -> Void
    ) {
        guard isAuthorized else {
            completion(false, NSError(domain: "HealthKitService", code: 1, userInfo: [NSLocalizedDescriptionKey: "HealthKit no está autorizado"]))
            return
        }
        
        let workout = HKWorkout(
            activityType: type,
            start: startDate,
            end: endDate,
            duration: duration,
            totalEnergyBurned: HKQuantity(unit: .kilocalorie(), doubleValue: calories),
            totalDistance: nil,
            metadata: [HKMetadataKeyWorkoutBrandName: "WNH App"]
        )
        
        healthStore.save(workout) { success, error in
            DispatchQueue.main.async {
                completion(success, error)
            }
        }
    }
    
    /// Obtiene estadísticas de workouts para un período específico
    func getWorkoutStats(from startDate: Date, to endDate: Date, completion: @escaping (WorkoutHealthStats?) -> Void) {
        guard isAuthorized else {
            completion(nil)
            return
        }
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        let workoutQuery = HKSampleQuery(
            sampleType: workoutType,
            predicate: predicate,
            limit: HKObjectQueryNoLimit,
            sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)]
        ) { [weak self] _, samples, error in
            guard let workouts = samples as? [HKWorkout], error == nil else {
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            
            let stats = self?.calculateWorkoutStats(from: workouts)
            DispatchQueue.main.async {
                completion(stats)
            }
        }
        
        healthStore.execute(workoutQuery)
    }
    
    /// Verifica si HealthKit está disponible
    var isHealthKitAvailable: Bool {
        return HKHealthStore.isHealthDataAvailable()
    }
    
    // MARK: - Private Methods
    
    private func checkAuthorizationStatus() {
        guard HKHealthStore.isHealthDataAvailable() else {
            isAuthorized = false
            authorizationStatus = .notDetermined
            return
        }
        
        let status = healthStore.authorizationStatus(for: heartRateType)
        DispatchQueue.main.async {
            self.authorizationStatus = status
            self.isAuthorized = status == .sharingAuthorized
        }
    }
    
    private func processHeartRateSamples(_ samples: [HKSample]?) {
        guard let heartRateSamples = samples as? [HKQuantitySample] else { return }
        
        // Obtener la muestra más reciente
        if let latestSample = heartRateSamples.last {
            let heartRateUnit = HKUnit.count().unitDivided(by: .minute())
            let heartRate = latestSample.quantity.doubleValue(for: heartRateUnit)
            
            DispatchQueue.main.async {
                self.currentHeartRate = Int(heartRate)
                self.lastUpdated = latestSample.startDate
            }
        }
    }
    
    private func calculateWorkoutStats(from workouts: [HKWorkout]) -> WorkoutHealthStats {
        let totalWorkouts = workouts.count
        let totalDuration = workouts.reduce(0) { $0 + $1.duration }
        let totalCalories = workouts.reduce(0) { $0 + ($1.totalEnergyBurned?.doubleValue(for: .kilocalorie()) ?? 0) }
        
        let averageDuration = totalWorkouts > 0 ? totalDuration / Double(totalWorkouts) : 0
        let averageCalories = totalWorkouts > 0 ? totalCalories / Double(totalWorkouts) : 0
        
        return WorkoutHealthStats(
            totalWorkouts: totalWorkouts,
            totalDuration: totalDuration,
            totalCalories: totalCalories,
            averageDuration: averageDuration,
            averageCalories: averageCalories,
            lastWorkoutDate: workouts.first?.startDate
        )
    }
}

// MARK: - Supporting Models

struct WorkoutHealthStats {
    let totalWorkouts: Int
    let totalDuration: TimeInterval
    let totalCalories: Double
    let averageDuration: TimeInterval
    let averageCalories: Double
    let lastWorkoutDate: Date?
    
    var totalHours: Double {
        totalDuration / 3600
    }
    
    var averageMinutes: Double {
        averageDuration / 60
    }
    
    var formattedTotalDuration: String {
        let hours = Int(totalHours)
        let minutes = Int((totalDuration.truncatingRemainder(dividingBy: 3600)) / 60)
        return "\(hours)h \(minutes)m"
    }
    
    var formattedAverageDuration: String {
        let minutes = Int(averageMinutes)
        return "\(minutes) min"
    }
} 