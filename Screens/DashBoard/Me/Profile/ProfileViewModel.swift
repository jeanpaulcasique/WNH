import SwiftUI
import UIKit

// MARK: - Enhanced Models
struct ProfileItem: Identifiable, Equatable {
    let id = UUID()
    let text: String
    let value: String
    let icon: String
    let iconColor: Color
    let category: ProfileCategory
    
    init(text: String, value: String, icon: String, iconColor: Color = .appYellow, category: ProfileCategory = .personal) {
        self.text = text
        self.value = value
        self.icon = icon
        self.iconColor = iconColor
        self.category = category
    }
}

enum ProfileCategory {
    case personal, fitness, preferences
}

struct ProfileAchievement: Identifiable {
    let id = UUID()
    let title: String
    let icon: String
    let color: Color
    let date: Date
    let description: String
}

// MARK: - Enhanced ProfileViewModel
class ProfileViewModel: ObservableObject {
    @Published var infoItems: [ProfileItem] = []
    @Published var profileImage: UIImage?
    @Published var showPhotoOptions = false
    @Published var showImagePicker = false
    @Published var sourceType: UIImagePickerController.SourceType = .photoLibrary
    @Published var recentAchievements: [ProfileAchievement] = []
    
    // User stats
    @Published var totalWorkouts: Int = 0
    @Published var currentStreak: Int = 0
    @Published var achievedGoals: Int = 0
    @Published var userName: String = "Fitness Enthusiast"
    @Published var userLevel: String = "Beginner"
    @Published var memberSince: String = "Jan 2024"
    
    // UserDefaults keys
    private let profileImageKey = "profile_image_data"
    private let userStatsKey = "user_stats"
    
    init() {
        loadData()
        loadProfileImage()
        loadUserStats()
        generateAchievements()
    }
    
    // MARK: - Data Loading
    func loadData() {
        let defaults = UserDefaults.standard
        
        // Load all user data
        let gender = defaults.string(forKey: "gender") ?? "Not Set"
        
        let height: String
        if let storedHeightCm = defaults.value(forKey: "selectedHeightCm") as? Int {
            height = "\(storedHeightCm) cm"
        } else if let storedHeightFt = defaults.value(forKey: "selectedHeightFt") as? Int,
                  let storedHeightInch = defaults.value(forKey: "selectedHeightInch") as? Int {
            height = "\(storedHeightFt) ft \(storedHeightInch) in"
        } else {
            height = "Not Set"
        }
        
        let weight = defaults.value(forKey: "selectedWeightKg") as? Double ?? 0.0
        let targetWeight = defaults.value(forKey: "selectedTargetWeight") as? Double ?? 0.0
        let goal = defaults.string(forKey: "selectedGoal") ?? "Not Set"
        let target = defaults.string(forKey: "selectedTarget") ?? "Not Set"
        let equipmentPreference = defaults.string(forKey: "equipmentPreference") ?? "Not Set"
        let bodyCurrent = defaults.string(forKey: "bodyCurrentImage") ?? "Not Set"
        let desiredBody = defaults.string(forKey: "desiredBodyImage") ?? "Not Set"
        let birthYear = defaults.string(forKey: "selectedBirthYear") ?? "Not Set"
        let workoutLevel = defaults.string(forKey: "selectedWorkoutLevel") ?? "Not Set"
        let levelActivity = defaults.string(forKey: "selectedLevelActivity") ?? "Not Set"
        let howOften = defaults.string(forKey: "selectedHowOften") ?? "Not Set"
        
        // Update user level based on workout level
        userLevel = workoutLevel != "Not Set" ? workoutLevel : "Beginner"
        
        // Create organized profile items
        infoItems = [
            // Personal Information
            ProfileItem(text: "Gender", value: gender, icon: "person.fill", iconColor: .blue, category: .personal),
            ProfileItem(text: "Birth Year", value: birthYear, icon: "calendar", iconColor: .green, category: .personal),
            ProfileItem(text: "Height", value: height, icon: "ruler", iconColor: .purple, category: .personal),
            ProfileItem(text: "Current Weight", value: String(format: "%.1f kg", weight), icon: "scalemass", iconColor: .orange, category: .personal),
            
            // Fitness Goals
            ProfileItem(text: "Target Weight", value: String(format: "%.1f kg", targetWeight), icon: "target", iconColor: .red, category: .fitness),
            ProfileItem(text: "Primary Goal", value: goal, icon: "flag.fill", iconColor: .appYellow, category: .fitness),
            ProfileItem(text: "Target Area", value: target, icon: "scope", iconColor: .cyan, category: .fitness),
            ProfileItem(text: "Workout Level", value: workoutLevel, icon: "figure.strengthtraining.traditional", iconColor: .red, category: .fitness),
            ProfileItem(text: "Activity Level", value: levelActivity, icon: "heart.fill", iconColor: .pink, category: .fitness),
            
            // Preferences
            ProfileItem(text: "Workout Frequency", value: howOften, icon: "clock.fill", iconColor: .blue, category: .preferences),
            ProfileItem(text: "Equipment Preference", value: equipmentPreference, icon: "dumbbell.fill", iconColor: .gray, category: .preferences),
            ProfileItem(text: "Current Body Type", value: bodyCurrent, icon: "figure.walk", iconColor: .green, category: .preferences),
            ProfileItem(text: "Desired Body Type", value: desiredBody, icon: "figure.run", iconColor: .blue, category: .preferences)
        ]
    }
    
    func loadProfileImage() {
        if let imageData = UserDefaults.standard.data(forKey: profileImageKey),
           let image = UIImage(data: imageData) {
            profileImage = image
        }
    }
    
    func loadUserStats() {
        let defaults = UserDefaults.standard
        
        // Load or generate stats
        totalWorkouts = defaults.integer(forKey: "total_workouts")
        currentStreak = defaults.integer(forKey: "current_streak")
        achievedGoals = defaults.integer(forKey: "achieved_goals")
        
        // Generate some stats if first time
        if totalWorkouts == 0 {
            totalWorkouts = Int.random(in: 5...25)
            currentStreak = Int.random(in: 1...14)
            achievedGoals = Int.random(in: 1...8)
            saveUserStats()
        }
        
        // Update member since date
        if let firstLaunchDate = defaults.object(forKey: "first_launch_date") as? Date {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM yyyy"
            memberSince = formatter.string(from: firstLaunchDate)
        } else {
            defaults.set(Date(), forKey: "first_launch_date")
        }
        
        // Generate user name from data
        generateUserName()
    }
    
    private func generateUserName() {
        let goal = UserDefaults.standard.string(forKey: "selectedGoal") ?? ""
        
        switch goal {
        case let str where str.contains("Weight"):
            userName = "Weight Loss Warrior"
        case let str where str.contains("Muscle"):
            userName = "Muscle Builder"
        case let str where str.contains("Strength"):
            userName = "Strength Seeker"
        case let str where str.contains("Endurance"):
            userName = "Endurance Expert"
        default:
            userName = "Fitness Enthusiast"
        }
    }
    
    private func generateAchievements() {
        // Generate some recent achievements based on user stats
        var achievements: [ProfileAchievement] = []
        
        if totalWorkouts >= 5 {
            achievements.append(ProfileAchievement(
                title: "First Week",
                icon: "flame.fill",
                color: .orange,
                date: Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date(),
                description: "Completed 5 workouts"
            ))
        }
        
        if currentStreak >= 7 {
            achievements.append(ProfileAchievement(
                title: "Week Warrior",
                icon: "calendar",
                color: .green,
                date: Calendar.current.date(byAdding: .day, value: -3, to: Date()) ?? Date(),
                description: "7-day workout streak"
            ))
        }
        
        if achievedGoals >= 3 {
            achievements.append(ProfileAchievement(
                title: "Goal Getter",
                icon: "target",
                color: .blue,
                date: Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date(),
                description: "Achieved 3 fitness goals"
            ))
        }
        
        recentAchievements = achievements
    }
    
    // MARK: - Data Organization
    func getPersonalInfoItems() -> [ProfileItem] {
        return infoItems.filter { $0.category == .personal }
    }
    
    func getFitnessGoalItems() -> [ProfileItem] {
        return infoItems.filter { $0.category == .fitness }
    }
    
    func getPreferenceItems() -> [ProfileItem] {
        return infoItems.filter { $0.category == .preferences }
    }
    
    // MARK: - Update Methods
    func updateItem(_ item: ProfileItem, newValue: String) {
        if let index = infoItems.firstIndex(where: { $0.id == item.id }) {
            let updatedItem = ProfileItem(
                text: item.text,
                value: newValue,
                icon: item.icon,
                iconColor: item.iconColor,
                category: item.category
            )
            infoItems[index] = updatedItem
            
            // Save to UserDefaults based on item type
            saveItemToUserDefaults(item: updatedItem)
        }
    }
    
    private func saveItemToUserDefaults(item: ProfileItem) {
        let defaults = UserDefaults.standard
        
        switch item.text {
        case "Gender":
            defaults.set(item.value, forKey: "gender")
        case "Birth Year":
            defaults.set(item.value, forKey: "selectedBirthYear")
        case "Height":
            // Parse and save height appropriately
            if item.value.contains("cm") {
                let heightStr = item.value.replacingOccurrences(of: " cm", with: "")
                if let height = Int(heightStr) {
                    defaults.set(height, forKey: "selectedHeightCm")
                }
            }
        case "Current Weight":
            let weightStr = item.value.replacingOccurrences(of: " kg", with: "")
            if let weight = Double(weightStr) {
                defaults.set(weight, forKey: "selectedWeightKg")
            }
        case "Target Weight":
            let weightStr = item.value.replacingOccurrences(of: " kg", with: "")
            if let weight = Double(weightStr) {
                defaults.set(weight, forKey: "selectedTargetWeight")
            }
        case "Primary Goal":
            defaults.set(item.value, forKey: "selectedGoal")
            generateUserName() // Update user name based on new goal
        case "Target Area":
            defaults.set(item.value, forKey: "selectedTarget")
        case "Workout Level":
            defaults.set(item.value, forKey: "selectedWorkoutLevel")
            userLevel = item.value // Update display level
        case "Activity Level":
            defaults.set(item.value, forKey: "selectedLevelActivity")
        case "Workout Frequency":
            defaults.set(item.value, forKey: "selectedHowOften")
        case "Equipment Preference":
            defaults.set(item.value, forKey: "equipmentPreference")
        case "Current Body Type":
            defaults.set(item.value, forKey: "bodyCurrentImage")
        case "Desired Body Type":
            defaults.set(item.value, forKey: "desiredBodyImage")
        default:
            break
        }
    }
    
    // MARK: - Profile Image Methods
    func saveProfileImage() {
        guard let image = profileImage,
              let imageData = image.jpegData(compressionQuality: 0.8) else { return }
        
        UserDefaults.standard.set(imageData, forKey: profileImageKey)
    }
    
    // MARK: - Stats Methods
    func incrementWorkoutCount() {
        totalWorkouts += 1
        saveUserStats()
        
        // Check for new achievements
        checkForNewAchievements()
    }
    
    func updateStreak(_ newStreak: Int) {
        currentStreak = newStreak
        saveUserStats()
    }
    
    func addAchievedGoal() {
        achievedGoals += 1
        saveUserStats()
        
        // Check for new achievements
        checkForNewAchievements()
    }
    
    private func saveUserStats() {
        let defaults = UserDefaults.standard
        defaults.set(totalWorkouts, forKey: "total_workouts")
        defaults.set(currentStreak, forKey: "current_streak")
        defaults.set(achievedGoals, forKey: "achieved_goals")
    }
    
    private func checkForNewAchievements() {
        var newAchievements: [ProfileAchievement] = []
        
        // Check for milestone achievements
        if totalWorkouts == 10 && !hasAchievement("Decathlete") {
            newAchievements.append(ProfileAchievement(
                title: "Decathlete",
                icon: "10.circle.fill",
                color: .purple,
                date: Date(),
                description: "Completed 10 workouts"
            ))
        }
        
        if totalWorkouts == 25 && !hasAchievement("Quarter Century") {
            newAchievements.append(ProfileAchievement(
                title: "Quarter Century",
                icon: "25.circle.fill",
                color: .yellow,
                date: Date(),
                description: "Completed 25 workouts"
            ))
        }
        
        if currentStreak == 30 && !hasAchievement("Month Master") {
            newAchievements.append(ProfileAchievement(
                title: "Month Master",
                icon: "calendar.badge.checkmark",
                color: .cyan,
                date: Date(),
                description: "30-day workout streak"
            ))
        }
        
        // Add new achievements
        recentAchievements.append(contentsOf: newAchievements)
        
        // Keep only recent achievements (last 5)
        recentAchievements = Array(recentAchievements.suffix(5))
    }
    
    private func hasAchievement(_ title: String) -> Bool {
        return recentAchievements.contains { $0.title == title }
    }
    
    // MARK: - Utility Methods
    func calculateBMI() -> Double {
        let weightKg = UserDefaults.standard.double(forKey: "selectedWeightKg")
        let heightCm = UserDefaults.standard.double(forKey: "selectedHeightCm")
        
        guard weightKg > 0, heightCm > 0 else { return 0.0 }
        
        let heightM = heightCm / 100.0
        return weightKg / (heightM * heightM)
    }
    
    func getProgressToGoal() -> Double {
        let currentWeight = UserDefaults.standard.double(forKey: "selectedWeightKg")
        let targetWeight = UserDefaults.standard.double(forKey: "selectedTargetWeight")
        let startingWeight = UserDefaults.standard.double(forKey: "starting_weight")
        
        guard currentWeight > 0, targetWeight > 0, startingWeight > 0 else { return 0.0 }
        
        let totalWeightToLose = abs(startingWeight - targetWeight)
        let weightLostSoFar = abs(startingWeight - currentWeight)
        
        return min(weightLostSoFar / totalWeightToLose, 1.0)
    }
    
    func getCompletionPercentage() -> Int {
        let goals = [
            !UserDefaults.standard.string(forKey: "selectedGoal")!.contains("Not Set"),
            !UserDefaults.standard.string(forKey: "gender")!.contains("Not Set"),
            UserDefaults.standard.double(forKey: "selectedWeightKg") > 0,
            !UserDefaults.standard.string(forKey: "selectedWorkoutLevel")!.contains("Not Set"),
            profileImage != nil
        ]
        
        let completedGoals = goals.filter { $0 }.count
        return Int((Double(completedGoals) / Double(goals.count)) * 100)
    }
    
    // MARK: - Reset Methods
    func resetAllData() {
        let defaults = UserDefaults.standard
        let keys = [
            "gender", "selectedHeightCm", "selectedWeightKg", "selectedGoal",
            "selectedTarget", "equipmentPreference", "bodyCurrentImage",
            "desiredBodyImage", "selectedBirthYear", "selectedWorkoutLevel",
            "selectedLevelActivity", "selectedHowOften", "selectedTargetWeight"
        ]
        
        keys.forEach { defaults.removeObject(forKey: $0) }
        
        // Reset stats
        totalWorkouts = 0
        currentStreak = 0
        achievedGoals = 0
        recentAchievements = []
        
        // Clear profile image
        profileImage = nil
        defaults.removeObject(forKey: profileImageKey)
        
        // Reload data
        loadData()
    }
}

// MARK: - Extensions
extension ProfileViewModel {
    
    // Helper for UI binding
    var profileImageBinding: Binding<UIImage?> {
        Binding(
            get: { self.profileImage },
            set: { newImage in
                self.profileImage = newImage
                if newImage != nil {
                    self.saveProfileImage()
                }
            }
        )
    }
}

// MARK: - Color Extension
extension Color {
    static let lightGold = Color(red: 1.0, green: 0.84, blue: 0.0)
    static let lightMint = Color(red: 0.0, green: 1.0, blue: 0.8)
    static let lightTeal = Color(red: 0.0, green: 0.5, blue: 0.5)
}
