import Foundation


class MockWorkoutRepository: WorkoutRepositoryProtocol {
    
    func getMuscleGroups() async throws -> [MuscleGroup] {
        // Simular delay de red - reducido para respuesta más rápida
        try await Task.sleep(nanoseconds: 100_000_000) // 0.1 segundos
        
        return [
            MuscleGroup(name: "Cardio", exercises: [], position: CGPoint(x: 0.9, y: 0.01)),
            MuscleGroup(name: "Shoulders", exercises: [], position: CGPoint(x: 0.34, y: 0.07)),   // Centro de hombros
            MuscleGroup(name: "Chest", exercises: [], position: CGPoint(x: 0.59, y: 0.14)),       // Centro del pecho
            MuscleGroup(name: "Biceps", exercises: [], position: CGPoint(x: 0.70, y: 0.2)),      // Entre hombro y codo
            MuscleGroup(name: "Forearms", exercises: [], position: CGPoint(x: 0.77, y: 0.33)),    // Entre codo y muñeca
            MuscleGroup(name: "Abs", exercises: [], position: CGPoint(x: 0.49, y: 0.29)),         // Centro del abdomen
            MuscleGroup(name: "Obliques", exercises: [], position: CGPoint(x: 0.40, y: 0.33)),    // Lado izquierdo del abdomen
            MuscleGroup(name: "Quads", exercises: [], position: CGPoint(x: 0.39, y: 0.70)),       // Centro de los muslos
            MuscleGroup(name: "Adductors", exercises: [], position: CGPoint(x: 0.58, y: 0.66))    // Centro bajo entre muslos
        ]
    }
    
    func getMuscleGroupsForBack() async throws -> [MuscleGroup] {
        // Simular delay de red - reducido para respuesta más rápida
        try await Task.sleep(nanoseconds: 100_000_000) // 0.1 segundos
        
        return [
         
            MuscleGroup(name: "Traps", exercises: [], position: CGPoint(x: 0.55, y: 0.01)),
            MuscleGroup(name: "Upper Back", exercises: [], position: CGPoint(x: 0.43, y: 0.04)),
            MuscleGroup(name: "Lats", exercises: [], position: CGPoint(x: 0.54, y: 0.25)),
            MuscleGroup(name: "Lower Back", exercises: [], position: CGPoint(x: 0.48, y: 0.32)),
            MuscleGroup(name: "Triceps", exercises: [], position: CGPoint(x: 0.66, y: 0.16)),
            MuscleGroup(name: "Glutes", exercises: [], position: CGPoint(x: 0.53, y: 0.50)),
            MuscleGroup(name: "Hamstrings", exercises: [], position: CGPoint(x: 0.40, y: 0.67)),
            MuscleGroup(name: "Calves", exercises: [], position: CGPoint(x: 0.27, y: 0.90))
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
