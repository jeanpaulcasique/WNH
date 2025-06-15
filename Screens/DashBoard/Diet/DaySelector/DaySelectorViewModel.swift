import SwiftUI
import Combine

class DaySelectorViewModel: ObservableObject {
    @Published var days: [Date] = []
    @Published var selectedDay: Date = Date()
    
    private let calendar = Calendar(identifier: .gregorian)
    
    init() {
        setupDays()
    }
    
    func select(day: Date) {
        selectedDay = day
    }
    
    func dayNumber(from date: Date) -> String {
        let components = calendar.dateComponents([.day], from: date)
        return "\(components.day ?? 0)"
    }
    
    private func setupDays() {
        let today = calendar.startOfDay(for: Date())
        let weekday = calendar.component(.weekday, from: today)
        let offset = (weekday == 1 ? -6 : 2 - weekday)
        guard let start = calendar.date(byAdding: .day, value: offset, to: today) else { return }
        days = (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: start) }
        selectedDay = days.first ?? today
    }
} 