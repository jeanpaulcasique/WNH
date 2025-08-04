import SwiftUI
import Combine

/// Manager que maneja la búsqueda de ejercicios
class WorkoutSearchManager: ObservableObject {
    
    // MARK: - Published Properties
    @Published var filteredExercises: [Exercise] = []
    @Published var searchText: String = ""
    @Published var selectedMuscleFilter: String? = nil
    
    // MARK: - Private Properties
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    init() {
        setupSearch()
    }
    
    // MARK: - Public Methods
    
    /// Actualiza la búsqueda con nuevos parámetros
    func updateSearch(text: String, muscleFilter: String?, allExercises: [Exercise]) {
        self.searchText = text
        self.selectedMuscleFilter = muscleFilter
        
        var filtered = allExercises
        
        // Filtrar por músculo
        if let muscle = muscleFilter, !muscle.isEmpty {
            filtered = filtered.filter { exercise in
                exercise.muscleGroups.contains { $0.localizedCaseInsensitiveContains(muscle) }
            }
        }
        
        // Filtrar por texto de búsqueda
        if !text.isEmpty {
            filtered = filtered.filter { exercise in
                exercise.name.localizedCaseInsensitiveContains(text) ||
                exercise.muscleGroups.contains { $0.localizedCaseInsensitiveContains(text) } ||
                exercise.equipment.contains { $0.localizedCaseInsensitiveContains(text) }
            }
        }
        
        self.filteredExercises = filtered
    }
    
    /// Limpia el filtro de músculo
    func clearMuscleFilter() {
        selectedMuscleFilter = nil
    }
    
    /// Limpia la búsqueda
    func clearSearch() {
        searchText = ""
        selectedMuscleFilter = nil
        filteredExercises = []
    }
    
    // MARK: - Private Methods
    
    private func setupSearch() {
        // Configuración de búsqueda reactiva
        Publishers.CombineLatest($searchText, $selectedMuscleFilter)
            .debounce(for: .milliseconds(200), scheduler: RunLoop.main)
            .sink { [weak self] (_, _) in
                // La lógica de filtrado se maneja en updateSearch
            }
            .store(in: &cancellables)
    }
} 