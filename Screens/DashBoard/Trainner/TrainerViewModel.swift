import SwiftUI
import Foundation


// MARK: - ViewModel
@MainActor
class FitnessTrainerViewModel: ObservableObject {
    private let repository: TrainerRepositoryProtocol
    @Published var trainers: [Trainer] = []
    @Published var isLoading = false
    @Published var favorites: Set<UUID> = []
    
    init(repository: TrainerRepositoryProtocol = MockTrainerRepository()) {
        self.repository = repository
        loadTrainers()
    }
    
    func loadTrainers() {
        isLoading = true
        repository.fetchTrainers { [weak self] trainers in
            DispatchQueue.main.async {
                self?.trainers = trainers
                self?.isLoading = false
            }
        }
    }
    
    func loadTrainers(completion: @escaping () -> Void) {
        guard trainers.isEmpty else {
            completion()
            return
        }
        print("🔄 Iniciando carga de entrenadores...")
        isLoading = true
        
        // Cargar inmediatamente sin delay
        self.trainers = TrainerData.sampleTrainers
        print("✅ Entrenadores cargados: \(self.trainers.count)")
        self.isLoading = false
        print("🏁 Carga completada. Loading: \(self.isLoading)")
        
        // Notificar que los datos están listos
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            completion()
        }
    }
    
    func getFilteredTrainers(searchText: String, category: TrainerCategory) -> [Trainer] {
        var filtered = trainers
        
        if !searchText.isEmpty {
            filtered = filtered.filter { trainer in
                trainer.name.localizedCaseInsensitiveContains(searchText) ||
                trainer.bio.localizedCaseInsensitiveContains(searchText) ||
                trainer.location.address.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        if category != .all {
            filtered = filtered.filter { trainer in
                trainer.specialty == category.rawValue
            }
        }
        
        return filtered
    }
    
    func toggleFavorite(for trainer: Trainer) {
        if favorites.contains(trainer.id) {
            favorites.remove(trainer.id)
        } else {
            favorites.insert(trainer.id)
        }
    }
    
    func isFavorited(_ trainer: Trainer) -> Bool {
        favorites.contains(trainer.id)
    }
    
    var activeTrainers: [Trainer] {
        trainers.filter { $0.isActive }
    }
}
