import SwiftUI
import Charts

// Wrapper para que Date sea Identifiable y funcione con .sheet(item:)
struct IdentifiableDate: Identifiable {
    let id = UUID()
    let date: Date
}

struct WorkoutCalendarView: View {
    @StateObject private var progressManager = WorkoutProgressManager()
    @ObservedObject var workoutViewModel: WorkoutViewModel
    // Se usa un wrapper Identifiable para la fecha seleccionada
    @State private var selectedDateWrapper: IdentifiableDate?
    
    var body: some View {
        HStack(spacing: 15) {
            ForEach(progressManager.currentWeekDays, id: \.self) { date in
                WorkoutDayProgressCircle(
                    progress: progressManager.getProgress(for: date).completionPercentage,
                    date: date,
                    isToday: Calendar.current.isDateInToday(date),
                    steps: workoutViewModel.getStepsForDate(date),
                    workoutViewModel: workoutViewModel
                )
                .onTapGesture {
                    self.selectedDateWrapper = IdentifiableDate(date: date)
                }
            }
        }
        .padding(.vertical, 10)
        .sheet(item: $selectedDateWrapper) { wrapper in
            DayProgressDetailSheet(
                date: wrapper.date,
                progressManager: progressManager,
                workoutViewModel: workoutViewModel
            )
        }
    }
}

// Ajusta el tamaño del círculo y el número del día en WorkoutDayProgressCircle:
struct WorkoutDayProgressCircle: View {
    let progress: Double
    let date: Date
    let isToday: Bool
    let steps: Int
    @ObservedObject var workoutViewModel: WorkoutViewModel
    
    // ✅ Calcular progreso diario basado en ejercicios y pasos (misma lógica que HeaderProgressCard)
    private var dailyProgressPercentage: Double {
        let exercisesProgress = calculateExercisesProgress()
        let stepsProgress = calculateStepsProgress()
        
        // Promedio ponderado: 70% ejercicios, 30% pasos
        let totalProgress = (exercisesProgress * 0.7) + (stepsProgress * 0.3)
        
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
    
    // ✅ Obtener ejercicios completados para una fecha específica
    private func getExercisesCompletedForDate() -> Int {
        // Usar el progressManager para obtener datos históricos
        let progressManager = WorkoutProgressManager()
        let dayProgress = progressManager.getProgress(for: date)
        return dayProgress.exercisesCompleted
    }
    
    var progressColor: Color {
        let percentage = dailyProgressPercentage
        
        switch percentage {
        case 0.0..<0.25:
            return .red
        case 0.25..<0.5:
            return .orange
        case 0.5..<0.75:
            return .yellow
        case 0.75...1.0:
            return .green
        default:
            return .red
        }
    }
    
    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.15), lineWidth: 5)
                    .frame(width: 42, height: 42) // Tamaño círculo
                Circle()
                    .trim(from: 0, to: dailyProgressPercentage)
                    .stroke(
                        progressColor, // ✅ Siempre usar el color de progreso, no amarillo
                        style: StrokeStyle(lineWidth: 5, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .frame(width: 42, height: 42) // Tamaño círculo
                    .animation(.easeInOut(duration: 0.7), value: dailyProgressPercentage)
                Text(dayNumber)
                    .font(.system(size: 18, weight: .bold)) // Tamaño número
                    .foregroundColor(isToday ? .yellow : .white) // También el número en amarillo
            }
            Text(dayShort)
                .font(.caption2)
                .foregroundColor(isToday ? .yellow : .white.opacity(0.7))
        }
    }
    
    private var dayNumber: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }
    
    private var dayShort: String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.setLocalizedDateFormatFromTemplate("EEE")
        return formatter.string(from: date)
    }
    

}

// MARK: - Preview
#Preview {
    WorkoutCalendarView(workoutViewModel: WorkoutViewModel())
        .padding()
        .background(Color.black)
        .preferredColorScheme(.dark)
}
