import SwiftUI



// MARK: - GymEquipmentView
struct GymEquipmentView: View {
    @StateObject private var viewModel = GymEquipmentViewModel()
    @ObservedObject var progressViewModel: ProgressViewModel
    @Environment(\.presentationMode) var presentationMode
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
                    equipmentOptionsSection
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
private extension GymEquipmentView {
    var progressSection: some View {
        VStack(spacing: 5) {
            ProgressBarWithIcons(progressViewModel: progressViewModel)
        }
        .padding(.top, 10)
    }
    
    var headerSection: some View {
        VStack(spacing: 20) {
            // Animated equipment icon
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
                
                Image(systemName: "house.circle.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.yellow)
                    .scaleEffect(viewModel.selectedIndex != nil ? 1.1 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: viewModel.selectedIndex)
            }
            
            VStack(spacing: 12) {
                Text("What equipment do you have at home?")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.yellow)
                    .multilineTextAlignment(.center)
                
                Text("We'll customize your workouts accordingly")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.top, 15)
    }
    
    var equipmentOptionsSection: some View {
        VStack(spacing: 20) {
            HStack {
                Text("Choose Your Setup")
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
                ForEach(viewModel.homeEquipmentOptions, id: \.id) { option in
                    EpicEquipmentCard(
                        option: option,
                        isSelected: viewModel.selectedIndex == option.id
                    ) {
                        viewModel.selectOption(option.id)
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
        
        // Save additional info for dashboard
        let selectedEquipment = viewModel.homeEquipmentOptions[selectedIndex]
        UserDefaults.standard.set(selectedEquipment.title, forKey: "selectedEquipmentType")
        UserDefaults.standard.set(selectedIndex, forKey: "selectedEquipmentIndex")
        
        print("🎯 Guardado para dashboard - Equipamiento: \(selectedEquipment.title), Índice: \(selectedIndex)")
        
        // Disable button temporarily
        viewModel.disableNextButtonTemporarily()
        
        // Advance progress
        withAnimation(.easeInOut(duration: 0.5)) {
            progressViewModel.advanceProgress()
        }
        
        // Navigate to ShowInfoView to display user selections
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            navigateToShowInfo = true
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

// MARK: - Epic Equipment Card
struct EpicEquipmentCard: View {
    let option: HomeEquipmentOption
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 0) {
                // Main card content
                HStack(spacing: 16) {
                    // Equipment icon
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        option.color.opacity(isSelected ? 0.4 : 0.2),
                                        option.color.opacity(isSelected ? 0.1 : 0.05)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 70, height: 70)
                        
                        Image(systemName: option.icon)
                            .font(.system(size: 28, weight: .semibold))
                            .foregroundColor(option.color)
                    }
                    
                    // Equipment info
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(option.title)
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(.white)
                                
                                Text(option.subtitle)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(option.color)
                            }
                            
                            Spacer()
                            
                            // Selection indicator
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
                        
                        // Equipment details
                        HStack(spacing: 12) {
                            EquipmentStat(icon: "wrench.and.screwdriver", text: option.equipment, color: option.color)
                            EquipmentStat(icon: "chart.line.uptrend.xyaxis", text: option.difficulty, color: option.color)
                        }
                        
                        Text(option.description)
                            .font(.system(size: 13))
                            .foregroundColor(.white.opacity(0.7))
                            .lineLimit(isSelected ? nil : 2)
                    }
                }
                .padding(20)
                
                // Expandable sections (only when selected)
                if isSelected {
                    VStack(spacing: 12) {
                        Divider()
                            .background(option.color.opacity(0.4))
                        
                        // Advantages section
                        VStack(spacing: 8) {
                            HStack {
                                Text("Advantages:")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(option.color)
                                Spacer()
                            }
                            
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), alignment: .leading), count: 2), spacing: 6) {
                                ForEach(option.advantages, id: \.self) { advantage in
                                    HStack(spacing: 6) {
                                        Image(systemName: "checkmark.circle.fill")
                                            .font(.system(size: 10))
                                            .foregroundColor(option.color)
                                        
                                        Text(advantage)
                                            .font(.system(size: 12))
                                            .foregroundColor(.white.opacity(0.8))
                                        
                                        Spacer()
                                    }
                                }
                            }
                        }
                        
                        // Workout types section
                        VStack(spacing: 8) {
                            HStack {
                                Text("Workout types:")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(option.color)
                                Spacer()
                            }
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(option.workoutTypes, id: \.self) { workoutType in
                                        Text(workoutType)
                                            .font(.system(size: 11, weight: .medium))
                                            .foregroundColor(option.color)
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 4)
                                            .background(option.color.opacity(0.2))
                                            .cornerRadius(8)
                                    }
                                }
                                .padding(.horizontal, 20)
                            }
                        }
                        .padding(.bottom, 16)
                    }
                    .padding(.horizontal, 20)
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.gray.opacity(isSelected ? 0.15 : 0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                isSelected ? option.color.opacity(0.6) : Color.gray.opacity(0.3),
                                lineWidth: isSelected ? 2 : 1
                            )
                    )
            )
            .scaleEffect(isSelected ? 1.02 : 1.0)
            .shadow(
                color: isSelected ? option.color.opacity(0.3) : Color.clear,
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
struct EquipmentStat: View {
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
struct GymEquipmentView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            GymEquipmentView(progressViewModel: ProgressViewModel())
        }
        .preferredColorScheme(.dark)
    }
}
