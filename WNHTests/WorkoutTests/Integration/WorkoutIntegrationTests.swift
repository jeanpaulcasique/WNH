import XCTest
import Combine
@testable import WNH

class WorkoutIntegrationTests: XCTestCase {
    
    var workoutService: WorkoutService!
    var progressService: ProgressService!
    var userPreferencesService: UserPreferencesService!
    var healthKitService: HealthKitService!
    var performanceOptimizer: PerformanceOptimizer!
    var templateService: WorkoutTemplateService!
    var viewModel: WorkoutViewModel!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        workoutService = WorkoutService()
        progressService = ProgressService()
        userPreferencesService = UserPreferencesService()
        healthKitService = HealthKitService()
        performanceOptimizer = PerformanceOptimizer()
        templateService = WorkoutTemplateService(
            userPreferencesService: userPreferencesService,
            progressService: progressService
        )
        viewModel = WorkoutViewModel()
        cancellables = Set<AnyCancellable>()
        
        // Limpiar UserDefaults para tests
        UserDefaults.standard.removeObject(forKey: "workoutProgress")
        UserDefaults.standard.removeObject(forKey: "workoutStreak")
        UserDefaults.standard.removeObject(forKey: "longestWorkoutStreak")
        UserDefaults.standard.removeObject(forKey: "userWorkoutTemplates")
        UserDefaults.standard.removeObject(forKey: "workoutCompletions")
    }
    
    override func tearDown() {
        workoutService = nil
        progressService = nil
        userPreferencesService = nil
        healthKitService = nil
        performanceOptimizer = nil
        templateService = nil
        viewModel = nil
        cancellables = nil
        super.tearDown()
    }
    
    // MARK: - Service Integration Tests
    
    func testWorkoutServiceAndProgressServiceIntegration() {
        // Given
        let testDate = Date()
        let muscle = MuscleGroup(name: "Chest", exercises: [], position: CGPoint(x: 0.5, y: 0.5), isLeftSide: true)
        
        // When
        workoutService.selectMuscle(muscle)
        progressService.updateProgress(for: testDate, progress: .complete)
        
        // Then
        XCTAssertEqual(workoutService.selectedMuscle?.name, "Chest")
        XCTAssertEqual(progressService.getProgress(for: testDate), .complete)
        XCTAssertEqual(progressService.currentStreak, 1)
    }
    
    func testUserPreferencesAndTemplateServiceIntegration() {
        // Given
        userPreferencesService.workoutGoal = .muscleGain
        userPreferencesService.workoutLevel = .intermediate
        
        // When
        let recommendations = templateService.getRecommendations(for: .muscleGain)
        
        // Then
        XCTAssertFalse(recommendations.isEmpty)
        XCTAssertTrue(recommendations.allSatisfy { template in
            template.tags.contains("strength") || template.category == .strength
        })
    }
    
    func testPerformanceOptimizerAndWorkoutServiceIntegration() async throws {
        // Given
        let muscleName = "Chest"
        let exercises = [
            Exercise(
                name: "Push-ups",
                duration: "10 min",
                difficulty: "Beginner",
                videoURL: nil,
                muscleGroups: ["Chest"],
                equipment: "bodyweight"
            )
        ]
        
        // When
        let cachedExercises = try await performanceOptimizer.getExercises(for: muscleName) {
            return exercises
        }
        
        // Then
        XCTAssertEqual(cachedExercises.count, 1)
        XCTAssertEqual(cachedExercises.first?.name, "Push-ups")
        
        // Test cache hit
        let cachedExercisesAgain = try await performanceOptimizer.getExercises(for: muscleName) {
            return []
        }
        XCTAssertEqual(cachedExercisesAgain.count, 1) // Should return cached version
    }
    
    // MARK: - ViewModel Integration Tests
    
    func testViewModelAndServicesIntegration() {
        // Given
        let muscle = MuscleGroup(name: "Back", exercises: [], position: CGPoint(x: 0.3, y: 0.3), isLeftSide: true)
        let testDate = Date()
        
        // When
        viewModel.selectMuscle(muscle)
        viewModel.updateProgress(for: testDate, progress: .partial)
        
        // Then
        XCTAssertEqual(viewModel.selectedMuscle?.name, "Back")
        XCTAssertEqual(viewModel.progressForDate(testDate), 0.5) // partial = 0.5
    }
    
    func testViewModelSearchAndFilteringIntegration() {
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
        viewModel.selectedMuscleFilter = "Chest"
        
        // Then - Wait for debounce
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            XCTAssertEqual(self.viewModel.filteredExercises.count, 1)
            XCTAssertEqual(self.viewModel.filteredExercises.first?.name, "Push-ups")
        }
    }
    
    // MARK: - Template Service Integration Tests
    
    func testTemplateCreationAndProgressIntegration() {
        // Given
        let template = WorkoutTemplate(
            id: "test_template",
            name: "Test Template",
            description: "Test description",
            difficulty: .beginner,
            duration: 30,
            exercises: [
                TemplateExercise(name: "Push-ups", sets: 3, reps: "10", rest: 60)
            ],
            category: .fullBody,
            equipment: [.bodyweight],
            tags: ["test"]
        )
        
        // When
        templateService.createTemplate(template)
        templateService.startTemplate(template)
        
        // Then
        XCTAssertEqual(templateService.userTemplates.count, 1)
        XCTAssertEqual(templateService.currentTemplate?.name, "Test Template")
    }
    
    func testTemplateCompletionAndProgressUpdate() {
        // Given
        let template = WorkoutTemplate(
            id: "test_template",
            name: "Test Template",
            description: "Test description",
            difficulty: .beginner,
            duration: 30,
            exercises: [
                TemplateExercise(name: "Push-ups", sets: 3, reps: "10", rest: 60)
            ],
            category: .fullBody,
            equipment: [.bodyweight],
            tags: ["test"]
        )
        
        templateService.createTemplate(template)
        templateService.startTemplate(template)
        
        // When
        let expectation = XCTestExpectation(description: "Template completion")
        templateService.completeTemplate(template) { success in
            XCTAssertTrue(success)
            expectation.fulfill()
        }
        
        // Then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertNil(templateService.currentTemplate)
        
        let completions = templateService.getWorkoutCompletions()
        XCTAssertEqual(completions.count, 1)
        XCTAssertEqual(completions.first?.templateName, "Test Template")
    }
    
    // MARK: - HealthKit Integration Tests
    
    func testHealthKitAndProgressServiceIntegration() {
        // Given
        let testHeartRate = 150.0
        let testWeight = 70.0
        
        // When
        healthKitService.heartRate = testHeartRate
        healthKitService.userWeight = testWeight
        
        // Then
        XCTAssertEqual(healthKitService.heartRate, testHeartRate)
        XCTAssertEqual(healthKitService.userWeight, testWeight)
    }
    
    // MARK: - Performance Integration Tests
    
    func testPerformanceOptimizerMemoryManagement() {
        // Given
        let initialMemoryUsage = performanceOptimizer.memoryUsage
        
        // When - Simulate memory warning
        NotificationCenter.default.post(name: UIApplication.didReceiveMemoryWarningNotification, object: nil)
        
        // Then
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let newMemoryUsage = self.performanceOptimizer.memoryUsage
            XCTAssertLessThanOrEqual(newMemoryUsage, initialMemoryUsage)
        }
    }
    
    func testPerformanceOptimizerCacheMetrics() {
        // Given
        let initialHitRate = performanceOptimizer.cacheHitRate
        
        // When - Perform some operations that would use cache
        let muscleName = "Test"
        Task {
            _ = try await performanceOptimizer.getExercises(for: muscleName) {
                return []
            }
        }
        
        // Then
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let newHitRate = self.performanceOptimizer.cacheHitRate
            XCTAssertGreaterThanOrEqual(newHitRate, initialHitRate)
        }
    }
    
    // MARK: - End-to-End Workflow Tests
    
    func testCompleteWorkoutWorkflow() {
        // Given
        let muscle = MuscleGroup(name: "Chest", exercises: [], position: CGPoint(x: 0.5, y: 0.5), isLeftSide: true)
        let testDate = Date()
        
        // When - Complete workflow
        workoutService.selectMuscle(muscle)
        workoutService.changeWorkoutMode(.atHome)
        progressService.updateProgress(for: testDate, progress: .complete)
        
        // Then
        XCTAssertEqual(workoutService.selectedMuscle?.name, "Chest")
        XCTAssertEqual(workoutService.selectedWorkoutMode, .atHome)
        XCTAssertEqual(progressService.getProgress(for: testDate), .complete)
        XCTAssertEqual(progressService.currentStreak, 1)
        
        // Test stats integration
        let stats = workoutService.getWorkoutStats()
        XCTAssertEqual(stats.selectedMuscle, "Chest")
        XCTAssertEqual(stats.workoutMode, "At Home")
    }
    
    func testTemplateRecommendationWorkflow() {
        // Given
        userPreferencesService.workoutGoal = .weightLoss
        userPreferencesService.workoutLevel = .beginner
        userPreferencesService.selectedWorkoutMode = .atHome
        
        // When
        let recommendations = templateService.recommendedTemplates
        
        // Then
        XCTAssertFalse(recommendations.isEmpty)
        XCTAssertTrue(recommendations.allSatisfy { template in
            template.difficulty == .beginner &&
            (template.tags.contains("fat-burning") || template.category == .cardio) &&
            template.equipment.allSatisfy { $0 == .bodyweight }
        })
    }
    
    // MARK: - Error Handling Integration Tests
    
    func testErrorHandlingAcrossServices() {
        // Given
        let invalidData = "invalid data".data(using: .utf8)!
        
        // When
        let importSuccess = progressService.importProgress(from: invalidData)
        
        // Then
        XCTAssertFalse(importSuccess)
    }
    
    // MARK: - Performance Integration Tests
    
    func testLazyLoadingIntegration() {
        // Given
        let items = Array(0..<100).map { "Item \($0)" }
        let lazyLoader = performanceOptimizer.lazyLoadItems(items, pageSize: 20)
        
        // When
        let firstPage = lazyLoader.loadNextPage()
        let secondPage = lazyLoader.loadNextPage()
        
        // Then
        XCTAssertEqual(firstPage.count, 20)
        XCTAssertEqual(secondPage.count, 20)
        XCTAssertTrue(lazyLoader.hasMorePages())
        XCTAssertEqual(firstPage.first, "Item 0")
        XCTAssertEqual(secondPage.first, "Item 20")
    }
    
    func testOptimizedListIntegration() {
        // Given
        struct TestItem: Identifiable {
            let id = UUID()
            let name: String
        }
        
        let items = Array(0..<50).map { TestItem(name: "Item \($0)") }
        let optimizedList = performanceOptimizer.optimizeScrollPerformance(items)
        
        // When
        let visibleItems = optimizedList.getVisibleItems()
        
        // Then
        XCTAssertLessThanOrEqual(visibleItems.count, 10) // visibleRange = 10
        XCTAssertNotNil(optimizedList.getItem(at: 0))
        XCTAssertNil(optimizedList.getItem(at: 100)) // Out of bounds
    }
} 