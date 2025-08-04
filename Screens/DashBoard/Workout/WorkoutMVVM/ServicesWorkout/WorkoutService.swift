import Foundation
import Combine

/// Servicio que maneja la lógica de negocio relacionada con workouts
class WorkoutService: ObservableObject {
    
    // MARK: - Published Properties
    @Published var allExercises: [Exercise] = []
    @Published var muscleGroups: [MuscleGroup] = []
    @Published var selectedMuscle: MuscleGroup?
    @Published var selectedWorkoutMode: WorkoutLocation = .atHome
    
    // MARK: - Private Properties
    private var cancellables = Set<AnyCancellable>()
    private let repository: WorkoutRepositoryProtocol
    
    // MARK: - Initialization
    
    init(repository: WorkoutRepositoryProtocol = MockWorkoutRepository()) {
        self.repository = repository
        setupBindings()
        loadInitialData()
    }
    
    // MARK: - Public Methods
    
    /// Carga los datos iniciales del workout
    func loadInitialData() {
        loadExercises()
        loadMuscleGroups()
        loadUserPreferences()
    }
    
    /// Selecciona un grupo muscular
    func selectMuscle(_ muscle: MuscleGroup) {
        selectedMuscle = muscle
        saveUserPreferences()
    }
    
    /// Cambia el modo de workout
    func changeWorkoutMode(_ mode: WorkoutLocation) {
        selectedWorkoutMode = mode
        saveUserPreferences()
    }
    
    /// Obtiene ejercicios filtrados por grupo muscular
    func getExercisesForMuscle(_ muscle: MuscleGroup) -> [Exercise] {
        return allExercises.filter { exercise in
            exercise.muscleGroups.contains { $0.lowercased() == muscle.name.lowercased() }
        }
    }
    
    /// Obtiene ejercicios filtrados por ubicación
    func getExercisesForLocation(_ location: WorkoutLocation) -> [Exercise] {
        return allExercises.filter { exercise in
            switch location {
            case .atHome:
                return exercise.equipment.contains("bodyweight") || exercise.equipment.contains("dumbbell")
            case .atTheGym:
                return exercise.equipment.contains("barbell") || exercise.equipment.contains("machine")
            case .outdoors:
                return exercise.equipment.contains("bodyweight") || exercise.equipment.contains("resistance")
            }
        }
    }
    
    /// Obtiene ejercicios combinados por músculo y ubicación
    func getFilteredExercises(muscle: MuscleGroup? = nil, location: WorkoutLocation? = nil) -> [Exercise] {
        var exercises = allExercises
        
        if let muscle = muscle {
            exercises = exercises.filter { exercise in
                exercise.muscleGroups.contains { $0.lowercased() == muscle.name.lowercased() }
            }
        }
        
        if let location = location {
            exercises = exercises.filter { exercise in
                switch location {
                case .atHome:
                    return exercise.equipment.contains("bodyweight") || exercise.equipment.contains("dumbbell")
                case .atTheGym:
                    return exercise.equipment.contains("barbell") || exercise.equipment.contains("machine")
                case .outdoors:
                    return exercise.equipment.contains("bodyweight") || exercise.equipment.contains("resistance")
                }
            }
        }
        
        return exercises
    }
    
    /// Busca ejercicios por texto
    func searchExercises(query: String) -> [Exercise] {
        guard !query.isEmpty else { return allExercises }
        
        return allExercises.filter { exercise in
            exercise.name.localizedCaseInsensitiveContains(query) ||
            exercise.muscleGroups.contains { $0.localizedCaseInsensitiveContains(query) } ||
            exercise.equipment.contains { $0.localizedCaseInsensitiveContains(query) }
        }
    }
    
    /// Obtiene estadísticas de workout
    func getWorkoutStats() -> WorkoutStats {
        let totalExercises = allExercises.count
        let totalMuscleGroups = muscleGroups.count
        let exercisesByMuscle = Dictionary(grouping: allExercises) { exercise in
            exercise.muscleGroups.first ?? "Unknown"
        }
        
        return WorkoutStats(
            totalExercises: totalExercises,
            totalMuscleGroups: totalMuscleGroups,
            exercisesByMuscle: exercisesByMuscle,
            selectedMuscle: selectedMuscle?.name ?? "None",
            workoutMode: selectedWorkoutMode.displayName
        )
    }
    
    // MARK: - Private Methods
    
    private func setupBindings() {
        // Observar cambios en el repositorio
        repository.exercisesPublisher
            .receive(on: DispatchQueue.main)
            .assign(to: \.allExercises, on: self)
            .store(in: &cancellables)
        
        repository.muscleGroupsPublisher
            .receive(on: DispatchQueue.main)
            .assign(to: \.muscleGroups, on: self)
            .store(in: &cancellables)
    }
    
    private func loadExercises() {
        repository.loadExercises()
    }
    
    private func loadMuscleGroups() {
        repository.loadMuscleGroups()
    }
    
    private func loadUserPreferences() {
        selectedWorkoutMode = UserDefaults.standard.string(forKey: "selectedWorkoutMode")
            .flatMap { WorkoutLocation(rawValue: $0) } ?? .atHome
        
        if let selectedMuscleName = UserDefaults.standard.string(forKey: "selectedMuscle") {
            selectedMuscle = muscleGroups.first { $0.name == selectedMuscleName }
        }
    }
    
    private func saveUserPreferences() {
        UserDefaults.standard.set(selectedWorkoutMode.rawValue, forKey: "selectedWorkoutMode")
        UserDefaults.standard.set(selectedMuscle?.name, forKey: "selectedMuscle")
    }
}

// MARK: - WorkoutStats Model

struct WorkoutStats {
    let totalExercises: Int
    let totalMuscleGroups: Int
    let exercisesByMuscle: [String: [Exercise]]
    let selectedMuscle: String
    let workoutMode: String
    
    var mostExercisesMuscle: String {
        exercisesByMuscle.max(by: { $0.value.count < $1.value.count })?.key ?? "None"
    }
    
    var averageExercisesPerMuscle: Double {
        guard !exercisesByMuscle.isEmpty else { return 0 }
        let total = exercisesByMuscle.values.reduce(0) { $0 + $1.count }
        return Double(total) / Double(exercisesByMuscle.count)
    }
} 