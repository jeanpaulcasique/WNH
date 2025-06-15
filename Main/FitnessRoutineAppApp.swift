import SwiftUI

@main
struct WNHApp: App {
    @StateObject private var progressViewModel = ProgressViewModel()
    @StateObject private var sessionManager = UserSessionManager()
    
    // 1) Añadimos el DietViewModel aquí
    @StateObject private var dietViewModel = DietViewModel()

    var body: some Scene {
        WindowGroup {
            Group {
                if sessionManager.isLoggedIn {
                    DashboardView()
                        // 2) Inyectamos el DietViewModel si lo quieres en el entorno
                        .environmentObject(dietViewModel)
                        // 3) Arrancamos los recordatorios al aparecer la pantalla principal
                        .onAppear {
                            dietViewModel.startWaterRemindersThreeTimes()
                        }
                } else {
                    LoginView(viewModel: LoginViewModel())
                }
            }
            .environmentObject(progressViewModel)
            .environmentObject(sessionManager)
        }
    }
}
