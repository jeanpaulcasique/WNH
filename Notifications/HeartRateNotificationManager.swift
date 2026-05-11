import Foundation
import UserNotifications
import SwiftUI
import Combine

// MARK: - Heart Rate Alert Types

enum HeartRateAlertType: String, CaseIterable {
    case tooHigh = "too_high"
    case tooLow = "too_low"
    case critical = "critical"
    case normal = "normal"
    
    var title: String {
        switch self {
        case .tooHigh:
            return "⚠️ High Heart Rate"
        case .tooLow:
            return "⚠️ Low Heart Rate"
        case .critical:
            return "🚨 Critical Heart Rate"
        case .normal:
            return "✅ Heart Rate Normal"
        }
    }
}

// MARK: - Heart Rate Zone

enum HeartRateZone {
    case resting      // < 60 bpm
    case normal       // 60-100 bpm  
    case elevated     // 100-150 bpm
    case high         // 150-180 bpm
    case veryHigh     // 180-200 bpm
    case critical     // > 200 bpm
    
    func getZone(for heartRate: Int, age: Int) -> HeartRateZone {
        let maxHeartRate = 220 - age
        let percentage = Double(heartRate) / Double(maxHeartRate)
        
        switch heartRate {
        case 0..<60:
            return .resting
        case 60...100:
            return .normal
        case 101...150:
            return .elevated
        case 151...180:
            return .high
        case 181...200:
            return .veryHigh
        default:
            return .critical
        }
    }
    
    var description: String {
        switch self {
        case .resting:
            return "Resting"
        case .normal:
            return "Normal"
        case .elevated:
            return "Elevated"
        case .high:
            return "High"
        case .veryHigh:
            return "Very High"
        case .critical:
            return "Critical"
        }
    }
    
    var color: Color {
        switch self {
        case .resting:
            return .blue
        case .normal:
            return .green
        case .elevated:
            return .yellow
        case .high:
            return .orange
        case .veryHigh:
            return .red
        case .critical:
            return .purple
        }
    }
}

// MARK: - Heart Rate Notification Manager

final class HeartRateNotificationManager: ObservableObject {
    static let shared = HeartRateNotificationManager()
    
    // MARK: - Published Properties
    @Published var isMonitoringEnabled = false
    @Published var showInAppAlert = false
    @Published var currentAlert: HeartRateAlert?
    @Published var lastNotificationTime: Date?
    
    // MARK: - Private Properties
    private let notificationCenter = UNUserNotificationCenter.current()
    private let userDefaults = UserDefaults.standard
    private var cancellables = Set<AnyCancellable>()
    
    // Configuration
    private let minimumTimeBetweenNotifications: TimeInterval = 300 // 5 minutes
    private let criticalTimeBetweenNotifications: TimeInterval = 60  // 1 minute for critical
    
    // Keys for UserDefaults
    private let monitoringEnabledKey = "heartRateMonitoringEnabled"
    private let lastNotificationTimeKey = "lastHeartRateNotificationTime"
    private let userAgeKey = "selectedBirthYear"
    
    private init() {
        loadSettings()
        setupNotificationCategories()
    }
    
    // MARK: - Public Methods
    
    /// Inicia el monitoreo de ritmo cardíaco
    func startMonitoring() {
        print("🫀 HeartRateNotificationManager: Iniciando monitoreo...")
        isMonitoringEnabled = true
        saveSettings()
        requestNotificationPermissions()
    }
    
    /// Detiene el monitoreo de ritmo cardíaco
    func stopMonitoring() {
        print("🫀 HeartRateNotificationManager: Deteniendo monitoreo...")
        isMonitoringEnabled = false
        saveSettings()
        cancelAllNotifications()
    }
    
    /// Procesa un nuevo valor de ritmo cardíaco
    func processHeartRate(_ heartRate: Int) {
        guard isMonitoringEnabled else { return }
        
        print("🫀 Procesando ritmo cardíaco: \(heartRate) bpm")
        
        let userAge = getUserAge()
        let zone = HeartRateZone.normal.getZone(for: heartRate, age: userAge)
        let alertType = determineAlertType(heartRate: heartRate, zone: zone, age: userAge)
        
        if shouldTriggerAlert(for: alertType) {
            triggerAlert(heartRate: heartRate, zone: zone, alertType: alertType)
        }
    }
    
    /// Maneja alertas críticas inmediatas
    func handleCriticalAlert(heartRate: Int) {
        let userAge = getUserAge()
        let zone = HeartRateZone.normal.getZone(for: heartRate, age: userAge)
        
        let alert = HeartRateAlert(
            type: .critical,
            heartRate: heartRate,
            zone: zone,
            timestamp: Date(),
            message: getCriticalMessage(for: heartRate, age: userAge)
        )
        
        // Mostrar alerta en la app inmediatamente
        showInAppAlert(alert)
        
        // Enviar notificación push crítica
        sendCriticalNotification(alert)
    }
    
    // MARK: - Private Methods
    
    private func loadSettings() {
        isMonitoringEnabled = userDefaults.bool(forKey: monitoringEnabledKey)
        lastNotificationTime = userDefaults.object(forKey: lastNotificationTimeKey) as? Date
    }
    
    private func saveSettings() {
        userDefaults.set(isMonitoringEnabled, forKey: monitoringEnabledKey)
        if let lastTime = lastNotificationTime {
            userDefaults.set(lastTime, forKey: lastNotificationTimeKey)
        }
    }
    
    private func getUserAge() -> Int {
        let birthYear = userDefaults.string(forKey: userAgeKey) ?? "1990"
        let currentYear = Calendar.current.component(.year, from: Date())
        return currentYear - (Int(birthYear) ?? 30)
    }
    
    private func determineAlertType(heartRate: Int, zone: HeartRateZone, age: Int) -> HeartRateAlertType {
        switch zone {
        case .resting:
            return heartRate < 50 ? .tooLow : .normal
        case .normal:
            return .normal
        case .elevated:
            return .normal // Elevated puede ser normal durante ejercicio
        case .high:
            return .tooHigh
        case .veryHigh:
            return .tooHigh
        case .critical:
            return .critical
        }
    }
    
    private func shouldTriggerAlert(for alertType: HeartRateAlertType) -> Bool {
        guard let lastTime = lastNotificationTime else { return true }
        
        let timeSinceLastNotification = Date().timeIntervalSince(lastTime)
        
        switch alertType {
        case .critical:
            return timeSinceLastNotification >= criticalTimeBetweenNotifications
        case .tooHigh, .tooLow:
            return timeSinceLastNotification >= minimumTimeBetweenNotifications
        case .normal:
            return false // No enviar notificaciones para valores normales
        }
    }
    
    private func triggerAlert(heartRate: Int, zone: HeartRateZone, alertType: HeartRateAlertType) {
        let alert = HeartRateAlert(
            type: alertType,
            heartRate: heartRate,
            zone: zone,
            timestamp: Date(),
            message: getMessage(for: alertType, heartRate: heartRate)
        )
        
        // Mostrar alerta en la app
        showInAppAlert(alert)
        
        // Enviar notificación push
        sendPushNotification(alert)
        
        // Actualizar último tiempo de notificación
        lastNotificationTime = Date()
        saveSettings()
    }
    
    private func showInAppAlert(_ alert: HeartRateAlert) {
        DispatchQueue.main.async {
            self.currentAlert = alert
            self.showInAppAlert = true
        }
    }
    
    private func getMessage(for alertType: HeartRateAlertType, heartRate: Int) -> String {
        switch alertType {
        case .tooHigh:
            return "Your heart rate is \(heartRate) bpm, which is higher than recommended. Consider resting and monitoring your condition."
        case .tooLow:
            return "Your heart rate is \(heartRate) bpm, which is lower than normal. If you feel unwell, consider consulting a healthcare professional."
        case .critical:
            return getCriticalMessage(for: heartRate, age: getUserAge())
        case .normal:
            return "Your heart rate is \(heartRate) bpm, which is within normal range."
        }
    }
    
    private func getCriticalMessage(for heartRate: Int, age: Int) -> String {
        if heartRate > 200 {
            return "CRITICAL: Your heart rate is \(heartRate) bpm. This is extremely high. Please seek immediate medical attention if you feel unwell."
        } else if heartRate < 40 {
            return "CRITICAL: Your heart rate is \(heartRate) bpm. This is very low. Please seek medical attention if you feel dizzy or unwell."
        } else {
            return "Your heart rate is \(heartRate) bpm. Please monitor your condition and consult a healthcare professional if you have concerns."
        }
    }
    
    // MARK: - Notification Methods
    
    private func requestNotificationPermissions() {
        notificationCenter.requestAuthorization(options: [.alert, .badge, .sound, .criticalAlert]) { granted, error in
            if granted {
                print("🫀 Permisos de notificación concedidos para ritmo cardíaco")
            } else {
                print("🫀 Permisos de notificación denegados para ritmo cardíaco")
            }
        }
    }
    
    private func setupNotificationCategories() {
        let heartRateCategory = UNNotificationCategory(
            identifier: "HEART_RATE_ALERT",
            actions: [
                UNNotificationAction(
                    identifier: "VIEW_DETAILS",
                    title: "View Details",
                    options: [.foreground]
                ),
                UNNotificationAction(
                    identifier: "DISMISS",
                    title: "Dismiss",
                    options: []
                )
            ],
            intentIdentifiers: [],
            options: [.customDismissAction]
        )
        
        let criticalCategory = UNNotificationCategory(
            identifier: "CRITICAL_HEART_RATE",
            actions: [
                UNNotificationAction(
                    identifier: "EMERGENCY_CALL",
                    title: "Emergency",
                    options: [.foreground, .destructive]
                ),
                UNNotificationAction(
                    identifier: "VIEW_DETAILS",
                    title: "View Details",
                    options: [.foreground]
                )
            ],
            intentIdentifiers: [],
            options: [.customDismissAction]
        )
        
        notificationCenter.setNotificationCategories([heartRateCategory, criticalCategory])
    }
    
    private func sendPushNotification(_ alert: HeartRateAlert) {
        let content = UNMutableNotificationContent()
        content.title = alert.type.title
        content.body = alert.message
        content.sound = alert.type == .critical ? .defaultCritical : .default
        content.categoryIdentifier = alert.type == .critical ? "CRITICAL_HEART_RATE" : "HEART_RATE_ALERT"
        
        content.userInfo = [
            "type": "heart_rate_alert",
            "alert_type": alert.type.rawValue,
            "heart_rate": alert.heartRate,
            "zone": alert.zone.description,
            "timestamp": alert.timestamp.timeIntervalSince1970
        ]
        
        let identifier = "heart_rate_\(alert.type.rawValue)_\(Date().timeIntervalSince1970)"
        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: nil // Immediate notification
        )
        
        notificationCenter.add(request) { error in
            if let error = error {
                print("🫀 Error enviando notificación de ritmo cardíaco: \(error)")
            } else {
                print("🫀 Notificación de ritmo cardíaco enviada: \(alert.type.rawValue)")
            }
        }
    }
    
    private func sendCriticalNotification(_ alert: HeartRateAlert) {
        let content = UNMutableNotificationContent()
        content.title = "🚨 CRITICAL HEART RATE ALERT"
        content.body = alert.message
        content.sound = .defaultCritical
        content.categoryIdentifier = "CRITICAL_HEART_RATE"
        
        // Configurar como notificación crítica
        content.interruptionLevel = .critical
        content.relevanceScore = 1.0
        
        content.userInfo = [
            "type": "critical_heart_rate",
            "heart_rate": alert.heartRate,
            "timestamp": alert.timestamp.timeIntervalSince1970,
            "emergency": true
        ]
        
        let identifier = "critical_heart_rate_\(Date().timeIntervalSince1970)"
        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: nil
        )
        
        notificationCenter.add(request) { error in
            if let error = error {
                print("🫀 Error enviando notificación crítica: \(error)")
            } else {
                print("🫀 Notificación crítica enviada")
            }
        }
    }
    
    private func cancelAllNotifications() {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [])
        notificationCenter.removeDeliveredNotifications(withIdentifiers: [])
    }
    
    // MARK: - Public Utilities
    
    /// Obtiene el estado actual del monitoreo
    func getMonitoringStatus() -> String {
        return isMonitoringEnabled ? "Active" : "Inactive"
    }
    
    /// Prueba el sistema de notificaciones
    func testNotificationSystem() {
        let testAlert = HeartRateAlert(
            type: .tooHigh,
            heartRate: 180,
            zone: .veryHigh,
            timestamp: Date(),
            message: "Test notification: Heart rate monitoring is working correctly."
        )
        
        showInAppAlert(testAlert)
        sendPushNotification(testAlert)
    }
    
    /// Limpia alertas antigas
    func clearOldAlerts() {
        currentAlert = nil
        showInAppAlert = false
    }
}

// MARK: - Heart Rate Alert Model

struct HeartRateAlert: Identifiable {
    let id = UUID()
    let type: HeartRateAlertType
    let heartRate: Int
    let zone: HeartRateZone
    let timestamp: Date
    let message: String
    
    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: timestamp)
    }
    
    var isRecent: Bool {
        Date().timeIntervalSince(timestamp) < 3600 // Last hour
    }
}

// MARK: - Heart Rate Monitoring Settings

struct HeartRateMonitoringSettings {
    var isEnabled: Bool = false
    var alertThresholds: HeartRateThresholds = HeartRateThresholds()
    var notificationPreferences: NotificationPreferences = NotificationPreferences()
    
    struct HeartRateThresholds {
        var highThreshold: Int = 180
        var lowThreshold: Int = 50
        var criticalHighThreshold: Int = 200
        var criticalLowThreshold: Int = 40
    }
    
    struct NotificationPreferences {
        var enablePushNotifications: Bool = true
        var enableInAppAlerts: Bool = true
        var enableCriticalAlerts: Bool = true
        var minimumTimeBetweenAlerts: TimeInterval = 300 // 5 minutes
    }
}
