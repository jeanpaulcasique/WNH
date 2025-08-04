// GenderSelectionViewModel.swift
import SwiftUI

class GenderSelectionViewModel: ObservableObject {
    @Published var selectedGender: Gender?
    @Published var isButtonDisabled = false
    @Published var isLoading = false
    @Published var navigateToGoal = false
    @Published var progressUpdating = false
 

    private let userDefaultsKey = "gender"

    init() {
        // No cargar género automáticamente para evitar preselección
        // loadGenderFromUserDefaults()
    }

    func selectGender(_ gender: Gender) {
        selectedGender = gender
    }

    func onNextTapped() {
        guard selectedGender != nil && !isButtonDisabled && !isLoading else { return }

        isButtonDisabled = true
        isLoading = true
        progressUpdating = true

        HapticManager.shared.impact(style: .medium)

        // Guardar género seleccionado solo al avanzar
        if let gender = selectedGender {
            UserDefaults.standard.set(gender.rawValue, forKey: self.userDefaultsKey)
        }

        // Navegación instantánea
        self.isLoading = false
        self.isButtonDisabled = false
        self.progressUpdating = false
        self.navigateToGoal = true
    }

    private func loadGenderFromUserDefaults() {
        if let savedGender = UserDefaults.standard.string(forKey: userDefaultsKey),
           let gender = Gender(rawValue: savedGender) {
            selectedGender = gender
        }
    }
}


