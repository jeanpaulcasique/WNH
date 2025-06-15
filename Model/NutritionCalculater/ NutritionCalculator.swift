import Foundation

// MARK: - NutritionCalculator - Sistema modular mejorado

class NutritionCalculator {
    
    // MARK: - Configuración
    private struct Config {
        static let calorieDeficit: Double = 500
        static let calorieSurplus: Double = 300
        static let proteinPerKg: Double = 1.6  // Gramos por kg
        static let fatRatio: Double = 0.25     // 25% de calorías de grasa
        static let minCalories: Double = 1200  // Mínimo seguro
    }
    
    // MARK: - Distribución de comidas
    enum MealDistribution {
        case balanced        // 30% - 40% - 30%
        case frontLoaded    // 40% - 35% - 25%
        case backLoaded     // 25% - 35% - 40%
        case custom(breakfast: Double, lunch: Double, dinner: Double)
        
        var percentages: (breakfast: Double, lunch: Double, dinner: Double) {
            switch self {
            case .balanced:
                return (0.30, 0.40, 0.30)
            case .frontLoaded:
                return (0.40, 0.35, 0.25)
            case .backLoaded:
                return (0.25, 0.35, 0.40)
            case .custom(let b, let l, let d):
                let total = b + l + d
                return (b/total, l/total, d/total)
            }
        }
    }
    
    // MARK: - Propiedades
    private let userProfile: UserProfile
    private let distribution: MealDistribution
    
    // MARK: - Inicialización
    init(userProfile: UserProfile = UserProfile.loadFromUserDefaults(),
         distribution: MealDistribution = .balanced) {
        self.userProfile = userProfile
        self.distribution = distribution
    }
    
    // MARK: - API Pública Principal
    
    /// Calcula las calorías diarias objetivo basadas en el perfil del usuario
    func calculateDailyCalories() -> Double {
        let bmr = calculateBMR()
        let tdee = calculateTDEE(bmr: bmr)
        let adjustedCalories = adjustForGoal(tdee: tdee)
        
        print("🔥 Cálculo calórico:")
        print("   • BMR: \(Int(bmr)) cal")
        print("   • TDEE: \(Int(tdee)) cal")
        print("   • Objetivo: \(Int(adjustedCalories)) cal")
        
        return max(adjustedCalories, Config.minCalories)
    }
    
    /// Calcula la distribución de calorías por comida
    func calculateMealDistribution() -> [MealType: Double] {
        let dailyCalories = calculateDailyCalories()
        let percentages = distribution.percentages
        
        return [
            .Breakfast: dailyCalories * percentages.breakfast,
            .Lunch: dailyCalories * percentages.lunch,
            .Dinner: dailyCalories * percentages.dinner
        ]
    }
    
    /// Calcula macronutrientes objetivo
    func calculateMacros() -> MacroTargets {
        let dailyCalories = calculateDailyCalories()
        
        // Proteína: g/kg de peso corporal
        let proteinGrams = userProfile.weightKg * Config.proteinPerKg
        let proteinCalories = proteinGrams * 4.0
        
        // Grasa: porcentaje fijo de calorías totales
        let fatCalories = dailyCalories * Config.fatRatio
        let fatGrams = fatCalories / 9.0
        
        // Carbohidratos: calorías restantes
        let remainingCalories = dailyCalories - proteinCalories - fatCalories
        let carbGrams = max(remainingCalories / 4.0, 0)
        
        return MacroTargets(
            calories: dailyCalories,
            protein: proteinGrams,
            fat: fatGrams,
            carbs: carbGrams
        )
    }
    
    /// Ajusta una lista de recetas para cumplir objetivos calóricos
    func adjustRecipes(_ recipes: [Recipe]) -> [Recipe] {
        print("🔄 Iniciando ajuste inteligente de \(recipes.count) recetas")
        
        let mealDistribution = calculateMealDistribution()
        let groupedRecipes = Dictionary(grouping: recipes, by: { $0.mealType })
        
        var adjustedRecipes: [Recipe] = []
        
        // Ajustar cada grupo de comidas
        for (mealType, mealRecipes) in groupedRecipes {
            guard let targetCalories = mealDistribution[mealType] else { continue }
            
            let adjustedMealRecipes = adjustMealGroup(
                recipes: mealRecipes,
                targetCalories: targetCalories,
                mealType: mealType
            )
            
            adjustedRecipes.append(contentsOf: adjustedMealRecipes)
        }
        
        // Verificación final
        verifyAdjustment(original: recipes, adjusted: adjustedRecipes)
        
        return adjustedRecipes
    }
    
    // MARK: - Métodos Privados - Cálculos Base
    
    private func calculateBMR() -> Double {
        let weight = userProfile.weightKg
        let height = Double(userProfile.resolvedHeightCm)
        let age = calculateAge()
        
        // Fórmula de Mifflin-St Jeor (más precisa que Harris-Benedict)
        let isMale = ["male", "m", "hombre", "masculino"]
            .contains(userProfile.gender.lowercased().trimmingCharacters(in: .whitespacesAndNewlines))
        
        if isMale {
            return (10 * weight) + (6.25 * height) - (5 * Double(age)) + 5
        } else {
            return (10 * weight) + (6.25 * height) - (5 * Double(age)) - 161
        }
    }
    
    private func calculateTDEE(bmr: Double) -> Double {
        let activityFactors: [String: Double] = [
            "sedentary": 1.2,
            "low": 1.2,
            "lightly active": 1.375,
            "moderate": 1.55,
            "moderately active": 1.55,
            "very active": 1.725,
            "high": 1.725,
            "active": 1.725,
            "extremely active": 1.9
        ]
        
        let normalizedActivity = userProfile.levelActivity
            .lowercased()
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        let factor = activityFactors[normalizedActivity] ?? 1.55 // Default moderado
        
        return bmr * factor
    }
    
    private func adjustForGoal(tdee: Double) -> Double {
        let goalLower = userProfile.goal.lowercased()
        
        switch goalLower {
        case let goal where goal.contains("lose") || goal.contains("cut") || goal.contains("deficit"):
            return tdee - Config.calorieDeficit
        case let goal where goal.contains("gain") || goal.contains("bulk") || goal.contains("muscle"):
            return tdee + Config.calorieSurplus
        default: // maintain
            return tdee
        }
    }
    
    private func calculateAge() -> Int {
        guard let birthYear = Int(userProfile.birthYear), birthYear > 1900 else {
            return 30 // Default seguro
        }
        
        let currentYear = Calendar.current.component(.year, from: Date())
        return max(currentYear - birthYear, 18) // Mínimo 18 años
    }
    
    // MARK: - Ajuste de Recetas
    
    private func adjustMealGroup(recipes: [Recipe], targetCalories: Double, mealType: MealType) -> [Recipe] {
        guard !recipes.isEmpty else { return [] }

        print("🍽️ Ajustando \(mealType.displayName):")
        print("   • Recetas: \(recipes.count)")
        print("   • Objetivo: \(Int(targetCalories)) cal")

        // Si solo hay una receta, ajustamos directamente
        if recipes.count == 1 {
            let recipe = recipes[0]
            let factor = recipe.calories > 0 ? targetCalories / Double(recipe.calories) : 1.0
            print("   • Ajuste único: \(String(format: "%.2f", factor))x")

            let adjusted = adjustSingleRecipe(recipe, factor: factor)
            print("   ✅ Resultado: \(adjusted.calories) cal")
            return [adjusted]
        }

        // Ajuste para múltiples recetas
        let currentCalories = recipes.reduce(0) { $0 + $1.calories }
        print("   • Actual: \(currentCalories) cal")

        let adjustmentFactor = currentCalories > 0 ? targetCalories / Double(currentCalories) : 1.0
        print("   • Factor: \(String(format: "%.3f", adjustmentFactor))")

        let adjustedRecipes = recipes.map { recipe in
            adjustSingleRecipe(recipe, factor: adjustmentFactor)
        }

        let finalCalories = adjustedRecipes.reduce(0) { $0 + $1.calories }
        print("   ✅ Resultado: \(finalCalories) cal")

        return adjustedRecipes
    }
    
    private func adjustSingleRecipe(_ recipe: Recipe, factor: Double) -> Recipe {
        // Ajustar ingredientes usando el QuantityParser existente
        let adjustedIngredients = recipe.ingredients.map { ingredient in
            adjustIngredient(ingredient, factor: factor)
        }
        
        // Calcular nuevas calorías
        let newCalories = Int((Double(recipe.calories) * factor).rounded())
        
        return Recipe(
            title: recipe.title,
            mealType: recipe.mealType,
            imageName: recipe.imageName,
            ingredients: adjustedIngredients,
            instructions: recipe.instructions,
            calories: newCalories
        )
    }
    
    private func adjustIngredient(_ ingredient: Ingredient, factor: Double) -> Ingredient {
        // Usar el parseQuantitySimple que ya existe en DietViewModel
        let (quantity, unit) = parseQuantitySimple(ingredient.quantity)
        let adjustedQuantity = quantity * factor
        
        // Convertir gramos a unidades si es posible
        let formattedQuantity: String
        let normalizedUnit = unit.lowercased().trimmingCharacters(in: .whitespaces)
        
        if ["g", "gr", "gramos", "grams"].contains(normalizedUnit) {
            formattedQuantity = convertToUnitBasedIfPossible(name: ingredient.name, quantityInGrams: adjustedQuantity)
        } else {
            formattedQuantity = formatQuantitySimple(adjustedQuantity, unit: unit)
        }
        
        return Ingredient(
            name: ingredient.name,
            quantity: formattedQuantity,
            isChecked: ingredient.isChecked
        )
    }
    
    // MARK: - Helpers de Parsing (Usando la misma lógica que DietViewModel)
    
    private func parseQuantitySimple(_ quantity: String) -> (Double, String) {
        let pattern = #"([0-9]*\.?[0-9]+)\s*(.*)?"#
        guard let regex = try? NSRegularExpression(pattern: pattern),
              let match = regex.firstMatch(in: quantity, range: NSRange(quantity.startIndex..., in: quantity)),
              let numberRange = Range(match.range(at: 1), in: quantity) else {
            return (1.0, quantity)
        }
        
        let number = Double(quantity[numberRange]) ?? 1.0
        let unitRange = Range(match.range(at: 2), in: quantity)
        let unit = unitRange != nil ? String(quantity[unitRange!]) : ""
        
        return (number, unit.trimmingCharacters(in: .whitespaces))
    }
    
    private func formatQuantitySimple(_ value: Double, unit: String) -> String {
        let rounded = (value * 10).rounded() / 10
        
        if rounded.truncatingRemainder(dividingBy: 1) == 0 {
            return "\(Int(rounded))\(unit.isEmpty ? "" : " \(unit)")"
        } else {
            return String(format: "%.1f%@", rounded, unit.isEmpty ? "" : " \(unit)")
        }
    }
    
    /// Convierte gramos a unidades aproximadas si corresponde (ej: zanahoria, tomate, etc.)
    private func convertToUnitBasedIfPossible(name: String, quantityInGrams: Double) -> String {
        let unitMap: [String: Double] = [
            "zanahoria": 80,
            "tomate": 120,
            "papa": 150,
            "cebolla": 100,
            "manzana": 180,
            "huevo": 60,
            "plátano": 120,
            "naranja": 150
        ]
        
        for (key, avgGramsPerUnit) in unitMap {
            if name.lowercased().contains(key) {
                let units = Int(ceil(quantityInGrams / avgGramsPerUnit))
                return "\(units) \(key)\(units > 1 ? "s" : "")"
            }
        }
        
        return "\(Int(quantityInGrams)) gr"
    }
    
    // MARK: - Verificación y Debug
    
    private func verifyAdjustment(original: [Recipe], adjusted: [Recipe]) {
        let originalCalories = original.reduce(0) { $0 + $1.calories }
        let adjustedCalories = adjusted.reduce(0) { $0 + $1.calories }
        let dailyTarget = calculateDailyCalories()
        
        print("📊 Verificación del ajuste:")
        print("   • Original semanal: \(originalCalories) cal")
        print("   • Ajustado semanal: \(adjustedCalories) cal")
        print("   • Objetivo diario: \(Int(dailyTarget)) cal")
        print("   • Promedio diario ajustado: \(Int(Double(adjustedCalories) / 7.0)) cal")
        
        let precision = (Double(adjustedCalories) / 7.0) / dailyTarget * 100
        print("   • Precisión: \(String(format: "%.1f", precision))%")
    }
    
    /// Genera un reporte detallado del plan nutricional
    func generateNutritionReport() -> NutritionReport {
        let dailyCalories = calculateDailyCalories()
        let macros = calculateMacros()
        let mealDistribution = calculateMealDistribution()
        
        return NutritionReport(
            dailyCalories: dailyCalories,
            macros: macros,
            mealDistribution: mealDistribution,
            userProfile: userProfile
        )
    }
}

// MARK: - Estructuras de Soporte

struct MacroTargets {
    let calories: Double
    let protein: Double  // gramos
    let fat: Double      // gramos
    let carbs: Double    // gramos
    
    var proteinCalories: Double { protein * 4.0 }
    var fatCalories: Double { fat * 9.0 }
    var carbCalories: Double { carbs * 4.0 }
    
    var proteinPercentage: Double { (proteinCalories / calories) * 100 }
    var fatPercentage: Double { (fatCalories / calories) * 100 }
    var carbPercentage: Double { (carbCalories / calories) * 100 }
}

struct NutritionReport {
    let dailyCalories: Double
    let macros: MacroTargets
    let mealDistribution: [MealType: Double]
    let userProfile: UserProfile
    
    // Computed properties para facilitar el acceso a la información
    var dailyCaloriesInt: Int {
        Int(dailyCalories.rounded())
    }
    
    var proteinGrams: Int {
        Int(macros.protein.rounded())
    }
    
    var fatGrams: Int {
        Int(macros.fat.rounded())
    }
    
    var carbGrams: Int {
        Int(macros.carbs.rounded())
    }
    
    var breakfastCalories: Int {
        Int((mealDistribution[.Breakfast] ?? 0).rounded())
    }
    
    var lunchCalories: Int {
        Int((mealDistribution[.Lunch] ?? 0).rounded())
    }
    
    var dinnerCalories: Int {
        Int((mealDistribution[.Dinner] ?? 0).rounded())
    }
}
