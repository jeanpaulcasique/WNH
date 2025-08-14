import SwiftUI
import UIKit

// MARK: - GroceryListSheetView2 Simple con Contador

struct GroceryListSheetView2: View {
    @ObservedObject var groceryListViewModel: GroceryListViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showOnlyUnchecked = false
    @State private var resetTrigger: Int = 0
    @State private var showResetToast = false
    @State private var showFloatingButtonText = true
    @State private var isOfflineMode = false
    
    // Filtrar ingredientes según el toggle
    private var filteredIngredients: [Ingredient] {
        groceryListViewModel.getFilteredIngredientsForAll(showOnlyUnchecked: showOnlyUnchecked)
    }
    
    // Categorías presentes en la lista, para evitar cálculos en el body
    private var presentCategories: [GroceryListViewModel.GroceryCategory] {
        groceryListViewModel.presentCategories(showOnlyUnchecked: showOnlyUnchecked)
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                topCardSection
                if !groceryListViewModel.groceryList.isEmpty {
                    glovoPromoBanner
                }
                if groceryListViewModel.groceryList.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "cart")
                            .font(.system(size: 60))
                            .foregroundColor(.yellow.opacity(0.6))
                        Text("No ingredients")
                            .font(.title2)
                            .foregroundColor(.white.opacity(0.8))
                        Text("Select recipes to generate your shopping list")
                            .font(.body)
                            .foregroundColor(.white.opacity(0.6))
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    VStack(spacing: 0) {
                        GroceryListScrollView(presentCategories: presentCategories, resetTrigger: resetTrigger, showOnlyUnchecked: showOnlyUnchecked, groceryListViewModel: groceryListViewModel)
                    }
                }
            }
            .background(
                LinearGradient(
                    colors: [Color.appBlack, Color.gray.opacity(0.3), Color.appBlack],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
            )
            .onAppear {
                isOfflineMode = groceryListViewModel.checkOfflineMode()
            }
            .overlay(
                Group {
                    if !groceryListViewModel.groceryList.isEmpty {
                        glovoFloatingButton
                            .padding(.trailing, 20)
                            .padding(.bottom, 100)
                    }
                },
                alignment: .bottomTrailing
            )
            .navigationBarHidden(true)
        }
        .preferredColorScheme(.dark)
    }
    
    // MARK: - Glovo Logo Component
    private var glovoLogo: some View {
        ZStack {
            Circle()
                .fill(Color.yellow)
                .frame(width: 44, height: 44)
            
            Image(systemName: "cart.fill")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.green)
        }
    }
    
    // MARK: - Glovo Promo Banner
    private var glovoPromoBanner: some View {
        HStack(spacing: 12) {
            // Logo de Glovo real
            glovoLogo
                .frame(width: 44, height: 44)
            
            VStack(alignment: .leading, spacing: 3) {
                Text("Get groceries delivered")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.green)
                Text("Order via Glovo in minutes")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.black)
            }
            
            Spacer()
            
            Button("Order Now") {
                openGlovoApp()
            }
            .font(.system(size: 14, weight: .semibold))
            .foregroundColor(.black)
            .padding(.horizontal, 18)
            .padding(.vertical, 10)
            .background(Color.green)
            .cornerRadius(22)
            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        }
        .padding(18)
        .background(Color.yellow)
        .cornerRadius(18)
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color.green.opacity(0.3), lineWidth: 1)
        )
        .shadow(color: .yellow.opacity(0.3), radius: 8, x: 0, y: 4)
        .padding(.horizontal, 24)
        .padding(.vertical, 12)
    }
    
    // MARK: - Glovo Floating Button
    private var glovoFloatingButton: some View {
        Button(action: {
            openGlovoApp()
        }) {
            HStack(spacing: showFloatingButtonText ? 8 : 0) {
                glovoLogo
                    .frame(width: 24, height: 24)
                
                if showFloatingButtonText {
                    Text("Order via Glovo")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.green)
                        .transition(.opacity.combined(with: .scale))
                }
            }
            .padding(.horizontal, showFloatingButtonText ? 16 : 12)
            .padding(.vertical, showFloatingButtonText ? 12 : 12)
            .background(Color.yellow)
            .cornerRadius(showFloatingButtonText ? 25 : 20)
            .overlay(
                RoundedRectangle(cornerRadius: showFloatingButtonText ? 25 : 20)
                    .stroke(Color.green.opacity(0.3), lineWidth: 1)
            )
            .shadow(color: .yellow.opacity(0.3), radius: 8, x: 0, y: 4)
        }
        .animation(.easeInOut(duration: 0.3), value: showFloatingButtonText)
        .onAppear {
            // Ocultar el texto después de 5 segundos
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                withAnimation(.easeInOut(duration: 0.3).speed(1.2)) {
                    showFloatingButtonText = false
                }
            }
        }
    }
    
    // MARK: - Glovo App Integration
    private func openGlovoApp() {
        // Intentar abrir Glovo app
        if let glovoURL = URL(string: "glovo://") {
            if UIApplication.shared.canOpenURL(glovoURL) {
                UIApplication.shared.open(glovoURL)
            } else {
                // Abrir App Store si no está instalado
                if let appStoreURL = URL(string: "https://apps.apple.com/app/glovo/id740189189") {
                    UIApplication.shared.open(appStoreURL)
                }
            }
        }
    }
    
    // MARK: - Card superior moderna
    private var topCardSection: some View {
        VStack(spacing: 14) {
            HStack {
                Image(systemName: "cart.fill")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.appYellow)
                Text("Shopping List")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.appWhite)
                Spacer()
                HStack(spacing: 8) {
                    // Offline indicator
                    if isOfflineMode {
                        Image(systemName: "wifi.slash")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.orange)
                            .padding(4)
                            .background(Color.orange.opacity(0.2))
                            .clipShape(Circle())
                    }
                    
                    Button(action: {
                        groceryListViewModel.clearAllChecked()
                        resetTrigger += 1
                        showResetToast = true
                        HapticManager.shared.impact(style: .heavy)
                    }) {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.appYellow)
                            .padding(8)
                            .background(Color.gray.opacity(0.15))
                            .clipShape(Circle())
                    }
                }
            }
            HStack(spacing: 12) {
                Label("\(groceryListViewModel.totalCount) items", systemImage: "list.bullet")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.appWhite)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.gray.opacity(0.18))
                    .cornerRadius(12)
                Label("\(groceryListViewModel.checkedCount) completed", systemImage: "checkmark.circle.fill")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.appYellow)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.appYellow.opacity(0.13))
                    .cornerRadius(12)
                Spacer()
                if !groceryListViewModel.groceryList.isEmpty {
                    let text = groceryListViewModel.groceryListText(for: "General")
                    ShareLink(item: text) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.appYellow)
                            .padding(8)
                            .background(Color.gray.opacity(0.15))
                            .clipShape(Circle())
                    }
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 18)
        .background(Color.gray.opacity(0.10))
        .cornerRadius(20)
        .shadow(color: Color.appYellow.opacity(0.08), radius: 8, x: 0, y: 4)
        .padding(.horizontal, 12)
        .padding(.top, 8)
        .padding(.bottom, 8)
        .overlay(
            Group {
                if showResetToast {
                                            ToastView(message: "List reset")
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .zIndex(2)
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                withAnimation { showResetToast = false }
                            }
                        }
                }
            }, alignment: .top
        )
    }
    
    // MARK: - Fila de ingrediente optimizada
    private func ingredientRow(ingredient: Ingredient) -> some View {
        HStack(spacing: 12) {
            Button(action: {
                withAnimation(.interpolatingSpring(stiffness: 300, damping: 15)) {
                    groceryListViewModel.toggleCheck(for: ingredient)
                    HapticManager.shared.impact(style: .medium)
                }
            }) {
                ZStack {
                    Circle()
                        .fill(ingredient.isChecked ? Color.appYellow.opacity(0.18) : Color.gray.opacity(0.13))
                        .frame(width: 28, height: 28)
                    Image(systemName: ingredient.isChecked ? "checkmark.circle.fill" : "circle")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(ingredient.isChecked ? .appYellow : .appWhite.opacity(0.6))
                        .scaleEffect(ingredient.isChecked ? 1.18 : 1.0)
                        .animation(.spring(response: 0.25, dampingFraction: 0.5), value: ingredient.isChecked)
                }
            }
            .buttonStyle(PlainButtonStyle())
            VStack(alignment: .leading, spacing: 2) {
                Text(ingredient.name)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(ingredient.isChecked ? .appWhite.opacity(0.6) : .appWhite)
                    .strikethrough(ingredient.isChecked)
                    .lineLimit(1)
                Text(ingredient.quantity)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.appYellow)
                    .lineLimit(1)
            }
            Spacer()
            if ingredient.isChecked {
                Image(systemName: "checkmark")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.appYellow.opacity(0.8))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color.gray.opacity(0.10))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(ingredient.isChecked ? Color.appYellow.opacity(0.4) : Color.gray.opacity(0.15), lineWidth: ingredient.isChecked ? 1.5 : 1)
        )
        .shadow(color: Color.appYellow.opacity(ingredient.isChecked ? 0.10 : 0.04), radius: 4, x: 0, y: 2)
        .opacity(ingredient.isChecked ? 0.7 : 1.0)
        .animation(.easeInOut(duration: 0.15), value: ingredient.isChecked)
        .contentShape(Rectangle())
        .onTapGesture {
            groceryListViewModel.toggleCheck(for: ingredient)
        }
    }
    
    // Iconos para cada categoría
    private func iconForCategory(_ category: GroceryListViewModel.GroceryCategory) -> String {
        switch category {
        case .vegetales: return "leaf"
        case .frutas: return "applelogo"
        case .proteinas: return "takeoutbag.and.cup.and.straw.fill"
        case .lacteos: return "cup.and.saucer.fill"
        case .granos: return "bag.fill"
        case .legumbres: return "leaf.circle"
        case .frutosSecos: return "circle.hexagongrid.fill"
        case .aceites: return "drop.fill"
        case .condimentos: return "pills.fill"
        case .otros: return "questionmark.circle"
        }
    }
    
    // MARK: - Sticky Header Mejorado
    private func stickyCategoryHeader(for category: GroceryListViewModel.GroceryCategory) -> some View {
        let isExpanded = groceryListViewModel.isCategoryExpanded(category)
        let items = groceryListViewModel.getFilteredIngredients(for: category, showOnlyUnchecked: showOnlyUnchecked)
        return HStack {
            ZStack {
                Circle()
                    .fill(Color.appYellow.opacity(0.18))
                    .frame(width: 38, height: 38)
                Image(systemName: iconForCategory(category))
                    .foregroundColor(.appYellow)
                    .font(.system(size: 18, weight: .bold))
            }
            Text(category.rawValue)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.appWhite)
            Spacer()
            Text("\(items.count)")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.appWhite.opacity(0.7))
                .padding(.horizontal, 8)
                .padding(.vertical, 2)
                .background(Color.appYellow.opacity(0.13))
                .cornerRadius(8)
            Image(systemName: "chevron.down")
                .rotationEffect(.degrees(isExpanded ? 0 : -90))
                .foregroundColor(.appWhite.opacity(0.7))
                .font(.system(size: 13, weight: .medium))
                .animation(.easeInOut(duration: 0.2), value: isExpanded)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color.gray.opacity(0.10))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.appYellow.opacity(isExpanded ? 0.4 : 0.15), lineWidth: isExpanded ? 2 : 1)
        )
        .shadow(color: Color.appYellow.opacity(0.10), radius: 6, x: 0, y: 2)
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.2)) {
                groceryListViewModel.toggleCategoryExpansion(category)
            }
        }
    }

    // Contenido de la categoría (solo ingredientes)
    private func categorySectionContent(for category: GroceryListViewModel.GroceryCategory) -> some View {
        let isExpanded = groceryListViewModel.isCategoryExpanded(category)
        let items = groceryListViewModel.getFilteredIngredients(for: category, showOnlyUnchecked: showOnlyUnchecked)
        return Group {
            if isExpanded && !items.isEmpty {
                LazyVStack(spacing: 4) {
                    ForEach(Array(items.enumerated()), id: \.element.id) { index, ingredient in
                        ingredientRow(ingredient: ingredient)
                            .onAppear {
                                // Preload next items for smooth scrolling
                                if index >= items.count - 3 {
                                    groceryListViewModel.preloadNextItems(for: category, currentIndex: index)
                                }
                            }
                    }
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
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

// MARK: - ToastView
struct ToastView: View {
    let message: String
    var body: some View {
        Text(message)
            .font(.system(size: 15, weight: .semibold))
            .foregroundColor(.white)
            .padding(.vertical, 10)
            .padding(.horizontal, 24)
            .background(Color.yellow.opacity(0.95))
            .cornerRadius(16)
            .shadow(radius: 8)
            .padding(.top, 60)
    }
}

// MARK: - HapticManager
class HapticManager {
    static let shared = HapticManager()
    private init() {}
    func impact(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
}

// Subvista para ScrollViewReader y LazyVStack
struct GroceryListScrollView: View {
    let presentCategories: [GroceryListViewModel.GroceryCategory]
    let resetTrigger: Int
    let showOnlyUnchecked: Bool
    @ObservedObject var groceryListViewModel: GroceryListViewModel
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 6, pinnedViews: [.sectionHeaders]) {
                    ForEach(presentCategories, id: \.self) { category in
                        Section(header: stickyCategoryHeader(for: category)) {
                            categorySectionContent(for: category)
                        }
                    }
                }
            }
            .scrollIndicators(.hidden)
            .id(resetTrigger)
        }
    }
    
    private func stickyCategoryHeader(for category: GroceryListViewModel.GroceryCategory) -> some View {
        let isExpanded = groceryListViewModel.isCategoryExpanded(category)
        let items = groceryListViewModel.getFilteredIngredients(for: category, showOnlyUnchecked: showOnlyUnchecked)
        return HStack {
            ZStack {
                Circle()
                    .fill(Color.appYellow.opacity(0.18))
                    .frame(width: 38, height: 38)
                Image(systemName: iconForCategory(category))
                    .foregroundColor(.appYellow)
                    .font(.system(size: 18, weight: .bold))
            }
            Text(category.rawValue)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.appWhite)
            Spacer()
            Text("\(items.count)")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.appWhite.opacity(0.7))
                .padding(.horizontal, 8)
                .padding(.vertical, 2)
                .background(Color.appYellow.opacity(0.13))
                .cornerRadius(8)
            Image(systemName: "chevron.down")
                .rotationEffect(.degrees(isExpanded ? 0 : -90))
                .foregroundColor(.appWhite.opacity(0.7))
                .font(.system(size: 13, weight: .medium))
                .animation(.easeInOut(duration: 0.2), value: isExpanded)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 10)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [Color.gray.opacity(0.6), Color.gray.opacity(0.2), .clear],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.5
                )
        )
        .shadow(color: Color.gray.opacity(0.15), radius: 8, x: 0, y: 4)
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.2)) {
                groceryListViewModel.toggleCategoryExpansion(category)
            }
        }
    }
    
    private func iconForCategory(_ category: GroceryListViewModel.GroceryCategory) -> String {
        switch category {
        case .vegetales: return "leaf"
        case .frutas: return "applelogo"
        case .proteinas: return "takeoutbag.and.cup.and.straw.fill"
        case .lacteos: return "cup.and.saucer.fill"
        case .granos: return "bag.fill"
        case .legumbres: return "leaf.circle"
        case .frutosSecos: return "circle.hexagongrid.fill"
        case .aceites: return "drop.fill"
        case .condimentos: return "pills.fill"
        case .otros: return "questionmark.circle"
        }
    }
    
    private func categorySectionContent(for category: GroceryListViewModel.GroceryCategory) -> some View {
        let isExpanded = groceryListViewModel.isCategoryExpanded(category)
        let items = groceryListViewModel.getFilteredIngredients(for: category, showOnlyUnchecked: showOnlyUnchecked)
        return Group {
            if isExpanded && !items.isEmpty {
                VStack(spacing: 0) {
                    ForEach(items, id: \.id) { ingredient in
                        ingredientRow(ingredient: ingredient)
                    }
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }
    
    private func ingredientRow(ingredient: Ingredient) -> some View {
        HStack(spacing: 12) {
            Button(action: {
                withAnimation(.interpolatingSpring(stiffness: 300, damping: 15)) {
                    groceryListViewModel.toggleCheck(for: ingredient)
                    HapticManager.shared.impact(style: .medium)
                }
            }) {
                ZStack {
                    Circle()
                        .fill(ingredient.isChecked ? Color.appYellow.opacity(0.18) : Color.gray.opacity(0.13))
                        .frame(width: 28, height: 28)
                    Image(systemName: ingredient.isChecked ? "checkmark.circle.fill" : "circle")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(ingredient.isChecked ? .appYellow : .appWhite.opacity(0.6))
                        .scaleEffect(ingredient.isChecked ? 1.18 : 1.0)
                        .animation(.spring(response: 0.25, dampingFraction: 0.5), value: ingredient.isChecked)
                }
            }
            .buttonStyle(PlainButtonStyle())
            VStack(alignment: .leading, spacing: 2) {
                Text(ingredient.name)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(ingredient.isChecked ? .appWhite.opacity(0.6) : .appWhite)
                    .strikethrough(ingredient.isChecked)
                    .lineLimit(1)
                Text(ingredient.quantity)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.appYellow)
                    .lineLimit(1)
            }
            Spacer()
            if ingredient.isChecked {
                Image(systemName: "checkmark")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.appYellow.opacity(0.8))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color.gray.opacity(0.10))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(ingredient.isChecked ? Color.appYellow.opacity(0.4) : Color.gray.opacity(0.15), lineWidth: ingredient.isChecked ? 1.5 : 1)
        )
        .shadow(color: Color.appYellow.opacity(ingredient.isChecked ? 0.10 : 0.04), radius: 4, x: 0, y: 2)
        .opacity(ingredient.isChecked ? 0.7 : 1.0)
        .animation(.easeInOut(duration: 0.15), value: ingredient.isChecked)
        .contentShape(Rectangle())
        .onTapGesture {
            groceryListViewModel.toggleCheck(for: ingredient)
        }
    }
}
