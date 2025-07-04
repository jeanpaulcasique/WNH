import SwiftUI

struct SearchBarWorkoutView: View {
    @ObservedObject var viewModel: SearchBarWorkoutViewModel
    var onExerciseSelected: (Exercise) -> Void
    var onFilterChanged: (String?) -> Void
    var onLocationTapped: () -> Void
    @Binding var showSearchResults: Bool
    
    var body: some View {
        HStack(spacing: 8) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                TextField("Search exercise...", text: $viewModel.searchText, onEditingChanged: { editing in
                    withAnimation {
                        showSearchResults = editing || !viewModel.searchText.isEmpty
                    }
                    onFilterChanged(viewModel.searchText.isEmpty ? nil : viewModel.searchText)
                })
                .foregroundColor(.white)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                if !viewModel.searchText.isEmpty {
                    Button(action: {
                        viewModel.searchText = ""
                        withAnimation { showSearchResults = false }
                        onFilterChanged(nil)
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(10)
            .background(Color.white.opacity(0.08))
            .cornerRadius(12)
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
                            onFilterChanged(nil)
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
} 
