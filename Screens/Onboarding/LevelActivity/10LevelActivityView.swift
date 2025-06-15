import SwiftUI
import Combine

// MARK: - LevelActivityView
struct LevelActivityView: View {
    @StateObject private var viewModel = LevelActivityViewModel()
    @ObservedObject var progressViewModel: ProgressViewModel
    @State private var navigateToNextView = false
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        ZStack {
            // Elegant gradient background
            LinearGradient(
                colors: [Color.black, Color.gray.opacity(0.3), Color.black],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
        VStack {
            progressBar
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 30) {
                    titleSection
                    activityCardsSection
                    selectedInfoSection
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 100)
            }
            
            Spacer()
            
            // NextButton como en las pantallas ejemplo
            NextButton(
                title: "Next",
                action: proceedToNext,
                isLoading: $viewModel.isLoading,
                isDisabled: $viewModel.isNextButtonDisabled
            )
            .padding(.bottom, 0)

            navigationLink
        }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar { backButton }
    }
}

// MARK: - Subviews & Helpers
private extension LevelActivityView {
    var progressBar: some View {
        VStack(spacing: 5) {
            ProgressBarWithIcons(progressViewModel: progressViewModel)
        }
        .padding(.top, 10)
    }

    var titleSection: some View {
        VStack(spacing: 16) {
            Text("What's your activity level?")
                .font(.system(size: 32, weight: .bold))
                .multilineTextAlignment(.center)
                .foregroundColor(.yellow)
                .padding(.top, 20)
            
            Text("This helps us calculate your daily calorie needs")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
        }
    }
    
    var activityCardsSection: some View {
        VStack(spacing: 16) {
            ForEach(viewModel.activityLevels, id: \.id) { level in
                ActivityCard(
                    level: level,
                    isSelected: viewModel.selectedLevel == level.id,
                    action: { viewModel.selectLevel(level.id) }
                )
            }
        }
    }
    
    var selectedInfoSection: some View {
        VStack(spacing: 20) {
            // Selected level highlight
            VStack(spacing: 12) {
                Text("Selected Level")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.yellow)
                
                HStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(viewModel.currentActivityLevel.color.opacity(0.2))
                            .frame(width: 60, height: 60)
                        
                        Image(systemName: viewModel.currentActivityLevel.icon)
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundColor(viewModel.currentActivityLevel.color)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(viewModel.currentActivityLevel.title)
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("Calorie Factor: \(viewModel.currentActivityLevel.calorieMultiplier)")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(viewModel.currentActivityLevel.color)
                    }
                    
                    Spacer()
                }
                .padding(20)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(viewModel.currentActivityLevel.color.opacity(0.3), lineWidth: 2)
                )
            }
        }
    }
    
    var nextButtonSection: some View {
        VStack {
            NextButton(
                title: "Next",
                action: proceedToNext,
                isLoading: $viewModel.isLoading,
                isDisabled: $viewModel.isNextButtonDisabled
            )
            
            NavigationLink(
                destination: WorkoutLevelView(progressViewModel: progressViewModel),
                isActive: $navigateToNextView
            ) {
                EmptyView()
            }
            .hidden()
        }
    }

    var navigationLink: some View {
        NavigationLink(
            destination: WorkoutLevelView(progressViewModel: progressViewModel),
            isActive: $navigateToNextView
        ) {
            EmptyView()
        }
        .hidden()
    }

    var backButton: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Button(action: goBack) {
                Image(systemName: "chevron.left")
                    .foregroundColor(.yellow)
                    .font(.system(size: 18, weight: .semibold))
            }
        }
    }

    func proceedToNext() {
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
        
        viewModel.disableNextButtonTemporarily()

        withAnimation(.easeInOut(duration: 0.5)) {
            progressViewModel.advanceProgress()
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            navigateToNextView = true
        }
    }

    func goBack() {
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
        
        withAnimation(.easeInOut(duration: 0.3)) {
            progressViewModel.decreaseProgress()
        }
        presentationMode.wrappedValue.dismiss()
    }
}

// MARK: - ActivityCard Component
struct ActivityCard: View {
    let level: ActivityLevel
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Icon section
                ZStack {
                    Circle()
                        .fill(isSelected ? level.color : level.color.opacity(0.2))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: level.icon)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(isSelected ? .white : level.color)
                }
                
                // Content section
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(level.title)
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(isSelected ? .yellow : .white)
                        
                        Spacer()
                        
                        Text(level.calorieMultiplier)
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(isSelected ? level.color : .white.opacity(0.6))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(isSelected ? .white.opacity(0.2) : .gray.opacity(0.2))
                            .cornerRadius(8)
                    }
                    
                    Text(level.subtitle)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(isSelected ? level.color : .white.opacity(0.7))
                    
                    Text(level.description)
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.6))
                        .lineLimit(2)
                }
                
                // Selection indicator
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.yellow)
                }
            }
            .padding(20)
            .background(isSelected ? Color.gray.opacity(0.2) : Color.gray.opacity(0.1))
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? .yellow : level.color.opacity(0.3), lineWidth: isSelected ? 2 : 1)
            )
            .scaleEffect(isSelected ? 1.02 : 1.0)
            .shadow(color: isSelected ? Color.yellow.opacity(0.3) : Color.clear, radius: 8, x: 0, y: 4)
        }
        .buttonStyle(PlainButtonStyle())
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
}

// MARK: - Preview
struct LevelActivityView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            LevelActivityView(progressViewModel: ProgressViewModel())
        }
        .preferredColorScheme(.dark)
    }
}
