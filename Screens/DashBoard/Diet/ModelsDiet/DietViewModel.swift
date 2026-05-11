import SwiftUI
import Combine
import Foundation

// MARK: - DietViewModel Final

class DietViewModel: ObservableObject {
    @Published var selectedDiet: String {
        didSet {
            UserDefaults.standard.set(selectedDiet, forKey: Self.selectedDietKey)
            Task {
                await loadRecipesForSelectedDiet()
            }
        }
    }
    @Published var days: [Date] = []
    @Published var selectedDay: Date = Date()
    @Published var weeklyRecipes: [Date: [Recipe]] = [:] {
        didSet {
            updateGroceryList()
        }
    }
    @Published var nutritionReport: NutritionReport?
    @Published var isLoadingNutrition = false
    @Published var ringRotation: Double = 0.0

    // Animation states
    @Published var showNutritionCards: Bool = false
    @Published var showSelectors: Bool = false

    private let calendar = Calendar(identifier: .gregorian)
    private static let selectedDietKey = "selectedDietType"

    // ✅ CORREGIDO: Variable normal que se actualiza cuando sea necesario
    private var userProfile: UserProfile = UserProfile.loadFromUserDefaults()
    
    private lazy var nutritionCalculator: NutritionCalculator = {
        return NutritionCalculator()
    }()
    
    // ✅ OPTIMIZACIÓN: Cache para evitar recálculos
    private var nutritionCache: [String: NutritionReport] = [:]
    private var recipesCache: [String: [Recipe]] = [:]
    
    // MARK: - Grocery List Integration
    @Published var groceryListViewModel = GroceryListViewModel()
    var cancellables = Set<AnyCancellable>()

    // MARK: - Init Optimizado

    init() {
        let stored = UserDefaults.standard.string(forKey: Self.selectedDietKey) ?? "Keto"
        selectedDiet = stored

        // ✅ OPTIMIZACIÓN: Solo setup básico en init
        setupDays()
        setupGroceryListSubscription()
        startRingAnimation()
        
        // ❌ REMOVIDO: Carga pesada movida a loadHeavyDataIfNeeded()
    }
    
    private func startRingAnimation() {
        Timer.publish(every: 0.016, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.ringRotation += 0.5
                if self?.ringRotation ?? 0 >= 360 {
                    self?.ringRotation = 0
                }
            }
            .store(in: &cancellables)
    }
    
    private func setupGroceryListSubscription() {
        groceryListViewModel.$groceryList
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                // Forzar actualización cuando cambie la grocery list
                self?.objectWillChange.send()
                print("📱 DietViewModel: Lista de compras actualizada")
            }
            .store(in: &cancellables)
    }

    // MARK: - Public Methods

    func select(day: Date) {
        selectedDay = day
    }

    func updateUserProfile(_ newProfile: UserProfile) async {
        userProfile = newProfile
        UserDefaults.standard.set(newProfile.dietType, forKey: Self.selectedDietKey)

        // Actualizar calculadora sin distribution
        nutritionCalculator = NutritionCalculator()

        selectedDiet = newProfile.dietType
        await loadNutritionData()
        await loadRecipesForSelectedDiet()
        updateGroceryList()
    }

    func recipes(for meal: MealType) -> [Recipe] {
        weeklyRecipes[selectedDay]?.filter { $0.mealType == meal } ?? []
    }

    func dayNumber(from date: Date) -> String {
        let components = calendar.dateComponents([.day], from: date)
        return "\(components.day ?? 0)"
    }

    // MARK: - Métodos nutricionales

    func getDailyCaloriesTarget() -> Double {
        return nutritionCalculator.generateNutritionReport().dailyCalories
    }

    func getMacroTargets() -> MacroTargets {
        return nutritionCalculator.generateNutritionReport().macros
    }

    func getMealDistribution() -> [MealType: Double] {
        return nutritionCalculator.generateNutritionReport().mealDistribution
    }

    func getConsumedCalories() -> [MealType: Int] {
        var consumed: [MealType: Int] = [:]

        for mealType in MealType.allCases {
            consumed[mealType] = recipes(for: mealType).reduce(0) { $0 + $1.calories }
        }

        return consumed
    }

    func getTotalDailyCalories() -> Int {
        getConsumedCalories().values.reduce(0, +)
    }

    func getCalorieProgress() -> Double {
        let consumed = Double(getTotalDailyCalories())
        let target = getDailyCaloriesTarget()
        return min(consumed / target, 1.0)
    }

    func calculateRecommendedWaterIntake() -> String {
        // ✅ CORREGIDO: Refrescar perfil del usuario para obtener datos más actualizados
        refreshUserProfile()
        
        // Calcular sin debug constante
        let result = nutritionCalculator.calculateWaterNeedsSynchronously(for: userProfile)
        return result
    }
    
    /// ✅ NUEVO: Método para refrescar el perfil del usuario
    private func refreshUserProfile() {
        userProfile = UserProfile.loadFromUserDefaults()
        // Log silenciado para evitar spam en consola
    }

    // MARK: - Grocery List Methods (Delegated)
    
    func toggleCheck(for ingredient: Ingredient) {
        print("🔄 DietViewModel: Delegando toggle para '\(ingredient.name)'")
        groceryListViewModel.toggleCheck(for: ingredient)
    }
    
    var groceryListText: String {
        groceryListViewModel.groceryListText(for: selectedDiet)
    }
    
    // Método de conveniencia para acceder a la lista
    var groceryList: [Ingredient] {
        groceryListViewModel.groceryList
    }
    
    // Contadores de la grocery list
    var groceryListCheckedCount: Int {
        groceryListViewModel.checkedCount
    }
    
    var groceryListTotalCount: Int {
        groceryListViewModel.totalCount
    }
    
    var groceryListUncheckedCount: Int {
        groceryListViewModel.uncheckedCount
    }
    
    var groceryListProgressText: String {
        groceryListViewModel.progressText
    }
    
    var groceryListCompletionText: String {
        groceryListViewModel.completionText
    }
    
    var groceryListCompletionPercentage: Double {
        groceryListViewModel.completionPercentage
    }
    
    var isGroceryListCompleted: Bool {
        groceryListViewModel.isCompleted
    }
    
    var isGroceryListEmpty: Bool {
        groceryListViewModel.isEmpty
    }

    // MARK: - Water Notifications

    // ✅ CORREGIDO: Agregar flag para evitar múltiples llamadas
    private var waterNotificationsStarted = false

    func startWaterRemindersThreeTimes() {
        print("🔧 DietViewModel: startWaterRemindersThreeTimes() llamado")
        
        // ✅ CORREGIDO: Verificar permisos primero
        NotificationWater.shared.checkNotificationPermissions { status in
            switch status {
            case .authorized, .provisional:
                self.proceedWithWaterNotifications()
            case .denied:
                print("❌ DietViewModel: Permisos de notificación denegados")
                // ✅ NUEVO: Intentar solicitar permisos nuevamente
                self.requestNotificationPermissions()
            case .notDetermined:
                print("❓ DietViewModel: Permisos de notificación no determinados")
                self.requestNotificationPermissions()
            case .ephemeral:
                print("⚠️ DietViewModel: Permisos de notificación efímeros")
                self.proceedWithWaterNotifications()
            @unknown default:
                print("❓ DietViewModel: Estado de permisos desconocido")
                self.requestNotificationPermissions()
            }
        }
    }
    
    // ✅ NUEVO: Método separado para solicitar permisos
    private func requestNotificationPermissions() {
        NotificationWater.shared.requestAuthorization { granted in
            if granted {
                print("✅ DietViewModel: Permisos concedidos, procediendo con notificaciones...")
                self.proceedWithWaterNotifications()
            } else {
                print("❌ DietViewModel: Permisos de notificación denegados definitivamente")
            }
        }
    }
    
    // ✅ NUEVO: Método separado para proceder con las notificaciones
    private func proceedWithWaterNotifications() {
        // ✅ CORREGIDO: Forzar limpieza y reprogramación siempre para asegurar valores actualizados
        print("🔄 DietViewModel: Forzando limpieza y reprogramación de notificaciones de agua...")
        waterNotificationsStarted = false // Reset flag
        
        // ✅ CORREGIDO: Limpieza completa antes de programar
        print("🧹 DietViewModel: Limpiando TODAS las notificaciones existentes...")
        NotificationWater.shared.forceCleanAndReset()
        
        // ✅ NUEVO: Debug del estado antes de programar
        NotificationWater.shared.debugNotificationStatus()
        
        let rec = calculateRecommendedWaterIntake()
        print("💧 DietViewModel: Programando notificaciones de agua con: \(rec)")
        
        let breakfast = DateComponents(hour: 9, minute: 0)
        let lunch     = DateComponents(hour: 13, minute: 0)
        let dinner    = DateComponents(hour: 19, minute: 0)
        
        NotificationWater.shared.scheduleThreeDailyReminders(
            at: [breakfast, lunch, dinner],
            dailyRecommendation: rec
        )
        
        // ✅ CORREGIDO: Marcar como iniciadas
        self.waterNotificationsStarted = true
        print("✅ DietViewModel: Notificaciones marcadas como iniciadas")
        
        // Verificación silenciosa tras programar
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            // Verificar estado sin logs (para evitar spam)
        }
    }

    func stopWaterRemindersThreeTimes() {
        NotificationWater.shared.cancelThreeDailyReminders()
        waterNotificationsStarted = false
    }
    
    /// Limpia todas las notificaciones existentes y las reprograma
    func resetWaterNotifications() {
        let rec = calculateRecommendedWaterIntake()
        NotificationWater.shared.resetAndRescheduleNotifications(dailyRecommendation: rec)
        waterNotificationsStarted = false
    }
    
    /// Verifica el estado de las notificaciones de agua
    func checkWaterNotificationStatus() {
        NotificationWater.shared.checkNotificationStatus()
    }
    
    /// ✅ NUEVO: Método para forzar actualización de notificaciones de agua
    func forceUpdateWaterNotifications() {
        print("🔄 DietViewModel: Forzando actualización de notificaciones de agua...")
        
        // Refrescar perfil antes de calcular
        refreshUserProfile()
        
        // Obtener el valor más actualizado
        let currentRecommendation = calculateRecommendedWaterIntake()
        print("💧 Recomendación actual: \(currentRecommendation)")
        
        // Limpiar y reprogramar con el valor correcto
        NotificationWater.shared.forceCleanAndReset()
        
        // Esperar un momento antes de reprogramar
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            let breakfast = DateComponents(hour: 9, minute: 0)
            let lunch     = DateComponents(hour: 13, minute: 0)
            let dinner    = DateComponents(hour: 19, minute: 0)
            
            NotificationWater.shared.scheduleThreeDailyReminders(
                at: [breakfast, lunch, dinner],
                dailyRecommendation: currentRecommendation
            )
            
            print("✅ Notificaciones de agua actualizadas con valor: \(currentRecommendation)")
        }
    }
    
    /// ✅ NUEVO: Método para verificar y corregir notificaciones de agua
    func verifyAndFixWaterNotifications() {
        print("🔍 DietViewModel: Verificando notificaciones de agua...")
        
        // Obtener el valor correcto
        let correctValue = calculateRecommendedWaterIntake()
        print("💧 Valor correcto de agua: \(correctValue)")
        
        // Forzar actualización
        forceUpdateWaterNotifications()
        
        // Verificar estado después de un momento
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            self.checkWaterNotificationStatus()
        }
    }
    
    /// ✅ NUEVO: Método de debug manual (solo llamar cuando sea necesario)
    func debugWaterCalculation() {
        refreshUserProfile()
        let result = nutritionCalculator.calculateWaterNeedsSynchronously(for: userProfile)
        print("🔍 DEBUG MANUAL - Cálculo de agua:")
        print("   📊 Peso usuario: \(userProfile.weightKg) kg")
        print("   📊 Actividad: \(userProfile.levelActivity)")
        print("   📊 Nivel workout: \(userProfile.workoutLevel)")
        print("   💧 Resultado: \(result)")
        userProfile.printAllValues()
    }

    // MARK: - Private Helpers

    private func setupDays() {
        let today = calendar.startOfDay(for: Date())
        let weekday = calendar.component(.weekday, from: today)
        let offset = (weekday == 1 ? -6 : 2 - weekday)
        guard let start = calendar.date(byAdding: .day, value: offset, to: today) else { return }
        days = (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: start) }
        selectedDay = days.first ?? today
    }

    private func loadNutritionData() async {
        isLoadingNutrition = true

        await MainActor.run {
            self.nutritionReport = self.nutritionCalculator.generateNutritionReport()
            self.isLoadingNutrition = false
        }
    }

    func loadRecipesForSelectedDiet() async {
        await loadRecipesWithCorrectCalories()
    }

    func organizeRecipesByDay(_ recipes: [Recipe]) -> [[Recipe]] {
        var days: [[Recipe]] = []
        let recipesPerDay = 3

        var currentDayRecipes: [Recipe] = []
        for (index, recipe) in recipes.enumerated() {
            currentDayRecipes.append(recipe)
            if (index + 1) % recipesPerDay == 0 {
                days.append(currentDayRecipes)
                currentDayRecipes = []
            }
        }

        if !currentDayRecipes.isEmpty {
            days.append(currentDayRecipes)
        }
        return days
    }

    private func updateGroceryList() {
        Task { @MainActor in
            self.groceryListViewModel.updateGroceryList(from: self.weeklyRecipes)
        }
    }

    // ✅ NUEVO: Método para carga pesada bajo demanda
    func loadHeavyDataIfNeeded() async {
        guard nutritionReport == nil else { return }
        
        await withTaskGroup(of: Void.self) { group in
            group.addTask { await self.loadNutritionData() }
            group.addTask { await self.loadRecipesWithCorrectCalories() }
            group.addTask { self.updateGroceryList() }
        }
    }

    // Método que ajusta recetas por día y por tipo de comida según el objetivo diario
    func loadRecipesWithCorrectCalories() async {
        let normalizedDiet = selectedDiet.lowercased().filter { $0.isLetter }
        print("🔄 CARGANDO DIETA CON AJUSTE POR COMIDA: \(normalizedDiet)")

        // 1. Obtener recetas base
        let baseRecipes: [Recipe]
        switch normalizedDiet {
        case "keto":
            baseRecipes = RecipesKeto.getWeeklyRecipes()
        case "lowcarb":
            baseRecipes = RecipesLowCarb.getWeeklyRecipes()
        case "caloriedeficit", "deficit":
            baseRecipes = RecipesDeficit.getWeeklyRecipes()
        default:
            baseRecipes = RecipesDeficit.getWeeklyRecipes()
        }

        // 2. Organizar recetas por día (7 días)
        let recipesPerDay = 3
        var dailyRecipes: [[Recipe]] = []
        var currentDayRecipes: [Recipe] = []
        for (index, recipe) in baseRecipes.enumerated() {
            currentDayRecipes.append(recipe)
            if (index + 1) % recipesPerDay == 0 {
                dailyRecipes.append(currentDayRecipes)
                currentDayRecipes = []
            }
        }
        if !currentDayRecipes.isEmpty {
            dailyRecipes.append(currentDayRecipes)
        }

        // 3. Ajustar las recetas de cada día individualmente, y por tipo de comida
        let targetDaily = getDailyCaloriesTarget()
        var adjustedWeeklyRecipes: [[Recipe]] = []

        for dayGroup in dailyRecipes {
            var adjustedDay: [Recipe] = []

            let distribution = getMealDistribution()
            let mealGroups = Dictionary(grouping: dayGroup, by: { $0.mealType })

            for mealType in MealType.allCases {
                guard let group = mealGroups[mealType] else { continue }

                // CORRECCIÓN CRÍTICA: distribution[mealType] ya es el valor en calorías, no un porcentaje
                let mealTargetCalories = distribution[mealType] ?? 0.0
                
                print("   • \(mealType.displayName) objetivo: \(Int(mealTargetCalories)) cal")
                
                let currentCalories = group.reduce(0) { $0 + $1.calories }
                let factor = currentCalories > 0 ? mealTargetCalories / Double(currentCalories) : 1.0

                let adjustedMeal = group.map { recipe -> Recipe in
                    let newCalories = Int((Double(recipe.calories) * factor).rounded())
                    let adjustedIngredients = recipe.ingredients.map { ingredient -> Ingredient in
                        let (qty, unit) = parseQuantitySimple(ingredient.quantity)
                        let newQty = qty * factor
                        let newQuantityString = formatQuantitySimple(newQty, unit: unit)

                        return Ingredient(
                            name: ingredient.name,
                            quantity: newQuantityString,
                            isChecked: ingredient.isChecked
                        )
                    }
                    return Recipe(
                        title: recipe.title,    
                        mealType: recipe.mealType,
                        imageName: recipe.imageName,
                        ingredients: adjustedIngredients,
                        instructions: recipe.instructions,
                        calories: newCalories
                    )
                }

                adjustedDay.append(contentsOf: adjustedMeal)
            }
            adjustedWeeklyRecipes.append(adjustedDay)
        }

        // 4. Asignar resultado en el hilo principal
        let result: [Date: [Recipe]] = {
            var dict: [Date: [Recipe]] = [:]
            for (i, day) in days.enumerated() {
                if i < adjustedWeeklyRecipes.count {
                    dict[day] = adjustedWeeklyRecipes[i]
                }
            }
            return dict
        }()
        await MainActor.run {
            self.weeklyRecipes = result
        }
    }
    
    // Parseo simple de cantidades
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
    
    // Formateo simple de cantidades
    private func formatQuantitySimple(_ value: Double, unit: String) -> String {
        let rounded = (value * 10).rounded() / 10
        
        if rounded.truncatingRemainder(dividingBy: 1) == 0 {
            return "\(Int(rounded))\(unit.isEmpty ? "" : " \(unit)")"
        } else {
            return String(format: "%.1f%@", rounded, unit.isEmpty ? "" : " \(unit)")
        }
    }
    
    // Verificar resultado final
    private func verifyFinalResult() {
        let target = getDailyCaloriesTarget()
        let actual = getTotalDailyCalories()
        let difference = actual - Int(target)
        
        print("📊 VERIFICACIÓN FINAL:")
        print("   • Objetivo: \(Int(target)) kcal")
        print("   • Actual: \(actual) kcal")
        print("   • Diferencia: \(difference) kcal")
        print("   • Estado: \(abs(difference) <= 50 ? "✅ CORRECTO" : "❌ NECESITA AJUSTE")")
    }

    // MARK: - Fix Temporal para Debug

    func debugCalorieIssue() async throws {
        print("🔍 DEBUGGING CALORIE ISSUE...")
        
        // 1. Verificar recetas base
        let baseRecipes = RecipesDeficit.getWeeklyRecipes()
        let baseTotal = baseRecipes.reduce(0) { $0 + $1.calories }
        let baseDailyAvg = Double(baseTotal) / 7.0
        
        print("📦 RECETAS BASE:")
        print("   • Total semanal: \(baseTotal) kcal")
        print("   • Promedio diario: \(Int(baseDailyAvg)) kcal")
        
        // 2. Verificar objetivo
        let target = getDailyCaloriesTarget()
        print("🎯 OBJETIVO: \(Int(target)) kcal/día")
        
        // 3. Calcular factor necesario
        let neededFactor = target / baseDailyAvg
        print("⚙️ FACTOR NECESARIO: \(String(format: "%.2f", neededFactor))")
        
        // 4. Verificar si NutritionCalculator está funcionando
        let adjustedByCalculator = try await nutritionCalculator.adjustRecipes(baseRecipes, for: userProfile)
        let adjustedTotal = adjustedByCalculator.reduce(0) { $0 + $1.calories }
        let adjustedDailyAvg = Double(adjustedTotal) / 7.0
        
        print("🔧 DESPUÉS DEL NUTRITION CALCULATOR:")
        print("   • Total semanal: \(adjustedTotal) kcal")
        print("   • Promedio diario: \(Int(adjustedDailyAvg)) kcal")
        print("   • Factor aplicado: \(String(format: "%.2f", adjustedDailyAvg / baseDailyAvg))")
        
        // 5. Verificar recetas específicas
        print("📋 EJEMPLOS DE RECETAS:")
        for i in 0..<min(3, baseRecipes.count) {
            let original = baseRecipes[i]
            let adjusted = adjustedByCalculator[i]
            print("   • \(original.title):")
            print("     - Original: \(original.calories) kcal")
            print("     - Ajustada: \(adjusted.calories) kcal")
        }
    }
}

// MARK: - Estructuras de Soporte

struct DaySummary {
    let date: Date
    let targetCalories: Double
    let consumedCalories: Double
    let remainingCalories: Double
    let progress: Double
    let mealSummaries: [MealType: MealSummary]
}

struct MealSummary {
    let type: MealType
    let targetCalories: Double
    let consumedCalories: Double
    let progress: Double
    
    var isComplete: Bool { progress >= 0.95 }
    var remainingCalories: Double { max(targetCalories - consumedCalories, 0) }
}

struct NutritionInfo {
    let dailyCalories: Int
    let protein: Double
    let fat: Double
    let carbs: Double
    let waterRecommendation: String
    
    var proteinCalories: Int { Int(protein * 4) }
    var fatCalories: Int { Int(fat * 9) }
    var carbCalories: Int { Int(carbs * 4) }
    
    var proteinPercentage: Double { Double(proteinCalories) / Double(dailyCalories) * 100 }
    var fatPercentage: Double { Double(fatCalories) / Double(dailyCalories) * 100 }
    var carbPercentage: Double { Double(carbCalories) / Double(dailyCalories) * 100 }
}

enum TargetStatus {
    case onTarget
    case underTarget(deficit: Double)
    case overTarget(surplus: Double)
    
    var message: String {
        switch self {
        case .onTarget:
            return "¡Perfecto! Estás en tu objetivo calórico"
        case .underTarget(let deficit):
            return "Te faltan \(Int(deficit)) calorías para tu objetivo"
        case .overTarget(let surplus):
            return "Has excedido tu objetivo por \(Int(surplus)) calorías"
        }
    }
    
    var color: Color {
        switch self {
        case .onTarget:
            return .green
        case .underTarget:
            return .orange
        case .overTarget:
            return .red
        }
    }
}

// MARK: - Extensiones de Soporte

extension DateFormatter {
    static let dayName: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "es_ES")
        formatter.dateFormat = "EEEE"
        return formatter
    }()
    
    static let shortDay: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "es_ES")
        formatter.dateFormat = "E"
        return formatter
    }()
}

// MARK: - Models (para referencia)

struct Recipe: Identifiable {
    let id = UUID()
    let title: String
    let mealType: MealType
    let imageName: String
    let ingredients: [Ingredient]
    let instructions: String
    let calories: Int
}

struct Ingredient: Identifiable, Equatable {
    let id = UUID()
    let name: String
    var quantity: String
    var isChecked: Bool = false

    static func == (lhs: Ingredient, rhs: Ingredient) -> Bool {
        lhs.id == rhs.id && lhs.isChecked == rhs.isChecked
    }
}

enum MealType: String, CaseIterable, Identifiable {
    case Breakfast, Lunch, Dinner
    var id: String { rawValue }
    var displayName: String {
        switch self {
        case .Breakfast: return LanguageManager.localizedString("Breakfast")
        case .Lunch:     return LanguageManager.localizedString("Lunch")
        case .Dinner:    return LanguageManager.localizedString("Dinner")
        }
    }
}

// MARK: - Fix Temporal - Forzar Ajuste Correcto

extension DietViewModel {
    
    // Método que ajusta recetas por día y por tipo de comida según el objetivo diario
    func printCalorieSummary() {
        print("🔎 Resumen Calórico Diario Detallado")
        for day in days {
            guard let recipes = weeklyRecipes[day] else {
                print("📅 Día \(day): No hay recetas")
                continue
            }
            let totalDay = recipes.reduce(0) { $0 + $1.calories }
            print("📅 Día \(day): Total kcal = \(totalDay)")

            let grouped = Dictionary(grouping: recipes, by: { $0.mealType })
            for meal in MealType.allCases {
                let cal = grouped[meal]?.reduce(0) { $0 + $1.calories } ?? 0
                print("   • \(meal.displayName): \(cal) kcal")
            }
        }
    }
}
