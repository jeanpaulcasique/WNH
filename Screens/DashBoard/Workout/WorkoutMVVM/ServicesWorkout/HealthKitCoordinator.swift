import SwiftUI
import Combine
import HealthKit

/// Coordinador que maneja toda la lógica de HealthKit
class HealthKitCoordinator: ObservableObject {
    
    // MARK: - Published Properties
    @Published var heartRate: Double? = nil
    @Published var userWeight: Double? = nil
    @Published var healthKitAuthorized: Bool = false
    @Published var todaySteps: Int = 0
    @Published var stepsAuthorized: Bool = false
    @Published var isLoadingHeartRate: Bool = false
    @Published var isLoadingSteps: Bool = false
    
    // MARK: - Services
    private let healthKitService: HealthKitService
    let stepsService: StepsService
    private let dailyStepsStorage: DailyStepsStorageService
    let userPreferencesService: UserPreferencesService
    let healthKitPersistence: HealthKitPersistenceService
    
    // MARK: - Private Properties
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    init(
        healthKitService: HealthKitService = HealthKitService(),
        stepsService: StepsService = StepsService(),
        dailyStepsStorage: DailyStepsStorageService = DailyStepsStorageService(),
        userPreferencesService: UserPreferencesService = UserPreferencesService(),
        healthKitPersistence: HealthKitPersistenceService = HealthKitPersistenceService()
    ) {
        self.healthKitService = healthKitService
        self.stepsService = stepsService
        self.dailyStepsStorage = dailyStepsStorage
        self.userPreferencesService = userPreferencesService
        self.healthKitPersistence = healthKitPersistence
        
        setupBindings()
    }
    
    // MARK: - Public Methods
    
    /// Carga datos de HealthKit automáticamente si están autorizados
    func loadHealthDataIfAuthorized() {
        print("HealthKitCoordinator: loadHealthDataIfAuthorized called")
        
        guard HKHealthStore.isHealthDataAvailable() else {
            print("HealthKitCoordinator: HealthKit not available")
            return
        }
        
        let healthStore = HKHealthStore()
        
        // Verificar autorización de ritmo cardíaco directamente
        let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
        let heartRateStatus = healthStore.authorizationStatus(for: heartRateType)
        let isHeartRateAuthorized = heartRateStatus == .sharingAuthorized
        
        // Verificar autorización de pasos directamente
        let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        let stepsStatus = healthStore.authorizationStatus(for: stepType)
        let isStepsAuthorized = stepsStatus == .sharingAuthorized
        
        print("HealthKitCoordinator: Direct HealthKit status - Heart Rate: \(heartRateStatus.rawValue), Steps: \(stepsStatus.rawValue)")
        print("HealthKitCoordinator: Current data - Heart Rate: \(heartRate?.description ?? "nil"), Steps: \(todaySteps)")
        
        // Actualizar persistencia con el estado real
        healthKitPersistence.saveHeartRateAuthorization(isHeartRateAuthorized)
        healthKitPersistence.saveStepsAuthorization(isStepsAuthorized)
        
        // Para ritmo cardíaco: cargar si está autorizado
        if isHeartRateAuthorized && self.heartRate == nil {
            print("HealthKitCoordinator: Starting heart rate loading")
            self.isLoadingHeartRate = true
            healthKitService.startHeartRateMonitoring()
        }
        
        // Para pasos: cargar si está autorizado
        if isStepsAuthorized && self.isLoadingSteps == false {
            print("HealthKitCoordinator: Starting steps loading")
            self.isLoadingSteps = true
            stepsService.fetchTodaySteps()
            
            // Timeout de seguridad para pasos (5 segundos)
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) { [weak self] in
                if self?.isLoadingSteps == true {
                    print("HealthKitCoordinator: Steps loading timeout, stopping")
                    self?.isLoadingSteps = false
                }
            }
        }
    }
    
    /// Solicita autorización de HealthKit
    func requestHealthKitAuthorization() {
        print("HealthKitCoordinator: requestHealthKitAuthorization called")
        
        // Verificar el estado actual de HealthKit directamente
        guard HKHealthStore.isHealthDataAvailable() else {
            print("HealthKitCoordinator: HealthKit not available")
            return
        }
        
        let healthStore = HKHealthStore()
        let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
        let currentStatus = healthStore.authorizationStatus(for: heartRateType)
        
        print("HealthKitCoordinator: Current HealthKit status: \(currentStatus.rawValue)")
        
        if currentStatus == .sharingAuthorized {
            print("HealthKitCoordinator: HealthKit already authorized, refreshing data")
            // Si ya está autorizado, solo refrescar los datos
            isLoadingHeartRate = true
            healthKitService.startHeartRateMonitoring()
            
            // Actualizar persistencia
            healthKitPersistence.saveHeartRateAuthorization(true)
        } else {
            print("HealthKitCoordinator: HealthKit not authorized, requesting authorization")
            // Si no está autorizado, solicitar autorización
            isLoadingHeartRate = true
            healthKitService.requestAuthorization()
        }
        
        // El loading se detendrá automáticamente cuando lleguen los datos reales
        // a través del sink en setupBindings()
    }
    
    /// Solicita autorización para pasos
    func requestStepsAuthorization() {
        print("HealthKitCoordinator: requestStepsAuthorization called")
        
        // Verificar el estado actual de HealthKit directamente
        guard HKHealthStore.isHealthDataAvailable() else {
            print("HealthKitCoordinator: HealthKit not available for steps")
            return
        }
        
        let healthStore = HKHealthStore()
        let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        let currentStatus = healthStore.authorizationStatus(for: stepType)
        
        print("HealthKitCoordinator: Current Steps status: \(currentStatus.rawValue)")
        
        if currentStatus == .sharingAuthorized {
            print("HealthKitCoordinator: Steps already authorized, refreshing data")
            // Si ya está autorizado, solo refrescar los datos
            isLoadingSteps = true
            stepsService.fetchTodaySteps() // Solo obtener datos actuales
            
            // Actualizar persistencia
            healthKitPersistence.saveStepsAuthorization(true)
            
            // Timeout de seguridad para el loading de pasos (5 segundos)
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) { [weak self] in
                if self?.isLoadingSteps == true {
                    print("HealthKitCoordinator: Steps loading timeout, stopping")
                    self?.isLoadingSteps = false
                }
            }
        } else {
            print("HealthKitCoordinator: Steps not authorized, requesting authorization")
            // Si no está autorizado, solicitar autorización
            isLoadingSteps = true
            stepsService.requestAuthorization()
            
            // Timeout de seguridad para el loading de pasos (5 segundos)
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) { [weak self] in
                if self?.isLoadingSteps == true {
                    print("HealthKitCoordinator: Steps loading timeout, stopping")
                    self?.isLoadingSteps = false
                }
            }
        }
    }
    
    // MARK: - Daily Steps Methods
    
    /// Obtiene los pasos para una fecha específica
    func getStepsForDate(_ date: Date) -> Int {
        return dailyStepsStorage.getStepsForDate(date)
    }
    
    /// Obtiene los pasos de la semana actual
    func getCurrentWeekSteps() -> [DailySteps] {
        return dailyStepsStorage.getCurrentWeekSteps()
    }
    
    /// Obtiene el promedio de pasos de la semana
    func getWeeklyAverageSteps() -> Int {
        return dailyStepsStorage.getWeeklyAverage()
    }
    
    /// Obtiene el total de pasos de la semana
    func getWeeklyTotalSteps() -> Int {
        return dailyStepsStorage.getWeeklyTotal()
    }
    
    /// Obtiene el objetivo diario recomendado
    func getRecommendedDailyGoal() -> Int {
        return userPreferencesService.recommendedDailySteps
    }
    
    /// Obtiene el ritmo cardíaco promedio para una fecha específica
    func getHeartRateForDate(_ date: Date) -> Double? {
        // Por ahora retornamos el ritmo cardíaco actual
        // En el futuro esto se puede conectar con HealthKit para obtener datos históricos
        return heartRate
    }
    
    /// Obtiene el ritmo cardíaco promedio para una fecha específica desde HealthKit
    func getHeartRateForDateFromHealthKit(_ date: Date, completion: @escaping (Double?) -> Void) {
        healthKitService.getHeartRateForDate(date, completion: completion)
    }
    
    /// Obtiene las calorías activas quemadas para una fecha específica
    func getActiveCaloriesForDate(_ date: Date, completion: @escaping (Double) -> Void) {
        healthKitService.getActiveCaloriesForDate(date, completion: completion)
    }
    
    /// Inicia el timer de ritmo cardíaco si es necesario
    func startHeartRateTimerIfNeeded() {
        if healthKitAuthorized {
            healthKitService.startHeartRateMonitoring()
        }
    }
    
    /// Obtiene estadísticas de HealthKit
    func getHealthKitStats(from startDate: Date, to endDate: Date, completion: @escaping (WorkoutHealthStats?) -> Void) {
        healthKitService.getWorkoutStats(from: startDate, to: endDate, completion: completion)
    }
    
    /// Guarda un workout en HealthKit
    func saveWorkoutToHealthKit(
        type: HKWorkoutActivityType,
        startDate: Date,
        endDate: Date,
        duration: TimeInterval,
        calories: Double,
        completion: @escaping (Bool, Error?) -> Void
    ) {
        healthKitService.saveWorkout(
            type: type,
            startDate: startDate,
            endDate: endDate,
            duration: duration,
            calories: calories,
            completion: completion
        )
    }
    
    /// Limpia recursos
    func cleanup() {
        healthKitService.stopHeartRateMonitoring()
    }
    
    /// Fuerza una nueva verificación de autorización (útil para testing)
    func forceReauthorization() {
        print("HealthKitCoordinator: Force reauthorization called")
        healthKitPersistence.forceReauthorization()
        
        // Recargar datos después de la verificación
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.loadHealthDataIfAuthorized()
        }
    }
    
    // MARK: - Private Methods
    
    private func setupBindings() {
        // Observar cambios en el HealthKitService y guardar persistencia
        healthKitService.$isAuthorized
            .sink { [weak self] isAuthorized in
                print("HealthKitCoordinator: HealthKit authorization changed to: \(isAuthorized)")
                self?.healthKitAuthorized = isAuthorized
                
                // Guardar estado de autorización para persistencia
                self?.healthKitPersistence.saveHeartRateAuthorization(isAuthorized)
                
                // Cargar datos automáticamente cuando se autorice
                if isAuthorized {
                    print("HealthKitCoordinator: HealthKit authorized, loading data")
                    self?.loadHealthDataIfAuthorized()
                }
            }
            .store(in: &cancellables)
        
        healthKitService.$currentHeartRate
            .compactMap { $0.map { Double($0) } }
            .sink { [weak self] newHeartRate in
                self?.heartRate = newHeartRate
                // Detener loading solo cuando lleguen datos reales
                if newHeartRate > 0 && self?.isLoadingHeartRate == true {
                    self?.isLoadingHeartRate = false
                }
            }
            .store(in: &cancellables)
        
        // Timeout de seguridad para el loading del ritmo cardíaco (10 segundos)
        healthKitService.$currentHeartRate
            .compactMap { $0 }
            .filter { $0 > 0 }
            .first()
            .delay(for: .seconds(10), scheduler: DispatchQueue.main)
            .sink { [weak self] _ in
                if self?.isLoadingHeartRate == true {
                    self?.isLoadingHeartRate = false
                }
            }
            .store(in: &cancellables)
        
        // Observar cambios en el StepsService y guardar persistencia
        stepsService.$isAuthorized
            .sink { [weak self] isAuthorized in
                print("HealthKitCoordinator: Steps authorization changed to: \(isAuthorized)")
                self?.stepsAuthorized = isAuthorized
                
                // Guardar estado de autorización para persistencia
                self?.healthKitPersistence.saveStepsAuthorization(isAuthorized)
                
                // Cargar datos automáticamente cuando se autorice
                if isAuthorized {
                    print("HealthKitCoordinator: Steps authorized, loading data")
                    self?.loadHealthDataIfAuthorized()
                }
            }
            .store(in: &cancellables)
        
        stepsService.$todaySteps
            .sink { [weak self] newSteps in
                self?.todaySteps = newSteps
                // Detener loading cuando lleguen datos (incluso si son 0)
                if self?.isLoadingSteps == true {
                    self?.isLoadingSteps = false
                }
            }
            .store(in: &cancellables)
        
        // Observar el estado de loading del StepsService
        stepsService.$isLoading
            .sink { [weak self] isLoading in
                // Sincronizar el estado de loading
                if !isLoading && self?.isLoadingSteps == true {
                    self?.isLoadingSteps = false
                }
            }
            .store(in: &cancellables)
        
        // Observar cambios en el estado persistente de HealthKit
        healthKitPersistence.$isHeartRateAuthorized
            .sink { [weak self] isAuthorized in
                print("HealthKitCoordinator: Persistent heart rate authorization changed to: \(isAuthorized)")
                if isAuthorized && self?.healthKitAuthorized == false {
                    // Si el estado persistente dice que está autorizado pero el servicio no lo sabe
                    self?.healthKitAuthorized = true
                }
            }
            .store(in: &cancellables)
        
        // Observar cambios en el estado persistente de Steps
        healthKitPersistence.$isStepsAuthorized
            .sink { [weak self] isAuthorized in
                print("HealthKitCoordinator: Persistent steps authorization changed to: \(isAuthorized)")
                if isAuthorized && self?.stepsAuthorized == false {
                    // Si el estado persistente dice que está autorizado pero el servicio no lo sabe
                    self?.stepsAuthorized = true
                }
            }
            .store(in: &cancellables)
        
        // Timeout de seguridad para el loading de pasos (5 segundos)
        stepsService.$todaySteps
            .first()
            .delay(for: .seconds(5), scheduler: DispatchQueue.main)
            .sink { [weak self] _ in
                if self?.isLoadingSteps == true {
                    self?.isLoadingSteps = false
                }
            }
            .store(in: &cancellables)
        
        // Guardar pasos automáticamente cuando cambien
        stepsService.$todaySteps
            .filter { $0 > 0 } // Solo guardar si hay pasos
            .sink { [weak self] steps in
                self?.dailyStepsStorage.saveTodaySteps(steps)
            }
            .store(in: &cancellables)
        
        // Observar cambios en el UserPreferencesService
        userPreferencesService.$userProfile
            .map { $0.weightKg }
            .assign(to: \.userWeight, on: self)
            .store(in: &cancellables)
    }
} 