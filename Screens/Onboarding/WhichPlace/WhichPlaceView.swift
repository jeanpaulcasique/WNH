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
    let location: WorkoutLocation
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
                                    .foregroundColor(location.color)
                            }
                            
                            Spacer()
                            
                            // Selection indicator with animation
                            if isSelected {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 24))
                                    .foregroundColor(.green)
                                    .scaleEffect(1.2)
                                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)
                            } else {
                                Image(systemName: "circle")
                                    .font(.system(size: 24))
                                    .foregroundColor(.white.opacity(0.3))
                            }
                        }
                        
                        // Quick stats row - solo equipamiento
                        HStack {
                            QuickStat(icon: "wrench.and.screwdriver", text: location.equipment, color: location.color)
                            Spacer()
                        }
                        
                        Text(location.description)
                            .font(.system(size: 13))
                            .foregroundColor(.white.opacity(0.7))
                            .lineLimit(isSelected ? nil : 2)
                    }
                }
                .padding(20)
                
                // Expandable advantages section (only when selected)
                if isSelected {
                    VStack(spacing: 12) {
                        Divider()
                            .background(location.color.opacity(0.4))
                        
                        VStack(spacing: 8) {
                            HStack {
                                Text("Why choose \(location.title == "Outdoors" ? "Al Aire Libre" : location.title.lowercased())?")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(location.color)
                                Spacer()
                            }
                            
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), alignment: .leading), count: 2), spacing: 8) {
                                ForEach(location.advantages, id: \.self) { advantage in
                                    HStack(spacing: 6) {
                                        Image(systemName: "checkmark.circle.fill")
                                            .font(.system(size: 10))
                                            .foregroundColor(location.color)
                                        
                                        Text(advantage)
                                            .font(.system(size: 12))
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
                                isSelected ? location.color.opacity(0.6) : Color.gray.opacity(0.3),
                                lineWidth: isSelected ? 2 : 1
                            )
                    )
            )
            .scaleEffect(isSelected ? 1.02 : 1.0)
            .shadow(
                color: isSelected ? location.color.opacity(0.3) : Color.clear,
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
