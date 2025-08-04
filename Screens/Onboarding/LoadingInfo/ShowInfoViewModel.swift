import SwiftUI
import Foundation

// MARK: - Supporting Structures
struct ExpectedTimeline {
    let firstResults: String
    let goalAchievement: String
    let scienceNote: String
}

struct NutritionSummary {
    let dailyCalories: Double
    let dailyWater: String
    let protein: Double
    let carbs: Double
    let fat: Double
    let weeklyWeightChange: Double
    let successProbability: Double
}

// MARK: - Enhanced ShowInfoViewModel
@MainActor
class ShowInfoViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var isGeneratingPlan = true
    @Published var showResults = false
    @Published var isPulsing = false
    @Published var currentStep = "Initializing AI Analysis..."
    @Published var currentStepIndex = 0
    @Published var progress: Double = 0.0
    @Published var error: String?
    
    // MARK: - Core Data
    @Published var nutritionSummary: NutritionSummary?
    @Published var scientificResults: ScientificResults?
    @Published var expectedTimeline = ExpectedTimeline(
        firstResults: "2-3 weeks",
        goalAchievement: "3-6 months",
        scienceNote: "Based on your profile and goals"
    )
    
    // MARK: - Computed Properties for UI Compatibility
    var dailyCalories: Double {
        nutritionSummary?.dailyCalories ?? 0
    }
    
    var dailyWater: String {
        nutritionSummary?.dailyWater ?? calculateWaterIntake()
    }
    
    // MARK: - Private Properties
    private var analysisTimer: Timer?
    private var progressTimer: Timer?
    let totalSteps = 6
    
    // ✅ CORREGIDO: Inicialización directa y robusta
    private var userProfile: UserProfile
    private let nutritionCalculator: NutritionCalculator
    private var resultSoon: ResultSoon?
    
    // MARK: - Public Properties for UI Access
    var currentUserProfile: UserProfile? {
        return self.userProfile
    }
    
    // MARK: - Analysis Steps
    private let analysisSteps = [
        "Analyzing your body composition...",
        "Calculating metabolic rate...",
        "Optimizing nutrition plan...",
        "Generating workout recommendations...",
        "Creating personalized timeline...",
        "Finalizing your plan..."
    ]
    
    // MARK: - Initialization
    init(
        nutritionCalculator: NutritionCalculator? = nil,
        resultSoon: ResultSoon? = nil
    ) {
        // ✅ CORREGIDO: Inicialización robusta con fallback
        self.userProfile = UserProfile.loadFromUserDefaults()
        self.nutritionCalculator = nutritionCalculator ?? NutritionCalculator()
        self.resultSoon = resultSoon
        
        // Verificar que userProfile se inicialice correctamente
        print("🔬 SHOWINFO - Inicializando ViewModel...")
        print("   • Peso: \(userProfile.weightKg) kg")
        print("   • Altura: \(userProfile.heightCm ?? 0) cm")
        print("   • Meta: \(userProfile.goal)")
        
        // ✅ CORREGIDO: Iniciar animación inmediatamente
        startPulsingAnimation()
    }
    
    // ✅ CORREGIDO: Mover cleanupTimers fuera de deinit
    func cleanup() {
        cleanupTimers()
    }
    
    // MARK: - Public Methods
    func loadUserData() {
        print("📱 SHOWINFO - Cargando datos de usuario...")
        userProfile = UserProfile.loadFromUserDefaults()
        print("📱 SHOWINFO - Datos cargados:")
        print("   • Peso: \(userProfile.weightKg) kg")
        print("   • Altura: \(userProfile.heightCm ?? 0) cm")
        print("   • Meta: '\(userProfile.goal)'")
        print("   • Dieta: '\(userProfile.dietType)'")
        print("   • Actividad: '\(userProfile.levelActivity)'")
        print("   • Nivel entrenamiento: '\(userProfile.workoutLevel)'")
    }
    
    // MARK: - Validation Methods
    private func validateUserProfile() -> Bool {
        let isValid = userProfile.weightKg > 0 && 
                     userProfile.heightCm != nil && 
                     userProfile.heightCm! > 0 &&
                     !userProfile.goal.isEmpty
        
        if !isValid {
            print("❌ SHOWINFO - userProfile inválido:")
            print("   • Peso: \(userProfile.weightKg)")
            print("   • Altura: \(userProfile.heightCm ?? -1)")
            print("   • Meta: '\(userProfile.goal)'")
        }
        
        return isValid
    }
    
    func calculateResults() {
        print("🔬 SHOWINFO - Calculando resultados...")
        loadUserData()
        
        // Crear ResultSoon de manera segura
        let resultSoon = ResultSoon(userProfile: userProfile)
        let scientificResults = resultSoon.calculateScientificResults()
        
        // Generar reporte nutricional
        let nutritionReport = nutritionCalculator.generateNutritionReport()
        
        // Crear resumen nutricional
        let summary = NutritionSummary(
            dailyCalories: Double(scientificResults.dailyCalorieTarget),
            dailyWater: calculateWaterIntake(),
            protein: nutritionReport.macros.protein,
            carbs: nutritionReport.macros.carbs,
            fat: nutritionReport.macros.fat,
            weeklyWeightChange: scientificResults.weeklyWeightChange,
            successProbability: scientificResults.successProbability
        )
        
        // Actualizar UI
        self.nutritionSummary = summary
        self.scientificResults = scientificResults
        
        print("✅ SHOWINFO - Resultados calculados exitosamente")
    }
    
    // MARK: - Private Methods
    private func startPulsingAnimation() {
        withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
            isPulsing = true
        }
    }
    
    private func startProgressTimer() {
        print("📊 SHOWINFO - Iniciando timer de progreso...")
        progressTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self else { 
                print("❌ SHOWINFO - Self es nil en progress timer")
                return 
            }
            
            Task { @MainActor in
                if self.progress < 1.0 {
                    self.progress += 0.01
                    if Int(self.progress * 100) % 10 == 0 {
                        print("📊 SHOWINFO - Progreso: \(Int(self.progress * 100))%")
                    }
                } else {
                    print("📊 SHOWINFO - Progreso completado al 100%")
                    self.progressTimer?.invalidate()
                    self.progressTimer = nil
                }
            }
        }
    }
    
    private func startAnalysisTimer() {
        print("⏰ SHOWINFO - Iniciando timer de análisis...")
        analysisTimer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: true) { [weak self] _ in
            guard let self = self else { 
                print("❌ SHOWINFO - Self es nil en timer")
                return 
            }
            
            Task { @MainActor in
                print("⏰ SHOWINFO - Timer tick: \(self.currentStepIndex + 1)/\(self.analysisSteps.count)")
                if self.currentStepIndex < self.analysisSteps.count - 1 {
                    self.currentStepIndex += 1
                    self.currentStep = self.analysisSteps[self.currentStepIndex]
                    print("⏰ SHOWINFO - Paso actualizado: \(self.currentStep)")
                } else {
                    print("⏰ SHOWINFO - Análisis completado, llamando completeAnalysis()")
                    self.completeAnalysis()
                }
            }
        }
    }
    
    private func completeAnalysis() {
        analysisTimer?.invalidate()
        analysisTimer = nil
        
        // ✅ CORREGIDO: Asegurar que tenemos datos válidos antes de mostrar resultados
        if nutritionSummary == nil || scientificResults == nil {
            print("⚠️ SHOWINFO - Datos no disponibles, creando fallback...")
            createFallbackData()
        }
        
        // Show results with animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.easeInOut(duration: 0.8)) {
                self.isGeneratingPlan = false
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.spring(response: 0.8, dampingFraction: 0.8)) {
                    self.showResults = true
                }
            }
        }
    }
    
    // ✅ CORREGIDO: Método de fallback mejorado para asegurar que siempre tengamos datos
    private func createFallbackData() {
        print("🔄 SHOWINFO - Creando datos de fallback...")
        
        // Crear datos básicos de nutrición
        let fallbackSummary = NutritionSummary(
            dailyCalories: 2000.0,
            dailyWater: "2.5L",
            protein: 150.0,
            carbs: 200.0,
            fat: 70.0,
            weeklyWeightChange: -0.5,
            successProbability: 0.75
        )
        
        // Crear resultados científicos básicos
        let fallbackResults = ScientificResults(
            targetWeight: userProfile.weightKg - 5.0,
            estimatedTimeToTarget: 60,
            weeklyWeightChange: -0.5,
            monthlyWeightChange: -2.0,
            muscleGain: 0.5,
            fatLoss: 2.5,
            dailyCalorieTarget: 2000,
            successProbability: 0.75,
            recommendations: [
                "Follow your personalized nutrition plan",
                "Stay consistent with your workout routine",
                "Monitor your progress weekly"
            ],
            milestones: [
                Milestone(day: 7, description: "First week completed", expectedWeight: userProfile.weightKg - 0.5, motivation: "Great start!"),
                Milestone(day: 30, description: "First month milestone", expectedWeight: userProfile.weightKg - 2.0, motivation: "Keep going strong!")
            ]
        )
        
        self.nutritionSummary = fallbackSummary
        self.scientificResults = fallbackResults
        self.calculateSimpleTimeline()
        
        print("✅ SHOWINFO - Datos de fallback creados exitosamente")
    }
    
    // ✅ CORREGIDO: Usar el nuevo sistema científico con manejo robusto de errores
    private func performRealCalculations() async {
        print("🔬 SHOWINFO - Iniciando cálculos científicos...")
        
        // Verificar que userProfile esté inicializado correctamente
        guard validateUserProfile() else {
            print("❌ Error: userProfile no tiene datos válidos")
            await MainActor.run {
                self.error = "Error: Datos de usuario no válidos"
                self.createFallbackData()
            }
            return
        }
        
        // ✅ CORREGIDO: Crear ResultSoon con el userProfile actual y probar
        print("🔬 SHOWINFO - Creando ResultSoon...")
        let resultSoon = ResultSoon(userProfile: userProfile)
        
        // ✅ CORREGIDO: Probar el cálculo antes de usarlo
        guard resultSoon.testCalculation() else {
            print("❌ Error: ResultSoon falló en la prueba")
            await MainActor.run {
                self.error = "Error: Fallo en cálculos científicos"
                self.createFallbackData()
            }
            return
        }
        
        print("🔬 SHOWINFO - Calculando resultados científicos...")
        let scientificResults = resultSoon.calculateScientificResults()
        print("🔬 SHOWINFO - Resultados científicos calculados exitosamente")
        
        // ✅ CORREGIDO: Usar el mismo método que DietViewModel para consistencia
        print("🔬 SHOWINFO - Generando reporte nutricional...")
        let nutritionReport = nutritionCalculator.generateNutritionReport()
        let calories = nutritionReport.dailyCalories
        let macros = nutritionReport.macros
        let water = nutritionReport.waterNeeds
        print("🔬 SHOWINFO - Reporte nutricional generado")
        
        // Crear resumen nutricional
        let summary = NutritionSummary(
            dailyCalories: Double(scientificResults.dailyCalorieTarget),
            dailyWater: calculateWaterIntake(),
            protein: macros.protein,
            carbs: macros.carbs,
            fat: macros.fat,
            weeklyWeightChange: scientificResults.weeklyWeightChange,
            successProbability: scientificResults.successProbability
        )
        
        // Actualizar UI en main thread
        await MainActor.run {
            self.nutritionSummary = summary
            self.scientificResults = scientificResults
            self.calculateSimpleTimeline()
            
            print("🔬 SHOWINFO - CÁLCULOS CIENTÍFICOS COMPLETADOS:")
            print("   • Peso objetivo: \(String(format: "%.1f", scientificResults.targetWeight)) kg")
            print("   • Tiempo al objetivo: \(scientificResults.adjustedTimeToTarget) días")
            print("   • Cambio semanal: \(String(format: "%.2f", scientificResults.weeklyWeightChange)) kg")
            print("   • Calorías diarias: \(scientificResults.dailyCalorieTarget) kcal")
            print("   • Probabilidad éxito: \(Int(scientificResults.successProbability * 100))%")
            print("   • Plan realista: \(scientificResults.isRealistic)")
        }
    }
    
    private func calculateWaterIntake() -> String {
        return nutritionCalculator.calculateWaterNeedsSynchronously(for: userProfile)
    }
    
    private func calculateSimpleSuccessProbability() -> Double {
        let goal = userProfile.goal.lowercased()
        let activity = userProfile.levelActivity.lowercased()
        
        var probability = 0.7 // Base 70%
        
        // Ajustar por actividad
        if activity.contains("active") || activity.contains("moderate") {
            probability += 0.1
        }
        
        // Ajustar por objetivo
        if goal.contains("mantener") || goal.contains("maintain") {
            probability += 0.1
        } else if goal.contains("perder") && activity.contains("active") {
            probability += 0.05
        }
        
        return min(probability, 0.95)
    }
    
    private func calculateSimpleWeightChange() -> Double {
        let goal = userProfile.goal.lowercased()
        let activityLevel = userProfile.levelActivity.lowercased()
        
        var baseChange = 0.5 // kg por semana
        
        if goal.contains("perder") || goal.contains("adelgazar") {
            baseChange = -0.5
        } else if goal.contains("ganar") || goal.contains("musculo") {
            baseChange = 0.3
        } else {
            baseChange = 0.0
        }
        
        // Ajustar por actividad
        if activityLevel.contains("very active") {
            baseChange *= 1.2
        } else if activityLevel.contains("active") {
            baseChange *= 1.1
        }
        
        return baseChange
    }
    
    // ✅ SIMPLIFICADO: Timeline básico sin ResultSoon
    private func calculateSimpleTimeline() {
        let goal = userProfile.goal.lowercased()
        let dietType = userProfile.dietType.lowercased()
        
        var firstResultsDays = 7
        var goalWeeks = 8
        
        // Ajuste por tipo de dieta
        if dietType.contains("keto") {
            firstResultsDays = 3
            goalWeeks = 6
        } else if dietType.contains("bajo") && dietType.contains("carb") {
            firstResultsDays = 5
            goalWeeks = 7
        }
        
        let scienceNote: String
        if goal.contains("perder") || goal.contains("adelgazar") {
            scienceNote = "Your caloric deficit plan creates sustainable fat loss through metabolic optimization."
        } else if goal.contains("ganar") || goal.contains("musculo") {
            scienceNote = "Muscle protein synthesis accelerates with your high-protein nutrition plan."
        } else {
            scienceNote = "Your balanced approach maintains optimal body composition and health."
        }
        
        expectedTimeline = ExpectedTimeline(
            firstResults: "\(firstResultsDays) days",
            goalAchievement: "\(goalWeeks) weeks",
            scienceNote: scienceNote
        )
    }
    
    private func cleanupTimers() {
        analysisTimer?.invalidate()
        analysisTimer = nil
        progressTimer?.invalidate()
        progressTimer = nil
    }
    
    // MARK: - Additional Utility Methods
    
    /// Obtiene un resumen rápido para mostrar en UI
    func getQuickSummary() -> String? {
        guard let scientificResults = scientificResults else { return nil }
        
        let goal = userProfile.goal.lowercased()
        let changeDirection = goal.contains("perder") ? "lose" : goal.contains("ganar") ? "gain" : "maintain"
        let timeFrame = scientificResults.adjustedTimeToTarget <= 30 ? "\(scientificResults.adjustedTimeToTarget) days" : "\(scientificResults.adjustedTimeToTarget / 30) months"
        
        return """
        🎯 Target: \(String(format: "%.1f", scientificResults.targetWeight))kg (\(changeDirection) \(String(format: "%.1f", abs(scientificResults.targetWeight - userProfile.weightKg)))kg)
        ⏱️ Timeline: \(timeFrame)
        📊 Weekly change: \(String(format: "%.2f", abs(scientificResults.weeklyWeightChange)))kg
        💪 Muscle gain: \(String(format: "%.1f", scientificResults.muscleGain))kg/month
        🔥 Daily calories: \(scientificResults.dailyCalorieTarget)
        ✅ Success rate: \(Int(scientificResults.successProbability * 100))%
        """
    }
    
    /// Verifica si el plan es factible
    func isPlanFeasible() -> Bool {
        guard let scientificResults = scientificResults else { return true }
        return scientificResults.isRealistic && scientificResults.successProbability > 0.6
    }
    
    /// Obtiene recomendaciones adicionales
    func getAdditionalRecommendations() -> [String] {
        guard let scientificResults = scientificResults else { return [] }
        
        var recommendations: [String] = []
        
        if !scientificResults.isRealistic {
            recommendations.append("Consider adjusting your timeline for more realistic progress")
        }
        
        if scientificResults.successProbability < 0.6 {
            recommendations.append("Plan may be challenging - consider gradual adjustments")
        }
        
        if scientificResults.dailyCalorieTarget < 1200 {
            recommendations.append("Plan includes minimum safe calorie intake")
        }
        
        if abs(scientificResults.weeklyWeightChange) > 1.0 {
            recommendations.append("Rapid progress planned - monitor closely")
        }
        
        if scientificResults.muscleGain > 2.0 {
            recommendations.append("High muscle gain potential - ensure proper recovery")
        }
        
        return recommendations
    }
}

// MARK: - Extensions for UI Compatibility
extension ShowInfoViewModel {
    
    /// Compatibilidad con UI existente
    var formattedCalories: String {
        guard let summary = nutritionSummary else { return "Calculating..." }
        return "\(Int(summary.dailyCalories))"
    }
    
    var formattedWater: String {
        guard let summary = nutritionSummary else { return "Calculating..." }
        return summary.dailyWater
    }
    
    var formattedMacros: String {
        guard let summary = nutritionSummary else { return "Calculating..." }
        return "\(Int(summary.protein))g protein • \(Int(summary.carbs))g carbs • \(Int(summary.fat))g fat"
    }
    
    var progressIndicator: String {
        guard let scientificResults = scientificResults else { return "🔄 Analyzing..." }
        
        let probability = scientificResults.successProbability
        if probability > 0.8 && scientificResults.isRealistic {
            return "🚀 Excellent plan"
        } else if probability > 0.6 {
            return "💪 Good plan"
        } else {
            return "⚠️ Challenging plan"
        }
    }
}

// MARK: - Factory Extension para fácil inicialización
extension ShowInfoViewModel {
    
    /// Factory method simple
    static func make() -> ShowInfoViewModel {
        return ShowInfoViewModel()
    }
    
    /// Factory method para testing
    static func makeForTesting(
        nutritionCalculator: NutritionCalculator
    ) -> ShowInfoViewModel {
        return ShowInfoViewModel(
            nutritionCalculator: nutritionCalculator,
            resultSoon: nil
        )
    }
}
