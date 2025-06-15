import Foundation
import SwiftUI

enum Goal: String, CaseIterable {
    case loseWeight = "Lose Weight"
    case buildMuscle = "Build Muscle"
    case keepFit = "Keep Fit"
}

class GoalViewModel: ObservableObject {
    @Published var selectedGoal: Goal? {
        didSet {
            if let goal = selectedGoal {
                UserDefaults.standard.set(goal.rawValue, forKey: "selectedGoal")
            }
        }
    }

    @Published var gender: Gender = .male {
        didSet {
            UserDefaults.standard.set(gender.rawValue, forKey: "gender")
        }
    }

    init() {
        loadGoalFromUserDefaults()
        loadGenderFromUserDefaults()
    }

    func selectGoal(_ goal: Goal) {
        selectedGoal = goal
    }

    func loadGoalFromUserDefaults() {
        if let saved = UserDefaults.standard.string(forKey: "selectedGoal"),
           let goal = Goal(rawValue: saved) {
            selectedGoal = goal
        }
    }

    func loadGenderFromUserDefaults() {
        if let saved = UserDefaults.standard.string(forKey: "gender"),
           let gender = Gender(rawValue: saved.lowercased()) {
            self.gender = gender
        }
    }

    func imageName(for goal: Goal) -> String {
        switch gender {
        case .male:
            switch goal {
            case .loseWeight: return "lossMen"
            case .buildMuscle: return "buildMen"
            case .keepFit: return "keepMen"
            }
        case .female:
            switch goal {
            case .loseWeight: return "lossWomen"
            case .buildMuscle: return "buildWomen"
            case .keepFit: return "keepWomen"
            }
        }
    }
}

