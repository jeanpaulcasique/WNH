import SwiftUI

struct SearchBarWorkoutView: View {
    @ObservedObject var viewModel: SearchBarWorkoutViewModel
    var onExerciseSelected: (Exercise) -> Void
    var onFilterChanged: (String?) -> Void
    var onLocationTapped: () -> Void
    @Binding var showSearchResults: Bool
    
    @State private var showMuscleFilter: Bool = false
    
    var body: some View {
        HStack(spacing: 8) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                TextField("Buscar ejercicio...", text: $viewModel.searchText, onEditingChanged: { editing in
                    withAnimation {
                        showSearchResults = editing || !viewModel.searchText.isEmpty
                    }
                })
                .foregroundColor(.white)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                if !viewModel.searchText.isEmpty {
                    Button(action: {
                        viewModel.searchText = ""
                        withAnimation { showSearchResults = false }
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(10)
            .background(Color.white.opacity(0.08))
            .cornerRadius(12)
            // Filtro de músculo
            Button(action: { showMuscleFilter = true }) {
                Image(systemName: "line.3.horizontal.decrease.circle")
                    .font(.title2)
                    .foregroundColor(viewModel.selectedMuscleFilter == nil ? .gray : .yellow)
                    .padding(8)
                    .background(Color.white.opacity(0.08))
                    .clipShape(Circle())
            }
            .sheet(isPresented: $showMuscleFilter) {
                muscleFilterSheet
            }
            // Icono de localización - solo botón, sin menú
            Button(action: onLocationTapped) {
                Image(systemName: "location.fill")
                    .font(.title2)
                    .foregroundColor(.yellow)
                    .padding(8)
                    .background(Color.black.opacity(0.7))
                    .clipShape(Circle())
            }
        }
        .padding(.vertical, 8)
        // Resultados de búsqueda
        if showSearchResults && !viewModel.filteredExercises.isEmpty {
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(viewModel.filteredExercises) { exercise in
                        Button(action: {
                            onExerciseSelected(exercise)
                            showSearchResults = false
                            viewModel.searchText = ""
                        }) {
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(exercise.name)
                                        .foregroundColor(.white)
                                        .font(.headline)
                                    Text(exercise.duration)
                                        .foregroundColor(.yellow)
                                        .font(.caption)
                                    Text(exercise.difficulty)
                                        .foregroundColor(.gray)
                                        .font(.caption2)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                            }
                            .padding(.vertical, 10)
                            .padding(.horizontal, 8)
                            .background(Color.white.opacity(0.03))
                            .cornerRadius(8)
                        }
                        .padding(.vertical, 2)
                    }
                }
                .padding(.top, 8)
            }
            .background(Color.black.opacity(0.7))
            .cornerRadius(16)
            .padding(.bottom, 8)
        }
    }
    
    private var muscleFilterSheet: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                VStack(spacing: 0) {
                    Button(action: {
                        viewModel.clearMuscleFilter()
                        showMuscleFilter = false
                        onFilterChanged(nil)
                    }) {
                        HStack {
                            Image(systemName: "circle.fill")
                                .foregroundColor(viewModel.selectedMuscleFilter == nil ? .yellow : .gray)
                                .font(.system(size: 18))
                            Text("Todos los músculos")
                                .foregroundColor(viewModel.selectedMuscleFilter == nil ? .yellow : .white)
                                .fontWeight(.semibold)
                            Spacer()
                        }
                        .padding(.vertical, 14)
                        .padding(.horizontal, 18)
                        .background(Color.white.opacity(0.04))
                        .cornerRadius(10)
                    }
                    .padding(.top, 12)
                    ScrollView {
                        VStack(spacing: 0) {
                            ForEach(Array(Set(viewModel.allMuscleGroups.map { $0.name })).sorted(), id: \ .self) { muscle in
                                Button(action: {
                                    viewModel.selectedMuscleFilter = muscle
                                    showMuscleFilter = false
                                    onFilterChanged(muscle)
                                }) {
                                    HStack {
                                        Image(systemName: viewModel.selectedMuscleFilter == muscle ? "circle.fill" : "circle")
                                            .foregroundColor(viewModel.selectedMuscleFilter == muscle ? .yellow : .gray)
                                            .font(.system(size: 18))
                                        Text(muscle)
                                            .foregroundColor(viewModel.selectedMuscleFilter == muscle ? .yellow : .white)
                                            .fontWeight(viewModel.selectedMuscleFilter == muscle ? .semibold : .regular)
                                        Spacer()
                                    }
                                    .padding(.vertical, 14)
                                    .padding(.horizontal, 18)
                                    .background(Color.white.opacity(viewModel.selectedMuscleFilter == muscle ? 0.08 : 0.02))
                                    .cornerRadius(10)
                                }
                                .padding(.vertical, 2)
                            }
                        }
                    }
                    .padding(.top, 8)
                    Spacer()
                }
                .padding(.horizontal, 8)
            }
            .navigationTitle("Filtrar por músculo")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cerrar") { showMuscleFilter = false }
                        .foregroundColor(.yellow)
                }
            }
        }
        .preferredColorScheme(.dark)
    }
} 