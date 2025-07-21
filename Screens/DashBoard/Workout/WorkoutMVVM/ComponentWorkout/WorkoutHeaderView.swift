import SwiftUI

/// Componente del header de WorkoutView que muestra saludo y tips
struct WorkoutHeaderView: View {
    @ObservedObject var viewModel: WorkoutHeaderViewModel
    
    var body: some View {
        VStack(spacing: 4) {
            // Saludo
            HStack {
                Image(systemName: "figure.strengthtraining.traditional")
                    .font(WorkoutTypography.headerIcon)
                    .foregroundColor(WorkoutColors.textAccent)
                
                Text(viewModel.greetingMessage)
                    .font(WorkoutTypography.headerTitle)
                    .foregroundColor(WorkoutColors.textAccent)
                
                Spacer()
            }
            .padding(.bottom, 2)
            
            // Tips animados
            ZStack {
                ForEach(0..<WorkoutTip.workoutTips.count, id: \.self) { i in
                    if i == viewModel.currentTipIndex {
                        Text(viewModel.currentTip.message)
                            .font(WorkoutTypography.headerTip)
                            .foregroundColor(WorkoutColors.textSecondary)
                            .multilineTextAlignment(.center)
                            // .padding(.horizontal, 8) // Eliminado para evitar padding doble
                            .lineLimit(2)
                            .minimumScaleFactor(0.85)
                            .id(i)
                            .opacity(viewModel.animateTip ? 1 : 0)
                            .offset(y: viewModel.animateTip ? 0 : 30)
                            .animation(.spring(response: 0.7, dampingFraction: 0.7), value: viewModel.animateTip)
                    }
                }
            }
            .frame(height: 26)
        }
        .padding(.vertical, 8) // Solo padding vertical interno
        .frame(maxWidth: .infinity, alignment: .leading) // Expande el fondo y borde
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(WorkoutColors.cardBackground)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [WorkoutColors.cardBorder, WorkoutColors.cardBorder.opacity(0.2), .clear],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.2
                )
        )
        .shadow(color: WorkoutColors.cardShadow, radius: 5, x: 0, y: 2)
    }
}

#Preview {
    WorkoutHeaderView(viewModel: WorkoutHeaderViewModel())
        .padding()
        .background(Color.black)
        .preferredColorScheme(.dark)
} 
