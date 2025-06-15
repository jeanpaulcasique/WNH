import SwiftUI

struct TodaysMealsView: View {
    @ObservedObject var viewModel: TodaysMealsViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Today's Meals")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.appYellow)
                Spacer()
                
                // Progress indicator
                Text("\(viewModel.getTotalDailyCalories())/\(Int(viewModel.totalCaloriesGoal)) kcal")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.appYellow.opacity(0.8))
            }
            
            VStack(spacing: 12) {
                ForEach(MealType.allCases, id: \.self) { meal in
                    ForEach(viewModel.recipes(for: meal)) { recipe in
                        NavigationLink(destination: RecipeDetailView(recipe: recipe)) {
                            StyledRecipeCard(recipe: recipe)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
        }
    }
}

struct TodaysMealsView_Previews: PreviewProvider {
    static var previews: some View {
        TodaysMealsView(viewModel: TodaysMealsViewModel())
            .preferredColorScheme(.dark)
    }
} 