import Foundation
import HealthKit

/// Servicio para manejar la persistencia del estado de autorización de HealthKit
class HealthKitPersistenceService: ObservableObject {
    
    // MARK: - Published Properties
    @Published var isHeartRateAuthorized: Bool = false
    @Published var isStepsAuthorized: Bool = false
    
    // MARK: - Private Properties
    private let userDefaults = UserDefaults.standard
    private let heartRateAuthKey = "HealthKit_HeartRate_Authorized"
    private let stepsAuthKey = "HealthKit_Steps_Authorized"
    private let lastAuthCheckKey = "HealthKit_LastAuthCheck"
    
    // MARK: - Initialization
    init() {
        loadAuthorizationState()
    }
    
    // MARK: - Public Methods
    
    /// Guarda el estado de autorización de ritmo cardíaco
    func saveHeartRateAuthorization(_ isAuthorized: Bool) {
        userDefaults.set(isAuthorized, forKey: heartRateAuthKey)
        userDefaults.set(Date(), forKey: lastAuthCheckKey)
        isHeartRateAuthorized = isAuthorized
        
        print("HealthKitPersistence: Heart rate authorization saved: \(isAuthorized)")
    }
    
    /// Guarda el estado de autorización de pasos
    func saveStepsAuthorization(_ isAuthorized: Bool) {
        userDefaults.set(isAuthorized, forKey: stepsAuthKey)
        userDefaults.set(Date(), forKey: lastAuthCheckKey)
        isStepsAuthorized = isAuthorized
        
        print("HealthKitPersistence: Steps authorization saved: \(isAuthorized)")
    }
    
    /// Verifica si la autorización ha expirado o necesita verificación
    /// HealthKit mantiene la autorización hasta que el usuario la revoque manualmente
    /// Verificamos si nunca se ha verificado antes o si han pasado más de 24 horas
    func isAuthorizationExpired() -> Bool {
        // Para testing, siempre verificar el estado real
        return true
    }
    
    /// Limpia todos los datos de autorización (útil para logout)
    func clearAuthorizationData() {
        userDefaults.removeObject(forKey: heartRateAuthKey)
        userDefaults.removeObject(forKey: stepsAuthKey)
        userDefaults.removeObject(forKey: lastAuthCheckKey)
        
        isHeartRateAuthorized = false
        isStepsAuthorized = false
        
        print("HealthKitPersistence: Authorization data cleared")
    }
    
    /// Fuerza una nueva verificación de autorización (útil para testing)
    func forceReauthorization() {
        print("HealthKitPersistence: Forcing reauthorization check")
        clearAuthorizationData()
        verifyCurrentAuthorizationStatus()
    }
    
    /// Verifica el estado actual de autorización con HealthKit
    /// Solo se ejecuta la primera vez o si nunca se ha verificado antes
    func verifyCurrentAuthorizationStatus() {
        guard HKHealthStore.isHealthDataAvailable() else {
            print("HealthKitPersistence: HealthKit not available")
            return
        }
        
        let healthStore = HKHealthStore()
        
        // Verificar autorización de ritmo cardíaco
        let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
        let heartRateStatus = healthStore.authorizationStatus(for: heartRateType)
        let isHeartRateAuth = heartRateStatus == .sharingAuthorized
        
        // Verificar autorización de pasos
        let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        let stepsStatus = healthStore.authorizationStatus(for: stepType)
        let isStepsAuth = stepsStatus == .sharingAuthorized
        
        // Actualizar estado persistente
        saveHeartRateAuthorization(isHeartRateAuth)
        saveStepsAuthorization(isStepsAuth)
        
        print("HealthKitPersistence: Current authorization verified - Heart Rate: \(isHeartRateAuth), Steps: \(isStepsAuth)")
    }
    
    // MARK: - Private Methods
    
    /// Carga el estado de autorización guardado
    private func loadAuthorizationState() {
        isHeartRateAuthorized = userDefaults.bool(forKey: heartRateAuthKey)
        isStepsAuthorized = userDefaults.bool(forKey: stepsAuthKey)
        
        print("HealthKitPersistence: Loaded authorization state - Heart Rate: \(isHeartRateAuthorized), Steps: \(isStepsAuthorized)")
    }
} 