import SwiftUI
import Combine

// MARK: - Importaciones de Componentes
// Los componentes están en el mismo módulo, por lo que no necesitan importación adicional

/// Vista principal de Workout que coordina todos los subcomponentes
struct WorkoutView: View {
    // MARK: - ViewModels
    @StateObject private var headerVM = WorkoutHeaderViewModel()
    @StateObject private var searchBarVM = SearchBarWorkoutViewModel()
    @StateObject private var viewModel = WorkoutViewModel()
    
    // MARK: - State
    @State private var showSearchResults: Bool = false
    @State private var showLocationMenu: Bool = false
    @State private var selectedLocation: WorkoutLocation = .atHome
    @State private var animatingSelection: Bool = false
    @State private var selectedLocationOption: WorkoutLocation? = nil
    @State private var selectedMuscleForVideos: MuscleGroup? = nil // Para navegación a videos
    @State private var isShowingBack: Bool = false // Para imagen frontal/trasera
    
    var body: some View {
        NavigationView {
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
                    WorkoutCalendarView(workoutViewModel: viewModel)
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
                    
                    // Tira de categorías de músculos
                    MuscleCategoryCards(
                        muscleGroups: isShowingBack ? viewModel.getBackMuscleGroups() : viewModel.getFrontMuscleGroups(),
                        selectedMuscle: viewModel.selectedMuscle,
                        onMuscleSelected: { group in
                            selectedMuscleForVideos = group
                        }
                    )
                    .padding(.vertical, 8)
                    .padding(.horizontal, 20)
                    
                    // Imagen del personaje
                    WorkoutCharacterView(
                        isShowingBack: isShowingBack,
                        onToggle: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                isShowingBack.toggle()
                            }
                        }
                    )
                    .padding(.horizontal, 20)
                    
                    Spacer()
                }
                
                // Botones de músculos como overlay de toda la pantalla (solo cuando se muestra la vista frontal)
                if !isShowingBack {
                    GeometryReader { geometry in
                        ZStack {
                            ForEach(viewModel.getFrontMuscleGroups()) { muscleGroup in
                                MuscleGroupButton(
                                    muscleGroup: muscleGroup,
                                    action: {
                                        // Navegar a videos del músculo seleccionado
                                        selectedMuscleForVideos = muscleGroup
                                    }
                                )
                                .position(
                                    x: muscleGroup.position.x * geometry.size.width,
                                    y: muscleGroup.position.y * geometry.size.height
                                )
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .allowsHitTesting(true)
                }
                
                // Botones de músculos traseros como overlay de toda la pantalla (solo cuando se muestra la vista trasera)
                if isShowingBack {
                    GeometryReader { geometry in
                        ZStack {
                            ForEach(viewModel.getBackMuscleGroups()) { muscleGroup in
                                MuscleGroupButton(
                                    muscleGroup: muscleGroup,
                                    action: {
                                        // Navegar a videos del músculo seleccionado
                                        selectedMuscleForVideos = muscleGroup
                                    }
                                )
                                .position(
                                    x: muscleGroup.position.x * geometry.size.width,
                                    y: muscleGroup.position.y * geometry.size.height
                                )
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .allowsHitTesting(true)
                }
                
                // Indicadores de ritmo cardíaco y pasos como overlay flotante
                VStack {
                    Spacer()
                        .frame(height: 280) // ← 30 puntos más abajo (250 + 30)
                    HStack {
                        HeartRateIndicator(
                            bpm: viewModel.heartRate,
                            isAuthorized: viewModel.healthKitAuthorized,
                            isLoading: viewModel.isLoadingHeartRate,
                            onRequestAuthorization: {
                                viewModel.requestHealthKitAuthorization()
                            }
                        )
                        .padding(.leading, 20)
                        Spacer()
                        StepsIndicator(
                            workoutViewModel: viewModel,
                            isAuthorized: viewModel.stepsAuthorized,
                            isLoading: viewModel.isLoadingSteps,
                            onRequestAuthorization: {
                                viewModel.requestStepsAuthorization()
                            }
                        )
                        .padding(.trailing, 20)
                    }
                    Spacer()
                }
                
                // Botón para cambiar imagen del personaje
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                isShowingBack.toggle()
                            }
                        }) {
                            Image(systemName: "arrow.triangle.2.circlepath")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white)
                                .frame(width: 40, height: 40)
                                .background(
                                    Circle()
                                        .fill(Color.black.opacity(0.7))
                                        .overlay(
                                            Circle()
                                                .stroke(Color.yellow.opacity(0.6), lineWidth: 1.5)
                                        )
                                )
                                .shadow(color: Color.black.opacity(0.3), radius: 5, x: 0, y: 2)
                        }
                        .padding(.trailing, 20)
                        .padding(.bottom, 20)
                    }
                }
                
                // Menú de localización como overlay flotante
                if showLocationMenu {
                    LocationMenuView(
                        isVisible: $showLocationMenu,
                        selectedLocation: $selectedLocation
                    )
                }
                
                // NavigationLink oculto para navegar a VideosDashBoardView
                NavigationLink(
                    destination: selectedMuscleForVideos.map { group in
                        VideosDashBoardView(selectedMuscleGroup: group.name) {
                            selectedMuscleForVideos = nil
                        }
                    },
                    isActive: Binding(
                        get: { selectedMuscleForVideos != nil },
                        set: { if !$0 { selectedMuscleForVideos = nil } }
                    )
                ) {
                    EmptyView()
                }
                .hidden()
            }
            .onAppear {
                viewModel.loadInitialData()
                searchBarVM.configure(
                    exercises: viewModel.allExercises,
                    muscleGroups: viewModel.muscleGroups
                )
                // Iniciar monitoreo de pasos
                if viewModel.stepsAuthorized {
                    viewModel.stepsService.startStepsMonitoring()
                }
            }
            .navigationBarHidden(true)
            .navigationBarBackButtonHidden(true)
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
    
