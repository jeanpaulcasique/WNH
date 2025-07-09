import Foundation

class FirebaseTrainerRepository: TrainerRepositoryProtocol {
    func fetchTrainers(completion: @escaping ([Trainer]) -> Void) {
        // Aquí irá la lógica real de integración con Firebase
        completion([]) // Por ahora vacío
    }
} 