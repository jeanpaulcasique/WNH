import XCTest
import Combine
@testable import WNH

class ProgressServiceTests: XCTestCase {
    
    var progressService: ProgressService!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        progressService = ProgressService()
        cancellables = Set<AnyCancellable>()
        
        // Limpiar UserDefaults para tests
        UserDefaults.standard.removeObject(forKey: "workoutProgress")
        UserDefaults.standard.removeObject(forKey: "workoutStreak")
        UserDefaults.standard.removeObject(forKey: "longestWorkoutStreak")
    }
    
    override func tearDown() {
        progressService = nil
        cancellables = nil
        super.tearDown()
    }
    
    // MARK: - Initialization Tests
    
    func testInitialization() {
        XCTAssertNotNil(progressService)
        XCTAssertTrue(progressService.dailyProgress.isEmpty)
        XCTAssertEqual(progressService.currentStreak, 0)
        XCTAssertEqual(progressService.longestStreak, 0)
    }
    
    // MARK: - Progress Update Tests
    
    func testUpdateProgress() {
        // Given
        let testDate = Date()
        let progress: WorkoutProgress = .complete
        
        // When
        progressService.updateProgress(for: testDate, progress: progress)
        
        // Then
        let savedProgress = progressService.getProgress(for: testDate)
        XCTAssertEqual(savedProgress, progress)
    }
    
    func testUpdateProgressMultipleDays() {
        // Given
        let calendar = Calendar.current
        let today = Date()
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        let twoDaysAgo = calendar.date(byAdding: .day, value: -2, to: today)!
        
        // When
        progressService.updateProgress(for: today, progress: .complete)
        progressService.updateProgress(for: yesterday, progress: .partial)
        progressService.updateProgress(for: twoDaysAgo, progress: .none)
        
        // Then
        XCTAssertEqual(progressService.getProgress(for: today), .complete)
        XCTAssertEqual(progressService.getProgress(for: yesterday), .partial)
        XCTAssertEqual(progressService.getProgress(for: twoDaysAgo), .none)
    }
    
    func testGetProgressForNonExistentDate() {
        // Given
        let testDate = Date()
        
        // When
        let progress = progressService.getProgress(for: testDate)
        
        // Then
        XCTAssertEqual(progress, .none)
    }
    
    // MARK: - Completion Percentage Tests
    
    func testGetCompletionPercentage() {
        // Given
        let testDate = Date()
        
        // When & Then
        progressService.updateProgress(for: testDate, progress: .none)
        XCTAssertEqual(progressService.getCompletionPercentage(for: testDate), 0.0)
        
        progressService.updateProgress(for: testDate, progress: .partial)
        XCTAssertEqual(progressService.getCompletionPercentage(for: testDate), 0.5)
        
        progressService.updateProgress(for: testDate, progress: .complete)
        XCTAssertEqual(progressService.getCompletionPercentage(for: testDate), 1.0)
    }
    
    // MARK: - Weekly Progress Tests
    
    func testGetWeeklyProgress() {
        // Given
        let calendar = Calendar.current
        let weekStart = calendar.dateInterval(of: .weekOfYear, for: Date())?.start ?? Date()
        
        // When
        let weeklyProgress = progressService.getWeeklyProgress(for: weekStart)
        
        // Then
        XCTAssertEqual(weeklyProgress.count, 7)
        XCTAssertTrue(weeklyProgress.allSatisfy { $0 == .none })
    }
    
    func testGetWeeklyProgressWithData() {
        // Given
        let calendar = Calendar.current
        let weekStart = calendar.dateInterval(of: .weekOfYear, for: Date())?.start ?? Date()
        let today = Date()
        
        progressService.updateProgress(for: today, progress: .complete)
        
        // When
        let weeklyProgress = progressService.getWeeklyProgress(for: weekStart)
        
        // Then
        XCTAssertEqual(weeklyProgress.count, 7)
        let todayIndex = calendar.component(.weekday, from: today) - 1
        XCTAssertEqual(weeklyProgress[todayIndex], .complete)
    }
    
    // MARK: - Monthly Stats Tests
    
    func testGetMonthlyStats() {
        // Given
        let calendar = Calendar.current
        let today = Date()
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        
        progressService.updateProgress(for: today, progress: .complete)
        progressService.updateProgress(for: yesterday, progress: .partial)
        
        // When
        let monthlyStats = progressService.getMonthlyStats()
        
        // Then
        XCTAssertEqual(monthlyStats.totalWorkouts, 2)
        XCTAssertEqual(monthlyStats.completedWorkouts, 1)
        XCTAssertEqual(monthlyStats.totalMinutes, 90) // 60 + 30
        XCTAssertEqual(monthlyStats.completionRate, 0.5)
    }
    
    func testGetMonthlyStatsEmpty() {
        // When
        let monthlyStats = progressService.getMonthlyStats()
        
        // Then
        XCTAssertEqual(monthlyStats.totalWorkouts, 0)
        XCTAssertEqual(monthlyStats.completedWorkouts, 0)
        XCTAssertEqual(monthlyStats.totalMinutes, 0)
        XCTAssertEqual(monthlyStats.completionRate, 0.0)
    }
    
    // MARK: - Streak Tests
    
    func testCurrentStreakCalculation() {
        // Given
        let calendar = Calendar.current
        let today = Date()
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        let twoDaysAgo = calendar.date(byAdding: .day, value: -2, to: today)!
        
        // When
        progressService.updateProgress(for: today, progress: .complete)
        progressService.updateProgress(for: yesterday, progress: .partial)
        progressService.updateProgress(for: twoDaysAgo, progress: .complete)
        
        // Then
        XCTAssertEqual(progressService.currentStreak, 3)
    }
    
    func testLongestStreakUpdate() {
        // Given
        let calendar = Calendar.current
        let today = Date()
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        let twoDaysAgo = calendar.date(byAdding: .day, value: -2, to: today)!
        let threeDaysAgo = calendar.date(byAdding: .day, value: -3, to: today)!
        
        // When - Crear un streak de 4 días
        progressService.updateProgress(for: today, progress: .complete)
        progressService.updateProgress(for: yesterday, progress: .complete)
        progressService.updateProgress(for: twoDaysAgo, progress: .complete)
        progressService.updateProgress(for: threeDaysAgo, progress: .complete)
        
        // Then
        XCTAssertEqual(progressService.currentStreak, 4)
        XCTAssertEqual(progressService.longestStreak, 4)
    }
    
    func testStreakBreak() {
        // Given
        let calendar = Calendar.current
        let today = Date()
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        let twoDaysAgo = calendar.date(byAdding: .day, value: -2, to: today)!
        let threeDaysAgo = calendar.date(byAdding: .day, value: -3, to: today)!
        
        // When - Crear un streak y luego romperlo
        progressService.updateProgress(for: threeDaysAgo, progress: .complete)
        progressService.updateProgress(for: twoDaysAgo, progress: .complete)
        progressService.updateProgress(for: yesterday, progress: .none) // Rompe el streak
        progressService.updateProgress(for: today, progress: .complete)
        
        // Then
        XCTAssertEqual(progressService.currentStreak, 1)
        XCTAssertEqual(progressService.longestStreak, 2)
    }
    
    // MARK: - Reset Progress Tests
    
    func testResetProgress() {
        // Given
        let testDate = Date()
        progressService.updateProgress(for: testDate, progress: .complete)
        XCTAssertEqual(progressService.getProgress(for: testDate), .complete)
        
        // When
        progressService.resetProgress(for: testDate)
        
        // Then
        XCTAssertEqual(progressService.getProgress(for: testDate), .none)
    }
    
    // MARK: - Export/Import Tests
    
    func testExportProgress() {
        // Given
        let testDate = Date()
        progressService.updateProgress(for: testDate, progress: .complete)
        
        // When
        let exportData = progressService.exportProgress()
        
        // Then
        XCTAssertNotNil(exportData)
        XCTAssertTrue(exportData!.count > 0)
    }
    
    func testImportProgress() {
        // Given
        let testDate = Date()
        progressService.updateProgress(for: testDate, progress: .complete)
        let exportData = progressService.exportProgress()!
        
        // When - Crear nuevo servicio e importar
        let newProgressService = ProgressService()
        let importSuccess = newProgressService.importProgress(from: exportData)
        
        // Then
        XCTAssertTrue(importSuccess)
        XCTAssertEqual(newProgressService.getProgress(for: testDate), .complete)
    }
    
    func testImportInvalidData() {
        // Given
        let invalidData = "invalid data".data(using: .utf8)!
        
        // When
        let importSuccess = progressService.importProgress(from: invalidData)
        
        // Then
        XCTAssertFalse(importSuccess)
    }
    
    // MARK: - Published Properties Tests
    
    func testPublishedPropertiesUpdate() {
        // Given
        let expectation = XCTestExpectation(description: "Published properties should update")
        
        // When
        progressService.$currentStreak
            .dropFirst()
            .sink { streak in
                XCTAssertEqual(streak, 1)
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        let testDate = Date()
        progressService.updateProgress(for: testDate, progress: .complete)
        
        // Then
        wait(for: [expectation], timeout: 1.0)
    }
    
    // MARK: - Weekly Stats Tests
    
    func testWeeklyStatsCalculation() {
        // Given
        let calendar = Calendar.current
        let today = Date()
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        
        progressService.updateProgress(for: today, progress: .complete)
        progressService.updateProgress(for: yesterday, progress: .partial)
        
        // When
        let weeklyStats = progressService.weeklyStats
        
        // Then
        XCTAssertEqual(weeklyStats.totalWorkouts, 2)
        XCTAssertEqual(weeklyStats.completedWorkouts, 1)
        XCTAssertEqual(weeklyStats.totalMinutes, 90)
        XCTAssertEqual(weeklyStats.workoutDays, 2)
        XCTAssertEqual(weeklyStats.completionRate, 0.5)
    }
    
    func testWeeklyStatsCalculatedProperties() {
        // Given
        let calendar = Calendar.current
        let today = Date()
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        
        progressService.updateProgress(for: today, progress: .complete)
        progressService.updateProgress(for: yesterday, progress: .partial)
        
        // When
        let weeklyStats = progressService.weeklyStats
        
        // Then
        XCTAssertEqual(weeklyStats.averageMinutesPerWorkout, 45.0)
        XCTAssertEqual(weeklyStats.averageMinutesPerDay, 45.0)
    }
} 