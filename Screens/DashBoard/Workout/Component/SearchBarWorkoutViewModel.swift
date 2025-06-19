import SwiftUI
import Combine

class SearchBarWorkoutViewModel: ObservableObject {
    @Published var searchText: String = ""
    @Published var selectedMuscleFilter: String? = nil
    @Published var allExercises: [Exercise] = []
    @Published var filteredExercises: [Exercise] = []
    @Published var allMuscleGroups: [MuscleGroup] = []
    @Published var filteredMuscleGroups: [MuscleGroup] = []
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupSearch()
    }
    
    func configure(exercises: [Exercise], muscleGroups: [MuscleGroup]) {
        self.allExercises = exercises
        self.allMuscleGroups = muscleGroups
        self.filteredExercises = exercises
        self.filteredMuscleGroups = muscleGroups
    }
    
    private func setupSearch() {
        Publishers.CombineLatest($searchText, $selectedMuscleFilter)
            .debounce(for: .milliseconds(200), scheduler: RunLoop.main)
            .sink { [weak self] (text, muscle) in
                guard let self = self else { return }
                var filtered = self.allExercises
                if let muscle = muscle, !muscle.isEmpty {
                    filtered = filtered.filter { $0.name.localizedCaseInsensitiveContains(muscle) }
                }
                if !text.isEmpty {
                    filtered = filtered.filter { $0.name.localizedCaseInsensitiveContains(text) }
                }
                self.filteredExercises = filtered
                // Filtrar los grupos musculares para los botones
                if let muscle = muscle, !muscle.isEmpty {
                    self.filteredMuscleGroups = self.allMuscleGroups.filter { $0.name.localizedCaseInsensitiveContains(muscle) }
                } else {
                    self.filteredMuscleGroups = self.allMuscleGroups
                }
            }
            .store(in: &cancellables)
    }
    
    func clearMuscleFilter() {
        selectedMuscleFilter = nil
    }
} 