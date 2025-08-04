import Foundation
import SwiftUI

/// Ubicaciones disponibles para realizar workouts
enum WorkoutLocation: String, CaseIterable, Identifiable, Codable {
    case atHome = "At Home"
    case atTheGym = "At the Gym"
    case outdoors = "Al aire libre"
    
    var id: String { self.rawValue }
    
    var icon: String {
        switch self {
        case .atHome: return "house.fill"
        case .atTheGym: return "dumbbell.fill"
        case .outdoors: return "leaf.fill"
        }
    }
    
    var displayName: String {
        return self.rawValue
    }
}

// MARK: - Workout Models

/// Modelo de ejercicio
struct Exercise: Identifiable {
    let id = UUID()
    let name: String
    let duration: String
    let difficulty: String
    let videoURL: String?
    let muscleGroups: [String]
    let equipment: [String]
}

/// Modelo de grupo muscular
struct MuscleGroup: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let exercises: [Exercise]
    let position: CGPoint
    let isLeftSide: Bool
    
    static func == (lhs: MuscleGroup, rhs: MuscleGroup) -> Bool {
        return lhs.id == rhs.id
    }
}

/// Modelo de posición de músculo
struct MusclePosition {
    let name: String
    let x: CGFloat
    let y: CGFloat
    let isLeftSide: Bool
    
    var position: CGPoint {
        return CGPoint(x: x, y: y)
    }
}

/// Configuración de posiciones de botones de músculos
struct MuscleButtonPositions {
    // MARK: - Posiciones de Músculos Delanteros
    static let frontMuscles: [MusclePosition] = [
        MusclePosition(name: "Cardio", x: 0.19, y: 0.90, isLeftSide: false),
        MusclePosition(name: "Shoulders", x: 0.36, y: 0.51, isLeftSide: true),
        MusclePosition(name: "Chest", x: 0.55, y: 0.53, isLeftSide: false),
        MusclePosition(name: "Biceps", x: 0.65, y: 0.56, isLeftSide: false),
        MusclePosition(name: "Forearms", x: 0.70, y: 0.62, isLeftSide: false),
        MusclePosition(name: "Abs", x: 0.46, y: 0.60, isLeftSide: true),
        MusclePosition(name: "Obliques", x: 0.40, y: 0.62, isLeftSide: true),
        MusclePosition(name: "Quads", x: 0.40, y: 0.77, isLeftSide: true),
        MusclePosition(name: "Adductors", x: 0.55, y: 0.74, isLeftSide: false)
    ]
    
    // MARK: - Posiciones de Músculos Traseros
    static let backMuscles: [MusclePosition] = [
        MusclePosition(name: "Traps", x: 0.44, y: 0.48, isLeftSide: true),
        MusclePosition(name: "Upper Back", x: 0.52, y: 0.50, isLeftSide: false),
        MusclePosition(name: "Lats", x: 0.43, y: 0.58, isLeftSide: true),
        MusclePosition(name: "Lower Back", x: 0.46, y: 0.61, isLeftSide: false),
        MusclePosition(name: "Triceps", x: 0.61, y: 0.56, isLeftSide: false),
        MusclePosition(name: "Glutes", x: 0.52, y: 0.68, isLeftSide: false),
        MusclePosition(name: "Hamstrings", x: 0.39, y: 0.75, isLeftSide: true),
        MusclePosition(name: "Calves", x: 0.30, y: 0.85, isLeftSide: true)
    ]
    
    // MARK: - Configuración de Líneas de Texto
    struct LineConfig {
        static let lineLength: CGFloat = 60
        static let lineOffset: CGFloat = 30
        static let textOffset: CGFloat = 80
    }
} 