import Foundation
import UserNotifications

final class NotificationWater {
    static let shared = NotificationWater()
    private let center = UNUserNotificationCenter.current()
    private var hasScheduledNotifications = false

    private init() {}

    /// Pide permiso al usuario (llámalo al iniciar la app)
    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        // Configurar categorías de notificación
        setupNotificationCategories()
        
        center.requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
            completion(granted)
        }
    }
    
    /// Configura las categorías de notificación
    private func setupNotificationCategories() {
        let waterReminderCategory = UNNotificationCategory(
            identifier: "WATER_REMINDER",
            actions: [],
            intentIdentifiers: [],
            options: [.customDismissAction]
        )
        
        center.setNotificationCategories([waterReminderCategory])
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
        // Evitar programar notificaciones duplicadas
        guard !hasScheduledNotifications else {
            print("🚫 Notificaciones de agua ya programadas, evitando duplicados")
            return
        }
        
        // Borra cualquier notificación previa
        center.removePendingNotificationRequests(withIdentifiers: ["waterReminder1", "waterReminder2", "waterReminder3"])
        
        for (index, time) in times.enumerated() {
            let content = UNMutableNotificationContent()
            content.title = "Hora de hidratarte"
            content.body = "Tu meta diaria es \(dailyRecommendation). Bebe un poco de agua ahora."
            content.sound = .default
            content.userInfo = ["screen": "diet", "type": "water_reminder"]
            content.categoryIdentifier = "WATER_REMINDER"
            
            // Agregar el logo de la app
            if let appIcon = Bundle.main.icon {
                content.attachments = [try! UNNotificationAttachment(identifier: "appIcon", url: appIcon, options: nil)]
            }

            let trigger = UNCalendarNotificationTrigger(dateMatching: time, repeats: true)
            let id = "waterReminder\(index+1)"
            let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)

            center.add(request) { error in
                if let error = error {
                    print("Error scheduling water reminder \(id): \(error)")
                } else {
                    print("✅ Notificación de agua programada: \(id)")
                }
            }
        }
        
        // Marcar como programadas
        hasScheduledNotifications = true
        print("✅ Todas las notificaciones de agua programadas exitosamente")
    }

    /// Cancela estos 3 recordatorios
    func cancelThreeDailyReminders() {
        center.removePendingNotificationRequests(withIdentifiers: ["waterReminder1", "waterReminder2", "waterReminder3"])
        hasScheduledNotifications = false
        print("🗑️ Notificaciones de agua canceladas")
    }
    
    /// Limpia todas las notificaciones de agua existentes (útil para debugging)
    func cleanupAllWaterNotifications() {
        center.removeAllPendingNotificationRequests()
        center.removeAllDeliveredNotifications()
        hasScheduledNotifications = false
        print("🧹 Todas las notificaciones de agua limpiadas")
    }
    
    /// Verifica el estado actual de las notificaciones
    func checkNotificationStatus() {
        center.getPendingNotificationRequests { requests in
            let waterRequests = requests.filter { $0.identifier.contains("waterReminder") }
            print("📱 Notificaciones de agua pendientes: \(waterRequests.count)")
            for request in waterRequests {
                print("   - \(request.identifier): \(request.content.title)")
            }
        }
    }
    
    /// Método para limpiar y reprogramar notificaciones (útil para testing)
    func resetAndRescheduleNotifications(dailyRecommendation: String) {
        print("🔄 Reseteando y reprogramando notificaciones de agua")
        hasScheduledNotifications = false
        cleanupAllWaterNotifications()
        
        // Reprogramar después de un breve delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.scheduleThreeDailyReminders(
                at: [
                    DateComponents(hour: 9, minute: 0),
                    DateComponents(hour: 13, minute: 0),
                    DateComponents(hour: 19, minute: 0)
                ],
                dailyRecommendation: dailyRecommendation
            )
        }
    }
}

// MARK: - Bundle Extension for App Icon
extension Bundle {
    var icon: URL? {
        if let icons = infoDictionary?["CFBundleIcons"] as? [String: Any],
           let primaryIcon = icons["CFBundlePrimaryIcon"] as? [String: Any],
           let iconFiles = primaryIcon["CFBundleIconFiles"] as? [String],
           let iconFileName = iconFiles.first {
            return Bundle.main.url(forResource: iconFileName, withExtension: "png")
        }
        return nil
    }
}

