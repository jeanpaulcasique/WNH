import Foundation
import Combine


class MockWorkoutRepository: WorkoutRepositoryProtocol {
    @Published private(set) var exercises: [Exercise] = []
    @Published private(set) var muscleGroups: [MuscleGroup] = []
    
    var exercisesPublisher: Published<[Exercise]>.Publisher { $exercises }
    var muscleGroupsPublisher: Published<[MuscleGroup]>.Publisher { $muscleGroups }
    
    func loadExercises() {
        // Simula la carga de todos los ejercicios para todos los grupos
        Task {
            var all: [Exercise] = []
            let groups = try? await getMuscleGroups()
            for group in groups ?? [] {
                let exs = try? await getExercises(for: group.name)
                all.append(contentsOf: exs ?? [])
            }
            DispatchQueue.main.async {
                self.exercises = all
            }
        }
    }
    
    func loadMuscleGroups() {
        Task {
            let groups = try? await getMuscleGroups()
            DispatchQueue.main.async {
                self.muscleGroups = groups ?? []
            }
        }
    }
    
    func getMuscleGroups() async throws -> [MuscleGroup] {
        // Simular delay de red - reducido para respuesta más rápida
        try await Task.sleep(nanoseconds: 100_000_000) // 0.1 segundos
        
        return [
            MuscleGroup(name: "Cardio", exercises: [], position: CGPoint(x: 0.9, y: 0.01), isLeftSide: false),
            MuscleGroup(name: "Shoulders", exercises: [], position: CGPoint(x: 0.34, y: 0.07), isLeftSide: true),   // Centro de hombros
            MuscleGroup(name: "Chest", exercises: [], position: CGPoint(x: 0.59, y: 0.14), isLeftSide: true),       // Centro del pecho
            MuscleGroup(name: "Biceps", exercises: [], position: CGPoint(x: 0.70, y: 0.2), isLeftSide: false),      // Entre hombro y codo
            MuscleGroup(name: "Forearms", exercises: [], position: CGPoint(x: 0.77, y: 0.33), isLeftSide: false),    // Entre codo y muñeca
            MuscleGroup(name: "Abs", exercises: [], position: CGPoint(x: 0.49, y: 0.29), isLeftSide: false),         // Centro del abdomen
            MuscleGroup(name: "Obliques", exercises: [], position: CGPoint(x: 0.40, y: 0.33), isLeftSide: true),    // Lado izquierdo del abdomen
            MuscleGroup(name: "Quads", exercises: [], position: CGPoint(x: 0.39, y: 0.70), isLeftSide: true),       // Centro de los muslos
            MuscleGroup(name: "Adductors", exercises: [], position: CGPoint(x: 0.58, y: 0.66), isLeftSide: false)    // Centro bajo entre muslos
        ]
    }
    
    func getMuscleGroupsForBack() async throws -> [MuscleGroup] {
        // Simular delay de red - reducido para respuesta más rápida
        try await Task.sleep(nanoseconds: 100_000_000) // 0.1 segundos
        
        return [
         
            MuscleGroup(name: "Traps", exercises: [], position: CGPoint(x: 0.55, y: 0.01), isLeftSide: false),
            MuscleGroup(name: "Upper Back", exercises: [], position: CGPoint(x: 0.43, y: 0.04), isLeftSide: false),
            MuscleGroup(name: "Lats", exercises: [], position: CGPoint(x: 0.54, y: 0.25), isLeftSide: false),
            MuscleGroup(name: "Lower Back", exercises: [], position: CGPoint(x: 0.48, y: 0.32), isLeftSide: false),
            MuscleGroup(name: "Triceps", exercises: [], position: CGPoint(x: 0.66, y: 0.16), isLeftSide: false),
            MuscleGroup(name: "Glutes", exercises: [], position: CGPoint(x: 0.53, y: 0.50), isLeftSide: false),
            MuscleGroup(name: "Hamstrings", exercises: [], position: CGPoint(x: 0.40, y: 0.67), isLeftSide: false),
            MuscleGroup(name: "Calves", exercises: [], position: CGPoint(x: 0.27, y: 0.90), isLeftSide: false)
        ]
    }
    
    func getExercises(for muscleGroup: String) async throws -> [Exercise] {
        // Simular delay - reducido para respuesta más rápida
        try await Task.sleep(nanoseconds: 50_000_000) // 0.05 segundos
        
        switch muscleGroup.lowercased() {
        case "chest":
            return [
                Exercise(name: "Push-ups", duration: "15 reps", difficulty: "Medium", videoURL: nil, muscleGroups: ["Chest"], equipment: "Bodyweight"),
                Exercise(name: "Bench Press", duration: "12 reps", difficulty: "High", videoURL: nil, muscleGroups: ["Chest"], equipment: "Barbell")
            ]
        case "biceps":
            return [
                Exercise(name: "Bicep Curls", duration: "12 reps", difficulty: "Medium", videoURL: nil, muscleGroups: ["Biceps"], equipment: "Dumbbell"),
                Exercise(name: "Hammer Curls", duration: "15 reps", difficulty: "Low", videoURL: nil, muscleGroups: ["Biceps"], equipment: "Dumbbell")
            ]
        case "lats":
            return [
                Exercise(name: "Pull-ups", duration: "10 reps", difficulty: "High", videoURL: nil, muscleGroups: ["Lats"], equipment: "Bodyweight"),
                Exercise(name: "Lat Pulldowns", duration: "12 reps", difficulty: "Medium", videoURL: nil, muscleGroups: ["Lats"], equipment: "Machine")
            ]
        case "upper back":
            return [
                Exercise(name: "Rows", duration: "12 reps", difficulty: "Medium", videoURL: nil, muscleGroups: ["Upper Back"], equipment: "Barbell"),
                Exercise(name: "Face Pulls", duration: "15 reps", difficulty: "Low", videoURL: nil, muscleGroups: ["Upper Back"], equipment: "Cable")
            ]
        case "triceps":
            return [
                Exercise(name: "Tricep Dips", duration: "12 reps", difficulty: "Medium", videoURL: nil, muscleGroups: ["Triceps"], equipment: "Bodyweight"),
                Exercise(name: "Overhead Extensions", duration: "15 reps", difficulty: "Low", videoURL: nil, muscleGroups: ["Triceps"], equipment: "Dumbbell")
            ]
        case "glutes":
            return [
                Exercise(name: "Squats", duration: "15 reps", difficulty: "Medium", videoURL: nil, muscleGroups: ["Glutes"], equipment: "Barbell"),
                Exercise(name: "Hip Thrusts", duration: "12 reps", difficulty: "Medium", videoURL: nil, muscleGroups: ["Glutes"], equipment: "Barbell")
            ]
        case "hamstrings":
            return [
                Exercise(name: "Deadlifts", duration: "10 reps", difficulty: "High", videoURL: nil, muscleGroups: ["Hamstrings"], equipment: "Barbell"),
                Exercise(name: "Leg Curls", duration: "15 reps", difficulty: "Medium", videoURL: nil, muscleGroups: ["Hamstrings"], equipment: "Machine")
            ]
        case "calves":
            return [
                Exercise(name: "Calf Raises", duration: "20 reps", difficulty: "Low", videoURL: nil, muscleGroups: ["Calves"], equipment: "Bodyweight"),
                Exercise(name: "Jump Rope", duration: "5 min", difficulty: "Medium", videoURL: nil, muscleGroups: ["Calves"], equipment: "Rope")
            ]
        default:
            return []
        }
    }
}

import SwiftUI // Necesario para CGPoint
