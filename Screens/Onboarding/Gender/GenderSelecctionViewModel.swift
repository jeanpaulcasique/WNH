// GenderSelectionViewModel.swift
import SwiftUI

class GenderSelectionViewModel: ObservableObject {
    @Published var selectedGender: Gender? {
        didSet { saveGenderToUserDefaults() }
    }
    @Published var isButtonDisabled = false
    @Published var isLoading = false
    @Published var navigateToGoal = false
    @Published var progressUpdating = false
    @Published var showInfo = false

    private let userDefaultsKey = "gender"

    init() {
        loadGenderFromUserDefaults()
    }

    func selectGender(_ gender: Gender) {
        selectedGender = gender
        HapticManager.generateImpact()
    }

    func onNextTapped(progressViewModel: ProgressViewModel) {
        guard selectedGender != nil && !isButtonDisabled else { return }

        isButtonDisabled = true
        isLoading = true
        progressUpdating = true

        HapticManager.generateImpact()
        progressViewModel.advanceProgress()

        self.navigateToGoal = true
        self.progressUpdating = false

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.isButtonDisabled = false
            self.isLoading = false
        }
    }

    private func saveGenderToUserDefaults() {
        if let gender = selectedGender {
            UserDefaults.standard.set(gender.rawValue, forKey: userDefaultsKey)
        }
    }

    private func loadGenderFromUserDefaults() {
        if let savedGender = UserDefaults.standard.string(forKey: userDefaultsKey),
           let gender = Gender(rawValue: savedGender) {
            selectedGender = gender
        }
    }
}

// Gender enum
enum Gender: String, CaseIterable {
    case male, female
}

// Haptic Manager
enum HapticManager {
    static func generateImpact() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
}
