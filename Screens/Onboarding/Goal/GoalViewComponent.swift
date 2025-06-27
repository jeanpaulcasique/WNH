import SwiftUI

// MARK: - Enhanced Goal Option Card
struct EnhancedGoalOptionCard: View {
    let goal: Goal
    let imageName: String
    let isSelected: Bool
    let action: () -> Void
    
    var goalInfo: (color: Color, icon: String, description: String, benefits: [String]) {
        switch goal {
        case .loseWeight:
            return (.red, "flame.fill", "Focus on burning calories and fat loss", [
                "High-intensity cardio workouts",
                "Calorie tracking and nutrition guidance",
                "Fat-burning exercise routines"
            ])
        case .buildMuscle:
            return (.blue, "dumbbell.fill", "Build strength and increase muscle mass", [
                "Progressive strength training",
                "Muscle-building nutrition plans",
                "Recovery and growth optimization"
            ])
        case .keepFit:
            return (.green, "heart.fill", "Maintain fitness and overall health", [
                "Balanced cardio and strength mix",
                "Flexibility and mobility focus",
                "Sustainable healthy habits"
            ])
        }
    }
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 0) {
                // Main card content
                HStack(spacing: 16) {
                    // Goal icon with image fallback
                    ZStack {
                        // Background circle
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        goalInfo.color.opacity(isSelected ? 0.3 : 0.2),
                                        goalInfo.color.opacity(isSelected ? 0.1 : 0.05)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 70, height: 70)
                        
                        // Icon
                        Image(systemName: goalInfo.icon)
                            .font(.system(size: 30))
                            .foregroundColor(goalInfo.color)
                    }
                    
                    // Goal info
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(goal.rawValue)
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.appWhite)
                            
                            Spacer()
                            
                            // Selection indicator
                            if isSelected {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(.green)
                            } else {
                                Image(systemName: "circle")
                                    .font(.system(size: 20))
                                    .foregroundColor(.appWhite.opacity(0.3))
                            }
                        }
                        
                        Text(goalInfo.description)
                            .font(.system(size: 14))
                            .foregroundColor(.appWhite.opacity(0.7))
                            .lineLimit(2)
                    }
                }
                .padding(20)
                
                // Expandable benefits section (only when selected)
                if isSelected {
                    VStack(spacing: 12) {
                        Divider()
                            .background(goalInfo.color.opacity(0.3))
                        
                        VStack(spacing: 8) {
                            HStack {
                                Text("What you'll get:")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(goalInfo.color)
                                Spacer()
                            }
                            
                            ForEach(goalInfo.benefits, id: \.self) { benefit in
                                HStack(spacing: 8) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 12))
                                        .foregroundColor(goalInfo.color)
                                    
                                    Text(benefit)
                                        .font(.system(size: 13))
                                        .foregroundColor(.appWhite.opacity(0.8))
                                    
                                    Spacer()
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
                                isSelected ? goalInfo.color.opacity(0.6) : Color.gray.opacity(0.3),
                                lineWidth: isSelected ? 2 : 1
                            )
                    )
            )
            .scaleEffect(isSelected ? 1.02 : 1.0)
            .shadow(
                color: isSelected ? goalInfo.color.opacity(0.3) : Color.clear,
                radius: isSelected ? 12 : 0,
                x: 0,
                y: 6
            )
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Goal Selection Success View
struct GoalSelectionSuccessView: View {
    var body: some View {
        VStack {
            Spacer()
            
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                
                Text("Goal selected!")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.appWhite)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(Color.gray.opacity(0.9))
            .cornerRadius(25)
            .padding(.bottom, 60)
        }
    }
}
