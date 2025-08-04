import SwiftUI

struct StepsIndicator: View {
    @ObservedObject var workoutViewModel: WorkoutViewModel
    var isAuthorized: Bool
    var isLoading: Bool = false
    var onRequestAuthorization: () -> Void
    @State private var stepsScale: CGFloat = 1.0
    @State private var showAuthDialog = false
    
    var body: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(gradient: Gradient(colors: [Color.green.opacity(0.35), .black]), center: .center, startRadius: 8, endRadius: 40)
                )
                .frame(width: 60, height: 60)
            
            VStack(spacing: 1) {
                Text("STEPS")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.yellow.opacity(0.7))
                
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.7)
                } else {
                    Text(isAuthorized ? "\(workoutViewModel.getTodaySteps())" : "--")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .scaleEffect(stepsScale)
                        .animation(.spring(response: 0.4, dampingFraction: 0.5), value: stepsScale)
                }
                
                Image(systemName: "shoe")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 14, height: 14)
                    .foregroundColor(.green)
            }
        }
        .onChange(of: workoutViewModel.getTodaySteps()) { old, new in
            if old != new && isAuthorized {
                stepsScale = 1.25
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
                    stepsScale = 1.0
                }
            }
        }
        .onTapGesture {
            if !isAuthorized {
                showAuthDialog = true
            }
        }
        .alert(isPresented: $showAuthDialog) {
            Alert(
                title: Text("Allow Health Access"),
                message: Text("To show your daily steps, please allow access to Health data."),
                primaryButton: .default(Text("Allow"), action: onRequestAuthorization),
                secondaryButton: .cancel()
            )
        }
    }
} 