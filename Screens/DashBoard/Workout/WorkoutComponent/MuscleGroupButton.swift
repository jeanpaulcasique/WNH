import SwiftUI

struct MuscleGroupButton: View {
    let muscleGroup: MuscleGroup
    let geometry: GeometryProxy
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Circle()
                .fill(Color.yellow)
                .frame(width: 8, height: 8)
        }
        .position(
            x: geometry.size.width * muscleGroup.position.x,
            y: geometry.size.height * muscleGroup.position.y
        )
    }
} 