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
                    // Header con fecha y progreso en un solo card
                    HeaderProgressCard(date: date, progress: dayProgress, workoutViewModel: workoutViewModel)
                    
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
        VStack(spacing: 16) {
            // Fecha y título
            VStack(spacing: 8) {
                Text(formattedDate)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("Day Progress")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
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
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
        .frame(maxWidth: .infinity)
        .frame(height: 200)
        .padding(.top, 10)
        .padding(.bottom, 16)
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
    
    @State private var isLoadingSteps = false
    @State private var hasHealthKitData = false
    @State private var stepsFromHealthKit: Int = 0
    
    private var steps: Int {
        // ✅ SINCRONIZADO CON EL CARD DE PASOS: Usar la misma lógica
        
        // Para el día actual, usar todaySteps del WorkoutViewModel
        if Calendar.current.isDateInToday(date) {
            let todaySteps = workoutViewModel.getTodaySteps()
            print("✅ STEPS SECTION: Usando todaySteps - \(todaySteps)")
            return todaySteps
        }
        
        // Para días pasados, usar getStepsForDate con validación
        let savedSteps = workoutViewModel.getStepsForDate(date)
        
        // Solo usar datos guardados si son realistas
        if savedSteps > 0 && savedSteps < 30000 {
            print("✅ STEPS SECTION: Usando datos pasados realistas - \(savedSteps)")
            return savedSteps
        } else {
            print("❌ STEPS SECTION: Datos pasados irreales - \(savedSteps)")
            return 0
        }
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
                
                // Indicador de estado de HealthKit
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
            
            VStack(spacing: 12) {
                // Pasos actuales
                HStack {
                    if isLoadingSteps {
                        ProgressView()
                            .scaleEffect(0.8)
                            .foregroundColor(.green)
                    } else {
                        Text("\(steps)")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.green)
                    }
                    Text("steps")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                }
                
                // Explicación del promedio recomendado
                HStack {
                    Text("Daily goal based on your profile:")
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
                        Text("Daily Goal")
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
        .onAppear {
            loadStepsData()
        }
    }
    
    private func loadStepsData() {
        // ✅ SIMPLIFICADO: StepsSectionView ahora usa la misma lógica que el card
        print("🔄 STEPS SECTION: Cargando datos...")
        
        // Para el día actual, los datos se obtienen automáticamente de todaySteps
        // Para días pasados, se obtienen de getStepsForDate
        // No necesitamos lógica adicional aquí
    }
    
    // ✅ Función para limpiar datos irreales del almacenamiento
    private func cleanUnrealisticData() {
        let savedSteps = workoutViewModel.getStepsForDate(date)
        if savedSteps > 50000 || savedSteps < 0 {
            print("🧹 STEPS: Limpiando datos irreales del almacenamiento - \(savedSteps)")
            // Resetear datos irreales
            workoutViewModel.saveTodaySteps(0)
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
        
        // Obtener el peso inicial (peso de partida) desde UserDefaults
        let startingWeight = UserDefaults.standard.object(forKey: "startingWeightKg") as? Double ?? currentWeight
        
        print("🎯 WEIGHT PROGRESS BAR - Cálculo de progreso:")
        print("   • Peso actual: \(currentWeight) kg")
        print("   • Peso inicial: \(startingWeight) kg")
        print("   • Peso ideal: \(idealWeight) kg")
        
        // Si el peso actual es mayor al ideal (necesita perder peso)
        if currentWeight > idealWeight {
            let totalToLose = startingWeight - idealWeight
            let alreadyLost = startingWeight - currentWeight
            
            print("   • Objetivo: Perder peso")
            print("   • Total a perder: \(totalToLose) kg")
            print("   • Ya perdido: \(alreadyLost) kg")
            
            // Si ya perdió todo lo necesario, mostrar 100%
            if alreadyLost >= totalToLose {
                print("   • Progreso: 100% (meta alcanzada)")
                return 1.0
            }
            
            // Calcular progreso basado en cuánto ha perdido vs cuánto necesita perder
            let progress = max(0, min(alreadyLost / totalToLose, 1.0))
            print("   • Progreso: \(Int(progress * 100))%")
            return progress
            
        } else if currentWeight < idealWeight {
            // Si el peso actual es menor al ideal (necesita ganar peso)
            let totalToGain = idealWeight - startingWeight
            let alreadyGained = currentWeight - startingWeight
            
            print("   • Objetivo: Ganar peso")
            print("   • Total a ganar: \(totalToGain) kg")
            print("   • Ya ganado: \(alreadyGained) kg")
            
            // Si ya ganó todo lo necesario, mostrar 100%
            if alreadyGained >= totalToGain {
                print("   • Progreso: 100% (meta alcanzada)")
                return 1.0
            }
            
            // Calcular progreso basado en cuánto ha ganado vs cuánto necesita ganar
            let progress = max(0, min(alreadyGained / totalToGain, 1.0))
            print("   • Progreso: \(Int(progress * 100))%")
            return progress
            
        } else {
            // Si está en el peso ideal
            print("   • Objetivo: Mantener peso (ya en peso ideal)")
            print("   • Progreso: 100%")
            return 1.0
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
            HStack(spacing: 8) {
                Image(systemName: "scalemass.fill")
                    .font(.title2)
                    .foregroundColor(.purple)
                
                Text("Weight Progress")
                    .font(.headline)
                    .foregroundColor(.white)
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
                            .foregroundColor(.white)
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
                        Text("\(String(format: "%.1f", abs(currentWeight - idealWeight))) kg")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(currentWeight > idealWeight ? .orange : .blue)
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
                            .foregroundColor(.yellow)
                    }
                }
            }
            .padding(16)
            .background(Color.white.opacity(0.05))
            .cornerRadius(12)
        }
        .onReceive(NotificationCenter.default.publisher(for: .weightUpdated)) { _ in
            // ✅ SINCRONIZACIÓN: Forzar actualización cuando se cambie el peso
            print("🔄 WEIGHT PROGRESS: Recibida notificación de peso actualizado")
            refreshTrigger.toggle()
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

// MARK: - Notification Extensions
extension Notification.Name {
    static let weightUpdated = Notification.Name("weightUpdated")
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
