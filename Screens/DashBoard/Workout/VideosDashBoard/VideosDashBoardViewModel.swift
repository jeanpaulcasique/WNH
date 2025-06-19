
import Foundation
import SwiftUI

class VideosDashBoardViewModel: ObservableObject {
    // Aquí puedes agregar la lógica y estado global del dashboard de videos
    @Published var selectedMuscleGroup: MuscleGroup? = nil
    // Puedes agregar más propiedades según lo que necesite el dashboard
    
    // Lista de grupos musculares (puedes cargarla de WorkoutViewModel o definirla aquí)
    let muscleGroups: [MuscleGroup] = [
        MuscleGroup(name: "Cardio", exercises: [], position: .zero),
        MuscleGroup(name: "Shoulders", exercises: [], position: .zero),
        MuscleGroup(name: "Chest", exercises: [], position: .zero),
        MuscleGroup(name: "Biceps", exercises: [], position: .zero),
        MuscleGroup(name: "Forearms", exercises: [], position: .zero),
        MuscleGroup(name: "Abs", exercises: [], position: .zero),
        MuscleGroup(name: "Obliques", exercises: [], position: .zero),
        MuscleGroup(name: "Quads", exercises: [], position: .zero),
        MuscleGroup(name: "Adductors", exercises: [], position: .zero),
        MuscleGroup(name: "Traps", exercises: [], position: .zero),
        MuscleGroup(name: "Lats", exercises: [], position: .zero),
        MuscleGroup(name: "Triceps", exercises: [], position: .zero),
        MuscleGroup(name: "Lower Back", exercises: [], position: .zero),
        MuscleGroup(name: "Glutes", exercises: [], position: .zero),
        MuscleGroup(name: "Hamstrings", exercises: [], position: .zero),
        MuscleGroup(name: "Calves", exercises: [], position: .zero)
    ]
} 
