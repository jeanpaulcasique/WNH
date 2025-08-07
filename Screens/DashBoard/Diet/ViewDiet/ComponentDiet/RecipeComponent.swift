import SwiftUI

// MARK: - StyledRecipeCard
struct StyledRecipeCard: View {
    let recipe: Recipe

    var body: some View {
        HStack(spacing: 16) {
            // Recipe image
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        LinearGradient(
                            colors: [Color.appYellow.opacity(0.3), Color.appYellow.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 60, height: 60)
                
                Image(systemName: mealIcon(for: recipe.mealType))
                    .font(.system(size: 24))
                    .foregroundColor(.appYellow)
            }
            
            // Recipe info
            VStack(alignment: .leading, spacing: 4) {
                Text(recipe.title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.appWhite)
                    .lineLimit(2)
                
                HStack(spacing: 8) {
                    Text(recipe.mealType.displayName)
                        .font(.system(size: 12))
                        .foregroundColor(.appWhite.opacity(0.6))
                    
                    Spacer()
                    
                    HStack(spacing: 4) {
                        Image(systemName: "flame.fill")
                            .font(.system(size: 10))
                            .foregroundColor(.orange)
                        
                        Text("\(recipe.calories) kcal")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.appYellow)
                    }
                }
            }
            
            // Arrow indicator
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.appWhite.opacity(0.4))
        }
        .padding(16)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
    }
    
    private func mealIcon(for mealType: MealType) -> String {
        switch mealType {
        case .Breakfast:
            return "sun.rise.fill"
        case .Lunch:
            return "sun.max.fill"
        case .Dinner:
            return "moon.stars.fill"
        }
    }
}

// MARK: - RecipeDetailView
struct RecipeDetailView: View {
    let recipe: Recipe

    var body: some View {
        ZStack {
            // Gradient background matching app style
            LinearGradient(
                colors: [Color.appBlack, Color.gray.opacity(0.3), Color.appBlack],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 30) {
                    headerImageSection
                    recipeInfoSection
                    ingredientsSection
                    instructionsSection
                    
                    Spacer(minLength: 50)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 100)
            }
        }
        .navigationTitle(recipe.title)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var headerImageSection: some View {
        ZStack(alignment: .bottomTrailing) {
            // Recipe image placeholder with gradient
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            colors: [Color.appYellow.opacity(0.3), Color.appYellow.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(height: 200)
                
                Image(systemName: "photo.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.appYellow.opacity(0.6))
            }
            
            // Calories badge
            VStack(spacing: 4) {
                Text("\(recipe.calories)")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.appBlack)
                
                Text("kcal")
                    .font(.system(size: 12))
                    .foregroundColor(.appBlack.opacity(0.8))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.appYellow)
            .cornerRadius(12)
            .padding()
        }
    }
    
    private var recipeInfoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(recipe.title)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.appYellow)
            
            HStack(spacing: 16) {
                HStack(spacing: 6) {
                    Image(systemName: "tag.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.appYellow)
                    
                    Text(recipe.mealType.displayName)
                        .font(.system(size: 14))
                        .foregroundColor(.appWhite.opacity(0.8))
                }
                
                Spacer()
                
                HStack(spacing: 6) {
                    Image(systemName: "clock.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.appYellow)
                    
                    Text("~30 min")
                        .font(.system(size: 14))
                        .foregroundColor(.appWhite.opacity(0.8))
                }
            }
        }
    }
    
    private var ingredientsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "list.bullet.circle.fill")
                    .foregroundColor(.appYellow)
                    .font(.system(size: 20))
                
                Text("Ingredients")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.appYellow)
            }
            
            VStack(spacing: 12) {
                ForEach(recipe.ingredients) { ingredient in
                    HStack(spacing: 12) {
                        Circle()
                            .fill(Color.appYellow.opacity(0.3))
                            .frame(width: 8, height: 8)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(ingredient.name)
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(.appWhite)
                            
                            Text(ingredient.quantity)
                                .font(.system(size: 13))
                                .foregroundColor(.appYellow.opacity(0.8))
                        }
                        
                        Spacer()
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 16)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                }
            }
        }
    }
    
    private var instructionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "doc.text.fill")
                    .foregroundColor(.appYellow)
                    .font(.system(size: 20))
                
                Text("Instructions")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.appYellow)
            }
            
            Text(recipe.instructions)
                .font(.system(size: 15))
                .foregroundColor(.appWhite)
                .lineSpacing(6)
                .padding(16)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(16)
        }
    }
} 
