import SwiftUI
import Foundation
import Combine
import HealthKit

// MARK: - Models
struct WeightDataPoint: Identifiable {
    let id = UUID()
    let date: Date
    let weight: Double
}

struct WorkoutDataPoint: Identifiable {
    let id = UUID()
    let day: String
    let duration: Int
}

struct Achievement: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let icon: String
    let date: Date
    let isCompleted: Bool
}

enum AnalyticsTimeRange: String, CaseIterable {
    case week = "7d"
    case month = "30d"
    case threeMonths = "3m"
    case year = "1y"
    
    var displayName: String {
        switch self {
        case .week: return "7D"
        case .month: return "30D"
        case .threeMonths: return "3M"
        case .year: return "1Y"
        }
    }
    
    var days: Int {
        switch self {
        case .week: return 7
        case .month: return 30
        case .threeMonths: return 90
        case .year: return 365
        }
    }
}

enum TrendDirection {
    case positive, negative, neutral
    
    var iconName: String {
        switch self {
        case .positive: return "arrow.up.right"
        case .negative: return "arrow.down.right"
        case .neutral: return "arrow.right"
        }
    }
    
    var color: Color {
        switch self {
        case .positive: return .green
        case .negative: return .red
        case .neutral: return .gray
        }
    }
}

enum InsightType {
    case positive, warning, neutral
    
    var color: Color {
        switch self {
        case .positive: return .green
        case .warning: return .orange
        case .neutral: return .gray
        }
    }
}

// MARK: - AnalyticsViewModel
final class AnalyticsViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var selectedTimeRange: AnalyticsTimeRange = .month {
        didSet {
            loadAnalyticsData()
        }
    }
    
    // Weight Analytics
    @Published var weightData: [WeightDataPoint] = []
    @Published var currentWeight: Double = 70.0
    @Published var goalWeight: Double = 65.0
    @Published var weightChange: String = "-2.5"
    @Published var weightTrend: TrendDirection = .negative
    @Published var weightProgress: Double = 0.75
    
    // Workout Analytics
    @Published var workoutData: [WorkoutDataPoint] = []
    @Published var totalWorkouts: Int = 12
    @Published var totalWorkoutMinutes: Int = 840
    @Published var avgWorkoutDuration: Int = 45
    @Published var workoutConsistency: Int = 85
    @Published var activeDays: Int = 18
    
    // Nutrition Analytics
    @Published var avgCaloriesConsumed: Int = 1850
    @Published var caloriesTrend: TrendDirection = .positive
    @Published var avgProtein: Int = 120
    @Published var avgCarbs: Int = 180
    @Published var avgFats: Int = 65
    @Published var proteinGoal: Int = 130
    @Published var carbsGoal: Int = 200
    @Published var fatsGoal: Int = 70
    @Published var nutritionInsight: String = "Great protein intake! Consider increasing fiber."
    @Published var nutritionInsightType: InsightType = .positive
    
    // Apple Watch Data
    @Published var isAppleWatchConnected: Bool = false
    @Published var avgHeartRate: Int = 72
    @Published var avgSteps: Int = 8500
    @Published var activeEnergy: Int = 420
    @Published var standHours: Int = 10
    
    // Health Metrics
    @Published var currentBMI: Double = 23.5
    @Published var bodyFatPercentage: Double = 18.5
    @Published var muscleMass: Double = 32.8
    @Published var waterPercentage: Double = 58.2
    
    // Achievements
    @Published var recentAchievements: [Achievement] = []
    
    // UI State
    @Published var isLoading: Bool = false
    
    // MARK: - Private Properties
    private let healthStore = HKHealthStore()
    private var cancellables = Set<AnyCancellable>()
    private let userDefaults = UserDefaults.standard
    
    // MARK: - Computed Properties
    var bmiStatus: String {
        switch currentBMI {
        case ..<18.5: return "Underweight"
        case 18.5..<25: return "Normal"
        case 25..<30: return "Overweight"
        default: return "Obese"
        }
    }
    
    var bmiStatusColor: Color {
        switch currentBMI {
        case ..<18.5: return .blue
        case 18.5..<25: return .green
        case 25..<30: return .orange
        default: return .red
        }
    }
    
    var bodyFatStatus: String {
        switch bodyFatPercentage {
        case ..<10: return "Very Low"
        case 10..<18: return "Low"
        case 18..<25: return "Normal"
        default: return "High"
        }
    }
    
    var muscleMassStatus: String {
        return muscleMass > 30 ? "Good" : "Needs Work"
    }
    
    var waterStatus: String {
        return waterPercentage > 55 ? "Hydrated" : "Dehydrated"
    }
    
    // MARK: - Initialization
    init() {
        setupMockData()
        checkAppleWatchConnection()
        loadSavedData()
    }
    
    // MARK: - Public Methods
    func loadAnalyticsData() {
        isLoading = true
        
        // Simulate API call
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.generateWeightData()
            self.generateWorkoutData()
            self.updateNutritionData()
            self.loadHealthMetrics()
            self.isLoading = false
        }
    }
    
    @MainActor
    func refreshData() async {
        isLoading = true
        
        // Simulate API refresh
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        
        generateWeightData()
        generateWorkoutData()
        updateNutritionData()
        
        if isAppleWatchConnected {
            await loadAppleWatchData()
        }
        
        isLoading = false
    }
    
    func shareProgress() {
        // Implementation for sharing progress
        print("Sharing progress...")
    }
    
    // Esta función se llamará desde Settings cuando se active Apple Health
    func enableAppleHealthIntegration() {
        requestHealthKitPermissions { [weak self] success in
            DispatchQueue.main.async {
                self?.isAppleWatchConnected = success
                if success {
                    Task {
                        await self?.loadAppleWatchData()
                    }
                }
            }
        }
    }
    
    // MARK: - Private Methods
    private func setupMockData() {
        recentAchievements = [
            Achievement(
                title: "Week Warrior",
                description: "Completed 5 workouts this week",
                icon: "flame.fill",
                date: Date().addingTimeInterval(-86400),
                isCompleted: true
            ),
            Achievement(
                title: "Calorie Master",
                description: "Hit your calorie goal 7 days in a row",
                icon: "target",
                date: Date().addingTimeInterval(-172800),
                isCompleted: true
            ),
            Achievement(
                title: "Early Bird",
                description: "Completed 10 morning workouts",
                icon: "sunrise.fill",
                date: Date().addingTimeInterval(-259200),
                isCompleted: true
            )
        ]
    }
    
    private func generateWeightData() {
        let calendar = Calendar.current
        let endDate = Date()
        let startDate = calendar.date(byAdding: .day, value: -selectedTimeRange.days, to: endDate) ?? endDate
        
        weightData = []
        let dayInterval = TimeInterval(86400) // 1 day
        var currentDate = startDate
        let startWeight = currentWeight + Double(selectedTimeRange.days) * 0.05
        
        while currentDate <= endDate {
            let daysFromStart = calendar.dateComponents([.day], from: startDate, to: currentDate).day ?? 0
            let weight = startWeight - (Double(daysFromStart) * 0.05) + Double.random(in: -0.3...0.3)
            
            weightData.append(WeightDataPoint(date: currentDate, weight: weight))
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
        }
        
        // Update current weight to the last data point
        if let lastWeight = weightData.last?.weight {
            currentWeight = lastWeight
        }
        
        // Calculate weight progress
        let totalWeightToLose = abs(goalWeight - (weightData.first?.weight ?? currentWeight))
        let weightLost = abs(currentWeight - (weightData.first?.weight ?? currentWeight))
        weightProgress = min(weightLost / totalWeightToLose, 1.0)
    }
    
    private func generateWorkoutData() {
        let calendar = Calendar.current
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        
        workoutData = []
        
        for i in 0..<min(selectedTimeRange.days, 30) {
            let date = calendar.date(byAdding: .day, value: -i, to: Date()) ?? Date()
            let dayName = formatter.string(from: date)
            let duration = Int.random(in: 20...75)
            
            workoutData.append(WorkoutDataPoint(day: dayName, duration: duration))
        }
        
        workoutData.reverse()
    }
    
    private func updateNutritionData() {
        // Generate nutrition insights based on current data
        let proteinPercentage = Double(avgProtein) / Double(proteinGoal)
        let carbsPercentage = Double(avgCarbs) / Double(carbsGoal)
        let fatsPercentage = Double(avgFats) / Double(fatsGoal)
        
        if proteinPercentage >= 0.9 {
            nutritionInsight = "Excellent protein intake! You're meeting your goals."
            nutritionInsightType = .positive
        } else if proteinPercentage < 0.7 {
            nutritionInsight = "Consider increasing your protein intake for better results."
            nutritionInsightType = .warning
        } else {
            nutritionInsight = "Good nutrition balance. Keep it up!"
            nutritionInsightType = .neutral
        }
    }
    
    private func loadHealthMetrics() {
        // Calculate BMI
        let heightInM = 1.75 // This should come from user profile
        currentBMI = currentWeight / (heightInM * heightInM)
    }
    
    private func checkAppleWatchConnection() {
        if HKHealthStore.isHealthDataAvailable() {
            // Check if we have permissions
            let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
            let status = healthStore.authorizationStatus(for: heartRateType)
            isAppleWatchConnected = status == .sharingAuthorized
        }
    }
    
    private func requestHealthKitPermissions(completion: @escaping (Bool) -> Void) {
        guard HKHealthStore.isHealthDataAvailable() else {
            completion(false)
            return
        }
        
        let typesToRead: Set<HKObjectType> = [
            HKQuantityType.quantityType(forIdentifier: .heartRate)!,
            HKQuantityType.quantityType(forIdentifier: .stepCount)!,
            HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!,
            HKCategoryType.categoryType(forIdentifier: .appleStandHour)!,
            HKQuantityType.quantityType(forIdentifier: .bodyMass)!
        ]
        
        healthStore.requestAuthorization(toShare: nil, read: typesToRead) { success, error in
            completion(success)
        }
    }
    
    @MainActor
    private func loadAppleWatchData() async {
        guard isAppleWatchConnected else { return }
        
        // Simulate loading Apple Watch data
        try? await Task.sleep(nanoseconds: 500_000_000)
        
        // In a real implementation, you would query HealthKit here
        avgHeartRate = Int.random(in: 65...85)
        avgSteps = Int.random(in: 7000...12000)
        activeEnergy = Int.random(in: 350...500)
        standHours = Int.random(in: 8...12)
    }
    
    private func loadSavedData() {
        // Load any saved analytics preferences
        if let savedRange = userDefaults.object(forKey: "selectedTimeRange") as? String,
           let range = AnalyticsTimeRange(rawValue: savedRange) {
            selectedTimeRange = range
        }
    }
    
    private func saveData() {
        userDefaults.set(selectedTimeRange.rawValue, forKey: "selectedTimeRange")
    }
}

// MARK: - Supporting View Models and Components
struct CircularProgressView: View {
    let progress: Double
    let color: Color
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(color.opacity(0.3), lineWidth: 4)
            
            Circle()
                .trim(from: 0, to: progress)
                .stroke(color, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                .rotationEffect(.degrees(-90))
            
            Text("\(Int(progress * 100))%")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.appWhite)
        }
        .frame(width: 40, height: 40)
    }
}

struct WorkoutMetricView: View {
    let title: String
    let value: String
    let unit: String
    
    var body: some View {
        VStack(alignment: .center, spacing: 4) {
            Text(value)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.appWhite)
            
            Text(unit)
                .font(.system(size: 10))
                .foregroundColor(.appWhite.opacity(0.6))
            
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.appWhite.opacity(0.8))
        }
    }
}

struct MacroProgressView: View {
    let title: String
    let current: Int
    let goal: Int
    let color: Color
    
    private var progress: Double {
        return min(Double(current) / Double(goal), 1.0)
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.appWhite)
            
            ZStack {
                Circle()
                    .stroke(color.opacity(0.3), lineWidth: 3)
                
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(color, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                
                VStack(spacing: 2) {
                    Text("\(current)")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.appWhite)
                    
                    Text("/ \(goal)g")
                        .font(.system(size: 8))
                        .foregroundColor(.appWhite.opacity(0.6))
                }
            }
            .frame(width: 50, height: 50)
        }
    }
}

struct NutritionInsight: View {
    let message: String
    let type: InsightType
    
    var body: some View {
        HStack {
            Image(systemName: type == .positive ? "checkmark.circle.fill" :
                           type == .warning ? "exclamationmark.triangle.fill" : "info.circle.fill")
                .foregroundColor(type.color)
                .font(.system(size: 16))
            
            Text(message)
                .font(.system(size: 14))
                .foregroundColor(.appWhite.opacity(0.8))
            
            Spacer()
        }
        .padding(12)
        .background(type.color.opacity(0.1))
        .cornerRadius(8)
    }
}

struct WatchMetricCard: View {
    let title: String
    let value: String
    let unit: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.system(size: 16))
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.appWhite)
                
                Text(unit)
                    .font(.system(size: 10))
                    .foregroundColor(.appWhite.opacity(0.6))
            }
            
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.appWhite.opacity(0.8))
        }
        .padding(12)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
}

struct HealthMetricView: View {
    let title: String
    let value: String
    let status: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.appWhite.opacity(0.8))
            
            Text(value)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.appWhite)
            
            Text(status)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(color)
                .padding(.horizontal, 8)
                .padding(.vertical, 2)
                .background(color.opacity(0.2))
                .cornerRadius(4)
        }
        .padding(12)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
}

struct AchievementRow: View {
    let achievement: Achievement
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.appYellow.opacity(0.2))
                    .frame(width: 40, height: 40)
                
                Image(systemName: achievement.icon)
                    .foregroundColor(.appYellow)
                    .font(.system(size: 18))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(achievement.title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.appWhite)
                
                Text(achievement.description)
                    .font(.system(size: 12))
                    .foregroundColor(.appWhite.opacity(0.7))
            }
            
            Spacer()
            
            Text(RelativeDateTimeFormatter().localizedString(for: achievement.date, relativeTo: Date()))
                .font(.system(size: 10))
                .foregroundColor(.appWhite.opacity(0.5))
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Simple Chart Views for iOS < 16
struct SimpleLineChart: View {
    let data: [Double]
    
    var body: some View {
        GeometryReader { geometry in
            let maxValue = data.max() ?? 1
            let minValue = data.min() ?? 0
            let range = maxValue - minValue
            
            Path { path in
                for (index, value) in data.enumerated() {
                    let x = geometry.size.width * CGFloat(index) / CGFloat(data.count - 1)
                    let y = geometry.size.height * CGFloat(1 - (value - minValue) / range)
                    
                    if index == 0 {
                        path.move(to: CGPoint(x: x, y: y))
                    } else {
                        path.addLine(to: CGPoint(x: x, y: y))
                    }
                }
            }
            .stroke(Color.appYellow, lineWidth: 2)
        }
    }
}

struct SimpleBarChart: View {
    let data: [Int]
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 4) {
            ForEach(Array(data.enumerated()), id: \.offset) { index, value in
                VStack {
                    Spacer()
                    Rectangle()
                        .fill(Color.appYellow)
                        .frame(height: CGFloat(value) * 2)
                        .cornerRadius(2)
                }
            }
        }
    }
}
