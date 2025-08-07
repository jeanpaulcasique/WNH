import SwiftUI
import Combine

class TodaysMealsViewModel: ObservableObject {
    @Published var weeklyRecipes: [Date: [Recipe]] = [:]
    @Published var selectedDay: Date = Date()
    
    private var nutritionCalculator: NutritionCalculator
    private var userProfile: UserProfile
    
    var totalCaloriesGoal: Int {
        // Usar método async en Task
        return 2000 // Valor por defecto, actualizar con async
    }
    
    init(userProfile: UserProfile = UserProfile.loadFromUserDefaults()) {
        self.userProfile = userProfile
        self.nutritionCalculator = NutritionCalculator() // Sin parámetro userProfile
        
        // Calcular calorías asíncronamente
        Task {
            await updateCaloriesGoal()
        }
    }
    
    @MainActor
    private func updateCaloriesGoal() async {
        do {
            let calories = try await nutritionCalculator.calculateDailyCalories(for: userProfile)
            // Actualizar UI si necesario
        } catch {
            print("Error calculando calorías: \(error)")
        }
    }
    
    // Resto del código igual...
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
        DispatchQueue.main.async {
            self.selectedDay = day
        }
    }
    
    func updateWeeklyRecipes(_ recipes: [Date: [Recipe]]) {
        DispatchQueue.main.async {
            self.weeklyRecipes = recipes
        }
    }
}
