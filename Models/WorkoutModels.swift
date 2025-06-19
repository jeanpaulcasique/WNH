import Foundation

enum WorkoutLocation: String, CaseIterable {
    case atHome = "At Home"
    case atGym = "At Gym"
    case outdoors = "Outdoors"
    
    var icon: String {
        switch self {
        case .atHome:
            return "house.fill"
        case .atGym:
            return "dumbbell.fill"
        case .outdoors:
            return "leaf.fill"
        }
    }
}

enum ExerciseDifficulty: String, CaseIterable {
    case beginner = "Beginner"
    case intermediate = "Intermediate"
    case advanced = "Advanced"
} 