import SwiftUI

struct DashboardView: View {
    @StateObject private var viewModel = DashboardViewModel()
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            // Pestaña Workout
            WorkoutView()
                .tag(0)
                .tabItem {
                    Image(systemName: "dumbbell.fill")
                    Text("Workout")
                }

            // Pestaña Diet
            DietView()
                .tag(1)
                .tabItem {
                    Image(systemName: "fork.knife")
                    Text("Diet")
                }

            // Pestaña Trainer
            FitnessTrainerApp()
                .tag(2)
                .tabItem {
                    Image(systemName: "person.2.fill")
                    Text("Trainer")
                }

            // Pestaña Shop
            ShoppingView()
                .tag(3)
                .tabItem {
                    Image(systemName: "cart.fill")
                    Text("Shop")
                }

            // Pestaña Me
            MeView()
                .tag(4)
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Me")
                }
        }
        .accentColor(.yellow)
        // Oculta la barra de navegación y el botón Back
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("NavigateToDietTab"))) { _ in
            // Cambiar a la pestaña de Diet cuando se recibe la notificación
            selectedTab = 1
        }
        // Asegúrate de que esto se muestre dentro de un NavigationView si lo necesitas en previews:
    }
}

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            DashboardView()
        }
        .preferredColorScheme(.dark)
    }
}

