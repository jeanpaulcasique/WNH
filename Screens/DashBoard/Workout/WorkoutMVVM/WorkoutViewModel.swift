import SwiftUI
import Combine
import HealthKit

// MARK: - Configuración de Posiciones de Botones de Músculos
struct MuscleButtonPositions {
    
    // MARK: - Posiciones de Músculos Delanteros
    static let frontMuscles: [MusclePosition] = [
        MusclePosition(name: "Cardio", x: 0.80, y: 0.42, isLeftSide: false),
        MusclePosition(name: "Shoulders", x: 0.36, y: 0.51, isLeftSide: true),
        MusclePosition(name: "Chest", x: 0.55, y: 0.53, isLeftSide: false),
        MusclePosition(name: "Biceps", x: 0.65, y: 0.56, isLeftSide: false),
        MusclePosition(name: "Forearms", x: 0.70, y: 0.62, isLeftSide: false),
        MusclePosition(name: "Abs", x: 0.46, y: 0.60, isLeftSide: false),
        MusclePosition(name: "Obliques", x: 0.40, y: 0.62, isLeftSide: true),
        MusclePosition(name: "Quads", x: 0.40, y: 0.77, isLeftSide: true),
        MusclePosition(name: "Adductors", x: 0.55, y: 0.74, isLeftSide: false)
    ]
    
    // MARK: - Posiciones de Músculos Traseros
    static let backMuscles: [MusclePosition] = [
        MusclePosition(name: "Traps", x: 0.55, y: 0.01, isLeftSide: false),
        MusclePosition(name: "Upper Back", x: 0.43, y: 0.04, isLeftSide: false),
        MusclePosition(name: "Lats", x: 0.54, y: 0.25, isLeftSide: false),
        MusclePosition(name: "Lower Back", x: 0.48, y: 0.32, isLeftSide: false),
        MusclePosition(name: "Triceps", x: 0.66, y: 0.16, isLeftSide: false),
        MusclePosition(name: "Glutes", x: 0.53, y: 0.50, isLeftSide: false),
        MusclePosition(name: "Hamstrings", x: 0.40, y: 0.67, isLeftSide: false),
        MusclePosition(name: "Calves", x: 0.27, y: 0.90, isLeftSide: false)
    ]
    
    // MARK: - Configuración de Líneas de Texto
    struct LineConfig {
        static let lineLength: CGFloat = 60
        static let lineOffset: CGFloat = 30
        static let textOffset: CGFloat = 80
    }
}

// MARK: - Modelo de Posición de Músculo
struct MusclePosition {
    let name: String
    let x: CGFloat
    let y: CGFloat
    let isLeftSide: Bool
    
    var position: CGPoint {
        return CGPoint(x: x, y: y)
    }
}

// MARK: - Models
struct MuscleGroup: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let exercises: [Exercise]
    let position: CGPoint // Posición relativa en la imagen (0-1)
    let isLeftSide: Bool // Indica si el músculo está en el lado izquierdo
    
    static func == (lhs: MuscleGroup, rhs: MuscleGroup) -> Bool {
        return lhs.id == rhs.id
    }
}

struct Exercise: Identifiable {
    let id = UUID()
    let name: String
    let duration: String
    let difficulty: String
    let videoURL: String? // Para futuras implementaciones
    let muscleGroups: [String]
    let equipment: String
}

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
    @Published var heartRate: Double? = nil
    @Published var userWeight: Double? = nil
    @Published var healthKitAuthorized: Bool = false
    
    // MARK: - Posiciones dinámicas para debugging
    @Published var debugPositions: Bool = false
    @Published var forceReload: Bool = false
    
    // MARK: - Gender-Based Properties
    @Published var userManager: UserManager
    
    // MARK: - Services
    private let workoutService: WorkoutService
    private let progressService: ProgressService
    private let healthKitService: HealthKitService
    private let userPreferencesService: UserPreferencesService
    private let performanceOptimizer: PerformanceOptimizer
    private let templateService: WorkoutTemplateService
    
    // MARK: - Private Properties
    private var cancellables = Set<AnyCancellable>()
    private var frontMuscleGroups: [MuscleGroup] = []
    private var backMuscleGroups: [MuscleGroup] = []
    
    // MARK: - Initialization
    
    init(
        workoutService: WorkoutService = WorkoutService(),
        progressService: ProgressService = ProgressService(),
        healthKitService: HealthKitService = HealthKitService(),
        userPreferencesService: UserPreferencesService = UserPreferencesService(),
        userManager: UserManager = UserManager()
    ) {
        self.workoutService = workoutService
        self.progressService = progressService
        self.healthKitService = healthKitService
        self.userPreferencesService = userPreferencesService
        self.userManager = userManager
        self.performanceOptimizer = PerformanceOptimizer()
        self.templateService = WorkoutTemplateService(
            userPreferencesService: userPreferencesService,
            progressService: progressService
        )
        
        setupBindings()
        loadInitialData()
    }
    
    // MARK: - Public Methods
    
    /// Carga los datos iniciales
    func loadInitialData() {
        isLoading = true
        errorMessage = nil
        
        Task {
            await loadAllMuscleGroups()
            await loadUserData()
            await MainActor.run {
                self.isLoading = false
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
            // Cambiar inmediatamente usando cache
            if isShowingBack {
                muscleGroups = backMuscleGroups
            } else {
                muscleGroups = frontMuscleGroups
            }
        }
    }
    
    /// Limpia el filtro de músculo
    func clearMuscleFilter() {
        selectedMuscleFilter = nil
    }
    
    /// Solicita autorización de HealthKit
    func requestHealthKitAuthorization() {
        healthKitService.requestAuthorization()
    }
    
    /// Inicia el timer de ritmo cardíaco si es necesario
    func startHeartRateTimerIfNeeded() {
        if healthKitAuthorized {
            healthKitService.startHeartRateMonitoring()
        }
    }
    

    
    /// Obtiene el progreso para una fecha específica
    func progressForDate(_ date: Date) -> Double {
        return progressService.getCompletionPercentage(for: date)
    }
    
    /// Actualiza el progreso para una fecha específica
    func updateProgress(for date: Date, progress: WorkoutProgressWorkout) {
        progressService.updateProgress(for: date, progress: progress)
    }
    
    /// Obtiene estadísticas de workout
    func getWorkoutStats() -> WorkoutStats {
        return workoutService.getWorkoutStats()
    }
    
    /// Obtiene estadísticas de progreso semanal
    func getWeeklyStats() -> WeeklyStats {
        return progressService.weeklyStats
    }
    
    /// Obtiene estadísticas de progreso mensual
    func getMonthlyStats() -> MonthlyStats {
        return progressService.getMonthlyStats()
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
    
    // MARK: - Gender-Based Workout Methods
    
    /// Mensaje de bienvenida personalizado para el workout según género
    var workoutWelcomeMessage: String {
        switch userManager.userProfile.genderEnum {
        case .female:
            return "Ready to build strength and confidence? Let's crush this workout! 💪"
        case .male:
            return "Ready to build power and endurance? Let's dominate this workout! 🔥"
        case .other:
            return "Ready to build your best self? Let's rock this workout! ⭐"
        case .notSet:
            return "Ready to get stronger? Let's start this workout! 💪"
        }
    }
    
    /// Intensidad recomendada según género
    var recommendedIntensity: String {
        switch userManager.userProfile.genderEnum {
        case .female:
            return "Focus on form and gradual progression"
        case .male:
            return "Push your limits while maintaining form"
        case .other, .notSet:
            return "Find your comfortable challenge level"
        }
    }
    
    /// Duración recomendada de workout según género
    var recommendedWorkoutDuration: Int {
        let baseDuration: Int
        switch userManager.userProfile.genderEnum {
        case .female:
            baseDuration = 35 // Mujeres suelen preferir workouts más largos pero menos intensos
        case .male:
            baseDuration = 45 // Hombres suelen preferir workouts más intensos pero más cortos
        case .other, .notSet:
            baseDuration = 40
        }
        
        // Ajustar por nivel de actividad
        switch userManager.userProfile.activityLevelEnum {
        case .sedentary: return baseDuration - 10
        case .lightlyActive: return baseDuration - 5
        case .active: return baseDuration
        case .veryActive: return baseDuration + 10
        case .notSet: return baseDuration
        }
    }
    
    /// Ejercicios recomendados según género
    var recommendedExercises: [String] {
        switch userManager.userProfile.genderEnum {
        case .female:
            return [
                "Squats with proper form",
                "Push-ups (modified if needed)",
                "Planks for core strength",
                "Glute bridges for posterior chain"
            ]
        case .male:
            return [
                "Compound movements",
                "Progressive overload",
                "Functional strength",
                "Mobility work"
            ]
        case .other, .notSet:
            return [
                "Full body movements",
                "Balance exercises",
                "Flexibility work",
                "Strength building"
            ]
        }
    }
    
    /// Mensaje de motivación durante el workout según género
    func getWorkoutMotivationMessage(for exercise: String) -> String {
        switch userManager.userProfile.genderEnum {
        case .female:
            return "You're building incredible strength with \(exercise)! Keep going! 💪"
        case .male:
            return "You're crushing \(exercise)! Push through! 🔥"
        case .other, .notSet:
            return "You're doing amazing with \(exercise)! Stay strong! ⭐"
        }
    }
    
    /// Configuración de descanso según género
    var restTimeConfiguration: (short: Int, medium: Int, long: Int) {
        switch userManager.userProfile.genderEnum {
        case .female:
            return (short: 30, medium: 60, long: 90) // Mujeres suelen necesitar más tiempo de recuperación
        case .male:
            return (short: 45, medium: 90, long: 120) // Hombres suelen tener más masa muscular, necesitan más descanso
        case .other, .notSet:
            return (short: 40, medium: 75, long: 105)
        }
    }
    
    /// Calorías quemadas estimadas según género
    func estimatedCaloriesBurned(for duration: Int, intensity: String) -> Int {
        let baseCalories: Double
        switch userManager.userProfile.genderEnum {
        case .female:
            baseCalories = 6.0 // Mujeres suelen quemar menos calorías por minuto
        case .male:
            baseCalories = 8.0 // Hombres suelen quemar más calorías por minuto
        case .other, .notSet:
            baseCalories = 7.0
        }
        
        let intensityMultiplier: Double
        switch intensity.lowercased() {
        case "low": intensityMultiplier = 0.7
        case "medium": intensityMultiplier = 1.0
        case "high": intensityMultiplier = 1.3
        default: intensityMultiplier = 1.0
        }
        
        return Int(baseCalories * Double(duration) * intensityMultiplier)
    }
    
    /// Mensaje de logro post-workout según género
    func getPostWorkoutMessage(caloriesBurned: Int, duration: Int) -> String {
        switch userManager.userProfile.genderEnum {
        case .female:
            return "Incredible! You burned \(caloriesBurned) calories in \(duration) minutes. Your strength is growing! 💪"
        case .male:
            return "Amazing! You burned \(caloriesBurned) calories in \(duration) minutes. You're getting stronger! 🔥"
        case .other, .notSet:
            return "Fantastic! You burned \(caloriesBurned) calories in \(duration) minutes. You're making progress! ⭐"
        }
    }
    
    /// Navegación condicional post-workout según género
    func getPostWorkoutNextStep() -> String {
        switch userManager.userProfile.genderEnum {
        case .female:
            return "RecoveryAndStretching"
        case .male:
            return "ProgressTracking"
        case .other, .notSet:
            return "GeneralProgress"
        }
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
        
        // Observar cambios en el HealthKitService
        healthKitService.$isAuthorized
            .assign(to: \.healthKitAuthorized, on: self)
            .store(in: &cancellables)
        
        healthKitService.$currentHeartRate
            .map { Double($0) }
            .assign(to: \.heartRate, on: self)
            .store(in: &cancellables)
        
        // Observar cambios en el UserPreferencesService
        userPreferencesService.$userProfile
            .map { $0.weightKg }
            .assign(to: \.userWeight, on: self)
            .store(in: &cancellables)
        
        // Configurar búsqueda
        setupSearch()
        
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
        // Cargar músculos frontales y traseros
        do {
            let frontGroups = try await loadMuscleGroupsForView(isBack: false)
            let backGroups = try await loadMuscleGroupsForView(isBack: true)
            
            self.frontMuscleGroups = frontGroups
            self.backMuscleGroups = backGroups
            self.muscleGroups = frontGroups // Comenzar con vista frontal
        } catch {
            self.errorMessage = "Error loading muscle groups: \(error.localizedDescription)"
        }
    }
    
    private func loadMuscleGroupsForView(isBack: Bool) async throws -> [MuscleGroup] {
        if isBack {
            // Músculos traseros - usando el nuevo sistema de posiciones
            return MuscleButtonPositions.backMuscles.map { musclePos in
                MuscleGroup(
                    name: musclePos.name,
                    exercises: [],
                    position: musclePos.position,
                    isLeftSide: musclePos.isLeftSide
                )
            }
        } else {
            // Músculos delanteros - usando el nuevo sistema de posiciones
            return MuscleButtonPositions.frontMuscles.map { musclePos in
                MuscleGroup(
                    name: musclePos.name,
                    exercises: [],
                    position: musclePos.position,
                    isLeftSide: musclePos.isLeftSide
                )
            }
        }
    }
    
    @MainActor
    private func loadUserData() async {
        // Cargar datos del usuario desde UserPreferencesService
        userWeight = userPreferencesService.userWeight
    }
    
    private func setupSearch() {
        Publishers.CombineLatest($searchText, $selectedMuscleFilter)
            .debounce(for: .milliseconds(200), scheduler: RunLoop.main)
            .sink { [weak self] (text, muscle) in
                guard let self = self else { return }
                
                var filtered = self.allExercises
                
                // Filtrar por músculo
                if let muscle = muscle, !muscle.isEmpty {
                    filtered = filtered.filter { exercise in
                        exercise.muscleGroups.contains { $0.localizedCaseInsensitiveContains(muscle) }
                    }
                }
                
                // Filtrar por texto de búsqueda
                if !text.isEmpty {
                    filtered = filtered.filter { exercise in
                        exercise.name.localizedCaseInsensitiveContains(text) ||
                        exercise.muscleGroups.contains { $0.localizedCaseInsensitiveContains(text) } ||
                        exercise.equipment.localizedCaseInsensitiveContains(text)
                    }
                }
                
                self.filteredExercises = filtered
            }
            .store(in: &cancellables)
    }
    
    deinit {
        healthKitService.stopHeartRateMonitoring()
    }
}
