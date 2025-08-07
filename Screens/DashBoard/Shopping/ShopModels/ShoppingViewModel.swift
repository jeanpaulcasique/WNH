import Foundation
import SwiftUI

@MainActor
class ShoppingViewModel: ObservableObject {
    @Published var products: [ShopProduct] = []
    @Published var cart: [CartItem] = []
    @Published var isLoading = false
    @Published var searchText = ""
    @Published var selectedCategory: ProductCategory = .all
    
    // MARK: - Product Sections
    var recommendedProducts: [ShopProduct] {
        products.filter { $0.rating >= 4.5 }.prefix(10).map { $0 }
    }
    
    var weightGainProducts: [ShopProduct] {
        products.filter { $0.category == .supplements || $0.category == .nutrition }.prefix(8).map { $0 }
    }
    
    var fitnessEquipment: [ShopProduct] {
        products.filter { $0.category == .equipment }.prefix(8).map { $0 }
    }
    
    var nutritionProducts: [ShopProduct] {
        products.filter { $0.category == .nutrition }.prefix(8).map { $0 }
    }
    
    var trendingProducts: [ShopProduct] {
        products.filter { $0.isNew || $0.discountPercentage > 0.1 }.prefix(8).map { $0 }
    }
    
    var filteredProducts: [ShopProduct] {
        var filtered = products
        
        // Filter by category
        if selectedCategory != .all {
            filtered = filtered.filter { $0.category == selectedCategory }
        }
        
        // Filter by search text
        if !searchText.isEmpty {
            filtered = filtered.filter { product in
                product.name.localizedCaseInsensitiveContains(searchText) ||
                product.description.localizedCaseInsensitiveContains(searchText) ||
                product.category.displayName.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return filtered
    }
    
    var cartItemCount: Int {
        cart.reduce(0) { $0 + $1.quantity }
    }
    
    var cartTotal: Double {
        cart.reduce(0) { $0 + ($1.product.currentPrice * Double($1.quantity)) }
    }
    
    // MARK: - Product Management
    func loadProducts() {
        isLoading = true
        
        // Simulate API call
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.products = ProductData.sampleProducts
            self.isLoading = false
        }
    }
    
    // MARK: - Cart Management
    func addToCart(_ product: ShopProduct) {
        if let existingIndex = cart.firstIndex(where: { $0.product.id == product.id }) {
            cart[existingIndex].quantity += 1
        } else {
            cart.append(CartItem(product: product, quantity: 1))
        }
        
        // Haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
    }
    
    func removeFromCart(_ product: ShopProduct) {
        cart.removeAll { $0.product.id == product.id }
    }
    
    func updateQuantity(for product: ShopProduct, quantity: Int) {
        if let index = cart.firstIndex(where: { $0.product.id == product.id }) {
            if quantity <= 0 {
                cart.remove(at: index)
            } else {
                cart[index].quantity = quantity
            }
        }
    }
    
    func clearCart() {
        cart.removeAll()
    }
    
    // MARK: - Checkout
    func checkout() {
        // Here you would integrate with payment processing
        print("Processing checkout for $\(cartTotal)")
        
        // Simulate successful checkout
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.clearCart()
            // Show success message or navigate to confirmation
        }
    }
}

// MARK: - Data Models
struct ShopProduct: Identifiable, Codable, Equatable {
    let id = UUID()
    let name: String
    let description: String
    let category: ProductCategory
    let originalPrice: Double
    let currentPrice: Double
    let discountPercentage: Double
    let rating: Double
    let imageURL: String
    let isNew: Bool
    let inStock: Bool
    let specifications: [String: String]
    
    var isDiscounted: Bool {
        discountPercentage > 0
    }
}

struct CartItem: Identifiable {
    let id = UUID()
    let product: ShopProduct
    var quantity: Int
}

enum ProductCategory: String, CaseIterable, Codable {
    case all = "all"
    case supplements = "supplements"
    case equipment = "equipment"
    case clothing = "clothing"
    case accessories = "accessories"
    case nutrition = "nutrition"
    
    var displayName: String {
        switch self {
        case .all: return "All"
        case .supplements: return "Supplements"
        case .equipment: return "Equipment"
        case .clothing: return "Clothing"
        case .accessories: return "Accessories"
        case .nutrition: return "Nutrition"
        }
    }
    
    var icon: String {
        switch self {
        case .all: return "square.grid.2x2"
        case .supplements: return "pills"
        case .equipment: return "dumbbell"
        case .clothing: return "tshirt"
        case .accessories: return "watch"
        case .nutrition: return "leaf"
        }
    }
}

// MARK: - Sample Data
struct ProductData {
    static let sampleProducts: [ShopProduct] = [
        ShopProduct(
            name: "Premium Whey Protein",
            description: "High-quality whey protein isolate for muscle recovery and growth",
            category: .supplements,
            originalPrice: 89.99,
            currentPrice: 69.99,
            discountPercentage: 0.22,
            rating: 4.8,
            imageURL: "https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=400",
            isNew: true,
            inStock: true,
            specifications: [
                "Protein": "25g per serving",
                "Calories": "120 kcal",
                "Size": "2 lbs"
            ]
        ),
        ShopProduct(
            name: "Adjustable Dumbbells Set",
            description: "Professional grade adjustable dumbbells from 5-50 lbs",
            category: .equipment,
            originalPrice: 299.99,
            currentPrice: 249.99,
            discountPercentage: 0.17,
            rating: 4.9,
            imageURL: "https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400",
            isNew: false,
            inStock: true,
            specifications: [
                "Weight Range": "5-50 lbs",
                "Material": "Steel",
                "Warranty": "2 years"
            ]
        ),
        ShopProduct(
            name: "Performance Training Shirt",
            description: "Moisture-wicking athletic shirt for optimal performance",
            category: .clothing,
            originalPrice: 49.99,
            currentPrice: 39.99,
            discountPercentage: 0.20,
            rating: 4.6,
            imageURL: "https://images.unsplash.com/photo-1551698618-1dfe5d97d256?w=400",
            isNew: false,
            inStock: true,
            specifications: [
                "Material": "Polyester/Spandex",
                "Fit": "Athletic",
                "Sizes": "XS-XXL"
            ]
        ),
        ShopProduct(
            name: "Fitness Smartwatch",
            description: "Advanced fitness tracking with heart rate monitoring",
            category: .accessories,
            originalPrice: 199.99,
            currentPrice: 199.99,
            discountPercentage: 0.0,
            rating: 4.7,
            imageURL: "https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=400",
            isNew: true,
            inStock: true,
            specifications: [
                "Battery": "7 days",
                "Waterproof": "Yes",
                "GPS": "Built-in"
            ]
        ),
        ShopProduct(
            name: "Organic Protein Bars",
            description: "Delicious organic protein bars with natural ingredients",
            category: .nutrition,
            originalPrice: 24.99,
            currentPrice: 19.99,
            discountPercentage: 0.20,
            rating: 4.5,
            imageURL: "https://images.unsplash.com/photo-1604329760661-e71dc83f8f26?w=400",
            isNew: false,
            inStock: true,
            specifications: [
                "Protein": "15g per bar",
                "Calories": "200 kcal",
                "Count": "12 bars"
            ]
        ),
        ShopProduct(
            name: "Creatine Monohydrate",
            description: "Pure creatine monohydrate for strength and power",
            category: .supplements,
            originalPrice: 34.99,
            currentPrice: 29.99,
            discountPercentage: 0.14,
            rating: 4.8,
            imageURL: "https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?w=400",
            isNew: false,
            inStock: true,
            specifications: [
                "Creatine": "5g per serving",
                "Size": "500g",
                "Servings": "100"
            ]
        ),
        ShopProduct(
            name: "Yoga Mat Premium",
            description: "Non-slip yoga mat with alignment lines",
            category: .equipment,
            originalPrice: 79.99,
            currentPrice: 79.99,
            discountPercentage: 0.0,
            rating: 4.6,
            imageURL: "https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?w=400",
            isNew: true,
            inStock: true,
            specifications: [
                "Thickness": "6mm",
                "Material": "TPE",
                "Size": "72\" x 24\""
            ]
        ),
        ShopProduct(
            name: "Compression Leggings",
            description: "High-performance compression leggings for training",
            category: .clothing,
            originalPrice: 69.99,
            currentPrice: 55.99,
            discountPercentage: 0.20,
            rating: 4.7,
            imageURL: "https://images.unsplash.com/photo-1551698618-1dfe5d97d256?w=400",
            isNew: false,
            inStock: true,
            specifications: [
                "Material": "Nylon/Spandex",
                "Compression": "Medium",
                "Sizes": "XS-XXL"
            ]
        )
    ]
} 
