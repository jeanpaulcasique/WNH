import SwiftUI

enum OrderSection: String, CaseIterable {
    case myOrders = "My Orders"
    case buyAgain = "Buy Again" 
    case returns = "Returns"
    case trackOrder = "Track Order"
    
    var icon: String {
        switch self {
        case .myOrders: return "bag.fill"
        case .buyAgain: return "arrow.clockwise"
        case .returns: return "arrow.uturn.backward"
        case .trackOrder: return "location"
        }
    }
    
    var displayName: String {
        return self.rawValue
    }
}

