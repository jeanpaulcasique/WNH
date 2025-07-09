import Foundation

class MockTrainerRepository: TrainerRepositoryProtocol {
    func fetchTrainers(completion: @escaping ([Trainer]) -> Void) {
        completion(TrainerData.sampleTrainers)
    }
} 