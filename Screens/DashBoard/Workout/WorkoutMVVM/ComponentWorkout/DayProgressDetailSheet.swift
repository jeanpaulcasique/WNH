import SwiftUI
import Charts

// MARK: - Day Progress Detail Sheet
struct DayProgressDetailSheet: View {
    let date: Date
    @ObservedObject var progressManager: WorkoutProgressManager
    @ObservedObject var workoutViewModel: WorkoutViewModel
    @Environment(\.dismiss) private var dismiss
    
    private var dayProgress: DayProgress {
        progressManager.getProgress(for: date)
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 25) {
                    // Gesture para cerrar teclado
                    Color.clear
                        .frame(height: 1)
                        .onTapGesture {
                            hideKeyboard()
                        }
                    // Header con fecha
                    VStack(spacing: 8) {
                        Text(formattedDate)
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("Day Progress")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 20)
                    
                    // Gráfico circular de progreso general
                    OverallProgressView(progress: dayProgress)
                    
                    // Métricas principales
                    MetricsGridView(progress: dayProgress, workoutViewModel: workoutViewModel, date: date)
                    
                    // Sección de pasos
                    StepsSectionView(
                        workoutViewModel: workoutViewModel,
                        date: date
                    )
                    
                    // Gráficos detallados
                    DetailedChartsView(progress: dayProgress, workoutViewModel: workoutViewModel)
                    
                    Spacer(minLength: 100)
                }
                .padding(.horizontal, 20)
            }
            .background(
                ZStack {
                    LinearGradient(
                        colors: [
                            Color.black.opacity(0.95),
                            Color.gray.opacity(0.2),
                            Color.black.opacity(0.95)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    Rectangle()
                        .fill(.ultraThinMaterial)
                        .opacity(0.1)
                }
                .ignoresSafeArea()
            )
            .onTapGesture {
                hideKeyboard()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
        }
        .preferredColorScheme(.dark)
    }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.locale = Locale(identifier: "en_US")
        return formatter.string(from: date)
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

// MARK: - Overall Progress View
struct OverallProgressView: View {
    let progress: DayProgress
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.1), lineWidth: 8)
                    .frame(width: 200, height: 200)
                
                Circle()
                    .trim(from: 0, to: progress.completionPercentage)
                    .stroke(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 0.7), value: progress.completionPercentage)
                
                VStack(spacing: 3) {
                    Text("\(Int(progress.completionPercentage * 100))%")
                        .font(.title)
                        .fontWeight(.bold)
                    Text("Completado")
                        .font(.title2)
                        .foregroundColor(.secondary)
                }
            }
            
            Text("Overall Progress")
                .font(.subheadline)
                .foregroundColor(.white)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(Color.white.opacity(0.05))
        .cornerRadius(8)
    }
}

// MARK: - Metrics Grid View
struct MetricsGridView: View {
    let progress: DayProgress
    @ObservedObject var workoutViewModel: WorkoutViewModel
    let date: Date
    @State private var heartRateForDate: Double? = nil
    @State private var isLoadingHeartRate: Bool = false
    @State private var caloriesForDate: Double = 0.0
    @State private var isLoadingCalories: Bool = false
    
    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 3), spacing: 16) {
            MetricCard(
                title: "Exercises",
                value: "\(progress.exercisesCompleted)/\(progress.totalExercises)",
                icon: "dumbbell.fill",
                color: .blue
            )
            
            MetricCard(
                title: "Time",
                value: "\(progress.workoutDurationMinutes) min",
                icon: "clock.fill",
                color: .green
            )
            
            MetricCard(
                title: "Calories",
                value: getCaloriesDisplayValue(),
                icon: "flame.fill",
                color: .orange
            )
            
            MetricCard(
                title: "Steps",
                value: getStepsDisplayValue(),
                icon: "figure.walk",
                color: .green
            )
            
            MetricCard(
                title: "Heart Rate",
                value: getHeartRateDisplayValue(),
                icon: "heart.fill",
                color: .red
            )
            
            EditableWeightCard(
                currentWeight: Binding(
                    get: { workoutViewModel.userPreferencesService.currentUserWeight },
                    set: { newWeight in
                        workoutViewModel.userPreferencesService.userWeight = newWeight
                    }
                ),
                isCurrentDay: Calendar.current.isDateInToday(date),
                onWeightChanged: { newWeight in
                    workoutViewModel.userPreferencesService.userWeight = newWeight
                }
            )
        }
        .onAppear {
            loadHeartRateForDate()
            loadCaloriesForDate()
        }
    }
    
    private func loadHeartRateForDate() {
        isLoadingHeartRate = true
        workoutViewModel.getHeartRateForDateFromHealthKit(date) { heartRate in
            DispatchQueue.main.async {
                self.heartRateForDate = heartRate
                self.isLoadingHeartRate = false
            }
        }
    }
    
    private func loadCaloriesForDate() {
        isLoadingCalories = true
        workoutViewModel.getActiveCaloriesForDate(date) { calories in
            DispatchQueue.main.async {
                self.caloriesForDate = calories
                self.isLoadingCalories = false
            }
        }
    }
    
    private func getCaloriesDisplayValue() -> String {
        if isLoadingCalories {
            return "Loading..."
        }
        
        if caloriesForDate > 0 {
            return "\(Int(caloriesForDate))"
        }
        
        // Si no hay datos de HealthKit, usar los datos del progreso local
        if progress.caloriesBurned > 0 {
            return "\(Int(progress.caloriesBurned))"
        }
        
        return "0"
    }
    
    private func getHeartRateDisplayValue() -> String {
        if isLoadingHeartRate {
            return "Loading..."
        }
        
        // Si tenemos datos históricos del día, usarlos
        if let historicalHeartRate = heartRateForDate, historicalHeartRate > 0 {
            return "\(Int(historicalHeartRate)) bpm"
        }
        
        // Si no hay datos históricos pero tenemos ritmo actual, usarlo
        if let currentHeartRate = workoutViewModel.heartRate, currentHeartRate > 0 {
            return "\(Int(currentHeartRate)) bpm"
        }
        
        // Si no hay datos, mostrar "--"
        return "--"
    }
    
    private func getStepsDisplayValue() -> String {
        let stepsTaken = workoutViewModel.getStepsForDate(date)
        return "\(stepsTaken)"
    }
}

// MARK: - Metric Card
struct MetricCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
    }
}

// MARK: - Editable Weight Card
struct EditableWeightCard: View {
    @Binding var currentWeight: Double
    let isCurrentDay: Bool
    let onWeightChanged: (Double) -> Void
    
    @State private var isEditing = false
    @State private var editedWeight: String = ""
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                // Icono de balanza centrado
                Image(systemName: "scalemass")
                    .font(.title2)
                    .foregroundColor(.purple)
                
                // Icono de lápiz en la esquina superior derecha (solo para día actual)
                if !isEditing && isCurrentDay {
                    VStack {
                        HStack {
                            Spacer()
                            Image(systemName: "pencil.circle.fill")
                                .font(.caption)
                                .foregroundColor(.purple.opacity(0.7))
                        }
                        Spacer()
                    }
                }
            }
            
            if isEditing {
                TextField("Weight", text: $editedWeight)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .keyboardType(.decimalPad)
                    .focused($isTextFieldFocused)
                    .toolbar {
                        ToolbarItemGroup(placement: .keyboard) {
                            Spacer()
                            Button("Done") {
                                saveWeight()
                            }
                            .foregroundColor(.purple)
                        }
                    }
                    .onSubmit {
                        saveWeight()
                    }
                    .onAppear {
                        editedWeight = String(format: "%.1f", currentWeight)
                        isTextFieldFocused = true
                    }
            } else {
                Text("\(String(format: "%.1f", currentWeight)) kg")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .onTapGesture {
                        if isCurrentDay {
                            startEditing()
                        }
                    }
            }
            
            Text("Weight")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isEditing ? Color.purple.opacity(0.5) : Color.clear, lineWidth: 1)
        )
        .onTapGesture {
            if !isEditing && isCurrentDay {
                startEditing()
            }
        }
        .onChange(of: isTextFieldFocused) { oldValue, newValue in
            if !newValue && isEditing {
                // Si perdió el foco y está editando, guardar
                saveWeight()
            }
        }
    }
    
    private func startEditing() {
        isEditing = true
        editedWeight = String(format: "%.1f", currentWeight)
    }
    
    private func saveWeight() {
        if let newWeight = Double(editedWeight), newWeight > 0 {
            onWeightChanged(newWeight)
        }
        isEditing = false
        isTextFieldFocused = false
    }
}

// MARK: - Steps Section View
struct StepsSectionView: View {
    @ObservedObject var workoutViewModel: WorkoutViewModel
    let date: Date
    
    private var steps: Int {
        workoutViewModel.getStepsForDate(date)
    }
    
    private var dailyGoal: Int {
        workoutViewModel.userPreferencesService.recommendedDailySteps
    }
    
    private var weeklyAverage: Int {
        workoutViewModel.getWeeklyAverageSteps()
    }
    
    private var progressPercentage: Double {
        guard dailyGoal > 0 else { return 0 }
        return min(Double(steps) / Double(dailyGoal), 1.0)
    }
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "shoe")
                    .foregroundColor(.green)
                    .font(.title2)
                Text("Daily Steps")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
            }
            
            VStack(spacing: 12) {
                // Pasos actuales
                HStack {
                    Text("\(steps)")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.green)
                    Text("steps")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                }
                
                // Explicación del promedio recomendado
                HStack {
                    Text("Average based on your data:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("\(dailyGoal) steps/day")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.blue)
                }
                
                // Barra de progreso
                VStack(spacing: 8) {
                    HStack {
                        Text("Goal: \(dailyGoal)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("\(Int(progressPercentage * 100))%")
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                    
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .fill(Color.white.opacity(0.1))
                                .frame(height: 8)
                                .cornerRadius(4)
                            
                            Rectangle()
                                .fill(Color.green)
                                .frame(width: geometry.size.width * progressPercentage, height: 8)
                                .cornerRadius(4)
                                .animation(.easeInOut(duration: 0.5), value: progressPercentage)
                        }
                    }
                    .frame(height: 8)
                }
                
                // Estadísticas adicionales
                HStack(spacing: 20) {
                    VStack(spacing: 4) {
                        Text("\(dailyGoal)")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.blue)
                        Text("Daily Average")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    VStack(spacing: 4) {
                        if steps >= dailyGoal {
                            Text("+\(steps - dailyGoal)")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundColor(.green)
                            Text("Extra!")
                                .font(.caption)
                                .foregroundColor(.green)
                        } else {
                            Text("\(dailyGoal - steps)")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundColor(.orange)
                            Text("Remaining")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .padding(16)
            .background(Color.white.opacity(0.05))
            .cornerRadius(12)
        }
    }
}

// MARK: - Detailed Charts View
struct DetailedChartsView: View {
    let progress: DayProgress
    @ObservedObject var workoutViewModel: WorkoutViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            // Gráfico de progreso de peso hacia BMI ideal
            WeightProgressChart(workoutViewModel: workoutViewModel)
            
            // Gráfico de progreso semanal
            WeeklyProgressChart()
        }
    }
}

// MARK: - Weight Progress Chart
struct WeightProgressChart: View {
    @ObservedObject var workoutViewModel: WorkoutViewModel
    
    private var currentWeight: Double {
        workoutViewModel.userPreferencesService.userWeight
    }
    
    private var idealWeight: Double {
        workoutViewModel.userPreferencesService.idealWeight
    }
    
    private var currentBMI: Double {
        workoutViewModel.userPreferencesService.bmi
    }
    
    private var idealBMI: Double {
        // BMI ideal está entre 18.5 y 24.9, usamos 22 como punto medio
        22.0
    }
    
    private var weightProgress: Double {
        guard idealWeight > 0 else { return 0 }
        
        // Si el peso actual es mayor al ideal, calculamos progreso hacia abajo
        if currentWeight > idealWeight {
            let totalToLose = currentWeight - idealWeight
            let lost = max(0, currentWeight - idealWeight) // Asumiendo que empezó más alto
            return min(lost / totalToLose, 1.0)
        } else {
            // Si el peso actual es menor al ideal, calculamos progreso hacia arriba
            let totalToGain = idealWeight - currentWeight
            let gained = max(0, idealWeight - currentWeight) // Asumiendo que empezó más bajo
            return min(gained / totalToGain, 1.0)
        }
    }
    
    private var bmiProgress: Double {
        guard currentBMI > 0 else { return 0 }
        
        // Calculamos progreso hacia BMI ideal (22)
        if currentBMI > idealBMI {
            // Si BMI actual es alto, progreso hacia abajo
            let maxBMI = 40.0 // BMI máximo para el cálculo
            let totalRange = maxBMI - idealBMI
            let currentRange = currentBMI - idealBMI
            return max(0, 1 - (currentRange / totalRange))
        } else {
            // Si BMI actual es bajo, progreso hacia arriba
            let minBMI = 16.0 // BMI mínimo para el cálculo
            let totalRange = idealBMI - minBMI
            let currentRange = idealBMI - currentBMI
            return max(0, 1 - (currentRange / totalRange))
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Weight Progress")
                .font(.headline)
                .foregroundColor(.white)
            
            VStack(spacing: 12) {
                // Información actual
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Current Weight")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("\(Int(currentWeight)) kg")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Ideal Weight")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("\(Int(idealWeight)) kg")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                    }
                }
                
                // Barra de progreso de peso
                VStack(spacing: 8) {
                    HStack {
                        Text("Weight Progress")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("\(Int(weightProgress * 100))%")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                    
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .fill(Color.white.opacity(0.1))
                                .frame(height: 8)
                                .cornerRadius(4)
                            
                            Rectangle()
                                .fill(Color.blue)
                                .frame(width: geometry.size.width * weightProgress, height: 8)
                                .cornerRadius(4)
                                .animation(.easeInOut(duration: 0.5), value: weightProgress)
                        }
                    }
                    .frame(height: 8)
                }
                
                // Información de BMI
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Current BMI")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(String(format: "%.1f", currentBMI))
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Ideal BMI")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(String(format: "%.1f", idealBMI))
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                    }
                }
                
                // Barra de progreso de BMI
                VStack(spacing: 8) {
                    HStack {
                        Text("BMI Progress")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("\(Int(bmiProgress * 100))%")
                            .font(.caption)
                            .foregroundColor(.purple)
                    }
                    
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .fill(Color.white.opacity(0.1))
                                .frame(height: 8)
                                .cornerRadius(4)
                            
                            Rectangle()
                                .fill(Color.purple)
                                .frame(width: geometry.size.width * bmiProgress, height: 8)
                                .cornerRadius(4)
                                .animation(.easeInOut(duration: 0.5), value: bmiProgress)
                        }
                    }
                    .frame(height: 8)
                }
                
                // Información adicional
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Difference")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("\(Int(abs(currentWeight - idealWeight))) kg")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(currentWeight > idealWeight ? .orange : .blue)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Category")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(workoutViewModel.userPreferencesService.bmiCategory.rawValue.capitalized)
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.yellow)
                    }
                }
            }
            .padding(16)
            .background(Color.white.opacity(0.05))
            .cornerRadius(12)
        }
    }
}

// MARK: - Weekly Progress Chart
struct WeeklyProgressChart: View {
    private let weekData = [
        ChartDataPoint(day: "L", progress: 0.8),
        ChartDataPoint(day: "M", progress: 0.6),
        ChartDataPoint(day: "X", progress: 0.9),
        ChartDataPoint(day: "J", progress: 0.4),
        ChartDataPoint(day: "V", progress: 0.7),
        ChartDataPoint(day: "S", progress: 0.3),
        ChartDataPoint(day: "D", progress: 0.0)
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Weekly Progress")
                .font(.headline)
                .foregroundColor(.white)
            
            Chart(weekData, id: \.day) { item in
                LineMark(
                    x: .value("Día", item.day),
                    y: .value("Progreso", item.progress)
                )
                .foregroundStyle(.blue)
                .lineStyle(StrokeStyle(lineWidth: 3))
                
                PointMark(
                    x: .value("Día", item.day),
                    y: .value("Progreso", item.progress)
                )
                .foregroundStyle(.blue)
                .symbol(Circle())
                .symbolSize(50)
            }
            .frame(height: 120)
            .chartYScale(domain: 0...1)
            .chartYAxis {
                AxisMarks(position: .leading) { value in
                    AxisGridLine()
                        .foregroundStyle(.white.opacity(0.2))
                    AxisTick()
                        .foregroundStyle(.white.opacity(0.5))
                    AxisValueLabel {
                        if let doubleValue = value.as(Double.self) {
                            let percentage = Int(doubleValue * 100)
                            Text("\(percentage)%")
                                .foregroundStyle(.white.opacity(0.7))
                        }
                    }
                }
            }
            .chartXAxis {
                AxisMarks { value in
                    AxisValueLabel()
                        .foregroundStyle(.white.opacity(0.7))
                }
            }
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
    }
}

// MARK: - Supporting Models
struct ChartDataPoint {
    let day: String
    let progress: Double
}

// MARK: - Preview
#Preview {
    DayProgressDetailSheet(
        date: Date(),
        progressManager: WorkoutProgressManager(),
        workoutViewModel: WorkoutViewModel()
    )
    .preferredColorScheme(.dark)
} 
