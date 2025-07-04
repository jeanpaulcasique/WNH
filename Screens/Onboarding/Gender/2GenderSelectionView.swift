import SwiftUI

struct GenderSelectionView: View {
    @State private var selectedGender: Gender? = nil
    @State private var navigateToGoal = false
    @ObservedObject var progressViewModel: ProgressViewModel
    @ObservedObject var viewModel: GenderSelectionViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            Color.appBackgroundGradient.ignoresSafeArea()
            ScrollView {
                VStack(spacing: 30) {
                    ProgressBarWithIcons(progressViewModel: progressViewModel)
                        .cascadingAppear(index: 0)
                    // Header
                    VStack(spacing: 8) {
                        Image(systemName: "person.2.fill")
                            .font(.system(size: 44))
                            .foregroundColor(.appYellow)
                        Text("What's your gender?")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.appYellow)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 8)
                    .cascadingAppear(index: 1)
                    // Tarjetas de género
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Choose Your Gender")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.appYellow)
                            .padding(.leading, 8)
                        HStack(spacing: 20) {
                            IconCard(
                                icon: "figure.arms.open",
                                title: "Male",
                                isSelected: selectedGender == .male,
                                color: Color.blue
                            ) {
                                withAnimation(.easeOut(duration: 0.15)) {
                                    selectedGender = .male
                                }
                            }
                            IconCard(
                                icon: "figure.stand",
                                title: "Female",
                                isSelected: selectedGender == .female,
                                color: Color.pink
                            ) {
                                withAnimation(.easeOut(duration: 0.15)) {
                                    selectedGender = .female
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                    .cascadingAppear(index: 2)
                    // Info cards
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Why This Matters")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.appYellow)
                            .padding(.leading, 8)
                        VStack(spacing: 12) {
                            InfoCard(
                                icon: "heart.fill",
                                title: "Metabolic Rate",
                                description: "Men and women have different metabolic rates",
                                color: .appSuccess
                            )
                            InfoCard(
                                icon: "flame.fill",
                                title: "Calorie Calculations",
                                description: "Accurate calorie burn and intake recommendations",
                                color: .appWarning
                            )
                            InfoCard(
                                icon: "figure.strengthtraining.traditional",
                                title: "Workout Plans",
                                description: "Gender-specific exercise recommendations",
                                color: .appInfo
                            )
                        }
                        .padding(.horizontal, 16)
                    }
                    .cascadingAppear(index: 3)
                    Spacer(minLength: 100)
                }
                .screenHorizontalPadding()
                .padding(.bottom, 120)
            }
            if selectedGender != nil {
                VStack {
                    Spacer()
                    NextButton(
                        title: "Next",
                        action: {
                            if let gender = selectedGender {
                                viewModel.selectedGender = gender
                            }
                            progressViewModel.advanceProgress()
                            navigateToGoal = true
                        },
                        isLoading: $viewModel.isLoading,
                        isDisabled: .constant(selectedGender == nil || viewModel.isButtonDisabled)
                    )
                    .frame(maxWidth: .infinity)
                    .screenHorizontalPadding()
                    .padding(.bottom, 32)
                    .cascadingAppear(index: 4)
                    NavigationLink(
                        destination: GoalView(viewModel: GoalViewModel(), progressViewModel: progressViewModel),
                        isActive: $navigateToGoal
                    ) {
                        EmptyView()
                    }
                    .hidden()
                }
                .frame(maxWidth: .infinity)
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

// MARK: - Preview
struct GenderSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            GenderSelectionView(
                progressViewModel: ProgressViewModel(),
                viewModel: GenderSelectionViewModel()
            )
        }
        .preferredColorScheme(.dark)
    }
}
