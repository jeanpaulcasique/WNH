import SwiftUI

// MARK: - HeightViewModel
class HeightViewModel: ObservableObject {
    @Published var selectedHeightCm: Int = 175
    @Published var selectedHeightFt: Int = 5
    @Published var selectedHeightInch: Int = 9
    @Published var isCmSelected: Bool = true
    @Published var isLoading: Bool = false
    @Published var isButtonDisabled: Bool = false


    // MARK: - Unit Toggle
    func toggleUnit(toCm: Bool) {
        isCmSelected = toCm
        saveHeightToUserDefaults()
    }

    // MARK: - Update Height (cm)
    func updateHeightInCm(_ value: Double) {
        if value >= 100 && value <= 230 {
            selectedHeightCm = Int(value)
            saveHeightToUserDefaults()
        }
    }

    // MARK: - Increment / Decrement for Feet & Inches
    func incrementFeetAndInches() {
        if selectedHeightInch < 11 {
            selectedHeightInch += 1
        } else if selectedHeightFt < 8 {
            selectedHeightInch = 0
            selectedHeightFt += 1
        }
        saveHeightToUserDefaults()
    }

    func decrementFeetAndInches() {
        if selectedHeightInch > 0 {
            selectedHeightInch -= 1
        } else if selectedHeightFt > 3 {
            selectedHeightInch = 11
            selectedHeightFt -= 1
        }
        saveHeightToUserDefaults()
    }

    // MARK: - Height Conversion Helper
    func heightInCm() -> Int {
        let totalInches = (selectedHeightFt * 12) + selectedHeightInch
        let cmHeight = Double(totalInches) * 2.54
        return Int(cmHeight)
    }

    // MARK: - UserDefaults Storage
    func saveHeightToUserDefaults() {
        if isCmSelected {
            UserDefaults.standard.set(selectedHeightCm, forKey: "selectedHeightCm")
        } else {
            UserDefaults.standard.set(selectedHeightFt, forKey: "selectedHeightFt")
            UserDefaults.standard.set(selectedHeightInch, forKey: "selectedHeightInch")
        }
    }

    func loadHeightFromUserDefaults() {
        if let storedHeightCm = UserDefaults.standard.value(forKey: "selectedHeightCm") as? Int, storedHeightCm >= 100, storedHeightCm <= 230 {
            selectedHeightCm = storedHeightCm
            isCmSelected = true
        } else if let storedHeightFt = UserDefaults.standard.value(forKey: "selectedHeightFt") as? Int,
                  let storedHeightInch = UserDefaults.standard.value(forKey: "selectedHeightInch") as? Int,
                  storedHeightFt >= 3, storedHeightFt <= 8, storedHeightInch >= 0, storedHeightInch <= 11 {
            selectedHeightFt = storedHeightFt
            selectedHeightInch = storedHeightInch
            isCmSelected = false
        }
    }
}
// MARK: - HeightViewModel Extensions
extension HeightViewModel {
    func getCurrentHeightString() -> String {
        if isCmSelected {
            return "\(selectedHeightCm) cm"
        } else {
            return "\(selectedHeightFt)'\(selectedHeightInch)\""
        }
    }
    
    func getAlternativeHeightString() -> String {
        if isCmSelected {
            let totalInches = Double(selectedHeightCm) / 2.54
            let feet = Int(totalInches) / 12
            let inches = Int(totalInches) % 12
            return "\(feet)'\(inches)\""
        } else {
            let totalInches = (selectedHeightFt * 12) + selectedHeightInch
            let cm = Int(Double(totalInches) * 2.54)
            return "\(cm) cm"
        }
    }
}
