import SwiftUI

// MARK: - GymEquipmentView
struct GymEquipmentView: View {
    @StateObject private var viewModel = GymEquipmentViewModel()
    
    @Environment(\.presentationMode) var presentationMode
    @State private var navigateToShowInfo = false
    @State private var navigateToPreviousView = false

    var body: some View {
        ZStack {
            // Simple white background
            Color.white.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Logo arriba
                Image("samsonWhite")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 170)
                    .padding(.top, 5)
                    .padding(.bottom, -10)
                    .opacity(1.0)
                
                // Card con título y subtítulo
                VStack(spacing: 8) {
                    Text("WHAT EQUIPMENT DO YOU HAVE AT HOME?")
                        .font(.system(size: 26, weight: .black, design: .default))
                        .foregroundColor(.black)
                        .multilineTextAlignment(.center)
                       
                    Text("We'll customize your workouts accordingly")
                        .font(.system(size: 17, weight: .medium))
                        .foregroundColor(.black.opacity(0.9))
                        .multilineTextAlignment(.center)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.horizontal, 8)
                        .cascadingAppear(index: 1)
                }
                .padding(.vertical, 16)
                .padding(.horizontal, 18)
                .background(Color.yellow.opacity(0.9))
                .cornerRadius(24)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.black, lineWidth: 4)
                )
                .padding(.horizontal, 24)
                .padding(.bottom, 25)
                
                // Equipment options section
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(viewModel.homeEquipmentOptions, id: \.id) { option in
                            EquipmentCard(
                                option: option,
                                isSelected: viewModel.selectedIndex == option.id
                            ) {
                                viewModel.selectOption(option.id)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .padding(.bottom, 120)
                }
                
                Spacer()
            }
            
            // Botones flotantes
            VStack {
                Spacer()
                
                HStack {
                    // Botón Back
                    Button(action: {
                        navigateToPreviousView = true
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.white)
                            .frame(width: 48, height: 48)
                            .background(Color(white: 0.18))
                            .clipShape(Circle())
                    }
                    
                    Spacer()
                    
                    // Botón Next - solo mostrar cuando hay selección
                    if viewModel.selectedIndex != nil {
                        Button(action: {
                            proceedToNext()
                        }) {
                            HStack(spacing: 8) {
                                Text("Next")
                                    .font(.system(size: 18, weight: .semibold, design: .default))
                                    .foregroundColor(.black)
                                Image(systemName: "arrow.right")
                                    .font(.system(size: 16, weight: .semibold, design: .default))
                                    .foregroundColor(.black)
                            }
                            .padding(.horizontal, 32)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 30)
                                    .fill(Color.yellow.opacity(0.9))
                                    .shadow(color: Color.yellow.opacity(0.4), radius: 10, x: 0, y: 4)
                            )
                        }
                        .scaleEffect(1.0)
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .bottom).combined(with: .opacity)
                        ))
                    }
                    
                    NavigationLink(
                        destination: ShowInfoView(),
                        isActive: $navigateToShowInfo
                    ) {
                        EmptyView()
                    }
                    .hidden()
                    
                    NavigationLink(
                        destination: WhichPlaceView(),
                        isActive: $navigateToPreviousView
                    ) {
                        EmptyView()
                    }
                    .hidden()
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: viewModel.selectedIndex != nil)
            }
        }
        .navigationBarHidden(true)
    }
    
    private func proceedToNext() {
        guard let selectedIndex = viewModel.selectedIndex else { return }
        
        // Enhanced haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
        
        // Save additional info for dashboard
        let selectedEquipment = viewModel.homeEquipmentOptions[selectedIndex]
        UserDefaults.standard.set(selectedEquipment.title, forKey: "selectedEquipmentType")
        UserDefaults.standard.set(selectedIndex, forKey: "selectedEquipmentIndex")
        
        print("🎯 Guardado para dashboard - Equipamiento: \(selectedEquipment.title), Índice: \(selectedIndex)")
        
        // Navigate to ShowInfoView to display user selections
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            navigateToShowInfo = true
        }
    }
}

// MARK: - Equipment Card
struct EquipmentCard: View {
    let option: HomeEquipmentOption
    let isSelected: Bool
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 0) {
                ZStack {
                    cardContent
                        .background(cardBackground)
                }
                
                if isSelected {
                    expandedContent
                        .transition(.asymmetric(
                            insertion: .opacity.combined(with: .move(edge: .top)),
                            removal: .opacity
                        ))
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.black, lineWidth: 4)
                    .shadow(color: isSelected ? Color.yellow.opacity(0.5) : Color.clear, radius: 8)
            )
            .scaleEffect(isPressed ? 0.98 : 1.0)
            .shadow(
                color: isSelected ? Color.yellow.opacity(0.25) : Color.black.opacity(0.1),
                radius: isSelected ? 15 : 5,
                x: 0,
                y: isSelected ? 8 : 2
            )
            .animation(.spring(response: 0.4, dampingFraction: 0.7), value: isSelected)
            .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
    }
    
    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(
                LinearGradient(
                    colors: [
                        Color.yellow,
                        Color.yellow.opacity(0.9)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.black, lineWidth: 4)
            )
    }
    
    private var cardContent: some View {
        HStack(spacing: 16) {
            // Equipment icon
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.white.opacity(0.9),
                                Color.white.opacity(0.7)
                            ],
                            center: .topLeading,
                            startRadius: 0,
                            endRadius: 50
                        )
                    )
                    .frame(width: 60, height: 60)
                    .scaleEffect(isSelected ? 1.1 : 1.0)
                    .animation(.spring(response: 0.5, dampingFraction: 0.8), value: isSelected)
                
                Image(systemName: option.icon)
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(.black)
                    .scaleEffect(isSelected ? 1.2 : 1.0)
                    .animation(.spring(response: 0.6, dampingFraction: 0.7), value: isSelected)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(option.title)
                            .font(.system(size: 18, weight: .bold, design: .default))
                            .foregroundColor(.black)
                        
                        Text(option.subtitle)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.black.opacity(0.7))
                    }
                    
                    Spacer()
                    
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.green)
                    }
                }
                
                // Equipment details
                HStack(spacing: 12) {
                    EquipmentStat(icon: "wrench.and.screwdriver", text: option.equipment)
                    EquipmentStat(icon: "chart.line.uptrend.xyaxis", text: option.difficulty)
                }
                
                Text(option.description)
                    .font(.system(size: 13))
                    .foregroundColor(.black.opacity(0.8))
                    .lineLimit(isSelected ? nil : 2)
            }
            
            Spacer()
        }
        .padding(16)
    }
    
    private var expandedContent: some View {
        VStack(spacing: 16) {
            Divider()
                .background(Color.black.opacity(0.3))
                .padding(.horizontal, 16)
            
            VStack(spacing: 16) {
                // Advantages section
                VStack(spacing: 8) {
                    HStack {
                        Text("Advantages:")
                            .font(.system(size: 14, weight: .bold, design: .default))
                            .foregroundColor(.black)
                        Spacer()
                    }
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), alignment: .leading), count: 1), spacing: 6) {
                        ForEach(option.advantages, id: \.self) { advantage in
                            HStack(spacing: 6) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 10))
                                    .foregroundColor(.black.opacity(0.7))
                                
                                Text(advantage)
                                    .font(.system(size: 12, weight: .medium, design: .default))
                                    .foregroundColor(.black.opacity(0.8))
                                
                                Spacer()
                            }
                        }
                    }
                }
                
                // Workout types section
                VStack(spacing: 8) {
                    HStack {
                        Text("Workout types:")
                            .font(.system(size: 14, weight: .bold, design: .default))
                            .foregroundColor(.black)
                        Spacer()
                    }
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(option.workoutTypes, id: \.self) { workoutType in
                                Text(workoutType)
                                    .font(.system(size: 11, weight: .medium, design: .default))
                                    .foregroundColor(.black)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.black.opacity(0.1))
                                    .cornerRadius(8)
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
    }
}

// MARK: - Support Components
struct EquipmentStat: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 10))
                .foregroundColor(.black.opacity(0.7))
            
            Text(text)
                .font(.system(size: 11, weight: .medium, design: .default))
                .foregroundColor(.black.opacity(0.8))
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.black.opacity(0.1))
        .cornerRadius(8)
    }
}

// MARK: - Preview
struct GymEquipmentView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            GymEquipmentView()
        }
        .preferredColorScheme(.light)
    }
}
