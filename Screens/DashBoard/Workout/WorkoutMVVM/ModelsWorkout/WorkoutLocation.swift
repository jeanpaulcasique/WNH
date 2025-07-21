import Foundation

/// Ubicaciones disponibles para realizar workouts
enum WorkoutLocation: String, CaseIterable, Identifiable {
    case atHome = "At Home"
    case atGym = "At Gym"
    case outdoors = "Outdoors"
    
    var id: String { self.rawValue }
    
    var icon: String {
        switch self {
        case .atHome: return "house.fill"
        case .atGym: return "dumbbell.fill"
        case .outdoors: return "leaf.fill"
        }
    }
    
    var displayName: String {
        return self.rawValue
    }
} 