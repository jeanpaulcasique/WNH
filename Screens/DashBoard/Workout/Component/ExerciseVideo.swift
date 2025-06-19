import Foundation

struct ExerciseVideo: Identifiable {
    let id: String
    let title: String
    let description: String
    let videoURL: String
    let thumbnailURL: String
    let duration: Int // en segundos
    let difficulty: ExerciseDifficulty
    let location: WorkoutLocation
    let muscleGroup: String
    let equipment: [String]?
    let calories: Int
    let instructions: [String]
}

enum ExerciseDifficulty: String, CaseIterable {
    case beginner = "Beginner"
    case intermediate = "Intermediate"
    case advanced = "Advanced"
}

enum WorkoutLocation: String, CaseIterable {
    case atHome = "At Home"
    case atGym = "At Gym"
    case outdoors = "Outdoors"
} 