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
    }
    
    func calculateTargetWeight(for profile: UserProfile) -> Double {
        let currentWeight = profile.weightKg
        let goal = profile.goal.lowercased()
        let bmi = profile.bmi ?? 25.0
        let height = Double(profile.resolvedHeightCm) / 100.0 // convertir a metros
        
        print("🔬 CALCULANDO PESO OBJETIVO:")
        print("   • Peso actual: \(currentWeight) kg")
        print("   • BMI actual: \(bmi)")
        print("   • Altura: \(height) m")
        print("   • Objetivo: \(goal)")
        
        if goal.contains("perder") || goal.contains("lose") {
            // ✅ CORREGIDO: Calcular peso objetivo basado en BMI saludable
            let targetBMI: Double
            if bmi > 30 {
                targetBMI = 25.0 // Obesidad → Normal
                print("   • Obesidad → BMI objetivo: \(targetBMI)")
            } else if bmi > 25 {
                targetBMI = 22.0 // Sobrepeso → Normal bajo
                print("   • Sobrepeso → BMI objetivo: \(targetBMI)")
            } else {
                targetBMI = 20.0 // Normal → Delgado
                print("   • Normal → BMI objetivo: \(targetBMI)")
            }
            
            let targetWeight = targetBMI * height * height
            let maxLoss = currentWeight * 0.15 // Máximo 15% de pérdida inicial
            let finalTarget = max(targetWeight, currentWeight - maxLoss)
            
            print("   • Peso objetivo calculado: \(targetWeight) kg")
            print("   • Pérdida máxima inicial: \(maxLoss) kg")
            print("   • Peso objetivo final: \(finalTarget) kg")
            
            return finalTarget
            
        } else if goal.contains("ganar") || goal.contains("gain") {
            // ✅ CORREGIDO: Ganancia de peso para músculo
            let muscleGain = min(currentWeight * 0.15, 10.0) // Máximo 15% o 10kg
            let targetWeight = currentWeight + muscleGain
            
            print("   • Ganancia de músculo: \(muscleGain) kg")
            print("   • Peso objetivo: \(targetWeight) kg")
            
            return targetWeight
            
        } else {
            // ✅ CORREGIDO: Mantener peso actual (con pequeña optimización)
            let optimalBMI = 22.0 // BMI óptimo
            let optimalWeight = optimalBMI * height * height
            
            print("   • Mantenimiento → BMI óptimo: \(optimalBMI)")
            print("   • Peso óptimo: \(optimalWeight) kg")
            
            return optimalWeight
        }
    }
    
    func calculateTimeline(for profile: UserProfile, weightDifference: Double) -> Int {
        let goal = profile.goal.lowercased()
        let dietType = profile.dietType.lowercased()
        let workoutLevel = profile.workoutLevel.lowercased()
        let activityLevel = profile.levelActivity.lowercased()
        let bmi = profile.bmi ?? 25.0
        
        print("🔬 CALCULANDO TIMELINE:")
        print("   • Objetivo: \(goal)")
        print("   • BMI: \(bmi)")
        print("   • Diferencia de peso: \(weightDifference) kg")
        
        // ✅ MEJORADO: Base semanal según BMI y objetivo
        var baseWeeklyChange: Double
        
        if goal.contains("perder") || goal.contains("lose") {
            if bmi > 30 {
                baseWeeklyChange = -0.8 // Obesidad: pérdida más rápida
                print("   • Obesidad → Base semanal: -0.8 kg")
            } else if bmi > 25 {
                baseWeeklyChange = -0.6 // Sobrepeso: pérdida moderada
                print("   • Sobrepeso → Base semanal: -0.6 kg")
            } else {
                baseWeeklyChange = -0.4 // Normal: pérdida lenta
                print("   • Normal → Base semanal: -0.4 kg")
            }
        } else if goal.contains("ganar") || goal.contains("gain") {
            baseWeeklyChange = 0.3 // Ganancia moderada
            print("   • Ganancia → Base semanal: +0.3 kg")
        } else {
            return 30 // Mantenimiento
        }
        
        // ✅ NUEVO: Ajustar por frecuencia de ejercicio (días por semana)
        let workoutFrequencyMultiplier = getWorkoutFrequencyMultiplier()
        baseWeeklyChange *= workoutFrequencyMultiplier
        print("   • Frecuencia de ejercicio: \(workoutFrequencyMultiplier)x")
        
        // ✅ Ajustar por nivel de actividad diaria
        let activityMultiplier = getActivityMultiplier(for: activityLevel)
        baseWeeklyChange *= activityMultiplier
        print("   • Nivel de actividad: \(activityMultiplier)x")
        
        // ✅ Ajustar por intensidad de entrenamiento
        let workoutMultiplier = getWorkoutMultiplier(for: workoutLevel)
        baseWeeklyChange *= workoutMultiplier
        print("   • Intensidad de entrenamiento: \(workoutMultiplier)x")
        
        // ✅ Ajustar por tipo de dieta
        let dietMultiplier = getDietMultiplier(for: dietType)
        baseWeeklyChange *= dietMultiplier
        print("   • Tipo de dieta: \(dietMultiplier)x")
        
        // ✅ NUEVO: Ajustar por edad (metabolismo más lento con la edad)
        let ageMultiplier = getAgeMultiplier(for: profile.birthYear)
        baseWeeklyChange *= ageMultiplier
        print("   • Factor edad: \(ageMultiplier)x")
        
        // ✅ NUEVO: Ajustar por género (diferencias metabólicas)
        let genderMultiplier = getGenderMultiplier(for: profile.gender)
        baseWeeklyChange *= genderMultiplier
        print("   • Factor género: \(genderMultiplier)x")
        
        print("   • Cambio semanal final: \(String(format: "%.2f", baseWeeklyChange)) kg")
        
        // ✅ Calcular timeline basado en cambio semanal realista
        let weeksNeeded = weightDifference / abs(baseWeeklyChange)
        let daysNeeded = Int(weeksNeeded * 7)
        
        let finalDays = max(14, min(daysNeeded, 365)) // Entre 2 semanas y 1 año
        
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
        
        if goal.contains("mantener") || goal.contains("maintain") {
            return 0.0
        }
        
        // ✅ MEJORADO: Usar la misma lógica completa que calculateTimeline
        var baseWeeklyChange: Double
        
        if goal.contains("perder") || goal.contains("lose") {
            if bmi > 30 {
                baseWeeklyChange = -0.8 // Obesidad: pérdida más rápida
            } else if bmi > 25 {
                baseWeeklyChange = -0.6 // Sobrepeso: pérdida moderada
            } else {
                baseWeeklyChange = -0.4 // Normal: pérdida lenta
            }
        } else if goal.contains("ganar") || goal.contains("gain") {
            baseWeeklyChange = 0.3 // Ganancia moderada
        } else {
            return 0.0
        }
        
        // ✅ APLICAR TODOS LOS MULTIPLICADORES
        let workoutFrequencyMultiplier = getWorkoutFrequencyMultiplier()
        let activityMultiplier = getActivityMultiplier(for: profile.levelActivity.lowercased())
        let workoutMultiplier = getWorkoutMultiplier(for: profile.workoutLevel.lowercased())
        let dietMultiplier = getDietMultiplier(for: profile.dietType.lowercased())
        let ageMultiplier = getAgeMultiplier(for: profile.birthYear)
        let genderMultiplier = getGenderMultiplier(for: profile.gender)
        
        baseWeeklyChange *= workoutFrequencyMultiplier * activityMultiplier * workoutMultiplier * dietMultiplier * ageMultiplier * genderMultiplier
        
        // Limitar a rangos realistas (mismos que ResultSoon)
        if baseWeeklyChange < 0 {
            baseWeeklyChange = max(baseWeeklyChange, -1.0) // Máximo 1kg por semana
            baseWeeklyChange = min(baseWeeklyChange, -0.25) // Mínimo 0.25kg por semana
        } else if baseWeeklyChange > 0 {
            baseWeeklyChange = min(baseWeeklyChange, 0.5) // Máximo 0.5kg por semana
        }
        
        return baseWeeklyChange
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
