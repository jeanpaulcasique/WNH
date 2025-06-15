import SwiftUI
import Combine

// MARK: - Main View
struct WorkoutView: View {
    @StateObject private var viewModel = WorkoutViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                LinearGradient(
                    colors: [Color.black, Color.gray.opacity(0.3), Color.black],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    headerView
                    
                    // Menú desplegable de modalidades
                    HStack {
                        Spacer()
                        Menu {
                            Button(action: { viewModel.selectedWorkoutMode = .atHome }) {
                                Label("At Home", systemImage: "house.fill")
                            }
                            Button(action: { viewModel.selectedWorkoutMode = .atGym }) {
                                Label("At Gym", systemImage: "dumbbell.fill")
                            }
                            Button(action: { viewModel.selectedWorkoutMode = .outdoors }) {
                                Label("Outdoors", systemImage: "leaf.fill")
                            }
                        } label: {
                            Image(systemName: "location.fill")
                                .font(.title2)
                                .foregroundColor(.yellow)
                                .padding()
                                .background(Color.black.opacity(0.7))
                                .clipShape(Circle())
                        }
                        .padding()
                    }
                    
                    Spacer()
                    
                    // Main anatomy view
                    GeometryReader { geometry in
                        ZStack {
                            // Human figure (placeholder - you would replace with actual image)
                            humanFigureView(geometry: geometry)
                            
                            // Muscle group buttons
                            muscleGroupButtons(geometry: geometry)
                        }
                    }
                    .aspectRatio(0.6, contentMode: .fit)
                    
                    Spacer()
                    
                    // Bottom controls
                    bottomControlsView
                    
                }
                .padding()
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $viewModel.showingExerciseDetail) {
            if let muscleGroup = viewModel.selectedMuscleGroup {
                ExerciseDetailView(muscleGroup: muscleGroup)
            }
        }
    }
    
    // MARK: - Header
    private var headerView: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Exercises")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            
            Spacer()
        }
    }
    
    // MARK: - Human Figure
    private func humanFigureView(geometry: GeometryProxy) -> some View {
        ZStack {
            // Front image
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
            
            // Back image
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
    
    // MARK: - Muscle Group Buttons
    private func muscleGroupButtons(geometry: GeometryProxy) -> some View {
        let muscleGroups = viewModel.isShowingBack ? viewModel.backMuscleGroups : viewModel.muscleGroups
        
        return ForEach(muscleGroups, id: \.name) { muscleGroup in
            MuscleGroupButton(
                muscleGroup: muscleGroup,
                geometry: geometry
            ) {
                viewModel.selectMuscleGroup(muscleGroup)
            }
        }
    }
    
    // MARK: - Bottom Controls
    private var bottomControlsView: some View {
        VStack(spacing: 20) {
            // Rotation control
            HStack {
                Image(systemName: "arrow.left.and.right")
                    .foregroundColor(.yellow)
                Text("Swipe")
                    .foregroundColor(.white)
                Text("180°")
                    .foregroundColor(.yellow)
                    .font(.title2)
                    .fontWeight(.bold)
            }
            .padding()
            
            .background(Color.white.opacity(0.1))
            .cornerRadius(12)
            .onTapGesture {
                viewModel.toggleView()
            }
        }.padding(.bottom, -30)
    }
}
    

// MARK: - Preview
struct WorkoutView_Previews: PreviewProvider {
    static var previews: some View {
        WorkoutView()
            .preferredColorScheme(.dark)
    }
}
