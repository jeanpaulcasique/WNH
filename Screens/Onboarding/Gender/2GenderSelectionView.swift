import SwiftUI

struct GenderSelectionView: View {
    @ObservedObject var viewModel: GenderSelectionViewModel
    @ObservedObject var progressViewModel: ProgressViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var navigateToGoal = false
    @State private var isLoading = false
    @State private var isButtonDisabled = false
    @State private var showCopiedAnimation = false
    
    var body: some View {
        ZStack {
            
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
                    genderSelectionSection
                    infoSection
                    
                    Spacer(minLength: 100)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 120)
            }
            
            // Next button overlay
            if viewModel.selectedGender != nil {
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
        .overlay(
            // Info overlay
            Group {
                if viewModel.showInfo {
                    InfoOverlayView(showInfo: $viewModel.showInfo)
                        .transition(.scale.combined(with: .opacity))
                }
            }
        )
        .overlay(
            // Success animation overlay
            Group {
                if showCopiedAnimation {
                    SelectionSuccessView()
                        .transition(.scale.combined(with: .opacity))
                }
            }
        )
    }
}

// MARK: - Subviews
private extension GenderSelectionView {
    
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
            // Animated gender icon
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
                
                Image(systemName: "person.2.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.appYellow)
                    .scaleEffect(viewModel.selectedGender != nil ? 1.1 : 1.0)
                    .animation(nil, value: viewModel.selectedGender)
            }
            
            VStack(spacing: 1) {
                Text("What's your gender?")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.appYellow)
                    .multilineTextAlignment(.center)
                
                Text("")
                    .font(.system(size: 16))
                    .foregroundColor(.appWhite.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }
        }
        .padding(.top, 10)
    }
    
    var genderSelectionSection: some View {
        VStack(spacing: 20) {
            HStack {
                Text("Choose Your Gender")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.appYellow)
                
                Spacer()
                
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        viewModel.showInfo.toggle()
                    }
                }) {
                    Image(systemName: "info.circle")
                        .foregroundColor(.appYellow.opacity(0.7))
                        .font(.system(size: 16))
                }
            }
            
            HStack(spacing: 20) {
                GenderOptionCard(
                    gender: .male,
                    isSelected: viewModel.selectedGender == .male
                ) {
                    selectGender(.male)
                }
                
                GenderOptionCard(
                    gender: .female,
                    isSelected: viewModel.selectedGender == .female
                ) {
                    selectGender(.female)
                }
            }
        }
    }
    
    var infoSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Why This Matters")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.appYellow)
                Spacer()
            }
            
            VStack(spacing: 12) {
                InfoStepView(
                    icon: "heart.fill",
                    title: "Metabolic Rate",
                    description: "Men and women have different metabolic rates",
                    color: .red
                )
                
                InfoStepView(
                    icon: "flame.fill",
                    title: "Calorie Calculations",
                    description: "Accurate calorie burn and intake recommendations",
                    color: .orange
                )
                
                InfoStepView(
                    icon: "figure.strengthtraining.traditional",
                    title: "Workout Plans",
                    description: "Gender-specific exercise recommendations",
                    color: .blue
                )
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
                destination: GoalView(viewModel: GoalViewModel(), progressViewModel: progressViewModel),
                isActive: $viewModel.navigateToGoal
            ) {
                EmptyView()
            }
          
            .hidden()
        }
    }
        
    // MARK: - Actions
    func selectGender(_ gender: Gender) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            viewModel.selectGender(gender)
            showCopiedAnimation = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation(.easeOut(duration: 0.3)) {
                showCopiedAnimation = false
            }
        }
        // Haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
    
    func proceedToNext() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        progressViewModel.advanceProgress()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            self.viewModel.navigateToGoal = true
        }
    }
}

// MARK: - Supporting Views
struct GenderOptionCard: View {
    let gender: Gender
    let isSelected: Bool
    let action: () -> Void
    
    var genderInfo: (icon: String, title: String, color: Color) {
        switch gender {
        case .male:
            return ("figure.arms.open", "Male", .blue)
        case .female:
            return ("figure.stand", "Female", .pink)
        }
    }
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(
                            isSelected ?
                            genderInfo.color.opacity(0.3) :
                            Color.gray.opacity(0.1)
                        )
                        .frame(width: 80, height: 80)
                    
                    Image(systemName: genderInfo.icon)
                        .font(.system(size: 40))
                        .foregroundColor(isSelected ? genderInfo.color : .appWhite.opacity(0.6))
                    
                    if isSelected {
                        Circle()
                            .stroke(genderInfo.color, lineWidth: 3)
                            .frame(width: 80, height: 80)
                    }
                }
                
                Text(genderInfo.title)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(isSelected ? .appWhite : .appWhite.opacity(0.7))
                
                if isSelected {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 14))
                            .foregroundColor(.green)
                        
                        Text("Selected")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.green)
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 160)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.gray.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                isSelected ? genderInfo.color.opacity(0.6) : Color.gray.opacity(0.3),
                                lineWidth: isSelected ? 2 : 1
                            )
                    )
            )
            .scaleEffect(isSelected ? 1.05 : 1.0)
            .animation(nil, value: isSelected)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct InfoStepView: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 50, height: 50)
                
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(color)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.appWhite)
                
                Text(description)
                    .font(.system(size: 14))
                    .foregroundColor(.appWhite.opacity(0.7))
                    .lineLimit(2)
            }
            
            Spacer()
        }
        .padding(16)
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
    }
}

// Using existing ProgressBarView component

struct InfoOverlayView: View {
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
                        Image(systemName: "info.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.appYellow)
                        
                        Text("Why We Ask This")
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
                    
                    Text("Your gender helps us provide more accurate fitness recommendations, including personalized calorie calculations, workout intensity suggestions, and metabolic rate estimations. This ensures your fitness journey is tailored specifically for you.")
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

struct SelectionSuccessView: View {
    var body: some View {
        VStack {
            Spacer()
            
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                
                Text("Selection saved!")
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

// Using existing Color extensions

// MARK: - Preview
struct GenderSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            GenderSelectionView(
                viewModel: GenderSelectionViewModel(),
                progressViewModel: ProgressViewModel()
            )
        }
        .preferredColorScheme(.dark)
    }
}
