import UIKit
import UserNotifications
import FirebaseCore
#if canImport(GoogleSignIn)
import GoogleSignIn
#endif
#if canImport(FBSDKCoreKit)
import FBSDKCoreKit
#endif

// ✅ NUEVO: Extensiones para notificaciones de ciclo de vida de la app
extension Notification.Name {
    static let appWillTerminate = Notification.Name("appWillTerminate")
    static let appDidEnterBackground = Notification.Name("appDidEnterBackground")
}

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        if FirebaseApp.app() == nil {
            if let plistPath = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist"),
               let options = FirebaseOptions(contentsOfFile: plistPath) {
                FirebaseApp.configure(options: options)
                print("Firebase configurado correctamente.")
            } else {
                print("Firebase no configurado: falta GoogleService-Info.plist en el target.")
            }
        }
        
        // Configurar el delegate de notificaciones
        UNUserNotificationCenter.current().delegate = self

        #if canImport(FBSDKCoreKit)
        ApplicationDelegate.shared.application(
            application,
            didFinishLaunchingWithOptions: launchOptions
        )
        #endif
        
        return true
    }

    func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey : Any] = [:]
    ) -> Bool {
        #if canImport(GoogleSignIn)
        if GIDSignIn.sharedInstance.handle(url) {
            return true
        }
        #endif

        #if canImport(FBSDKCoreKit)
        if ApplicationDelegate.shared.application(app, open: url, options: options) {
            return true
        }
        #endif

        return false
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
    
    // ✅ NUEVO: Guardar datos cuando la app va a ser terminada
    func applicationWillTerminate(_ application: UIApplication) {
        print("📱 APP TERMINATION: Guardando datos antes de cerrar la app...")
        
        // Forzar guardado de UserDefaults
        UserDefaults.standard.synchronize()
        
        // Notificar a los servicios para que guarden sus datos
        NotificationCenter.default.post(name: .appWillTerminate, object: nil)
        
        print("✅ APP TERMINATION: Datos guardados correctamente")
    }
    
    // ✅ NUEVO: Guardar datos cuando la app entra en background
    func applicationDidEnterBackground(_ application: UIApplication) {
        print("📱 APP BACKGROUND: Guardando datos al entrar en background...")
        
        // Forzar guardado de UserDefaults
        UserDefaults.standard.synchronize()
        
        // Notificar a los servicios para que guarden sus datos
        NotificationCenter.default.post(name: .appDidEnterBackground, object: nil)
        
        print("✅ APP BACKGROUND: Datos guardados correctamente")
    }
}
