import SwiftUI
import Charts
// Importa la lógica y modelos desde ProgressWorkout
// import ProgressWorkout (si es necesario)

// Wrapper para que Date sea Identifiable y funcione con .sheet(item:)
struct IdentifiableDate: Identifiable {
    let id = UUID()
    let date: Date
}

struct WorkoutCalendarView: View {
    @StateObject private var progressManager = WorkoutProgressManager()
    // Se usa un wrapper Identifiable para la fecha seleccionada
    @State private var selectedDateWrapper: IdentifiableDate?
    
    var body: some View {
        HStack(spacing: 15) {
            ForEach(progressManager.currentWeekDays, id: \.self) { date in
                WorkoutDayProgressCircle(
                    progress: progressManager.getProgress(for: date).completionPercentage,
                    date: date,
                    isToday: Calendar.current.isDateInToday(date)
                )
                .onTapGesture {
                    self.selectedDateWrapper = IdentifiableDate(date: date)
                }
            }
        }
        .padding(.vertical, 10)
        .sheet(item: $selectedDateWrapper) { wrapper in
            DayDetailView(
                date: wrapper.date,
                progressManager: progressManager
            )
        }
    }
}

// Ajusta el tamaño del círculo y el número del día en WorkoutDayProgressCircle:
struct WorkoutDayProgressCircle: View {
    let progress: Double
    let date: Date
    let isToday: Bool
    
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

// MARK: - Day Detail View

struct DayDetailView: View {
    let date: Date
    @ObservedObject var progressManager: WorkoutProgressManager
    @Environment(\.dismiss) private var dismiss
    
    private var dayProgress: DayProgress {
        progressManager.getProgress(for: date)
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 25) {
                    // Header con fecha
                    VStack(spacing: 8) {
                        Text(formattedDate)
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("Progreso del día")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 20)
                    
                    // Gráfico circular de progreso general
                    OverallProgressView(progress: dayProgress)
                    
                    // Métricas principales
                    MetricsGridView(progress: dayProgress)
                    
                    // Gráficos detallados
                    DetailedChartsView(progress: dayProgress)
                    
                    Spacer(minLength: 100)
                }
                .padding(.horizontal, 20)
            }
            .background(Color.black.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cerrar") {
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
        formatter.locale = Locale(identifier: "es_ES")
        return formatter.string(from: date)
    }
}

// MARK: - Overall Progress View

struct OverallProgressView: View {
    let progress: DayProgress
    
    var body: some View {
        VStack(spacing: 15) {
            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.1), lineWidth: 12)
                    .frame(width: 120, height: 120)
                
                Circle()
                    .trim(from: 0, to: progress.completionPercentage)
                    .stroke(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 12, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .frame(width: 120, height: 120)
                    .animation(.easeInOut(duration: 1), value: progress.completionPercentage)
                
                VStack(spacing: 4) {
                    Text("\(Int(progress.completionPercentage * 100))%")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("Completado")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
}

// MARK: - Metrics Grid

struct MetricsGridView: View {
    let progress: DayProgress
    
    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 15), count: 2), spacing: 15) {
            MetricCard(
                title: "Ejercicios",
                value: "\(progress.exercisesCompleted)/\(progress.totalExercises)",
                icon: "figure.strengthtraining.functional",
                color: .green
            )
            
            MetricCard(
                title: "Ritmo Cardíaco",
                value: "\(Int(progress.heartRate)) bpm",
                icon: "heart.fill",
                color: .red
            )
            
            MetricCard(
                title: "Pasos",
                value: "\(progress.steps)",
                icon: "figure.walk",
                color: .orange
            )
            
            MetricCard(
                title: "Calorías",
                value: String(format: "%.0f kcal", progress.caloriesBurned),
                icon: "flame.fill",
                color: .red
            )
        }
    }
}

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
            
            VStack(spacing: 4) {
                Text(value)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .frame(height: 100)
        .frame(maxWidth: .infinity)
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
    }
}

// MARK: - Detailed Charts

struct DetailedChartsView: View {
    let progress: DayProgress
    
    var body: some View {
        VStack(spacing: 25) {
            // Gráfico de barras para ejercicios vs videos
            ExerciseComparisonChart(progress: progress)
            
            // Gráfico de progreso semanal simulado
            WeeklyProgressChart()
        }
    }
}

struct ExerciseComparisonChart: View {
    let progress: DayProgress
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Ejercicios vs Ritmo Cardíaco")
                .font(.headline)
                .foregroundColor(.white)
            
            Chart {
                BarMark(
                    x: .value("Categoría", "Ejercicios"),
                    y: .value("Completados", progress.exercisesCompleted)
                )
                .foregroundStyle(.green)
                .cornerRadius(4)
                
                BarMark(
                    x: .value("Categoría", "Ritmo Cardíaco"),
                    y: .value("BPM", progress.heartRate)
                )
                .foregroundStyle(.red)
                .cornerRadius(4)
            }
            .frame(height: 150)
            .chartXAxis {
                AxisMarks { value in
                    AxisValueLabel()
                        .foregroundStyle(.white.opacity(0.7))
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading) { value in
                    AxisGridLine()
                        .foregroundStyle(.white.opacity(0.2))
                    AxisTick()
                        .foregroundStyle(.white.opacity(0.5))
                    AxisValueLabel {
                        if let doubleValue = value.as(Double.self) {
                            Text("\(Int(doubleValue))")
                                .foregroundStyle(.white.opacity(0.7))
                        }
                    }
                }
            }
            .padding(10)
            .background(Color.white.opacity(0.05))
            .cornerRadius(12)
        }
    }
}

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
            Text("Progreso Semanal")
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
    WorkoutCalendarView()
        .padding()
        .background(Color.black)
        .preferredColorScheme(.dark)
}
