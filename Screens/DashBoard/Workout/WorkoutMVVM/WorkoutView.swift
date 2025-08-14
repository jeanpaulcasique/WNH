import SwiftUI
import Combine

// MARK: - Importaciones de Componentes
// Los componentes están en el mismo módulo, por lo que no necesitan importación adicional

/// Vista principal de Workout que coordina todos los subcomponentes
struct WorkoutView: View {
    // MARK: - ViewModels
    @StateObject private var headerVM = WorkoutHeaderViewModel()
    @StateObject private var viewModel = WorkoutViewModel()
    
    // MARK: - State
    @State private var showLocationMenu: Bool = false
    @State private var selectedLocation: WorkoutLocation = .atHome
    @State private var animatingSelection: Bool = false
    @State private var selectedLocationOption: WorkoutLocation? = nil
    @State private var selectedMuscleForVideos: MuscleGroup? = nil // Para navegación a videos
    @State private var isShowingBack: Bool = false // Para imagen frontal/trasera
    
    var body: some View {
        NavigationView {
            ZStack {
                // Fondo igual que MeView
                Color.appBackgroundGradient
                    .ignoresSafeArea()
                
                // Contenido principal
                VStack(spacing: 5) {
                    // Header con page indicator
                    WorkoutHeaderWithPageIndicator()
                        .padding(.top, 5)
                        .padding(.horizontal, 20)
                    // Card de progreso de días
                    WorkoutCalendarView(workoutViewModel: viewModel)
                        .padding(.top, 0) // Eliminado el padding para acercar completamente los círculos al header
                        .padding(.horizontal, 20)
                    
                    // Tira de categorías de músculos
                    MuscleCategoryCards(
                        muscleGroups: isShowingBack ? viewModel.getBackMuscleGroups() : viewModel.getFrontMuscleGroups(),
                        selectedMuscle: viewModel.selectedMuscle,
                        onMuscleSelected: { group in
                            selectedMuscleForVideos = group
                        }
                    )
                    .padding(.top, -5) // Padding negativo para subir más la tira de scroll horizontal
                    .padding(.bottom, 8)
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
                        .frame(height: 255) // ← Aumentado de 250 a 255 para bajar 5 puntos más los indicadores de ritmo cardíaco y steps
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
                
                // Botón de localización y botón para cambiar imagen del personaje
                VStack {
                    Spacer()
                    
                    // Botón de localización
                    HStack {
                        Spacer()
                        
                        Button(action: {
                            showLocationMenu = true
                        }) {
                            Image(systemName: "location.fill")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.yellow)
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
                        .padding(.bottom, 10)
                    }
                    
                    // Botón para cambiar imagen del personaje
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
    
