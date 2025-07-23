
import Foundation
import SwiftUI

class VideosDashBoardViewModel: ObservableObject {
    // Aquí puedes agregar la lógica y estado global del dashboard de videos
    @Published var selectedMuscleGroup: MuscleGroup? = nil
    // Puedes agregar más propiedades según lo que necesite el dashboard
    
    // Lista de grupos musculares (puedes cargarla de WorkoutViewModel o definirla aquí)
    let muscleGroups: [MuscleGroup] = [
        MuscleGroup(name: "Cardio", exercises: [], position: .zero, isLeftSide: false),
        MuscleGroup(name: "Shoulders", exercises: [], position: .zero, isLeftSide: true),
        MuscleGroup(name: "Chest", exercises: [], position: .zero, isLeftSide: true),
        MuscleGroup(name: "Biceps", exercises: [], position: .zero, isLeftSide: false),
        MuscleGroup(name: "Forearms", exercises: [], position: .zero, isLeftSide: false),
        MuscleGroup(name: "Abs", exercises: [], position: .zero, isLeftSide: false),
        MuscleGroup(name: "Obliques", exercises: [], position: .zero, isLeftSide: true),
        MuscleGroup(name: "Quads", exercises: [], position: .zero, isLeftSide: true),
        MuscleGroup(name: "Adductors", exercises: [], position: .zero, isLeftSide: false),
        MuscleGroup(name: "Traps", exercises: [], position: .zero, isLeftSide: false),
        MuscleGroup(name: "Lats", exercises: [], position: .zero, isLeftSide: false),
        MuscleGroup(name: "Triceps", exercises: [], position: .zero, isLeftSide: false),
        MuscleGroup(name: "Lower Back", exercises: [], position: .zero, isLeftSide: false),
        MuscleGroup(name: "Glutes", exercises: [], position: .zero, isLeftSide: false),
        MuscleGroup(name: "Hamstrings", exercises: [], position: .zero, isLeftSide: false),
        MuscleGroup(name: "Calves", exercises: [], position: .zero, isLeftSide: false)
    ]
} 
