import SwiftUI
import Combine

// MARK: - Models
struct MuscleGroup {
    let id = UUID()
    let name: String
    let exercises: [Exercise]
    let position: CGPoint // Posición relativa en la imagen (0-1)
}

struct Exercise {
    let id = UUID()
    let name: String
    let duration: String
    let difficulty: String
    let videoURL: String? // Para futuras implementaciones
}

enum WorkoutMode {
    case atHome
    case atGym
    case outdoors
}

// MARK: - ViewModel
class WorkoutViewModel: ObservableObject {
    @Published var selectedMuscleGroup: MuscleGroup?
    @Published var showingExerciseDetail = false
    @Published var isShowingBack = false
    @Published var selectedWorkoutMode: WorkoutMode = .atHome
    
    let muscleGroups: [MuscleGroup] = [
        MuscleGroup(
            name: "Cardio",
            exercises: [
                Exercise(name: "Running", duration: "30 min", difficulty: "Medium", videoURL: nil),
                Exercise(name: "Jump Rope", duration: "15 min", difficulty: "High", videoURL: nil),
                Exercise(name: "Cycling", duration: "45 min", difficulty: "Low", videoURL: nil)
            ],
            position: CGPoint(x: 0.9, y: 0.15)
        ),
        MuscleGroup(
            name: "Shoulders",
            exercises: [
                Exercise(name: "Shoulder Press", duration: "12 reps", difficulty: "Medium", videoURL: nil),
                Exercise(name: "Lateral Raises", duration: "15 reps", difficulty: "Low", videoURL: nil),
                Exercise(name: "Front Raises", duration: "12 reps", difficulty: "Medium", videoURL: nil)
            ],
            position: CGPoint(x: 0.44, y: 0.24)
        ),
        MuscleGroup(
            name: "Chest",
            exercises: [
                Exercise(name: "Push-ups", duration: "15 reps", difficulty: "Medium", videoURL: nil),
                Exercise(name: "Bench Press", duration: "12 reps", difficulty: "High", videoURL: nil),
                Exercise(name: "Chest Fly", duration: "12 reps", difficulty: "Medium", videoURL: nil)
            ],
            position: CGPoint(x: 0.7, y: 0.3)
        ),
        MuscleGroup(
            name: "Biceps",
            exercises: [
                Exercise(name: "Bicep Curls", duration: "12 reps", difficulty: "Medium", videoURL: nil),
                Exercise(name: "Hammer Curls", duration: "15 reps", difficulty: "Low", videoURL: nil),
                Exercise(name: "Chin-ups", duration: "8 reps", difficulty: "High", videoURL: nil)
            ],
            position: CGPoint(x: 0.85, y: 0.33)
        ),
        MuscleGroup(
            name: "Forearms",
            exercises: [
                Exercise(name: "Wrist Curls", duration: "20 reps", difficulty: "Low", videoURL: nil),
                Exercise(name: "Grip Squeeze", duration: "30 sec", difficulty: "Low", videoURL: nil),
                Exercise(name: "Farmer's Walk", duration: "2 min", difficulty: "Medium", videoURL: nil)
            ],
            position: CGPoint(x: 0.15, y: 0.5)
        ),
        MuscleGroup(
            name: "Abs",
            exercises: [
                Exercise(name: "Crunches", duration: "20 reps", difficulty: "Medium", videoURL: nil),
                Exercise(name: "Plank", duration: "60 sec", difficulty: "Medium", videoURL: nil),
                Exercise(name: "Russian Twists", duration: "30 reps", difficulty: "High", videoURL: nil)
            ],
            position: CGPoint(x: 0.63, y: 0.41)
        ),
        MuscleGroup(
            name: "Obliques",
            exercises: [
                Exercise(name: "Side Plank", duration: "45 sec", difficulty: "Medium", videoURL: nil),
                Exercise(name: "Bicycle Crunches", duration: "20 reps", difficulty: "High", videoURL: nil),
                Exercise(name: "Wood Choppers", duration: "15 reps", difficulty: "Medium", videoURL: nil)
            ],
            position: CGPoint(x: 0.1, y: 0.58)
        ),
        MuscleGroup(
            name: "Quads",
            exercises: [
                Exercise(name: "Squats", duration: "15 reps", difficulty: "Medium", videoURL: nil),
                Exercise(name: "Lunges", duration: "12 reps", difficulty: "Medium", videoURL: nil),
                Exercise(name: "Leg Press", duration: "15 reps", difficulty: "High", videoURL: nil)
            ],
            position: CGPoint(x: 0.25, y: 0.72)
        ),
        MuscleGroup(
            name: "Adductors",
            exercises: [
                Exercise(name: "Side Lunges", duration: "12 reps", difficulty: "Medium", videoURL: nil),
                Exercise(name: "Sumo Squats", duration: "15 reps", difficulty: "Medium", videoURL: nil),
                Exercise(name: "Cossack Squats", duration: "10 reps", difficulty: "High", videoURL: nil)
            ],
            position: CGPoint(x: 0.75, y: 0.72)
        )
    ]
    
    let backMuscleGroups: [MuscleGroup] = [
        MuscleGroup(
            name: "Traps",
            exercises: [
                Exercise(name: "Shrugs", duration: "15 reps", difficulty: "Medium", videoURL: nil),
                Exercise(name: "Upright Rows", duration: "12 reps", difficulty: "Medium", videoURL: nil)
            ],
            position: CGPoint(x: 0.5, y: 0.22)
        ),
        MuscleGroup(
            name: "Lats",
            exercises: [
                Exercise(name: "Pull-ups", duration: "8 reps", difficulty: "High", videoURL: nil),
                Exercise(name: "Lat Pulldowns", duration: "12 reps", difficulty: "Medium", videoURL: nil),
                Exercise(name: "Rows", duration: "15 reps", difficulty: "Medium", videoURL: nil)
            ],
            position: CGPoint(x: 0.25, y: 0.4)
        ),
        MuscleGroup(
            name: "Triceps",
            exercises: [
                Exercise(name: "Tricep Dips", duration: "12 reps", difficulty: "Medium", videoURL: nil),
                Exercise(name: "Close-Grip Push-ups", duration: "10 reps", difficulty: "High", videoURL: nil),
                Exercise(name: "Overhead Extension", duration: "15 reps", difficulty: "Medium", videoURL: nil)
            ],
            position: CGPoint(x: 0.75, y: 0.4)
        ),
        MuscleGroup(
            name: "Lower Back",
            exercises: [
                Exercise(name: "Deadlifts", duration: "10 reps", difficulty: "High", videoURL: nil),
                Exercise(name: "Back Extensions", duration: "15 reps", difficulty: "Medium", videoURL: nil),
                Exercise(name: "Superman", duration: "20 reps", difficulty: "Low", videoURL: nil)
            ],
            position: CGPoint(x: 0.5, y: 0.52)
        ),
        MuscleGroup(
            name: "Glutes",
            exercises: [
                Exercise(name: "Hip Thrusts", duration: "15 reps", difficulty: "Medium", videoURL: nil),
                Exercise(name: "Glute Bridges", duration: "20 reps", difficulty: "Low", videoURL: nil),
                Exercise(name: "Bulgarian Split Squats", duration: "12 reps", difficulty: "High", videoURL: nil)
            ],
            position: CGPoint(x: 0.5, y: 0.62)
        ),
        MuscleGroup(
            name: "Hamstrings",
            exercises: [
                Exercise(name: "Romanian Deadlifts", duration: "12 reps", difficulty: "High", videoURL: nil),
                Exercise(name: "Leg Curls", duration: "15 reps", difficulty: "Medium", videoURL: nil),
                Exercise(name: "Good Mornings", duration: "12 reps", difficulty: "Medium", videoURL: nil)
            ],
            position: CGPoint(x: 0.5, y: 0.72)
        ),
        MuscleGroup(
            name: "Calves",
            exercises: [
                Exercise(name: "Calf Raises", duration: "20 reps", difficulty: "Low", videoURL: nil),
                Exercise(name: "Jump Squats", duration: "15 reps", difficulty: "High", videoURL: nil),
                Exercise(name: "Single Leg Calf Raise", duration: "12 reps", difficulty: "Medium", videoURL: nil)
            ],
            position: CGPoint(x: 0.5, y: 0.85)
        )
    ]
    
    func selectMuscleGroup(_ muscleGroup: MuscleGroup) {
        selectedMuscleGroup = muscleGroup
        showingExerciseDetail = true
    }
    
    func toggleView() {
        withAnimation(.easeInOut(duration: 0.6)) {
            isShowingBack.toggle()
        }
    }
}

