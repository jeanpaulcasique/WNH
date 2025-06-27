import SwiftUI
import UIKit

// MARK: - WhichPlaceView
struct WhichPlaceView: View {
    @StateObject private var viewModel = WhichPlaceViewModel()
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
private extension WhichPlaceView {
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

// MARK: - Preview
struct WhichPlaceView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            WhichPlaceView(progressViewModel: ProgressViewModel())
        }
        .preferredColorScheme(.dark)
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
                            Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                                .font(.system(size: 24))
                                .foregroundColor(isSelected ? .yellow : .white.opacity(0.3))
                        }
                        
                        Text(location.description)
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.6))
                            .lineLimit(2)
                    }
                }
                .padding(20)
                
                // Expandable benefits section
                if isSelected {
                    VStack(spacing: 12) {
                        Divider()
                            .background(location.color.opacity(0.3))
                            .padding(.horizontal, 20)
                        
                        // Advantages Section
                        VStack(alignment: .leading, spacing: 8) {
                            Text("What you'll get:")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(location.color)
                            
                            ForEach(location.features, id: \.self) { feature in
                                HStack(spacing: 8) {
                                    Image(systemName: feature.icon)
                                        .font(.system(size: 12))
                                        .foregroundColor(location.color)
                                    Text(feature.text)
                                        .font(.system(size: 13))
                                        .foregroundColor(.white.opacity(0.8))
                                    Spacer()
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        // Equipment & Convenience Section
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Equipment").font(.caption).foregroundColor(.gray)
                                Text(location.equipment).font(.footnote)
                            }
                            Spacer()
                            VStack(alignment: .trailing) {
                                Text("Convenience").font(.caption).foregroundColor(.gray)
                                Text(location.convenience).font(.footnote)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 16)
                    }
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.gray.opacity(isSelected ? 0.2 : 0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(
                                isSelected ? location.color.opacity(0.7) : Color.gray.opacity(0.4),
                                lineWidth: isSelected ? 2.5 : 1
                            )
                    )
            )
            .scaleEffect(isSelected ? 1.03 : 1.0)
            .shadow(
                color: isSelected ? location.color.opacity(0.4) : Color.clear,
                radius: isSelected ? 15 : 0,
                x: 0,
                y: 8
            )
            .animation(.spring(response: 0.4, dampingFraction: 0.7), value: isSelected)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
