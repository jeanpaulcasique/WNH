import SwiftUI
import UIKit

// MARK: - NewScreenView
struct NewScreenView: View {
    @StateObject private var viewModel = NewScreenViewModel()
    @ObservedObject var progressViewModel: ProgressViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var navigateToNextView = false
    @State private var navigateToShowInfo = false

    var body: some View {
        ZStack {
            // Premium gradient background
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
                    locationsSection
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 120)
            }
            
            // Floating next button (only when selection made)
            if viewModel.selectedIndex != nil {
                VStack {
                    Spacer()
                    nextButtonSection
                        .padding(.horizontal, 0)
                        .padding(.bottom, 0)
                }
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar { backButton }
    }
}

// MARK: - Subviews
private extension NewScreenView {
    var progressSection: some View {
        VStack(spacing: 5) {
            ProgressBarWithIcons(progressViewModel: progressViewModel)
        }
        .padding(.top, 10)
    }
    
    var headerSection: some View {
        VStack(spacing: 20) {
            // Animated location icon with pulsing effect
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
                            endRadius: 90
                        )
                    )
                    .frame(width: 140, height: 140)
                    .scaleEffect(viewModel.selectedIndex != nil ? 1.1 : 1.0)
                    .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: viewModel.selectedIndex != nil)
                
                Image(systemName: "location.circle.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.yellow)
                    .scaleEffect(viewModel.selectedIndex != nil ? 1.1 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: viewModel.selectedIndex)
            }
            
            VStack(spacing: 12) {
                Text("Where do you prefer to workout?")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.yellow)
                    .multilineTextAlignment(.center)
                
                Text("Choose your ideal training environment")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.top, 15)
    }
    
    var locationsSection: some View {
        VStack(spacing: 20) {
            HStack {
                Text("Choose Your Environment")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.yellow)
                
                Spacer()
                
                Text("Tap to explore")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white.opacity(0.6))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
            }
            
            VStack(spacing: 16) {
                ForEach(viewModel.workoutLocations, id: \.id) { location in
                    EpicLocationCard(
                        location: location,
                        isSelected: viewModel.selectedIndex == location.id
                    ) {
                        viewModel.selectLocation(at: location.id)
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
                destination: GymEquipmentView(progressViewModel: progressViewModel),
                isActive: $navigateToNextView
            ) {
                EmptyView()
            }
            .hidden()
            
            NavigationLink(
                destination: ShowInfoView(),
                isActive: $navigateToShowInfo
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
    
    private func proceedToNext() {
        guard let selectedIndex = viewModel.selectedIndex else { return }
        
        // Enhanced haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
        impactFeedback.impactOccurred()
        
        // Guardar información adicional para el dashboard
        let selectedLocation = viewModel.workoutLocations[selectedIndex]
        UserDefaults.standard.set(selectedLocation.title, forKey: "selectedWorkoutLocation")
        UserDefaults.standard.set(selectedIndex, forKey: "workoutLocationIndex")
        
        print("🎯 Guardado para dashboard - Ubicación: \(selectedLocation.title), Índice: \(selectedIndex)")
        
        // Disable button temporarily
        viewModel.disableNextButtonTemporarily()
        
        // Advance progress
        withAnimation(.easeInOut(duration: 0.5)) {
            progressViewModel.advanceProgress()
        }
        
        // Navigate based on selection
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            if selectedIndex == 0 || selectedIndex == 2 {  // At Home o Al aire libre
                navigateToNextView = true
            } else if selectedIndex == 1 {  // At the Gym
                navigateToShowInfo = true
            }
        }
    }
    
    private func goBack() {
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
        
        withAnimation(.easeInOut(duration: 0.3)) {
            progressViewModel.decreaseProgress()
        }
        presentationMode.wrappedValue.dismiss()
    }
}

// MARK: - Epic Location Card
struct EpicLocationCard: View {
    let location: WorkoutLocationModel
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 0) {
                // Main card content
                HStack(spacing: 16) {
                    // Location icon with gradient background
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        location.color.opacity(isSelected ? 0.4 : 0.2),
                                        location.color.opacity(isSelected ? 0.1 : 0.05)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 70, height: 70)
                        
                        Image(systemName: location.icon)
                            .font(.system(size: 28, weight: .semibold))
                            .foregroundColor(location.color)
                    }
                    
                    // Location info
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(location.title)
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(.white)
                                
                                Text(location.subtitle)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.white.opacity(0.7))
                            }
                            
                            Spacer()
                            
                            // Selection indicator
                            if isSelected {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 24))
                                    .foregroundColor(.yellow)
                                    .transition(.scale.combined(with: .opacity))
                            }
                        }
                        
                        Text(location.description)
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.6))
                            .lineLimit(2)
                    }
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.black.opacity(0.3))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(
                                    isSelected ? Color.yellow : Color.clear,
                                    lineWidth: 2
                                )
                        )
                )
                
                // Expanded info (only when selected)
                if isSelected {
                    VStack(alignment: .leading, spacing: 16) {
                        // Advantages section
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Advantages")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.yellow)
                            
                            ForEach(location.advantages, id: \.self) { advantage in
                                HStack(spacing: 8) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                    Text(advantage)
                                        .font(.system(size: 14))
                                        .foregroundColor(.white.opacity(0.8))
                                }
                            }
                        }
                        
                        // Equipment section
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Equipment")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.white.opacity(0.7))
                                Text(location.equipment)
                                    .font(.system(size: 14))
                                    .foregroundColor(.white.opacity(0.6))
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .trailing, spacing: 4) {
                                Text("Convenience")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.white.opacity(0.7))
                                Text(location.convenience)
                                    .font(.system(size: 14))
                                    .foregroundColor(.white.opacity(0.6))
                            }
                        }
                    }
                    .padding(16)
                    .background(Color.black.opacity(0.2))
                    .cornerRadius(16)
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
}

// MARK: - Support Components
struct QuickStat: View {
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
struct NewScreenView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            NewScreenView(progressViewModel: ProgressViewModel())
        }
        .preferredColorScheme(.dark)
    }
}
