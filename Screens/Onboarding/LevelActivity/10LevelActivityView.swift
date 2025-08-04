import SwiftUI
import Combine

// MARK: - LevelActivityView
struct LevelActivityView: View {
    @StateObject private var viewModel = LevelActivityViewModel()
    
    @State private var navigateToNextView = false
    @State private var navigateToPreviousView = false
    @Environment(\.presentationMode) var presentationMode
    @State private var animateIn = false

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
                    Text("WHAT'S YOUR ACTIVITY LEVEL?")
                        .font(.system(size: 26, weight: .black, design: .default))
                        .foregroundColor(.black)
                        .multilineTextAlignment(.center)
                       
                    Text("This helps us calculate your daily calorie needs")
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
                .background(Color.yellow)
                .cornerRadius(24)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.black, lineWidth: 3)
                )
                .padding(.horizontal, 24)
                .padding(.bottom, 20)
                
                Spacer()
                
                // Contenido principal - activity cards
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        // Header section
                        HStack {
                            Text("Select Your Activity Level")
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
                        
                        // Activity cards section
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
                    .padding(.horizontal, 20)
                    .padding(.bottom, 100) // Padding para que no se superponga con los botones flotantes
                    .onChange(of: viewModel.selectedLevel) { newLevel in
                        // Haptic feedback when selection changes
                        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                        impactFeedback.impactOccurred()
                    }
                }
                
                Spacer()
            }
            
            // Botones flotantes
            VStack {
                Spacer()
                
                HStack {
                    // Botón Back
                    Button(action: {
                        goBack()
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
                        destination: WhichPlaceView(),
                        isActive: $navigateToNextView
                    ) {
                        EmptyView()
                    }
                    .hidden()
                    
                    NavigationLink(
                        destination: WorkoutLevelView(),
                        isActive: $navigateToPreviousView
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
        
        // Save user selection to UserDefaults
        let selectedActivity = viewModel.activityLevels[viewModel.selectedLevel].title
        UserDefaults.standard.set(selectedActivity, forKey: "userSelectedActivityLevel")
        UserDefaults.standard.set(viewModel.selectedLevel, forKey: "userSelectedActivityLevelId")
        
        // Save timestamp for when user completed this step
        UserDefaults.standard.set(Date(), forKey: "activityLevelCompletedAt")
        
        // Print saved data for debugging (optional)
        let selectedActivityData = viewModel.activityLevels[viewModel.selectedLevel]
        print("💾 Saved Activity Level:")
        print("   Level: \(selectedActivityData.title)")
        print("   Calorie Multiplier: \(selectedActivityData.calorieMultiplier)")
        
        // Navigate after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            navigateToNextView = true
        }
    }
    
    func goBack() {
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
        
        withAnimation(.easeInOut(duration: 0.3)) {
            
        }
        // Navigate to WorkoutLevelView instead of dismissing
        navigateToPreviousView = true
    }
    
    // MARK: - UserDefaults Helper Functions
    static func getUserActivityLevel() -> (level: String, id: Int)? {
        guard let levelTitle = UserDefaults.standard.string(forKey: "userSelectedActivityLevel"),
              let levelId = UserDefaults.standard.object(forKey: "userSelectedActivityLevelId") as? Int else {
            return nil
        }
        return (level: levelTitle, id: levelId)
    }
    
    static func hasCompletedActivityLevel() -> Bool {
        return UserDefaults.standard.object(forKey: "activityLevelCompletedAt") != nil
    }
    
    static func clearActivityLevelData() {
        UserDefaults.standard.removeObject(forKey: "userSelectedActivityLevel")
        UserDefaults.standard.removeObject(forKey: "userSelectedActivityLevelId")
        UserDefaults.standard.removeObject(forKey: "activityLevelCompletedAt")
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
                            .foregroundColor(.black)
                        
                        Spacer()
                        
                        Text(level.calorieMultiplier)
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(isSelected ? level.color : .black.opacity(0.6))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(isSelected ? level.color.opacity(0.1) : Color.gray.opacity(0.1))
                            .cornerRadius(8)
                    }
                    
                    Text(level.subtitle)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(level.color)
                    
                    Text(level.description)
                        .font(.system(size: 12))
                        .foregroundColor(.black.opacity(0.6))
                        .lineLimit(2)
                }
                
                // Selection indicator
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.green)
                } else {
                    Image(systemName: "circle")
                        .font(.system(size: 20))
                        .foregroundColor(.gray.opacity(0.3))
                }
            }
            .padding(20)
            .background(Color.white)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? level.color.opacity(0.8) : Color.gray.opacity(0.3), lineWidth: isSelected ? 2 : 1)
            )
            .shadow(color: isSelected ? level.color.opacity(0.2) : Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
            .scaleEffect(isSelected ? 1.02 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
}

// MARK: - Preview
struct LevelActivityView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            LevelActivityView()
        }
        .preferredColorScheme(.light)
    }
}
