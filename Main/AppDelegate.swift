import UIKit
import UserNotifications

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        // Configurar el delegate de notificaciones
        UNUserNotificationCenter.current().delegate = self
        
        return true
    }
    
    // MARK: - UNUserNotificationCenterDelegate
    
    // Cuando se toca una notificación y la app está en segundo plano
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let userInfo = response.notification.request.content.userInfo
        
        // Guardar la información de la notificación para manejarla cuando la app se active
        if let screen = userInfo["screen"] as? String, screen == "diet" {
            UserDefaults.standard.set(userInfo, forKey: "pendingNotification")
            print("🚰 Notificación de agua recibida, guardada para navegación")
            
            // Si la app está activa, navegar inmediatamente
            DispatchQueue.main.async {
                NotificationCenter.default.post(
                    name: Notification.Name("NavigateToDietTab"),
                    object: nil
                )
            }
        }
        
        completionHandler()
    }
    
    // Cuando se recibe una notificación y la app está en primer plano
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        // Mostrar la notificación incluso si la app está en primer plano
        completionHandler([.banner, .sound, .badge])
    }
}
