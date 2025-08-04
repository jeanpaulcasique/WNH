import SwiftUI
import UIKit

// MARK: - WhichPlaceView
struct WhichPlaceView: View {
    @StateObject private var viewModel = WhichPlaceViewModel()
    
    @Environment(\.presentationMode) var presentationMode
    @State private var navigateToNextView = false
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
                    Text("WHERE DO YOU PREFER TO WORKOUT?")
                        .font(.system(size: 26, weight: .black, design: .default))
                        .foregroundColor(.black)
                        .multilineTextAlignment(.center)
                       
                    Text("Choose your ideal training environment")
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
                
                // Locations section
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(viewModel.workoutLocations, id: \.id) { location in
                            LocationCard(
                                location: location,
                                isSelected: viewModel.selectedIndex == location.id
                            ) {
                                viewModel.selectLocation(at: location.id)
                            }
                        }
                    }
                    .padding(.vertical, 10)
                    .padding(.horizontal, 20)
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
                        destination: GymEquipmentView(),
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
                    
                    NavigationLink(
                        destination: LevelActivityView(),
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
        
        // Guardar información adicional para el dashboard
        let selectedLocation = viewModel.workoutLocations[selectedIndex]
        UserDefaults.standard.set(selectedLocation.title, forKey: "selectedWorkoutLocation")
        UserDefaults.standard.set(selectedIndex, forKey: "workoutLocationIndex")
        
        print("🎯 Guardado para dashboard - Ubicación: \(selectedLocation.title), Índice: \(selectedIndex)")
        
        // Navigate based on selection
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            if selectedIndex == 0 || selectedIndex == 2 {  // At Home o Al aire libre
                navigateToNextView = true
            } else if selectedIndex == 1 {  // At the Gym
                navigateToShowInfo = true
            }
        }
    }
}

// MARK: - Location Card
struct LocationCard: View {
    let location: WorkoutLocationModel
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
            // Location icon
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
                
                Image(systemName: location.icon)
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(.black)
                    .scaleEffect(isSelected ? 1.2 : 1.0)
                    .animation(.spring(response: 0.6, dampingFraction: 0.7), value: isSelected)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(location.title)
                            .font(.system(size: 18, weight: .bold, design: .default))
                            .foregroundColor(.black)
                        
                        Text(location.subtitle)
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
                
                Text(location.description)
                    .font(.system(size: 13))
                    .foregroundColor(.black.opacity(0.8))
                    .lineLimit(2)
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
                // Features section
                VStack(alignment: .leading, spacing: 8) {
                    Text("What you'll get:")
                        .font(.system(size: 14, weight: .bold, design: .default))
                        .foregroundColor(.black)
                    
                    ForEach(location.features, id: \.self) { feature in
                        HStack(spacing: 8) {
                            Image(systemName: feature.icon)
                                .font(.system(size: 12))
                                .foregroundColor(.black.opacity(0.7))
                            Text(feature.text)
                                .font(.system(size: 13, weight: .medium, design: .default))
                                .foregroundColor(.black.opacity(0.8))
                            Spacer()
                        }
                    }
                }
                
                // Equipment & Convenience Section
                HStack {
                    VStack(alignment: .leading) {
                        Text("Equipment")
                            .font(.system(size: 12, weight: .bold, design: .default))
                            .foregroundColor(.black.opacity(0.6))
                        Text(location.equipment)
                            .font(.system(size: 12, weight: .medium, design: .default))
                            .foregroundColor(.black.opacity(0.8))
                    }
                    Spacer()
                    VStack(alignment: .trailing) {
                        Text("Convenience")
                            .font(.system(size: 12, weight: .bold, design: .default))
                            .foregroundColor(.black.opacity(0.6))
                        Text(location.convenience)
                            .font(.system(size: 12, weight: .medium, design: .default))
                            .foregroundColor(.black.opacity(0.8))
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
    }
}

// MARK: - Preview
struct WhichPlaceView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            WhichPlaceView()
        }
        .preferredColorScheme(.light)
    }
}
