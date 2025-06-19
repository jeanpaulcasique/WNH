import Foundation

// ✅ El "contrato" - qué puede hacer nuestro repositorio
protocol WorkoutRepositoryProtocol {
    func getMuscleGroups() async throws -> [MuscleGroup]
    func getMuscleGroupsForBack() async throws -> [MuscleGroup]
    func getExercises(for muscleGroup: String) async throws -> [Exercise]
}

// ✅ Errores que puede devolver
enum WorkoutRepositoryError: Error {
    case networkError
    case noData
    case invalidData
}
