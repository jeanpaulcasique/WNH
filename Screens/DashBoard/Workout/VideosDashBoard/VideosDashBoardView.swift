import SwiftUI

struct VideosDashBoardView: View {
    let selectedMuscleGroup: String
    var onBack: (() -> Void)? = nil
    @State private var currentMuscle: MuscleGroup
    @State private var selectedVideoIndex: Int? = nil
    
    // Mock data con tu estructura actual
    let mockExercises: [(String, String)] = [
        ("Bending to the sides", "1:36 min"),
        ("Jump squats", "2:10 min"),
        ("Mountain climbers", "2:45 min"),
        ("Burpees", "1:20 min")
    ]
    
    // Mock videos para navegación
    var mockVideos: [ExerciseVideo] {
        mockExercises.enumerated().map { index, exercise in
            ExerciseVideo(
                id: "\(index)",
                title: exercise.0,
                description: "Great exercise for \(currentMuscle.name.lowercased())",
                videoURL: "https://www.w3schools.com/html/mov_bbb.mp4",
                thumbnailURL: "",
                duration: 150,
                difficulty: .intermediate,
                location: .atHome,
                muscleGroup: currentMuscle.name,
                equipment: nil,
                calories: 120,
                instructions: ["Step 1", "Step 2"]
            )
        }
    }
    
    // ✅ Inicializador que recibe el músculo seleccionado
    init(selectedMuscleGroup: String, onBack: (() -> Void)? = nil) {
        self.selectedMuscleGroup = selectedMuscleGroup
        self.onBack = onBack
        // Crear el MuscleGroup basado en el nombre
        _currentMuscle = State(initialValue: MuscleGroup(
            name: selectedMuscleGroup,
            exercises: [],
            position: .zero,
            isLeftSide: false
        ))
    }
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            LinearGradient(
                colors: [Color.black, Color.gray.opacity(0.3), Color.black],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 0) {
                        // Imagen principal con información superpuesta
                        ZStack {
                            Rectangle()
                                .fill(LinearGradient(
                                    colors: [Color.gray.opacity(0.4), Color.gray.opacity(0.2)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ))
                                .frame(height: 400)
                            
                            Image(systemName: "figure.strengthtraining.traditional")
                                .font(.system(size: 120))
                                .foregroundColor(.yellow.opacity(0.8))
                            
                            // Botón back superpuesto
                            VStack {
                                HStack {
                                    Button(action: {
                                        onBack?()
                                    }) {
                                        Image(systemName: "chevron.left")
                                            .font(.title2)
                                            .foregroundColor(.yellow)
                                            .padding()
                                    }
                                    Spacer()
                                }
                                .padding(.top, 44)
                                Spacer()
                            }
                            
                            // Tarjeta de información superpuesta
                            VStack {
                                Spacer()
                                VStack(alignment: .leading, spacing: 16) {
                                    Text("\(LanguageManager.localizedString(currentMuscle.name)) \(LanguageManager.localizedString("workout"))")
                                        .font(.title)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                    
                                    Text("\(LanguageManager.localizedString("A complete")) \(LanguageManager.localizedString(currentMuscle.name).lowercased()) \(LanguageManager.localizedString("workout routine designed to strengthen and tone your muscles effectively."))")
                                        .font(.body)
                                        .foregroundColor(.white.opacity(0.8))
                                        .lineLimit(nil)
                                    
                                    HStack(spacing: 16) {
                                        // Calorías badge
                                        HStack(spacing: 8) {
                                            Image(systemName: "flame.fill")
                                                .foregroundColor(.yellow)
                                            Text("345 Kcal")
                                                .fontWeight(.semibold)
                                                .foregroundColor(.white)
                                        }
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(Color.white.opacity(0.1))
                                        .cornerRadius(20)
                                        
                                        // Tiempo badge
                                        HStack(spacing: 8) {
                                            Image(systemName: "clock.fill")
                                                .foregroundColor(.yellow)
                                            Text("30 min")
                                                .fontWeight(.semibold)
                                                .foregroundColor(.white)
                                        }
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(Color.white.opacity(0.1))
                                        .cornerRadius(20)
                                        
                                        Spacer()
                                    }
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 24)
                                .background(
                                    LinearGradient(
                                        colors: [Color.clear, Color.black.opacity(0.8)],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                            }
                        }
                        
                        // Lista de ejercicios
                        VStack(spacing: 12) {
                            ForEach(Array(mockExercises.enumerated()), id: \.offset) { index, exercise in
                                let (name, duration) = exercise
                                Button(action: {
                                    selectedVideoIndex = index
                                }) {
                                    HStack(spacing: 16) {
                                        // Thumbnail del video
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(Color.white.opacity(0.1))
                                                .frame(width: 60, height: 60)
                                            
                                            Image(systemName: "play.circle.fill")
                                                .font(.system(size: 24))
                                                .foregroundColor(.yellow)
                                        }
                                        
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(name)
                                                .font(.headline)
                                                .foregroundColor(.white)
                                            Text(duration)
                                                .font(.subheadline)
                                                .foregroundColor(.white.opacity(0.7))
                                        }
                                        
                                        Spacer()
                                        
                                        // Play button (visual only)
                                        Circle()
                                            .stroke(Color.yellow, lineWidth: 2)
                                            .frame(width: 40, height: 40)
                                            .overlay(
                                                Image(systemName: "play.fill")
                                                    .font(.system(size: 14))
                                                    .foregroundColor(.yellow)
                                            )
                                    }
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 12)
                                    .background(Color.white.opacity(0.05))
                                    .cornerRadius(16)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 8)
                    }
                }
                
                // Start Workout Button
                Button(action: {
                    selectedVideoIndex = 0
                }) {
                    HStack(spacing: 12) {
                        Image(systemName: "play.fill")
                            .font(.title2)
                        Text("Start Workout")
                            .font(.headline)
                            .fontWeight(.bold)
                    }
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.yellow)
                    .cornerRadius(24)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 0)
                
                // NavigationLink invisible
                NavigationLink(
                    destination: Group {
                        if let index = selectedVideoIndex {
                            VideoMuscleView(videos: mockVideos, initialIndex: index)
                        } else {
                            EmptyView()
                        }
                    },
                    isActive: Binding(
                        get: { selectedVideoIndex != nil },
                        set: { if !$0 { selectedVideoIndex = nil } }
                    )
                ) {
                    EmptyView()
                }
                .hidden()
            }
        }
        .navigationBarHidden(true)
    }
}
