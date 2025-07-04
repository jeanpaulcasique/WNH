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
    // Estados para animación 3D del personaje
    @State private var rotationAngle: Double = 0
    @State private var characterScale: CGFloat = 1.0
    @State private var isRotating = false
    // Estado global para el rebote de Cardio
    @State private var cardioBounce = false
    
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
                    headerSection
                    SearchBarWorkoutView(
                        viewModel: searchBarVM,
                        onExerciseSelected: { exercise in
                            path = [exercise.name]
                        },
                        onFilterChanged: { _ in },
                        onLocationTapped: { showLocationMenu = true },
                        showSearchResults: $showSearchResults
                    )
                    .padding(.horizontal, 8)
                    .padding(.top, 4)
                    // Scroll horizontal de chips
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(viewModel.muscleGroups, id: \.name) { muscle in
                                Button(action: { path = [muscle.name] }) {
                                    Text(muscle.name.capitalized)
                                        .font(.system(size: 15, weight: .medium))
                                        .foregroundColor(.appYellow)
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 8)
                                        .background(.ultraThinMaterial)
                                        .cornerRadius(8)
                                        .shadow(color: Color.appYellow.opacity(0.08), radius: 4, x: 0, y: 2)
                                }
                            }
                        }
                        .padding(.horizontal, 4)
                        .padding(.vertical, 2)
                    }
                    .padding(.top, 6)
                    .padding(.bottom, 2)
                    if showSearchResults && !searchBarVM.filteredExercises.isEmpty {
                        EmptyView()
                    } else {
                        Spacer(minLength: 0)
                        GeometryReader { geometry in
                            ZStack {
                                character3DViewEpicProtagonist(geometry: geometry)
                                muscleGroupButtonsEpic(geometry: geometry)
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                        .frame(height: 340)
                        Spacer()
                        epicBottomControlsView
                    }
                }
                .screenHorizontalPadding()
                .frame(maxHeight: .infinity, alignment: .top)
                .padding(.vertical, 0)
                .zIndex(1)

                if showLocationMenu {
                    locationMenuOverlay
                        .zIndex(2)
                }
            }
            .navigationBarHidden(true)
            .navigationDestination(for: String.self) { muscleName in
                VideosDashBoardView(
                    selectedMuscleGroup: muscleName,
                    onBack: { path = [] }
                )
            }
            .onAppear { setupView() }
            .onChange(of: viewModel.selectedMuscle) { _, newMuscle in
                if let muscle = newMuscle {
                    path = [muscle.name]
                    selectedMuscleForLabel = nil
                }
            }
            .onChange(of: viewModel.isShowingBack) { _, _ in
                selectedMuscleForLabel = nil
            }
            .onChange(of: viewModel.muscleGroups) { _, newGroups in
                searchBarVM.configure(exercises: viewModel.allExercises, muscleGroups: newGroups)
            }
        }
    }
    
    // Header compacto con saludo y tip
    private var headerSection: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: "figure.strengthtraining.traditional")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.appYellow)
                Text(userName != nil ? "Hi, \(userName!)!" : "Ready to train?")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.appYellow)
                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.top, 12)
            .padding(.bottom, 2)
            ZStack {
                ForEach(0..<workoutTips.count, id: \.self) { i in
                    if i == currentTipIndex {
                        Text(workoutTips[i])
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.appWhite.opacity(0.85))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 12)
                            .lineLimit(2)
                            .minimumScaleFactor(0.85)
                            .id(i)
                            .opacity(animateTip ? 1 : 0)
                            .offset(y: animateTip ? 0 : 30)
                            .animation(.spring(response: 0.7, dampingFraction: 0.7), value: animateTip)
                    }
                }
            }
            .frame(height: 36)
        }
        .background(.ultraThinMaterial)
        .cornerRadius(18)
        .shadow(color: Color.appYellow.opacity(0.08), radius: 8, x: 0, y: 2)
        .padding(.horizontal, 8)
        .padding(.top, 8)
        .padding(.bottom, 4)
    }
    
    // Imagen protagonista épica centrada y un poco más arriba, con ligero ajuste horizontal
    private func character3DViewEpicProtagonist(geometry: GeometryProxy) -> some View {
        ZStack {
            Ellipse()
                .fill(Color.appYellow.opacity(0.13))
                .frame(width: geometry.size.width * 1.20, height: 70)
                .offset(x: -geometry.size.width * 0.08, y: -geometry.size.height * 0.10)
                .blur(radius: 16)
                .scaleEffect(characterScale * 1.0)
                .allowsHitTesting(false)
            Ellipse()
                .fill(Color.black.opacity(0.18))
                .frame(width: geometry.size.width * 1.10, height: 54)
                .offset(x: -geometry.size.width * 0.08, y: -geometry.size.height * 0.09)
                .blur(radius: 14)
                .scaleEffect(characterScale * 1.0)
                .allowsHitTesting(false)
            ZStack {
                Image("human_front")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: geometry.size.width * 1.65, height: geometry.size.height * 1.65)
                    .clipped()
                    .shadow(color: .appYellow.opacity(0.13), radius: 32, x: 0, y: 16)
                    .allowsHitTesting(false)
                    .offset(x: -geometry.size.width * 0.4, y: -geometry.size.height * 0.46)
                    .opacity(viewModel.isShowingBack ? 0.0 : 1.0)
                    .animation(.easeInOut(duration: 0.45), value: viewModel.isShowingBack)
                Image("human_back")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: geometry.size.width * 1.85, height: geometry.size.height * 1.85)
                    .clipped()
                    .shadow(color: .appYellow.opacity(0.13), radius: 32, x: 0, y: 16)
                    .allowsHitTesting(false)
                    .offset(x: -geometry.size.width * 0.4, y: -geometry.size.height * 0.46)
                    .opacity(viewModel.isShowingBack ? 1.0 : 0.0)
                    .animation(.easeInOut(duration: 0.45), value: viewModel.isShowingBack)
            }
            .scaleEffect(characterScale)
            .rotation3DEffect(
                .degrees(rotationAngle),
                axis: (x: 0, y: 1, z: 0),
                perspective: 0.3
            )
            .gesture(characterDragGesture)
            .animation(.spring(response: 0.8, dampingFraction: 0.7), value: rotationAngle)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: characterScale)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }
    
    private var characterDragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                if !isRotating {
                    rotationAngle = value.translation.width * 0.3
                }
            }
            .onEnded { value in
                if abs(value.translation.width) > 80 {
                    withAnimation(.spring(response: 0.8, dampingFraction: 0.7)) {
                        viewModel.toggleView()
                        rotationAngle = 0
                    }
                } else {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                        rotationAngle = 0
                    }
                }
            }
    }

    private func performCharacterRotation() {
        isRotating = true
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            characterScale = 1.1
        }
        withAnimation(.spring(response: 0.8, dampingFraction: 0.7)) {
            rotationAngle += 180
            viewModel.toggleView()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                characterScale = 1.0
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            rotationAngle = 0
            isRotating = false
        }
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }
    
    // MARK: - Epic Muscle Group Buttons
    private func muscleGroupButtonsEpic(geometry: GeometryProxy) -> some View {
        ZStack {
            ForEach(searchBarVM.filteredMuscleGroups, id: \.id) { muscle in
                let position = muscle.position
                let isSelected = selectedMuscleForLabel?.id == muscle.id
                Button(action: {
                    if isSelected {
                        viewModel.selectMuscle(muscle)
                    } else {
                        selectedMuscleForLabel = muscle
                    }
                }) {
                    if muscle.name.lowercased() == "cardio" {
                        VStack(spacing: 4) {
                            Image(systemName: "figure.run")
                                .font(.system(size: isSelected ? 32 : 24, weight: .bold))
                                .foregroundColor(isSelected ? .appYellow : .appYellow.opacity(0.7))
                                .scaleEffect(cardioBounce ? 1.18 : 0.92)
                                .shadow(color: .appYellow.opacity(0.18), radius: isSelected ? 8 : 2, x: 0, y: 1)
                                .onAppear {
                                    withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                                        cardioBounce = true
                                    }
                                }
                            if isSelected {
                                Text(muscle.name)
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(.appYellow)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 5)
                                    .background(Color.black.opacity(0.85))
                                    .cornerRadius(10)
                                    .shadow(color: .appYellow.opacity(0.18), radius: 6, x: 0, y: 2)
                                    .transition(.scale.combined(with: .opacity))
                            }
                        }
                    } else {
                        VStack(spacing: 4) {
                            Circle()
                                .fill(isSelected ? Color.appYellow : Color.appYellow.opacity(0.7))
                                .frame(width: isSelected ? 18 : 13, height: isSelected ? 18 : 13)
                                .shadow(color: isSelected ? .appYellow : .black.opacity(0.3), radius: isSelected ? 8 : 2, x: 0, y: 1)
                                .overlay(
                                    Circle()
                                        .stroke(Color.white.opacity(isSelected ? 0.8 : 0.3), lineWidth: isSelected ? 2 : 1)
                                        .blur(radius: isSelected ? 1 : 0)
                                )
                            if isSelected {
                                Text(muscle.name)
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(.appYellow)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 5)
                                    .background(Color.black.opacity(0.85))
                                    .cornerRadius(10)
                                    .shadow(color: .appYellow.opacity(0.18), radius: 6, x: 0, y: 2)
                                    .transition(.scale.combined(with: .opacity))
                            }
                        }
                    }
                }
                .buttonStyle(PlainButtonStyle())
                .position(x: geometry.size.width * position.x, y: geometry.size.height * position.y)
                .animation(.spring(response: 0.4, dampingFraction: 0.7), value: isSelected)
                .zIndex(10)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: searchBarVM.filteredMuscleGroups)
    }
    
    // MARK: - Epic Bottom Controls
    private var epicBottomControlsView: some View {
        HStack {
            Spacer()
            VStack(spacing: 14) {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.left.and.right")
                        .foregroundColor(.appYellow)
                        .font(.title3)
                    Text("Swipe to rotate")
                        .foregroundColor(.appWhite)
                        .font(.system(size: 15, weight: .medium))
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 18)
                .background(.ultraThinMaterial)
                .cornerRadius(14)
                .shadow(color: Color.appYellow.opacity(0.10), radius: 8, x: 0, y: 2)
                .onTapGesture {
                    viewModel.toggleView()
                }
            }
            Spacer()
        }
        .padding(.bottom, 18)
    }
    
    private var locationMenuOverlay: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            showLocationMenu = false
                        }
                    }
                
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
                    x: geometry.size.width - 60,
                    y: 120
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
            
            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
            impactFeedback.impactOccurred()
            
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
    
    private func setupView() {
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
}

struct WorkoutView_Previews: PreviewProvider {
    static var previews: some View {
        WorkoutView()
            .preferredColorScheme(.dark)
    }
}
