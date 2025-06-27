import SwiftUI

// MARK: - Enhanced ViewModel
class AllergySelectionViewModel: ObservableObject {
    @Published var selectedAllergens: Set<String> = []
    
    let categorizedAllergies: [String: [String]] = [
        "🥛 Productos Lácteos": ["Leche", "Queso", "Yogurt", "Mantequilla"],
        "🥜 Frutos Secos": ["Maní", "Nueces", "Almendras", "Avellanas", "Coco"],
        "🌾 Cereales y Granos": ["Trigo", "Gluten", "Avena", "Maíz", "Soja"],
        "🥚 Proteínas": ["Huevo", "Pescado", "Mariscos"],
        "🥕 Vegetales": ["Apio", "Cebolla", "Ajo", "Tomate", "Zanahoria"],
        "🍓 Frutas": ["Fresas", "Cítricos"],
        "🫘 Legumbres": ["Lentejas", "Garbanzos", "Frijoles"],
        "🌱 Semillas": ["Sésamo", "Chía"],
        "🌶️ Especias": ["Mostaza", "Cilantro", "Pimienta", "Canela"],
        "🍫 Otros": ["Chocolate"]
    ]
    
    var totalAllergies: Int {
        categorizedAllergies.values.flatMap { $0 }.count
    }
    
    var selectionPercentage: Int {
        guard totalAllergies > 0 else { return 0 }
        return Int((Double(selectedAllergens.count) / Double(totalAllergies)) * 100)
    }
    
    func getCategoryIcon(_ category: String) -> String {
        switch category {
        case let cat where cat.contains("Lácteos"): return "drop.circle.fill"
        case let cat where cat.contains("Frutos"): return "leaf.circle.fill"
        case let cat where cat.contains("Cereales"): return "grain.fill"
        case let cat where cat.contains("Proteínas"): return "fish.circle.fill"
        case let cat where cat.contains("Vegetales"): return "carrot.fill"
        case let cat where cat.contains("Frutas"): return "heart.circle.fill"
        case let cat where cat.contains("Legumbres"): return "seedling.fill"
        case let cat where cat.contains("Semillas"): return "circle.hexagongrid.fill"
        case let cat where cat.contains("Especias"): return "flame.circle.fill"
        default: return "square.grid.2x2.fill"
        }
    }
    
    func toggleAllergen(_ allergen: String) {
        if selectedAllergens.contains(allergen) {
            selectedAllergens.remove(allergen)
        } else {
            selectedAllergens.insert(allergen)
        }
        
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
    }
    
    func clearAllSelection() {
        selectedAllergens.removeAll()
        
        let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
        impactFeedback.impactOccurred()
    }
    
    func getSelectedAllergens() -> [String] {
        Array(selectedAllergens).sorted()
    }
}
