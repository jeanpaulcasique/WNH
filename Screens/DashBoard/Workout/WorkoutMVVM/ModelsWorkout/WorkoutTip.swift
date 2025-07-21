import Foundation

/// Modelo para los tips de workout que se muestran al usuario
struct WorkoutTip: Identifiable {
    let id = UUID()
    let message: String
    let category: TipCategory
    
    enum TipCategory: String, CaseIterable {
        case warmup = "Warm-up"
        case technique = "Technique"
        case recovery = "Recovery"
        case motivation = "Motivation"
        case nutrition = "Nutrition"
        
        var icon: String {
            switch self {
            case .warmup: return "flame.fill"
            case .technique: return "figure.strengthtraining.traditional"
            case .recovery: return "heart.fill"
            case .motivation: return "star.fill"
            case .nutrition: return "leaf.fill"
            }
        }
    }
}

/// Datos de ejemplo para los tips de workout
extension WorkoutTip {
    static let workoutTips: [WorkoutTip] = [
        WorkoutTip(message: "Start your session with a proper warm-up!", category: .warmup),
        WorkoutTip(message: "Begin with chest and triceps: they work together in most exercises.", category: .technique),
        WorkoutTip(message: "Focus on compound movements first (bench press, dips, push-ups).", category: .technique),
        WorkoutTip(message: "Keep your rest between sets to 60-90 seconds for muscle growth.", category: .recovery),
        WorkoutTip(message: "Stay hydrated and listen to your body.", category: .nutrition),
        WorkoutTip(message: "Finish with isolation exercises for a great pump!", category: .technique)
    ]
} 