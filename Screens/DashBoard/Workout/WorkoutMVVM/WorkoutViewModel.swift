import SwiftUI
import Combine
import HealthKit

// MARK: - Models
struct MuscleGroup: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let exercises: [Exercise]
    let position: CGPoint // Posición relativa en la imagen (0-1)
    
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
}

class WorkoutViewModel: ObservableObject {
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
    @Published var healthKitAuthorized: Bool = false
    
    // ✅ Repository inyectado
    private let repository: WorkoutRepositoryProtocol
    
    // ✅ Cache para músculos de ambas vistas
    private var frontMuscleGroups: [MuscleGroup] = []
    private var backMuscleGroups: [MuscleGroup] = []
    
    // ✅ Constructor recibe repository
    init(repository: WorkoutRepositoryProtocol = MockWorkoutRepository()) {
        self.repository = repository
        loadAllMuscleGroups()
        setupSearch()
    }
    
    // ✅ Precarga todos los músculos para ambas vistas y todos los ejercicios
    private func loadAllMuscleGroups() {
        Task {
            do {
                async let frontGroups = repository.getMuscleGroups()
                async let backGroups = repository.getMuscleGroupsForBack()
                
                let (front, back) = try await (frontGroups, backGroups)
                
                await MainActor.run {
                    self.frontMuscleGroups = front
                    self.backMuscleGroups = back
                    self.muscleGroups = front // Comenzar con vista frontal
                    self.isLoading = false
                }
                // Cargar todos los ejercicios de todos los músculos
                await loadAllExercises(from: front + back)
            } catch {
                await MainActor.run {
                    self.errorMessage = "Error loading exercises"
                    self.isLoading = false
                }
            }
        }
    }
    
    // ✅ Cargar todos los ejercicios de todos los músculos
    @MainActor
    private func loadAllExercises(from muscleGroups: [MuscleGroup]) async {
        var all: [Exercise] = []
        for muscle in muscleGroups {
            let exercises = try? await repository.getExercises(for: muscle.name)
            if let exercises = exercises {
                all.append(contentsOf: exercises)
            }
        }
        self.allExercises = all
        self.filteredExercises = all
    }
    
    // ✅ Filtrar ejercicios según el texto de búsqueda y el filtro de músculo
    private func setupSearch() {
        Publishers.CombineLatest($searchText, $selectedMuscleFilter)
            .debounce(for: .milliseconds(200), scheduler: RunLoop.main)
            .sink { [weak self] (text, muscle) in
                guard let self = self else { return }
                var filtered = self.allExercises
                if let muscle = muscle, !muscle.isEmpty {
                    filtered = filtered.filter { $0.name.localizedCaseInsensitiveContains(muscle) || $0.name.localizedCaseInsensitiveContains(text) }
                }
                if !text.isEmpty {
                    filtered = filtered.filter { $0.name.localizedCaseInsensitiveContains(text) }
                }
                self.filteredExercises = filtered
            }
            .store(in: &cancellables)
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    // ✅ Carga datos del repository según la vista actual
    func loadMuscleGroups() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let groups: [MuscleGroup]
                if isShowingBack {
                    groups = try await repository.getMuscleGroupsForBack()
                } else {
                    groups = try await repository.getMuscleGroups()
                }
                
                await MainActor.run {
                    self.muscleGroups = groups
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = "Error loading exercises"
                    self.isLoading = false
                }
            }
        }
    }
    
    func selectMuscle(_ muscle: MuscleGroup) {
        selectedMuscle = muscle
    }
    
    func toggleView() {
        withAnimation(.easeInOut(duration: 0.6)) {
            isShowingBack.toggle()
            // ✅ Cambiar inmediatamente usando cache
            if isShowingBack {
                muscleGroups = backMuscleGroups
            } else {
                muscleGroups = frontMuscleGroups
            }
        }
    }
    
    func clearMuscleFilter() {
        selectedMuscleFilter = nil
    }
    
    func requestHealthKitAuthorization() {
        HealthKitManager.shared.requestAuthorization { [weak self] success, error in
            DispatchQueue.main.async {
                self?.healthKitAuthorized = success
                if success {
                    self?.fetchLatestHeartRate()
                }
            }
        }
    }
    
    func fetchLatestHeartRate() {
        HealthKitManager.shared.fetchLatestHeartRate { [weak self] value in
            DispatchQueue.main.async {
                self?.heartRate = value
            }
        }
    }
}
