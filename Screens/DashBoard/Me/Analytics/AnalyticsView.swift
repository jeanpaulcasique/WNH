import SwiftUI
import Charts

struct AnalyticsView: View {
    @StateObject private var viewModel = AnalyticsViewModel()
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack {
            Color.appBlack.ignoresSafeArea()
            
            ScrollView {
                LazyVStack(spacing: 24) {
                    headerSection
                    timeRangeSelector
                    overviewCards
                    weightProgressChart
                    workoutAnalyticsChart
                    nutritionChart
                    appleWatchSection
                    healthMetricsGrid
                    achievementsSection
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 100)
            }
        }
        .navigationTitle("Analytics")
        .navigationBarTitleDisplayMode(.inline)
        .foregroundColor(.appWhite)
        .onAppear {
            viewModel.loadAnalyticsData()
        }
        .refreshable {
            await viewModel.refreshData()
        }
    }
}

// MARK: - Subviews
private extension AnalyticsView {
    
    var headerSection: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Your Progress")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.appYellow)
                    
                    Text("Keep tracking your journey")
                        .font(.system(size: 16))
                        .foregroundColor(.appWhite.opacity(0.8))
                }
                
                Spacer()
                
                Button(action: {
                    viewModel.shareProgress()
                }) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 20))
                        .foregroundColor(.appYellow)
                }
            }
        }
        .padding(.top, 20)
    }
    
    var timeRangeSelector: some View {
        HStack(spacing: 0) {
            ForEach(AnalyticsTimeRange.allCases, id: \.self) { range in
                Button(action: {
                    viewModel.selectedTimeRange = range
                }) {
                    Text(range.displayName)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(viewModel.selectedTimeRange == range ? .black : .appWhite)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(
                            viewModel.selectedTimeRange == range ?
                            Color.appYellow : Color.clear
                        )
                }
            }
        }
        .background(Color.gray.opacity(0.2))
        .cornerRadius(12)
    }
    
    var overviewCards: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
            OverviewCard(
                title: "Weight Change",
                value: viewModel.weightChange,
                unit: "kg",
                trend: viewModel.weightTrend,
                icon: "scalemass.fill"
            )
            
            OverviewCard(
                title: "Workouts",
                value: String(viewModel.totalWorkouts),
                unit: "sessions",
                trend: .positive,
                icon: "figure.strengthtraining.traditional"
            )
            
            OverviewCard(
                title: "Avg Calories",
                value: String(viewModel.avgCaloriesConsumed),
                unit: "kcal/day",
                trend: viewModel.caloriesTrend,
                icon: "flame.fill"
            )
            
            OverviewCard(
                title: "Active Days",
                value: String(viewModel.activeDays),
                unit: "days",
                trend: .positive,
                icon: "calendar"
            )
        }
    }
    
    var weightProgressChart: some View {
        AnalyticsCard(title: "Weight Progress", icon: "chart.line.uptrend.xyaxis") {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    VStack(alignment: .leading) {
                        Text("Current: \(String(format: "%.1f", viewModel.currentWeight)) kg")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.appWhite)
                        
                        Text("Goal: \(String(format: "%.1f", viewModel.goalWeight)) kg")
                            .font(.system(size: 14))
                            .foregroundColor(.appWhite.opacity(0.7))
                    }
                    
                    Spacer()
                    
                    CircularProgressView(
                        progress: viewModel.weightProgress,
                        color: .appYellow
                    )
                }
                
                // Weight chart would go here using Charts framework
                if #available(iOS 16.0, *) {
                    Chart(viewModel.weightData) { data in
                        LineMark(
                            x: .value("Date", data.date),
                            y: .value("Weight", data.weight)
                        )
                        .foregroundStyle(Color.appYellow)
                    }
                    .frame(height: 120)
                    .chartYAxis {
                        AxisMarks(position: .leading)
                    }
                } else {
                    SimpleLineChart(data: viewModel.weightData.map { $0.weight })
                        .frame(height: 120)
                }
            }
        }
    }
    
    var workoutAnalyticsChart: some View {
        AnalyticsCard(title: "Workout Analytics", icon: "figure.strengthtraining.traditional") {
            VStack(spacing: 16) {
                HStack {
                    WorkoutMetricView(
                        title: "Total Time",
                        value: "\(viewModel.totalWorkoutMinutes)",
                        unit: "min"
                    )
                    
                    Spacer()
                    
                    WorkoutMetricView(
                        title: "Avg Duration",
                        value: "\(viewModel.avgWorkoutDuration)",
                        unit: "min"
                    )
                    
                    Spacer()
                    
                    WorkoutMetricView(
                        title: "Consistency",
                        value: "\(viewModel.workoutConsistency)",
                        unit: "%"
                    )
                }
                
                if #available(iOS 16.0, *) {
                    Chart(viewModel.workoutData) { data in
                        BarMark(
                            x: .value("Day", data.day),
                            y: .value("Duration", data.duration)
                        )
                        .foregroundStyle(Color.appYellow)
                    }
                    .frame(height: 100)
                } else {
                    SimpleBarChart(data: viewModel.workoutData.map { $0.duration })
                        .frame(height: 100)
                }
            }
        }
    }
    
    var nutritionChart: some View {
        AnalyticsCard(title: "Nutrition Breakdown", icon: "fork.knife") {
            VStack(spacing: 16) {
                HStack {
                    MacroProgressView(
                        title: "Protein",
                        current: viewModel.avgProtein,
                        goal: viewModel.proteinGoal,
                        color: .red
                    )
                    
                    MacroProgressView(
                        title: "Carbs",
                        current: viewModel.avgCarbs,
                        goal: viewModel.carbsGoal,
                        color: .blue
                    )
                    
                    MacroProgressView(
                        title: "Fats",
                        current: viewModel.avgFats,
                        goal: viewModel.fatsGoal,
                        color: .green
                    )
                }
                
                NutritionInsight(
                    message: viewModel.nutritionInsight,
                    type: viewModel.nutritionInsightType
                )
            }
        }
    }
    
    var appleWatchSection: some View {
        Group {
            if viewModel.isAppleWatchConnected {
                AnalyticsCard(title: "Apple Watch Data", icon: "applewatch") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                        WatchMetricCard(
                            title: "Heart Rate",
                            value: "\(viewModel.avgHeartRate)",
                            unit: "bpm",
                            icon: "heart.fill",
                            color: .red
                        )
                        
                        WatchMetricCard(
                            title: "Steps",
                            value: "\(viewModel.avgSteps)",
                            unit: "steps",
                            icon: "figure.walk",
                            color: .green
                        )
                        
                        WatchMetricCard(
                            title: "Active Energy",
                            value: "\(viewModel.activeEnergy)",
                            unit: "kcal",
                            icon: "flame.fill",
                            color: .orange
                        )
                        
                        WatchMetricCard(
                            title: "Stand Hours",
                            value: "\(viewModel.standHours)",
                            unit: "hours",
                            icon: "figure.stand",
                            color: .blue
                        )
                    }
                }
            }
        }
    }
    
    var healthMetricsGrid: some View {
        AnalyticsCard(title: "Health Metrics", icon: "heart.text.square") {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                HealthMetricView(
                    title: "BMI",
                    value: String(format: "%.1f", viewModel.currentBMI),
                    status: viewModel.bmiStatus,
                    color: viewModel.bmiStatusColor
                )
                
                HealthMetricView(
                    title: "Body Fat",
                    value: String(format: "%.1f%%", viewModel.bodyFatPercentage),
                    status: viewModel.bodyFatStatus,
                    color: .appYellow
                )
                
                HealthMetricView(
                    title: "Muscle Mass",
                    value: String(format: "%.1f kg", viewModel.muscleMass),
                    status: viewModel.muscleMassStatus,
                    color: .green
                )
                
                HealthMetricView(
                    title: "Water %",
                    value: String(format: "%.1f%%", viewModel.waterPercentage),
                    status: viewModel.waterStatus,
                    color: .blue
                )
            }
        }
    }
    
    var achievementsSection: some View {
        AnalyticsCard(title: "Recent Achievements", icon: "trophy.fill") {
            VStack(spacing: 12) {
                ForEach(viewModel.recentAchievements, id: \.id) { achievement in
                    AchievementRow(achievement: achievement)
                }
                
                if viewModel.recentAchievements.isEmpty {
                    Text("Keep working towards your first achievement!")
                        .font(.system(size: 14))
                        .foregroundColor(.appWhite.opacity(0.6))
                        .padding(.vertical, 20)
                }
            }
        }
    }
}

struct AnalyticsCard<Content: View>: View {
    let title: String
    let icon: String
    let content: Content
    
    init(title: String, icon: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.icon = icon
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.appYellow)
                    .font(.system(size: 18))
                
                Text(title)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.appWhite)
                
                Spacer()
            }
            
            content
        }
        .padding(20)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(16)
    }
}

struct OverviewCard: View {
    let title: String
    let value: String
    let unit: String
    let trend: TrendDirection
    let icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.appYellow)
                    .font(.system(size: 20))
                
                Spacer()
                
                Image(systemName: trend.iconName)
                    .foregroundColor(trend.color)
                    .font(.system(size: 14))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(value)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.appWhite)
                
                Text(unit)
                    .font(.system(size: 12))
                    .foregroundColor(.appWhite.opacity(0.7))
            }
            
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.appWhite.opacity(0.8))
        }
        .padding(16)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}

// MARK: - Preview
struct AnalyticsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            AnalyticsView()
        }
        .preferredColorScheme(.dark)
    }
}
