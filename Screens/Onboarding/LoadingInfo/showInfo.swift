// MARK: - Simple ShowInfoView
import SwiftUI

struct ShowInfoView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var navigateToDashboard = false
    @State private var nutritionData: NutritionData?
    
    var body: some View {
        ZStack {
            // Clean white background
            Color.white.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header with logo
                headerSection
                
                // Main content with results
                ScrollView {
                    VStack(spacing: 24) {
                        // Success icon
                        successIcon
                        
                        // Results section
                        resultsSection
                        
                        // Info cards
                        infoCardsSection
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 120)
                }
                
                Spacer()
            }
            
            // Navigation buttons
            VStack {
                Spacer()
                navigationButtonsSection
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            calculateNutritionData()
        }
    }
}

// MARK: - Nutrition Data Structure
struct NutritionData {
    let targetWeight: Double
    let weightDifference: Double
    let direction: String
    let timeline: Int
    let weeklyChange: Double
    let dailyCalories: Int
    let waterIntake: String
    let successRate: Int
}

// MARK: - Nutrition Calculation
private extension ShowInfoView {
    func calculateNutritionData() {
        let userProfile = UserProfile.loadFromUserDefaults()
        
        // ✅ DEBUG: Verificar datos del perfil
        print("🔍 VERIFICANDO DATOS DEL PERFIL:")
        print("   • Peso: \(userProfile.weightKg) kg")
        print("   • Altura: \(userProfile.resolvedHeightCm) cm")
        print("   • BMI: \(userProfile.bmi ?? 0)")
        print("   • Objetivo: \(userProfile.goal)")
        print("   • Tipo de dieta: \(userProfile.dietType)")
        print("   • Nivel de actividad: \(userProfile.levelActivity)")
        print("   • Intensidad de entrenamiento: \(userProfile.workoutLevel)")
        
        // ✅ USAR LOS MISMOS MÉTODOS QUE DietViewModel
        let dailyCalories = getDailyCaloriesTarget()
        let waterIntake = calculateRecommendedWaterIntake()
        
        // Calcular peso objetivo basado en el perfil
        let targetWeight = calculateTargetWeight(for: userProfile)
        let currentWeight = userProfile.weightKg
        let weightDifference = abs(targetWeight - currentWeight)
        
        // Determinar dirección
        let goal = userProfile.goal.lowercased()
        let direction = goal.contains("perder") || goal.contains("lose") ? "to lose" : 
                       goal.contains("ganar") || goal.contains("gain") ? "to gain" : "to maintain"
        
        print("🔬 CÁLCULOS INICIALES:")
        print("   • Peso objetivo: \(targetWeight) kg")
        print("   • Peso actual: \(currentWeight) kg")
        print("   • Diferencia: \(weightDifference) kg")
        print("   • Dirección: \(direction)")
        
        // Calcular timeline basado en dieta y objetivo
        let timeline = calculateTimeline(for: userProfile, weightDifference: weightDifference)
        
        // Calcular cambio semanal
        let weeklyChange = calculateWeeklyChange(for: userProfile, weightDifference: weightDifference, timeline: timeline)
        
        // Calcular probabilidad de éxito
        let successRate = calculateSuccessRate(for: userProfile)
        
        // Crear datos nutricionales
        nutritionData = NutritionData(
            targetWeight: targetWeight,
            weightDifference: weightDifference,
            direction: direction,
            timeline: timeline,
            weeklyChange: weeklyChange,
            dailyCalories: Int(dailyCalories),
            waterIntake: waterIntake,
            successRate: successRate
        )
        
        print("🔬 NUTRITION DATA CALCULATED (SAME AS DietView):")
        print("   • Current Weight: \(currentWeight) kg")
        print("   • Target Weight: \(targetWeight) kg")
        print("   • Weight Difference: \(weightDifference) kg \(direction)")
        print("   • Timeline: \(timeline) days")
        print("   • Weekly Change: \(weeklyChange) kg")
        print("   • Daily Calories: \(dailyCalories) (SAME AS DietView)")
        print("   • Water Intake: \(waterIntake) (SAME AS DietView)")
        print("   • Success Rate: \(successRate)%")
        print("   • Goal: \(goal)")
        print("   • BMI: \(userProfile.bmi ?? 0)")
        print("   • Height: \(userProfile.resolvedHeightCm) cm")
        print("   • Gender: \(userProfile.gender)")
        print("   • Activity Level: \(userProfile.levelActivity)")
        print("   • Workout Level: \(userProfile.workoutLevel)")
        print("   • Diet Type: \(userProfile.dietType)")
    }
    
    func calculateTargetWeight(for profile: UserProfile) -> Double {
        let currentWeight = profile.weightKg
        let goal = profile.goal.lowercased()
        let bmi = profile.bmi ?? 25.0
        let height = Double(profile.resolvedHeightCm) / 100.0 // convertir a metros
        let heightCm = profile.resolvedHeightCm
        
        if goal.contains("perder") || goal.contains("lose") {
            // Calcular peso objetivo basado en BMI saludable
            let targetBMI: Double
            if bmi > 30 {
                targetBMI = 25.0 // Obesidad → Normal
            } else if bmi > 25 {
                // Para sobrepeso, usar un BMI más realista (23-24 en lugar de 22)
                targetBMI = 23.5 // Sobrepeso → Normal medio
            } else {
                targetBMI = 21.0 // Normal → Delgado
            }
            
            let targetWeight = targetBMI * height * height
            return max(targetWeight, currentWeight * 0.85) // No más del 15% de pérdida inicial
            
        } else if goal.contains("ganar") || goal.contains("gain") {
            // Ganancia de peso para músculo
            let muscleGain = min(currentWeight * 0.15, 10.0) // Máximo 15% o 10kg
            return currentWeight + muscleGain
            
        } else {
            // Mantener peso - usar fórmula más realista para hombres
            let isMale = profile.gender.lowercased().contains("male")
            
            if isMale {
                // Para hombres: usar fórmula de Broca mejorada o BMI 23-24
                let brocaWeight = Double(heightCm - 100)
                let bmiWeight = 23.5 * height * height // BMI 23.5 como punto medio
                
                // Usar el promedio de ambas fórmulas para mayor precisión
                return (brocaWeight + bmiWeight) / 2
            } else {
                // Para mujeres: optimizar a BMI 22
                let optimalBMI = 22.0
                let optimalWeight = optimalBMI * height * height
                return optimalWeight
            }
        }
    }
    
    func calculateTimeline(for profile: UserProfile, weightDifference: Double) -> Int {
        let goal = profile.goal.lowercased()
        let bmi = profile.bmi ?? 25.0
        let activityLevel = profile.levelActivity.lowercased()
        let dietType = profile.dietType.lowercased()
        
        print("🔬 CALCULANDO TIMELINE (FÓRMULA CIENTÍFICA):")
        print("   • Objetivo: \(goal)")
        print("   • BMI: \(bmi)")
        print("   • Diferencia de peso: \(weightDifference) kg")
        
        // ✅ FÓRMULA CIENTÍFICA BASADA EN RESULTSOON
        var baseWeeklyChange: Double = 0.0
        
        if goal.contains("perder") || goal.contains("lose") {
            // Pérdida de peso basada en BMI - DATOS CIENTÍFICOS REALES
            if bmi > 30 {
                baseWeeklyChange = -1.2 // Obesidad: pérdida rápida pero realista
                print("   • Obesidad → Base semanal: -1.2 kg (datos científicos)")
            } else if bmi > 25 {
                baseWeeklyChange = -0.8 // Sobrepeso: pérdida moderada
                print("   • Sobrepeso → Base semanal: -0.8 kg (datos científicos)")
            } else {
                baseWeeklyChange = -0.5 // Normal: pérdida lenta y segura
                print("   • Normal → Base semanal: -0.5 kg (datos científicos)")
            }
            
            // Ajustar por actividad física - DATOS CIENTÍFICOS
            if activityLevel.contains("sedentario") || activityLevel.contains("sedentary") {
                baseWeeklyChange *= 0.8 // Menos actividad = menos pérdida
                print("   • Actividad sedentaria → Multiplicador: 0.8")
            } else if activityLevel.contains("activo") || activityLevel.contains("active") {
                baseWeeklyChange *= 1.2 // Más actividad = más pérdida
                print("   • Actividad alta → Multiplicador: 1.2")
            }
            
        } else if goal.contains("ganar") || goal.contains("gain") {
            baseWeeklyChange = 0.3 // Ganancia realista de músculo
            print("   • Ganancia → Base semanal: +0.3 kg (datos científicos)")
            
        } else {
            // Mantenimiento - calcular timeline basado en optimización hacia peso ideal
            let isMale = profile.gender.lowercased().contains("male")
            let currentBMI = profile.bmi ?? 25.0
            let height = Double(profile.resolvedHeightCm) / 100.0
            
            // Calcular peso ideal
            let idealBMI = isMale ? 23.5 : 22.0
            let idealWeight = idealBMI * height * height
            let currentWeight = profile.weightKg
            let difference = idealWeight - currentWeight
            
            if abs(difference) > 1.0 {
                // Hay diferencia significativa, calcular timeline para optimización
                baseWeeklyChange = difference > 0 ? 0.2 : -0.2 // Cambio pequeño pero más rápido
                print("   • Mantenimiento con optimización → Base semanal: \(baseWeeklyChange) kg")
                print("   • Diferencia con peso ideal: \(String(format: "%.1f", difference)) kg")
            } else {
                // Ya está cerca del peso ideal
                baseWeeklyChange = 0.0
                print("   • Mantenimiento → Ya en peso ideal")
                return 30 // 30 días para mantenimiento puro
            }
        }
        
        // Aplicar efectividad de la dieta - DATOS CIENTÍFICOS REALES
        let dietEffectiveness: Double
        if dietType.contains("keto") {
            dietEffectiveness = 1.3 // Keto: 20-30% más efectivo inicialmente
            print("   • Dieta Keto → Multiplicador: 1.3 (datos científicos)")
        } else if dietType.contains("bajo") && dietType.contains("carb") {
            dietEffectiveness = 1.1 // Bajo carbos: 10-15% más efectivo
            print("   • Dieta baja en carbos → Multiplicador: 1.1 (datos científicos)")
        } else {
            dietEffectiveness = 1.0 // Dieta balanceada: base
            print("   • Dieta balanceada → Multiplicador: 1.0 (datos científicos)")
        }
        
        baseWeeklyChange *= dietEffectiveness
        
        // Aplicar multiplicador adicional por intensidad de entrenamiento - DATOS CIENTÍFICOS
        let workoutMultiplier: Double
        if profile.workoutLevel.lowercased().contains("intensivo") || profile.workoutLevel.lowercased().contains("intense") {
            workoutMultiplier = 1.15 // Entrenamiento intenso: +15% pérdida
            print("   • Entrenamiento intensivo → Multiplicador: 1.15 (datos científicos)")
        } else if profile.workoutLevel.lowercased().contains("intermedio") || profile.workoutLevel.lowercased().contains("moderate") {
            workoutMultiplier = 1.1 // Entrenamiento moderado: +10% pérdida
            print("   • Entrenamiento intermedio → Multiplicador: 1.1 (datos científicos)")
        } else {
            workoutMultiplier = 1.0 // Entrenamiento suave: sin bonus
            print("   • Entrenamiento suave → Multiplicador: 1.0 (datos científicos)")
        }
        
        baseWeeklyChange *= workoutMultiplier
        
        print("🔬 DEBUG MULTIPLICADORES:")
        print("   • Base semanal inicial: \(String(format: "%.2f", baseWeeklyChange / dietEffectiveness / workoutMultiplier))")
        print("   • Después de actividad: \(String(format: "%.2f", baseWeeklyChange / dietEffectiveness / workoutMultiplier))")
        print("   • Después de dieta (\(dietEffectiveness)x): \(String(format: "%.2f", baseWeeklyChange / workoutMultiplier))")
        print("   • Después de entrenamiento (\(workoutMultiplier)x): \(String(format: "%.2f", baseWeeklyChange))")
        print("   • Cambio semanal final: \(String(format: "%.2f", baseWeeklyChange)) kg/semana")
        
        // Límites basados en DATOS CIENTÍFICOS REALES
        if baseWeeklyChange < 0 {
            baseWeeklyChange = max(baseWeeklyChange, -2.0) // Máximo 2kg por semana (solo bajo supervisión médica)
            baseWeeklyChange = min(baseWeeklyChange, -0.3) // Mínimo 0.3kg por semana (pérdida sostenible)
        } else if baseWeeklyChange > 0 {
            baseWeeklyChange = min(baseWeeklyChange, 0.4) // Máximo 0.4kg por semana (ganancia de músculo realista)
        }
        
        print("   • Cambio semanal final (con límites científicos): \(String(format: "%.2f", baseWeeklyChange)) kg/semana")
        
        // Calcular timeline
        guard baseWeeklyChange != 0 else { return 30 }
        
        let weeksNeeded = weightDifference / abs(baseWeeklyChange)
        let daysNeeded = Int(weeksNeeded * 7)
        
        // Límites realistas: entre 2 semanas y 6 meses
        let finalDays = max(14, min(daysNeeded, 180))
        
        print("   • Semanas necesarias: \(String(format: "%.1f", weeksNeeded))")
        print("   • Días necesarios: \(finalDays)")
        
        return finalDays
    }
    
    // ✅ Métodos auxiliares para mantener consistencia con ResultSoon
    private func getActivityMultiplier(for activityLevel: String) -> Double {
        let activity = activityLevel.lowercased()
        
        if activity.contains("sedentario") || activity.contains("sedentary") {
            return 0.8 // Menos activo = menos pérdida
        } else if activity.contains("ligero") || activity.contains("lightly") {
            return 0.9
        } else if activity.contains("moderado") || activity.contains("moderate") {
            return 1.0
        } else if activity.contains("activo") || activity.contains("active") {
            return 1.1
        } else {
            return 1.2 // Muy activo = más pérdida
        }
    }
    
    private func getWorkoutMultiplier(for workoutLevel: String) -> Double {
        let workout = workoutLevel.lowercased()
        
        if workout.contains("suave") || workout.contains("light") {
            return 0.9
        } else if workout.contains("intermedio") || workout.contains("moderate") {
            return 1.0
        } else if workout.contains("intensivo") || workout.contains("intense") {
            return 1.1
        } else {
            return 1.0
        }
    }
    
    private func getDietMultiplier(for dietType: String) -> Double {
        let diet = dietType.lowercased()
        
        if diet.contains("keto") {
            return 1.2 // Keto es más efectivo
        } else if diet.contains("bajo") && diet.contains("carb") {
            return 1.1 // Bajo en carbos es moderadamente efectivo
        } else {
            return 1.0 // Dieta balanceada
        }
    }
    
    // ✅ NUEVO: Multiplicador por frecuencia de ejercicio
    private func getWorkoutFrequencyMultiplier() -> Double {
        let frequency = UserDefaults.standard.string(forKey: "selectedFrequency") ?? "4-5"
        
        switch frequency {
        case "2-3":
            return 0.8 // Menos días = menos progreso
        case "4-5":
            return 1.0 // Frecuencia estándar
        case "6-7":
            return 1.2 // Más días = más progreso
        default:
            return 1.0
        }
    }
    
    // ✅ NUEVO: Multiplicador por edad
    private func getAgeMultiplier(for birthYear: String) -> Double {
        let currentYear = Calendar.current.component(.year, from: Date())
        let age = currentYear - (Int(birthYear) ?? (currentYear - 30))
        
        switch age {
        case 18...25:
            return 1.0 // Metabolismo óptimo
        case 26...35:
            return 0.95 // Ligera reducción
        case 36...45:
            return 0.9 // Reducción moderada
        case 46...55:
            return 0.85 // Reducción significativa
        default:
            return 0.8 // Metabolismo más lento
        }
    }
    
    // ✅ NUEVO: Multiplicador por género
    private func getGenderMultiplier(for gender: String) -> Double {
        let genderLower = gender.lowercased()
        
        if genderLower.contains("male") {
            return 1.0 // Hombres: metabolismo base
        } else if genderLower.contains("female") {
            return 0.9 // Mujeres: metabolismo ligeramente más lento
        } else {
            return 0.95 // Otros: promedio
        }
    }
    
    func calculateWeeklyChange(for profile: UserProfile, weightDifference: Double, timeline: Int) -> Double {
        let goal = profile.goal.lowercased()
        let bmi = profile.bmi ?? 25.0
        
        print("🔬 CALCULANDO WEEKLY CHANGE:")
        print("   • Goal: \(goal)")
        print("   • BMI: \(bmi)")
        print("   • Weight Difference: \(weightDifference) kg")
        print("   • Timeline: \(timeline) days")
        
        // Calcular weekly change basándose en timeline y diferencia de peso
        let weeksInTimeline = Double(timeline) / 7.0
        var weeklyChange: Double = 0.0
        
        if goal.contains("perder") || goal.contains("lose") {
            if weightDifference > 0 && weeksInTimeline > 0 {
                weeklyChange = -weightDifference / weeksInTimeline
                print("   • Pérdida de peso → Weekly Change calculado: \(String(format: "%.2f", weeklyChange)) kg/semana")
            } else {
                // Fallback a valores fijos si no hay timeline válido
                if bmi > 30 {
                    weeklyChange = -0.8
                } else if bmi > 25 {
                    weeklyChange = -0.6
                } else {
                    weeklyChange = -0.4
                }
                print("   • Pérdida de peso → Weekly Change fallback: \(weeklyChange)")
            }
            
        } else if goal.contains("ganar") || goal.contains("gain") {
            if weightDifference > 0 && weeksInTimeline > 0 {
                weeklyChange = weightDifference / weeksInTimeline
                print("   • Ganancia de peso → Weekly Change calculado: \(String(format: "%.2f", weeklyChange)) kg/semana")
            } else {
                weeklyChange = 0.3 // Fallback
                print("   • Ganancia de peso → Weekly Change fallback: \(weeklyChange)")
            }
            
        } else if goal.contains("mantener") || goal.contains("maintain") {
            // Para mantenimiento, usar cambio pequeño
            if abs(weightDifference) > 1.0 && weeksInTimeline > 0 {
                weeklyChange = -weightDifference / weeksInTimeline
                print("   • Mantenimiento → Weekly Change calculado: \(String(format: "%.2f", weeklyChange)) kg/semana")
            } else {
                weeklyChange = 0.0
                print("   • Mantenimiento → Weekly Change: \(weeklyChange)")
            }
            
        } else {
            // Objetivo no reconocido
            weeklyChange = -0.5
            print("   • Objetivo no reconocido → Weekly Change: \(weeklyChange)")
        }
        
        // Limitar a rangos realistas
        if weeklyChange < 0 {
            weeklyChange = max(weeklyChange, -2.0) // Máximo 2kg por semana
            weeklyChange = min(weeklyChange, -0.25) // Mínimo 0.25kg por semana
        } else if weeklyChange > 0 {
            weeklyChange = min(weeklyChange, 1.0) // Máximo 1kg por semana
        }
        
        print("   • Weekly Change final (con límites): \(String(format: "%.2f", weeklyChange))")
        return weeklyChange
    }
    
    func calculateSuccessRate(for profile: UserProfile) -> Int {
        var probability = 70 // Base 70%
        
        let goal = profile.goal.lowercased()
        let activityLevel = profile.levelActivity.lowercased()
        let workoutLevel = profile.workoutLevel.lowercased()
        let dietType = profile.dietType.lowercased()
        
        // Factor 1: Nivel de actividad (15%)
        if activityLevel.contains("activo") || activityLevel.contains("active") {
            probability += 15
        } else if activityLevel.contains("moderado") || activityLevel.contains("moderate") {
            probability += 10
        }
        
        // Factor 2: Intensidad de entrenamiento (10%)
        if workoutLevel.contains("intermedio") || workoutLevel.contains("moderate") {
            probability += 10
        } else if workoutLevel.contains("intensivo") || workoutLevel.contains("intense") {
            probability += 5
        }
        
        // Factor 3: Tipo de dieta (5%)
        if dietType.contains("keto") || dietType.contains("bajo") && dietType.contains("carb") {
            probability += 5
        }
        
        // Factor 4: Objetivo realista (10%)
        if goal.contains("mantener") || goal.contains("maintain") {
            probability += 10
        }
        
        return min(probability, 95) // Máximo 95%
    }
    
    // ✅ MÉTODOS DE CONVENIENCIA PARA GARANTIZAR CONSISTENCIA CON DietViewModel
    func getDailyCaloriesTarget() -> Double {
        let nutritionCalculator = NutritionCalculator()
        return nutritionCalculator.generateNutritionReport().dailyCalories
    }
    
    func calculateRecommendedWaterIntake() -> String {
        let userProfile = UserProfile.loadFromUserDefaults()
        let nutritionCalculator = NutritionCalculator()
        return nutritionCalculator.calculateWaterNeedsSynchronously(for: userProfile)
    }
}

// MARK: - Header Section
private extension ShowInfoView {
    var headerSection: some View {
        VStack(spacing: 0) {
            // Logo arriba - igual que WhichPlaceView
            Image("samsonWhite")
                .resizable()
                .scaledToFit()
                .frame(width: 170)
                .padding(.top, 5)
                .padding(.bottom, -10)
                .opacity(1.0)
            
            // Card con título y subtítulo - igual que WhichPlaceView
            VStack(spacing: 8) {
                Text("YOUR PLAN IS READY")
                    .font(.system(size: 26, weight: .black, design: .default))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                   
                Text("Your personalized fitness and nutrition plan has been created")
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(.black.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 8)
                    .cascadingAppear(index: 1)
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 18)
            .background(Color.yellow.opacity(0.9))
            .cornerRadius(24)
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(Color.black, lineWidth: 4)
            )
            .padding(.horizontal, 24)
            .padding(.bottom, 25)
        }
    }
}

// MARK: - Results Section
private extension ShowInfoView {
    var resultsSection: some View {
        VStack(spacing: 16) {
            // Main target card
            mainTargetCard
            
            // Scientific metrics
            scientificMetricsSection
        }
    }
    
    var mainTargetCard: some View {
        VStack(spacing: 16) {
            Text("Target Weight")
                .font(.system(size: 16, weight: .bold, design: .default))
                .foregroundColor(.black)
            
            Text("\(String(format: "%.1f", nutritionData?.targetWeight ?? 70.0))")
                .font(.system(size: 42, weight: .black, design: .default))
                .foregroundColor(.black)
            
            Text("kg")
                .font(.system(size: 16, weight: .medium, design: .default))
                .foregroundColor(.black.opacity(0.8))
            
            Text("\(String(format: "%.1f", nutritionData?.weightDifference ?? 5.0))kg \(nutritionData?.direction ?? "to lose")")
                .font(.system(size: 14, weight: .medium, design: .default))
                .foregroundColor(.black.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.yellow.opacity(0.9))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.black, lineWidth: 4)
                )
        )
    }
    
    var scientificMetricsSection: some View {
        VStack(spacing: 12) {
            Text("Your Plan Details")
                .font(.system(size: 18, weight: .bold, design: .default))
                .foregroundColor(.black)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                ScientificMetricCard(
                    title: "Timeline",
                    value: "\(nutritionData?.timeline ?? 60) days",
                    icon: "clock.fill",
                    color: .blue
                )
                
                ScientificMetricCard(
                    title: "Weekly Change",
                    value: "\(String(format: "%.2f", abs(nutritionData?.weeklyChange ?? 0.5)))kg",
                    icon: "chart.line.uptrend.xyaxis",
                    color: .green
                )
                
                ScientificMetricCard(
                    title: "Daily Calories",
                    value: "\(nutritionData?.dailyCalories ?? 2000)",
                    icon: "flame.fill",
                    color: .orange
                )
                
                ScientificMetricCard(
                    title: "Water Intake",
                    value: nutritionData?.waterIntake ?? "2.5L",
                    icon: "drop.fill",
                    color: .blue
                )
            }
        }
    }
}

// MARK: - Additional Views Section
private extension ShowInfoView {
    var successIcon: some View {
        ZStack {
            // Success rings
            Circle()
                .stroke(Color.green.opacity(0.3), lineWidth: 3)
                .frame(width: 120, height: 120)
            
            Circle()
                .stroke(Color.green.opacity(0.5), lineWidth: 2)
                .frame(width: 90, height: 90)
            
            // Success icon
            Circle()
                .fill(
                    LinearGradient(
                        colors: [Color.green, Color.green.opacity(0.8)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 70, height: 70)
                .overlay(
                    Circle()
                        .stroke(Color.black, lineWidth: 3)
                )
                .overlay(
                    Image(systemName: "checkmark")
                        .font(.system(size: 35, weight: .bold))
                        .foregroundColor(.white)
                )
        }
    }
    
    var infoCardsSection: some View {
        VStack(spacing: 16) {
            // Plan ready card
            infoCard(
                title: "Personalized Plan",
                description: "Your fitness and nutrition plan has been customized based on your goals and preferences",
                icon: "person.fill.checkmark",
                color: .blue
            )
            
            // Success rate card
            infoCard(
                title: "Success Rate",
                description: "\(nutritionData?.successRate ?? 85)% chance of achieving your goal with this plan",
                icon: "checkmark.circle.fill",
                color: .green
            )
        }
    }
    
    func infoCard(title: String, description: String, icon: String, color: Color) -> some View {
        HStack(spacing: 16) {
            // Icon
            Image(systemName: icon)
                .font(.system(size: 24, weight: .medium))
                .foregroundColor(color)
                .frame(width: 50, height: 50)
                .background(
                    Circle()
                        .fill(color.opacity(0.1))
                        .overlay(
                            Circle()
                                .stroke(color, lineWidth: 2)
                        )
                )
            
            // Text content
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .bold, design: .default))
                    .foregroundColor(.black)
                
                Text(description)
                    .font(.system(size: 14, weight: .medium, design: .default))
                    .foregroundColor(.black.opacity(0.7))
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.yellow.opacity(0.3))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.black, lineWidth: 2)
                )
        )
    }
}

// MARK: - ScientificMetricCard View
struct ScientificMetricCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(color)
            
            Text(value)
                .font(.system(size: 14, weight: .bold, design: .default))
                .foregroundColor(.black)
            
            Text(title)
                .font(.system(size: 11, weight: .medium, design: .default))
                .foregroundColor(.black.opacity(0.7))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.yellow.opacity(0.9))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.black, lineWidth: 2)
                )
        )
    }
}

// MARK: - Navigation Buttons Section
private extension ShowInfoView {
    var navigationButtonsSection: some View {
        VStack(spacing: 16) {
            // Back button
            Button(action: {
                let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                impactFeedback.impactOccurred()
                presentationMode.wrappedValue.dismiss()
            }) {
                HStack(spacing: 10) {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 16, weight: .bold))
                    
                    Text("Back")
                        .font(.system(size: 18, weight: .bold, design: .default))
                }
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.gray.opacity(0.2))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.black, lineWidth: 3)
                        )
                )
            }
            
            // Start Journey button
            Button(action: {
                let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
                impactFeedback.impactOccurred()
                navigateToDashboard = true
            }) {
                HStack(spacing: 10) {
                    Text("Start Journey")
                        .font(.system(size: 18, weight: .bold, design: .default))
                    
                    Image(systemName: "arrow.right")
                        .font(.system(size: 16, weight: .bold))
                }
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.yellow.opacity(0.9))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.black, lineWidth: 4)
                        )
                )
            }
            
            // Navigation link
            NavigationLink(
                destination: DashboardView(),
                isActive: $navigateToDashboard
            ) {
                EmptyView()
            }
            .hidden()
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 40)
    }
}

// MARK: - Preview
struct ShowInfoView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ShowInfoView()
        }
        .preferredColorScheme(.light)
    }
}
