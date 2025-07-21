import SwiftUI
import Combine

/// Vista principal de Workout que coordina todos los subcomponentes
struct WorkoutView: View {
    // MARK: - ViewModels
    @StateObject private var headerVM = WorkoutHeaderViewModel()
    @StateObject private var searchBarVM = SearchBarWorkoutViewModel()
    @StateObject private var viewModel = WorkoutViewModel()
    // Otros ViewModels comentados hasta que se usen
    // @StateObject private var characterVM = WorkoutCharacterViewModel()
    
    // MARK: - State
    @State private var showSearchResults: Bool = false
    @State private var showLocationMenu: Bool = false
    @State private var selectedLocation: WorkoutLocation = .atHome
    @State private var animatingSelection: Bool = false
    @State private var selectedLocationOption: WorkoutLocation? = nil
    
    var body: some View {
        // Fondo gradiente + ultraThinMaterial igual que el menú de localización
        ZStack {
            ZStack {
                LinearGradient(
                    colors: [
                        Color.black.opacity(0.95),
                        Color.gray.opacity(0.2),
                        Color.black.opacity(0.95)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                Rectangle()
                    .fill(.ultraThinMaterial)
                    .opacity(0.1)
            }
            .ignoresSafeArea()
            // Contenido principal
            VStack(spacing: 5) {
                // Header
                WorkoutHeaderView(viewModel: headerVM)
                    .padding(.top, 12)
                    .padding(.horizontal, 20)
                // Card de progreso de días
                WorkoutCalendarView()
                    .padding(.horizontal, 20)
                // Search bar de ejercicios
                SearchBarWorkoutView(
                    viewModel: searchBarVM,
                    onExerciseSelected: { _ in },
                    onFilterChanged: { _ in },
                    onLocationTapped: { showLocationMenu = true },
                    showSearchResults: $showSearchResults
                )
                .padding(.horizontal, 20)
                Spacer()
            }
            // Menú de localización como overlay flotante
            if showLocationMenu {
                LocationMenuView(
                    isVisible: $showLocationMenu,
                    selectedLocation: $selectedLocation
                )
            }
        }
        .onAppear {
            searchBarVM.configure(
                exercises: viewModel.allExercises,
                muscleGroups: viewModel.muscleGroups
            )
        }
    }
}

// MARK: - Preview
struct WorkoutView_Previews: PreviewProvider {
    static var previews: some View {
        WorkoutView()
            .preferredColorScheme(.dark)
    }
}
    
