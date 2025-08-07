import SwiftUI

struct DashboardView: View {
    @StateObject private var viewModel = DashboardViewModel()

    var body: some View {
        TabView {
            // Pestaña Workout
            WorkoutView()
                .tabItem {
                    Image(systemName: "dumbbell.fill")
                    Text("Workout")
                }

            // Pestaña Diet
            DietView()
                .tabItem {
                    Image(systemName: "fork.knife")
                    Text("Diet")
                }

            // Pestaña Trainer
            FitnessTrainerApp()
                .tabItem {
                    Image(systemName: "person.2.fill")
                    Text("Trainer")
                }

            // Pestaña Shop
            ShoppingView()
                .tabItem {
                    Image(systemName: "cart.fill")
                    Text("Shop")
                }

            // Pestaña Me
            MeView()
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Me")
                }
        }
        .accentColor(.yellow)
        // Oculta la barra de navegación y el botón Back
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
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

