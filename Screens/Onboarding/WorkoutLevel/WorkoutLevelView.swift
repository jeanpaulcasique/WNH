import SwiftUI
import Combine


// MARK: - WorkoutLevelView
struct WorkoutLevelView: View {
    @StateObject private var viewModel = WorkoutLevelViewModel()
    @ObservedObject var progressViewModel: ProgressViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var navigateToNextScreen = false

    var body: some View {
        ZStack {
            // Elegant gradient background
            LinearGradient(
                colors: [Color.black, Color.gray.opacity(0.3), Color.black],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 30) {
                    progressSection
                    headerSection
                    levelsSection
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 120)
            }
            
            // Next button overlay - floating
            VStack {
                Spacer()
                nextButtonSection
                    .padding(.horizontal, 0)
                    .padding(.bottom, 0)
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar { backButton }
    }
}

// MARK: - Subviews
private extension WorkoutLevelView {
    var progressSection: some View {
        VStack(spacing: 5) {
            ProgressBarWithIcons(progressViewModel: progressViewModel)
        }
        .padding(.top, 10)
    }
    
    var headerSection: some View {
        VStack(spacing: 20) {
            // Animated fitness icon
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.yellow.opacity(0.4),
                                Color.yellow.opacity(0.1),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 30,
                            endRadius: 80
                        )
                    )
                    .frame(width: 140, height: 140)
                
                Image(systemName: "flame.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.yellow)
                    .scaleEffect(viewModel.selectedIndex != nil ? 1.1 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: viewModel.selectedIndex)
            }
            
            VStack(spacing: 12) {
                Text("Choose your workout level")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.yellow)
                    .multilineTextAlignment(.center)
                
                Text("We'll personalize your training intensity")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.top, 15)
    }
    
    var levelsSection: some View {
        VStack(spacing: 20) {
            HStack {
                Text("Select Your Level")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.yellow)
                
                Spacer()
                
                Text("Tap to see details")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white.opacity(0.6))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
            }
            
            VStack(spacing: 16) {
                ForEach(viewModel.workoutLevels, id: \.id) { level in
                    EnhancedLevelCard(
                        level: level,
                        isSelected: viewModel.selectedIndex == level.id
                    ) {
                        viewModel.selectLevel(at: level.id)
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
                isLoading: $viewModel.isLoading,
                isDisabled: $viewModel.isNextButtonDisabled
            )
            
            NavigationLink(
                destination: NewScreenView(progressViewModel: progressViewModel),
                isActive: $navigateToNextScreen
            ) {
                EmptyView()
            }
            .hidden()
        }
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
        guard let selectedIndex = viewModel.selectedIndex else { return }
        
        // Haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
        
        // Save selection
        let selectedLevel = viewModel.workoutLevels[selectedIndex].title
        UserDefaults.standard.set(selectedLevel, forKey: "selectedWorkoutLevel")
        
        // Disable button temporarily
        viewModel.disableNextButtonTemporarily()
        
        // Advance progress
        withAnimation(.easeInOut(duration: 0.5)) {
            progressViewModel.advanceProgress()
        }
        
        // Navigate after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            navigateToNextScreen = true
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

// MARK: - Enhanced Level Card
struct EnhancedLevelCard: View {
    let level: WorkoutLevel
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 0) {
                // Main card content
                HStack(spacing: 16) {
                    // Level icon with intensity indicator
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        level.color.opacity(isSelected ? 0.4 : 0.2),
                                        level.color.opacity(isSelected ? 0.1 : 0.05)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 70, height: 70)
                        
                        VStack(spacing: 4) {
                            Image(systemName: level.icon)
                                .font(.system(size: 24, weight: .semibold))
                                .foregroundColor(level.color)
                            
                            // Intensity dots
                            HStack(spacing: 2) {
                                ForEach(0..<3) { index in
                                    Circle()
                                        .fill(index <= level.id ? level.color : level.color.opacity(0.3))
                                        .frame(width: 4, height: 4)
                                }
                            }
                        }
                    }
                    
                    // Level info
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(level.title)
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(.white)
                                
                                Text(level.subtitle)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(level.color)
                            }
                            
                            Spacer()
                            
                            // Selection indicator
                            if isSelected {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 22))
                                    .foregroundColor(.green)
                            } else {
                                Image(systemName: "circle")
                                    .font(.system(size: 22))
                                    .foregroundColor(.white.opacity(0.3))
                            }
                        }
                        
                        // Quick stats
                        HStack(spacing: 20) {
                            StatPill(icon: "clock", text: level.duration, color: level.color)
                            StatPill(icon: "calendar", text: level.frequency, color: level.color)
                        }
                        
                        Text(level.description)
                            .font(.system(size: 13))
                            .foregroundColor(.white.opacity(0.7))
                            .lineLimit(2)
                    }
                }
                .padding(20)
                
                // Expandable benefits section (only when selected)
                if isSelected {
                    VStack(spacing: 12) {
                        Divider()
                            .background(level.color.opacity(0.3))
                        
                        VStack(spacing: 8) {
                            HStack {
                                Text("What you'll achieve:")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(level.color)
                                Spacer()
                            }
                            
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), alignment: .leading), count: 1), spacing: 6) {
                                ForEach(level.benefits, id: \.self) { benefit in
                                    HStack(spacing: 8) {
                                        Image(systemName: "checkmark.circle.fill")
                                            .font(.system(size: 12))
                                            .foregroundColor(level.color)
                                        
                                        Text(benefit)
                                            .font(.system(size: 13))
                                            .foregroundColor(.white.opacity(0.8))
                                        
                                        Spacer()
                                    }
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
                                isSelected ? level.color.opacity(0.6) : Color.gray.opacity(0.3),
                                lineWidth: isSelected ? 2 : 1
                            )
                    )
            )
            .scaleEffect(isSelected ? 1.02 : 1.0)
            .shadow(
                color: isSelected ? level.color.opacity(0.3) : Color.clear,
                radius: isSelected ? 12 : 0,
                x: 0,
                y: 6
            )
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Support Components
struct StatPill: View {
    let icon: String
    let text: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 10))
                .foregroundColor(color)
            
            Text(text)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.white.opacity(0.8))
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(color.opacity(0.2))
        .cornerRadius(8)
    }
}

// MARK: - Preview
struct WorkoutLevelView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            WorkoutLevelView(progressViewModel: ProgressViewModel())
        }
        .preferredColorScheme(.dark)
    }
}
