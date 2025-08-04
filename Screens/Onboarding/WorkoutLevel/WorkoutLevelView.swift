import SwiftUI
import Combine

// MARK: - WorkoutLevelView
struct WorkoutLevelView: View {
    @StateObject private var viewModel = WorkoutLevelViewModel()
    
    @Environment(\.presentationMode) var presentationMode
    @State private var navigateToNextScreen = false
    @State private var navigateToPreviousScreen = false

    var body: some View {
        ZStack {
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
                    Text("CHOOSE YOUR WORKOUT LEVEL")
                        .font(.system(size: 26, weight: .black, design: .default))
                        .foregroundColor(.black)
                        .multilineTextAlignment(.center)
                       
                    Text("We'll personalize your training intensity")
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
                        .stroke(Color.black, lineWidth: 3)
                )
                .padding(.horizontal, 24)
                .padding(.bottom, 100)
                
              
                
                // CONTENIDO COMENTADO - VAMOS A CONSTRUIR PASO A PASO
                /*
                // Contenido principal - niveles de actividad física
                VStack(spacing: 0) {
                    // Header section
                    HStack {
                        Text("Select Your Level")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.black)
                        
                        Spacer()
                        
                        Text("Tap to see details")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.black.opacity(0.6))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(8)
                    }
                    .padding(.bottom, 20)
                    
                    // Levels section
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
                .padding(.horizontal, 20)
                .onChange(of: viewModel.selectedIndex) { newIndex in
                    // Haptic feedback when selection changes
                    if newIndex != nil {
                        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                        impactFeedback.impactOccurred()
                    }
                }
                */
                
                // Cards sencillas para intensidad y frecuencia
                VStack(spacing: 20) {
                    // Card de intensidad
                    VStack(spacing: 12) {
                        HStack {
                            Image(systemName: "flame.fill")
                                .font(.system(size: 20))
                                .foregroundColor(.orange)
                            Text("Training Intensity")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.black)
                            Spacer()
                        }
                        
                        HStack(spacing: 12) {
                            IntensityButton(title: "Low", isSelected: viewModel.selectedIntensity == "Low") {
                                viewModel.selectedIntensity = "Low"
                            }
                            IntensityButton(title: "Medium", isSelected: viewModel.selectedIntensity == "Medium") {
                                viewModel.selectedIntensity = "Medium"
                            }
                            IntensityButton(title: "High", isSelected: viewModel.selectedIntensity == "High") {
                                viewModel.selectedIntensity = "High"
                            }
                        }
                    }
                    .padding(20)
                    .background(Color.white)
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                    .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                    
                    // Card de frecuencia
                    VStack(spacing: 12) {
                        HStack {
                            Image(systemName: "calendar")
                                .font(.system(size: 20))
                                .foregroundColor(.blue)
                            Text("Training Frequency")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.black)
                            Spacer()
                        }
                        
                        HStack(spacing: 12) {
                            FrequencyButton(title: "2-3", subtitle: "days/week", isSelected: viewModel.selectedFrequency == "2-3") {
                                viewModel.selectedFrequency = "2-3"
                            }
                            FrequencyButton(title: "4-5", subtitle: "days/week", isSelected: viewModel.selectedFrequency == "4-5") {
                                viewModel.selectedFrequency = "4-5"
                            }
                            FrequencyButton(title: "6-7", subtitle: "days/week", isSelected: viewModel.selectedFrequency == "6-7") {
                                viewModel.selectedFrequency = "6-7"
                            }
                        }
                    }
                    .padding(20)
                    .background(Color.white)
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                    .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                }
                .padding(.horizontal, 20)
                
                Spacer()
            }
            
            // Botones flotantes
            VStack {
                Spacer()
                
                HStack {
                    // Botón Back
                    Button(action: {
                        navigateToPreviousScreen = true
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.white)
                            .frame(width: 48, height: 48)
                            .background(Color(white: 0.18))
                            .clipShape(Circle())
                    }
                    
                    Spacer()
                    
                    // Botón Next
                    Button(action: {
                        proceedToNext()
                    }) {
                        HStack(spacing: 8) {
                            Text("Next")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.black)
                            Image(systemName: "arrow.right")
                                .font(.system(size: 16, weight: .semibold))
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
                    
                    NavigationLink(
                        destination: LevelActivityView(),
                        isActive: $navigateToNextScreen
                    ) {
                        EmptyView()
                    }
                    .hidden()
                    
                    NavigationLink(
                        destination: DietTypeView(),
                        isActive: $navigateToPreviousScreen
                    ) {
                        EmptyView()
                    }
                    .hidden()
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
            }
        }
        .navigationBarBackButtonHidden(true)
    }
    
    func proceedToNext() {
        // Haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
        
        // Save all user selections to UserDefaults
        UserDefaults.standard.set(viewModel.selectedIntensity, forKey: "userSelectedIntensity")
        UserDefaults.standard.set(viewModel.selectedFrequency, forKey: "userSelectedFrequency")
        
        // Save workout level if selected
        if let selectedIndex = viewModel.selectedIndex {
            let selectedLevel = viewModel.workoutLevels[selectedIndex].title
            UserDefaults.standard.set(selectedLevel, forKey: "selectedWorkoutLevel")
        }
        
        // Save timestamp for when user completed this step
        UserDefaults.standard.set(Date(), forKey: "workoutLevelCompletedAt")
        
        // Print saved data for debugging (optional)
        print("💾 Saved Workout Preferences:")
        print("   Intensity: \(viewModel.selectedIntensity)")
        print("   Frequency: \(viewModel.selectedFrequency)")
        if let selectedIndex = viewModel.selectedIndex {
            print("   Level: \(viewModel.workoutLevels[selectedIndex].title)")
        }
        
        // Navigate after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            navigateToNextScreen = true
        }
    }
    
    // MARK: - UserDefaults Helper Functions
    static func getUserWorkoutPreferences() -> (intensity: String, frequency: String, level: String?) {
        let intensity = UserDefaults.standard.string(forKey: "userSelectedIntensity") ?? "Medium"
        let frequency = UserDefaults.standard.string(forKey: "userSelectedFrequency") ?? "4-5"
        let level = UserDefaults.standard.string(forKey: "selectedWorkoutLevel")
        
        return (intensity: intensity, frequency: frequency, level: level)
    }
    
    static func hasCompletedWorkoutLevel() -> Bool {
        return UserDefaults.standard.object(forKey: "workoutLevelCompletedAt") != nil
    }
    
    static func clearWorkoutLevelData() {
        UserDefaults.standard.removeObject(forKey: "userSelectedIntensity")
        UserDefaults.standard.removeObject(forKey: "userSelectedFrequency")
        UserDefaults.standard.removeObject(forKey: "selectedWorkoutLevel")
        UserDefaults.standard.removeObject(forKey: "workoutLevelCompletedAt")
    }
}

// MARK: - Intensity Button
struct IntensityButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(isSelected ? .white : .black)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(isSelected ? Color.orange : Color.gray.opacity(0.1))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isSelected ? Color.orange : Color.gray.opacity(0.3), lineWidth: 1)
                )
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
}

// MARK: - Frequency Button
struct FrequencyButton: View {
    let title: String
    let subtitle: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 2) {
                Text(title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(isSelected ? .white : .black)
                Text(subtitle)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(isSelected ? .white.opacity(0.8) : .black.opacity(0.6))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.blue : Color.gray.opacity(0.1))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.blue : Color.gray.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
}

// MARK: - Enhanced Level Card (COMENTADO)
/*
struct EnhancedLevelCard: View {
    let level: WorkoutLevelModel
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 0) {
                mainCardContent
                if isSelected {
                    expandableBenefitsSection
                        .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                isSelected ? level.color.opacity(0.8) : Color.gray.opacity(0.3),
                                lineWidth: isSelected ? 2 : 1
                            )
                    )
                    .shadow(
                        color: isSelected ? level.color.opacity(0.2) : Color.black.opacity(0.1),
                        radius: isSelected ? 8 : 4,
                        x: 0,
                        y: 2
                    )
            )
            .scaleEffect(isSelected ? 1.02 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    @ViewBuilder
    private var mainCardContent: some View {
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
                    HStack(spacing: 2) {
                        ForEach(0..<3) { index in
                            Circle()
                                .fill(index <= level.id ? level.color : level.color.opacity(0.3))
                                .frame(width: 4, height: 4)
                        }
                    }
                }
            }
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(level.title)
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.black)
                        Text(level.subtitle)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(level.color)
                    }
                    Spacer()
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 22))
                            .foregroundColor(.green)
                    } else {
                        Image(systemName: "circle")
                            .font(.system(size: 22))
                            .foregroundColor(.gray.opacity(0.3))
                    }
                }
                HStack(spacing: 20) {
                    StatPill(title: level.duration, subtitle: "Duration")
                    StatPill(title: level.frequency, subtitle: "Frequency")
                }
                Text(level.description)
                    .font(.system(size: 13))
                    .foregroundColor(.black.opacity(0.7))
                    .lineLimit(2)
            }
        }
        .padding(20)
    }
    
    @ViewBuilder
    private var expandableBenefitsSection: some View {
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
                                .foregroundColor(.black.opacity(0.8))
                            Spacer()
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 16)
        }
    }
}
*/

// MARK: - Preview
struct WorkoutLevelView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            WorkoutLevelView()
        }
        .preferredColorScheme(.light)
    }
}
