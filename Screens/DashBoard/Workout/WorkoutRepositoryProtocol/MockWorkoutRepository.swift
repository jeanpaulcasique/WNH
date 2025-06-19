import Foundation

// ✅ Versión FAKE para probar - datos hardcodeados
class MockWorkoutRepository: WorkoutRepositoryProtocol {
    
    func getMuscleGroups() async throws -> [MuscleGroup] {
        // Simular delay de red - reducido para respuesta más rápida
        try await Task.sleep(nanoseconds: 100_000_000) // 0.1 segundos
        
        return [
            MuscleGroup(name: "Cardio", exercises: [], position: CGPoint(x: 0.9, y: 0.15)), // Fuera del cuerpo
            MuscleGroup(name: "Shoulders", exercises: [], position: CGPoint(x: 0.50, y: 0.19)),   // Centro de hombros
            MuscleGroup(name: "Chest", exercises: [], position: CGPoint(x: 0.50, y: 0.28)),       // Centro del pecho
            MuscleGroup(name: "Biceps", exercises: [], position: CGPoint(x: 0.62, y: 0.32)),      // Entre hombro y codo
            MuscleGroup(name: "Forearms", exercises: [], position: CGPoint(x: 0.80, y: 0.48)),    // Entre codo y muñeca
            MuscleGroup(name: "Abs", exercises: [], position: CGPoint(x: 0.50, y: 0.40)),         // Centro del abdomen
            MuscleGroup(name: "Obliques", exercises: [], position: CGPoint(x: 0.36, y: 0.43)),    // Lado izquierdo del abdomen
            MuscleGroup(name: "Quads", exercises: [], position: CGPoint(x: 0.50, y: 0.72)),       // Centro de los muslos
            MuscleGroup(name: "Adductors", exercises: [], position: CGPoint(x: 0.50, y: 0.78))    // Centro bajo entre muslos
        ]
    }
    
    func getMuscleGroupsForBack() async throws -> [MuscleGroup] {
        // Simular delay de red - reducido para respuesta más rápida
        try await Task.sleep(nanoseconds: 100_000_000) // 0.1 segundos
        
        return [
            MuscleGroup(name: "Neck", exercises: [], position: CGPoint(x: 0.5, y: 0.12)),
            MuscleGroup(name: "Traps", exercises: [], position: CGPoint(x: 0.5, y: 0.18)),
            MuscleGroup(name: "Upper Back", exercises: [], position: CGPoint(x: 0.5, y: 0.25)),
            MuscleGroup(name: "Lats", exercises: [], position: CGPoint(x: 0.5, y: 0.35)),
            MuscleGroup(name: "Lower Back", exercises: [], position: CGPoint(x: 0.5, y: 0.45)),
            MuscleGroup(name: "Triceps", exercises: [], position: CGPoint(x: 0.15, y: 0.33)),
            MuscleGroup(name: "Glutes", exercises: [], position: CGPoint(x: 0.5, y: 0.55)),
            MuscleGroup(name: "Hamstrings", exercises: [], position: CGPoint(x: 0.5, y: 0.65)),
            MuscleGroup(name: "Calves", exercises: [], position: CGPoint(x: 0.5, y: 0.78))
        ]
    }
    
    func getExercises(for muscleGroup: String) async throws -> [Exercise] {
        // Simular delay - reducido para respuesta más rápida
        try await Task.sleep(nanoseconds: 50_000_000) // 0.05 segundos
        
        switch muscleGroup.lowercased() {
        case "chest":
            return [
                Exercise(name: "Push-ups", duration: "15 reps", difficulty: "Medium", videoURL: nil),
                Exercise(name: "Bench Press", duration: "12 reps", difficulty: "High", videoURL: nil)
            ]
        case "biceps":
            return [
                Exercise(name: "Bicep Curls", duration: "12 reps", difficulty: "Medium", videoURL: nil),
                Exercise(name: "Hammer Curls", duration: "15 reps", difficulty: "Low", videoURL: nil)
            ]
        case "lats":
            return [
                Exercise(name: "Pull-ups", duration: "10 reps", difficulty: "High", videoURL: nil),
                Exercise(name: "Lat Pulldowns", duration: "12 reps", difficulty: "Medium", videoURL: nil)
            ]
        case "upper back":
            return [
                Exercise(name: "Rows", duration: "12 reps", difficulty: "Medium", videoURL: nil),
                Exercise(name: "Face Pulls", duration: "15 reps", difficulty: "Low", videoURL: nil)
            ]
        case "triceps":
            return [
                Exercise(name: "Tricep Dips", duration: "12 reps", difficulty: "Medium", videoURL: nil),
                Exercise(name: "Overhead Extensions", duration: "15 reps", difficulty: "Low", videoURL: nil)
            ]
        case "glutes":
            return [
                Exercise(name: "Squats", duration: "15 reps", difficulty: "Medium", videoURL: nil),
                Exercise(name: "Hip Thrusts", duration: "12 reps", difficulty: "Medium", videoURL: nil)
            ]
        case "hamstrings":
            return [
                Exercise(name: "Deadlifts", duration: "10 reps", difficulty: "High", videoURL: nil),
                Exercise(name: "Leg Curls", duration: "15 reps", difficulty: "Medium", videoURL: nil)
            ]
        case "calves":
            return [
                Exercise(name: "Calf Raises", duration: "20 reps", difficulty: "Low", videoURL: nil),
                Exercise(name: "Jump Rope", duration: "5 min", difficulty: "Medium", videoURL: nil)
            ]
        default:
            return []
        }
    }
}

import SwiftUI // Necesario para CGPoint
