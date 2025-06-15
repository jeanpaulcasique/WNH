import Foundation
import UserNotifications
//comment

final class NotificationWater {
    static let shared = NotificationWater()
    private let center = UNUserNotificationCenter.current()

    private init() {}

    /// Pide permiso al usuario (llámalo al iniciar la app)
    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        center.requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
            completion(granted)
        }
    }

    /**
     Programa 3 recordatorios al día, en las horas indicadas.
     - parameter times: array de DateComponents con la hora (h,m) de cada notificación.
     - parameter dailyRecommendation: cadena con la meta diaria (p.ej. "2L").
     */
    func scheduleThreeDailyReminders(
        at times: [DateComponents],
        dailyRecommendation: String
    ) {
        // Borra cualquier notificación previa
        center.removePendingNotificationRequests(withIdentifiers: ["waterReminder1", "waterReminder2", "waterReminder3"])
        
        for (index, time) in times.enumerated() {
            let content = UNMutableNotificationContent()
            content.title = "Hora de hidratarte"
            content.body = "Tu meta diaria es \(dailyRecommendation). Bebe un poco de agua ahora."
            content.sound = .default

            let trigger = UNCalendarNotificationTrigger(dateMatching: time, repeats: true)
            let id = "waterReminder\(index+1)"
            let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)

            center.add(request) { error in
                if let error = error {
                    print("Error scheduling water reminder \(id): \(error)")
                }
            }
        }
    }

    /// Cancela estos 3 recordatorios
    func cancelThreeDailyReminders() {
        center.removePendingNotificationRequests(withIdentifiers: ["waterReminder1", "waterReminder2", "waterReminder3"])
    }
}

