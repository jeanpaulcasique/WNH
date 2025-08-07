import SwiftUI

struct FoodScanResultsView: View {
    let detectedFoods: [DetectedFood]
    let totalCalories: Int
    @Environment(\.dismiss) private var dismiss
    @State private var showConfetti = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [Color.appBlack, Color.gray.opacity(0.3), Color.appBlack],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // Header
                        VStack(spacing: 16) {
                            HStack(spacing: 12) {
                                Image(systemName: "sparkles")
                                    .font(.system(size: 32, weight: .bold))
                                    .foregroundColor(.appYellow)
                                
                                Text("Analysis Results")
                                    .font(.system(size: 32, weight: .bold))
                                    .foregroundColor(.white)
                            }
                            
                            Text("Here's what we found in your food")
                                .font(.system(size: 16))
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 20)
                        }
                        .padding(.top, 20)
                        
                        // Total calories card
                        VStack(spacing: 12) {
                            Text("Total Estimated Calories")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.appWhite)
                            
                            Text("\(totalCalories)")
                                .font(.system(size: 48, weight: .bold))
                                .foregroundColor(.appYellow)
                            
                            Text("kcal")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 24)
                        .background(.ultraThinMaterial)
                        .cornerRadius(16)
                        .padding(.horizontal, 20)
                        
                        // Detected foods list
                        if !detectedFoods.isEmpty {
                            VStack(spacing: 16) {
                                HStack {
                                    Text("Detected Foods")
                                        .font(.system(size: 20, weight: .semibold))
                                        .foregroundColor(.appYellow)
                                    Spacer()
                                }
                                .padding(.horizontal, 20)
                                
                                LazyVStack(spacing: 12) {
                                    ForEach(detectedFoods) { food in
                                        DetectedFoodCard(food: food)
                                    }
                                }
                                .padding(.horizontal, 20)
                            }
                        } else {
                            // No foods detected
                            VStack(spacing: 16) {
                                Image(systemName: "questionmark.circle")
                                    .font(.system(size: 60))
                                    .foregroundColor(.gray)
                                
                                Text("No foods detected")
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(.gray)
                                
                                Text("Try taking a clearer photo of your food")
                                    .font(.system(size: 14))
                                    .foregroundColor(.gray.opacity(0.8))
                                    .multilineTextAlignment(.center)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 40)
                            .background(.ultraThinMaterial)
                            .cornerRadius(16)
                            .padding(.horizontal, 20)
                        }
                        
                        // Disclaimer
                        VStack(spacing: 8) {
                            Text("⚠️ Disclaimer")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.orange)
                            
                            Text("These are approximate calorie estimates based on AI analysis. Actual calories may vary depending on portion size, preparation method, and ingredients.")
                                .font(.system(size: 12))
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                                .lineLimit(nil)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 10)
                        
                        Spacer(minLength: 50)
                    }
                }
            }
            .navigationBarHidden(true)
            .overlay(
                // Close button
                VStack {
                    HStack {
                        Button(action: {
                            dismiss()
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 32))
                                .foregroundColor(.gray)
                        }
                        .padding(.leading, 20)
                        .padding(.top, 20)
                        
                        Spacer()
                    }
                    Spacer()
                }
            )
        }
    }
}

// MARK: - Detected Food Card
struct DetectedFoodCard: View {
    let food: DetectedFood
    
    var body: some View {
        HStack(spacing: 16) {
            // Food icon
            ZStack {
                Circle()
                    .fill(Color.appYellow.opacity(0.2))
                    .frame(width: 50, height: 50)
                
                Image(systemName: "fork.knife")
                    .font(.system(size: 20))
                    .foregroundColor(.appYellow)
            }
            
            // Food info
            VStack(alignment: .leading, spacing: 4) {
                Text(food.name)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.appWhite)
                
                Text("Confidence: \(Int(food.confidence * 100))%")
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            // Calories
            VStack(alignment: .trailing, spacing: 2) {
                Text("\(food.calories)")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.appYellow)
                
                Text("kcal")
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(.ultraThinMaterial)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
    }
} 