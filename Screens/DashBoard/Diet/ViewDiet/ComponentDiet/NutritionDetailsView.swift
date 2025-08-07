/*import SwiftUI

// MARK: - Nutrition Details View

struct NutritionDetailsView: View {
    let vm: DietViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header con información del usuario
                    userProfileCard
                    
                    // Resumen calórico
                    caloricSummaryCard
                    
                    // Distribución por comidas
                    mealDistributionCard
                    
                    // Progreso semanal
                    weeklyProgressCard
                    
                    // Recomendaciones
                    recommendationsCard
                }
                .padding()
            }
            .background(Color.black.ignoresSafeArea())
            .navigationTitle("Análisis Nutricional")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cerrar") {
                        dismiss()
                    }
                    .foregroundColor(.yellow)
                }
            }
        }
        .preferredColorScheme(.dark)
    }
    
    private var userProfileCard: some View {
        let nutritionInfo = vm.getNutritionInfo()
        
        return VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "person.circle.fill")
                    .font(.title2)
                    .foregroundColor(.yellow)
                
                Text("Tu Perfil Nutricional")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Spacer()
            }
            
            HStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Objetivo Diario")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                    Text("\(nutritionInfo.dailyCalories) kcal")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.yellow)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Hidratación")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                    Text(nutritionInfo.waterRecommendation)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.cyan)
                }
                
                Spacer()
            }
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(16)
    }
    
    private var caloricSummaryCard: some View {
        let daySummary = vm.getDaySummary()
        let targetStatus = vm.isOnTarget()
        
        return VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "flame.circle.fill")
                    .font(.title2)
                    .foregroundColor(.orange)
                
                Text("Resumen Calórico")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Spacer()
            }
            
            // Gráfico de progreso circular
            HStack(spacing: 30) {
                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.2), lineWidth: 8)
                        .frame(width: 80, height: 80)
                    
                    Circle()
                        .trim(from: 0, to: daySummary.progress)
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [.yellow, .orange]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            style: StrokeStyle(lineWidth: 8, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                        .animation(.easeInOut(duration: 1.0), value: daySummary.progress)
                    
                    VStack(spacing: 2) {
                        Text("\(String(format: "%.0f", daySummary.progress * 100))%")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text("Completado")
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Consumido")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                        Text("\(Int(daySummary.consumedCalories)) kcal")
                            .font(.body)
                            .fontWeight(.semibold)
                            .foregroundColor(.yellow)
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Restante")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                        Text("\(Int(daySummary.remainingCalories)) kcal")
                            .font(.body)
                            .fontWeight(.semibold)
                            .foregroundColor(.orange)
                    }
                }
                
                Spacer()
            }
            
            // Status
            Text(targetStatus.message)
                .font(.subheadline)
                .foregroundColor(targetStatus.color)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(targetStatus.color.opacity(0.2))
                .cornerRadius(8)
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(16)
    }
    
    private var mealDistributionCard: some View {
        let mealDistribution = vm.getMealDistribution()
        let daySummary = vm.getDaySummary()
        
        return VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "chart.pie.fill")
                    .font(.title2)
                    .foregroundColor(.green)
                
                Text("Distribución por Comidas")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Spacer()
            }
            
            VStack(spacing: 12) {
                ForEach(MealType.allCases, id: \.self) { mealType in
                    mealProgressRow(
                        mealType: mealType,
                        targetCalories: mealDistribution[mealType] ?? 0,
                        mealSummary: daySummary.mealSummaries[mealType]
                    )
                }
            }
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(16)
    }
    
    private func mealProgressRow(mealType: MealType, targetCalories: Double, mealSummary: MealSummary?) -> some View {
        let progress = mealSummary?.progress ?? 0
        let consumedCalories = mealSummary?.consumedCalories ?? 0
        
        return VStack(spacing: 6) {
            HStack {
                Text(mealType.displayName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                
                Spacer()
                
                Text("\(Int(consumedCalories)) / \(Int(targetCalories)) kcal")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.white.opacity(0.2))
                        .frame(height: 6)
                        .cornerRadius(3)
                    
                    Rectangle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [mealTypeColor(mealType), mealTypeColor(mealType).opacity(0.7)]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * progress, height: 6)
                        .cornerRadius(3)
                        .animation(.easeInOut(duration: 0.5), value: progress)
                }
            }
            .frame(height: 6)
        }
    }
    
    private func mealTypeColor(_ mealType: MealType) -> Color {
        switch mealType {
        case .Breakfast:
            return .orange
        case .Lunch:
            return .green
        case .Dinner:
            return .purple
        }
    }
    
    private var weeklyProgressCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "calendar")
                    .font(.title2)
                    .foregroundColor(.blue)
                
                Text("Progreso Semanal")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Spacer()
            }
            
            HStack(spacing: 8) {
                ForEach(vm.days, id: \.self) { day in
                    weeklyDayView(day: day)
                }
            }
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(16)
    }
    
    private func weeklyDayView(day: Date) -> some View {
        let isToday = Calendar.current.isDate(day, inSameDayAs: Date())
        let isPast = day < Date()
        let isSelected = Calendar.current.isDate(day, inSameDayAs: vm.selectedDay)
        
        return VStack(spacing: 4) {
            Text(DateFormatter.shortDay.string(from: day))
                .font(.caption2)
                .foregroundColor(.white.opacity(0.7))
            
            Circle()
                .fill(circleColor(isToday: isToday, isPast: isPast, isSelected: isSelected))
                .frame(width: 30, height: 30)
                .overlay(
                    Text("\(Calendar.current.component(.day, from: day))")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(textColor(isToday: isToday, isPast: isPast, isSelected: isSelected))
                )
        }
        .frame(maxWidth: .infinity)
    }
    
    private func circleColor(isToday: Bool, isPast: Bool, isSelected: Bool) -> Color {
        if isToday {
            return .yellow
        } else if isSelected {
            return .blue
        } else if isPast {
            return .green.opacity(0.3)
        } else {
            return .white.opacity(0.2)
        }
    }
    
    private func textColor(isToday: Bool, isPast: Bool, isSelected: Bool) -> Color {
        if isToday {
            return .black
        } else if isSelected {
            return .white
        } else {
            return .white
        }
    }
    
    private var recommendationsCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .font(.title2)
                    .foregroundColor(.yellow)
                
                Text("Recomendaciones")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 12) {
                recommendationRow(
                    icon: "drop.fill",
                    iconColor: .cyan,
                    title: "Hidratación",
                    description: "Bebe \(vm.calculateRecommendedWaterIntake()) de agua diariamente"
                )
                
                recommendationRow(
                    icon: "moon.fill",
                    iconColor: .purple,
                    title: "Descanso",
                    description: "Duerme 7-9 horas para optimizar tu metabolismo"
                )
                
                recommendationRow(
                    icon: "figure.walk",
                    iconColor: .green,
                    title: "Actividad",
                    description: "Mantén tu nivel de actividad para cumplir tus objetivos"
                )
                
                let targetStatus = vm.isOnTarget()
                switch targetStatus {
                case .underTarget(let deficit):
                    recommendationRow(
                        icon: "plus.circle.fill",
                        iconColor: .orange,
                        title: "Calorías",
                        description: "Agrega \(Int(deficit)) kcal más para alcanzar tu objetivo"
                    )
                case .overTarget(let surplus):
                    recommendationRow(
                        icon: "minus.circle.fill",
                        iconColor: .red,
                        title: "Calorías",
                        description: "Has excedido tu objetivo por \(Int(surplus)) kcal"
                    )
                case .onTarget:
                    recommendationRow(
                        icon: "checkmark.circle.fill",
                        iconColor: .green,
                        title: "¡Perfecto!",
                        description: "Estás cumpliendo exactamente tu objetivo calórico"
                    )
                }
            }
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(16)
    }
    
    private func recommendationRow(icon: String, iconColor: Color, title: String, description: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.body)
                .foregroundColor(iconColor)
                .frame(width: 20)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
        }
    }
}

// MARK: - Macro Breakdown View

struct MacroBreakdownView: View {
    let vm: DietViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    macroSummaryCard
                    macroChartsCard
                    macroRecommendationsCard
                }
                .padding()
            }
            .background(Color.black.ignoresSafeArea())
            .navigationTitle("Macronutrientes")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cerrar") {
                        dismiss()
                    }
                    .foregroundColor(.yellow)
                }
            }
        }
        .preferredColorScheme(.dark)
    }
    
    private var macroSummaryCard: some View {
        let macros = vm.getMacroTargets()
        
        return VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "chart.bar.fill")
                    .font(.title2)
                    .foregroundColor(.yellow)
                
                Text("Distribución de Macros")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Spacer()
            }
            
            HStack(spacing: 20) {
                macroColumn(
                    title: "Proteína",
                    grams: macros.protein,
                    percentage: macros.proteinPercentage,
                    color: .red
                )
                
                macroColumn(
                    title: "Grasa",
                    grams: macros.fat,
                    percentage: macros.fatPercentage,
                    color: .orange
                )
                
                macroColumn(
                    title: "Carbohidratos",
                    grams: macros.carbs,
                    percentage: macros.carbPercentage,
                    color: .green
                )
            }
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(16)
    }
    
    private func macroColumn(title: String, grams: Double, percentage: Double, color: Color) -> some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
            
            Text("\(String(format: "%.1f", grams))g")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text("\(String(format: "%.1f", percentage))%")
                .font(.caption)
                .foregroundColor(.white.opacity(0.8))
        }
        .frame(maxWidth: .infinity)
    }
    
    private var macroChartsCard: some View {
        let macros = vm.getMacroTargets()
        
        return VStack(alignment: .leading, spacing: 16) {
            Text("Gráfico de Macros")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            ZStack {
                // Gráfico de dona simple
                Circle()
                    .stroke(Color.white.opacity(0.2), lineWidth: 20)
                    .frame(width: 150, height: 150)
                
                // Segmentos de macros (simplificado)
                Circle()
                    .trim(from: 0, to: macros.proteinPercentage / 100)
                    .stroke(Color.red, lineWidth: 20)
                    .frame(width: 150, height: 150)
                    .rotationEffect(.degrees(-90))
                
                VStack {
                    Text("\(Int(macros.calories))")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("kcal/día")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            .frame(maxWidth: .infinity)
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(16)
    }
    
    private var macroRecommendationsCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Recomendaciones de Macros")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            VStack(alignment: .leading, spacing: 12) {
                macroRecommendationRow(
                    color: .red,
                    title: "Proteína",
                    description: "Esencial para construir y reparar músculos. Consume con cada comida."
                )
                
                macroRecommendationRow(
                    color: .orange,
                    title: "Grasa",
                    description: "Importante para hormonas y absorción de vitaminas. Prefiere grasas saludables."
                )
                
                macroRecommendationRow(
                    color: .green,
                    title: "Carbohidratos",
                    description: "Principal fuente de energía. Consume más antes y después del ejercicio."
                )
            }
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(16)
    }
    
    private func macroRecommendationRow(color: Color, title: String, description: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Circle()
                .fill(color)
                .frame(width: 12, height: 12)
                .padding(.top, 4)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
        }
    }
}

// MARK: - Preview

struct NutritionDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        NutritionDetailsView(vm: DietViewModel())
    }
 }*/
