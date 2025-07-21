import SwiftUI

/// Componente de controles inferiores de WorkoutView
struct WorkoutBottomControlsView: View {
    let onToggleView: () -> Void
    
    var body: some View {
        HStack {
            Spacer()
            VStack(spacing: 14) {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.left.and.right")
                        .foregroundColor(WorkoutColors.textAccent)
                        .font(.title3)
                    
                    Text("Swipe to rotate")
                        .foregroundColor(WorkoutColors.textPrimary)
                        .font(WorkoutTypography.bottomControlText)
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 18)
                .background(WorkoutColors.cardBackground)
                .cornerRadius(14)
                .shadow(color: WorkoutColors.cardShadow, radius: 8, x: 0, y: 2)
                .onTapGesture {
                    onToggleView()
                }
            }
            Spacer()
        }
        .padding(.bottom, 18)
    }
}

#Preview {
    WorkoutBottomControlsView {
        print("Toggle view tapped")
    }
    .padding()
    .background(Color.black)
    .preferredColorScheme(.dark)
} 