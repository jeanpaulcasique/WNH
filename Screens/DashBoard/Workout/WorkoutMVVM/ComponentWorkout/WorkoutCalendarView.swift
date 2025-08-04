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
                    steps: workoutViewModel.getStepsForDate(date)
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
    
    var progressColor: Color {
        switch progress {
        case 0.0..<0.25:
            return .red
        case 0.25..<0.5:
            return .orange
        case 0.5..<0.75:
            return .yellow
        default:
            return .green
        }
    }
    
    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.15), lineWidth: 5)
                    .frame(width: 42, height: 42) // Tamaño círculo
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        isToday ? Color.yellow : progressColor, // Ahora amarillo para el día actual
                        style: StrokeStyle(lineWidth: 5, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .frame(width: 42, height: 42) // Tamaño círculo
                    .animation(.easeInOut(duration: 0.7), value: progress)
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
