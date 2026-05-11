import Foundation
import UserNotifications

final class NotificationWater {
    static let shared = NotificationWater()
    private let center = UNUserNotificationCenter.current()
    
    // ✅ CORREGIDO: Usar UserDefaults para persistir el estado
    private let userDefaults = UserDefaults.standard
    private let notificationScheduledKey = "waterNotificationsScheduled"
    private let lastScheduledDateKey = "lastScheduledDate"

    private init() {
        // ✅ NUEVO: Verificar estado al inicializar
        print("🔧 Inicializando NotificationWater")
        checkAndCleanupIfNeeded()
    }
    
    // ✅ NUEVO: Verificar si las notificaciones necesitan ser limpiadas
    private func checkAndCleanupIfNeeded() {
        let lastScheduled = userDefaults.object(forKey: lastScheduledDateKey) as? Date
        let isScheduled = userDefaults.bool(forKey: notificationScheduledKey)
        
        // Si han pasado más de 24 horas desde la última programación, limpiar
        if let lastDate = lastScheduled, 
           Date().timeIntervalSince(lastDate) > 24 * 60 * 60 {
            print("🔧 Han pasado más de 24 horas, limpiando notificaciones...")
            cleanupAllWaterNotifications()
        } else if isScheduled {
            print("🔧 Notificaciones ya programadas, verificando estado...")
            verifyExistingNotifications()
        }
    }
    
    // ✅ NUEVO: Verificar que las notificaciones existentes estén correctas
    private func verifyExistingNotifications() {
        center.getPendingNotificationRequests { requests in
            let waterRequests = requests.filter { $0.identifier.contains("waterReminder") }
            
            if waterRequests.count != 3 {
                print("🔧 Notificaciones incompletas detectadas (\(waterRequests.count)/3), reprogramando...")
                DispatchQueue.main.async {
                    self.userDefaults.set(false, forKey: self.notificationScheduledKey)
                    self.forceCleanAndReset()
                }
            } else {
                print("🔧 Notificaciones verificadas correctamente (\(waterRequests.count)/3)")
            }
        }
    }

    /// Pide permiso al usuario (llámalo al iniciar la app)
    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        print("🔧 Solicitando autorización de notificaciones")
        
        // Configurar categorías de notificación
        setupNotificationCategories()
        
        center.requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
            print("🔧 Autorización de notificaciones: \(granted ? "✅ Concedida" : "❌ Denegada")")
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
        print("🔧 Categorías de notificación configuradas")
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
        print("🔧 Intentando programar notificaciones de agua...")
        
        // ✅ CORREGIDO: Verificar si ya están programadas usando UserDefaults
        if userDefaults.bool(forKey: notificationScheduledKey) {
            print("🚫 Notificaciones de agua ya programadas, evitando duplicados")
            return
        }
        
        // ✅ CORREGIDO: Limpieza agresiva antes de programar
        print("🧹 Limpiando todas las notificaciones existentes...")
        center.removeAllPendingNotificationRequests()
        center.removeAllDeliveredNotifications()
        
        // ✅ NUEVO: Esperar un momento antes de programar
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.programNotifications(at: times, dailyRecommendation: dailyRecommendation)
        }
    }
    
    // ✅ NUEVO: Método separado para programar notificaciones
    private func programNotifications(at times: [DateComponents], dailyRecommendation: String) {
        print("🔧 Programando \(times.count) notificaciones de agua...")
        
        var successCount = 0
        let totalCount = times.count
        
        for (index, time) in times.enumerated() {
            let content = UNMutableNotificationContent()
            
            // ✅ MEJORADO: Mensajes personalizados según la hora
            let (title, body) = getNotificationContent(for: index, time: time, dailyRecommendation: dailyRecommendation)
            content.title = title
            content.body = body
            
            content.sound = .default
            content.userInfo = ["screen": "diet", "type": "water_reminder", "hour": time.hour ?? 0]
            content.categoryIdentifier = "WATER_REMINDER"
            
            // ✅ CORREGIDO: Usar hora exacta para evitar conflictos
            var exactTime = time
            exactTime.second = 0
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: exactTime, repeats: true)
            let id = "waterReminder\(index+1)"
            let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)

            center.add(request) { error in
                if let error = error {
                    print("❌ Error programando notificación de agua \(id): \(error)")
                } else {
                    print("✅ Notificación de agua programada: \(id) a las \(exactTime.hour ?? 0):\(exactTime.minute ?? 0)")
                    successCount += 1
                    
                    // ✅ NUEVO: Marcar como programadas solo cuando todas estén listas
                    if successCount == totalCount {
                        DispatchQueue.main.async {
                            self.userDefaults.set(true, forKey: self.notificationScheduledKey)
                            self.userDefaults.set(Date(), forKey: self.lastScheduledDateKey)
                            print("✅ Todas las notificaciones de agua programadas exitosamente (\(successCount)/\(totalCount))")
                        }
                    }
                }
            }
        }
    }
    
    // ✅ NUEVO: Método para generar contenido personalizado de notificaciones
    private func getNotificationContent(for index: Int, time: DateComponents, dailyRecommendation: String) -> (title: String, body: String) {
        let hour = time.hour ?? 0
        let goalText = "Meta diaria: \(dailyRecommendation)"
        
        switch hour {
        case 9:
            return (
                title: "🌅 ¡Buenos días! Hora de hidratarte",
                body: "\(goalText). Empieza con un vaso de agua."
            )
        case 13:
            return (
                title: "☀️ ¡Mediodía! Mantén la hidratación",
                body: "\(goalText). Da un sorbo y sigue con energía."
            )
        case 19:
            return (
                title: "🌙 ¡Tarde! Recuerda hidratarte",
                body: "\(goalText). Toma agua y cierra el día fuerte."
            )
        default:
            return (
                title: "💧 Hora de hidratarte",
                body: "\(goalText). Bebe agua ahora y cuida tu salud."
            )
        }
    }

    /// Cancela estos 3 recordatorios
    func cancelThreeDailyReminders() {
        print("🗑️ Cancelando notificaciones de agua...")
        center.removePendingNotificationRequests(withIdentifiers: ["waterReminder1", "waterReminder2", "waterReminder3"])
        userDefaults.set(false, forKey: notificationScheduledKey)
        userDefaults.removeObject(forKey: lastScheduledDateKey)
        print("🗑️ Notificaciones de agua canceladas")
    }
    
    /// Limpia todas las notificaciones de agua existentes (útil para debugging)
    func cleanupAllWaterNotifications() {
        print("🧹 Limpiando TODAS las notificaciones de agua...")
        center.removeAllPendingNotificationRequests()
        center.removeAllDeliveredNotifications()
        userDefaults.set(false, forKey: notificationScheduledKey)
        userDefaults.removeObject(forKey: lastScheduledDateKey)
        print("🧹 Todas las notificaciones de agua limpiadas")
    }
    
    /// Verifica el estado actual de las notificaciones
    func checkNotificationStatus() {
        center.getPendingNotificationRequests { requests in
            let waterRequests = requests.filter { $0.identifier.contains("waterReminder") }
            print("📱 Notificaciones de agua pendientes: \(waterRequests.count)")
            for request in waterRequests {
                print("   - \(request.identifier): \(request.content.title)")
                if let trigger = request.trigger as? UNCalendarNotificationTrigger {
                    print("     Próxima: \(trigger.nextTriggerDate()?.description ?? "N/A")")
                }
            }
        }
    }
    
    /// Método para limpiar y reprogramar notificaciones (útil para testing)
    func resetAndRescheduleNotifications(dailyRecommendation: String) {
        print("🔄 Reseteando y reprogramando notificaciones de agua")
        
        // ✅ CORREGIDO: Limpiar el estado antes de reprogramar
        userDefaults.set(false, forKey: notificationScheduledKey)
        userDefaults.removeObject(forKey: lastScheduledDateKey)
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
    
    // ✅ NUEVO: Método para verificar y limpiar estado al iniciar la app
    func forceCleanAndReset() {
        print("🧹 FORZANDO LIMPIEZA COMPLETA DE NOTIFICACIONES")
        
        // Limpiar UserDefaults
        userDefaults.removeObject(forKey: notificationScheduledKey)
        userDefaults.removeObject(forKey: lastScheduledDateKey)
        
        // Limpiar todas las notificaciones
        center.removeAllPendingNotificationRequests()
        center.removeAllDeliveredNotifications()
        
        print("🧹 Estado completamente limpiado")
    }
    
    // ✅ NUEVO: Método de prueba para verificar estado
    func debugNotificationStatus() {
        print("🔍 DEBUG: Verificando estado de notificaciones...")
        
        // Verificar UserDefaults
        let isScheduled = userDefaults.bool(forKey: notificationScheduledKey)
        let lastScheduled = userDefaults.object(forKey: lastScheduledDateKey) as? Date
        print("🔍 UserDefaults - Notificaciones programadas: \(isScheduled)")
        print("🔍 UserDefaults - Última programación: \(lastScheduled?.description ?? "N/A")")
        
        // Verificar notificaciones pendientes
        center.getPendingNotificationRequests { requests in
            let waterRequests = requests.filter { $0.identifier.contains("waterReminder") }
            print("🔍 Notificaciones pendientes: \(waterRequests.count)")
            
            for request in waterRequests {
                print("   - ID: \(request.identifier)")
                print("   - Título: \(request.content.title)")
                print("   - Cuerpo: \(request.content.body)")
                if let trigger = request.trigger as? UNCalendarNotificationTrigger {
                    print("   - Próxima fecha: \(trigger.nextTriggerDate()?.description ?? "N/A")")
                }
            }
        }
        
        // Verificar notificaciones entregadas
        center.getDeliveredNotifications { notifications in
            let waterNotifications = notifications.filter { $0.request.identifier.contains("waterReminder") }
            print("🔍 Notificaciones entregadas: \(waterNotifications.count)")
        }
    }
    
    // ✅ NUEVO: Método para probar notificación inmediata
    func testImmediateNotification() {
        print("🧪 Probando notificación inmediata...")
        
        let content = UNMutableNotificationContent()
        content.title = "🧪 Prueba de notificación de agua"
        content.body = "Las notificaciones están funcionando correctamente. Recibirás recordatorios a las 9:00, 13:00 y 19:00."
        content.sound = .default
        content.userInfo = ["screen": "diet", "type": "test"]
        
        // Trigger inmediato (5 segundos)
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let request = UNNotificationRequest(identifier: "testNotification", content: content, trigger: trigger)
        
        center.add(request) { error in
            if let error = error {
                print("❌ Error en notificación de prueba: \(error)")
            } else {
                print("✅ Notificación de prueba programada exitosamente")
            }
        }
    }
    
    // ✅ NUEVO: Método para probar notificación programada
    func testScheduledNotification() {
        print("🧪 Probando notificación programada...")
        
        let content = UNMutableNotificationContent()
        content.title = "🧪 Prueba programada de agua"
        content.body = "Esta notificación está programada para 10 segundos. Las notificaciones diarias se programan automáticamente."
        content.sound = .default
        content.userInfo = ["screen": "diet", "type": "test_scheduled"]
        
        // Trigger en 10 segundos
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 10, repeats: false)
        let request = UNNotificationRequest(identifier: "testScheduledNotification", content: content, trigger: trigger)
        
        center.add(request) { error in
            if let error = error {
                print("❌ Error en notificación programada: \(error)")
            } else {
                print("✅ Notificación programada exitosamente para 10 segundos")
            }
        }
    }
    
    // ✅ NUEVO: Método para verificar permisos
    func checkNotificationPermissions(completion: @escaping (UNAuthorizationStatus) -> Void) {
        center.getNotificationSettings { settings in
            print("🔍 Estado de permisos de notificación: \(settings.authorizationStatus.rawValue)")
            completion(settings.authorizationStatus)
        }
    }
    
    // ✅ NUEVO: Método para forzar solicitud de permisos
    func forceRequestPermissions(completion: @escaping (Bool) -> Void) {
        print("🔧 Forzando solicitud de permisos de notificación...")
        
        center.requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if let error = error {
                print("❌ Error solicitando permisos: \(error)")
                completion(false)
                return
            }
            
            print("🔧 Permisos de notificación: \(granted ? "✅ Concedidos" : "❌ Denegados")")
            completion(granted)
        }
    }
}

