import SwiftUI

enum OrderSection: String, CaseIterable {
    case shop = "Shop"
    case myOrders = "History"
    case buyAgain = "Buy Again" 
    case returns = "Returns"
    case trackOrder = "Track"
    
    var icon: String {
        switch self {
        case .shop: return "storefront.fill"
        case .myOrders: return "bag.fill"
        case .buyAgain: return "arrow.clockwise"
        case .returns: return "arrow.uturn.backward"
        case .trackOrder: return "location"
        }
    }
    
    var displayName: String {
        LanguageManager.localizedString(self.rawValue)
    }
}
