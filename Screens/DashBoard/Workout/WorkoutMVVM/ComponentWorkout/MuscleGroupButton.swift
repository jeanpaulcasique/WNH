import SwiftUI

struct MuscleGroupButton: View {
    let muscleGroup: MuscleGroup
    let geometry: GeometryProxy
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Circle()
                    .fill(Color.appYellow)
                    .frame(width: 10, height: 10)
                Text(muscleGroup.name)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.appWhite)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(.ultraThinMaterial)
                    .cornerRadius(10)
            }
        }
        .position(
            x: geometry.size.width * muscleGroup.position.x,
            y: geometry.size.height * muscleGroup.position.y
        )
        .shadow(color: Color.appYellow.opacity(0.10), radius: 4, x: 0, y: 2)
    }
} 