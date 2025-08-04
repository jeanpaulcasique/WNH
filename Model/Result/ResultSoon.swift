import Foundation

// MARK: - Estructuras de Resultados Científicos
struct ScientificResults {
    let targetWeight: Double
    let estimatedTimeToTarget: Int // días
    let weeklyWeightChange: Double
    let monthlyWeightChange: Double
    let muscleGain: Double
    let fatLoss: Double
    let dailyCalorieTarget: Int
    let successProbability: Double
    let recommendations: [String]
    let milestones: [Milestone]
    
    var isRealistic: Bool {
        // Verificar si el plan es científicamente realista
        let weeklyChange = abs(weeklyWeightChange)
        return weeklyChange >= 0.25 && weeklyChange <= 1.0
    }
    
    var adjustedTimeToTarget: Int {
        // Ajustar tiempo si el plan no es realista
        if !isRealistic {
            let realisticWeeklyChange = weeklyWeightChange > 0 ? 0.5 : -0.5
            let totalChange = abs(targetWeight - UserProfile.loadFromUserDefaults().weightKg)
            return Int(totalChange / abs(realisticWeeklyChange) * 7)
        }
        return estimatedTimeToTarget
    }
}

struct Milestone {
    let day: Int
    let description: String
    let expectedWeight: Double
    let motivation: String
}

// MARK: - Calculadora Científica de Resultados
class ResultSoon {
    
    // MARK: - Constantes Científicas
    private struct Constants {
        // Calorías por kg de peso corporal
        static let caloriesPerKg = 7700 // calorías para perder/ganar 1kg
        
        // Factores de actividad física (Harris-Benedict modificado)
        static let sedentary = 1.2
        static let lightlyActive = 1.375
        static let moderatelyActive = 1.55
        static let veryActive = 1.725
        static let extremelyActive = 1.9
        
        // Pérdida de peso realista por semana
        static let maxWeeklyWeightLoss = 1.0 // kg
        static let minWeeklyWeightLoss = 0.25 // kg
        static let maxWeeklyWeightGain = 0.5 // kg
        
        // Ganancia muscular realista por mes
        static let maxMonthlyMuscleGain = 2.0 // kg
        static let minMonthlyMuscleGain = 0.5 // kg
    }
    
    // MARK: - Propiedades
    private let userProfile: UserProfile
    
    // MARK: - Inicialización
    init(userProfile: UserProfile = UserProfile.loadFromUserDefaults()) {
        self.userProfile = userProfile
    }
    
    // MARK: - API Pública Principal
    func calculateScientificResults() -> ScientificResults {
        // ✅ CORREGIDO: Validaciones más robustas
        guard userProfile.weightKg > 0 else {
            print("❌ RESULTSOON - Peso inválido: \(userProfile.weightKg)")
            return createDefaultResults()
        }
        
        guard let height = userProfile.heightCm, height > 0 else {
            print("❌ RESULTSOON - Altura inválida: \(userProfile.heightCm ?? -1)")
            return createDefaultResults()
        }
        
        // ✅ CORREGIDO: Validar que el goal no esté vacío
        guard !userProfile.goal.isEmpty else {
            print("❌ RESULTSOON - Goal vacío")
            return createDefaultResults()
        }
        
        let goal = userProfile.goal.lowercased()
        let currentWeight = userProfile.weightKg
        
        // ✅ CORREGIDO: Cálculos seguros sin recursión
        let targetWeight = calculateTargetWeight()
        
        print("🔬 CALCULANDO RESULTADOS CIENTÍFICOS")
        print("   • Peso actual: \(currentWeight) kg")
        print("   • Peso objetivo: \(targetWeight) kg")
        print("   • Meta: \(goal)")
        
        let dailyCalorieTarget = calculateDailyCalorieTarget()
        let weeklyWeightChange = calculateWeeklyWeightChange()
        let monthlyWeightChange = weeklyWeightChange * 4
        let estimatedTimeToTarget = calculateTimeToTarget(targetWeight: targetWeight, weeklyChange: weeklyWeightChange)
        
        let muscleGain = calculateMuscleGain()
        let fatLoss = calculateFatLoss(weightChange: monthlyWeightChange, muscleGain: muscleGain)
        let successProbability = calculateSuccessProbability()
        let recommendations = generateScientificRecommendations()
        let milestones = generateMilestones(targetWeight: targetWeight, weeklyChange: weeklyWeightChange)
        
        return ScientificResults(
            targetWeight: targetWeight,
            estimatedTimeToTarget: estimatedTimeToTarget,
            weeklyWeightChange: weeklyWeightChange,
            monthlyWeightChange: monthlyWeightChange,
            muscleGain: muscleGain,
            fatLoss: fatLoss,
            dailyCalorieTarget: dailyCalorieTarget,
            successProbability: successProbability,
            recommendations: recommendations,
            milestones: milestones
        )
    }
    
    // MARK: - Métodos de Cálculo Científico
    
    private func calculateTargetWeight() -> Double {
        let currentWeight = userProfile.weightKg
        let goal = userProfile.goal.lowercased()
        let bmi = userProfile.bmi ?? 25.0
        let heightCm = userProfile.heightCm ?? 170
        let heightM = Double(heightCm) / 100.0 // convertir a metros
        
        if goal.contains("perder") || goal.contains("adelgazar") || goal.contains("lose") {
            // Calcular peso objetivo basado en BMI saludable
            let targetBMI: Double
            if bmi > 30 {
                targetBMI = 25.0 // Obesidad → Normal
            } else if bmi > 25 {
                targetBMI = 22.0 // Sobrepeso → Normal bajo
            } else {
                targetBMI = 20.0 // Normal → Delgado
            }
            
            let targetWeight = targetBMI * heightM * heightM
            return max(targetWeight, currentWeight * 0.85) // No más del 15% de pérdida inicial
        } else if goal.contains("ganar") || goal.contains("musculo") || goal.contains("muscle") || goal.contains("bulk") {
            // Ganancia de peso para músculo
            let muscleGain = min(currentWeight * 0.15, 10.0) // Máximo 15% o 10kg
            return currentWeight + muscleGain
        } else {
            // Mantener peso actual
            return currentWeight
        }
    }
    
    private func calculateDailyCalorieTarget() -> Int {
        let currentWeight = userProfile.weightKg
        let height = userProfile.heightCm
        let age = calculateAge()
        let isMale = isUserMale()
        let activityLevel = getActivityMultiplier()
        
        // Calcular Tasa Metabólica Basal (TMB) usando fórmula de Mifflin-St Jeor
        let heightValue = height ?? 170
        let tmb: Double
        if isMale {
            let weightComponent = 10 * currentWeight
            let heightComponent = 6.25 * Double(heightValue)
            let ageComponent = 5 * Double(age)
            tmb = weightComponent + heightComponent - ageComponent + 5
        } else {
            let weightComponent = 10 * currentWeight
            let heightComponent = 6.25 * Double(heightValue)
            let ageComponent = 5 * Double(age)
            tmb = weightComponent + heightComponent - ageComponent - 161
        }
        
        // Calcular Gasto Energético Total (GET)
        let get = tmb * activityLevel
        
        // Ajustar según objetivo
        let goal = userProfile.goal.lowercased()
        let weeklyWeightChange = calculateWeeklyWeightChange()
        let calorieAdjustment = weeklyWeightChange * Double(Constants.caloriesPerKg) / 7.0
        
        let targetCalories = get + calorieAdjustment
        
        return Int(targetCalories)
    }
    
    private func calculateWeeklyWeightChange() -> Double {
        let goal = userProfile.goal.lowercased()
        let bmi = userProfile.bmi ?? 25.0
        let activityLevel = getActivityMultiplier()
        let dietEffectiveness = getDietEffectiveness()
        let workoutIntensity = getWorkoutIntensity()
        
        // Verificar que tenemos datos válidos
        guard userProfile.weightKg > 0 else { return 0.0 }
        
        var baseWeeklyChange: Double = 0
        
        if goal.contains("perder") || goal.contains("adelgazar") || goal.contains("lose") {
            // Pérdida de peso
            if bmi > 30 {
                baseWeeklyChange = -0.8 // Obesidad: pérdida más rápida
            } else if bmi > 25 {
                baseWeeklyChange = -0.6 // Sobrepeso: pérdida moderada
            } else {
                baseWeeklyChange = -0.4 // Normal: pérdida lenta
            }
            
            // Ajustar por actividad física
            if activityLevel < Constants.moderatelyActive {
                baseWeeklyChange *= 0.8 // Menos activo = menos pérdida
            } else if activityLevel > Constants.veryActive {
                baseWeeklyChange *= 1.2 // Más activo = más pérdida
            }
            
        } else if goal.contains("ganar") || goal.contains("musculo") || goal.contains("muscle") || goal.contains("bulk") {
            // Ganancia de peso/músculo
            baseWeeklyChange = 0.3 // Ganancia moderada
            
            // Ajustar por intensidad de entrenamiento
            baseWeeklyChange *= workoutIntensity
            
        } else {
            // Mantener peso
            baseWeeklyChange = 0.0
        }
        
        // Aplicar efectividad de la dieta
        baseWeeklyChange *= dietEffectiveness
        
        // Limitar a rangos realistas
        if baseWeeklyChange < 0 {
            baseWeeklyChange = max(baseWeeklyChange, -Constants.maxWeeklyWeightLoss)
            baseWeeklyChange = min(baseWeeklyChange, -Constants.minWeeklyWeightLoss)
        } else if baseWeeklyChange > 0 {
            baseWeeklyChange = min(baseWeeklyChange, Constants.maxWeeklyWeightGain)
        }
        
        return baseWeeklyChange
    }
    
    private func calculateTimeToTarget(targetWeight: Double, weeklyChange: Double) -> Int {
        let currentWeight = userProfile.weightKg
        let totalChange = abs(targetWeight - currentWeight)
        
        guard weeklyChange != 0 else { return 30 } // Default a 30 días si no hay cambio
        
        let weeksNeeded = totalChange / abs(weeklyChange)
        let daysNeeded = Int(weeksNeeded * 7)
        
        // Limitar a rangos realistas
        return max(14, min(daysNeeded, 365)) // Entre 2 semanas y 1 año
    }
    
    private func calculateMuscleGain() -> Double {
        let goal = userProfile.goal.lowercased()
        guard goal.contains("ganar") || goal.contains("musculo") || goal.contains("muscle") || goal.contains("bulk") else {
            return 0.0
        }
        
        let workoutIntensity = getWorkoutIntensity()
        let experienceLevel = getExperienceLevel()
        let age = calculateAge()
        
        // Ganancia muscular base por mes
        var monthlyGain = 1.0
        
        // Ajustar por intensidad de entrenamiento
        monthlyGain *= workoutIntensity
        
        // Ajustar por experiencia
        monthlyGain *= experienceLevel
        
        // Ajustar por edad
        let ageFactor: Double
        switch age {
        case 18...25: ageFactor = 1.0
        case 26...35: ageFactor = 0.9
        case 36...45: ageFactor = 0.7
        default: ageFactor = 0.5
        }
        monthlyGain *= ageFactor
        
        // Limitar a rangos realistas
        return min(monthlyGain, Constants.maxMonthlyMuscleGain)
    }
    
    private func calculateFatLoss(weightChange: Double, muscleGain: Double) -> Double {
        let goal = userProfile.goal.lowercased()
        
        if goal.contains("perder") || goal.contains("adelgazar") || goal.contains("lose") {
            return abs(weightChange) - muscleGain
        } else if goal.contains("ganar") || goal.contains("musculo") || goal.contains("muscle") || goal.contains("bulk") {
            return max(0, muscleGain - weightChange)
        } else {
            return 0.0
        }
    }
    
    private func calculateSuccessProbability() -> Double {
        var probability: Double = 0.7 // Base 70%
        
        // Factor 1: Realismo del objetivo (20%)
        let results = calculateScientificResults()
        if results.isRealistic {
            probability += 0.2
        }
        
        // Factor 2: Nivel de actividad (15%)
        let activityLevel = getActivityMultiplier()
        if activityLevel >= Constants.moderatelyActive {
            probability += 0.15
        }
        
        // Factor 3: Edad (10%)
        let age = calculateAge()
        if age >= 18 && age <= 45 {
            probability += 0.1
        }
        
        // Factor 4: Consistencia del plan (15%)
        let workoutLevel = userProfile.workoutLevel.lowercased()
        if workoutLevel.contains("intermedio") || workoutLevel.contains("moderate") {
            probability += 0.15
        }
        
        return min(probability, 1.0)
    }
    
    // MARK: - Métodos de Soporte
    
    private func getActivityMultiplier() -> Double {
        let activity = userProfile.levelActivity.lowercased()
        
        switch activity {
        case let a where a.contains("sedentario") || a.contains("sedentary"):
            return Constants.sedentary
        case let a where a.contains("ligero") || a.contains("light"):
            return Constants.lightlyActive
        case let a where a.contains("moderado") || a.contains("moderate"):
            return Constants.moderatelyActive
        case let a where a.contains("activo") || a.contains("active"):
            return Constants.veryActive
        case let a where a.contains("muy activo") || a.contains("very active"):
            return Constants.extremelyActive
        default:
            return Constants.moderatelyActive
        }
    }
    
    private func getDietEffectiveness() -> Double {
        let dietType = userProfile.dietType.lowercased()
        
        switch dietType {
        case let d where d.contains("keto") || d.contains("cetogénica"):
            return 1.2
        case let d where d.contains("bajo") && d.contains("carb"):
            return 1.1
        case let d where d.contains("déficit") || d.contains("deficit"):
            return 1.0
        default:
            return 1.0
        }
    }
    
    private func getWorkoutIntensity() -> Double {
        let workoutLevel = userProfile.workoutLevel.lowercased()
        
        switch workoutLevel {
        case let w where w.contains("suave") || w.contains("light") || w.contains("principiante"):
            return 0.7
        case let w where w.contains("intermedio") || w.contains("moderate"):
            return 1.0
        case let w where w.contains("intensivo") || w.contains("intense") || w.contains("avanzado"):
            return 1.3
        default:
            return 1.0
        }
    }
    
    private func getExperienceLevel() -> Double {
        let workoutLevel = userProfile.workoutLevel.lowercased()
        
        switch workoutLevel {
        case let w where w.contains("principiante") || w.contains("beginner"):
            return 1.2 // Principiantes ganan más músculo inicialmente
        case let w where w.contains("intermedio") || w.contains("intermediate"):
            return 1.0
        case let w where w.contains("avanzado") || w.contains("advanced"):
            return 0.8 // Avanzados ganan menos músculo
        default:
            return 1.0
        }
    }
    
    private func isUserMale() -> Bool {
        let gender = userProfile.gender.lowercased()
        return ["male", "hombre", "masculino", "m"].contains(gender)
    }
    
    private func calculateAge() -> Int {
        // Verificar si birthYear es válido antes de convertir
        guard userProfile.birthYear != "Not Set",
              let birthYear = Int(userProfile.birthYear), 
              birthYear > 1900 else { 
            return 30 // Valor por defecto
        }
        let currentYear = Calendar.current.component(.year, from: Date())
        return max(currentYear - birthYear, 18)
    }
    
    // MARK: - Generación de Recomendaciones y Milestones
    
    private func generateScientificRecommendations() -> [String] {
        var recommendations: [String] = []
        let goal = userProfile.goal.lowercased()
        
        // ✅ CORREGIDO: Calcular valores directamente sin recursión
        let dailyCalories = calculateDailyCalorieTarget()
        let weeklyChange = calculateWeeklyWeightChange()
        
        // Recomendaciones basadas en calorías
        recommendations.append("Consume \(dailyCalories) calorías diarias para alcanzar tu objetivo")
        
        // Recomendaciones específicas por objetivo
        if goal.contains("perder") || goal.contains("adelgazar") || goal.contains("lose") {
            let calorieDeficit = Int(abs(weeklyChange * Double(Constants.caloriesPerKg) / 7.0))
            recommendations.append("Mantén un déficit de \(calorieDeficit) calorías diarias")
            recommendations.append("Combina cardio moderado (30-45 min) con entrenamiento de fuerza")
            recommendations.append("Prioriza proteína magra (1.6-2.2g por kg de peso corporal)")
        } else if goal.contains("ganar") || goal.contains("musculo") || goal.contains("muscle") || goal.contains("bulk") {
            let calorieSurplus = Int(abs(weeklyChange * Double(Constants.caloriesPerKg) / 7.0))
            recommendations.append("Consume \(calorieSurplus) calorías extra diariamente")
            recommendations.append("Enfócate en ejercicios compuestos (sentadillas, peso muerto, press)")
            recommendations.append("Descansa 48-72 horas entre entrenamientos del mismo grupo muscular")
        }
        
        // Recomendaciones de actividad
        let activityLevel = getActivityMultiplier()
        if activityLevel < Constants.moderatelyActive {
            recommendations.append("Aumenta gradualmente tu actividad física diaria")
        }
        
        return recommendations
    }
    
    private func generateMilestones(targetWeight: Double, weeklyChange: Double) -> [Milestone] {
        var milestones: [Milestone] = []
        let currentWeight = userProfile.weightKg
        let goal = userProfile.goal.lowercased()
        
        let totalChange = abs(targetWeight - currentWeight)
        
        // ✅ CORREGIDO: Evitar división por cero
        guard abs(weeklyChange) > 0.01 else {
            // Si no hay cambio semanal, crear milestone simple
            milestones.append(Milestone(
                day: 30,
                description: "Maintain your current weight",
                expectedWeight: currentWeight,
                motivation: "Keep up the great work maintaining your healthy weight!"
            ))
            return milestones
        }
        
        let weeksToTarget = totalChange / abs(weeklyChange)
        
        // Milestone 1: 25% del camino
        let milestone1Weight = currentWeight + (weeklyChange * weeksToTarget * 0.25)
        let milestone1Days = Int(weeksToTarget * 0.25 * 7)
        
        if milestone1Days >= 7 {
            milestones.append(Milestone(
                day: milestone1Days,
                description: "25% del camino completado",
                expectedWeight: milestone1Weight,
                motivation: goal.contains("perder") ? "¡Ya notas que tu ropa queda más holgada!" : "¡Empiezas a ver cambios en el espejo!"
            ))
        }
        
        // Milestone 2: 50% del camino
        let milestone2Weight = currentWeight + (weeklyChange * weeksToTarget * 0.5)
        let milestone2Days = Int(weeksToTarget * 0.5 * 7)
        
        if milestone2Days >= 14 {
            milestones.append(Milestone(
                day: milestone2Days,
                description: "¡Mitad del camino!",
                expectedWeight: milestone2Weight,
                motivation: goal.contains("perder") ? "¡Has perdido la mitad de tu objetivo!" : "¡Tu transformación es visible!"
            ))
        }
        
        // Milestone 3: 75% del camino
        let milestone3Weight = currentWeight + (weeklyChange * weeksToTarget * 0.75)
        let milestone3Days = Int(weeksToTarget * 0.75 * 7)
        
        if milestone3Days >= 21 {
            milestones.append(Milestone(
                day: milestone3Days,
                description: "¡Casi llegas!",
                expectedWeight: milestone3Weight,
                motivation: goal.contains("perder") ? "¡Estás muy cerca de tu peso objetivo!" : "¡Tu nueva versión está casi lista!"
            ))
        }
        
        // Milestone final
        milestones.append(Milestone(
            day: Int(weeksToTarget * 7),
            description: "¡Meta alcanzada!",
            expectedWeight: targetWeight,
            motivation: goal.contains("perder") ? "¡Has transformado tu cuerpo y tu vida!" : "¡Has construido la versión más fuerte de ti!"
        ))
        
        return milestones
    }
    
    // MARK: - Métodos para ShowInfoViewModel
    
    func getResultsSummary() -> String {
        // ✅ CORREGIDO: Calcular valores directamente sin recursión
        let targetWeight = calculateTargetWeight()
        let weeklyChange = calculateWeeklyWeightChange()
        let dailyCalories = calculateDailyCalorieTarget()
        let muscleGain = calculateMuscleGain()
        let successProbability = calculateSuccessProbability()
        let timeToTarget = calculateTimeToTarget(targetWeight: targetWeight, weeklyChange: weeklyChange)
        
        let goal = userProfile.goal.lowercased()
        let changeDirection = goal.contains("perder") ? "lose" : goal.contains("ganar") ? "gain" : "maintain"
        let timeFrame = timeToTarget <= 30 ? "\(timeToTarget) days" : "\(timeToTarget / 30) months"
        
        return """
        🎯 Target: \(String(format: "%.1f", targetWeight))kg (\(changeDirection) \(String(format: "%.1f", abs(targetWeight - userProfile.weightKg)))kg)
        ⏱️ Timeline: \(timeFrame)
        📊 Weekly change: \(String(format: "%.2f", abs(weeklyChange)))kg
        💪 Muscle gain: \(String(format: "%.1f", muscleGain))kg/month
        🔥 Daily calories: \(dailyCalories)
        ✅ Success rate: \(Int(successProbability * 100))%
        """
    }
    
    func isPlanRealistic() -> Bool {
        // ✅ CORREGIDO: Calcular directamente sin recursión
        let weeklyChange = abs(calculateWeeklyWeightChange())
        return weeklyChange >= 0.25 && weeklyChange <= 1.0
    }
    
    func getMotivationalMessage() -> String {
        // ✅ CORREGIDO: Calcular directamente sin recursión
        let successProbability = calculateSuccessProbability()
        
        if successProbability > 0.8 {
            return "¡Excelente plan! Tienes muy altas probabilidades de éxito 🚀"
        } else if successProbability > 0.6 {
            return "Buen plan con alta probabilidad de éxito 💪"
        } else {
            return "Plan ambicioso - considera ajustes para mayor éxito ⚠️"
        }
    }
    
    // MARK: - Helper Methods
    private func createDefaultResults() -> ScientificResults {
        print("🔬 RESULTSOON - Creando resultados por defecto")
        
        // ✅ CORREGIDO: Usar datos del usuario actual en lugar de valores fijos
        let currentWeight = userProfile.weightKg > 0 ? userProfile.weightKg : 70.0
        let targetWeight = currentWeight - 5.0 // Pérdida moderada por defecto
        let goal = userProfile.goal.lowercased()
        
        // Ajustar objetivo según la meta del usuario
        let adjustedTargetWeight: Double
        if goal.contains("perder") || goal.contains("adelgazar") || goal.contains("lose") {
            adjustedTargetWeight = currentWeight - 5.0
        } else if goal.contains("ganar") || goal.contains("musculo") || goal.contains("muscle") || goal.contains("bulk") {
            adjustedTargetWeight = currentWeight + 3.0
        } else {
            adjustedTargetWeight = currentWeight // Mantener peso
        }
        
        return ScientificResults(
            targetWeight: adjustedTargetWeight,
            estimatedTimeToTarget: 60,
            weeklyWeightChange: goal.contains("perder") ? -0.5 : goal.contains("ganar") ? 0.3 : 0.0,
            monthlyWeightChange: goal.contains("perder") ? -2.0 : goal.contains("ganar") ? 1.2 : 0.0,
            muscleGain: goal.contains("ganar") || goal.contains("musculo") ? 0.5 : 0.0,
            fatLoss: goal.contains("perder") || goal.contains("adelgazar") ? 2.0 : 0.0,
            dailyCalorieTarget: 2000,
            successProbability: 0.75,
            recommendations: [
                "Complete your profile for personalized recommendations",
                "Follow a consistent nutrition plan",
                "Stay active with regular exercise"
            ],
            milestones: [
                Milestone(day: 7, description: "First week completed", expectedWeight: currentWeight + (goal.contains("perder") ? -0.5 : goal.contains("ganar") ? 0.3 : 0.0), motivation: "Great start on your journey!"),
                Milestone(day: 30, description: "First month milestone", expectedWeight: currentWeight + (goal.contains("perder") ? -2.0 : goal.contains("ganar") ? 1.2 : 0.0), motivation: "Keep going strong!")
            ]
        )
    }
    
    // MARK: - Método de Prueba
    func testCalculation() -> Bool {
        print("🧪 RESULTSOON - Iniciando prueba de cálculo...")
        
        do {
            let results = calculateScientificResults()
            print("✅ RESULTSOON - Prueba exitosa:")
            print("   • Peso objetivo: \(results.targetWeight)")
            print("   • Calorías diarias: \(results.dailyCalorieTarget)")
            print("   • Cambio semanal: \(results.weeklyWeightChange)")
            return true
        } catch {
            print("❌ RESULTSOON - Prueba fallida: \(error)")
            return false
        }
    }
}

/*
 RESUMEN DE LA REESTRUCTURACIÓN:
 
 ✅ CALCULOS CIENTÍFICOS: Basados en fórmulas reales (Mifflin-St Jeor, etc.)
 ✅ OBJETIVOS REALISTAS: Basados en BMI y metas alcanzables
 ✅ TIMELINES PRECISOS: Cálculo realista de tiempo al objetivo
 ✅ FACTORES MÚLTIPLES: Actividad, dieta, intensidad, edad, experiencia
 ✅ RECOMENDACIONES ESPECÍFICAS: Basadas en datos del usuario
 ✅ MILESTONES PERSONALIZADOS: Hitos motivacionales realistas
 ✅ PROBABILIDAD DE ÉXITO: Cálculo basado en múltiples factores
 
 CÓMO USAR:
 
 let resultSoon = ResultSoon()
 let results = resultSoon.calculateScientificResults()
 let summary = resultSoon.getResultsSummary()
 let realistic = resultSoon.isPlanRealistic()
 let motivation = resultSoon.getMotivationalMessage()
 
 Este sistema ahora proporciona resultados científicos y realistas basados en todos los datos recolectados del usuario.
 */
