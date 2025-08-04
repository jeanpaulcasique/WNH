import Foundation
import HealthKit
import Combine

/// Servicio dedicado para manejar datos de pasos desde HealthKit
class StepsService: ObservableObject {
    
    // MARK: - Published Properties
    @Published var isAuthorized: Bool = false
    @Published var todaySteps: Int = 0
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    // MARK: - Private Properties
    private let healthStore = HKHealthStore()
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    init() {
        checkAuthorizationStatus()
    }
    
    // MARK: - Public Methods
    
    /// Solicita autorización para acceder a los datos de pasos
    func requestAuthorization() {
        print("StepsService: Requesting authorization")
        
        guard HKHealthStore.isHealthDataAvailable() else {
            print("StepsService: HealthKit no está disponible en este dispositivo")
            errorMessage = "HealthKit no está disponible en este dispositivo"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        
        healthStore.requestAuthorization(toShare: nil, read: [stepType]) { [weak self] success, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                if success {
                    print("StepsService: Authorization successful")
                    self?.isAuthorized = true
                    self?.fetchTodaySteps()
                } else {
                    print("StepsService: Authorization failed: \(error?.localizedDescription ?? "Unknown error")")
                    self?.errorMessage = error?.localizedDescription ?? "No se pudo obtener autorización para los pasos"
                }
            }
        }
    }
    
    /// Obtiene los pasos del día actual
    func fetchTodaySteps() {
        guard isAuthorized else { 
            print("StepsService: Not authorized, using test data")
            // ✅ TEMPORAL: Usar datos de prueba si no está autorizado
            DispatchQueue.main.async {
                self.todaySteps = 8472 // Datos de prueba
                print("StepsService: Using test data - \(self.todaySteps) steps")
            }
            return 
        }
        
        print("StepsService: Fetching today's steps")
        isLoading = true
        errorMessage = nil
        
        let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
        
        let query = HKStatisticsQuery(quantityType: stepType, quantitySamplePredicate: predicate, options: .cumulativeSum) { [weak self] _, result, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let error = error {
                    print("StepsService: Error fetching steps: \(error.localizedDescription)")
                    self?.errorMessage = error.localizedDescription
                    return
                }
                
                if let sum = result?.sumQuantity() {
                    let steps = Int(sum.doubleValue(for: HKUnit.count()))
                    print("StepsService: Fetched \(steps) steps")
                    self?.todaySteps = steps
                } else {
                    print("StepsService: No steps data available")
                    self?.todaySteps = 0
                }
            }
        }
        
        healthStore.execute(query)
    }
    
    /// Inicia el monitoreo en tiempo real de pasos
    func startStepsMonitoring() {
        guard isAuthorized else { return }
        
        let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        
        let query = HKObserverQuery(sampleType: stepType, predicate: nil) { [weak self] _, _, error in
            if error == nil {
                DispatchQueue.main.async {
                    self?.fetchTodaySteps()
                }
            }
        }
        
        healthStore.execute(query)
        
        // Habilitar actualizaciones en background
        healthStore.enableBackgroundDelivery(for: stepType, frequency: .immediate) { success, error in
            if let error = error {
                print("Error enabling background delivery: \(error.localizedDescription)")
            }
        }
    }
    
    /// Detiene el monitoreo de pasos
    func stopStepsMonitoring() {
        // En una implementación más compleja, aquí se detendrían las queries
        // Por ahora, solo limpiamos los datos
        todaySteps = 0
    }
    
    // MARK: - Private Methods
    
    /// Verifica el estado de autorización actual
    private func checkAuthorizationStatus() {
        guard HKHealthStore.isHealthDataAvailable() else {
            print("StepsService: HealthKit no está disponible para pasos")
            isAuthorized = false
            return
        }
        
        let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        
        let status = healthStore.authorizationStatus(for: stepType)
        print("StepsService: Authorization status: \(status.rawValue)")
        
        isAuthorized = status == .sharingAuthorized
        print("StepsService: isAuthorized set to: \(isAuthorized)")
        
        if isAuthorized {
            print("StepsService: Already authorized, fetching today's steps")
            fetchTodaySteps()
        } else {
            print("StepsService: Not authorized, using test data")
            // ✅ TEMPORAL: Usar datos de prueba si no está autorizado
            DispatchQueue.main.async {
                self.todaySteps = 8472 // Datos de prueba
                print("StepsService: Using test data - \(self.todaySteps) steps")
            }
        }
    }
    
    // MARK: - Deinit
    deinit {
        stopStepsMonitoring()
    }
} 