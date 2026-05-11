import XCTest
@testable import WNH

final class WeightContinuityTests: XCTestCase {
    func testTodayWithoutRecord_usesYesterdayWeight() {
        let service = DailyProgressService()
        let calendar = Calendar.current
        let today = Date()
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!

        // Guardar histórico en ayer
        // Acceso a método privado no permitido; simulamos vía API pública: updateWeightForToday en ayer no existe
        // En su lugar, persistimos día de ayer en UserDefaults como si fuese histórico
        let formatter = DateFormatter(); formatter.dateFormat = "yyyy-MM-dd"
        let key = "weightHistory_\(formatter.string(from: yesterday))"
        UserDefaults.standard.set(82.0, forKey: key)

        // Consultar hoy sin registro explícito
        let weightToday = service.getWeightForDate(today)
        XCTAssertEqual(weightToday, 82.0)
    }

    func testTodayWithRecord_usesTodayWeight() {
        let service = DailyProgressService()
        service.updateWeightForToday(81.5)
        let today = Date()
        let weightToday = service.getWeightForDate(today)
        XCTAssertEqual(weightToday, 81.5)
    }

    func testFutureDate_usesYesterdayWeight() {
        let service = DailyProgressService()
        let calendar = Calendar.current
        let today = Date()
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!

        // Guardar histórico en ayer
        let formatter = DateFormatter(); formatter.dateFormat = "yyyy-MM-dd"
        let key = "weightHistory_\(formatter.string(from: yesterday))"
        UserDefaults.standard.set(82.0, forKey: key)

        // Para fecha futura, debe usar ayer
        let weightTomorrow = service.getWeightForDate(tomorrow)
        XCTAssertEqual(weightTomorrow, 82.0)
    }
}



