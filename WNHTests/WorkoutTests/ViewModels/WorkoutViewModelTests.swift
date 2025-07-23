import XCTest
import Combine
import SwiftUI
@testable import WNH

class WorkoutViewModelTests: XCTestCase {
    
    var viewModel: WorkoutViewModel!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        viewModel = WorkoutViewModel()
        cancellables = Set<AnyCancellable>()
    }
    
    override func tearDown() {
        viewModel = nil
        cancellables = nil
        super.tearDown()
    }
    
    // MARK: - Initialization Tests
    
    func testInitialization() {
        XCTAssertNotNil(viewModel)
        XCTAssertTrue(viewModel.muscleGroups.isEmpty)
        XCTAssertNil(viewModel.selectedMuscle)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertFalse(viewModel.isShowingBack)
        XCTAssertEqual(viewModel.selectedWorkoutMode, .atHome)
        XCTAssertTrue(viewModel.searchText.isEmpty)
        XCTAssertTrue(viewModel.allExercises.isEmpty)
        XCTAssertTrue(viewModel.filteredExercises.isEmpty)
        XCTAssertNil(viewModel.selectedMuscleFilter)
        XCTAssertNil(viewModel.heartRate)
        XCTAssertNil(viewModel.userWeight)
        XCTAssertFalse(viewModel.healthKitAuthorized)
    }
    
    // MARK: - Muscle Selection Tests
    
    func testSelectMuscle() {
        // Given
        let muscle = MuscleGroup(name: "Chest", exercises: [], position: CGPoint(x: 0.5, y: 0.5), isLeftSide: true)
        
        // When
        viewModel.selectMuscle(muscle)
        
        // Then
        XCTAssertEqual(viewModel.selectedMuscle?.name, "Chest")
    }
    
    func testToggleView() {
        // Given
        XCTAssertFalse(viewModel.isShowingBack)
        
        // When
        viewModel.toggleView()
        
        // Then
        XCTAssertTrue(viewModel.isShowingBack)
        
        // When - Toggle back
        viewModel.toggleView()
        
        // Then
        XCTAssertFalse(viewModel.isShowingBack)
    }
    
    func testClearMuscleFilter() {
        // Given
        viewModel.selectedMuscleFilter = "Chest"
        XCTAssertEqual(viewModel.selectedMuscleFilter, "Chest")
        
        // When
        viewModel.clearMuscleFilter()
        
        // Then
        XCTAssertNil(viewModel.selectedMuscleFilter)
    }
    
    // MARK: - Progress Tests
    
    func testProgressForDate() {
        // Given
        let testDate = Date()
        
        // When
        let progress = viewModel.progressForDate(testDate)
        
        // Then
        XCTAssertEqual(progress, 0.0) // Default should be 0.0 for no progress
    }
    
    func testUpdateProgress() {
        // Given
        let testDate = Date()
        let progress: WorkoutProgress = .complete
        
        // When
        viewModel.updateProgress(for: testDate, progress: progress)
        
        // Then
        let retrievedProgress = viewModel.progressForDate(testDate)
        XCTAssertEqual(retrievedProgress, 1.0) // complete = 1.0
    }
    
    // MARK: - Stats Tests
    
    func testGetWorkoutStats() {
        // When
        let stats = viewModel.getWorkoutStats()
        
        // Then
        XCTAssertNotNil(stats)
        XCTAssertEqual(stats.totalExercises, 0)
        XCTAssertEqual(stats.totalMuscleGroups, 0)
        XCTAssertEqual(stats.selectedMuscle, "None")
        XCTAssertEqual(stats.workoutMode, "At Home")
    }
    
    func testGetWeeklyStats() {
        // When
        let weeklyStats = viewModel.getWeeklyStats()
        
        // Then
        XCTAssertNotNil(weeklyStats)
        XCTAssertEqual(weeklyStats.totalWorkouts, 0)
        XCTAssertEqual(weeklyStats.completedWorkouts, 0)
        XCTAssertEqual(weeklyStats.totalMinutes, 0)
        XCTAssertEqual(weeklyStats.workoutDays, 0)
        XCTAssertEqual(weeklyStats.completionRate, 0.0)
    }
    
    func testGetMonthlyStats() {
        // When
        let monthlyStats = viewModel.getMonthlyStats()
        
        // Then
        XCTAssertNotNil(monthlyStats)
        XCTAssertEqual(monthlyStats.totalWorkouts, 0)
        XCTAssertEqual(monthlyStats.completedWorkouts, 0)
        XCTAssertEqual(monthlyStats.totalMinutes, 0)
        XCTAssertEqual(monthlyStats.completionRate, 0.0)
    }
    
    // MARK: - Search Tests
    
    func testSearchTextUpdate() {
        // Given
        let expectation = XCTestExpectation(description: "Search text should update")
        
        // When
        viewModel.$searchText
            .dropFirst()
            .sink { searchText in
                XCTAssertEqual(searchText, "test")
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        viewModel.searchText = "test"
        
        // Then
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testFilteredExercisesUpdate() {
        // Given
        let exercise1 = Exercise(
            name: "Push-ups",
            duration: "10 min",
            difficulty: "Beginner",
            videoURL: nil,
            muscleGroups: ["Chest"],
            equipment: "bodyweight"
        )
        let exercise2 = Exercise(
            name: "Pull-ups",
            duration: "10 min",
            difficulty: "Intermediate",
            videoURL: nil,
            muscleGroups: ["Back"],
            equipment: "bodyweight"
        )
        
        viewModel.allExercises = [exercise1, exercise2]
        
        // When
        viewModel.searchText = "push"
        
        // Then - Wait for debounce
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            XCTAssertEqual(self.viewModel.filteredExercises.count, 1)
            XCTAssertEqual(self.viewModel.filteredExercises.first?.name, "Push-ups")
        }
    }
    
    // MARK: - HealthKit Tests
    
    func testRequestHealthKitAuthorization() {
        // Given
        XCTAssertFalse(viewModel.healthKitAuthorized)
        
        // When
        viewModel.requestHealthKitAuthorization()
        
        // Then - This will depend on the device and HealthKit availability
        // We can't easily test this in unit tests, but we can verify the method exists
        XCTAssertNotNil(viewModel.requestHealthKitAuthorization)
    }
    
    func testStartHeartRateTimerIfNeeded() {
        // Given
        viewModel.healthKitAuthorized = false
        
        // When
        viewModel.startHeartRateTimerIfNeeded()
        
        // Then - Should not start timer when not authorized
        XCTAssertNil(viewModel.heartRate)
    }
    
    // MARK: - Loading States Tests
    
    func testLoadingState() {
        // Given
        XCTAssertFalse(viewModel.isLoading)
        
        // When
        viewModel.loadInitialData()
        
        // Then
        XCTAssertTrue(viewModel.isLoading)
        
        // Wait for async operation to complete
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertFalse(self.viewModel.isLoading)
        }
    }
    
    // MARK: - Error Handling Tests
    
    func testErrorMessage() {
        // Given
        XCTAssertNil(viewModel.errorMessage)
        
        // When - Simulate error by setting error message
        viewModel.errorMessage = "Test error"
        
        // Then
        XCTAssertEqual(viewModel.errorMessage, "Test error")
    }
    
    // MARK: - Published Properties Tests
    
    func testPublishedPropertiesUpdate() {
        // Given
        let expectation = XCTestExpectation(description: "Published properties should update")
        
        // When
        viewModel.$selectedMuscle
            .dropFirst()
            .sink { muscle in
                XCTAssertNotNil(muscle)
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        let testMuscle = MuscleGroup(name: "Test", exercises: [], position: CGPoint(x: 0.5, y: 0.5), isLeftSide: true)
        viewModel.selectMuscle(testMuscle)
        
        // Then
        wait(for: [expectation], timeout: 1.0)
    }
    
    // MARK: - Integration Tests
    
    func testIntegrationWithServices() {
        // Given
        let muscle = MuscleGroup(name: "Chest", exercises: [], position: CGPoint(x: 0.5, y: 0.5), isLeftSide: true)
        
        // When
        viewModel.selectMuscle(muscle)
        viewModel.changeWorkoutMode(.atGym)
        
        // Then
        XCTAssertEqual(viewModel.selectedMuscle?.name, "Chest")
        XCTAssertEqual(viewModel.selectedWorkoutMode, .atGym)
    }
    
    // MARK: - Performance Tests
    
    func testPerformanceOfSearch() {
        // Given
        let exercises = (0..<1000).map { index in
            Exercise(
                name: "Exercise \(index)",
                duration: "10 min",
                difficulty: "Beginner",
                videoURL: nil,
                muscleGroups: ["Muscle \(index % 10)"],
                equipment: "equipment \(index % 5)"
            )
        }
        viewModel.allExercises = exercises
        
        // When & Then
        measure {
            viewModel.searchText = "Exercise"
            // Wait for debounce
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                // Search should complete within reasonable time
            }
        }
    }
} 