import SwiftUI

struct ExerciseDetailView: View {
    let muscleGroup: MuscleGroup
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    colors: [Color.black, Color.gray.opacity(0.3)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                ScrollView {
                    // ... aquí va el contenido del detalle del ejercicio ...
                }
            }
        }
    }
} 
