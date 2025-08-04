import XCTest
import Combine
@testable import WNH

class WorkoutServiceTests: XCTestCase {
    
    var workoutService: WorkoutService!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        workoutService = WorkoutService()
        cancellables = Set<AnyCancellable>()
    }
    
    override func tearDown() {
        workoutService = nil
        cancellables = nil
        super.tearDown()
    }
    
    // MARK: - Initialization Tests
    
    func testInitialization() {
        XCTAssertNotNil(workoutService)
        XCTAssertEqual(workoutService.selectedWorkoutMode, .atHome)
        XCTAssertNil(workoutService.selectedMuscle)
        XCTAssertTrue(workoutService.allExercises.isEmpty)
        XCTAssertTrue(workoutService.muscleGroups.isEmpty)
    }
    
    // MARK: - Muscle Selection Tests
    
    func testSelectMuscle() {
        // Given
        let muscle = MuscleGroup(name: "Chest", exercises: [], position: CGPoint(x: 0.5, y: 0.5), isLeftSide: true)
        
        // When
        workoutService.selectMuscle(muscle)
        
        // Then
        XCTAssertEqual(workoutService.selectedMuscle?.name, "Chest")
    }
    
    func testSelectMuscleUpdatesUserDefaults() {
        // Given
        let muscle = MuscleGroup(name: "Back", exercises: [], position: CGPoint(x: 0.3, y: 0.3), isLeftSide: false)
        
        // When
        workoutService.selectMuscle(muscle)
        
        // Then
        let savedMuscle = UserDefaults.standard.string(forKey: "selectedMuscle")
        XCTAssertEqual(savedMuscle, "Back")
    }
    
    // MARK: - Workout Mode Tests
    
    func testChangeWorkoutMode() {
        // Given
        XCTAssertEqual(workoutService.selectedWorkoutMode, .atHome)
        
        // When
        workoutService.changeWorkoutMode(.atTheGym)
        
        // Then
        XCTAssertEqual(workoutService.selectedWorkoutMode, .atTheGym)
    }
    
    func testChangeWorkoutModeUpdatesUserDefaults() {
        // When
        workoutService.changeWorkoutMode(.outdoors)
        
        // Then
        let savedMode = UserDefaults.standard.string(forKey: "selectedWorkoutMode")
        XCTAssertEqual(savedMode, "Outdoors")
    }
    
    // MARK: - Exercise Filtering Tests
    
    func testGetExercisesForMuscle() {
        // Given
        let chestMuscle = MuscleGroup(name: "Chest", exercises: [], position: CGPoint(x: 0.5, y: 0.5), isLeftSide: true)
        let chestExercise = Exercise(
            name: "Push-ups",
            duration: "10 min",
            difficulty: "Beginner",
            videoURL: nil,
            muscleGroups: ["Chest"],
            equipment: ["bodyweight"]
        )
        let backExercise = Exercise(
            name: "Pull-ups",
            duration: "10 min",
            difficulty: "Intermediate",
            videoURL: nil,
            muscleGroups: ["Back"],
            equipment: ["bodyweight"]
        )
        
        workoutService.allExercises = [chestExercise, backExercise]
        
        // When
        let exercises = workoutService.getExercisesForMuscle(chestMuscle)
        
        // Then
        XCTAssertEqual(exercises.count, 1)
        XCTAssertEqual(exercises.first?.name, "Push-ups")
    }
    
    func testGetExercisesForLocation() {
        // Given
        let homeExercise = Exercise(
            name: "Push-ups",
            duration: "10 min",
            difficulty: "Beginner",
            videoURL: nil,
            muscleGroups: ["Chest"],
            equipment: ["bodyweight"]
        )
        let gymExercise = Exercise(
            name: "Bench Press",
            duration: "15 min",
            difficulty: "Advanced",
            videoURL: nil,
            muscleGroups: ["Chest"],
            equipment: ["barbell"]
        )
        
        workoutService.allExercises = [homeExercise, gymExercise]
        
        // When
        let homeExercises = workoutService.getExercisesForLocation(.atHome)
        let gymExercises = workoutService.getExercisesForLocation(.atTheGym)
        
        // Then
        XCTAssertEqual(homeExercises.count, 1)
        XCTAssertEqual(homeExercises.first?.name, "Push-ups")
        XCTAssertEqual(gymExercises.count, 1)
        XCTAssertEqual(gymExercises.first?.name, "Bench Press")
    }
    
    func testGetFilteredExercises() {
        // Given
        let chestMuscle = MuscleGroup(name: "Chest", exercises: [], position: CGPoint(x: 0.5, y: 0.5), isLeftSide: true)
        let chestHomeExercise = Exercise(
            name: "Push-ups",
            duration: "10 min",
            difficulty: "Beginner",
            videoURL: nil,
            muscleGroups: ["Chest"],
            equipment: ["bodyweight"]
        )
        let chestGymExercise = Exercise(
            name: "Bench Press",
            duration: "15 min",
            difficulty: "Advanced",
            videoURL: nil,
            muscleGroups: ["Chest"],
            equipment: ["barbell"]
        )
        
        workoutService.allExercises = [chestHomeExercise, chestGymExercise]
        
        // When
        let filteredExercises = workoutService.getFilteredExercises(
            muscle: chestMuscle,
            location: .atHome
        )
        
        // Then
        XCTAssertEqual(filteredExercises.count, 1)
        XCTAssertEqual(filteredExercises.first?.name, "Push-ups")
    }
    
    // MARK: - Search Tests
    
    func testSearchExercises() {
        // Given
        let exercise1 = Exercise(
            name: "Push-ups",
            duration: "10 min",
            difficulty: "Beginner",
            videoURL: nil,
            muscleGroups: ["Chest"],
            equipment: ["bodyweight"]
        )
        let exercise2 = Exercise(
            name: "Pull-ups",
            duration: "10 min",
            difficulty: "Intermediate",
            videoURL: nil,
            muscleGroups: ["Back"],
            equipment: ["bodyweight"]
        )
        
        workoutService.allExercises = [exercise1, exercise2]
        
        // When
        let searchResults = workoutService.searchExercises(query: "push")
        
        // Then
        XCTAssertEqual(searchResults.count, 1)
        XCTAssertEqual(searchResults.first?.name, "Push-ups")
    }
    
    func testSearchExercisesByMuscleGroup() {
        // Given
        let exercise1 = Exercise(
            name: "Push-ups",
            duration: "10 min",
            difficulty: "Beginner",
            videoURL: nil,
            muscleGroups: ["Chest"],
            equipment: ["bodyweight"]
        )
        let exercise2 = Exercise(
            name: "Pull-ups",
            duration: "10 min",
            difficulty: "Intermediate",
            videoURL: nil,
            muscleGroups: ["Back"],
            equipment: ["bodyweight"]
        )
        
        workoutService.allExercises = [exercise1, exercise2]
        
        // When
        let searchResults = workoutService.searchExercises(query: "chest")
        
        // Then
        XCTAssertEqual(searchResults.count, 1)
        XCTAssertEqual(searchResults.first?.name, "Push-ups")
    }
    
    func testSearchExercisesByEquipment() {
        // Given
        let exercise1 = Exercise(
            name: "Push-ups",
            duration: "10 min",
            difficulty: "Beginner",
            videoURL: nil,
            muscleGroups: ["Chest"],
            equipment: ["bodyweight"]
        )
        let exercise2 = Exercise(
            name: "Bench Press",
            duration: "15 min",
            difficulty: "Advanced",
            videoURL: nil,
            muscleGroups: ["Chest"],
            equipment: ["barbell"]
        )
        
        workoutService.allExercises = [exercise1, exercise2]
        
        // When
        let searchResults = workoutService.searchExercises(query: "barbell")
        
        // Then
        XCTAssertEqual(searchResults.count, 1)
        XCTAssertEqual(searchResults.first?.name, "Bench Press")
    }
    
    func testSearchExercisesEmptyQuery() {
        // Given
        let exercise1 = Exercise(
            name: "Push-ups",
            duration: "10 min",
            difficulty: "Beginner",
            videoURL: nil,
            muscleGroups: ["Chest"],
            equipment: ["bodyweight"]
        )
        
        workoutService.allExercises = [exercise1]
        
        // When
        let searchResults = workoutService.searchExercises(query: "")
        
        // Then
        XCTAssertEqual(searchResults.count, 1)
        XCTAssertEqual(searchResults, workoutService.allExercises)
    }
    
    // MARK: - Stats Tests
    
    func testGetWorkoutStats() {
        // Given
        let exercise1 = Exercise(
            name: "Push-ups",
            duration: "10 min",
            difficulty: "Beginner",
            videoURL: nil,
            muscleGroups: ["Chest"],
            equipment: ["bodyweight"]
        )
        let exercise2 = Exercise(
            name: "Pull-ups",
            duration: "10 min",
            difficulty: "Intermediate",
            videoURL: nil,
            muscleGroups: ["Back"],
            equipment: ["bodyweight"]
        )
        
        workoutService.allExercises = [exercise1, exercise2]
        workoutService.muscleGroups = [
            MuscleGroup(name: "Chest", exercises: [], position: CGPoint(x: 0.5, y: 0.5), isLeftSide: true),
            MuscleGroup(name: "Back", exercises: [], position: CGPoint(x: 0.3, y: 0.3), isLeftSide: false)
        ]
        
        // When
        let stats = workoutService.getWorkoutStats()
        
        // Then
        XCTAssertEqual(stats.totalExercises, 2)
        XCTAssertEqual(stats.totalMuscleGroups, 2)
        XCTAssertEqual(stats.selectedMuscle, "None")
        XCTAssertEqual(stats.workoutMode, "At Home")
    }
    
    // MARK: - Published Properties Tests
    
    func testPublishedPropertiesUpdate() {
        // Given
        let expectation = XCTestExpectation(description: "Published properties should update")
        
        // When
        workoutService.$selectedMuscle
            .dropFirst()
            .sink { muscle in
                XCTAssertNotNil(muscle)
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        let testMuscle = MuscleGroup(name: "Test", exercises: [], position: CGPoint(x: 0.5, y: 0.5), isLeftSide: false)
        workoutService.selectMuscle(testMuscle)
        
        // Then
        wait(for: [expectation], timeout: 1.0)
    }
} 