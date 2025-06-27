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
                    progressSection
                        .opacity(animateIn ? 1 : 0)
                        .offset(y: animateIn ? 0 : 40)
                        .animation(.easeOut(duration: 0.5).delay(0.05), value: animateIn)
                    headerSection
                        .opacity(animateIn ? 1 : 0)
                        .offset(y: animateIn ? 0 : 40)
                        .animation(.easeOut(duration: 0.5).delay(0.15), value: animateIn)
                    goalSelectionSection
                        .opacity(animateIn ? 1 : 0)
                        .offset(y: animateIn ? 0 : 40)
                        .animation(.easeOut(duration: 0.5).delay(0.25), value: animateIn)
                    
                    Spacer(minLength: 100)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 120)
            }
            
            // Next button overlay
            if viewModel.selectedGoal != nil {
                VStack {
                    Spacer()
                    nextButtonSection
                        .opacity(animateIn ? 1 : 0)
                        .offset(y: animateIn ? 0 : 40)
                        .animation(.easeOut(duration: 0.5).delay(0.35), value: animateIn)
                        .padding(.horizontal, 0)
                        .padding(.bottom, 0)
                }
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
        VStack(spacing: 20) {
            // Animated target icon
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.appYellow.opacity(0.3), Color.appYellow.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)
                
                Image(systemName: "target")
                    .font(.system(size: 50))
                    .foregroundColor(.appYellow)
                    .scaleEffect(viewModel.selectedGoal != nil ? 1.1 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: viewModel.selectedGoal)
            }
            
            VStack(spacing: 12) {
                Text("What's your main goal?")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.appYellow)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.top, 10)
    }
    
    var goalSelectionSection: some View {
        VStack(spacing: 20) {
            HStack {
                Text("Choose Your Goal")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.appYellow)
                
                Spacer()
                
            }
            
            VStack(spacing: 16) {
                ForEach(Goal.allCases, id: \.self) { goal in
                    EnhancedGoalOptionCard(
                        goal: goal,
                        imageName: viewModel.imageName(for: goal),
                        isSelected: viewModel.selectedGoal == goal
                    ) {
                        selectGoal(goal)
                    }
                }
            }
        }
    }
    
    var nextButtonSection: some View {
        VStack {
            NextButton(
                title: "Next",
                action: proceedToNext,
                isLoading: $isLoading,
                isDisabled: $isButtonDisabled
            )
            
            NavigationLink(
                destination: BodyCurrentView(viewModel: BodyCurrentViewModel(), progressViewModel: progressViewModel),
                isActive: $navigateToBodyCurrent
            ) {
                EmptyView()
            }
            .hidden()
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
