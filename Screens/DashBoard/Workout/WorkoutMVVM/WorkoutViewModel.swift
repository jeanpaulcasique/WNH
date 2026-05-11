import SwiftUI
import Combine
import HealthKit

/// ViewModel principal que coordina todos los servicios de workout
class WorkoutViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var muscleGroups: [MuscleGroup] = []
    @Published var selectedMuscle: MuscleGroup?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isShowingBack = false
    @Published var selectedWorkoutMode: WorkoutLocation = .atHome
    @Published var searchText: String = ""
    @Published var allExercises: [Exercise] = []
    @Published var filteredExercises: [Exercise] = []
    @Published var selectedMuscleFilter: String? = nil
    @Published var positionsLoaded: Bool = false
    
    // MARK: - HealthKit Properties
    @Published var heartRate: Double? = nil
    @Published var userWeight: Double? = nil
    @Published var todaySteps: Int = 0
    @Published var isLoadingHeartRate: Bool = false
    @Published var isLoadingSteps: Bool = false
    @Published var healthKitAuthorized: Bool = false
    @Published var stepsAuthorized: Bool = false
    
    // MARK: - Debug Properties
    @Published var debugPositions: Bool = false
    @Published var forceReload: Bool = false
    
    // MARK: - Services
    private let workoutService: WorkoutService
    private let progressService: ProgressService
    private let healthKitService: HealthKitService
    let stepsService: StepsService
    private let dailyStepsStorage: DailyStepsStorageService
    let userPreferencesService: UserPreferencesService
    private let healthKitPersistence: HealthKitPersistenceService
    private let performanceOptimizer: PerformanceOptimizer
    private let templateService: WorkoutTemplateService
    let dailyProgressService: DailyProgressService
    
    // MARK: - Private Properties
    private var cancellables = Set<AnyCancellable>()
    private var frontMuscleGroups: [MuscleGroup] = []
    private var backMuscleGroups: [MuscleGroup] = []
    
    // MARK: - Initialization
    init() {
        self.workoutService = WorkoutService()
        self.progressService = ProgressService()
        self.healthKitService = HealthKitService()
        self.stepsService = StepsService()
        self.dailyStepsStorage = DailyStepsStorageService()
        self.userPreferencesService = UserPreferencesService()
        self.healthKitPersistence = HealthKitPersistenceService()
        self.performanceOptimizer = PerformanceOptimizer()
        self.templateService = WorkoutTemplateService(userPreferencesService: userPreferencesService, progressService: progressService)
        self.dailyProgressService = DailyProgressService()
        
        setupBindings()
        loadPositionsSynchronously()
    }
    
    // MARK: - HealthKit Methods
    
    /// Obtiene los pasos para una fecha específica
    func getStepsForDate(_ date: Date) -> Int {
        // Para el día actual, usar todaySteps
        if Calendar.current.isDateInToday(date) {
            return todaySteps
        }
        
        // Usar DailyProgressService para datos reales
        if let progress = dailyProgressService.getProgress(for: date) {
            return progress.steps
        }
        // Fallback al sistema anterior
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
        return dailyProgressService.currentDayProgress?.steps ?? userPreferencesService.recommendedDailySteps
    }
    
    /// Obtiene los pasos actuales del día
    func getTodaySteps() -> Int {
        return todaySteps
    }
    
    /// Obtiene las calorías quemadas hoy
    func getTodayCalories() -> Int {
        return dailyProgressService.currentDayProgress?.caloriesBurned ?? 0
    }
    
    /// Obtiene los minutos activos hoy
    func getTodayActiveMinutes() -> Int {
        return dailyProgressService.currentDayProgress?.activeMinutes ?? 0
    }
    
    /// Obtiene el ritmo cardíaco promedio hoy
    func getTodayHeartRate() -> Int? {
        return dailyProgressService.currentDayProgress?.heartRate.average
    }
    
    /// Actualiza los datos de progreso diario
    func refreshDailyProgress() {
        dailyProgressService.refreshTodayProgress()
    }
    
    /// Inicia el monitoreo de datos de HealthKit
    func startHealthKitMonitoring() {
        dailyProgressService.startMonitoring()
    }
    
    /// Obtiene el ritmo cardíaco promedio para una fecha específica
    func getHeartRateForDate(_ date: Date) -> Double? {
        return heartRate
    }
    
    /// Obtiene el ritmo cardíaco para una fecha específica desde HealthKit
    func getHeartRateForDateFromHealthKit(_ date: Date, completion: @escaping (Double?) -> Void) {
        healthKitService.getHeartRateForDate(date, completion: completion)
    }
    
    /// Obtiene las calorías activas quemadas para una fecha específica
    func getActiveCaloriesForDate(_ date: Date, completion: @escaping (Double) -> Void) {
        healthKitService.getActiveCaloriesForDate(date, completion: completion)
    }
    
    /// Obtiene los pasos para una fecha específica desde HealthKit
    func getStepsForDateFromHealthKit(_ date: Date, completion: @escaping (Int?) -> Void) {
        healthKitService.getStepsForDate(date, completion: completion)
    }
    
    /// Guarda los pasos del día actual
    func saveTodaySteps(_ steps: Int) {
        // ✅ Actualizar almacenamiento antiguo para compatibilidad
        dailyStepsStorage.saveTodaySteps(steps)
        // ✅ Actualizar estado vivo
        self.todaySteps = steps
        // ✅ Sincronizar con DailyProgressService para mantener consistencia
        dailyProgressService.updateStepsForToday(steps)
    }
    
    /// Solicita autorización de HealthKit
    func requestHealthKitAuthorization() {
        healthKitService.requestAuthorization()
        // Observar cambios en el estado de autorización
        healthKitService.$isAuthorized
            .sink { [weak self] authorized in
                DispatchQueue.main.async {
                    self?.healthKitAuthorized = authorized
                    if authorized {
                        self?.loadHealthDataIfAuthorized()
                    }
                }
            }
            .store(in: &cancellables)
    }
    
    /// Solicita autorización de pasos
    func requestStepsAuthorization() {
        stepsService.requestAuthorization()
        // Observar cambios en el estado de autorización
        stepsService.$isAuthorized
            .sink { [weak self] authorized in
                DispatchQueue.main.async {
                    self?.stepsAuthorized = authorized
                    if authorized {
                        self?.loadHealthDataIfAuthorized()
                    }
                }
            }
            .store(in: &cancellables)
    }
    
    /// Carga datos de HealthKit automáticamente si están autorizados
    private func loadHealthDataIfAuthorized() {
        // Verificar si la autorización ha expirado
        if healthKitPersistence.isAuthorizationExpired() {
            healthKitPersistence.verifyCurrentAuthorizationStatus()
        }
        
        // Usar estado persistente si los servicios no han actualizado aún
        let shouldLoadHeartRate = healthKitAuthorized || healthKitPersistence.isHeartRateAuthorized
        let shouldLoadSteps = stepsAuthorized || healthKitPersistence.isStepsAuthorized
        
        // Iniciar monitoreo del DailyProgressService
        if shouldLoadHeartRate || shouldLoadSteps {
            startHealthKitMonitoring()
        }
        
        // Para ritmo cardíaco: cargar si está autorizado
        if shouldLoadHeartRate && self.heartRate == nil {
            self.isLoadingHeartRate = true
            healthKitService.startHeartRateMonitoring()
        }
        
        // Para pasos: cargar si está autorizado
        if shouldLoadSteps && self.isLoadingSteps == false {
            self.isLoadingSteps = true
            stepsService.fetchTodaySteps()
        }
    }
    
    /// Limpia completamente la persistencia y fuerza nueva autorización
    func clearAllHealthKitData() {
        healthKitPersistence.clearAuthorizationData()
        
        // Limpiar datos actuales
        heartRate = nil
        todaySteps = 0
        isLoadingHeartRate = false
        isLoadingSteps = false
        healthKitAuthorized = false
        stepsAuthorized = false
    }
    
    // MARK: - Public Methods
    
    /// Carga los datos iniciales
    func loadInitialData() {
        isLoading = true
        errorMessage = nil
        
        Task {
            await loadAllMuscleGroups()
            await MainActor.run {
                self.isLoading = false
                self.loadHealthDataIfAuthorized()
            }
        }
    }
    
    /// Selecciona un músculo
    func selectMuscle(_ muscle: MuscleGroup) {
        workoutService.selectMuscle(muscle)
    }
    
    /// Cambia el modo de workout
    func changeWorkoutMode(_ mode: WorkoutLocation) {
        workoutService.changeWorkoutMode(mode)
    }
    
    /// Alterna entre vista frontal y trasera
    func toggleView() {
        withAnimation(.easeInOut(duration: 0.6)) {
            isShowingBack.toggle()
            updateMuscleGroupsForCurrentView()
        }
    }
    
    /// Actualiza los músculos según la vista actual
    private func updateMuscleGroupsForCurrentView() {
        if isShowingBack {
            muscleGroups = backMuscleGroups
        } else {
            muscleGroups = frontMuscleGroups
        }
    }
    
    /// Obtiene los músculos correctos según la vista actual
    func getCurrentMuscleGroups() -> [MuscleGroup] {
        return isShowingBack ? backMuscleGroups : frontMuscleGroups
    }
    
    /// Obtiene los músculos frontales
    func getFrontMuscleGroups() -> [MuscleGroup] {
        return frontMuscleGroups
    }
    
    /// Obtiene los músculos traseros
    func getBackMuscleGroups() -> [MuscleGroup] {
        return backMuscleGroups
    }
    
    /// Limpia el filtro de músculo
    func clearMuscleFilter() {
        selectedMuscleFilter = nil
    }
    
    // MARK: - Muscle Position Methods
    
    /// Carga las posiciones de forma síncrona
    private func loadPositionsSynchronously() {
        // Cargar músculos frontales y traseros de forma síncrona
        let frontGroups = MuscleButtonPositions.frontMuscles.map { musclePos in
            MuscleGroup(
                name: musclePos.name,
                exercises: [],
                position: musclePos.position,
                isLeftSide: musclePos.isLeftSide
            )
        }
        let backGroups = MuscleButtonPositions.backMuscles.map { musclePos in
            MuscleGroup(
                name: musclePos.name,
                exercises: [],
                position: musclePos.position,
                isLeftSide: musclePos.isLeftSide
            )
        }
        self.frontMuscleGroups = frontGroups
        self.backMuscleGroups = backGroups
        self.muscleGroups = frontGroups // Comenzar con vista frontal
        self.positionsLoaded = true
    }
    
    // MARK: - Progress Methods (Delegated to ProgressService)
    
    /// Obtiene el progreso para una fecha específica
    func progressForDate(_ date: Date) -> Double {
        return progressService.getCompletionPercentage(for: date)
    }
    
    /// Actualiza el progreso para una fecha específica
    func updateProgress(for date: Date, progress: WorkoutProgressWorkout) {
        progressService.updateProgress(for: date, progress: progress)
    }
    
    /// Obtiene estadísticas de progreso semanal
    func getWeeklyStats() -> WeeklyStats {
        return progressService.weeklyStats
    }
    
    /// Obtiene estadísticas de progreso mensual
    func getMonthlyStats() -> MonthlyStats {
        return progressService.getMonthlyStats()
    }
    
    // MARK: - Workout Stats Methods (Delegated to WorkoutService)
    
    /// Obtiene estadísticas de workout
    func getWorkoutStats() -> WorkoutStats {
        return workoutService.getWorkoutStats()
    }
    
    // MARK: - Performance Optimizer Methods
    
    /// Obtiene ejercicios optimizados con cache
    func getOptimizedExercises(for muscleName: String, loadFunction: @escaping () async throws -> [Exercise]) async throws -> [Exercise] {
        return try await performanceOptimizer.getExercises(for: muscleName, loadFunction: loadFunction)
    }
    
    /// Obtiene métricas de performance
    func getPerformanceMetrics() -> (cacheHitRate: Double, memoryUsage: Double, averageLoadTime: Double) {
        return (
            cacheHitRate: performanceOptimizer.cacheHitRate,
            memoryUsage: performanceOptimizer.memoryUsage,
            averageLoadTime: performanceOptimizer.averageLoadTime
        )
    }
    
    /// Limpia el cache de performance
    func clearPerformanceCache() {
        performanceOptimizer.clearAllCaches()
    }
    
    // MARK: - Template Service Methods
    
    /// Obtiene plantillas recomendadas
    func getRecommendedTemplates() -> [WorkoutTemplate] {
        return templateService.recommendedTemplates
    }
    
    /// Obtiene plantillas por categoría
    func getTemplates(for category: WorkoutCategory) -> [WorkoutTemplate] {
        return templateService.getTemplates(for: category)
    }
    
    /// Obtiene plantillas por dificultad
    func getTemplates(for difficulty: WorkoutLevelWorkout) -> [WorkoutTemplate] {
        return templateService.getTemplates(for: difficulty)
    }
    
    /// Crea una nueva plantilla personalizada
    func createTemplate(_ template: WorkoutTemplate) {
        templateService.createTemplate(template)
    }
    
    /// Inicia una plantilla de entrenamiento
    func startTemplate(_ template: WorkoutTemplate) {
        templateService.startTemplate(template)
    }
    
    /// Completa una plantilla de entrenamiento
    func completeTemplate(_ template: WorkoutTemplate, completion: @escaping (Bool) -> Void) {
        templateService.completeTemplate(template, completion: completion)
    }
    
    // MARK: - Private Methods
    
    private func setupBindings() {
        // Observar cambios en el WorkoutService
        workoutService.$allExercises
            .assign(to: \.allExercises, on: self)
            .store(in: &cancellables)
        
        workoutService.$muscleGroups
            .assign(to: \.muscleGroups, on: self)
            .store(in: &cancellables)
        
        workoutService.$selectedMuscle
            .assign(to: \.selectedMuscle, on: self)
            .store(in: &cancellables)
        
        workoutService.$selectedWorkoutMode
            .assign(to: \.selectedWorkoutMode, on: self)
            .store(in: &cancellables)
        
        // Observar cambios en HealthKitService
        healthKitService.$currentHeartRate
            .compactMap { $0 }
            .sink { [weak self] heartRate in
                DispatchQueue.main.async {
                    self?.heartRate = Double(heartRate)
                    self?.isLoadingHeartRate = false
                }
            }
            .store(in: &cancellables)
        
        // Observar cambios en StepsService
        stepsService.$todaySteps
            .sink { [weak self] steps in
                DispatchQueue.main.async {
                    self?.todaySteps = steps
                    self?.isLoadingSteps = false
                }
            }
            .store(in: &cancellables)
        
        // Observer para recargar posiciones
        $forceReload
            .filter { $0 }
            .sink { [weak self] _ in
                Task {
                    await self?.loadAllMuscleGroups()
                    await MainActor.run {
                        self?.forceReload = false
                    }
                }
            }
            .store(in: &cancellables)
    }
    
    @MainActor
    private func loadAllMuscleGroups() async {
        // Los músculos ya están cargados en loadPositionsSynchronously()
        // Solo actualizar la vista actual
        updateMuscleGroupsForCurrentView()
    }
}
