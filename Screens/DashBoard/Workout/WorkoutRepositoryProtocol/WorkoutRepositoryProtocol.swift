import Foundation
import Combine

protocol WorkoutRepositoryProtocol {
    func getMuscleGroups() async throws -> [MuscleGroup]
    func getMuscleGroupsForBack() async throws -> [MuscleGroup]
    func getExercises(for muscleGroup: String) async throws -> [Exercise]
    // Publishers para WorkoutService
    var exercisesPublisher: Published<[Exercise]>.Publisher { get }
    var muscleGroupsPublisher: Published<[MuscleGroup]>.Publisher { get }
    // Métodos para cargar datos
    func loadExercises()
    func loadMuscleGroups()
}

// ✅ Errores que puede devolver
enum WorkoutRepositoryError: Error {
    case networkError
    case noData
    case invalidData
}
