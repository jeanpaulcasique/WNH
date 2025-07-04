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
    
    // ✅ CORREGIDO: Usar clases directamente sin containers
    private lazy var userProfile: UserProfile = {
        return UserProfile.loadFromUserDefaults()
    }()
    
    private let nutritionCalculator: NutritionCalculator
    private var resultSoon: ResultSoon?
    
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
        // ✅ Usar clases directamente
        self.nutritionCalculator = nutritionCalculator ?? NutritionCalculator()
        self.resultSoon = resultSoon
        
        startPulsingAnimation()
    }
    
    // ✅ CORREGIDO: Mover cleanupTimers fuera de deinit
    func cleanup() {
        cleanupTimers()
    }
    
    // MARK: - Public Methods
    func loadUserData() {
        userProfile = UserProfile.loadFromUserDefaults()
    }
    
    func startAnalysis() {
        error = nil
        startProgressTimer()
        startAnalysisTimer()
        
        // ✅ Iniciar cálculos reales en background
        Task {
            await performRealCalculations()
        }
    }
    
    // MARK: - Private Methods
    private func startPulsingAnimation() {
        withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
            isPulsing = true
        }
    }
    
    private func startProgressTimer() {
        progressTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            Task { @MainActor in
                if self.progress < 1.0 {
                    self.progress += 0.01
                } else {
                    self.progressTimer?.invalidate()
                    self.progressTimer = nil
                }
            }
        }
    }
    
    private func startAnalysisTimer() {
        analysisTimer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            Task { @MainActor in
                if self.currentStepIndex < self.analysisSteps.count - 1 {
                    self.currentStepIndex += 1
                    self.currentStep = self.analysisSteps[self.currentStepIndex]
                } else {
                    self.completeAnalysis()
                }
            }
        }
    }
    
    private func completeAnalysis() {
        analysisTimer?.invalidate()
        analysisTimer = nil
        
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
    
    // ✅ SIMPLIFICADO: Usar solo NutritionCalculator por ahora
    private func performRealCalculations() async {
        do {
            print("🎯 SHOWINFO - Iniciando cálculos reales...")
            
            // ✅ CORREGIDO: Usar el mismo método que DietViewModel para consistencia
            let nutritionReport = nutritionCalculator.generateNutritionReport()
            let calories = nutritionReport.dailyCalories
            let macros = nutritionReport.macros
            let water = nutritionReport.waterNeeds
            
            // Usar ResultSoon si está disponible
            var weeklyWeightChange = calculateSimpleWeightChange()
            var successProbability = calculateSimpleSuccessProbability()
            
            if let resultSoon = self.resultSoon {
                let shortTermResults = resultSoon.calculateShortTermResults(for: userProfile)
                weeklyWeightChange = shortTermResults.totalWeightChange / 4.0
                successProbability = resultSoon.calculateSuccessProbability(for: userProfile, results: shortTermResults)
            }
            
            // Crear resumen nutricional
            let summary = NutritionSummary(
                dailyCalories: calories,
                dailyWater: calculateWaterIntake(),
                protein: macros.protein,
                carbs: macros.carbs,
                fat: macros.fat,
                weeklyWeightChange: weeklyWeightChange,
                successProbability: successProbability
            )
            
            // Actualizar UI en main thread
            await MainActor.run {
                self.nutritionSummary = summary
                self.calculateSimpleTimeline()
                
                print("🎯 SHOWINFO - CÁLCULOS COMPLETADOS:")
                print("   • Calorías diarias: \(Int(calories)) kcal")
                print("   • Agua diaria: \(String(format: "%.1f", water)) L")
                print("   • Proteína: \(Int(macros.protein))g")
                print("   • Cambio semanal: \(String(format: "%.1f", weeklyWeightChange))kg")
                print("   • Probabilidad éxito: \(Int(successProbability * 100))%")
            }
            
        } catch {
            await MainActor.run {
                self.error = "Error al calcular plan: \(error.localizedDescription)"
                print("❌ Error en ShowInfoViewModel: \(error)")
            }
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
        guard let summary = nutritionSummary else { return nil }
        
        let goal = userProfile.goal.lowercased()
        let changeDirection = goal.contains("perder") ? "lose" : goal.contains("ganar") ? "gain" : "maintain"
        
        return """
        📊 Your personalized plan targets \(String(format: "%.1f", abs(summary.weeklyWeightChange)))kg weekly \(changeDirection)
        🎯 Success probability: \(Int(summary.successProbability * 100))%
        🔥 Daily intake: \(Int(summary.dailyCalories)) calories
         Hydration goal: \(summary.dailyWater)
        """
    }
    
    /// Verifica si el plan es factible
    func isPlanFeasible() -> Bool {
        guard let summary = nutritionSummary else { return true }
        return summary.successProbability > 0.6
    }
    
    /// Obtiene recomendaciones adicionales
    func getAdditionalRecommendations() -> [String] {
        guard let summary = nutritionSummary else { return [] }
        
        var recommendations: [String] = []
        
        if summary.successProbability < 0.6 {
            recommendations.append("Consider adjusting your timeline for better success rate")
        }
        
        if summary.dailyCalories < 1200 {
            recommendations.append("Plan includes minimum safe calorie intake")
        }
        
        if summary.weeklyWeightChange > 1.0 {
            recommendations.append("Rapid progress planned - monitor closely")
        }
        
        if summary.protein > summary.dailyCalories * 0.35 / 4 {
            recommendations.append("High-protein approach for muscle preservation")
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
        guard let summary = nutritionSummary else { return "🔄 Analyzing..." }
        
        let probability = summary.successProbability
        if probability > 0.8 {
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
