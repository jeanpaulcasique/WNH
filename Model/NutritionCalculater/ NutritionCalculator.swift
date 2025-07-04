import Foundation

// MARK: - Enhanced CalculatorNutrition.swift
// Fusión de la lógica existente con arquitectura moderna

// MARK: - Protocols
protocol NutritionCalculatorProtocol {
    func calculateDailyCalories(for profile: UserProfile) async throws -> Double
    func calculateMacros(for profile: UserProfile) async throws -> MacroTargets
    func calculateWaterNeeds(for profile: UserProfile) async throws -> Double
    func calculateMealDistribution(for profile: UserProfile) async throws -> [MealType: Double]
    func adjustRecipes(_ recipes: [Recipe], for profile: UserProfile) async throws -> [Recipe]
}

protocol BodyTypeCalculatorProtocol {
    func calculateBodyType(for profile: UserProfile) -> BodyType
}

protocol MetabolismCalculatorProtocol {
    func calculateBMR(for profile: UserProfile, bodyType: BodyType) throws -> Double
    func calculateTDEE(bmr: Double, profile: UserProfile, bodyType: BodyType) throws -> Double
}

protocol ProfileValidatorProtocol {
    func validate(_ profile: UserProfile) throws
    func validateCalories(_ calories: Double, for profile: UserProfile) throws -> Double
}

// MARK: - Error Types
enum NutritionError: LocalizedError {
    case invalidProfile(String)
    case calculationFailed(Error)
    case caloriesOutOfRange(Double)
    case invalidBMI(Double)
    case invalidAge(Int)
    case invalidWeight(Double)
    case invalidHeight(Double)
    
    var errorDescription: String? {
        switch self {
        case .invalidProfile(let reason):
            return "Perfil inválido: \(reason)"
        case .calculationFailed(let error):
            return "Error en cálculo: \(error.localizedDescription)"
        case .caloriesOutOfRange(let calories):
            return "Calorías fuera de rango seguro: \(Int(calories))"
        case .invalidBMI(let bmi):
            return "BMI inválido: \(String(format: "%.1f", bmi))"
        case .invalidAge(let age):
            return "Edad inválida: \(age)"
        case .invalidWeight(let weight):
            return "Peso inválido: \(String(format: "%.1f", weight))kg"
        case .invalidHeight(let height):
            return "Altura inválida: \(String(format: "%.1f", height))cm"
        }
    }
}

// MARK: - Enums
enum BodyType: String, CaseIterable {
    case skinny = "Flaco"
    case regular = "Regular"
    case muscular = "Musculoso"
    case overweight = "Gordo"
    
    var metabolicMultiplier: Double {
        switch self {
        case .skinny: return 0.95
        case .regular: return 1.0
        case .muscular: return 1.05
        case .overweight: return 1.02
        }
    }
    
    var proteinMultiplier: Double {
        switch self {
        case .skinny: return 1.1
        case .regular: return 1.0
        case .muscular: return 1.05
        case .overweight: return 1.15
        }
    }
}

enum WorkoutIntensity: String, CaseIterable {
    case light = "Suave"
    case moderate = "Intermedio"
    case intense = "Intensivo"
    
    var multiplier: Double {
        switch self {
        case .light: return 1.05
        case .moderate: return 1.1
        case .intense: return 1.15
        }
    }
}

enum DietType: String, CaseIterable {
    case keto = "Keto"
    case lowCarb = "Bajo en Carbohidratos"
    case balanced = "Balanceada"
    
    var calorieMultiplier: Double {
        switch self {
        case .keto: return 0.95
        case .lowCarb: return 0.98
        case .balanced: return 1.0
        }
    }
}

// MARK: - Data Structures
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

struct NutritionConfig {
    // Calorías
    static let moderateDeficit: Double = 500
    static let aggressiveDeficit: Double = 750
    static let moderateSurplus: Double = 300
    static let aggressiveSurplus: Double = 500
    
    // Proteína por kg según objetivo
    static let proteinPerKgWeightLoss: Double = 2.0
    static let proteinPerKgMuscleGain: Double = 2.2
    static let proteinPerKgMaintenance: Double = 1.8
    
    // Límites de seguridad
    static let minCaloriesFemale: Double = 1200
    static let minCaloriesMale: Double = 1500
    static let maxCalories: Double = 5000
    
    // Distribución de macros por dieta
    static let ketoMacros = (protein: 0.25, fat: 0.70, carbs: 0.05)
    static let lowCarbMacros = (protein: 0.30, fat: 0.35, carbs: 0.35)
    static let balancedMacros = (protein: 0.25, fat: 0.30, carbs: 0.45)
    
    // Distribución de comidas
    static let mealDistribution = (breakfast: 0.30, lunch: 0.40, dinner: 0.30)
}

struct NutritionReport {
    let dailyCalories: Double
    let macros: MacroTargets
    let waterNeeds: Double
    let mealDistribution: [MealType: Double]
    let recommendations: [String]
    let bodyType: BodyType
    let dietType: DietType
    let workoutIntensity: WorkoutIntensity
    
    var formattedCalories: String {
        return String(format: "%.0f", dailyCalories)
    }
    
    var formattedWater: String {
        return String(format: "%.1f", waterNeeds)
    }
}

// MARK: - Implementation Classes
final class AdvancedBodyTypeCalculator: BodyTypeCalculatorProtocol {
    func calculateBodyType(for profile: UserProfile) -> BodyType {
        guard let bmi = profile.bmi, bmi > 0 else { return .regular }
        
        switch bmi {
        case 0..<18.5: return .skinny
        case 18.5..<25.0: return .regular
        case 25.0..<30.0: return .muscular
        default: return .overweight
        }
    }
}

final class PrecisionMetabolismCalculator: MetabolismCalculatorProtocol {
    func calculateBMR(for profile: UserProfile, bodyType: BodyType) throws -> Double {
        let weight = profile.weightKg
        let height = Double(profile.resolvedHeightCm)
        let age = try calculateAge(from: profile.birthYear)
        
        guard weight > 0 && height > 0 && age > 0 else {
            throw NutritionError.invalidProfile("Datos físicos inválidos")
        }
        
        // Fórmula Mifflin-St Jeor
        let isMale = ["male", "hombre", "masculino", "m"].contains(
            profile.gender.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        )
        
        let baseBMR: Double
        if isMale {
            baseBMR = (10 * weight) + (6.25 * height) - (5 * Double(age)) + 5
        } else {
            baseBMR = (10 * weight) + (6.25 * height) - (5 * Double(age)) - 161
        }
        
        return baseBMR * bodyType.metabolicMultiplier
    }
    
    func calculateTDEE(bmr: Double, profile: UserProfile, bodyType: BodyType) throws -> Double {
        let activityMultiplier = getActivityMultiplier(profile.levelActivity)
        let workoutIntensity = determineWorkoutIntensity(profile.workoutLevel)
        
        let baseTDEE = bmr * activityMultiplier
        return baseTDEE * workoutIntensity.multiplier
    }
    
    private func calculateAge(from birthYear: String) throws -> Int {
        guard let year = Int(birthYear), year > 1900 else {
            throw NutritionError.invalidProfile("Año de nacimiento inválido")
        }
        
        let currentYear = Calendar.current.component(.year, from: Date())
        let age = currentYear - year
        
        guard age >= 18 && age <= 100 else {
            throw NutritionError.invalidAge(age)
        }
        
        return age
    }
    
    private func getActivityMultiplier(_ activity: String) -> Double {
        let normalized = activity.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        if normalized.contains("sedentario") || normalized.contains("sedentary") {
            return 1.2
        } else if normalized.contains("ligero") || normalized.contains("lightly") {
            return 1.375
        } else if normalized.contains("moderado") || normalized.contains("moderate") {
            return 1.55
        } else if normalized.contains("muy") && normalized.contains("activo") {
            return 1.725
        } else if normalized.contains("activo") || normalized.contains("active") {
            return 1.725
        } else {
            return 1.55 // Default moderado
        }
    }
    
    private func determineWorkoutIntensity(_ workoutLevel: String) -> WorkoutIntensity {
        let normalized = workoutLevel.lowercased()
        
        if normalized.contains("suave") || normalized.contains("light") || normalized.contains("principiante") {
            return .light
        } else if normalized.contains("intensivo") || normalized.contains("intense") || normalized.contains("avanzado") {
            return .intense
        } else {
            return .moderate
        }
    }
}

final class ComprehensiveValidator: ProfileValidatorProtocol {
    func validate(_ profile: UserProfile) throws {
        // Validar peso
        guard profile.weightKg > 30 && profile.weightKg < 300 else {
            throw NutritionError.invalidWeight(profile.weightKg)
        }
        
        // Validar altura
        let height = Double(profile.resolvedHeightCm)
        guard height > 100 && height < 250 else {
            throw NutritionError.invalidHeight(height)
        }
        
        // Validar BMI si está disponible
        if let bmi = profile.bmi {
            guard bmi > 10 && bmi < 50 else {
                throw NutritionError.invalidBMI(bmi)
            }
        }
        
        // Validar año de nacimiento
        if let year = Int(profile.birthYear) {
            let currentYear = Calendar.current.component(.year, from: Date())
            let age = currentYear - year
            guard age >= 18 && age <= 100 else {
                throw NutritionError.invalidAge(age)
            }
        }
    }
    
    func validateCalories(_ calories: Double, for profile: UserProfile) throws -> Double {
        let isMale = ["male", "hombre", "masculino", "m"].contains(
            profile.gender.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        )
        
        let minCalories = isMale ? NutritionConfig.minCaloriesMale : NutritionConfig.minCaloriesFemale
        
        guard calories >= minCalories && calories <= NutritionConfig.maxCalories else {
            throw NutritionError.caloriesOutOfRange(calories)
        }
        
        return max(minCalories, min(calories, NutritionConfig.maxCalories))
    }
}

// MARK: - Main Calculator Class
final class NutritionCalculator: NutritionCalculatorProtocol {
    
    // MARK: - Dependencies
    private let bodyTypeCalculator: BodyTypeCalculatorProtocol
    private let metabolismCalculator: MetabolismCalculatorProtocol
    private let validator: ProfileValidatorProtocol
    
    // MARK: - Cache
    private var calculationCache: [String: Any] = [:]
    
    init(
        bodyTypeCalculator: BodyTypeCalculatorProtocol = AdvancedBodyTypeCalculator(),
        metabolismCalculator: MetabolismCalculatorProtocol = PrecisionMetabolismCalculator(),
        validator: ProfileValidatorProtocol = ComprehensiveValidator()
    ) {
        self.bodyTypeCalculator = bodyTypeCalculator
        self.metabolismCalculator = metabolismCalculator
        self.validator = validator
    }
    
    // MARK: - Public API
    func calculateDailyCalories(for profile: UserProfile) async throws -> Double {
        try validator.validate(profile)
        
        let cacheKey = "calories_\(profile.cacheKey)"
        if let cached = calculationCache[cacheKey] as? Double {
            return cached
        }
        
        let bodyType = bodyTypeCalculator.calculateBodyType(for: profile)
        let bmr = try metabolismCalculator.calculateBMR(for: profile, bodyType: bodyType)
        let tdee = try metabolismCalculator.calculateTDEE(bmr: bmr, profile: profile, bodyType: bodyType)
        
        let adjustedCalories = adjustForGoalAndDiet(tdee: tdee, profile: profile, bodyType: bodyType)
        let finalCalories = try validator.validateCalories(adjustedCalories, for: profile)
        
        calculationCache[cacheKey] = finalCalories
        return finalCalories
    }
    
    func calculateMacros(for profile: UserProfile) async throws -> MacroTargets {
        let dailyCalories = try await calculateDailyCalories(for: profile)
        let dietType = determineDietType(profile.dietType)
        let bodyType = bodyTypeCalculator.calculateBodyType(for: profile)
        
        let (proteinRatio, fatRatio, carbRatio) = getMacroRatios(for: dietType)
        
        // Calcular proteína basada en peso corporal
        let proteinGrams = calculateProteinNeeds(profile: profile, bodyType: bodyType)
        let proteinCalories = proteinGrams * 4.0
        
        // Ajustar otros macros
        let remainingCalories = dailyCalories - proteinCalories
        let fatCalories = remainingCalories * (fatRatio / (fatRatio + carbRatio))
        let carbCalories = remainingCalories - fatCalories
        
        return MacroTargets(
            calories: dailyCalories,
            protein: proteinGrams,
            fat: fatCalories / 9.0,
            carbs: carbCalories / 4.0
        )
    }
    
    func calculateWaterNeeds(for profile: UserProfile) async throws -> Double {
        try validator.validate(profile)
        
        let baseWater = profile.weightKg * 0.035 // 35ml por kg
        
        let activityMultiplier: Double
        let activity = profile.levelActivity.lowercased()
        
        if activity.contains("sedentario") || activity.contains("sedentary") {
            activityMultiplier = 1.0
        } else if activity.contains("ligero") || activity.contains("lightly") {
            activityMultiplier = 1.1
        } else if activity.contains("moderado") || activity.contains("moderate") {
            activityMultiplier = 1.2
        } else {
            activityMultiplier = 1.3
        }
        
        let workoutIntensity = determineWorkoutIntensity(profile.workoutLevel)
        let trainingBonus = workoutIntensity == .intense ? 0.5 : 0.3
        
        return (baseWater * activityMultiplier) + trainingBonus
    }
    
    // ✅ NUEVO: Método síncrono para calcular agua con fórmula mejorada
    func calculateWaterNeedsSynchronously(for profile: UserProfile) -> String {
        let weight = profile.weightKg
        let age: Int = {
            let currentYear = Calendar.current.component(.year, from: Date())
            return currentYear - (Int(profile.birthYear) ?? (currentYear - 30))
        }()
        let gender = profile.gender.lowercased()
        let height = Double(profile.resolvedHeightCm)

        guard weight > 0 else { return "Set your weight to get recommendation" }
        
        var liters = weight * 0.033 // Base: 33ml por kg
        
        // Ajustes por características físicas
        if height > 180 { liters *= 1.05 }
        else if height < 160 { liters *= 0.95 }
        if age < 14 { liters *= 0.8 }
        if gender.contains("male") { liters *= 1.1 }

        // Ajuste por nivel de actividad
        switch profile.levelActivity.lowercased() {
        case "high", "active", "very active":
            liters *= 1.2
        case "moderate", "moderately active":
            liters *= 1.1
        default:
            break
        }
        
        return String(format: "%.1f L", liters)
    }
    
    func calculateMealDistribution(for profile: UserProfile) async throws -> [MealType: Double] {
        let dailyCalories = try await calculateDailyCalories(for: profile)
        let dietType = determineDietType(profile.dietType)
        
        let distribution = getMealDistribution(for: dietType)
        
        return [
            MealType.Breakfast: dailyCalories * distribution.breakfast,
            MealType.Lunch: dailyCalories * distribution.lunch,
            MealType.Dinner: dailyCalories * distribution.dinner
        ]
    }
    
    func adjustRecipes(_ recipes: [Recipe], for profile: UserProfile) async throws -> [Recipe] {
        let mealDistribution = try await calculateMealDistribution(for: profile)
        let groupedRecipes = Dictionary(grouping: recipes, by: { $0.mealType })
        
        var adjustedRecipes: [Recipe] = []
        
        for (mealType, mealRecipes) in groupedRecipes {
            guard let targetCalories = mealDistribution[mealType] else { continue }
            
            let adjustedMealRecipes = adjustMealGroup(
                recipes: mealRecipes,
                targetCalories: targetCalories,
                mealType: mealType
            )
            
            adjustedRecipes.append(contentsOf: adjustedMealRecipes)
        }
        
        return adjustedRecipes
    }
    
    // MARK: - Private Methods
    private func adjustForGoalAndDiet(tdee: Double, profile: UserProfile, bodyType: BodyType) -> Double {
        let goal = profile.goal.lowercased()
        let dietType = determineDietType(profile.dietType)
        
        var adjustedCalories = tdee
        
        // Ajuste por objetivo
        if goal.contains("perder") || goal.contains("adelgazar") || goal.contains("lose") {
            let deficit = goal.contains("agresivo") ? NutritionConfig.aggressiveDeficit : NutritionConfig.moderateDeficit
            adjustedCalories = tdee - deficit
        } else if goal.contains("ganar") || goal.contains("musculo") || goal.contains("muscle") || goal.contains("bulk") {
            let surplus = goal.contains("agresivo") ? NutritionConfig.aggressiveSurplus : NutritionConfig.moderateSurplus
            adjustedCalories = tdee + surplus
        }
        
        // Ajuste por tipo de dieta
        adjustedCalories *= dietType.calorieMultiplier
        
        // Ajuste adicional por tipo de cuerpo
        if bodyType == .skinny && goal.contains("ganar") {
            adjustedCalories += 100 // Bonus para ectomorfos
        } else if bodyType == .overweight && goal.contains("perder") {
            adjustedCalories -= 50 // Déficit extra para sobrepeso
        }
        
        return adjustedCalories
    }
    
    private func determineDietType(_ dietString: String) -> DietType {
        let normalized = dietString.lowercased()
        
        if normalized.contains("keto") || normalized.contains("cetogénica") {
            return .keto
        } else if normalized.contains("bajo") && (normalized.contains("carb") || normalized.contains("carbohidrato")) {
            return .lowCarb
        } else {
            return .balanced
        }
    }
    
    private func determineWorkoutIntensity(_ workoutLevel: String) -> WorkoutIntensity {
        let normalized = workoutLevel.lowercased()
        
        if normalized.contains("suave") || normalized.contains("light") || normalized.contains("principiante") {
            return .light
        } else if normalized.contains("intensivo") || normalized.contains("intense") || normalized.contains("avanzado") {
            return .intense
        } else {
            return .moderate
        }
    }
    
    private func getMacroRatios(for dietType: DietType) -> (protein: Double, fat: Double, carbs: Double) {
        switch dietType {
        case .keto:
            return NutritionConfig.ketoMacros
        case .lowCarb:
            return NutritionConfig.lowCarbMacros
        case .balanced:
            return NutritionConfig.balancedMacros
        }
    }
    
    private func calculateProteinNeeds(profile: UserProfile, bodyType: BodyType) -> Double {
        let goal = profile.goal.lowercased()
        
        let baseProteinPerKg: Double
        if goal.contains("perder") || goal.contains("adelgazar") {
            baseProteinPerKg = NutritionConfig.proteinPerKgWeightLoss
        } else if goal.contains("ganar") || goal.contains("musculo") {
            baseProteinPerKg = NutritionConfig.proteinPerKgMuscleGain
        } else {
            baseProteinPerKg = NutritionConfig.proteinPerKgMaintenance
        }
        
        return profile.weightKg * baseProteinPerKg * bodyType.proteinMultiplier
    }
    
    private func getMealDistribution(for dietType: DietType) -> (breakfast: Double, lunch: Double, dinner: Double) {
        switch dietType {
        case .keto:
            return (0.25, 0.35, 0.40) // Cena más grande en keto
        case .lowCarb:
            return (0.30, 0.40, 0.30) // Almuerzo más sustancial
        case .balanced:
            return NutritionConfig.mealDistribution
        }
    }
    
    private func adjustMealGroup(recipes: [Recipe], targetCalories: Double, mealType: MealType) -> [Recipe] {
        guard !recipes.isEmpty else { return [] }
        
        if recipes.count == 1 {
            let recipe = recipes[0]
            let factor = recipe.calories > 0 ? targetCalories / Double(recipe.calories) : 1.0
            return [adjustSingleRecipe(recipe, factor: factor)]
        }
        
        let currentCalories = recipes.reduce(0) { $0 + $1.calories }
        let adjustmentFactor = currentCalories > 0 ? targetCalories / Double(currentCalories) : 1.0
        
        return recipes.map { adjustSingleRecipe($0, factor: adjustmentFactor) }
    }
    
    private func adjustSingleRecipe(_ recipe: Recipe, factor: Double) -> Recipe {
        let adjustedIngredients = recipe.ingredients.map { ingredient in
            adjustIngredient(ingredient, factor: factor)
        }
        
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
        let (quantity, unit) = parseQuantity(ingredient.quantity)
        let adjustedQuantity = quantity * factor
        let formattedQuantity = formatQuantity(adjustedQuantity, unit: unit, ingredientName: ingredient.name)
        
        return Ingredient(
            name: ingredient.name,
            quantity: formattedQuantity,
            isChecked: ingredient.isChecked
        )
    }
    
    private func parseQuantity(_ quantity: String) -> (Double, String) {
        let pattern = #"([0-9]*\.?[0-9]+)\s*(.*)?"#
        guard let regex = try? NSRegularExpression(pattern: pattern),
              let match = regex.firstMatch(in: quantity, range: NSRange(quantity.startIndex..., in: quantity)),
              let numberRange = Range(match.range(at: 1), in: quantity) else {
            return (1.0, quantity)
        }
        
        let number = Double(quantity[numberRange]) ?? 1.0
        let unitRange = Range(match.range(at: 2), in: quantity)
        let unit = unitRange != nil ? String(quantity[unitRange!]) : ""
        
        return (number, unit.trimmingCharacters(in: .whitespacesAndNewlines))
    }
    
    private func formatQuantity(_ value: Double, unit: String, ingredientName: String) -> String {
        let rounded = (value * 10).rounded() / 10
        
        // Convertir a unidades naturales si es posible
        if unit.lowercased().contains("g") || unit.lowercased().contains("gram") {
            return convertToNaturalUnits(name: ingredientName, grams: rounded)
        }
        
        if rounded.truncatingRemainder(dividingBy: 1) == 0 {
            return "\(Int(rounded))\(unit.isEmpty ? "" : " \(unit)")"
        } else {
            return String(format: "%.1f%@", rounded, unit.isEmpty ? "" : " \(unit)")
        }
    }
    
    private func convertToNaturalUnits(name: String, grams: Double) -> String {
        let unitMap: [String: Double] = [
            "zanahoria": 80, "tomate": 120, "papa": 150, "cebolla": 100,
            "manzana": 180, "huevo": 60, "plátano": 120, "naranja": 150
        ]
        
        for (key, avgGrams) in unitMap {
            if name.lowercased().contains(key) {
                let units = Int(ceil(grams / avgGrams))
                return "\(units) \(key)\(units > 1 ? "s" : "")"
            }
        }
        
        return "\(Int(grams)) gr"
    }
    
    // MARK: - Report Generation
    func generateNutritionReport() -> NutritionReport {
        let userProfile = UserProfile.loadFromUserDefaults()
        
        // Calcular todos los valores necesarios
        let bodyType = bodyTypeCalculator.calculateBodyType(for: userProfile)
        let dietType = determineDietType(userProfile.dietType)
        let workoutIntensity = determineWorkoutIntensity(userProfile.workoutLevel)
        
        // ✅ CORREGIDO: Usar cálculo real de calorías en lugar de valor fijo
        let dailyCalories = calculateDailyCaloriesSynchronously(for: userProfile)
        let macros = calculateMacrosSynchronously(for: userProfile, dailyCalories: dailyCalories)
        
        // ✅ CORREGIDO: Usar la fórmula mejorada de agua
        let waterNeeds = calculateWaterNeedsSynchronously(for: userProfile)
        let waterNeedsDouble = extractWaterValue(from: waterNeeds)
        
        let mealDistribution = [
            MealType.Breakfast: dailyCalories * 0.30,
            MealType.Lunch: dailyCalories * 0.40,
            MealType.Dinner: dailyCalories * 0.30
        ]
        
        let recommendations = generateRecommendations(for: userProfile, bodyType: bodyType, dietType: dietType)
        
        return NutritionReport(
            dailyCalories: dailyCalories,
            macros: macros,
            waterNeeds: waterNeedsDouble,
            mealDistribution: mealDistribution,
            recommendations: recommendations,
            bodyType: bodyType,
            dietType: dietType,
            workoutIntensity: workoutIntensity
        )
    }
    
    // ✅ NUEVO: Método auxiliar para extraer el valor numérico del agua
    private func extractWaterValue(from waterString: String) -> Double {
        let components = waterString.components(separatedBy: " ")
        if let firstComponent = components.first, let value = Double(firstComponent) {
            return value
        }
        return 2.0 // Default si no se puede extraer
    }
    
    // ✅ NUEVO: Método síncrono para calcular calorías
    private func calculateDailyCaloriesSynchronously(for profile: UserProfile) -> Double {
        let age = Calendar.current.component(.year, from: Date()) - (Int(profile.birthYear) ?? 30)
        let height = Double(profile.resolvedHeightCm)
        let weight = profile.weightKg
        let gender = profile.gender.lowercased()
        let activityLevel = profile.levelActivity.lowercased()
        let goal = profile.goal.lowercased()
        
        // Calcular BMR usando la fórmula de Mifflin-St Jeor
        var bmr: Double
        if gender.contains("male") {
            bmr = (10 * weight) + (6.25 * height) - (5 * Double(age)) + 5
        } else {
            bmr = (10 * weight) + (6.25 * height) - (5 * Double(age)) - 161
        }
        
        // Aplicar factor de actividad
        let activityMultiplier: Double
        switch activityLevel {
        case "sedentary", "low":
            activityMultiplier = 1.2
        case "moderate", "moderately active":
            activityMultiplier = 1.375
        case "active", "high":
            activityMultiplier = 1.55
        case "very active":
            activityMultiplier = 1.725
        default:
            activityMultiplier = 1.2
        }
        
        let tdee = bmr * activityMultiplier
        
        // Ajustar según el objetivo
        let adjustedCalories: Double
        if goal.contains("perder") || goal.contains("adelgazar") {
            adjustedCalories = tdee - 500 // Déficit de 500 calorías
        } else if goal.contains("ganar") || goal.contains("musculo") {
            adjustedCalories = tdee + 300 // Superávit de 300 calorías
        } else {
            adjustedCalories = tdee // Mantenimiento
        }
        
        return max(adjustedCalories, 1200) // Mínimo 1200 calorías
    }
    
    // ✅ NUEVO: Método síncrono para calcular macros
    private func calculateMacrosSynchronously(for profile: UserProfile, dailyCalories: Double) -> MacroTargets {
        let bodyType = bodyTypeCalculator.calculateBodyType(for: profile)
        let goal = profile.goal.lowercased()
        
        // Calcular proteína
        let proteinPerKg: Double
        if goal.contains("perder") || goal.contains("adelgazar") {
            proteinPerKg = NutritionConfig.proteinPerKgWeightLoss
        } else if goal.contains("ganar") || goal.contains("musculo") {
            proteinPerKg = NutritionConfig.proteinPerKgMuscleGain
        } else {
            proteinPerKg = NutritionConfig.proteinPerKgMaintenance
        }
        
        let protein = profile.weightKg * proteinPerKg * bodyType.proteinMultiplier
        let proteinCalories = protein * 4
        
        // Calcular grasas (25-35% del total)
        let fatPercentage = 0.30
        let fatCalories = dailyCalories * fatPercentage
        let fat = fatCalories / 9
        
        // Calcular carbohidratos (resto)
        let remainingCalories = dailyCalories - proteinCalories - fatCalories
        let carbs = remainingCalories / 4
        
        return MacroTargets(
            calories: dailyCalories,
            protein: protein,
            fat: fat,
            carbs: carbs
        )
    }
    
    private func generateRecommendations(for profile: UserProfile, bodyType: BodyType, dietType: DietType) -> [String] {
        var recommendations: [String] = []
        
        // Recomendaciones basadas en el objetivo
        let goal = profile.goal.lowercased()
        if goal.contains("perder") || goal.contains("adelgazar") {
            recommendations.append("Mantén un déficit calórico moderado de 300-500 calorías")
            recommendations.append("Prioriza proteína magra para preservar masa muscular")
        } else if goal.contains("ganar") || goal.contains("musculo") {
            recommendations.append("Consume un superávit calórico de 200-300 calorías")
            recommendations.append("Aumenta tu ingesta de proteína a 2.2g por kg")
        } else {
            recommendations.append("Mantén un balance calórico para mantener tu peso")
            recommendations.append("Enfócate en la calidad de los alimentos")
        }
        
        // Recomendaciones basadas en el tipo de cuerpo
        switch bodyType {
        case .skinny:
            recommendations.append("Considera aumentar la frecuencia de comidas")
        case .overweight:
            recommendations.append("Enfócate en alimentos con alta densidad nutricional")
        case .muscular:
            recommendations.append("Mantén una ingesta consistente de proteína")
        default:
            recommendations.append("Mantén un balance en todos los macronutrientes")
        }
        
        // Recomendaciones basadas en la dieta
        switch dietType {
        case .keto:
            recommendations.append("Mantén los carbohidratos por debajo de 50g diarios")
            recommendations.append("Aumenta tu ingesta de grasas saludables")
        case .lowCarb:
            recommendations.append("Limita los carbohidratos a 100-150g diarios")
            recommendations.append("Prioriza carbohidratos complejos")
        case .balanced:
            recommendations.append("Mantén una distribución equilibrada de macros")
        }
        
        return recommendations
    }
}

// MARK: - Extensions
extension UserProfile {
    var cacheKey: String {
        return "\(weightKg)_\(resolvedHeightCm)_\(age)_\(gender)_\(goal)_\(levelActivity)_\(dietType)_\(workoutLevel)"
    }
}
