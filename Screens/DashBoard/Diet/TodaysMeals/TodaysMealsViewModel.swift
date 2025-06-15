import SwiftUI
import Combine

class TodaysMealsViewModel: ObservableObject {
    @Published var weeklyRecipes: [Date: [Recipe]] = [:]
    @Published var selectedDay: Date = Date()
    
    private var nutritionCalculator: NutritionCalculator
    private var userProfile: UserProfile
    
    var totalCaloriesGoal: Int {
        return Int(nutritionCalculator.calculateDailyCalories())
    }
    
    init(userProfile: UserProfile = UserProfile.loadFromUserDefaults()) {
        self.userProfile = userProfile
        self.nutritionCalculator = NutritionCalculator(
            userProfile: userProfile,
            distribution: .custom(breakfast: 35, lunch: 40, dinner: 25)
        )
    }
    
    func recipes(for meal: MealType) -> [Recipe] {
        weeklyRecipes[selectedDay]?.filter { $0.mealType == meal } ?? []
    }
    
    func getTotalDailyCalories() -> Int {
        getConsumedCalories().values.reduce(0, +)
    }
    
    func getConsumedCalories() -> [MealType: Int] {
        var consumed: [MealType: Int] = [:]
        
        for mealType in MealType.allCases {
            consumed[mealType] = recipes(for: mealType).reduce(0) { $0 + $1.calories }
        }
        
        return consumed
    }
    
    func updateSelectedDay(_ day: Date) {
        selectedDay = day
    }
    
    func updateWeeklyRecipes(_ recipes: [Date: [Recipe]]) {
        weeklyRecipes = recipes
    }
} 