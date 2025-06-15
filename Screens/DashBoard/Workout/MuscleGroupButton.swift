import SwiftUI

struct MuscleGroupButton: View {
    let muscleGroup: MuscleGroup
    let geometry: GeometryProxy
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Circle()
                    .fill(Color.yellow)
                    .frame(width: 8, height: 8)
                
                Text(muscleGroup.name)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.black.opacity(0.7))
                    .cornerRadius(8)
            }
        }
        .position(
            x: geometry.size.width * muscleGroup.position.x,
            y: geometry.size.height * muscleGroup.position.y
        )
    }
} 
