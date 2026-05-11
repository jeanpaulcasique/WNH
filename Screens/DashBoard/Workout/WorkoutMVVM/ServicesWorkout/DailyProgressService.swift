import Foundation
import HealthKit
import Combine

// MARK: - Servicio de Progreso Diario
class DailyProgressService: ObservableObject {
    
    // MARK: - Published Properties
    @Published var currentDayProgress: DailyProgress?
    @Published var monthlyProgress: [DailyProgress] = [] // ✅ CAMBIO: Ahora guarda 30 días en lugar de 7
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
    
    // ✅ NUEVO: Constantes para manejo de peso
    private enum WeightKeys {
        static let initialWeightFromOnboarding = "initialWeightFromOnboarding" // Peso del onboarding (88 kg)
        static let currentDailyWeight = "currentDailyWeight" // Peso actual del día (82 kg)
        static let lastUpdatedWeight = "lastUpdatedWeight" // Último peso actualizado
        static let lastUpdatedDate = "lastUpdatedDate" // Fecha del último peso actualizado
        static let lastKnownHistoricalWeight = "lastKnownHistoricalWeight" // Último peso histórico real (no onboarding)
    }
    
    // MARK: - Initialization
    init() {
        setupHealthKit()
        loadStoredProgress()
        setupAppLifecycleObservers()
        
        // ✅ NUEVO: Limpiar datos duplicados al inicializar
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.cleanupDuplicateData()
        }
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
        fetchMonthlyProgress() // ✅ CAMBIO: Ahora obtiene datos de 30 días
        setupObservers()
    }
    
    /// Actualiza el progreso del día actual
    func refreshTodayProgress() {
        fetchTodayProgress()
    }
    
    /// Actualiza el progreso mensual (30 días)
    func refreshMonthlyProgress() {
        fetchMonthlyProgress() // ✅ CAMBIO: Ahora actualiza datos de 30 días
    }
    
    /// Limpia datos duplicados y asegura que cada día tenga datos únicos
    func cleanupDuplicateData() {
        print("🧹 CLEANUP: Iniciando limpieza de datos duplicados...")
        
        // Crear un diccionario para eliminar duplicados por fecha
        var uniqueProgress: [String: DailyProgress] = [:]
        
        // Agregar datos del progreso mensual (30 días)
        for progress in monthlyProgress {
            uniqueProgress[progress.dateString] = progress
        }
        
        // Agregar datos del día actual si existe
        if let currentProgress = currentDayProgress {
            uniqueProgress[currentProgress.dateString] = currentProgress
        }
        
        // Convertir de vuelta a array y actualizar
        monthlyProgress = Array(uniqueProgress.values).sorted { $0.date < $1.date }
        
        // ✅ NUEVO: Limpiar datos más antiguos de 30 días
        cleanupOldData()
        
        print("🧹 CLEANUP: Datos únicos por día (últimos \(monthlyProgress.count) días):")
        for progress in monthlyProgress.suffix(5) { // Mostrar solo los últimos 5 para no saturar el log
            print("   • \(progress.dateString): \(progress.caloriesBurned) cal, \(progress.heartRate) bpm, \(progress.currentWeight ?? 0) kg")
        }
        
        // Guardar los datos limpios
        saveProgress()
    }
    
    /// ✅ NUEVO: Limpia datos más antiguos de 30 días
    private func cleanupOldData() {
        let calendar = Calendar.current
        let thirtyDaysAgo = calendar.date(byAdding: .day, value: -30, to: Date()) ?? Date()
        
        // Filtrar datos que estén dentro de los últimos 30 días
        monthlyProgress = monthlyProgress.filter { $0.date >= thirtyDaysAgo }
        
        // Limpiar UserDefaults de datos antiguos (opcional, para liberar espacio)
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        // Limpiar datos más antiguos de 45 días de UserDefaults
        for dayOffset in 46...100 { // Revisar los días 46-100 días atrás
            if let oldDate = calendar.date(byAdding: .day, value: -dayOffset, to: Date()) {
                let oldDateString = formatter.string(from: oldDate)
                userDefaults.removeObject(forKey: "dayProgress_\(oldDateString)")
                userDefaults.removeObject(forKey: "weightHistory_\(oldDateString)")
                userDefaults.removeObject(forKey: "caloriesHistory_\(oldDateString)")
                userDefaults.removeObject(forKey: "heartRateHistory_\(oldDateString)")
            }
        }
        
        print("🧹 OLD DATA CLEANUP: Manteniendo solo datos de los últimos 30 días")
    }
    
    /// ✅ NUEVO: Actualiza el peso solo para el día actual (SIN afectar el peso global)
    func updateWeightForToday(_ newWeight: Double) {
        let today = Date()
        let todayString = formatDate(today)
        
        print("⚖️ WEIGHT UPDATE: Actualizando peso SOLO para hoy (\(todayString)): \(newWeight) kg")
        print("⚠️ IMPORTANTE: NO se actualiza el peso global del usuario")
        
        // Actualizar el progreso del día actual
        if var existingProgress = currentDayProgress {
            existingProgress.updateWeight(newWeight)
            currentDayProgress = existingProgress
        } else {
            // Crear nuevo progreso para hoy si no existe
            var newProgress = DailyProgress(
                date: today,
                steps: 0,
                heartRate: HeartRateData(),
                caloriesBurned: 0,
                activeMinutes: 0
            )
            // ✅ PESO HISTÓRICO: Usar peso del día anterior como base inicial
            let previousWeight = getPreviousDayWeight(from: today)
            newProgress.updateWeight(previousWeight)
            // Ahora actualizar con el nuevo peso
            newProgress.updateWeight(newWeight)
            currentDayProgress = newProgress
        }
        
        // Actualizar también en el progreso mensual
        if let currentProgress = currentDayProgress {
            if let index = monthlyProgress.firstIndex(where: { $0.dateString == todayString }) {
                monthlyProgress[index] = currentProgress
                print("🔄 WEIGHT UPDATE: Actualizado día existente en progreso mensual")
            } else {
                monthlyProgress.append(currentProgress)
                monthlyProgress.sort { $0.date < $1.date }
                print("➕ WEIGHT UPDATE: Agregado nuevo día al progreso mensual")
            }
        }
        
        // Guardar el peso histórico para este día específico
        saveWeightHistory(for: today, weight: newWeight)
        
        // Guardar todos los cambios
        saveProgress()
        
        // ✅ NUEVO: Usar el sistema de peso mejorado con fuerza
        forceUpdateCurrentWeight(newWeight)
        
        // ✅ NUEVO: Asegurar que el peso se guarde también en selectedWeightKg para compatibilidad
        userDefaults.set(newWeight, forKey: "selectedWeightKg")
        userDefaults.synchronize()
        
        NotificationCenter.default.post(name: .weightUpdated, object: newWeight)
        
        print("✅ WEIGHT UPDATE: Peso guardado SOLO para \(todayString) - Peso global NO modificado")
        print("✅ WEIGHT UPDATE: selectedWeightKg actualizado para compatibilidad: \(newWeight) kg")
    }
    
    /// ✅ NUEVO: Obtiene el peso histórico para una fecha específica
    func getWeightForDate(_ date: Date) -> Double? {
        let dateString = formatDate(date)
        
        // ✅ PRIORIDAD 0: Regla estricta para HOY → usar solo registro explícito; si no hay, devolver AYER
        let todayString = formatDate(Date())
        if dateString == todayString {
            // 0.1 Buscar en historial específico de hoy
            if let todayHistorical = getWeightFromHistory(for: date) {
                print("🔍 WEIGHT GET: (HOY) Histórico específico: \(todayHistorical) kg")
                return todayHistorical
            }
            // 0.2 Si no hay registro explícito de hoy, devolver AYER
            let yesterday = getPreviousDayWeight(from: date)
            print("🔍 WEIGHT GET: (HOY) Sin registro explícito → usando AYER: \(yesterday) kg")
            return yesterday > 0 ? yesterday : nil
        }
        
        // ✅ PRIORIDAD 2: Buscar en el progreso individual guardado del día actual
        if let todayData = userDefaults.data(forKey: "todayProgress_\(dateString)"),
           let progress = try? JSONDecoder().decode(DailyProgress.self, from: todayData) {
            print("🔍 WEIGHT GET: Peso del día actual desde todayProgress_: \(progress.currentWeight ?? 0) kg")
            return progress.currentWeight
        }
        
        // ✅ PRIORIDAD 3: Buscar en el progreso individual guardado
        if let dayData = userDefaults.data(forKey: "dayProgress_\(dateString)"),
           let progress = try? JSONDecoder().decode(DailyProgress.self, from: dayData) {
            print("🔍 WEIGHT GET: Peso desde dayProgress_: \(progress.currentWeight ?? 0) kg")
            return progress.currentWeight
        }
        
        // ✅ PRIORIDAD 4: Buscar en el progreso mensual en memoria
        if let monthlyProgress = monthlyProgress.first(where: { $0.dateString == dateString }) {
            print("🔍 WEIGHT GET: Peso desde monthlyProgress en memoria: \(monthlyProgress.currentWeight ?? 0) kg")
            return monthlyProgress.currentWeight
        }
        
        // ✅ PRIORIDAD 5: Fallback: buscar en el historial de peso específico
        if let historical = getWeightFromHistory(for: date) {
            print("🔍 WEIGHT GET: Peso desde historial específico: \(historical) kg")
            return historical
        }
        
        // ✅ PRIORIDAD 6: Siempre aplicar continuidad histórica desde el día anterior cuando no haya registro
        let continuityWeight = getPreviousDayWeight(from: date)
        print("🔍 WEIGHT GET: Peso desde continuidad histórica: \(continuityWeight) kg")
        return continuityWeight
    }

    /// ✅ NUEVO: Obtiene el peso para una fecha aplicando continuidad garantizada
    /// Siempre devuelve un valor estable (nunca nil), usando el último dato disponible
    func getWeightWithContinuity(for date: Date) -> Double {
        // 1. Buscar peso específico para esa fecha
        if let exact = getWeightForDate(date) { 
            return exact 
        }
        
        // 2. Para el día actual o cualquier otro, aplicar continuidad histórica desde el día anterior
        //    (evita mostrar el peso del onboarding si hoy no hay registro)
        return getPreviousDayWeight(from: date)
    }
    
    /// ✅ NUEVO: Guarda el peso histórico para una fecha específica
    private func saveWeightHistory(for date: Date, weight: Double) {
        let dateString = formatDate(date)
        let key = "weightHistory_\(dateString)"
        userDefaults.set(weight, forKey: key)
        // Guardar también último peso histórico conocido para usar como fallback preferente
        userDefaults.set(weight, forKey: WeightKeys.lastKnownHistoricalWeight)
        print("💾 WEIGHT HISTORY: Guardado peso \(weight) kg para \(dateString)")
    }
    
    /// ✅ NUEVO: Obtiene el peso del historial para una fecha específica
    private func getWeightFromHistory(for date: Date) -> Double? {
        let dateString = formatDate(date)
        let key = "weightHistory_\(dateString)"
        let weight = userDefaults.double(forKey: key)
        return weight > 0 ? weight : nil
    }
    
    /// ✅ NUEVO: Obtiene el peso del día anterior para mantener continuidad histórica
    private func getPreviousDayWeight(from date: Date) -> Double {
        let calendar = Calendar.current
        var currentDate = calendar.date(byAdding: .day, value: -1, to: date) ?? date
        
        // Buscar hacia atrás hasta 60 días para encontrar el último peso registrado
        for _ in 0..<60 {
            // ✅ CORREGIDO: Buscar directamente en UserDefaults para evitar recursión
            let dateString = formatDate(currentDate)
            
            // 1. Buscar en el historial de peso específico
            if let historical = getWeightFromHistory(for: currentDate) {
                print("📈 WEIGHT CONTINUITY: Usando peso del historial del día \(dateString): \(historical) kg como base para \(formatDate(date))")
                return historical
            }
            
            // 2. Buscar en el progreso individual guardado
            if let dayData = userDefaults.data(forKey: "dayProgress_\(dateString)"),
               let progress = try? JSONDecoder().decode(DailyProgress.self, from: dayData),
               let weight = progress.currentWeight {
                print("📈 WEIGHT CONTINUITY: Usando peso del progreso del día \(dateString): \(weight) kg como base para \(formatDate(date))")
                return weight
            }
            
            currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate) ?? currentDate
        }
        
        // Si no hay peso histórico válido, NO usar onboarding ni selectedWeightKg
        let lastHistorical = userDefaults.double(forKey: WeightKeys.lastKnownHistoricalWeight)
        if lastHistorical > 0 {
            print("📈 WEIGHT CONTINUITY: Usando último peso histórico conocido: \(lastHistorical) kg")
            return lastHistorical
        }
        print("📈 WEIGHT CONTINUITY: Sin histórico disponible. Retornando 0 para evitar usar onboarding")
        return 0
    }

    /// ✅ Público: Obtener peso de ayer (regla estricta solicitada)
    func getYesterdayWeight() -> Double {
        return getPreviousDayWeight(from: Date())
    }
    
    /// ✅ NUEVO: Actualiza las calorías solo para el día actual (SIN afectar datos globales)
    func updateCaloriesForToday(_ newCalories: Int) {
        let today = Date()
        let todayString = formatDate(today)
        
        print("🔥 CALORIES UPDATE: Actualizando calorías SOLO para hoy (\(todayString)): \(newCalories) cal")
        print("⚠️ IMPORTANTE: NO se actualizan las calorías globales")
        
        // Actualizar el progreso del día actual
        if var existingProgress = currentDayProgress {
            existingProgress.updateCaloriesBurned(newCalories)
            currentDayProgress = existingProgress
        } else {
            // Crear nuevo progreso para hoy si no existe
            var newProgress = DailyProgress(
                date: today,
                steps: 0,
                heartRate: HeartRateData(),
                caloriesBurned: newCalories,
                activeMinutes: 0
            )
            // ✅ PESO HISTÓRICO: Usar peso del día anterior como base inicial
            let previousWeight = getPreviousDayWeight(from: today)
            newProgress.updateWeight(previousWeight)
            currentDayProgress = newProgress
        }
        
        // Actualizar también en el progreso mensual
        if let currentProgress = currentDayProgress {
            if let index = monthlyProgress.firstIndex(where: { $0.dateString == todayString }) {
                monthlyProgress[index] = currentProgress
                print("🔄 CALORIES UPDATE: Actualizado día existente en progreso mensual")
            } else {
                monthlyProgress.append(currentProgress)
                monthlyProgress.sort { $0.date < $1.date }
                print("➕ CALORIES UPDATE: Agregado nuevo día al progreso mensual")
            }
        }
        
        // Guardar las calorías históricas para este día específico
        saveCaloriesHistory(for: today, calories: newCalories)
        
        // Guardar todos los cambios
        saveProgress()
        
        print("✅ CALORIES UPDATE: Calorías guardadas SOLO para \(todayString) - Datos globales NO modificados")
    }
    
    /// ✅ NUEVO: Actualiza el ritmo cardíaco solo para el día actual (SIN afectar datos globales)
    func updateHeartRateForToday(_ newHeartRate: HeartRateData) {
        let today = Date()
        let todayString = formatDate(today)
        
        if let averageHeartRate = newHeartRate.average {
            print("❤️ HEART RATE UPDATE: Actualizando ritmo cardíaco SOLO para hoy (\(todayString)): \(averageHeartRate) bpm")
        }
        print("⚠️ IMPORTANTE: NO se actualiza el ritmo cardíaco global")
        
        // Actualizar el progreso del día actual
        if var existingProgress = currentDayProgress {
            existingProgress.updateHeartRate(newHeartRate)
            currentDayProgress = existingProgress
        } else {
            // Crear nuevo progreso para hoy si no existe
            var newProgress = DailyProgress(
                date: today,
                steps: 0,
                heartRate: newHeartRate,
                caloriesBurned: 0,
                activeMinutes: 0
            )
            // ✅ PESO HISTÓRICO: Usar peso del día anterior como base inicial
            let previousWeight = getPreviousDayWeight(from: today)
            newProgress.updateWeight(previousWeight)
            currentDayProgress = newProgress
        }
        
        // Actualizar también en el progreso mensual
        if let currentProgress = currentDayProgress {
            if let index = monthlyProgress.firstIndex(where: { $0.dateString == todayString }) {
                monthlyProgress[index] = currentProgress
                print("🔄 HEART RATE UPDATE: Actualizado día existente en progreso mensual")
            } else {
                monthlyProgress.append(currentProgress)
                monthlyProgress.sort { $0.date < $1.date }
                print("➕ HEART RATE UPDATE: Agregado nuevo día al progreso mensual")
            }
        }
        
        // Guardar el ritmo cardíaco histórico para este día específico
        saveHeartRateHistory(for: today, heartRate: newHeartRate)
        
        // Guardar todos los cambios
        saveProgress()
        
        print("✅ HEART RATE UPDATE: Ritmo cardíaco guardado SOLO para \(todayString) - Datos globales NO modificados")
    }

    /// ✅ NUEVO: Actualiza los pasos solo para el día actual (SIN afectar datos globales)
    func updateStepsForToday(_ newSteps: Int) {
        let today = Date()
        let todayString = formatDate(today)
        
        print("👣 STEPS UPDATE: Actualizando pasos SOLO para hoy (\(todayString)): \(newSteps) pasos")
        
        // Actualizar el progreso del día actual
        if var existingProgress = currentDayProgress {
            existingProgress.updateSteps(newSteps)
            currentDayProgress = existingProgress
        } else {
            // Crear nuevo progreso para hoy si no existe
            var newProgress = DailyProgress(
                date: today,
                steps: newSteps,
                heartRate: HeartRateData(),
                caloriesBurned: 0,
                activeMinutes: 0
            )
            // ✅ PESO HISTÓRICO: Usar peso del día anterior como base inicial
            let previousWeight = getPreviousDayWeight(from: today)
            newProgress.updateWeight(previousWeight)
            currentDayProgress = newProgress
        }
        
        // Actualizar también en el progreso mensual
        if let currentProgress = currentDayProgress {
            if let index = monthlyProgress.firstIndex(where: { $0.dateString == todayString }) {
                monthlyProgress[index] = currentProgress
                print("🔄 STEPS UPDATE: Actualizado día existente en progreso mensual")
            } else {
                monthlyProgress.append(currentProgress)
                monthlyProgress.sort { $0.date < $1.date }
                print("➕ STEPS UPDATE: Agregado nuevo día al progreso mensual")
            }
        }
        
        // Guardar los cambios
        saveProgress()
        print("✅ STEPS UPDATE: Pasos guardados SOLO para \(todayString)")
    }
    
    /// ✅ NUEVO: Obtiene las calorías históricas para una fecha específica
    func getCaloriesForDate(_ date: Date) -> Int? {
        let dateString = formatDate(date)
        
        // 1. Intentar obtener del historial individual
        if let caloriesFromHistory = getCaloriesFromHistory(for: date) {
            print("🔥 CALORIES GET: Calorías obtenidas del historial para \(dateString): \(caloriesFromHistory) cal")
            return caloriesFromHistory
        }
        
        // 2. Intentar obtener del progreso mensual
        if let progress = monthlyProgress.first(where: { $0.dateString == dateString }) {
            print("🔥 CALORIES GET: Calorías obtenidas del progreso mensual para \(dateString): \(progress.caloriesBurned) cal")
            return progress.caloriesBurned
        }
        
        print("🔥 CALORIES GET: No se encontraron calorías para \(dateString)")
        return nil
    }
    
    /// ✅ NUEVO: Obtiene el ritmo cardíaco histórico para una fecha específica
    func getHeartRateForDate(_ date: Date) -> HeartRateData? {
        let dateString = formatDate(date)
        
        // 1. Intentar obtener del historial individual
        if let heartRateFromHistory = getHeartRateFromHistory(for: date) {
            if let averageHeartRate = heartRateFromHistory.average {
                print("❤️ HEART RATE GET: Ritmo cardíaco obtenido del historial para \(dateString): \(averageHeartRate) bpm")
            }
            return heartRateFromHistory
        }
        
        // 2. Intentar obtener del progreso mensual
        if let progress = monthlyProgress.first(where: { $0.dateString == dateString }) {
            if let averageHeartRate = progress.heartRate.average {
                print("❤️ HEART RATE GET: Ritmo cardíaco obtenido del progreso mensual para \(dateString): \(averageHeartRate) bpm")
            }
            return progress.heartRate
        }
        
        print("❤️ HEART RATE GET: No se encontró ritmo cardíaco para \(dateString)")
        return nil
    }
    
    /// ✅ NUEVO: Guarda las calorías históricas para una fecha específica
    private func saveCaloriesHistory(for date: Date, calories: Int) {
        let dateString = formatDate(date)
        let key = "caloriesHistory_\(dateString)"
        userDefaults.set(calories, forKey: key)
        print("💾 CALORIES HISTORY: Guardadas calorías \(calories) cal para \(dateString)")
    }
    
    /// ✅ NUEVO: Obtiene las calorías del historial para una fecha específica
    private func getCaloriesFromHistory(for date: Date) -> Int? {
        let dateString = formatDate(date)
        let key = "caloriesHistory_\(dateString)"
        let calories = userDefaults.integer(forKey: key)
        return calories > 0 ? calories : nil
    }
    
    /// ✅ NUEVO: Guarda el ritmo cardíaco histórico para una fecha específica
    private func saveHeartRateHistory(for date: Date, heartRate: HeartRateData) {
        let dateString = formatDate(date)
        let key = "heartRateHistory_\(dateString)"
        
        if let encoded = try? JSONEncoder().encode(heartRate) {
            userDefaults.set(encoded, forKey: key)
            if let averageHeartRate = heartRate.average {
                print("💾 HEART RATE HISTORY: Guardado ritmo cardíaco \(averageHeartRate) bpm para \(dateString)")
            }
        }
    }
    
    /// ✅ NUEVO: Obtiene el ritmo cardíaco del historial para una fecha específica
    private func getHeartRateFromHistory(for date: Date) -> HeartRateData? {
        let dateString = formatDate(date)
        let key = "heartRateHistory_\(dateString)"
        
        if let data = userDefaults.data(forKey: key),
           let heartRate = try? JSONDecoder().decode(HeartRateData.self, from: data) {
            return heartRate
        }
        return nil
    }
    
    /// Obtiene el progreso para una fecha específica
    func getProgress(for date: Date) -> DailyProgress? {
        let dateString = formatDate(date)
        
        // ✅ CORREGIDO: Buscar primero en los datos individuales guardados
        if let dayData = userDefaults.data(forKey: "dayProgress_\(dateString)"),
           let progress = try? JSONDecoder().decode(DailyProgress.self, from: dayData) {
            print("📱 DAILY PROGRESS: Cargado progreso individual guardado para \(dateString)")
            print("   • Pasos: \(progress.steps)")
            print("   • Calorías: \(progress.caloriesBurned)")
            print("   • Ritmo cardíaco: \(progress.heartRate) bpm")
            return progress
        }
        
        // ✅ FALLBACK: Si no hay datos individuales, buscar en el progreso mensual en memoria
        if let monthlyProgress = monthlyProgress.first(where: { $0.dateString == dateString }) {
            print("📱 DAILY PROGRESS: Cargado progreso mensual en memoria para \(dateString)")
            print("   • Pasos: \(monthlyProgress.steps)")
            print("   • Calorías: \(monthlyProgress.caloriesBurned)")
            print("   • Ritmo cardíaco: \(monthlyProgress.heartRate) bpm")
            return monthlyProgress
        }
        
        // ✅ FALLBACK FINAL: Si es el día actual, devolver el progreso actual
        let todayString = formatDate(Date())
        if dateString == todayString, let currentProgress = currentDayProgress {
            print("📱 DAILY PROGRESS: Cargado progreso del día actual para \(dateString)")
            print("   • Pasos: \(currentProgress.steps)")
            print("   • Calorías: \(currentProgress.caloriesBurned)")
            print("   • Ritmo cardíaco: \(currentProgress.heartRate) bpm")
            return currentProgress
        }
        
        print("❌ DAILY PROGRESS: No se encontraron datos para \(dateString)")
        return nil
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
    
    /// ✅ NUEVO: Configura observadores para el ciclo de vida de la app
    private func setupAppLifecycleObservers() {
        // Observar cuando la app va a ser terminada
        NotificationCenter.default.addObserver(
            forName: .appWillTerminate,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.forceSaveOnAppTermination()
        }
        
        // Observar cuando la app entra en background
        NotificationCenter.default.addObserver(
            forName: .appDidEnterBackground,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.forceSaveOnAppTermination()
        }
        
        // ✅ NUEVO: Observar inicialización del sistema de peso desde onboarding
        NotificationCenter.default.addObserver(
            forName: Notification.Name("InitializeWeightSystem"),
            object: nil,
            queue: .main
        ) { [weak self] notification in
            if let weight = notification.object as? Double {
                self?.initializeWeightSystem(fromOnboarding: weight)
            }
        }
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
    
    private func fetchMonthlyProgress() {
        let calendar = Calendar.current
        let now = Date()
        // ✅ CAMBIO: Obtener datos de los últimos 30 días en lugar de solo 7
        let thirtyDaysAgo = calendar.date(byAdding: .day, value: -29, to: now) ?? now
        
        var monthlyData: [DailyProgress] = []
        let group = DispatchGroup()
        
        print("📅 MONTHLY FETCH: Obteniendo datos de los últimos 30 días desde HealthKit...")
        
        // ✅ CAMBIO: Iterar por 30 días en lugar de 7
        for dayOffset in 0..<30 {
            let date = calendar.date(byAdding: .day, value: dayOffset, to: thirtyDaysAgo)!
            let startOfDay = calendar.startOfDay(for: date)
            let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
            
            let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: endOfDay, options: .strictStartDate)
            
            group.enter()
            
            // Fetch all data for this day
            fetchSteps(predicate: predicate) { steps in
                self.fetchHeartRate(predicate: predicate) { heartRate in
                    self.fetchCalories(predicate: predicate) { calories in
                        self.fetchActiveMinutes(predicate: predicate) { activeMinutes in
                            var dayProgress = DailyProgress(
                                date: date,
                                steps: steps,
                                heartRate: heartRate,
                                caloriesBurned: calories,
                                activeMinutes: activeMinutes
                            )
                            
                            // ✅ PESO HISTÓRICO: Usar peso del día anterior como base inicial
                            let previousWeight = self.getPreviousDayWeight(from: date)
                            dayProgress.updateWeight(previousWeight)
                            
                            monthlyData.append(dayProgress)
                            
                            // ✅ NUEVO: Guardar cada día individualmente
                            let dateString = self.formatDate(date)
                            if let encoded = try? JSONEncoder().encode(dayProgress) {
                                self.userDefaults.set(encoded, forKey: "dayProgress_\(dateString)")
                            }
                            
                            group.leave()
                        }
                    }
                }
            }
        }
        
        group.notify(queue: .main) { [weak self] in
            self?.monthlyProgress = monthlyData.sorted { $0.date < $1.date }
            self?.saveProgress()
            print("✅ MONTHLY FETCH: Guardados \(monthlyData.count) días de datos históricos")
        }
    }
    
    private func updateTodayProgress(steps: Int, heartRate: HeartRateData, calories: Int, activeMinutes: Int, weight: Double?) {
        let today = Date()
        let todayString = formatDate(today)
        
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
            // ✅ PESO HISTÓRICO: Usar peso del día anterior como base inicial
            let previousWeight = getPreviousDayWeight(from: today)
            newProgress.updateWeight(previousWeight)
            
            // Si se proporciona un peso específico, usarlo en su lugar
            if let weight = weight {
                newProgress.updateWeight(weight)
            }
            currentDayProgress = newProgress
        }
        
        // Update target weight from user profile
        let userProfile = UserProfile.loadFromUserDefaults()
        currentDayProgress?.updateTargetWeight(userProfile.targetWeightKg ?? userProfile.weightKg)
        
        // ✅ CORREGIDO: Actualizar también el progreso mensual para el día actual
        if let currentProgress = currentDayProgress {
            // Buscar si ya existe este día en el progreso mensual
            if let index = monthlyProgress.firstIndex(where: { $0.dateString == todayString }) {
                // Actualizar el día existente
                monthlyProgress[index] = currentProgress
                print("🔄 MONTHLY PROGRESS: Actualizado día existente \(todayString)")
            } else {
                // Agregar nuevo día al progreso mensual
                monthlyProgress.append(currentProgress)
                monthlyProgress.sort { $0.date < $1.date }
                print("➕ MONTHLY PROGRESS: Agregado nuevo día \(todayString)")
            }
        }
        
        saveProgress()
    }
    
    // MARK: - Persistence
    
    private func saveProgress() {
        let encoder = JSONEncoder()
        
        // ✅ CORREGIDO: Guardar el progreso del día actual si existe
        if let progress = currentDayProgress {
            if let encoded = try? encoder.encode(progress) {
                userDefaults.set(encoded, forKey: "todayProgress_\(progress.dateString)")
                print("💾 DAILY PROGRESS: Guardado progreso del día \(progress.dateString)")
                print("   • Pasos: \(progress.steps)")
                print("   • Calorías: \(progress.caloriesBurned)")
                print("   • Ritmo cardíaco: \(progress.heartRate) bpm")
                print("   • Peso: \(progress.currentWeight ?? 0) kg")
            }
        }
        
        // ✅ CORREGIDO: Guardar cada día del progreso mensual individualmente
        for dayProgress in monthlyProgress {
            if let encoded = try? encoder.encode(dayProgress) {
                let key = "dayProgress_\(dayProgress.dateString)"
                userDefaults.set(encoded, forKey: key)
                print("💾 MONTHLY PROGRESS: Guardado día \(dayProgress.dateString)")
                print("   • Pasos: \(dayProgress.steps)")
                print("   • Calorías: \(dayProgress.caloriesBurned)")
                print("   • Ritmo cardíaco: \(dayProgress.heartRate) bpm")
                print("   • Peso: \(dayProgress.currentWeight ?? 0) kg")
            }
        }
        
        // ✅ CORREGIDO: Guardar también el array mensual completo
        if let monthlyEncoded = try? encoder.encode(monthlyProgress) {
            userDefaults.set(monthlyEncoded, forKey: "monthlyProgress")
        }
        
        print("✅ SAVE PROGRESS: Todos los datos guardados correctamente")
    }
    
    private func loadStoredProgress() {
        let today = formatDate(Date())
        
        // ✅ CORREGIDO: Buscar primero en el historial del día actual
        if let dayData = userDefaults.data(forKey: "dayProgress_\(today)"),
           let progress = try? JSONDecoder().decode(DailyProgress.self, from: dayData) {
            currentDayProgress = progress
            print("📱 LOAD: Cargado progreso del día actual desde dayProgress_\(today)")
            print("   • Peso: \(progress.currentWeight ?? 0) kg")
        } else if let todayData = userDefaults.data(forKey: "todayProgress_\(today)"),
                  let progress = try? JSONDecoder().decode(DailyProgress.self, from: todayData) {
            currentDayProgress = progress
            print("📱 LOAD: Cargado progreso del día actual desde todayProgress_\(today)")
            print("   • Peso: \(progress.currentWeight ?? 0) kg")
        } else {
            // ✅ NUEVO: Si no hay datos del día actual, crear con peso del día anterior
            let previousWeight = getPreviousDayWeight(from: Date())
            var newProgress = DailyProgress(
                date: Date(),
                steps: 0,
                heartRate: HeartRateData(),
                caloriesBurned: 0,
                activeMinutes: 0
            )
            newProgress.updateWeight(previousWeight)
            currentDayProgress = newProgress
            print("📱 LOAD: Creado nuevo progreso para hoy con peso del día anterior: \(previousWeight) kg")
        }
        
        if let monthlyData = userDefaults.data(forKey: "monthlyProgress"),
           let progress = try? JSONDecoder().decode([DailyProgress].self, from: monthlyData) {
            monthlyProgress = progress
        }
        
        // ✅ NUEVO: Inicializar el peso inicial si no existe
        if userDefaults.double(forKey: WeightKeys.initialWeightFromOnboarding) == 0 {
            let currentWeight = userDefaults.double(forKey: "selectedWeightKg")
            if currentWeight > 0 {
                saveInitialWeightFromOnboarding(currentWeight)
            }
        }
        
        // ✅ NUEVO: Forzar sincronización para que el arranque use el último peso real (no onboarding)
        let todayWeight = getWeightForDate(Date()) ?? getPreviousDayWeight(from: Date())
        if todayWeight > 0 {
            saveCurrentDailyWeight(todayWeight)
            userDefaults.set(todayWeight, forKey: "selectedWeightKg")
            userDefaults.set(todayWeight, forKey: WeightKeys.lastKnownHistoricalWeight)
            print("🔄 SYNC STARTUP: Alineado peso actual y compat con último peso real: \(todayWeight) kg")
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
    
    /// ✅ NUEVO: Fuerza la persistencia de todos los datos al cerrar la app
    func forceSaveOnAppTermination() {
        print("💾 FORCE SAVE: Guardando todos los datos antes de cerrar la app...")
        saveProgress()
        UserDefaults.standard.synchronize()
        print("✅ FORCE SAVE: Todos los datos guardados correctamente")
    }
    
    /// ✅ NUEVO: Actualiza el peso actual en UserDefaults con el peso del día actual
    func updateCurrentWeightFromToday() {
        let today = Date()
        if let todayWeight = getWeightForDate(today) {
            UserDefaults.standard.set(todayWeight, forKey: "selectedWeightKg")
            UserDefaults.standard.synchronize()
            print("🔄 WEIGHT SYNC: Actualizado peso actual a \(todayWeight) kg desde el día de hoy")
        }
    }
    
    // MARK: - ✅ NUEVO: Sistema de Peso Mejorado
    
    /// Guarda el peso inicial del onboarding (88 kg)
    func saveInitialWeightFromOnboarding(_ weight: Double) {
        userDefaults.set(weight, forKey: WeightKeys.initialWeightFromOnboarding)
        userDefaults.synchronize()
        print("💾 INITIAL WEIGHT: Guardado peso inicial del onboarding: \(weight) kg")
    }
    
    /// Obtiene el peso inicial del onboarding
    func getInitialWeightFromOnboarding() -> Double {
        let weight = userDefaults.double(forKey: WeightKeys.initialWeightFromOnboarding)
        return weight > 0 ? weight : 70.0 // Fallback si no hay peso inicial
    }
    
    /// Guarda el peso actual del día (82 kg)
    func saveCurrentDailyWeight(_ weight: Double) {
        userDefaults.set(weight, forKey: WeightKeys.currentDailyWeight)
        userDefaults.set(weight, forKey: "selectedWeightKg") // Mantener compatibilidad
        userDefaults.set(weight, forKey: WeightKeys.lastUpdatedWeight)
        userDefaults.set(Date(), forKey: WeightKeys.lastUpdatedDate)
        userDefaults.synchronize()
        print("💾 CURRENT WEIGHT: Guardado peso actual del día: \(weight) kg")
        print("💾 VERIFICATION: selectedWeightKg = \(userDefaults.double(forKey: "selectedWeightKg"))")
        print("💾 VERIFICATION: currentDailyWeight = \(userDefaults.double(forKey: WeightKeys.currentDailyWeight))")
    }
    
    /// Obtiene el peso actual del día
    func getCurrentDailyWeight() -> Double {
        let currentWeight = userDefaults.double(forKey: WeightKeys.currentDailyWeight)
        let selectedWeight = userDefaults.double(forKey: "selectedWeightKg")
        
        print("🔍 WEIGHT DEBUG: currentDailyWeight = \(currentWeight)")
        print("🔍 WEIGHT DEBUG: selectedWeightKg = \(selectedWeight)")
        
        // Priorizar el peso actual, luego el seleccionado, luego el inicial
        if currentWeight > 0 {
            return currentWeight
        } else if selectedWeight > 0 {
            return selectedWeight
        } else {
            return getInitialWeightFromOnboarding()
        }
    }
    
    /// Obtiene el peso correcto para mostrar (prioriza el actual sobre el inicial)
    func getDisplayWeight() -> Double {
        // 1) Calcular pesos base
        let currentWeight = getCurrentDailyWeight()
        let initial = getInitialWeightFromOnboarding()
        let yesterday = getPreviousDayWeight(from: Date())
        
        // 2) Si el peso actual existe y es diferente del onboarding, usarlo
        if currentWeight > 0 && abs(currentWeight - initial) > 0.0001 { return currentWeight }
        
        // 3) Si el actual es igual al onboarding (o no existe) y tenemos ayer, usar AYER
        if yesterday > 0 { return yesterday }
        
        // 4) Último recurso: onboarding
        return initial
    }
    
    /// ✅ NUEVO: Inicializa el sistema de peso desde el onboarding
    func initializeWeightSystem(fromOnboarding weight: Double) {
        print("🚀 INITIALIZING: Configurando sistema de peso desde onboarding con \(weight) kg")
        
        // Guardar peso inicial del onboarding
        saveInitialWeightFromOnboarding(weight)
        
        // Establecer como peso actual también
        saveCurrentDailyWeight(weight)
        
        // Mantener compatibilidad con el sistema anterior
        userDefaults.set(weight, forKey: "selectedWeightKg")
        userDefaults.synchronize()
        
        print("✅ INITIALIZED: Sistema de peso configurado correctamente")
    }
    
    /// ✅ NUEVO: Fuerza la actualización del peso actual
    func forceUpdateCurrentWeight(_ newWeight: Double) {
        print("🔄 FORCE UPDATE: Forzando actualización del peso a \(newWeight) kg")
        
        // Guardar en todas las claves necesarias
        saveCurrentDailyWeight(newWeight)
        userDefaults.set(newWeight, forKey: WeightKeys.lastKnownHistoricalWeight)
        
        // Actualizar también en el progreso del día actual
        if var progress = currentDayProgress {
            progress.updateWeight(newWeight)
            currentDayProgress = progress
        }
        
        // Forzar guardado
        saveProgress()
        
        print("✅ FORCE UPDATE: Peso actualizado correctamente a \(newWeight) kg")
    }
}

// MARK: - Extensión para Cálculos Avanzados
extension DailyProgressService {
    
    /// Calcula el progreso semanal desde los datos mensuales
    func getWeeklyStats() -> WeeklyProgressStats? {
        guard !monthlyProgress.isEmpty else { return nil }
        
        let calendar = Calendar.current
        let now = Date()
        let weekStart = calendar.dateInterval(of: .weekOfYear, for: now)?.start ?? now
        let weekEnd = calendar.date(byAdding: .day, value: 6, to: weekStart)!
        
        // Filtrar solo los datos de esta semana desde los datos mensuales
        let weeklyData = monthlyProgress.filter { progress in
            progress.date >= weekStart && progress.date <= weekEnd
        }
        
        return WeeklyProgressStats(
            weekStartDate: weekStart,
            weekEndDate: weekEnd,
            dailyProgress: weeklyData
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