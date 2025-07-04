import Foundation

// MARK: - Estructuras de Resultados
struct ShortTermResults {
    let week1: WeekResults
    let week2: WeekResults
    let week3: WeekResults
    let week4: WeekResults
    
    var totalWeightChange: Double {
        week1.weightChange + week2.weightChange + week3.weightChange + week4.weightChange
    }
    
    var totalMuscleGain: Double {
        week1.muscleGain + week2.muscleGain + week3.muscleGain + week4.muscleGain
    }
    
    var averageEnergyLevel: String {
        let levels = [week1.energyLevel, week2.energyLevel, week3.energyLevel, week4.energyLevel]
        return levels.max(by: { $0.count < $1.count }) ?? "Bueno"
    }
}

struct WeekResults {
    let weekNumber: Int
    let weightChange: Double // kg
    let muscleGain: Double // kg
    let fatLoss: Double // kg
    let energyLevel: String
    let motivation: String
    let tips: [String]
    
    var expectedWeight: Double {
        let currentWeight = UserProfile.loadFromUserDefaults().weightKg
        return currentWeight + weightChange
    }
    
    var bodyFatPercentage: Double {
        let currentWeight = UserProfile.loadFromUserDefaults().weightKg
        let estimatedCurrentBodyFat = estimateInitialBodyFat()
        let fatLossKg = abs(fatLoss)
        let newWeight = currentWeight + weightChange
        
        guard newWeight > 0 else { return estimatedCurrentBodyFat }
        
        let newBodyFat = ((currentWeight * estimatedCurrentBodyFat / 100) - fatLossKg) / newWeight * 100
        return max(5.0, min(35.0, newBodyFat))
    }
    
    var muscleMass: Double {
        let currentWeight = UserProfile.loadFromUserDefaults().weightKg
        let estimatedCurrentBodyFat = estimateInitialBodyFat()
        let currentMuscle = currentWeight * (1 - estimatedCurrentBodyFat / 100)
        return currentMuscle + muscleGain
    }
    
    var isPositive: Bool {
        let goal = UserProfile.loadFromUserDefaults().goal.lowercased()
        if goal.contains("perder") || goal.contains("adelgazar") || goal.contains("lose") {
            return weightChange < 0
        } else if goal.contains("ganar") || goal.contains("musculo") || goal.contains("muscle") || goal.contains("bulk") {
            return weightChange > 0
        } else {
            return abs(weightChange) < 0.5
        }
    }
    
    private func estimateInitialBodyFat() -> Double {
        let profile = UserProfile.loadFromUserDefaults()
        let isMale = ["male", "hombre", "masculino", "m"].contains(
            profile.gender.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        )
        
        guard let bmi = profile.bmi else {
            return isMale ? 15.0 : 22.0
        }
        
        switch bmi {
        case 0..<18.5: return isMale ? 8.0 : 15.0
        case 18.5..<25.0: return isMale ? 15.0 : 22.0
        case 25.0..<30.0: return isMale ? 20.0 : 28.0
        default: return isMale ? 25.0 : 32.0
        }
    }
}

struct LongTermResults {
    let month3: MonthResults
    let month6: MonthResults
    let month12: MonthResults
    
    var totalWeightChange: Double {
        month12.weightChange
    }
    
    var totalMuscleGain: Double {
        month12.muscleGain
    }
    
    var projectedBodyFatChange: Double {
        let initial = estimateInitialBodyFat()
        let final = calculateFinalBodyFat()
        return final - initial
    }
    
    private func estimateInitialBodyFat() -> Double {
        let profile = UserProfile.loadFromUserDefaults()
        let isMale = ["male", "hombre", "masculino", "m"].contains(
            profile.gender.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        )
        
        guard let bmi = profile.bmi else {
            return isMale ? 15.0 : 22.0
        }
        
        switch bmi {
        case 0..<18.5: return isMale ? 8.0 : 15.0
        case 18.5..<25.0: return isMale ? 15.0 : 22.0
        case 25.0..<30.0: return isMale ? 20.0 : 28.0
        default: return isMale ? 25.0 : 32.0
        }
    }
    
    private func calculateFinalBodyFat() -> Double {
        let initialBodyFat = estimateInitialBodyFat()
        let fatLoss = month12.fatLoss
        let profile = UserProfile.loadFromUserDefaults()
        
        let newWeight = profile.weightKg + month12.weightChange
        guard newWeight > 0 else { return initialBodyFat }
        
        let newBodyFat = ((profile.weightKg * initialBodyFat / 100) - fatLoss) / newWeight * 100
        return max(5.0, min(35.0, newBodyFat))
    }
}

struct MonthResults {
    let monthNumber: Int
    let weightChange: Double
    let muscleGain: Double
    let fatLoss: Double
    let bodyComposition: String
    let healthImprovements: [String]
    let lifestyleChanges: [String]
    
    var expectedWeight: Double {
        let currentWeight = UserProfile.loadFromUserDefaults().weightKg
        return currentWeight + weightChange
    }
    
    var metabolicImprovement: Double {
        let muscleBonus = muscleGain * 13 // 13 calorías por kg de músculo
        let activityBonus = monthNumber * 20 // Mejora por adaptación
        return muscleBonus + Double(activityBonus)
    }
}

struct ResultsReport {
    let shortTerm: ShortTermResults
    let longTerm: LongTermResults
    let userProfile: UserProfile
    let recommendations: [String]
    let successProbability: Double
    
    var totalWeightChange: Double {
        shortTerm.totalWeightChange
    }
    
    var totalMuscleGain: Double {
        shortTerm.totalMuscleGain
    }
    
    var isOnTrack: Bool {
        let goal = userProfile.goal.lowercased()
        if goal.contains("perder") || goal.contains("adelgazar") {
            return totalWeightChange < -1.0
        } else if goal.contains("ganar") || goal.contains("musculo") {
            return totalWeightChange > 0.5
        } else {
            return abs(totalWeightChange) < 1.0
        }
    }
    
    var projectedSuccessMessage: String {
        switch successProbability {
        case 0.8...1.0:
            return "¡Excelente! Tienes muy altas probabilidades de éxito 🚀"
        case 0.6..<0.8:
            return "Buen plan con alta probabilidad de éxito 💪"
        case 0.4..<0.6:
            return "Plan moderadamente desafiante pero alcanzable 📈"
        default:
            return "Plan ambicioso - considera ajustes para mayor éxito ⚠️"
        }
    }
}

// MARK: - ResultSoon - Calculadora Principal
class ResultSoon {
    
    // MARK: - Enums
    enum BodyType: String, CaseIterable {
        case skinny = "Flaco"
        case regular = "Regular"
        case muscular = "Musculoso"
        case overweight = "Gordo"
        
        var description: String {
            switch self {
            case .skinny: return "Cuerpo delgado con poca masa muscular"
            case .regular: return "Cuerpo promedio con masa muscular moderada"
            case .muscular: return "Cuerpo atlético con buena masa muscular"
            case .overweight: return "Cuerpo con exceso de peso"
            }
        }
    }
    
    enum WorkoutIntensity: String, CaseIterable {
        case light = "Suave"
        case moderate = "Intermedio"
        case intense = "Intensivo"
        
        var multiplier: Double {
            switch self {
            case .light: return 1.1
            case .moderate: return 1.25
            case .intense: return 1.4
            }
        }
    }
    
    enum DietType: String, CaseIterable {
        case keto = "Keto"
        case caloricDeficit = "Déficit Calórico"
        case lowCarb = "Bajo en Carbohidratos"
        
        var effectiveness: Double {
            switch self {
            case .keto: return 1.3
            case .caloricDeficit: return 1.0
            case .lowCarb: return 1.15
            }
        }
    }
    
    // MARK: - Propiedades
    private let userProfile: UserProfile
    private lazy var nutritionCalculator: NutritionCalculator = {
        return NutritionCalculator()
    }()
    
    // MARK: - Inicialización
    init(userProfile: UserProfile = UserProfile.loadFromUserDefaults()) {
        self.userProfile = userProfile
    }
    
    // MARK: - API Pública
    func calculateShortTermResults() -> ShortTermResults {
        let bodyType = determineBodyType()
        let workoutIntensity = determineWorkoutIntensity()
        let dietType = determineDietType()
        
        print("🎯 CALCULANDO RESULTADOS A CORTO PLAZO")
        print("   • Tipo de cuerpo: \(bodyType.rawValue)")
        print("   • Intensidad: \(workoutIntensity.rawValue)")
        print("   • Dieta: \(dietType.rawValue)")
        
        let week1 = calculateWeekResults(week: 1, bodyType: bodyType, workoutIntensity: workoutIntensity, dietType: dietType)
        let week2 = calculateWeekResults(week: 2, bodyType: bodyType, workoutIntensity: workoutIntensity, dietType: dietType)
        let week3 = calculateWeekResults(week: 3, bodyType: bodyType, workoutIntensity: workoutIntensity, dietType: dietType)
        let week4 = calculateWeekResults(week: 4, bodyType: bodyType, workoutIntensity: workoutIntensity, dietType: dietType)
        
        return ShortTermResults(week1: week1, week2: week2, week3: week3, week4: week4)
    }
    
    func calculateLongTermResults() -> LongTermResults {
        let bodyType = determineBodyType()
        let workoutIntensity = determineWorkoutIntensity()
        let dietType = determineDietType()
        
        print("🎯 CALCULANDO RESULTADOS A LARGO PLAZO")
        
        let month3 = calculateMonthResults(month: 3, bodyType: bodyType, workoutIntensity: workoutIntensity, dietType: dietType)
        let month6 = calculateMonthResults(month: 6, bodyType: bodyType, workoutIntensity: workoutIntensity, dietType: dietType)
        let month12 = calculateMonthResults(month: 12, bodyType: bodyType, workoutIntensity: workoutIntensity, dietType: dietType)
        
        return LongTermResults(month3: month3, month6: month6, month12: month12)
    }
    
    func generateCompleteResultsReport() -> ResultsReport {
        let shortTerm = calculateShortTermResults()
        let longTerm = calculateLongTermResults()
        let successProbability = calculateSuccessProbability(for: userProfile, results: shortTerm)
        
        return ResultsReport(
            shortTerm: shortTerm,
            longTerm: longTerm,
            userProfile: userProfile,
            recommendations: generateRecommendations(),
            successProbability: successProbability
        )
    }
    
    // MARK: - Métodos Privados
    private func determineBodyType() -> BodyType {
        guard let bmi = userProfile.bmi else { return .regular }
        
        switch bmi {
        case 16.0..<18.5: return .skinny
        case 18.5..<25.0: return .regular
        case 25.0..<30.0: return .muscular
        default: return .overweight
        }
    }
    
    private func determineWorkoutIntensity() -> WorkoutIntensity {
        let workoutLevel = userProfile.workoutLevel.lowercased()
        
        if workoutLevel.contains("suave") || workoutLevel.contains("principiante") || workoutLevel.contains("básico") {
            return .light
        } else if workoutLevel.contains("intensivo") || workoutLevel.contains("avanzado") {
            return .intense
        } else {
            return .moderate
        }
    }
    
    private func determineDietType() -> DietType {
        let dietType = userProfile.dietType.lowercased()
        
        if dietType.contains("keto") || dietType.contains("cetogénica") {
            return .keto
        } else if dietType.contains("bajo") && dietType.contains("carb") {
            return .lowCarb
        } else {
            return .caloricDeficit
        }
    }
    
    private func calculateWeekResults(week: Int, bodyType: BodyType, workoutIntensity: WorkoutIntensity, dietType: DietType) -> WeekResults {
        let goal = userProfile.goal.lowercased()
        let baseWeightChange = getBaseWeightChange(week: week, goal: goal, bodyType: bodyType)
        let adjustedWeightChange = baseWeightChange * workoutIntensity.multiplier * dietType.effectiveness
        
        let muscleGain = calculateMuscleGain(week: week, goal: goal, bodyType: bodyType, workoutIntensity: workoutIntensity)
        let fatLoss = calculateFatLoss(weightChange: adjustedWeightChange, muscleGain: muscleGain, goal: goal)
        
        return WeekResults(
            weekNumber: week,
            weightChange: adjustedWeightChange,
            muscleGain: muscleGain,
            fatLoss: fatLoss,
            energyLevel: getEnergyLevel(week: week, weightChange: adjustedWeightChange),
            motivation: getMotivationMessage(week: week, weightChange: adjustedWeightChange, goal: goal),
            tips: getWeeklyTips(week: week, bodyType: bodyType, goal: goal)
        )
    }
    
    private func getBaseWeightChange(week: Int, goal: String, bodyType: BodyType) -> Double {
        let baseChange: Double
        
        if goal.contains("perder") || goal.contains("adelgazar") {
            baseChange = -0.5
        } else if goal.contains("ganar") || goal.contains("musculo") {
            baseChange = 0.3
        } else {
            baseChange = 0.0
        }
        
        let bodyTypeMultiplier: Double
        switch bodyType {
        case .skinny: bodyTypeMultiplier = 0.8
        case .regular: bodyTypeMultiplier = 1.0
        case .muscular: bodyTypeMultiplier = 1.2
        case .overweight: bodyTypeMultiplier = 1.3
        }
        
        let weekMultiplier = 1.0 + (Double(week - 1) * 0.1)
        
        return baseChange * bodyTypeMultiplier * weekMultiplier
    }
    
    private func calculateMuscleGain(week: Int, goal: String, bodyType: BodyType, workoutIntensity: WorkoutIntensity) -> Double {
        guard goal.contains("ganar") || goal.contains("musculo") else { return 0.0 }
        
        let baseMuscleGain = 0.1
        let intensityMultiplier = workoutIntensity.multiplier
        
        let bodyTypeMultiplier: Double
        switch bodyType {
        case .skinny: bodyTypeMultiplier = 1.2
        case .regular: bodyTypeMultiplier = 1.0
        case .muscular: bodyTypeMultiplier = 0.8
        case .overweight: bodyTypeMultiplier = 0.6
        }
        
        let weekMultiplier = 1.0 + (Double(week - 1) * 0.05)
        
        return baseMuscleGain * intensityMultiplier * bodyTypeMultiplier * weekMultiplier
    }
    
    private func calculateFatLoss(weightChange: Double, muscleGain: Double, goal: String) -> Double {
        if goal.contains("perder") || goal.contains("adelgazar") {
            return abs(weightChange) - muscleGain
        } else if goal.contains("ganar") || goal.contains("musculo") {
            return max(0, muscleGain - weightChange)
        } else {
            return 0.0
        }
    }
    
    private func calculateMonthResults(month: Int, bodyType: BodyType, workoutIntensity: WorkoutIntensity, dietType: DietType) -> MonthResults {
        let goal = userProfile.goal.lowercased()
        
        let totalWeightChange = calculateTotalWeightChange(month: month, goal: goal, bodyType: bodyType, workoutIntensity: workoutIntensity, dietType: dietType)
        let totalMuscleGain = calculateTotalMuscleGain(month: month, goal: goal, bodyType: bodyType, workoutIntensity: workoutIntensity)
        let totalFatLoss = calculateTotalFatLoss(weightChange: totalWeightChange, muscleGain: totalMuscleGain, goal: goal)
        
        return MonthResults(
            monthNumber: month,
            weightChange: totalWeightChange,
            muscleGain: totalMuscleGain,
            fatLoss: totalFatLoss,
            bodyComposition: getBodyCompositionDescription(month: month, weightChange: totalWeightChange, muscleGain: totalMuscleGain, goal: goal),
            healthImprovements: getHealthImprovements(month: month, goal: goal),
            lifestyleChanges: getLifestyleChanges(month: month, goal: goal)
        )
    }
    
    private func calculateTotalWeightChange(month: Int, goal: String, bodyType: BodyType, workoutIntensity: WorkoutIntensity, dietType: DietType) -> Double {
        let weeks = month * 4
        var totalChange: Double = 0
        
        for week in 1...weeks {
            let baseChange = getBaseWeightChange(week: week, goal: goal, bodyType: bodyType)
            let adjustedChange = baseChange * workoutIntensity.multiplier * dietType.effectiveness
            totalChange += adjustedChange
        }
        
        return totalChange
    }
    
    private func calculateTotalMuscleGain(month: Int, goal: String, bodyType: BodyType, workoutIntensity: WorkoutIntensity) -> Double {
        guard goal.contains("ganar") || goal.contains("musculo") else { return 0.0 }
        
        let weeks = month * 4
        var totalGain: Double = 0
        
        for week in 1...weeks {
            totalGain += calculateMuscleGain(week: week, goal: goal, bodyType: bodyType, workoutIntensity: workoutIntensity)
        }
        
        return totalGain
    }
    
    private func calculateTotalFatLoss(weightChange: Double, muscleGain: Double, goal: String) -> Double {
        if goal.contains("perder") || goal.contains("adelgazar") {
            return abs(weightChange) - muscleGain
        } else if goal.contains("ganar") || goal.contains("musculo") {
            return max(0, muscleGain - weightChange)
        } else {
            return 0.0
        }
    }
    
    private func getEnergyLevel(week: Int, weightChange: Double) -> String {
        let goal = userProfile.goal.lowercased()
        
        if goal.contains("perder") || goal.contains("adelgazar") {
            if weightChange < -0.8 {
                return "Alto - Gran progreso energiza tu motivación"
            } else if weightChange < -0.3 {
                return "Bueno - Sientes los beneficios del cambio"
            } else {
                return "Estable - Tu cuerpo se adapta gradualmente"
            }
        } else if goal.contains("ganar") || goal.contains("musculo") {
            if weightChange > 0.5 {
                return "Excelente - Ganancia muscular aumenta tu energía"
            } else if weightChange > 0.2 {
                return "Bueno - Progreso visible mejora tu estado de ánimo"
            } else {
                return "Estable - Construyendo base sólida"
            }
        } else {
            switch week {
            case 1: return "Adaptación - Tu cuerpo se acostumbra"
            case 2: return "Mejorando - Energía más estable"
            case 3: return "Poderoso - Energía sostenida para entrenamientos"
            case 4: return "Máximo - Rendimiento físico óptimo"
            default: return "Fuerte"
            }
        }
    }
    
    private func getMotivationMessage(week: Int, weightChange: Double, goal: String) -> String {
        if goal.contains("perder") || goal.contains("adelgazar") {
            if weightChange < 0 {
                return "¡Excelente progreso! Has perdido \(String(format: "%.1f", abs(weightChange))) kg esta semana. ¡Sigue así!"
            } else {
                return "¡Mantén la consistencia! Los resultados llegarán pronto. Recuerda que el peso puede fluctuar."
            }
        } else if goal.contains("ganar") || goal.contains("musculo") {
            if weightChange > 0 {
                return "¡Increíble! Has ganado \(String(format: "%.1f", weightChange)) kg de masa muscular. ¡Continúa construyendo!"
            } else {
                return "¡Enfócate en la nutrición! Asegúrate de comer suficientes calorías para ganar músculo."
            }
        } else {
            return "¡Manteniendo el equilibrio! Tu cuerpo se está adaptando perfectamente a tu nueva rutina."
        }
    }
    
    private func getWeeklyTips(week: Int, bodyType: BodyType, goal: String) -> [String] {
        var tips: [String] = []
        
        switch week {
        case 1:
            tips.append("Bebe al menos 2L de agua diariamente")
            tips.append("Mantén un diario de comidas para tracking")
            tips.append("Descansa 7-8 horas cada noche")
        case 2:
            tips.append("Aumenta gradualmente la intensidad de tus entrenamientos")
            tips.append("Incluye proteína en cada comida")
            tips.append("Mantén la consistencia en tu horario")
        case 3:
            tips.append("Varía tus ejercicios para evitar estancamiento")
            tips.append("Mide tu progreso semanalmente")
            tips.append("Celebra los pequeños logros")
        case 4:
            tips.append("Evalúa tu progreso y ajusta si es necesario")
            tips.append("Mantén la motivación con metas a corto plazo")
            tips.append("Comparte tu progreso con amigos o familia")
        default:
            tips.append("Mantén la consistencia en tu rutina")
        }
        
        switch bodyType {
        case .skinny:
            tips.append("Enfócate en ejercicios de fuerza y resistencia")
            tips.append("Aumenta tu ingesta calórica gradualmente")
        case .overweight:
            tips.append("Combina cardio y entrenamiento de fuerza")
            tips.append("Mantén un déficit calórico sostenible")
        case .muscular:
            tips.append("Optimiza tu recuperación entre entrenamientos")
            tips.append("Varía la intensidad de tus rutinas")
        default:
            tips.append("Mantén un balance entre cardio y fuerza")
        }
        
        return tips
    }
    
    private func getBodyCompositionDescription(month: Int, weightChange: Double, muscleGain: Double, goal: String) -> String {
        if goal.contains("perder") || goal.contains("adelgazar") {
            if weightChange < -5 {
                return "Transformación significativa: pérdida de grasa notable y tonificación muscular"
            } else if weightChange < -2 {
                return "Progreso visible: reducción de grasa corporal y mejora en la composición"
            } else {
                return "Cambios sutiles pero importantes en la composición corporal"
            }
        } else if goal.contains("ganar") || goal.contains("musculo") {
            if muscleGain > 3 {
                return "Desarrollo muscular impresionante con ganancias significativas de fuerza"
            } else if muscleGain > 1.5 {
                return "Ganancia muscular visible y mejora en la definición"
            } else {
                return "Progreso gradual en el desarrollo muscular"
            }
        } else {
            return "Composición corporal equilibrada y mantenimiento saludable"
        }
    }
    
    private func getHealthImprovements(month: Int, goal: String) -> [String] {
        var improvements: [String] = []
        
        if month >= 3 {
            improvements.append("Mejora en la resistencia cardiovascular")
            improvements.append("Mayor flexibilidad y movilidad")
            improvements.append("Mejor calidad del sueño")
        }
        
        if month >= 6 {
            improvements.append("Reducción del estrés y ansiedad")
            improvements.append("Mejor postura y equilibrio")
            improvements.append("Aumento en los niveles de energía")
        }
        
        if month >= 12 {
            improvements.append("Prevención de enfermedades crónicas")
            improvements.append("Mejora en la densidad ósea")
            improvements.append("Sistema inmunológico fortalecido")
        }
        
        return improvements
    }
    
    private func getLifestyleChanges(month: Int, goal: String) -> [String] {
        var changes: [String] = []
        
        if month >= 3 {
            changes.append("Rutina de ejercicio establecida")
            changes.append("Hábitos alimenticios mejorados")
            changes.append("Mejor gestión del tiempo")
        }
        
        if month >= 6 {
            changes.append("Estilo de vida más activo")
            changes.append("Preferencias alimentarias saludables")
            changes.append("Mayor autodisciplina")
        }
        
        if month >= 12 {
            changes.append("Transformación completa del estilo de vida")
            changes.append("Nuevos hobbies relacionados con el fitness")
            changes.append("Influencia positiva en familia y amigos")
        }
        
        return changes
    }
    
    private func generateRecommendations() -> [String] {
        var recommendations: [String] = []
        let goal = userProfile.goal.lowercased()
        let bodyType = determineBodyType()
        
        if goal.contains("perder") || goal.contains("adelgazar") {
            recommendations.append("Mantén un déficit calórico de 300-500 calorías diarias")
            recommendations.append("Combina cardio moderado con entrenamiento de fuerza")
            recommendations.append("Prioriza proteína magra y vegetales")
        } else if goal.contains("ganar") || goal.contains("musculo") {
            recommendations.append("Consume 300-500 calorías extra diariamente")
            recommendations.append("Enfócate en ejercicios compuestos y progresión")
            recommendations.append("Asegúrate de descansar adecuadamente entre entrenamientos")
        }
        
        switch bodyType {
        case .skinny:
            recommendations.append("Aumenta gradualmente la ingesta calórica")
            recommendations.append("Prioriza ejercicios de fuerza sobre cardio")
        case .overweight:
            recommendations.append("Comienza con cardio de baja intensidad")
            recommendations.append("Establece metas realistas y sostenibles")
        case .muscular:
            recommendations.append("Optimiza tu rutina de entrenamiento")
            recommendations.append("Mantén una nutrición consistente")
        default:
            recommendations.append("Mantén un balance entre todos los aspectos")
        }
        
        return recommendations
    }
    
    internal func calculateSuccessProbability(for profile: UserProfile, results: ShortTermResults) -> Double {
        var successFactors: Double = 0
        var totalFactors: Double = 0
        
        // Factor 1: Realismo del objetivo (30%)
        let weightChangeRate = abs(results.totalWeightChange) / profile.weightKg
        if weightChangeRate <= 0.05 {
            successFactors += 30
        } else if weightChangeRate <= 0.10 {
            successFactors += 15
        }
        totalFactors += 30
        
        // Factor 2: Consistencia de actividad (25%)
        let activityConsistency = evaluateActivityConsistency(profile: profile)
        successFactors += activityConsistency * 25
        totalFactors += 25
        
        // Factor 3: Edad y metabolismo (20%)
        let age = calculateAge(from: profile.birthYear)
        let ageAdvantage: Double
        switch age {
        case 18...25: ageAdvantage = 1.0
        case 26...35: ageAdvantage = 0.9
        case 36...45: ageAdvantage = 0.7
        default: ageAdvantage = 0.5
        }
        successFactors += ageAdvantage * 20
        totalFactors += 20
        
        // Factor 4: Tipo de cuerpo y objetivo (15%)
        let bodyType = determineBodyType()
        let bodyTypeAlignment = evaluateBodyTypeAlignment(profile: profile, bodyType: bodyType)
        successFactors += bodyTypeAlignment * 15
        totalFactors += 15
        
        // Factor 5: Intensidad de entrenamiento (10%)
        let trainingCommitment = evaluateTrainingCommitment(profile.workoutLevel)
        successFactors += trainingCommitment * 10
        totalFactors += 10
        
        return successFactors / totalFactors
    }
    
    private func evaluateActivityConsistency(profile: UserProfile) -> Double {
        let goal = profile.goal.lowercased()
        let activity = profile.levelActivity.lowercased()
        
        if goal.contains("perder") && (activity.contains("moderado") || activity.contains("activo")) {
            return 1.0
        } else if goal.contains("ganar") && (activity.contains("moderado") || activity.contains("activo")) {
            return 1.0
        } else if goal.contains("mantener") && activity.contains("ligero") {
            return 1.0
        } else {
            return 0.6
        }
    }
    
    private func evaluateBodyTypeAlignment(profile: UserProfile, bodyType: BodyType) -> Double {
        let goal = profile.goal.lowercased()
        
        switch (bodyType, goal) {
        case (.overweight, let g) where g.contains("perder"):
            return 1.0
        case (.skinny, let g) where g.contains("ganar"):
            return 1.0
        case (.regular, _):
            return 0.8
        case (.muscular, let g) where g.contains("mantener"):
            return 0.9
        default:
            return 0.5
        }
    }
    
    private func evaluateTrainingCommitment(_ workoutLevel: String) -> Double {
        let normalized = workoutLevel.lowercased()
        
        if normalized.contains("intensivo") || normalized.contains("intense") {
            return 1.0
        } else if normalized.contains("intermedio") || normalized.contains("moderate") {
            return 0.8
        } else {
            return 0.6
        }
    }
    
    private func calculateAge(from birthYear: String) -> Int {
        guard let year = Int(birthYear), year > 1900 else { return 30 }
        let currentYear = Calendar.current.component(.year, from: Date())
        return max(currentYear - year, 18)
    }
}

// MARK: - Métodos para ShowInfoViewModel
extension ResultSoon {
    
    /// Método específico para integración con ShowInfoViewModel
    func calculateShortTermResults(for profile: UserProfile) -> ShortTermResults {
        // Actualizar el perfil interno si se pasa uno diferente
        let tempProfile = self.userProfile
        
        // Usar el perfil pasado como parámetro temporalmente
        let calculator = ResultSoon(userProfile: profile)
        return calculator.calculateShortTermResults()
    }
    
    /// Método específico para integración con ShowInfoViewModel
    func calculateLongTermResults(for profile: UserProfile) -> LongTermResults {
        let calculator = ResultSoon(userProfile: profile)
        return calculator.calculateLongTermResults()
    }
    
    /// Método específico para integración con ShowInfoViewModel
    func generateCompleteResultsReport(for profile: UserProfile) -> ResultsReport {
        let calculator = ResultSoon(userProfile: profile)
        return calculator.generateCompleteResultsReport()
    }
    
    /// Resumen rápido para ShowInfoViewModel
    func getQuickResultsSummary(for profile: UserProfile) -> String {
        let shortTermResults = calculateShortTermResults(for: profile)
        let successProbability = calculateSuccessProbability(for: profile, results: shortTermResults)
        
        let weeklyChange = shortTermResults.totalWeightChange / 4.0
        let goal = profile.goal.lowercased()
        let changeDirection = goal.contains("perder") ? "lose" : goal.contains("ganar") ? "gain" : "maintain"
        
        return """
        📊 Your personalized plan targets \(String(format: "%.1f", abs(weeklyChange)))kg weekly \(changeDirection)
        🎯 Success probability: \(Int(successProbability * 100))%
        💪 Total muscle gain: \(String(format: "%.1f", shortTermResults.totalMuscleGain))kg
        ⚖️ Total weight change: \(String(format: "%.1f", shortTermResults.totalWeightChange))kg
        """
    }
    
    /// Verifica si el plan es factible
    func isPlanFeasible(for profile: UserProfile) -> Bool {
        let shortTermResults = calculateShortTermResults(for: profile)
        let successProbability = calculateSuccessProbability(for: profile, results: shortTermResults)
        return successProbability > 0.6
    }
    
    /// Genera mensajes motivacionales para timeline
    func generateMotivationalMilestones(for profile: UserProfile) -> [String] {
        let goal = profile.goal.lowercased()
        var milestones: [String] = []
        
        if goal.contains("perder") || goal.contains("adelgazar") {
            milestones.append("Semana 1: ¡Perdiste tus primeros 0.5-1kg! 🎉")
            milestones.append("Semana 4: Tu ropa empieza a quedar más holgada 👕")
            milestones.append("Semana 8: ¡Has perdido el 50% de tu objetivo! 💪")
            milestones.append("Semana 12: ¡Meta alcanzada! Tu nueva versión te espera 🌟")
        } else if goal.contains("ganar") || goal.contains("musculo") {
            milestones.append("Semana 2: Notas mayor fuerza en tus entrenamientos 💪")
            milestones.append("Semana 6: ¡Ya tienes más definición muscular! 🏋️")
            milestones.append("Semana 10: Tus músculos son notablemente más grandes 🚀")
            milestones.append("Semana 16: ¡Transformación completa lograda! 🏆")
        } else {
            milestones.append("Semana 2: Rutina establecida exitosamente ✅")
            milestones.append("Semana 6: Mejor energía y resistencia 🔋")
            milestones.append("Semana 12: ¡Estilo de vida saludable consolidado! 🌱")
        }
        
        return milestones
    }
}

/*
 RESUMEN DEL ARCHIVO CORREGIDO:
 
 ✅ ELIMINADO: Duplicación de estructuras
 ✅ MANTENIDO: Toda la lógica original de cálculo
 ✅ AÑADIDO: Métodos de extensión para ShowInfoViewModel
 ✅ SIMPLIFICADO: Una sola clase ResultSoon sin protocolos complejos
 ✅ COMPATIBLE: Con tu ShowInfoViewModel existente
 
 CÓMO USAR:
 
 // En ShowInfoViewModel
 let resultSoon = ResultSoon()
 let shortTermResults = resultSoon.calculateShortTermResults(for: profile)
 let summary = resultSoon.getQuickResultsSummary(for: profile)
 let feasible = resultSoon.isPlanFeasible(for: profile)
 
 Este archivo está listo para usar y debería compilar sin errores.
 */
