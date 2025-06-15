import Foundation
import SwiftUI

class DashboardViewModel: ObservableObject {
    
    enum Tab: Int, CaseIterable {
        case workout = 0
        case diet
        case trainer
        case daily
        case me
        
        var title: String {
            switch self {
            case .workout: return "Workout"
            case .diet: return "Diet"
            case .trainer: return "Trainer"
            case .daily: return "Daily"
            case .me: return "Me"
            }
        }
        
        var icon: String {
            switch self {
            case .workout: return "figure.walk"
            case .diet: return "leaf"
            case .trainer: return "person.2"
            case .daily: return "calendar"
            case .me: return "person.crop.circle"
            }
        }
    }
    
    @Published var selectedTab: Tab = .workout
    
    func selectTab(_ tab: Tab) {
        selectedTab = tab
    }
}

