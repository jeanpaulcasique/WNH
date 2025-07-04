import SwiftUI

struct GoalView: View {
    @ObservedObject var viewModel: GoalViewModel
    @ObservedObject var progressViewModel: ProgressViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var navigateToBodyCurrent = false
    @State private var isButtonDisabled = false
    @State private var isLoading = false
    @State private var showSelectionAnimation = false
    @State private var animateIn = false
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 30) {
                    progressSection.cascadingAppear(index: 0)
                    headerSection.cascadingAppear(index: 1)
                    goalSelectionSection.cascadingAppear(index: 2)
                    Spacer(minLength: 100)
                }
                .screenHorizontalPadding()
                .padding(.bottom, 120)
            }
            if viewModel.selectedGoal != nil {
                VStack {
                    Spacer()
                    NextButton(
                        title: "Next",
                        action: proceedToNext,
                        isLoading: $isLoading,
                        isDisabled: $isButtonDisabled
                    )
                    .frame(maxWidth: .infinity)
                    .screenHorizontalPadding()
                    .padding(.bottom, 32)
                    .cascadingAppear(index: 3)
                    NavigationLink(
                        destination: BodyCurrentView(viewModel: BodyCurrentViewModel(), progressViewModel: progressViewModel),
                        isActive: $navigateToBodyCurrent
                    ) {
                        EmptyView()
                    }
                    .hidden()
                }
                .frame(maxWidth: .infinity)
            }
        }
        .blackGradientBackground()
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: backButton)
        .onAppear {
            viewModel.loadGoalFromUserDefaults()
            viewModel.loadGenderFromUserDefaults()
            withAnimation(.spring(response: 0.7, dampingFraction: 0.9)) {
                animateIn = true
            }
        }
        .overlay(
            // Success animation overlay
            Group {
                if showSelectionAnimation {
                    GoalSelectionSuccessView()
                        .transition(.scale.combined(with: .opacity))
                }
            }
        )
    }
}

// MARK: - Subviews
private extension GoalView {
    
    var backButton: some View {
        Button(action: {
            progressViewModel.decreaseProgress()
            presentationMode.wrappedValue.dismiss()
        }) {
            Image(systemName: "chevron.left")
                .foregroundColor(.appYellow)
                .font(.system(size: 18))
        }
    }
    
    var progressSection: some View {
        VStack(spacing: 5) {
            ProgressBarWithIcons(progressViewModel: progressViewModel)
        }
        .padding(.top, 10)
    }
    
    var headerSection: some View {
        PageHeader(
            icon: "target",
            title: "What's your main goal?",
            subtitle: nil,
            progressViewModel: nil
        )
        .padding(.top, 10)
    }
    
    var goalSelectionSection: some View {
        VStack(spacing: 20) {
            SimpleSectionHeader(title: "Choose Your Goal")
            VStack(spacing: 16) {
                ForEach(Goal.allCases, id: \ .self) { goal in
                    let info = goalInfo(for: goal)
                    ExpandableSelectionCard(
                        isSelected: viewModel.selectedGoal == goal,
                        color: info.color,
                        action: { selectGoal(goal) },
                        header: {
                            HStack(spacing: 16) {
                                ZStack {
                                    Circle()
                                        .fill(
                                            LinearGradient(
                                                colors: [info.color.opacity(viewModel.selectedGoal == goal ? 0.3 : 0.2), info.color.opacity(viewModel.selectedGoal == goal ? 0.1 : 0.05)],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .frame(width: 70, height: 70)
                                    Image(systemName: info.icon)
                                        .font(.system(size: 30))
                                        .foregroundColor(info.color)
                                }
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Text(goal.rawValue)
                                            .font(.system(size: 18, weight: .semibold))
                                            .foregroundColor(.appWhite)
                                        Spacer()
                                        if viewModel.selectedGoal == goal {
                                            Image(systemName: "checkmark.circle.fill")
                                                .font(.system(size: 20))
                                                .foregroundColor(.green)
                                        } else {
                                            Image(systemName: "circle")
                                                .font(.system(size: 20))
                                                .foregroundColor(.appWhite.opacity(0.3))
                                        }
                                    }
                                    Text(info.description)
                                        .font(.system(size: 14))
                                        .foregroundColor(.appWhite.opacity(0.7))
                                        .lineLimit(2)
                                }
                            }
                        },
                        expandedContent: {
                            VStack(spacing: 8) {
                                HStack {
                                    Text("What you'll get:")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(info.color)
                                    Spacer()
                                }
                                ForEach(info.benefits, id: \ .self) { benefit in
                                    HStack(spacing: 8) {
                                        Image(systemName: "checkmark.circle.fill")
                                            .font(.system(size: 12))
                                            .foregroundColor(info.color)
                                        Text(benefit)
                                            .font(.system(size: 13))
                                            .foregroundColor(.appWhite.opacity(0.8))
                                        Spacer()
                                    }
                                }
                            }
                        }
                    )
                }
            }
        }
    }
}

// MARK: - Actions
private extension GoalView {
    func selectGoal(_ goal: Goal) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            viewModel.selectGoal(goal)
        }
        
        // Show success animation
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            showSelectionAnimation = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                showSelectionAnimation = false
            }
        }
        
        // Haptic feedback
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }
    
    func proceedToNext() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        progressViewModel.advanceProgress()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.navigateToBodyCurrent = true
        }
    }
}

// Helper para info de cada goal
private extension GoalView {
    func goalInfo(for goal: Goal) -> (color: Color, icon: String, description: String, benefits: [String]) {
        switch goal {
        case .loseWeight:
            return (.red, "flame.fill", "Focus on burning calories and fat loss", [
                "High-intensity cardio workouts",
                "Calorie tracking and nutrition guidance",
                "Fat-burning exercise routines"
            ])
        case .buildMuscle:
            return (.blue, "dumbbell.fill", "Build strength and increase muscle mass", [
                "Progressive strength training",
                "Muscle-building nutrition plans",
                "Recovery and growth optimization"
            ])
        case .keepFit:
            return (.green, "heart.fill", "Maintain fitness and overall health", [
                "Balanced cardio and strength mix",
                "Flexibility and mobility focus",
                "Sustainable healthy habits"
            ])
        }
    }
}

// MARK: - Preview
struct GoalView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            GoalView(
                viewModel: GoalViewModel(),
                progressViewModel: ProgressViewModel()
            )
        }
        .preferredColorScheme(.dark)
    }
}
