
import SwiftUI
import Combine

// MARK: - BirthYearViewModel
class BirthYearViewModel: ObservableObject {
    @Published var selectedYear: Int {
        didSet {
            // Guardamos el valor en UserDefaults cada vez que cambia
            UserDefaults.standard.set(selectedYear, forKey: "selectedBirthYear")
        }
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    var birthYearRange: [Int] {
        let currentYear = Calendar.current.component(.year, from: Date())
        return Array(1900...currentYear)
    }
    
    var canProceed: Bool {
        validateYear(selectedYear)
    }
    
    init() {
        // Cargamos el valor guardado previamente desde UserDefaults
        if let savedYear = UserDefaults.standard.value(forKey: "selectedBirthYear") as? Int {
            self.selectedYear = savedYear
        } else {
            self.selectedYear = Calendar.current.component(.year, from: Date()) // Valor por defecto
        }
        
        // Observamos cualquier cambio en el año seleccionado y lo guardamos
        $selectedYear
            .sink { [weak self] _ in _ = self?.canProceed }
            .store(in: &cancellables)
    }
    
    private func validateYear(_ year: Int) -> Bool {
        let currentYear = Calendar.current.component(.year, from: Date())
        return year >= 1900 && year <= currentYear
    }
    
    func selectYear(_ year: Int) {
        selectedYear = year
    }
}

// MARK: - BirthYearViewModel Extension
extension BirthYearViewModel {
    var calculatedAge: Int {
        let currentYear = Calendar.current.component(.year, from: Date())
        return max(0, currentYear - selectedYear)
    }
    
    var fitnessCategory: String {
        let age = calculatedAge
        switch age {
        case 0..<18:
            return "Youth"
        case 18..<30:
            return "Peak"
        case 30..<45:
            return "Prime"
        case 45..<60:
            return "Mature"
        default:
            return "Wise"
        }
    }
}
