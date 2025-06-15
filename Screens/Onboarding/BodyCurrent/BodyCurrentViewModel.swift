import SwiftUI

class BodyCurrentViewModel: ObservableObject {
    @Published var selectedBodyShape: BodyShape?

    enum BodyShape: String, CaseIterable, Identifiable {
        case medium = "mediumMen"
        case flabby = "flabbyMen"
        case skinny = "skinnyMen"
        case muscular = "muscularMen"
        
        var id: String { self.rawValue }
    }

    func selectBodyShape(_ shape: BodyShape) {
        selectedBodyShape = (selectedBodyShape == shape) ? nil : shape
        saveBodyShapeToUserDefaults()
    }

    private func saveBodyShapeToUserDefaults() {
        if let selectedShape = selectedBodyShape {
            UserDefaults.standard.set(selectedShape.rawValue, forKey: "bodyCurrentImage")
        } else {
            UserDefaults.standard.removeObject(forKey: "bodyCurrentImage")
        }
    }

    func loadBodyShapeFromUserDefaults() {
        if let savedShape = UserDefaults.standard.string(forKey: "bodyCurrentImage"),
           let shape = BodyShape(rawValue: savedShape) {
            selectedBodyShape = shape
        }
    }

    init() {
        loadBodyShapeFromUserDefaults()
    }
}

