import Foundation

// MARK: - PremiumFeature Model
struct PremiumFeature {
    let title: String
    let description: String
    let icon: String
}

// MARK: - Extensions
extension PremiumFeature: Identifiable {
    var id: String { title }
}

extension PremiumFeature: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(title)
        hasher.combine(description)
        hasher.combine(icon)
    }
}
