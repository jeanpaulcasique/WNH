import SwiftUI
import Combine

// MARK: - Animated greeting and workout tips (ENGLISH)
private let workoutTips: [String] = [
    "Start your session with a proper warm-up!",
    "Begin with chest and triceps: they work together in most exercises.",
    "Focus on compound movements first (bench press, dips, push-ups).",
    "Keep your rest between sets to 60-90 seconds for muscle growth.",
    "Stay hydrated and listen to your body.",
    "Finish with isolation exercises for a great pump!"
]

struct WorkoutView: View {
    @StateObject private var viewModel = WorkoutViewModel()
    @StateObject private var searchBarVM = SearchBarWorkoutViewModel()
    @State private var path: [String] = []
    @State private var selectedMuscleForLabel: MuscleGroup? = nil
    @State private var showSearchResults: Bool = false
    @State private var showLocationMenu: Bool = false
    @State private var locationButtonFrame: CGRect = .zero
    @State private var selectedLocationOption: WorkoutLocation? = nil
    @State private var animatingSelection: Bool = false
    @State private var currentTipIndex = 0
    @State private var animateTip = false
    @State private var userName: String? = nil
    
    var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                LinearGradient(
                    colors: [Color.black, Color.gray.opacity(0.3), Color.black],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Saludo y tips animados
                    VStack(spacing: 10) {
                        Text(userName != nil ? "Hi, \(userName!)!" : "Ready to train?")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(.yellow)
                            .multilineTextAlignment(.center)
                        ZStack {
                            ForEach(0..<workoutTips.count, id: \.self) { i in
                                if i == currentTipIndex {
                                    Text(workoutTips[i])
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.white.opacity(0.85))
                                        .multilineTextAlignment(.center)
                                        .padding(.horizontal, 16)
                                        .lineLimit(2)
                                        .minimumScaleFactor(0.85)
                                        .id(i)
                                        .opacity(animateTip ? 1 : 0)
                                        .offset(y: animateTip ? 0 : 30)
                                        .animation(.spring(response: 0.7, dampingFraction: 0.7), value: animateTip)
                                }
                            }
                        }
                        .frame(height: 48)
                    }
                    .padding(.top, 10)
                    headerView
                    SearchBarWorkoutView(
                        viewModel: searchBarVM,
                        onExerciseSelected: { exercise in
                            path = [exercise.name]
                        },
                        onFilterChanged: { _ in },
                        onLocationTapped: { showLocationMenu = true },
                        showSearchResults: $showSearchResults
                    )
                    if showSearchResults && !searchBarVM.filteredExercises.isEmpty {
                        EmptyView() // Los resultados ya se muestran en el SearchBarWorkoutView
                    } else {
                        Spacer(minLength: 0)
                        GeometryReader { geometry in
                            ZStack {
                                humanFigureView(geometry: geometry)
                                muscleGroupButtons(geometry: geometry)
                            }
                        }
                        .aspectRatio(0.6, contentMode: .fit)
                        Spacer()
                        bottomControlsView
                    }
                }
                .padding()
            }
            .navigationBarHidden(true)
            // ✅ Navegación directa al VideosDashBoardView
            .navigationDestination(for: String.self) { muscleName in
                VideosDashBoardView(
                    selectedMuscleGroup: muscleName,
                    onBack: {
                        path = []
                    }
                )
            }
            // Menú de localización posicionado como extensión del botón
            .overlay(
                locationMenuOverlay
                    .opacity(showLocationMenu ? 1 : 0)
                    .scaleEffect(showLocationMenu ? 1 : 0.8)
                    .animation(.spring(response: 0.4, dampingFraction: 0.8), value: showLocationMenu)
            )
        }
        .onAppear {
            // Sincronizar datos con el search bar VM
            searchBarVM.configure(exercises: viewModel.allExercises, muscleGroups: viewModel.muscleGroups)
            userName = UserDefaults.standard.string(forKey: "userName")
            animateTip = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                animateTip = true
            }
            var tipTimer: Timer?
            func startTipTimer() {
                tipTimer?.invalidate()
                tipTimer = Timer.scheduledTimer(withTimeInterval: 15.0, repeats: false) { _ in
                    withAnimation(.spring(response: 0.7, dampingFraction: 0.7)) {
                        animateTip = false
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        let isLast = currentTipIndex == workoutTips.count - 1
                        if isLast {
                            // Espera 1 minuto antes de reiniciar
                            tipTimer = Timer.scheduledTimer(withTimeInterval: 60.0, repeats: false) { _ in
                                currentTipIndex = 0
                                animateTip = true
                                startTipTimer()
                            }
                        } else {
                            currentTipIndex = (currentTipIndex + 1)
                            animateTip = true
                            startTipTimer()
                        }
                    }
                }
            }
            startTipTimer()
        }
        .onChange(of: viewModel.selectedMuscle) { _, newMuscle in
            if let muscle = newMuscle {
                path = [muscle.name]
                selectedMuscleForLabel = nil // Limpiar selección
            }
        }
        .onChange(of: viewModel.isShowingBack) { _, _ in
            selectedMuscleForLabel = nil // Limpiar al cambiar vista
        }
        .onChange(of: viewModel.muscleGroups) { _, newGroups in
            // Actualizar los grupos musculares en el search bar VM cuando cambie la vista (frontal/trasera)
            searchBarVM.configure(exercises: viewModel.allExercises, muscleGroups: newGroups)
        }
    }
    
    private var headerView: some View {
        HStack {
            Spacer()
        }
    }
    
    private func humanFigureView(geometry: GeometryProxy) -> some View {
        ZStack {
            // Vista frontal
            Image("human_front")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: geometry.size.width * 1.21, height: geometry.size.height * 1.15)
                .clipped()
                .offset(x: -25, y: -45)
                .opacity(viewModel.isShowingBack ? 0 : 1)
                .rotation3DEffect(
                    .degrees(viewModel.isShowingBack ? 90 : 0),
                    axis: (x: 0, y: 1, z: 0)
                )
            
            // Vista trasera
            Image("human_back")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: geometry.size.width * 1.21, height: geometry.size.height * 1.15)
                .clipped()
                .offset(x: -25, y: -45)
                .opacity(viewModel.isShowingBack ? 1 : 0)
                .rotation3DEffect(
                    .degrees(viewModel.isShowingBack ? 0 : -90),
                    axis: (x: 0, y: 1, z: 0)
                )
        }
        .animation(.easeInOut(duration: 0.6), value: viewModel.isShowingBack)
    }
    
    private func muscleGroupButtons(geometry: GeometryProxy) -> some View {
        ZStack {
            ForEach(searchBarVM.filteredMuscleGroups, id: \.id) { muscle in
                let position = muscle.position
                let isSelected = selectedMuscleForLabel?.id == muscle.id
                
                Button(action: {
                    if isSelected {
                        // Segundo tap - navegar
                        viewModel.selectMuscle(muscle)
                    } else {
                        // Primer tap - seleccionar y mostrar label
                        selectedMuscleForLabel = muscle
                    }
                }) {
                    VStack(spacing: 4) {
                        Circle()
                            .fill(isSelected ? Color.red : Color.yellow)
                            .frame(width: 12, height: 12)
                            .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
                        
                        if isSelected {
                            Text(muscle.name)
                                .font(.caption2)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.black.opacity(0.8))
                                .cornerRadius(8)
                                .shadow(color: .black.opacity(0.5), radius: 3, x: 0, y: 2)
                        }
                    }
                }
                .position(x: geometry.size.width * position.x, y: geometry.size.height * position.y)
                .animation(.easeInOut(duration: 0.2), value: isSelected)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: searchBarVM.filteredMuscleGroups)
    }
    
    private var bottomControlsView: some View {
        VStack(spacing: 16) {
            HStack(spacing: 6) {
                Image(systemName: "arrow.left.and.right")
                    .foregroundColor(.yellow)
                    .font(.title3)
                Text("Swipe")
                    .foregroundColor(.white)
                    .font(.system(size: 15, weight: .medium))
                Text("180°")
                    .foregroundColor(.yellow)
                    .font(.system(size: 17, weight: .bold))
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 16)
            .background(Color.white.opacity(0.12))
            .cornerRadius(10)
            .onTapGesture {
                viewModel.toggleView()
            }
        }
        .padding(.bottom, 16)
    }
    
    private var locationMenuOverlay: some View {
        GeometryReader { geometry in
            ZStack {
                // Fondo semi-transparente
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            showLocationMenu = false
                        }
                    }
                
                // Menú de localización posicionado como extensión del botón
                VStack(spacing: 0) {
                    VStack(spacing: 0) {
                        locationOptionButton(
                            location: .atHome,
                            icon: "house.fill",
                            title: "At Home"
                        )
                        
                        Divider()
                            .background(Color.gray.opacity(0.3))
                        
                        locationOptionButton(
                            location: .atGym,
                            icon: "dumbbell.fill",
                            title: "At Gym"
                        )
                        
                        Divider()
                            .background(Color.gray.opacity(0.3))
                        
                        locationOptionButton(
                            location: .outdoors,
                            icon: "leaf.fill",
                            title: "Outdoors"
                        )
                    }
                    .background(
                        LinearGradient(
                            colors: [Color.black, Color.gray.opacity(0.3), Color.black],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .cornerRadius(12)
                    .shadow(color: .black.opacity(0.8), radius: 15, x: 0, y: 8)
                }
                .frame(maxWidth: 200)
                .position(
                    x: geometry.size.width - 60, // Posición X: derecha, cerca del botón de localización
                    y: 120 // Posición Y: debajo del header y search bar
                )
            }
        }
    }
    
    private func locationOptionButton(location: WorkoutLocation, icon: String, title: String) -> some View {
        let isSelected = viewModel.selectedWorkoutMode == location
        let isAnimating = selectedLocationOption == location && animatingSelection
        
        return Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                selectedLocationOption = location
                animatingSelection = true
            }
            
            // Efecto de vibración haptic
            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
            impactFeedback.impactOccurred()
            
            // Animación de selección
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.easeInOut(duration: 0.2)) {
                    viewModel.selectedWorkoutMode = location
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        showLocationMenu = false
                        animatingSelection = false
                        selectedLocationOption = nil
                    }
                }
            }
        }) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.yellow)
                    .font(.title3)
                    .scaleEffect(isAnimating ? 1.3 : 1.0)
                    .rotationEffect(.degrees(isAnimating ? 360 : 0))
                    .animation(.spring(response: 0.4, dampingFraction: 0.6), value: isAnimating)
                
                Text(title)
                    .foregroundColor(.yellow)
                    .fontWeight(.semibold)
                    .scaleEffect(isAnimating ? 1.1 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isAnimating)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundColor(.yellow)
                        .scaleEffect(isAnimating ? 1.2 : 1.0)
                        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isAnimating)
                }
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.white.opacity(isAnimating ? 0.15 : 0.05))
                    .scaleEffect(isAnimating ? 1.05 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isAnimating)
            )
        }
        .scaleEffect(isAnimating ? 1.02 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isAnimating)
    }
}

struct WorkoutView_Previews: PreviewProvider {
    static var previews: some View {
        WorkoutView()
            .preferredColorScheme(.dark)
    }
}
