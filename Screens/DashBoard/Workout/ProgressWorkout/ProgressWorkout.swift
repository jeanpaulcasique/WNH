import SwiftUI

enum ProgressState: String, Codable {
    case none
    case partial
    case complete
}

struct DayProgress: Identifiable, Codable {
    let id = UUID()
    let date: Date
    var progress: ProgressState
}

class ProgressWorkoutViewModel: ObservableObject {
    @Published var days: [DayProgress] = []
    
    private let userDefaultsKey = "DaysProgressKey"
    private let calendar = Calendar.current
    
    init() {
        loadProgress()
    }
    
    func loadProgress() {
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey),
           let savedDays = try? JSONDecoder().decode([DayProgress].self, from: data) {
            self.days = updateDays(savedDays: savedDays)
        } else {
            self.days = createLast7Days()
            saveProgress()
        }
    }
    
    func createLast7Days() -> [DayProgress] {
        let today = Date()
        return (0..<7).map { offset in
            let date = calendar.date(byAdding: .day, value: -offset, to: today)!
            return DayProgress(date: date, progress: .none)
        }.reversed()
    }
    
    func updateDays(savedDays: [DayProgress]) -> [DayProgress] {
        let today = Date()
        var updatedDays = [DayProgress]()
        
        for offset in (0..<7).reversed() {
            let date = calendar.startOfDay(for: calendar.date(byAdding: .day, value: -offset, to: today)!)
            
            if let existing = savedDays.first(where: { calendar.isDate($0.date, inSameDayAs: date) }) {
                updatedDays.append(existing)
            } else {
                updatedDays.append(DayProgress(date: date, progress: .none))
            }
        }
        return updatedDays
    }
    
    func saveProgress() {
        if let encoded = try? JSONEncoder().encode(days) {
            UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
        }
    }
    
    func toggleProgress(for day: DayProgress) {
        guard let index = days.firstIndex(where: { $0.id == day.id }) else { return }
        
        days[index].progress = nextProgress(after: days[index].progress)
        saveProgress()
    }
    
    private func nextProgress(after current: ProgressState) -> ProgressState {
        switch current {
        case .none: return .partial
        case .partial: return .complete
        case .complete: return .none
        }
    }
}

struct ProgressCircle: View {
    var progress: ProgressState
    
    var body: some View {
        let borderColor: Color = {
            switch progress {
            case .none: return .red
            case .partial: return .orange
            case .complete: return .green
            }
        }()
        
        Circle()
            .strokeBorder(borderColor, lineWidth: 4)
            .background(
                Circle()
                    .fill(progress == .none ? Color.clear : borderColor.opacity(0.3))
            )
            .frame(width: 40, height: 40)
    }
}
