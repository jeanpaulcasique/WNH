import SwiftUI
import Combine

class ShopCategoryViewModel: ObservableObject {
    @Published var showingProductDetail: ShopProduct?
    @Published var title: String
    @Published var products: [ShopProduct]
    
    let viewModel: ShoppingViewModel
    private var cancellables = Set<AnyCancellable>()
    
    init(title: String, products: [ShopProduct], viewModel: ShoppingViewModel) {
        self.title = title
        self.products = products
        self.viewModel = viewModel
        
        print("🏪 ShopCategoryViewModel initialized")
        print("📦 Title: \(title)")
        print("📦 Products count: \(products.count)")
        print("📦 Products: \(products.map { $0.name })")
    }
    
    // MARK: - Public Methods
    func selectProduct(_ product: ShopProduct) {
        showingProductDetail = product
    }
    
    @MainActor
    func addToCart(_ product: ShopProduct) {
        viewModel.addToCart(product)
    }
    
    func dismiss() {
        showingProductDetail = nil
    }
    
    // MARK: - Computed Properties
    var productsCount: Int {
        products.count
    }
    
    var productsAvailableText: String {
        "\(productsCount) products available"
    }
}
