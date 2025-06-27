import SwiftUI

// MARK: - GroceryListSheetView Simple con Contador

struct GroceryListSheetView: View {
    @ObservedObject var vm: DietViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showOnlyUnchecked = false
    @State private var expandedCategories: [GroceryListViewModel.GroceryCategory: Bool] = [:]
    
    // Filtrar ingredientes según el toggle
    private var filteredIngredients: [Ingredient] {
        if showOnlyUnchecked {
            return vm.groceryList.filter { !$0.isChecked }
        } else {
            return vm.groceryList
        }
    }
    
    // Categorías presentes en la lista, para evitar cálculos en el body
    private var presentCategories: [GroceryListViewModel.GroceryCategory] {
        GroceryListViewModel.GroceryCategory.allCases.filter { vm.groceryListViewModel.groceryListByCategory[$0]?.isEmpty == false }
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
                        counterSection
                        controlsSection
                        // Lista agrupada por categorías
                        List {
                            ForEach(presentCategories, id: \.self) { category in
                                categorySection(for: category)
                            }
                        }
                        .listStyle(InsetGroupedListStyle())
                        .scrollContentBackground(.hidden)
                        .animation(.easeInOut(duration: 0.3), value: vm.groceryListViewModel.groceryListByCategory)
                    }
                }
            }
            .background(Color.black.ignoresSafeArea())
            .navigationTitle("Lista de Compras")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    HStack {
                        Button("Cerrar") {
                            dismiss()
                        }
                        .foregroundColor(.yellow)
                        Button("Reset") {
                            vm.groceryListViewModel.clearAllChecked()
                        }
                        .foregroundColor(.yellow)
                    }
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
    
    // Iconos para cada categoría
    private func iconForCategory(_ category: GroceryListViewModel.GroceryCategory) -> String {
        switch category {
        case .vegetales: return "leaf"
        case .frutas: return "applelogo"
        case .proteinas: return "takeoutbag.and.cup.and.straw.fill"
        case .lacteos: return "carton.fill"
        case .granos: return "bag.fill"
        case .legumbres: return "leaf.circle"
        case .frutosSecos: return "circle.hexagongrid.fill"
        case .aceites: return "drop.fill"
        case .condimentos: return "pills.fill"
        case .otros: return "questionmark.circle"
        }
    }
    
    // MARK: - Sección de categoría
    private func categorySection(for category: GroceryListViewModel.GroceryCategory) -> some View {
        guard let items = vm.groceryListViewModel.groceryListByCategory[category] else { return AnyView(EmptyView()) }
        let isExpanded = expandedCategories[category] ?? true
        return AnyView(
            Section(header:
                Button(action: {
                    withAnimation(.easeInOut) {
                        expandedCategories[category] = !(expandedCategories[category] ?? true)
                    }
                }) {
                    HStack {
                        Image(systemName: iconForCategory(category))
                            .foregroundColor(category.color)
                        Text(category.rawValue)
                            .font(.headline)
                            .foregroundColor(category.color)
                        Spacer()
                        Image(systemName: "chevron.down")
                            .rotationEffect(.degrees(isExpanded ? 0 : -90))
                            .foregroundColor(.white.opacity(0.7))
                            .animation(.easeInOut, value: isExpanded)
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.vertical, 4)
            ) {
                if isExpanded {
                    ForEach(items.filter { !showOnlyUnchecked || !$0.isChecked }.sorted { $0.name < $1.name }) { ingredient in
                        ingredientRow(ingredient: ingredient)
                            .id("\(ingredient.name)-\(ingredient.isChecked)")
                    }
                }
            }
        )
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
