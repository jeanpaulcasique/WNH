// Base de datos de conversiones de ingredientes a unidades de compra reales
 let ingredientConversions: [String: IngredientInfo] = [
        // Verduras y Hortalizas
        "pepino": IngredientInfo(averageWeight: 200, unit: "pepino", pluralUnit: "pepinos", englishUnit: "cucumber", englishPluralUnit: "cucumbers"),
        "tomate": IngredientInfo(averageWeight: 150, unit: "tomate", pluralUnit: "tomates", englishUnit: "tomato", englishPluralUnit: "tomatoes"),
        "tomate cherry": IngredientInfo(averageWeight: 10, unit: "tomate cherry", pluralUnit: "tomates cherry", englishUnit: "cherry tomato", englishPluralUnit: "cherry tomatoes"),
        "cebolla": IngredientInfo(averageWeight: 150, unit: "cebolla", pluralUnit: "cebollas", englishUnit: "onion", englishPluralUnit: "onions"),
        "zanahoria": IngredientInfo(averageWeight: 100, unit: "zanahoria", pluralUnit: "zanahorias", englishUnit: "carrot", englishPluralUnit: "carrots"),
        "papa": IngredientInfo(averageWeight: 200, unit: "papa", pluralUnit: "papas", englishUnit: "potato", englishPluralUnit: "potatoes"),
        "pimiento": IngredientInfo(averageWeight: 200, unit: "pimiento", pluralUnit: "pimientos", englishUnit: "bell pepper", englishPluralUnit: "bell peppers"),
        "calabacín": IngredientInfo(averageWeight: 250, unit: "calabacín", pluralUnit: "calabacines", englishUnit: "zucchini", englishPluralUnit: "zucchinis"),
        "calabaza": IngredientInfo(averageWeight: 1000, unit: "calabaza", pluralUnit: "calabazas", englishUnit: "pumpkin", englishPluralUnit: "pumpkins"),
        "berenjena": IngredientInfo(averageWeight: 250, unit: "berenjena", pluralUnit: "berenjenas", englishUnit: "eggplant", englishPluralUnit: "eggplants"),
        "lechuga": IngredientInfo(averageWeight: 400, unit: "lechuga", pluralUnit: "lechugas", englishUnit: "lettuce head", englishPluralUnit: "lettuce heads"),
        "apio": IngredientInfo(averageWeight: 400, unit: "apio", pluralUnit: "apios", englishUnit: "celery", englishPluralUnit: "celeries"),
        "brócoli": IngredientInfo(averageWeight: 400, unit: "brócoli", pluralUnit: "brócolis", englishUnit: "broccoli head", englishPluralUnit: "broccoli heads"),
        "coliflor": IngredientInfo(averageWeight: 600, unit: "coliflor", pluralUnit: "coliflores", englishUnit: "cauliflower", englishPluralUnit: "cauliflowers"),
        "espinaca": IngredientInfo(averageWeight: 250, unit: "bolsa", pluralUnit: "bolsas", englishUnit: "bag", englishPluralUnit: "bags"),
        "rúcula": IngredientInfo(averageWeight: 100, unit: "bolsa", pluralUnit: "bolsas", englishUnit: "bag", englishPluralUnit: "bags"),
        "acelga": IngredientInfo(averageWeight: 400, unit: "manojo", pluralUnit: "manojos", englishUnit: "bunch", englishPluralUnit: "bunches"),
        "espárragos": IngredientInfo(averageWeight: 250, unit: "manojo", pluralUnit: "manojos", englishUnit: "bunch", englishPluralUnit: "bunches"),
        "ejotes": IngredientInfo(averageWeight: 250, unit: "manojo", pluralUnit: "manojos", englishUnit: "bunch", englishPluralUnit: "bunches"),
        "champiñones": IngredientInfo(averageWeight: 250, unit: "bandeja", pluralUnit: "bandejas", englishUnit: "package", englishPluralUnit: "packages"),
        "setas shiitake": IngredientInfo(averageWeight: 100, unit: "bandeja", pluralUnit: "bandejas", englishUnit: "package", englishPluralUnit: "packages"),
        
        // Frutas
        "manzana": IngredientInfo(averageWeight: 180, unit: "manzana", pluralUnit: "manzanas", englishUnit: "apple", englishPluralUnit: "apples"),
        "plátano": IngredientInfo(averageWeight: 120, unit: "plátano", pluralUnit: "plátanos", englishUnit: "banana", englishPluralUnit: "bananas"),
        "naranja": IngredientInfo(averageWeight: 200, unit: "naranja", pluralUnit: "naranjas", englishUnit: "orange", englishPluralUnit: "oranges"),
        "limón": IngredientInfo(averageWeight: 100, unit: "limón", pluralUnit: "limones", englishUnit: "lemon", englishPluralUnit: "lemons"),
        "lima": IngredientInfo(averageWeight: 80, unit: "lima", pluralUnit: "limas", englishUnit: "lime", englishPluralUnit: "limes"),
        "aguacate": IngredientInfo(averageWeight: 200, unit: "aguacate", pluralUnit: "aguacates", englishUnit: "avocado", englishPluralUnit: "avocados"),
        "pera": IngredientInfo(averageWeight: 170, unit: "pera", pluralUnit: "peras"),
        "durazno": IngredientInfo(averageWeight: 150, unit: "durazno", pluralUnit: "duraznos"),
        "kiwi": IngredientInfo(averageWeight: 100, unit: "kiwi", pluralUnit: "kiwis"),
        "frutos rojos": IngredientInfo(averageWeight: 125, unit: "bandeja", pluralUnit: "bandejas"),
        "fresas": IngredientInfo(averageWeight: 250, unit: "bandeja", pluralUnit: "bandejas"),
        "arándanos": IngredientInfo(averageWeight: 125, unit: "bandeja", pluralUnit: "bandejas"),
        "piña": IngredientInfo(averageWeight: 1500, unit: "piña", pluralUnit: "piñas"),
        
        // Proteínas - Carnes
        "pollo": IngredientInfo(averageWeight: 200, unit: "pechuga", pluralUnit: "pechugas"),
        "carne molida": IngredientInfo(averageWeight: 500, unit: "paquete", pluralUnit: "paquetes"),
        "bistec": IngredientInfo(averageWeight: 200, unit: "bistec", pluralUnit: "bistecs"),
        "chuleta de cerdo": IngredientInfo(averageWeight: 200, unit: "chuleta", pluralUnit: "chuletas"),
        "lomo de cerdo": IngredientInfo(averageWeight: 500, unit: "paquete", pluralUnit: "paquetes"),
        "tocino": IngredientInfo(averageWeight: 200, unit: "paquete", pluralUnit: "paquetes"),
        "jamón": IngredientInfo(averageWeight: 200, unit: "paquete", pluralUnit: "paquetes"),
        "embutidos": IngredientInfo(averageWeight: 200, unit: "paquete", pluralUnit: "paquetes"),
        "pavo": IngredientInfo(averageWeight: 200, unit: "pechuga", pluralUnit: "pechugas"),
        
        // Proteínas - Pescados y Mariscos
        "salmón": IngredientInfo(averageWeight: 200, unit: "filete", pluralUnit: "filetes"),
        "atún": IngredientInfo(averageWeight: 200, unit: "filete", pluralUnit: "filetes"),
        "atún en lata": IngredientInfo(averageWeight: 140, unit: "lata", pluralUnit: "latas"),
        "camarón": IngredientInfo(averageWeight: 500, unit: "paquete", pluralUnit: "paquetes"),
        "tilapia": IngredientInfo(averageWeight: 200, unit: "filete", pluralUnit: "filetes"),
        "bacalao": IngredientInfo(averageWeight: 200, unit: "filete", pluralUnit: "filetes"),
        
        // Huevos
        "huevo": IngredientInfo(averageWeight: 60, unit: "huevo", pluralUnit: "huevos"),
        "clara de huevo": IngredientInfo(averageWeight: 30, unit: "clara", pluralUnit: "claras"),
        
        // Lácteos
        "yogur": IngredientInfo(averageWeight: 125, unit: "envase", pluralUnit: "envases", englishUnit: "container", englishPluralUnit: "containers"),
        "yogur griego": IngredientInfo(averageWeight: 170, unit: "envase", pluralUnit: "envases", englishUnit: "container", englishPluralUnit: "containers"),
        "queso": IngredientInfo(averageWeight: 250, unit: "paquete", pluralUnit: "paquetes", englishUnit: "package", englishPluralUnit: "packages"),
        "queso fresco": IngredientInfo(averageWeight: 400, unit: "paquete", pluralUnit: "paquetes", englishUnit: "package", englishPluralUnit: "packages"),
        "queso feta": IngredientInfo(averageWeight: 200, unit: "paquete", pluralUnit: "paquetes", englishUnit: "package", englishPluralUnit: "packages"),
        "queso parmesano": IngredientInfo(averageWeight: 100, unit: "paquete", pluralUnit: "paquetes", englishUnit: "package", englishPluralUnit: "packages"),
        "queso mozzarella": IngredientInfo(averageWeight: 250, unit: "paquete", pluralUnit: "paquetes", englishUnit: "package", englishPluralUnit: "packages"),
        "queso cottage": IngredientInfo(averageWeight: 400, unit: "pote", pluralUnit: "potes", englishUnit: "container", englishPluralUnit: "containers"),
        "leche": IngredientInfo(averageWeight: 1000, unit: "litro", pluralUnit: "litros", englishUnit: "gallon", englishPluralUnit: "gallons"),
        "leche de almendra": IngredientInfo(averageWeight: 1000, unit: "litro", pluralUnit: "litros", englishUnit: "gallon", englishPluralUnit: "gallons"),
        "leche de coco": IngredientInfo(averageWeight: 400, unit: "lata", pluralUnit: "latas", englishUnit: "can", englishPluralUnit: "cans"),
        "crema": IngredientInfo(averageWeight: 200, unit: "envase", pluralUnit: "envases", englishUnit: "container", englishPluralUnit: "containers"),
        "mantequilla": IngredientInfo(averageWeight: 200, unit: "paquete", pluralUnit: "paquetes", englishUnit: "package", englishPluralUnit: "packages"),
        
        // Condimentos y aromáticos
        "ajo": IngredientInfo(averageWeight: 5, unit: "diente", pluralUnit: "dientes"),
        "jengibre": IngredientInfo(averageWeight: 50, unit: "trozo", pluralUnit: "trozos"),
        "perejil": IngredientInfo(averageWeight: 50, unit: "manojo", pluralUnit: "manojos"),
        "cilantro": IngredientInfo(averageWeight: 50, unit: "manojo", pluralUnit: "manojos"),
        "albahaca": IngredientInfo(averageWeight: 30, unit: "manojo", pluralUnit: "manojos"),
        "cebollín": IngredientInfo(averageWeight: 50, unit: "manojo", pluralUnit: "manojos"),
        "hierbas frescas": IngredientInfo(averageWeight: 30, unit: "manojo", pluralUnit: "manojos"),
        
        // Aceites y líquidos
        "aceite de oliva": IngredientInfo(averageWeight: 500, unit: "botella", pluralUnit: "botellas", englishUnit: "bottle", englishPluralUnit: "bottles"),
        "aceite de aguacate": IngredientInfo(averageWeight: 500, unit: "botella", pluralUnit: "botellas", englishUnit: "bottle", englishPluralUnit: "bottles"),
        "aceite de coco": IngredientInfo(averageWeight: 500, unit: "frasco", pluralUnit: "frascos", englishUnit: "jar", englishPluralUnit: "jars"),
        "aceite de sésamo": IngredientInfo(averageWeight: 250, unit: "botella", pluralUnit: "botellas", englishUnit: "bottle", englishPluralUnit: "bottles"),
        "jugo de limón": IngredientInfo(averageWeight: 100, unit: "limón", pluralUnit: "limones", englishUnit: "lemon", englishPluralUnit: "lemons"),
        "jugo de lima": IngredientInfo(averageWeight: 80, unit: "lima", pluralUnit: "limas", englishUnit: "lime", englishPluralUnit: "limes"),
        "vinagre": IngredientInfo(averageWeight: 500, unit: "botella", pluralUnit: "botellas", englishUnit: "bottle", englishPluralUnit: "bottles"),
        "vinagre balsámico": IngredientInfo(averageWeight: 250, unit: "botella", pluralUnit: "botellas", englishUnit: "bottle", englishPluralUnit: "bottles"),
        
        // Salsas y condimentos
        "salsa de tomate": IngredientInfo(averageWeight: 400, unit: "frasco", pluralUnit: "frascos", englishUnit: "jar", englishPluralUnit: "jars"),
        "salsa de soya": IngredientInfo(averageWeight: 250, unit: "botella", pluralUnit: "botellas", englishUnit: "bottle", englishPluralUnit: "bottles"),
        "mostaza": IngredientInfo(averageWeight: 200, unit: "frasco", pluralUnit: "frascos", englishUnit: "jar", englishPluralUnit: "jars"),
        "mayonesa": IngredientInfo(averageWeight: 400, unit: "frasco", pluralUnit: "frascos", englishUnit: "jar", englishPluralUnit: "jars"),
        "hummus": IngredientInfo(averageWeight: 200, unit: "pote", pluralUnit: "potes", englishUnit: "container", englishPluralUnit: "containers"),
        
        // Frutos secos y semillas
        "almendras": IngredientInfo(averageWeight: 200, unit: "paquete", pluralUnit: "paquetes", englishUnit: "package", englishPluralUnit: "packages"),
        "nueces": IngredientInfo(averageWeight: 200, unit: "paquete", pluralUnit: "paquetes", englishUnit: "package", englishPluralUnit: "packages"),
        "avellanas": IngredientInfo(averageWeight: 200, unit: "paquete", pluralUnit: "paquetes", englishUnit: "package", englishPluralUnit: "packages"),
        "semillas de chía": IngredientInfo(averageWeight: 200, unit: "paquete", pluralUnit: "paquetes", englishUnit: "package", englishPluralUnit: "packages"),
        "semillas de sésamo": IngredientInfo(averageWeight: 100, unit: "paquete", pluralUnit: "paquetes", englishUnit: "package", englishPluralUnit: "packages"),
        
        // Granos y cereales
        "arroz": IngredientInfo(averageWeight: 1000, unit: "paquete", pluralUnit: "paquetes", englishUnit: "package", englishPluralUnit: "packages"),
        "quinoa": IngredientInfo(averageWeight: 500, unit: "paquete", pluralUnit: "paquetes", englishUnit: "package", englishPluralUnit: "packages"),
        "avena": IngredientInfo(averageWeight: 500, unit: "paquete", pluralUnit: "paquetes", englishUnit: "package", englishPluralUnit: "packages"),
        "pasta": IngredientInfo(averageWeight: 500, unit: "paquete", pluralUnit: "paquetes", englishUnit: "package", englishPluralUnit: "packages"),
        "harina de almendra": IngredientInfo(averageWeight: 500, unit: "paquete", pluralUnit: "paquetes", englishUnit: "package", englishPluralUnit: "packages"),
        "pan integral": IngredientInfo(averageWeight: 500, unit: "pan", pluralUnit: "panes", englishUnit: "loaf", englishPluralUnit: "loaves"),
        "tortilla integral": IngredientInfo(averageWeight: 300, unit: "paquete", pluralUnit: "paquetes", englishUnit: "package", englishPluralUnit: "packages"),
        "pan pita": IngredientInfo(averageWeight: 300, unit: "paquete", pluralUnit: "paquetes", englishUnit: "package", englishPluralUnit: "packages"),
        
        // Legumbres
        "frijoles": IngredientInfo(averageWeight: 500, unit: "paquete", pluralUnit: "paquetes", englishUnit: "package", englishPluralUnit: "packages"),
        "lentejas": IngredientInfo(averageWeight: 500, unit: "paquete", pluralUnit: "paquetes", englishUnit: "package", englishPluralUnit: "packages"),
        "garbanzos": IngredientInfo(averageWeight: 500, unit: "paquete", pluralUnit: "paquetes", englishUnit: "package", englishPluralUnit: "packages"),
        
        // Aceitunas y encurtidos
        "aceitunas": IngredientInfo(averageWeight: 200, unit: "frasco", pluralUnit: "frascos", englishUnit: "jar", englishPluralUnit: "jars"),
        "pepinillos": IngredientInfo(averageWeight: 300, unit: "frasco", pluralUnit: "frascos", englishUnit: "jar", englishPluralUnit: "jars"),
        
        // Otros
        "caldo": IngredientInfo(averageWeight: 1000, unit: "litro", pluralUnit: "litros", englishUnit: "quart", englishPluralUnit: "quarts"),
        "proteína en polvo": IngredientInfo(averageWeight: 1000, unit: "pote", pluralUnit: "potes", englishUnit: "container", englishPluralUnit: "containers"),
        "miel": IngredientInfo(averageWeight: 500, unit: "frasco", pluralUnit: "frascos", englishUnit: "jar", englishPluralUnit: "jars"),
        "extracto de vainilla": IngredientInfo(averageWeight: 100, unit: "frasco", pluralUnit: "frascos", englishUnit: "bottle", englishPluralUnit: "bottles"),
        "coco rallado": IngredientInfo(averageWeight: 100, unit: "paquete", pluralUnit: "paquetes", englishUnit: "package", englishPluralUnit: "packages"),
        "polvo para hornear": IngredientInfo(averageWeight: 100, unit: "sobre", pluralUnit: "sobres", englishUnit: "package", englishPluralUnit: "packages"),
        
        // Especias (mantener en gramos con keepInGrams = true)
        "canela": IngredientInfo(averageWeight: 50, unit: "sobre", pluralUnit: "sobres", englishUnit: "package", englishPluralUnit: "packages", keepInGrams: true),
        "romero": IngredientInfo(averageWeight: 20, unit: "sobre", pluralUnit: "sobres", englishUnit: "package", englishPluralUnit: "packages", keepInGrams: true),
        "tomillo": IngredientInfo(averageWeight: 20, unit: "sobre", pluralUnit: "sobres", englishUnit: "package", englishPluralUnit: "packages", keepInGrams: true),
        "orégano": IngredientInfo(averageWeight: 50, unit: "sobre", pluralUnit: "sobres", englishUnit: "package", englishPluralUnit: "packages", keepInGrams: true),
        "eneldo": IngredientInfo(averageWeight: 20, unit: "sobre", pluralUnit: "sobres", englishUnit: "package", englishPluralUnit: "packages", keepInGrams: true),
        "hierbas italianas": IngredientInfo(averageWeight: 50, unit: "sobre", pluralUnit: "sobres", englishUnit: "package", englishPluralUnit: "packages", keepInGrams: true),
        "condimento para tacos": IngredientInfo(averageWeight: 50, unit: "sobre", pluralUnit: "sobres", englishUnit: "package", englishPluralUnit: "packages", keepInGrams: true),
        "ajo en polvo": IngredientInfo(averageWeight: 50, unit: "sobre", pluralUnit: "sobres", englishUnit: "package", englishPluralUnit: "packages", keepInGrams: true),
        "hojuelas de chile": IngredientInfo(averageWeight: 50, unit: "sobre", pluralUnit: "sobres", englishUnit: "package", englishPluralUnit: "packages", keepInGrams: true),
        "pimienta": IngredientInfo(averageWeight: 50, unit: "sobre", pluralUnit: "sobres", englishUnit: "package", englishPluralUnit: "packages", keepInGrams: true)
    ]

import SwiftUI
import Combine
import Foundation

// MARK: - GroceryListViewModel

class GroceryListViewModel: ObservableObject {
    @Published var groceryList: [Ingredient] = []
    
    private static let checkedKey = "checkedIngredients"
    private static let expandedCategoriesKey = "expandedCategories"
    
    // MARK: - Agrupación por categorías
    enum GroceryCategory: String, CaseIterable {
        case vegetales = "Vegetables"
        case frutas = "Fruits"
        case proteinas = "Proteins"
        case lacteos = "Dairy"
        case granos = "Grains & Cereals"
        case legumbres = "Legumes"
        case frutosSecos = "Nuts & Seeds"
        case aceites = "Oils & Liquids"
        case condimentos = "Condiments & Spices"
        case otros = "Others"

        var displayName: String {
            LanguageManager.localizedString(rawValue)
        }
        
        var color: Color {
            switch self {
            case .vegetales: return Color.appYellow
            case .frutas: return Color.appYellow
            case .proteinas: return Color.appYellow
            case .lacteos: return Color.appYellow
            case .granos: return Color.appYellow
            case .legumbres: return Color.appYellow
            case .frutosSecos: return Color.appYellow
            case .aceites: return Color.appYellow
            case .condimentos: return Color.appYellow
            case .otros: return Color.appYellow
            }
        }
    }

    @Published var groceryListByCategory: [GroceryCategory: [Ingredient]] = [:]
    
    // ✅ NUEVO: Estado persistente de categorías expandidas
    @Published var expandedCategories: [GroceryCategory: Bool] = [:]
    
    // ✅ NUEVO: Cache para optimizar rendimiento
    private var filteredIngredientsCache: [GroceryCategory: [Ingredient]] = [:]
    private var lastFilterState: Bool = false
    
    // ✅ PERFORMANCE: Cache para lazy loading
    private var preloadedItems: [GroceryCategory: [Ingredient]] = [:]
    private var isOfflineMode: Bool = false
    private var lastSyncDate: Date = Date()
    
    // MARK: - Performance Optimization Methods
    
    /// Preload next items for smooth scrolling
    func preloadNextItems(for category: GroceryCategory, currentIndex: Int) {
        let items = getFilteredIngredients(for: category, showOnlyUnchecked: false)
        let nextItems = Array(items.dropFirst(currentIndex + 1).prefix(10))
        preloadedItems[category] = nextItems
    }
    
    /// Check if we can work offline
    func checkOfflineMode() -> Bool {
        let timeSinceLastSync = Date().timeIntervalSince(lastSyncDate)
        isOfflineMode = timeSinceLastSync > 300 // 5 minutes
        return isOfflineMode
    }
    
    /// Get cached ingredients for better performance
    func getCachedIngredients(for category: GroceryCategory, showOnlyUnchecked: Bool) -> [Ingredient] {
        let cacheKey = "\(category.rawValue)_\(showOnlyUnchecked)"
        
        // Check if we have cached data
        if let cached = filteredIngredientsCache[category], lastFilterState == showOnlyUnchecked {
            return cached
        }
        
        // Get fresh data and cache it
        let freshData = getFilteredIngredients(for: category, showOnlyUnchecked: showOnlyUnchecked)
        filteredIngredientsCache[category] = freshData
        lastFilterState = showOnlyUnchecked
        
        return freshData
    }
    
    /// Clear cache when data changes
    func clearCache() {
        filteredIngredientsCache.removeAll()
        preloadedItems.removeAll()
        print("🧹 Cache cleared for better performance")
    }
    
    init() {
        loadExpandedCategoriesState()
        // Colapsar todas las categorías por defecto
        expandedCategories = Dictionary(uniqueKeysWithValues: GroceryCategory.allCases.map { ($0, false) })
    }
    
    // MARK: - Public Methods
    
    func updateGroceryList(from weeklyRecipes: [Date: [Recipe]]) {
        print("🛒 Actualizando lista de compras...")
        
        let allIngredients = weeklyRecipes.values.flatMap { $0 }.flatMap { $0.ingredients }
        let checked = loadCheckedIngredientNames()
        let grouped = Dictionary(grouping: allIngredients, by: { $0.name }).map { name, items -> Ingredient in
            // Combinar cantidades primero
            let combinedQty = QuantityParser.combine(items.map { $0.quantity })
            
            // Convertir a cantidades de supermercado prácticas
            let shoppableQty = SmartShoppingConverter.convertToShoppableQuantity(
                name: name,
                combinedQuantity: combinedQty
            )
            
            let isChecked = checked.contains(name)
            
            // Crear ingrediente normal - el ID se genera automáticamente
            return Ingredient(name: name, quantity: shoppableQty, isChecked: isChecked)
        }
        groceryList = grouped.sorted { $0.name < $1.name }
        
        // Agrupar por categoría
        groceryListByCategory = Dictionary(grouping: groceryList, by: { categorizeIngredient($0.name) })
        
        // ✅ NUEVO: Limpiar cache cuando cambia la lista
        clearCache()
        lastSyncDate = Date() // Update sync timestamp
        
        print("✅ Lista actualizada:")
        print("   📊 Total: \(totalCount) ingredientes")
        print("   ✅ Completados: \(checkedCount)")
        print("   📋 Pendientes: \(uncheckedCount)")
        print("   📈 Progreso: \(completionText)")
    }
    
    // Método para desactivar debug cuando no lo necesites
    func updateGroceryListQuiet(from weeklyRecipes: [Date: [Recipe]]) {
        let allIngredients = weeklyRecipes.values.flatMap { $0 }.flatMap { $0.ingredients }
        let checked = loadCheckedIngredientNames()
        let grouped = Dictionary(grouping: allIngredients, by: { $0.name }).map { name, items -> Ingredient in
            let combinedQty = QuantityParser.combine(items.map { $0.quantity })
            let shoppableQty = SmartShoppingConverter.convertToShoppableQuantity(
                name: name,
                combinedQuantity: combinedQty
            )
            let isChecked = checked.contains(name)
            return Ingredient(name: name, quantity: shoppableQty, isChecked: isChecked)
        }
        groceryList = grouped.sorted { $0.name < $1.name }
    }
    
    func toggleCheck(for ingredient: Ingredient) {
        print("🔄 Intentando toggle para: '\(ingredient.name)' (actual: \(ingredient.isChecked))")
        
        // Buscar por id para mutar directamente el struct en el array
        if let index = groceryList.firstIndex(where: { $0.id == ingredient.id }) {
            groceryList[index].isChecked.toggle()
            // ACTUALIZAR agrupación por categoría tras toggle
            groceryListByCategory = Dictionary(grouping: groceryList, by: { categorizeIngredient($0.name) })
            let newState = groceryList[index].isChecked
            print("✅ Toggle exitoso: '\(ingredient.name)' cambiado a \(newState)")
            saveCheckedIngredientNames()
            objectWillChange.send()
        } else {
            print("❌ ERROR: No se encontró '\(ingredient.name)' en la lista")
            print("📋 Ingredientes disponibles:")
            for (i, item) in groceryList.enumerated() {
                print("   \(i): '\(item.name)' [\(item.isChecked ? "✓" : "○")]" )
            }
        }
    }
    
    func groceryListText(for dietType: String) -> String {
        let header = "🛒 Lista de Compras (\(dietType))\n"
        let counter = "📊 \(progressText) - \(completionText)\n\n"
        
        if isEmpty {
            return header + counter + "No hay ingredientes en la lista"
        }
        
        let checkedItems = groceryList.filter { $0.isChecked }
        let uncheckedItems = groceryList.filter { !$0.isChecked }
        
        var result = header + counter
        
        // Mostrar items pendientes primero
        if !uncheckedItems.isEmpty {
            result += "📋 Pendientes (\(uncheckedItems.count)):\n"
            let pendingItems = uncheckedItems.map { "- \($0.name): \($0.quantity)" }.joined(separator: "\n")
            result += pendingItems + "\n\n"
        }
        
        // Mostrar items completados
        if !checkedItems.isEmpty {
            result += "✅ Completados (\(checkedItems.count)):\n"
            let completedItems = checkedItems.map { "- \($0.name): \($0.quantity)" }.joined(separator: "\n")
            result += completedItems
        }
        
        return result
    }
    
    func clearAllChecked() {
        // Crea una nueva lista con nuevos IDs para forzar el refresco
        groceryList = groceryList.map { ing in
            Ingredient(name: ing.name, quantity: ing.quantity, isChecked: false)
        }
        groceryListByCategory = Dictionary(grouping: groceryList, by: { categorizeIngredient($0.name) })
        saveCheckedIngredientNames()
        objectWillChange.send()
    }
    
    func getCheckedIngredients() -> [Ingredient] {
        return groceryList.filter { $0.isChecked }
    }
    
    func getUncheckedIngredients() -> [Ingredient] {
        return groceryList.filter { !$0.isChecked }
    }
    
    var checkedCount: Int {
        groceryList.filter { $0.isChecked }.count
    }
    
    var totalCount: Int {
        groceryList.count
    }
    
    var uncheckedCount: Int {
        groceryList.filter { !$0.isChecked }.count
    }
    
    var completionPercentage: Double {
        guard totalCount > 0 else { return 0.0 }
        return Double(checkedCount) / Double(totalCount)
    }
    
    var progressText: String {
        return "\(checkedCount) de \(totalCount) items"
    }
    
    var completionText: String {
        let percentage = Int(completionPercentage * 100)
        return "\(percentage)% completado"
    }
    
    // Estado de la lista
    var isCompleted: Bool {
        totalCount > 0 && checkedCount == totalCount
    }
    
    var isEmpty: Bool {
        totalCount == 0
    }
    
    // MARK: - Private Methods
    
    private func saveCheckedIngredientNames() {
        let names = groceryList.filter { $0.isChecked }.map { $0.name }
        UserDefaults.standard.set(names, forKey: Self.checkedKey)
    }
    
    private func loadCheckedIngredientNames() -> [String] {
        UserDefaults.standard.stringArray(forKey: Self.checkedKey) ?? []
    }
    
    private func categorizeIngredient(_ name: String) -> GroceryCategory {
        let n = name.lowercased()
        if ["pepino","tomate","cebolla","zanahoria","papa","pimiento","calabacín","calabaza","berenjena","lechuga","apio","brócoli","coliflor","espinaca","rúcula","acelga","espárragos","ejotes","champiñones","setas"].contains(where: n.contains) {
            return .vegetales
        }
        if ["manzana","plátano","naranja","limón","lima","aguacate","pera","durazno","kiwi","frutos rojos","fresas","arándanos","piña"].contains(where: n.contains) {
            return .frutas
        }
        if ["pollo","carne","bistec","chuleta","lomo","tocino","jamón","embutidos","pavo","salmón","atún","camarón","tilapia","bacalao","huevo","clara"].contains(where: n.contains) {
            return .proteinas
        }
        if ["yogur","queso","leche","crema","mantequilla"].contains(where: n.contains) {
            return .lacteos
        }
        if ["arroz","quinoa","avena","pasta","harina","pan","tortilla"].contains(where: n.contains) {
            return .granos
        }
        if ["frijoles","lentejas","garbanzos"].contains(where: n.contains) {
            return .legumbres
        }
        if ["almendras","nueces","avellanas","semillas"].contains(where: n.contains) {
            return .frutosSecos
        }
        // Mejorar aceites y líquidos
        if ["aceite de oliva","aceite de aguacate","aceite de coco","aceite de sésamo","aceite","vinagre","jugo","salsa","mayonesa","hummus"].contains(where: n.contains) {
            return .aceites
        }
        if ["ajo","jengibre","perejil","cilantro","albahaca","cebollín","hierbas","canela","romero","tomillo","orégano","eneldo","condimento","pimienta","hojuelas"].contains(where: n.contains) {
            return .condimentos
        }
        return .otros
    }
    
    // Diagnóstico: Verifica qué ingredientes no tienen conversión práctica
    func printMissingIngredientConversions() {
        let allNames = Set(groceryList.map { $0.name })
        for name in allNames {
            let normalizedName = SmartShoppingConverter.normalizeIngredientName(name)
            let hasExact = ingredientConversions[normalizedName] != nil
            let hasPartial = ingredientConversions.keys.contains(where: { normalizedName.contains($0) })
            let hasSynonym = SmartShoppingConverter.findBestMatch(for: normalizedName) != nil
            if !hasExact && !hasPartial && !hasSynonym {
                print("❌ Sin conversión práctica: '", name, "'")
            }
        }
    }
    
    // ✅ NUEVO: Métodos para manejar estado persistente
    func toggleCategoryExpansion(_ category: GroceryCategory) {
        expandedCategories[category] = !(expandedCategories[category] ?? false)
        saveExpandedCategoriesState()
    }
    
    func isCategoryExpanded(_ category: GroceryCategory) -> Bool {
        return expandedCategories[category] ?? false
    }
    
    private func saveExpandedCategoriesState() {
        let expandedCategoryNames = expandedCategories.compactMap { category, isExpanded in
            isExpanded ? category.rawValue : nil
        }
        UserDefaults.standard.set(expandedCategoryNames, forKey: Self.expandedCategoriesKey)
    }
    
    private func loadExpandedCategoriesState() {
        if let savedCategories = UserDefaults.standard.array(forKey: Self.expandedCategoriesKey) as? [String] {
            expandedCategories = Dictionary(uniqueKeysWithValues: savedCategories.map { category in
                (GroceryCategory(rawValue: category) ?? .otros, true)
            })
        } else {
            // Por defecto, todas las categorías están colapsadas
            expandedCategories = Dictionary(uniqueKeysWithValues: GroceryCategory.allCases.map { ($0, false) })
        }
    }
    
    // ✅ NUEVO: Método optimizado para obtener ingredientes filtrados
    func getFilteredIngredients(for category: GroceryCategory, showOnlyUnchecked: Bool) -> [Ingredient] {
        guard let items = groceryListByCategory[category] else { return [] }
        let filtered = showOnlyUnchecked ? items.filter { !$0.isChecked } : items
        let sorted = filtered.sorted { $0.name < $1.name }
        return sorted
    }
    


    // Devuelve todos los ingredientes filtrados según el toggle global
    func getFilteredIngredientsForAll(showOnlyUnchecked: Bool) -> [Ingredient] {
        let all = groceryList
        return showOnlyUnchecked ? all.filter { !$0.isChecked } : all
    }

    // Devuelve solo las categorías presentes según el filtro
    func presentCategories(showOnlyUnchecked: Bool) -> [GroceryCategory] {
        GroceryCategory.allCases.filter { getFilteredIngredients(for: $0, showOnlyUnchecked: showOnlyUnchecked).isEmpty == false }
    }
}

// MARK: - QuantityParser Helper

struct QuantityParser {
    static func combine(_ quantities: [String]) -> String {
        // Agrupa cantidades por unidad y las suma
        var unitGroups: [String: Double] = [:]
        var noUnitTotal: Double = 0
        
        for quantity in quantities {
            let (value, unit) = parseQuantity(quantity)
            
            if unit.isEmpty {
                noUnitTotal += value
            } else {
                unitGroups[unit, default: 0] += value
            }
        }
        
        // Construye el resultado
        var results: [String] = []
        
        // Agregar elementos sin unidad
        if noUnitTotal > 0 {
            results.append(formatValue(noUnitTotal))
        }
        
        // Agregar elementos con unidad
        for (unit, total) in unitGroups.sorted(by: { $0.key < $1.key }) {
            results.append("\(formatValue(total)) \(unit)")
        }
        
        return results.joined(separator: " + ")
    }
    
    private static func parseQuantity(_ quantity: String) -> (Double, String) {
        let trimmed = quantity.trimmingCharacters(in: .whitespaces)
        let pattern = #"([0-9]*\.?[0-9]+)\s*(.*)?"#
        
        guard let regex = try? NSRegularExpression(pattern: pattern),
              let match = regex.firstMatch(in: trimmed, range: NSRange(trimmed.startIndex..., in: trimmed)),
              let numberRange = Range(match.range(at: 1), in: trimmed) else {
            return (1.0, trimmed)
        }
        
        let number = Double(trimmed[numberRange]) ?? 1.0
        let unitRange = Range(match.range(at: 2), in: trimmed)
        let unit = unitRange != nil ? String(trimmed[unitRange!]).trimmingCharacters(in: .whitespaces) : ""
        
        return (number, unit)
    }
    
    private static func formatValue(_ value: Double) -> String {
        if value.truncatingRemainder(dividingBy: 1) == 0 {
            return "\(Int(value))"
        } else {
            return String(format: "%.1f", value)
        }
    }
}

// MARK: - Unit System Detection and Conversion

enum UnitSystem {
    case metric
    case imperial
    
    static var current: UnitSystem {
        let locale = Locale.current
        let isUS = locale.identifier.contains("US") || locale.regionCode == "US"
        return isUS ? .imperial : .metric
    }
}

struct WeightConversion {
    static func gramsToOunces(_ grams: Double) -> Double {
        return grams * 0.035274
    }
    
    static func gramsToLbs(_ grams: Double) -> Double {
        return grams * 0.00220462
    }
    
    static func mlToFlOz(_ ml: Double) -> Double {
        return ml * 0.033814
    }
}

class SmartShoppingConverter {
    // MARK: - Public Methods
    
    static func convertToShoppableQuantity(name: String, combinedQuantity: String) -> String {
        // Extraer cantidad total en gramos
        let (totalValue, unit) = parseQuantityFromCombined(combinedQuantity)
        
        // Normalizar el nombre para búsqueda más flexible
        let normalizedName = normalizeIngredientName(name)
        
        // Buscar coincidencia exacta primero
        if let info = ingredientConversions[normalizedName] {
            // Si debe mantenerse en gramos (especia), respeta eso
            if info.keepInGrams {
                return "\(Int(ceil(totalValue))) g"
            }
            return convertIngredient(
                name: name,
                totalGrams: totalValue,
                unit: unit,
                info: info
            )
        }
        // Buscar coincidencia parcial (por ejemplo, 'cebolla morada' -> 'cebolla')
        if let (key, info) = ingredientConversions.first(where: { normalizedName.contains($0.key) }) {
            // Si debe mantenerse en gramos (especia), respeta eso
            if info.keepInGrams {
                return "\(Int(ceil(totalValue))) g"
            }
            // Si la unidad original es gramos o ml, forzar conversión a unidades prácticas
            if unit.lowercased().contains("g") || unit.lowercased().contains("ml") || unit.isEmpty {
                return convertIngredient(
                    name: name,
                    totalGrams: totalValue,
                    unit: unit,
                    info: info
                )
            }
        }
        // Buscar por sinónimos/variaciones
        if let info = findBestMatch(for: normalizedName) {
            if info.keepInGrams {
                return "\(Int(ceil(totalValue))) g"
            }
            return convertIngredient(
                name: name,
                totalGrams: totalValue,
                unit: unit,
                info: info
            )
        }
        // Si no hay conversión específica, mantener cantidad original pero mejorada
        return enhanceGenericQuantity(combinedQuantity, originalName: name)
    }
    
    // MARK: - Private Methods
    
     static func normalizeIngredientName(_ name: String) -> String {
        return name.lowercased()
            .trimmingCharacters(in: .whitespaces)
            .replacingOccurrences(of: "de ", with: "")
            .replacingOccurrences(of: "del ", with: "")
            .replacingOccurrences(of: "la ", with: "")
            .replacingOccurrences(of: "el ", with: "")
            .replacingOccurrences(of: "los ", with: "")
            .replacingOccurrences(of: "las ", with: "")
            .replacingOccurrences(of: "en ", with: "")
            .replacingOccurrences(of: "con ", with: "")
            .replacingOccurrences(of: "sin ", with: "")
            .replacingOccurrences(of: "  ", with: " ")
            .replacingOccurrences(of: "(entero)", with: "")
            .replacingOccurrences(of: "(bajo en grasa)", with: "")
            .replacingOccurrences(of: "(sin azúcar)", with: "")
            .replacingOccurrences(of: "(light)", with: "")
            .replacingOccurrences(of: "(magro)", with: "")
            .replacingOccurrences(of: "(cocida)", with: "")
            .replacingOccurrences(of: "(cocido)", with: "")
            .replacingOccurrences(of: " a la plancha", with: "")
            .replacingOccurrences(of: " a la parrilla", with: "")
            .replacingOccurrences(of: " asado", with: "")
            .replacingOccurrences(of: " congelados", with: "")
            .trimmingCharacters(in: .whitespaces)
    }
    
     static func findBestMatch(for normalizedName: String) -> IngredientInfo? {
        // 1. Búsqueda exacta primero
        for (key, info) in ingredientConversions {
            if normalizedName == key {
                return info
            }
        }
        
        // 2. Búsqueda por palabras contenidas
        for (key, info) in ingredientConversions {
            if normalizedName.contains(key) {
                return info
            }
        }
        
        // 3. Búsqueda por palabras clave múltiples
        for (key, info) in ingredientConversions {
            let keyWords = key.components(separatedBy: " ")
            let nameWords = normalizedName.components(separatedBy: " ")
            
            if keyWords.allSatisfy({ keyword in
                nameWords.contains { $0.contains(keyword) }
            }) {
                return info
            }
        }
        
        // 4. Búsqueda por sinónimos/variaciones
        let synonyms: [String: String] = [
            "patata": "papa",
            "banana": "plátano",
            "palta": "aguacate",
            "jitomate": "tomate",
            "choclo": "maíz",
            "elote": "maíz",
            "calabaza": "calabacín",
            "auyama": "calabaza",
            "egg": "huevo",
            "yogurt": "yogur",
            "beef": "res",
            "chicken": "pollo",
            "turkey": "pavo",
            "shrimp": "camarón",
            "bell pepper": "pimiento",
            "zucchini": "calabacín",
            "eggplant": "berenjena",
            "spinach": "espinaca",
            "lettuce": "lechuga",
            "onion": "cebolla",
            "carrot": "zanahoria",
            "potato": "papa",
            "tomato": "tomate",
            "cucumber": "pepino",
            "broccoli": "brócoli",
            "mushroom": "champiñón",
            "garlic": "ajo",
            "lemon": "limón",
            "lime": "lima",
            "avocado": "aguacate",
            "tuna": "atún",
            "salmon": "salmón",
            "cheese": "queso",
            "milk": "leche",
            "butter": "mantequilla",
            "oil": "aceite",
            "olive oil": "aceite de oliva",
            "pechuga": "pollo",
            "muslo": "pollo",
            "filete": "pollo",
            "calabacitas": "calabacín",
            "zanahorias": "zanahoria",
            "pimientos": "pimiento",
            "calabacines": "calabacín"
        ]
        
        for (synonym, canonical) in synonyms {
            if normalizedName.contains(synonym), let info = ingredientConversions[canonical] {
                return info
            }
        }
        
        return nil
    }
    
    private static func enhanceGenericQuantity(_ quantity: String, originalName: String) -> String {
        // Mejorar cantidades genéricas sin conversión específica
        let (value, unit) = parseQuantityFromCombined(quantity)
        
        // Si es en gramos y es una cantidad grande, sugerir conversión a kg
        if unit.lowercased().contains("g") && value >= 1000 {
            let kg = value / 1000
            return "\(formatValue(kg)) kg"
        }
        
        // Si parece ser líquido y está en ml, convertir a litros si es necesario
        if unit.lowercased().contains("ml") && value >= 1000 {
            let liters = value / 1000
            return "\(formatValue(liters)) L"
        }
        
        // Para ingredientes que suenan como podrían ser contables
        let countableHints = ["filete", "trozo", "rebanada", "rodaja", "diente", "rama", "hoja"]
        let normalizedName = originalName.lowercased()
        
        for hint in countableHints {
            if normalizedName.contains(hint) {
                let count = max(1, Int(ceil(value)))
                return "\(count) \(hint)\(count > 1 ? "s" : "")"
            }
        }
        
        return quantity
    }
    
    private static func convertIngredient(name: String, totalGrams: Double, unit: String, info: IngredientInfo) -> String {
        let unitSystem = UnitSystem.current
        let lowerName = name.lowercased()
        // Si ya está en unidades específicas (no gramos ni mililitros), mantener
        if !unit.lowercased().contains("gr") && 
           !unit.lowercased().contains("g") && 
           !unit.lowercased().contains("ml") && 
           !unit.isEmpty {
            // Redondear hacia arriba para unidades específicas
            let roundedValue = ceil(totalGrams)
            return "\(Int(roundedValue)) \(info.getUnit(for: unitSystem, count: Int(roundedValue)))"
        }
        // Para líquidos y aceites, siempre mostrar en botellas/litros
        if isLiquid(name) || lowerName.contains("aceite") {
            let units = max(1, Int(ceil(totalGrams / info.averageWeight)))
            return "\(units) \(info.getUnit(for: unitSystem, count: units))"
        }
        // Para todo lo demás, convertir a unidades prácticas
        let units = max(1, Int(ceil(totalGrams / info.averageWeight)))
        return "\(units) \(info.getUnit(for: unitSystem, count: units))"
    }
    
    private static func formatWeight(_ grams: Double, unitSystem: UnitSystem) -> String {
        switch unitSystem {
        case .metric:
            // Para cantidades muy pequeñas (menos de 5g), mantener en gramos
            if grams < 5 {
                return "\(formatValue(grams)) g"
            }
            
            // Para cantidades entre 5g y 20g, redondear al siguiente múltiplo de 5
            if grams < 20 {
                let rounded = ceil(grams / 5) * 5
                return "\(Int(rounded)) g"
            }
            
            // Para cantidades mayores, redondear al siguiente múltiplo de 10
            if grams < 100 {
                let rounded = ceil(grams / 10) * 10
                return "\(Int(rounded)) g"
            }
            
            // Para cantidades grandes, convertir a kg si es apropiado
            if grams >= 1000 {
                let kg = ceil(grams / 100) / 10  // Redondear a 0.1 kg más cercano
                return "\(formatValue(kg)) kg"
            }
            
            // Para el resto, redondear a los 50g más cercanos
            let rounded = ceil(grams / 50) * 50
            return "\(Int(rounded)) g"
            
        case .imperial:
            if grams < 28.35 { // Menos de 1 oz
                let oz = WeightConversion.gramsToOunces(grams)
                if oz < 0.1 {
                    return "⅛ oz"
                } else if oz < 0.25 {
                    return "¼ oz"
                } else if oz < 0.5 {
                    return "½ oz"
                } else if oz < 0.75 {
                    return "¾ oz"
        } else {
                    return "1 oz"
                }
            }
            
            let lbs = WeightConversion.gramsToLbs(grams)
            if lbs < 1 {
                let oz = ceil(WeightConversion.gramsToOunces(grams))
                return "\(Int(oz)) oz"
            }
            
            // Para libras, mostrar fracciones comunes
            let wholeLbs = floor(lbs)
            let remainder = lbs - wholeLbs
            
            if remainder < 0.125 {
                return "\(Int(wholeLbs)) lb"
            } else if remainder < 0.375 {
                return "\(Int(wholeLbs))¼ lb"
            } else if remainder < 0.625 {
                return "\(Int(wholeLbs))½ lb"
            } else if remainder < 0.875 {
                return "\(Int(wholeLbs))¾ lb"
            } else {
                return "\(Int(wholeLbs + 1)) lb"
            }
        }
    }
    
    private static func formatVolume(_ ml: Double, unitSystem: UnitSystem) -> String {
        switch unitSystem {
        case .metric:
            if ml >= 1000 {
                let l = ceil(ml / 100) / 10  // Redondear a 0.1 L más cercano
                return "\(formatValue(l)) L"
            }
            // Redondear a los 50ml más cercanos
            let rounded = ceil(ml / 50) * 50
            return "\(Int(rounded)) ml"
            
        case .imperial:
            let flOz = WeightConversion.mlToFlOz(ml)
            if flOz < 0.25 {
                return "¼ fl oz"
            } else if flOz < 0.5 {
                return "½ fl oz"
            } else if flOz < 1 {
                return "1 fl oz"
            } else if flOz <= 32 {
                return "\(Int(ceil(flOz))) fl oz"
            } else {
                // Convertir a cuartos de galón para cantidades grandes
                let quarts = flOz / 32
                if quarts < 2 {
                    return "1 qt"
                } else if quarts < 4 {
                    return "\(Int(ceil(quarts))) qt"
                } else {
                    let gallons = ceil(quarts / 4)
                    return "\(Int(gallons)) gal"
                }
            }
        }
    }
    
    private static func isLiquid(_ name: String) -> Bool {
        let liquidKeywords = [
            "leche", "milk",
            "aceite", "oil",
            "vinagre", "vinegar",
            "jugo", "juice",
            "salsa", "sauce",
            "crema", "cream",
            "caldo", "broth",
            "agua", "water",
            "vino", "wine",
            "cerveza", "beer",
            "yogur", "yogurt",
            "nata", "cream"
        ]
        
        let name = name.lowercased()
        return liquidKeywords.contains { keyword in
            name.contains(keyword.lowercased())
        }
    }
    
    private static func parseQuantityFromCombined(_ combined: String) -> (Double, String) {
        // Para cantidades combinadas como "150 g + 50 g", sumar todo
        let components = combined.components(separatedBy: " + ")
        var totalGrams: Double = 0
        var lastUnit = ""
        
        for component in components {
            let (value, unit) = parseQuantity(component.trimmingCharacters(in: .whitespaces))
            
            // Convertir a gramos si es necesario
            if unit.lowercased().contains("kg") {
                totalGrams += value * 1000
                lastUnit = "g"
            } else if unit.lowercased().contains("gr") || unit.lowercased().contains("g") {
                totalGrams += value
                lastUnit = "g"
            } else {
                // Si no es peso, mantener la unidad original
                return (value, unit)
            }
        }
        
        return (totalGrams, lastUnit)
    }
    
    private static func parseQuantity(_ quantity: String) -> (Double, String) {
        let trimmed = quantity.trimmingCharacters(in: .whitespaces)
        let pattern = #"([0-9]*\.?[0-9]+)\s*(.*)?"#
        
        guard let regex = try? NSRegularExpression(pattern: pattern),
              let match = regex.firstMatch(in: trimmed, range: NSRange(trimmed.startIndex..., in: trimmed)),
              let numberRange = Range(match.range(at: 1), in: trimmed) else {
            return (1.0, trimmed)
        }
        
        let number = Double(trimmed[numberRange]) ?? 1.0
        let unitRange = Range(match.range(at: 2), in: trimmed)
        let unit = unitRange != nil ? String(trimmed[unitRange!]).trimmingCharacters(in: .whitespaces) : ""
        
        return (number, unit)
    }
    
    private static func formatValue(_ value: Double) -> String {
        if value.truncatingRemainder(dividingBy: 1) == 0 {
            return "\(Int(value))"
        } else {
            return String(format: "%.1f", value)
        }
    }
}

// MARK: - Supporting Structures

struct IngredientInfo {
    let averageWeight: Double  // Peso promedio en gramos
    let unit: String          // Unidad singular (ej: "tomate")
    let pluralUnit: String    // Unidad plural (ej: "tomates")
    let englishUnit: String   // Unidad singular en inglés (ej: "tomato")
    let englishPluralUnit: String // Unidad plural en inglés (ej: "tomatoes")
    let keepInGrams: Bool     // Si debe mantenerse en peso (condimentos, especias, etc.)
    
    init(averageWeight: Double, unit: String, pluralUnit: String, englishUnit: String? = nil, englishPluralUnit: String? = nil, keepInGrams: Bool = false) {
        self.averageWeight = averageWeight
        self.unit = unit
        self.pluralUnit = pluralUnit
        self.englishUnit = englishUnit ?? unit
        self.englishPluralUnit = englishPluralUnit ?? pluralUnit
        self.keepInGrams = keepInGrams
    }
    
    func getUnit(for unitSystem: UnitSystem, count: Int) -> String {
        switch unitSystem {
        case .metric:
            return count == 1 ? unit : pluralUnit
        case .imperial:
            return count == 1 ? englishUnit : englishPluralUnit
        }
    }
}

// MARK: - Extensions
extension Array where Element == (GroceryListViewModel.GroceryCategory, Bool) {
    func toDictionary() -> [GroceryListViewModel.GroceryCategory: Bool] {
        return Dictionary(uniqueKeysWithValues: self)
    }
}
