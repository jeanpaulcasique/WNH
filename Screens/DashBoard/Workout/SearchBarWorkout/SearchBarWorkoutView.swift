import SwiftUI

struct SearchBarWorkoutView: View {
    @ObservedObject var viewModel: SearchBarWorkoutViewModel
    var onExerciseSelected: (Exercise) -> Void
    var onFilterChanged: (String?) -> Void
    var onLocationTapped: () -> Void
    @Binding var showSearchResults: Bool
    @State private var showFullSearch = false
    
    var body: some View {
        HStack(spacing: 8) {
            // Barra de búsqueda que abre la página completa
            Button(action: {
                showFullSearch = true
            }) {
                HStack(spacing: 6) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    Text("Search exercise...")
                        .foregroundColor(.gray)
                        .font(.system(size: 16))
                    Spacer()
                }
                .padding(.vertical, 10)
                .padding(.leading, 10)
                .background(Color.white.opacity(0.08))
                .cornerRadius(12)
            }
            .buttonStyle(PlainButtonStyle())
            
            Button(action: onLocationTapped) {
                Image(systemName: "location.fill")
                    .font(.title2)
                    .foregroundColor(.yellow)
                    .padding(8)
                    .background(Color.black.opacity(0.7))
                    .clipShape(Circle())
            }
            .padding(.leading, 4)
        }
        .fullScreenCover(isPresented: $showFullSearch) {
            FullSearchView(
                viewModel: viewModel,
                onExerciseSelected: onExerciseSelected,
                onFilterChanged: onFilterChanged
            )
        }
    }
}

// MARK: - Full Search View
struct FullSearchView: View {
    @ObservedObject var viewModel: SearchBarWorkoutViewModel
    var onExerciseSelected: (Exercise) -> Void
    var onFilterChanged: (String?) -> Void
    @Environment(\.presentationMode) var presentationMode
    @State private var searchText = ""
    @FocusState private var isSearchFocused: Bool
    
    var body: some View {
        NavigationView {
            ZStack {
                // Fondo
                Color.black.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header de búsqueda
                    searchHeader
                    
                    // Resultados
                    searchResults
                }
            }
            .navigationBarHidden(true)
        }
        .onAppear {
            isSearchFocused = true
        }
    }
    
    private var searchHeader: some View {
        VStack(spacing: 16) {
            // Barra de navegación
            HStack {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.white)
                        .frame(width: 40, height: 40)
                        .background(Color.gray.opacity(0.3))
                        .clipShape(Circle())
                }
                
                Spacer()
                
                Text("All Exercises")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                
                Spacer()
                
                if !searchText.isEmpty {
                    Button(action: {
                        searchText = ""
                        viewModel.searchText = ""
                    }) {
                        Text("Clear")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.yellow)
                    }
                } else {
                    Color.clear
                        .frame(width: 40, height: 40)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
            
            // Barra de búsqueda
            HStack(spacing: 12) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                    .font(.system(size: 18))
                
                TextField("Search exercises, muscles, equipment...", text: $searchText)
                    .font(.system(size: 16))
                    .foregroundColor(.white)
                    .focused($isSearchFocused)
                    .onChange(of: searchText) { newValue in
                        viewModel.searchText = newValue
                        onFilterChanged(newValue.isEmpty ? nil : newValue)
                    }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(Color.gray.opacity(0.2))
            .cornerRadius(12)
            .padding(.horizontal, 20)
        }
        .padding(.bottom, 20)
    }
    
    private var searchResults: some View {
        Group {
            if searchText.isEmpty {
                allExercisesGrid
            } else if viewModel.filteredExercises.isEmpty {
                noResultsState
            } else {
                filteredExercisesGrid
            }
        }
    }
    
    private var allExercisesGrid: some View {
        ScrollView {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 2), spacing: 16) {
                ForEach(viewModel.allExercises, id: \.id) { exercise in
                    ExerciseCard(
                        exercise: exercise,
                        onExerciseSelected: onExerciseSelected,
                        onDismiss: {
                            presentationMode.wrappedValue.dismiss()
                        }
                    )
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 100)
        }
    }
    
    private var filteredExercisesGrid: some View {
        ScrollView {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 2), spacing: 16) {
                ForEach(viewModel.filteredExercises, id: \.id) { exercise in
                    ExerciseCard(
                        exercise: exercise,
                        onExerciseSelected: onExerciseSelected,
                        onDismiss: {
                            presentationMode.wrappedValue.dismiss()
                        }
                    )
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 100)
        }
    }
    
    private var noResultsState: some View {
        VStack(spacing: 20) {
            Image(systemName: "questionmark.folder")
                .font(.system(size: 60))
                .foregroundColor(.gray.opacity(0.5))
            
            VStack(spacing: 8) {
                Text("No Results Found")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(.white)
                
                Text("Try different keywords or check your spelling")
                    .font(.system(size: 16))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Exercise Card
struct ExerciseCard: View {
    let exercise: Exercise
    var onExerciseSelected: (Exercise) -> Void
    var onDismiss: () -> Void
    
    var body: some View {
        Button(action: {
            onExerciseSelected(exercise)
            onDismiss()
        }) {
            VStack(spacing: 12) {
                // Icono del ejercicio
                ZStack {
                    Circle()
                        .fill(Color.yellow.opacity(0.2))
                        .frame(width: 60, height: 60)
                    Image(systemName: "dumbbell.fill")
                        .foregroundColor(.yellow)
                        .font(.system(size: 24, weight: .medium))
                }
                
                // Información del ejercicio
                VStack(spacing: 4) {
                    Text(exercise.name)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                    
                    let muscleGroupsText = exercise.muscleGroups.joined(separator: ", ")
                    Text(muscleGroupsText)
                        .font(.system(size: 11))
                        .foregroundColor(.gray)
                        .lineLimit(1)
                        .multilineTextAlignment(.center)
                    
                    if !exercise.equipment.isEmpty {
                        let equipmentText = exercise.equipment.joined(separator: ", ")
                        Text(equipmentText)
                            .font(.system(size: 10))
                            .foregroundColor(.gray.opacity(0.8))
                            .lineLimit(1)
                            .multilineTextAlignment(.center)
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.yellow.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
} 
