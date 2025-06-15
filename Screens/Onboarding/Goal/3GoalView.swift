import SwiftUI

struct GoalView: View {
    @ObservedObject var viewModel: GoalViewModel
    @ObservedObject var progressViewModel: ProgressViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var navigateToBodyCurrent = false
    @State private var showInfo = false
    @State private var isButtonDisabled = false
    @State private var isLoading = false
    @State private var showSelectionAnimation = false
    
    var body: some View {
        ZStack {
            // Gradient background matching TellAF style
            LinearGradient(
                colors: [Color.appBlack, Color.gray.opacity(0.3), Color.appBlack],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 30) {
                    progressSection
                    headerSection
                    goalSelectionSection
                    
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
                        .padding(.horizontal, 0)
                        .padding(.bottom, 0)
                }
            }
        }
       
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: backButton)
        .onAppear {
            viewModel.loadGoalFromUserDefaults()
            viewModel.loadGenderFromUserDefaults()
        }
        .overlay(
            // Info overlay
            Group {
                if showInfo {
                    GoalInfoOverlayView(showInfo: $showInfo)
                        .transition(.scale.combined(with: .opacity))
                }
            }
        )
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
                
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        showInfo.toggle()
                    }
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "info.circle")
                            .font(.system(size: 14))
                        Text("Why this matters")
                            .font(.system(size: 12, weight: .medium))
                    }
                    .foregroundColor(.appYellow.opacity(0.8))
                }
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
    
    // MARK: - Actions
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

// MARK: - Supporting Views
struct EnhancedGoalOptionCard: View {
    let goal: Goal
    let imageName: String
    let isSelected: Bool
    let action: () -> Void
    
    var goalInfo: (color: Color, icon: String, description: String, benefits: [String]) {
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
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 0) {
                // Main card content
                HStack(spacing: 16) {
                    // Goal icon with image fallback
                    ZStack {
                        // Background circle
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        goalInfo.color.opacity(isSelected ? 0.3 : 0.2),
                                        goalInfo.color.opacity(isSelected ? 0.1 : 0.05)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 70, height: 70)
                        
                        // Icon
                        Image(systemName: goalInfo.icon)
                            .font(.system(size: 30))
                            .foregroundColor(goalInfo.color)
                    }
                    
                    // Goal info
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(goal.rawValue)
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.appWhite)
                            
                            Spacer()
                            
                            // Selection indicator
                            if isSelected {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(.green)
                            } else {
                                Image(systemName: "circle")
                                    .font(.system(size: 20))
                                    .foregroundColor(.appWhite.opacity(0.3))
                            }
                        }
                        
                        Text(goalInfo.description)
                            .font(.system(size: 14))
                            .foregroundColor(.appWhite.opacity(0.7))
                            .lineLimit(2)
                    }
                }
                .padding(20)
                
                // Expandable benefits section (only when selected)
                if isSelected {
                    VStack(spacing: 12) {
                        Divider()
                            .background(goalInfo.color.opacity(0.3))
                        
                        VStack(spacing: 8) {
                            HStack {
                                Text("What you'll get:")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(goalInfo.color)
                                Spacer()
                            }
                            
                            ForEach(goalInfo.benefits, id: \.self) { benefit in
                                HStack(spacing: 8) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 12))
                                        .foregroundColor(goalInfo.color)
                                    
                                    Text(benefit)
                                        .font(.system(size: 13))
                                        .foregroundColor(.appWhite.opacity(0.8))
                                    
                                    Spacer()
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 16)
                    }
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.gray.opacity(isSelected ? 0.15 : 0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                isSelected ? goalInfo.color.opacity(0.6) : Color.gray.opacity(0.3),
                                lineWidth: isSelected ? 2 : 1
                            )
                    )
            )
            .scaleEffect(isSelected ? 1.02 : 1.0)
            .shadow(
                color: isSelected ? goalInfo.color.opacity(0.3) : Color.clear,
                radius: isSelected ? 12 : 0,
                x: 0,
                y: 6
            )
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// Removed GoalBenefitView - functionality integrated into EnhancedGoalOptionCard

struct GoalInfoOverlayView: View {
    @Binding var showInfo: Bool
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.6)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        showInfo = false
                    }
                }
            
            VStack(spacing: 20) {
                VStack(spacing: 16) {
                    HStack {
                        Image(systemName: "target")
                            .font(.system(size: 24))
                            .foregroundColor(.appYellow)
                        
                        Text("Why Choose a Goal?")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.appWhite)
                        
                        Spacer()
                        
                        Button(action: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                showInfo = false
                            }
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 20))
                                .foregroundColor(.appWhite.opacity(0.6))
                        }
                    }
                    
                    Text("Your goal shapes your entire fitness journey. We'll create a personalized workout plan with the perfect mix of cardio and strength training to help you achieve your specific objective efficiently and safely.")
                        .font(.system(size: 16))
                        .foregroundColor(.appWhite.opacity(0.8))
                        .lineSpacing(4)
                        .multilineTextAlignment(.leading)
                }
                
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        showInfo = false
                    }
                }) {
                    Text("Got it!")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.appBlack)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(Color.appYellow)
                        .cornerRadius(12)
                }
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.gray.opacity(0.95))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.appYellow.opacity(0.3), lineWidth: 1)
                    )
            )
            .padding(.horizontal, 40)
        }
    }
}

struct GoalSelectionSuccessView: View {
    var body: some View {
        VStack {
            Spacer()
            
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                
                Text("Goal selected!")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.appWhite)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(Color.gray.opacity(0.9))
            .cornerRadius(25)
            .padding(.bottom, 60)
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
