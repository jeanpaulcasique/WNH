import SwiftUI

// MARK: - GroceryListSheetView Simple con Contador

struct GroceryListSheetView: View {
    @ObservedObject var vm: DietViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showOnlyUnchecked = false
    
    // Filtrar ingredientes según el toggle
    private var filteredIngredients: [Ingredient] {
        if showOnlyUnchecked {
            return vm.groceryList.filter { !$0.isChecked }
        } else {
            return vm.groceryList
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                if vm.groceryList.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "cart")
                            .font(.system(size: 60))
                            .foregroundColor(.yellow.opacity(0.6))
                        
                        Text("No hay ingredientes")
                            .font(.title2)
                            .foregroundColor(.white.opacity(0.8))
                        
                        Text("Selecciona recetas para generar tu lista de compras")
                            .font(.body)
                            .foregroundColor(.white.opacity(0.6))
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    VStack(spacing: 0) {
                        // Contador simple
                        counterSection
                        
                        // Controles superiores
                        controlsSection
                        
                        // Lista de ingredientes
                        List {
                            ForEach(filteredIngredients) { ingredient in
                                ingredientRow(ingredient: ingredient)
                                    .id("\(ingredient.name)-\(ingredient.isChecked)")
                            }
                        }
                        .listStyle(PlainListStyle())
                        .scrollContentBackground(.hidden)
                    }
                }
            }
            .background(Color.black.ignoresSafeArea())
            .navigationTitle("Lista de Compras")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cerrar") {
                        dismiss()
                    }
                    .foregroundColor(.yellow)
                }
                
                if !vm.groceryList.isEmpty {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        ShareLink(item: vm.groceryListText) {
                            Image(systemName: "square.and.arrow.up")
                                .foregroundColor(.yellow)
                        }
                    }
                }
            }
        }
        .preferredColorScheme(.dark)
    }
    
    // MARK: - Contador Simple
    
    private var counterSection: some View {
        HStack {
            Text("Total: \(vm.groceryListTotalCount) items")
                .font(.headline)
                .foregroundColor(.white)
            
            Spacer()
            
            Text("Completados: \(vm.groceryListCheckedCount)")
                .font(.subheadline)
                .foregroundColor(.yellow)
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
        .background(Color.black.opacity(0.2))
    }
    
    // MARK: - Controles superiores
    
    private var controlsSection: some View {
        VStack(spacing: 12) {
            // Toggle para mostrar solo no marcados
            HStack {
                Image(systemName: "eye")
                    .foregroundColor(.yellow)
                    .font(.body)
                
                Text("Mostrar solo pendientes")
                    .font(.body)
                    .foregroundColor(.white)
                
                Spacer()
                
                Toggle("", isOn: $showOnlyUnchecked)
                    .tint(.yellow)
                    .scaleEffect(0.8)
            }
            .padding(.horizontal)
            
            Divider()
                .background(Color.white.opacity(0.2))
        }
        .padding(.top, 8)
        .padding(.bottom, 8)
        .background(Color.black.opacity(0.3))
    }
    
    // MARK: - Fila de ingrediente
    
    private func ingredientRow(ingredient: Ingredient) -> some View {
        HStack {
            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    vm.toggleCheck(for: ingredient)
                }
            }) {
                Image(systemName: ingredient.isChecked ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundColor(ingredient.isChecked ? .yellow : .white.opacity(0.6))
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(ingredient.name)
                    .font(.body)
                    .foregroundColor(ingredient.isChecked ? .white.opacity(0.6) : .white)
                    .strikethrough(ingredient.isChecked)
                
                Text(ingredient.quantity)
                    .font(.caption)
                    .foregroundColor(.yellow)
            }
            
            Spacer()
            
            // Indicador visual de estado
            if ingredient.isChecked {
                Image(systemName: "checkmark")
                    .font(.caption)
                    .foregroundColor(.yellow.opacity(0.8))
            }
        }
        .padding(.vertical, 6)
        .listRowBackground(Color.clear)
        .opacity(ingredient.isChecked ? 0.7 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: ingredient.isChecked)
    }
}

// MARK: - ShareSheet (helper)

struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
