import SwiftUI
import Charts

// MARK: - Day Progress Detail Sheet
struct DayProgressDetailSheet: View {
    let date: Date
    @ObservedObject var progressManager: WorkoutProgressManager
    @ObservedObject var workoutViewModel: WorkoutViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedDate: Date
    @State private var currentMonth: Date
    
    private var dayProgress: DayProgress {
        progressManager.getProgress(for: selectedDate)
    }
    
    init(date: Date, progressManager: WorkoutProgressManager, workoutViewModel: WorkoutViewModel) {
        self.date = date
        self.progressManager = progressManager
        self.workoutViewModel = workoutViewModel
        self._selectedDate = State(initialValue: date)
        self._currentMonth = State(initialValue: date)
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Date Selector fijo en la parte superior
                DateSelectorView(
                    selectedDate: $selectedDate,
                    currentMonth: $currentMonth
                )
                .padding(.horizontal, 16)
                .padding(.top, 0)
                .padding(.bottom, 16)
                
                // Contenido scrolleable
                ScrollView {
                    VStack(spacing: 16) {
                        // Gesture para cerrar teclado
                        Color.clear
                            .frame(height: 1)
                            .onTapGesture {
                                hideKeyboard()
                            }
                        
                        // Header con fecha y progreso en un solo card
                        HStack(spacing: 8) {
                            Image(systemName: "chart.pie.fill")
                                .foregroundColor(Color.appYellow)
                                .font(.headline)
                            Text("Daily Progress")
                                .font(.headline)
                                .foregroundColor(.white)
                        }
                        
                        HeaderProgressCard(date: selectedDate, progress: dayProgress, workoutViewModel: workoutViewModel)
                        
                        // Métricas principales
                        HStack(spacing: 8) {
                            Image(systemName: "chart.bar.fill")
                                .foregroundColor(Color.appYellow)
                                .font(.headline)
                            Text("Daily Metrics")
                                .font(.headline)
                                .foregroundColor(.white)
                        }
                        
                        MetricsGridView(progress: dayProgress, workoutViewModel: workoutViewModel, date: selectedDate)
                        
                        // Sección de pasos
                        StepsSectionView(
                            workoutViewModel: workoutViewModel,
                            date: selectedDate
                        )
                        
                        // Gráficos detallados
                        DetailedChartsView(progress: dayProgress, workoutViewModel: workoutViewModel)
                        
                        Spacer(minLength: 100)
                    }
                    .padding(.horizontal, 8)
                }
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
            .navigationBarHidden(true)
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

// MARK: - Header Progress Card
struct HeaderProgressCard: View {
    let date: Date
    let progress: DayProgress
    @ObservedObject var workoutViewModel: WorkoutViewModel
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.locale = Locale(identifier: "en_US")
        return formatter.string(from: date)
    }
    
    // ✅ Calcular progreso diario basado en ejercicios y pasos
    private var dailyProgressPercentage: Double {
        let exercisesProgress = calculateExercisesProgress()
        let stepsProgress = calculateStepsProgress()
        
        // Promedio ponderado: 70% ejercicios, 30% pasos
        let totalProgress = (exercisesProgress * 0.7) + (stepsProgress * 0.3)
        
        print("🎯 DAILY PROGRESS CALCULATION:")
        print("   • Exercises Progress: \(exercisesProgress * 100)%")
        print("   • Steps Progress: \(stepsProgress * 100)%")
        print("   • Total Progress: \(totalProgress * 100)%")
        
        return min(totalProgress, 1.0)
    }
    
    // ✅ Calcular progreso de ejercicios
    private func calculateExercisesProgress() -> Double {
        let targetExercises = 10 // Meta diaria de ejercicios
        let completedExercises = getExercisesCompletedForDate()
        
        let progress = Double(completedExercises) / Double(targetExercises)
        return min(progress, 1.0)
    }
    
    // ✅ Calcular progreso de pasos
    private func calculateStepsProgress() -> Double {
        let targetSteps = workoutViewModel.userPreferencesService.recommendedDailySteps
        let completedSteps = workoutViewModel.getStepsForDate(date)
        
        let progress = Double(completedSteps) / Double(targetSteps)
        return min(progress, 1.0)
    }
    
    // ✅ Obtener ejercicios completados para una fecha específica (misma lógica que WorkoutCalendarView)
    private func getExercisesCompletedForDate() -> Int {
        // Usar el progressManager para obtener datos históricos
        let progressManager = WorkoutProgressManager()
        let dayProgress = progressManager.getProgress(for: date)
        return dayProgress.exercisesCompleted
    }
    
    // ✅ Obtener color basado en el progreso
    private func getProgressColor() -> Color {
        let percentage = dailyProgressPercentage
        
        switch percentage {
        case 0.0..<0.25:
            return .red
        case 0.25..<0.50:
            return .orange
        case 0.50..<0.75:
            return .yellow
        case 0.75...1.0:
            return .green
        default:
            return .red
        }
    }
    
    var body: some View {
        VStack(spacing: 8) {
            // Círculo de progreso diario
            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.1), lineWidth: 6)
                    .frame(width: 120, height: 120)
                
                Circle()
                    .trim(from: 0, to: dailyProgressPercentage)
                    .stroke(
                        getProgressColor(),
                        style: StrokeStyle(lineWidth: 6, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 0.7), value: dailyProgressPercentage)
                
                VStack(spacing: 2) {
                    Text("\(Int(dailyProgressPercentage * 100))%")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    Text("Daily Goal")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.vertical, 12)
        .background(Color.clear)
        .cornerRadius(12)
        .frame(maxWidth: .infinity)
        .frame(height: 160)
        .padding(.top, 5)
        .padding(.bottom, 8)
    }
}

// MARK: - Overall Progress View
struct OverallProgressView: View {
    let progress: DayProgress
    
    var body: some View {
        VStack(spacing: 6) {
            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.1), lineWidth: 6)
                    .frame(width: 120, height: 120)
                
                Circle()
                    .trim(from: 0, to: progress.completionPercentage)
                    .stroke(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 6, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 0.7), value: progress.completionPercentage)
                
                VStack(spacing: 2) {
                    Text("\(Int(progress.completionPercentage * 100))%")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("Completado")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Text("Overall Progress")
                .font(.caption)
                .foregroundColor(.white)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
        .frame(maxWidth: .infinity)
        .frame(height: 160)
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
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 3), spacing: 12) {
            MetricCard(
                title: "Exercises",
                value: "\(progress.exercisesCompleted)/\(progress.totalExercises)",
                icon: "dumbbell.fill",
                color: Color.appYellow
            )
            
            MetricCard(
                title: "Time",
                value: "\(progress.workoutDurationMinutes) min",
                icon: "clock.fill",
                color: Color.appYellow
            )
            
            MetricCard(
                title: "Calories",
                value: getCaloriesDisplayValue(),
                icon: "flame.fill",
                color: Color.appYellow
            )
            
            MetricCard(
                title: "Steps",
                value: getStepsDisplayValue(),
                icon: "figure.walk",
                color: Color.appYellow
            )
            
            MetricCard(
                title: "Heart Rate",
                value: getHeartRateDisplayValue(),
                icon: "heart.fill",
                color: Color.appYellow
            )
            
            EditableWeightCard(
                currentWeight: Binding(
                    get: { workoutViewModel.userPreferencesService.currentUserWeight },
                    set: { newWeight in
                        workoutViewModel.userPreferencesService.userWeight = newWeight
                        // ✅ SINCRONIZACIÓN: Actualizar UserProfile para que WeightProgressChart se actualice
                        updateUserProfileWithNewWeight(newWeight)
                    }
                ),
                isCurrentDay: Calendar.current.isDateInToday(date),
                onWeightChanged: { newWeight in
                    workoutViewModel.userPreferencesService.userWeight = newWeight
                    // ✅ SINCRONIZACIÓN: Actualizar UserProfile para que WeightProgressChart se actualice
                    updateUserProfileWithNewWeight(newWeight)
                }
            )
        }
        .onAppear {
            loadHeartRateForDate()
            loadCaloriesForDate()
        }
    }
    
    // ✅ Función para sincronizar el peso con UserProfile
    private func updateUserProfileWithNewWeight(_ newWeight: Double) {
        print("🔄 SINCRONIZACIÓN: Actualizando UserDefaults con nuevo peso - \(newWeight) kg")
        
        // ✅ Actualizar solo UserDefaults (no modificar UserProfile directamente)
        UserDefaults.standard.set(newWeight, forKey: "selectedWeightKg")
        
        // ✅ Guardar el peso inicial si es la primera vez
        if UserDefaults.standard.object(forKey: "startingWeightKg") == nil {
            UserDefaults.standard.set(newWeight, forKey: "startingWeightKg")
            print("✅ SINCRONIZACIÓN: Peso inicial guardado - \(newWeight) kg")
        }
        
        print("✅ SINCRONIZACIÓN: UserDefaults actualizado con nuevo peso")
        
        // Forzar actualización de la vista
        DispatchQueue.main.async {
            // Esto forzará que WeightProgressChart se recalculen los valores
            workoutViewModel.objectWillChange.send()
            
            // ✅ Notificar a todas las vistas que se actualicen
            NotificationCenter.default.post(name: .weightUpdated, object: newWeight)
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
        
        // ✅ SOLO MOSTRAR DATOS HISTÓRICOS REALES
        let isFutureDate = date > Date()
        let isToday = Calendar.current.isDateInToday(date)
        
        print("🔍 CALORIES DEBUG - getCaloriesDisplayValue:")
        print("   • Fecha: \(date)")
        print("   • Es futuro: \(isFutureDate)")
        print("   • Es hoy: \(isToday)")
        print("   • Datos históricos: \(caloriesForDate)")
        
        // ✅ Para días futuros, no mostrar datos
        if isFutureDate {
            print("❌ CALORIES: Día futuro - no mostrar datos")
            return "0"
        }
        
        if caloriesForDate > 0 {
            print("✅ CALORIES: Datos históricos - \(caloriesForDate)")
            return "\(Int(caloriesForDate))"
        }
        
        // Si no hay datos de HealthKit, usar los datos del progreso local
        if progress.caloriesBurned > 0 {
            print("✅ CALORIES: Datos del progreso local - \(progress.caloriesBurned)")
            return "\(Int(progress.caloriesBurned))"
        }
        
        print("❌ CALORIES: Sin datos disponibles")
        return "0"
    }
    
    private func getHeartRateDisplayValue() -> String {
        if isLoadingHeartRate {
            return "Loading..."
        }
        
        // ✅ SOLO MOSTRAR DATOS HISTÓRICOS REALES
        let isFutureDate = date > Date()
        let isToday = Calendar.current.isDateInToday(date)
        
        print("🔍 HEART RATE DEBUG - getHeartRateDisplayValue:")
        print("   • Fecha: \(date)")
        print("   • Es futuro: \(isFutureDate)")
        print("   • Es hoy: \(isToday)")
        print("   • Datos históricos: \(heartRateForDate ?? 0)")
        
        // ✅ Para días futuros, no mostrar datos
        if isFutureDate {
            print("❌ HEART RATE: Día futuro - no mostrar datos")
            return "--"
        }
        
        // ✅ Si tenemos datos históricos del día, usarlos
        if let historicalHeartRate = heartRateForDate, historicalHeartRate > 0 {
            print("✅ HEART RATE: Datos históricos - \(historicalHeartRate) bpm")
            return "\(Int(historicalHeartRate)) bpm"
        }
        
        // ✅ Solo para hoy: si no hay datos históricos pero tenemos ritmo actual, usarlo
        if isToday, let currentHeartRate = workoutViewModel.heartRate, currentHeartRate > 0 {
            print("✅ HEART RATE: Datos actuales (hoy) - \(currentHeartRate) bpm")
            return "\(Int(currentHeartRate)) bpm"
        }
        
        // ✅ Si no hay datos, mostrar "--"
        print("❌ HEART RATE: Sin datos disponibles")
        return "--"
    }
    
    private func getStepsDisplayValue() -> String {
        // ✅ SOLO MOSTRAR DATOS REALES DE PASOS - VALIDACIÓN MÁS ESTRICTA
        
        let isFutureDate = date > Date()
        let isToday = Calendar.current.isDateInToday(date)
        let savedSteps = workoutViewModel.getStepsForDate(date)
        
        print("🔍 STEPS DEBUG - getStepsDisplayValue:")
        print("   • Fecha: \(date)")
        print("   • Es futuro: \(isFutureDate)")
        print("   • Es hoy: \(isToday)")
        print("   • Pasos guardados: \(savedSteps)")
        
        // ✅ Para días futuros, no mostrar datos
        if isFutureDate {
            print("❌ STEPS: Día futuro - no mostrar datos")
            return "0"
        }
        
        // ✅ VALIDACIÓN MÁS ESTRICTA: Solo mostrar datos realistas
        if savedSteps > 0 && savedSteps < 30000 { // Límite más estricto
            print("✅ STEPS: Datos realistas - \(savedSteps)")
            return "\(savedSteps)"
        } else {
            print("❌ STEPS: Datos irreales detectados - \(savedSteps)")
            print("❌ STEPS: Mostrando 0 en lugar de datos irreales")
            
            // ✅ Limpiar datos irreales del almacenamiento
            cleanUnrealisticStepsData()
            
            return "0"
        }
    }
    
    // ✅ Función para limpiar datos irreales de pasos
    private func cleanUnrealisticStepsData() {
        let savedSteps = workoutViewModel.getStepsForDate(date)
        if savedSteps > 30000 || savedSteps < 0 {
            print("🧹 METRICS: Limpiando datos irreales de pasos - \(savedSteps)")
            // Resetear datos irreales
            workoutViewModel.saveTodaySteps(0)
        }
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
                .foregroundColor(Color.appYellow)
            
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
    
    // ✅ Función helper para formatear peso con máximo 2 decimales
    private func formatWeight(_ weight: Double) -> String {
        let formatted = String(format: "%.2f", weight)
        // Remover .00 y .0 para mostrar solo los decimales necesarios
        return formatted.replacingOccurrences(of: ".00", with: "").replacingOccurrences(of: ".0", with: "")
    }
    
    // ✅ Función helper para formatear peso con 1 decimal (para card editable)
    private func formatWeightOneDecimal(_ weight: Double) -> String {
        return String(format: "%.1f", weight)
    }
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                // Icono de balanza centrado
                Image(systemName: "scalemass")
                    .font(.title2)
                    .foregroundColor(Color.appYellow)
                
                // Icono de lápiz en la esquina superior derecha (solo para día actual)
                if !isEditing && isCurrentDay {
                    VStack {
                        HStack {
                            Spacer()
                            Image(systemName: "pencil.circle.fill")
                                .font(.caption)
                                .foregroundColor(Color.appYellow.opacity(0.7))
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
                            .foregroundColor(Color.appYellow)
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
                Text("\(formatWeightOneDecimal(currentWeight)) kg")
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
                .stroke(isEditing ? Color.appYellow.opacity(0.5) : Color.clear, lineWidth: 1)
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
        if Calendar.current.isDateInToday(date) {
            return workoutViewModel.getTodaySteps()
        }
        
        let savedSteps = workoutViewModel.getStepsForDate(date)
        return (savedSteps > 0 && savedSteps < 30000) ? savedSteps : 0
    }
    
    private var dailyGoal: Int {
        workoutViewModel.userPreferencesService.recommendedDailySteps
    }
    
    private var progressPercentage: Double {
        guard dailyGoal > 0 else { return 0 }
        return min(Double(steps) / Double(dailyGoal), 1.0)
    }
    
    // Función para obtener el color basado en el progreso por fases
    private func getProgressColor() -> Color {
        let percentage = progressPercentage
        
        switch percentage {
        case 0.0..<0.25:
            return .red
        case 0.25..<0.50:
            return .orange
        case 0.50..<0.75:
            return .yellow
        case 0.75...1.0:
            return .green
        default:
            return .red
        }
    }
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "shoe")
                    .foregroundColor(Color.appYellow)
                    .font(.title2)
                Text("Daily Steps")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
                
                // Indicador de estado para hoy
                if Calendar.current.isDateInToday(date) {
                    HStack(spacing: 4) {
                        Circle()
                            .fill(steps > 0 ? Color.green : Color.gray)
                            .frame(width: 8, height: 8)
                        Text(steps > 0 ? "Live" : "No Data")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            VStack(spacing: 16) {
                // Pasos actuales con progreso visual
                VStack(spacing: 8) {
                    HStack {
                        Text("\(steps)")
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(getProgressColor())
                        Text("of \(dailyGoal)")
                            .font(.title3)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("\(Int(progressPercentage * 100))%")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(getProgressColor())
                    }
                    
                    // Barra de progreso
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .fill(Color.white.opacity(0.1))
                                .frame(height: 10)
                                .cornerRadius(5)
                            
                            Rectangle()
                                .fill(getProgressColor())
                                .frame(width: geometry.size.width * progressPercentage, height: 10)
                                .cornerRadius(5)
                                .animation(.easeInOut(duration: 0.5), value: progressPercentage)
                        }
                    }
                    .frame(height: 10)
                }
                
                // Solo mostrar "Extra!" si se superó la meta
                if steps >= dailyGoal {
                    HStack {
                        Spacer()
                        VStack(spacing: 4) {
                            Text("+\(steps - dailyGoal)")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundColor(.green)
                            Text("Extra!")
                                .font(.caption)
                                .foregroundColor(.green)
                        }
                    }
                }
                
                // Explicación de cómo se calculan los pasos recomendados
                VStack(spacing: 8) {
                    HStack {
                        Image(systemName: "info.circle")
                            .foregroundColor(Color.appYellow)
                            .font(.caption)
                        Text("How we calculate your daily steps:")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                    
                    Text("Based on your age, weight, height, activity level, and fitness goals, we recommend \(dailyGoal) steps per day to maintain a healthy lifestyle and achieve your fitness objectives.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.top, 8)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
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
        VStack(alignment: .leading, spacing: 20) {
            // Gráfico de progreso de peso hacia BMI ideal
            WeightProgressChart(workoutViewModel: workoutViewModel)
            
            // Weekly Progress Label fuera del card
            HStack(spacing: 8) {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .foregroundColor(Color.appYellow)
                    .font(.headline)
                Text("Weekly Progress")
                    .font(.headline)
                    .foregroundColor(.white)
            }
            
            // Gráfico de progreso semanal
            WeeklyProgressChart()
        }
    }
}

// MARK: - Weight Progress Chart
struct WeightProgressChart: View {
    @ObservedObject var workoutViewModel: WorkoutViewModel
    @State private var refreshTrigger = false // ✅ Para forzar actualización
    
    private var currentWeight: Double {
        // ✅ Usar UserDefaults directamente para obtener el peso más actualizado
        UserDefaults.standard.object(forKey: "selectedWeightKg") as? Double ?? workoutViewModel.userPreferencesService.userWeight
    }
    
    private var idealWeight: Double {
        // ✅ Usar el targetWeight calculado con la misma lógica que showInfo.swift
        calculateTargetWeight()
    }
    
    private var currentBMI: Double {
        // ✅ Calcular BMI usando el peso actualizado de UserDefaults
        let height = Double(UserDefaults.standard.object(forKey: "selectedHeightCm") as? Int ?? 170) / 100.0
        let weight = currentWeight
        return weight / (height * height)
    }
    
    private var idealBMI: Double {
        // BMI ideal está entre 18.5 y 24.9, usamos 22 como punto medio
        22.0
    }
    
    // ✅ Función helper para formatear peso con máximo 2 decimales
    private func formatWeight(_ weight: Double) -> String {
        let formatted = String(format: "%.2f", weight)
        // Remover .00 y .0 para mostrar solo los decimales necesarios
        return formatted.replacingOccurrences(of: ".00", with: "").replacingOccurrences(of: ".0", with: "")
    }
    
    // ✅ Función para calcular targetWeight usando la misma lógica que showInfo.swift
    private func calculateTargetWeight() -> Double {
        let userProfile = UserProfile.loadFromUserDefaults()
        let currentWeight = userProfile.weightKg
        let goal = userProfile.goal.lowercased()
        let bmi = userProfile.bmi ?? 25.0
        let height = Double(userProfile.resolvedHeightCm) / 100.0
        let heightCm = userProfile.resolvedHeightCm
        
        let targetWeight: Double
        
        if goal.contains("perder") || goal.contains("lose") {
            let targetBMI: Double
            if bmi > 30 {
                targetBMI = 25.0
            } else if bmi > 25 {
                targetBMI = 23.5
            } else {
                targetBMI = 21.0
            }
            
            targetWeight = targetBMI * height * height
            let finalWeight = max(targetWeight, currentWeight * 0.85)
            
            print("🎯 WEIGHT PROGRESS - Pérdida de peso:")
            print("   • Peso actual: \(currentWeight) kg")
            print("   • BMI actual: \(bmi)")
            print("   • BMI objetivo: \(targetBMI)")
            print("   • Peso objetivo calculado: \(finalWeight) kg")
            
            return finalWeight
            
        } else if goal.contains("ganar") || goal.contains("gain") {
            let muscleGain = min(currentWeight * 0.15, 10.0)
            targetWeight = currentWeight + muscleGain
            
            print("🎯 WEIGHT PROGRESS - Ganancia de peso:")
            print("   • Peso actual: \(currentWeight) kg")
            print("   • Ganancia objetivo: \(muscleGain) kg")
            print("   • Peso objetivo calculado: \(targetWeight) kg")
            
            return targetWeight
            
        } else {
            let isMale = userProfile.gender.lowercased().contains("male")
            if isMale {
                let brocaWeight = Double(heightCm - 100)
                let bmiWeight = 23.5 * height * height
                targetWeight = (brocaWeight + bmiWeight) / 2
                
                print("🎯 WEIGHT PROGRESS - Mantenimiento (hombre):")
                print("   • Peso actual: \(currentWeight) kg")
                print("   • Peso Broca: \(brocaWeight) kg")
                print("   • Peso BMI 23.5: \(bmiWeight) kg")
                print("   • Peso objetivo calculado: \(targetWeight) kg")
                
                return targetWeight
            } else {
                let optimalBMI = 22.0
                targetWeight = optimalBMI * height * height
                
                print("🎯 WEIGHT PROGRESS - Mantenimiento (mujer):")
                print("   • Peso actual: \(currentWeight) kg")
                print("   • BMI objetivo: \(optimalBMI)")
                print("   • Peso objetivo calculado: \(targetWeight) kg")
                
                return targetWeight
            }
        }
    }
    
    private var weightProgress: Double {
        guard idealWeight > 0 else { return 0 }
        
        // ✅ Obtener el peso inicial del onboarding (NO cambia nunca)
        let onboardingInitialWeight = UserDefaults.standard.object(forKey: "onboardingInitialWeightKg") as? Double ?? currentWeight
        
        print("🎯 WEIGHT PROGRESS BAR - Cálculo de progreso:")
        print("   • Peso actual: \(currentWeight) kg")
        print("   • Peso inicial (onboarding): \(onboardingInitialWeight) kg")
        print("   • Peso ideal: \(idealWeight) kg")
        
        // ✅ LÓGICA MEJORADA: Calcular progreso basado en la distancia al peso ideal desde el peso inicial del onboarding
        let distanceToIdeal = abs(currentWeight - idealWeight)
        let totalDistance = abs(onboardingInitialWeight - idealWeight)
        
        // Si ya está en el peso ideal o muy cerca (dentro de 0.5 kg)
        if distanceToIdeal <= 0.5 {
            print("   • Objetivo: Mantener peso (ya en peso ideal)")
            print("   • Progreso: 100%")
            return 1.0
        }
        
        // Si no hay distancia total que recorrer (peso inicial = peso ideal)
        if totalDistance <= 0.1 {
            print("   • Objetivo: Mantener peso (peso inicial ya era ideal)")
            print("   • Progreso: 100%")
            return 1.0
        }
        
        // Calcular progreso basado en cuánto se ha acercado al peso ideal desde el peso inicial del onboarding
        let progress = max(0, min(1 - (distanceToIdeal / totalDistance), 1.0))
        
        print("   • Distancia al ideal: \(distanceToIdeal) kg")
        print("   • Distancia total desde onboarding: \(totalDistance) kg")
        print("   • Progreso: \(Int(progress * 100))%")
        
        return progress
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
            HStack(spacing: 8) {
                Image(systemName: "scalemass.fill")
                    .font(.title2)
                    .foregroundColor(Color.appYellow)
                
                Text("Weight Progress")
                    .font(.headline)
                    .foregroundColor(.white)
            }
            .onAppear {
                ensureStartingWeightIsSaved()
            }
            
            VStack(spacing: 12) {
                // Información actual
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Current Weight")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("\(formatWeight(currentWeight)) kg")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(getProgressBarColor(weightProgress))
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Ideal Weight")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("\(formatWeight(idealWeight)) kg")
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
                            .foregroundColor(.appYellow)
                    }
                    
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .fill(Color.white.opacity(0.1))
                                .frame(height: 8)
                                .cornerRadius(4)
                            
                            Rectangle()
                                .fill(getProgressBarColor(weightProgress))
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
                            .foregroundColor(getProgressBarColor(bmiProgress))
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
                            .foregroundColor(.appYellow)
                    }
                    
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .fill(Color.white.opacity(0.1))
                                .frame(height: 8)
                                .cornerRadius(4)
                            
                            Rectangle()
                                .fill(getProgressBarColor(bmiProgress))
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
                        Text("\(String(format: "%.1f", abs(currentWeight - idealWeight))) kg")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(getDifferenceColor(abs(currentWeight - idealWeight)))
                            .onAppear {
                                print("🎯 WEIGHT DIFFERENCE DEBUG:")
                                print("   • Current Weight: \(currentWeight) kg")
                                print("   • Ideal Weight: \(idealWeight) kg")
                                print("   • Difference: \(abs(currentWeight - idealWeight)) kg")
                                print("   • Formatted: \(String(format: "%.1f", abs(currentWeight - idealWeight))) kg")
                            }
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Category")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(workoutViewModel.userPreferencesService.bmiCategory.rawValue.capitalized)
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(getBMICategoryColor(workoutViewModel.userPreferencesService.bmiCategory))
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .background(Color.white.opacity(0.05))
            .cornerRadius(12)
        }
        .onReceive(NotificationCenter.default.publisher(for: .weightUpdated)) { _ in
            // ✅ SINCRONIZACIÓN: Forzar actualización cuando se cambie el peso
            print("🔄 WEIGHT PROGRESS: Recibida notificación de peso actualizado")
            refreshTrigger.toggle()
        }
    }
    
    // ✅ Función helper para obtener el color de la barra basado en el progreso
    private func getProgressBarColor(_ progress: Double) -> Color {
        let percentage = progress * 100
        
        switch percentage {
        case 0.0..<25.0:
            return .red
        case 25.0..<50.0:
            return .orange
        case 50.0..<75.0:
            return .appYellow
        case 75.0...100.0:
            return .green
        default:
            return .red
        }
    }
    
    // ✅ Función helper para obtener el color de la diferencia basado en la distancia al peso ideal
    private func getDifferenceColor(_ difference: Double) -> Color {
        switch difference {
        case 0.0..<2.0:
            return .green // Muy cerca del ideal
        case 2.0..<5.0:
            return .appYellow // Moderadamente lejos
        default:
            return .red // Muy lejos del ideal
        }
    }
    
    // ✅ Función helper para obtener el color de la categoría BMI
    private func getBMICategoryColor(_ category: BMICategoryWorkout) -> Color {
        switch category {
        case .underweight:
            return .blue // Azul para bajo peso
        case .normal:
            return .green // Verde para peso normal
        case .overweight:
            return .orange // Naranja para sobrepeso
        case .obese:
            return .red // Rojo para obesidad
        }
    }
    
    // ✅ Función para asegurar que el peso inicial del onboarding esté guardado
    private func ensureStartingWeightIsSaved() {
        let onboardingInitialWeight = UserDefaults.standard.object(forKey: "onboardingInitialWeightKg") as? Double
        
        if onboardingInitialWeight == nil {
            // Si no hay peso inicial del onboarding guardado, usar el peso actual como inicial
            let currentWeight = UserDefaults.standard.object(forKey: "selectedWeightKg") as? Double ?? workoutViewModel.userPreferencesService.userWeight
            UserDefaults.standard.set(currentWeight, forKey: "onboardingInitialWeightKg")
            print("✅ WEIGHT PROGRESS: Peso inicial del onboarding guardado - \(currentWeight) kg")
        } else {
            print("✅ WEIGHT PROGRESS: Peso inicial del onboarding ya existe - \(onboardingInitialWeight!) kg")
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
        .padding(.vertical, 16)
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
    }
}

// MARK: - Supporting Models
struct ChartDataPoint {
    let day: String
    let progress: Double
}

// MARK: - Notification Extensions
extension Notification.Name {
    static let weightUpdated = Notification.Name("weightUpdated")
}

// MARK: - Date Selector View
struct DateSelectorView: View {
    @Binding var selectedDate: Date
    @Binding var currentMonth: Date
    
    @State private var scrollOffset: CGFloat = 0
    @State private var isScrolling = false
    
    private var monthDays: [Date] {
        let calendar = Calendar.current
        let startOfMonth = calendar.dateInterval(of: .month, for: currentMonth)?.start ?? currentMonth
        let endOfMonth = calendar.dateInterval(of: .month, for: currentMonth)?.end ?? currentMonth
        
        var days: [Date] = []
        var currentDate = startOfMonth
        
        while currentDate < endOfMonth {
            days.append(currentDate)
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
        }
        
        return days
    }
    
    // Calcular la posición inicial para mostrar la semana actual
    private var initialScrollPosition: CGFloat {
        let calendar = Calendar.current
        let today = Date()
        
        // Si estamos en el mes actual, calcular la posición de la semana actual
        if calendar.isDate(today, equalTo: currentMonth, toGranularity: .month) {
            let startOfMonth = calendar.dateInterval(of: .month, for: currentMonth)?.start ?? currentMonth
            let daysFromStart = calendar.dateComponents([.day], from: startOfMonth, to: today).day ?? 0
            let weekOfMonth = daysFromStart / 7
            return CGFloat(weekOfMonth * 7) * 43 // 43 = 35 (width) + 8 (spacing)
        }
        
        return 0
    }
    
    private var monthYearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        formatter.locale = Locale(identifier: "en_US")
        return formatter.string(from: currentMonth)
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Month Navigation
            HStack {
                Button(action: previousMonth) {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .foregroundColor(Color.appYellow)
                }
                
                Spacer()
                
                Text(monthYearString)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(Color.appYellow)
                
                Spacer()
                
                Button(action: nextMonth) {
                    Image(systemName: "chevron.right")
                        .font(.title2)
                        .foregroundColor(Color.appYellow)
                }
            }
            .padding(.horizontal, 20)
            
            // Month Days Selector - Muestra exactamente 7 días visualmente
            ScrollViewReader { proxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(monthDays, id: \.self) { date in
                            DayCircleView(
                                date: date,
                                isSelected: Calendar.current.isDate(date, inSameDayAs: selectedDate),
                                onTap: {
                                    selectedDate = date
                                }
                            )
                            .id(date)
                        }
                    }
                    .padding(.horizontal, 16)
                    .background(
                        GeometryReader { geometry in
                            Color.clear
                                .preference(key: ScrollOffsetPreferenceKey.self, value: geometry.frame(in: .named("scroll")).minX)
                        }
                    )
                }
                .coordinateSpace(name: "scroll")
                .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                    handleScrollOffset(value)
                }
                .frame(width: 7 * 48 + 32, height: 60) // Ancho fijo para mostrar exactamente 7 días (40 + 8 spacing) + padding horizontal
                .clipped() // Oculta el contenido que se sale del frame
                .onAppear {
                    // Posicionar automáticamente en la semana actual
                    let calendar = Calendar.current
                    let today = Date()
                    
                    if calendar.isDate(today, equalTo: currentMonth, toGranularity: .month) {
                        // Calcular cuántos días desde el inicio del mes hasta hoy
                        let startOfMonth = calendar.dateInterval(of: .month, for: currentMonth)?.start ?? currentMonth
                        let daysFromStart = calendar.dateComponents([.day], from: startOfMonth, to: today).day ?? 0
                        
                        // Calcular la semana actual (0-indexed)
                        let currentWeek = daysFromStart / 7
                        
                        // Calcular la posición del primer día de la semana actual
                        let firstDayOfWeek = calendar.date(byAdding: .day, value: currentWeek * 7, to: startOfMonth) ?? startOfMonth
                        
                        // Hacer scroll a esa posición
                        withAnimation(.easeInOut(duration: 0.5)) {
                            proxy.scrollTo(firstDayOfWeek, anchor: .leading)
                        }
                    }
                }
            }
        }
        .padding(.vertical, 16)
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
        .onAppear {
            // Asegurar que siempre se muestre la semana actual del mes al abrir
            if !Calendar.current.isDate(selectedDate, inSameDayAs: Date()) {
                selectedDate = Date()
            }
        }
    }
    
    private func handleScrollOffset(_ offset: CGFloat) {
        guard !isScrolling else { return }
        
        // Detectar si el scroll está cerca del final del mes
        let calendar = Calendar.current
        let daysInMonth = monthDays.count
        let dayWidth: CGFloat = 48 // 40 (width) + 8 (spacing)
        let totalWidth = CGFloat(daysInMonth) * dayWidth
        let visibleWidth: CGFloat = 7 * dayWidth // 7 días visibles
        
        // Si estamos cerca del final del mes, avanzar al siguiente
        if offset < -(totalWidth - visibleWidth + 50) {
            isScrolling = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                nextMonth()
                isScrolling = false
            }
        }
        // Si estamos cerca del inicio del mes, retroceder al anterior
        else if offset > 50 {
            isScrolling = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                previousMonth()
                isScrolling = false
            }
        }
    }
    
    private func previousMonth() {
        withAnimation(.easeInOut(duration: 0.3)) {
            currentMonth = Calendar.current.date(byAdding: .month, value: -1, to: currentMonth) ?? currentMonth
        }
    }
    
    private func nextMonth() {
        withAnimation(.easeInOut(duration: 0.3)) {
            currentMonth = Calendar.current.date(byAdding: .month, value: 1, to: currentMonth) ?? currentMonth
        }
    }
}



// MARK: - Day Circle View
struct DayCircleView: View {
    let date: Date
    let isSelected: Bool
    let onTap: () -> Void
    
    private var dayInitial: String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.setLocalizedDateFormatFromTemplate("EEE")
        return String(formatter.string(from: date).prefix(1))
    }
    
    private var dayNumber: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }
    
    private var isToday: Bool {
        Calendar.current.isDateInToday(date)
    }
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 2) {
                Text(dayInitial)
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundColor(isSelected ? .white : .white.opacity(0.7))
                
                Text(dayNumber)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(isSelected ? .white : .white)
            }
            .frame(width: 40, height: 50)
            .background(
                Circle()
                    .fill(isSelected ? Color.appYellow : Color.clear)
                    .overlay(
                        Circle()
                            .stroke(isToday && !isSelected ? Color.appYellow.opacity(0.5) : Color.clear, lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
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
