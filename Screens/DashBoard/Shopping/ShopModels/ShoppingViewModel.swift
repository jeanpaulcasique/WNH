import Foundation
import SwiftUI

@MainActor
class ShoppingViewModel: ObservableObject {
    @Published var products: [ShopProduct] = []
    @Published var cart: [CartItem] = []
    @Published var orders: [ShopOrder] = []
    @Published var isLoading = false
    @Published var searchText = ""
    @Published var selectedCategory: ProductCategory = .all
    @Published var lastCompletedOrder: ShopOrder?
    
    private let paymentGateway: ShoppingPaymentGateway
    private let orderStore: ShoppingOrderStore
    
    init(
        paymentGateway: ShoppingPaymentGateway = MockBankPaymentGateway(),
        orderStore: ShoppingOrderStore = UserDefaultsShoppingOrderStore()
    ) {
        self.paymentGateway = paymentGateway
        self.orderStore = orderStore
        loadOrders()
    }
    
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
        
        if selectedCategory != .all {
            filtered = filtered.filter { $0.category == selectedCategory }
        }
        
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        if !query.isEmpty {
            filtered = filtered.filter { product in
                product.name.localizedCaseInsensitiveContains(query) ||
                product.description.localizedCaseInsensitiveContains(query) ||
                product.category.displayName.localizedCaseInsensitiveContains(query)
            }
        }
        
        return filtered
    }
    
    var cartItemCount: Int {
        cart.reduce(0) { $0 + $1.quantity }
    }
    
    var cartSubtotal: Double {
        cart.reduce(0) { $0 + $1.lineTotal }
    }
    
    var shippingCost: Double {
        guard !cart.isEmpty else { return 0 }
        return cartSubtotal >= 75 ? 0 : 7.99
    }
    
    var taxAmount: Double {
        cartSubtotal * 0.0825
    }
    
    var cartTotal: Double {
        cartSubtotal + shippingCost + taxAmount
    }
    
    var orderSummary: ShopOrderSummary {
        ShopOrderSummary(
            itemCount: cartItemCount,
            subtotal: cartSubtotal,
            shipping: shippingCost,
            tax: taxAmount,
            total: cartTotal
        )
    }
    
    var activeOrders: [ShopOrder] {
        orders.filter { !$0.status.isClosed }
    }
    
    var buyAgainProducts: [ShopProduct] {
        var seen = Set<UUID>()
        return orders
            .flatMap { $0.items.map(\.product) }
            .filter { product in
                guard !seen.contains(product.id) else { return false }
                seen.insert(product.id)
                return true
            }
    }
    
    var returnRequests: [ShopOrder] {
        orders.filter { $0.returnRequest != nil }
    }
    
    // MARK: - Product Management
    func loadProducts() {
        guard products.isEmpty else { return }
        
        isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            self.products = ProductData.sampleProducts
            self.isLoading = false
        }
    }
    
    // MARK: - Cart Management
    func addToCart(_ product: ShopProduct, quantity: Int = 1) {
        guard product.inStock, quantity > 0 else { return }
        
        if let existingIndex = cart.firstIndex(where: { $0.product.id == product.id }) {
            cart[existingIndex].quantity = min(cart[existingIndex].quantity + quantity, 99)
        } else {
            cart.append(CartItem(product: product, quantity: min(quantity, 99)))
        }
        
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }
    
    func removeFromCart(_ product: ShopProduct) {
        cart.removeAll { $0.product.id == product.id }
    }
    
    func updateQuantity(for product: ShopProduct, quantity: Int) {
        if let index = cart.firstIndex(where: { $0.product.id == product.id }) {
            if quantity <= 0 {
                cart.remove(at: index)
            } else {
                cart[index].quantity = min(quantity, 99)
            }
        }
    }
    
    func clearCart() {
        cart.removeAll()
    }
    
    // MARK: - Checkout
    func placeOrder(with checkout: CheckoutDetails) async throws -> ShopOrder {
        guard !cart.isEmpty else {
            throw ShopCheckoutError.emptyCart
        }
        
        let validationErrors = checkout.validationErrors()
        guard validationErrors.isEmpty else {
            throw ShopCheckoutError.validation(validationErrors)
        }
        
        let summary = orderSummary
        let orderNumber = Self.makeOrderNumber()
        let paymentRequest = PaymentAuthorizationRequest(
            amount: summary.total,
            currency: "USD",
            orderReference: orderNumber,
            customerEmail: checkout.email,
            cardLastFour: checkout.cardLastFour
        )
        
        let authorization: PaymentAuthorization
        do {
            authorization = try await paymentGateway.authorize(paymentRequest)
        } catch {
            throw ShopCheckoutError.payment(error.localizedDescription)
        }
        
        let order = ShopOrder(
            orderNumber: orderNumber,
            createdAt: Date(),
            estimatedDelivery: Calendar.current.date(byAdding: .day, value: 4, to: Date()) ?? Date(),
            items: cart,
            totals: summary.totals,
            customerName: checkout.fullName.trimmed,
            customerEmail: checkout.email.trimmed,
            customerPhone: checkout.phone.trimmed,
            shippingAddress: checkout.shippingAddress,
            payment: PaymentSnapshot(
                method: .card,
                maskedReference: checkout.maskedCardNumber,
                authorizationID: authorization.id,
                bankReference: authorization.bankReference,
                paidAt: authorization.approvedAt
            ),
            status: .paid,
            timeline: ShopOrderTimeline.defaultTimeline(createdAt: Date())
        )
        
        orders.insert(order, at: 0)
        lastCompletedOrder = order
        saveOrders()
        clearCart()
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        return order
    }
    
    func reorder(_ order: ShopOrder) {
        for item in order.items {
            addToCart(item.product, quantity: item.quantity)
        }
    }
    
    func requestReturn(for order: ShopOrder, reason: String = "Customer request") {
        guard let index = orders.firstIndex(where: { $0.id == order.id }) else { return }
        
        orders[index].returnRequest = ReturnRequest(
            createdAt: Date(),
            reason: reason,
            status: .requested
        )
        saveOrders()
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
    
    func advanceTracking(for order: ShopOrder) {
        guard let index = orders.firstIndex(where: { $0.id == order.id }) else { return }
        orders[index].advanceStatus()
        saveOrders()
    }
    
    private func loadOrders() {
        orders = orderStore.loadOrders().sorted { $0.createdAt > $1.createdAt }
        
        if orders.isEmpty {
            orders = ProductData.demoOrders()
            saveOrders()
        }
    }
    
    private func saveOrders() {
        orderStore.saveOrders(orders)
    }
    
    private static func makeOrderNumber() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyMMddHHmmss"
        return "WNH-\(formatter.string(from: Date()))-\(Int.random(in: 100...999))"
    }
}

// MARK: - Checkout Data
struct CheckoutDetails: Equatable {
    var fullName = ""
    var email = ""
    var phone = ""
    var addressLine1 = ""
    var addressLine2 = ""
    var city = ""
    var region = ""
    var postalCode = ""
    var country = "United States"
    var cardholderName = ""
    var cardNumber = ""
    var expiration = ""
    var securityCode = ""
    var billingSameAsShipping = true
    
    var shippingAddress: ShippingAddress {
        ShippingAddress(
            line1: addressLine1.trimmed,
            line2: addressLine2.trimmed,
            city: city.trimmed,
            region: region.trimmed,
            postalCode: postalCode.trimmed,
            country: country.trimmed
        )
    }
    
    var cardDigits: String {
        cardNumber.filter(\.isNumber)
    }
    
    var cardLastFour: String {
        String(cardDigits.suffix(4))
    }
    
    var maskedCardNumber: String {
        guard !cardLastFour.isEmpty else { return LanguageManager.localizedString("Card ending ----") }
        return "\(LanguageManager.localizedString("Card ending")) \(cardLastFour)"
    }
    
    func shippingValidationErrors() -> [String] {
        var errors: [String] = []
        
        if fullName.trimmed.count < 2 { errors.append("Enter the recipient name.") }
        if !email.trimmed.contains("@") || !email.trimmed.contains(".") { errors.append("Enter a valid email.") }
        if phone.filter(\.isNumber).count < 7 { errors.append("Enter a valid phone number.") }
        if addressLine1.trimmed.count < 4 { errors.append("Enter the delivery address.") }
        if city.trimmed.isEmpty { errors.append("Enter the city.") }
        if region.trimmed.isEmpty { errors.append("Enter the state or region.") }
        if postalCode.trimmed.count < 3 { errors.append("Enter the postal code.") }
        if country.trimmed.isEmpty { errors.append("Enter the country.") }
        
        return errors
    }
    
    func paymentValidationErrors() -> [String] {
        var errors: [String] = []
        
        if cardholderName.trimmed.count < 2 { errors.append("Enter the cardholder name.") }
        if !(12...19).contains(cardDigits.count) { errors.append("Enter a valid card number.") }
        if !isValidExpiration { errors.append("Enter a valid expiration date in MM/YY format.") }
        if !(3...4).contains(securityCode.filter(\.isNumber).count) { errors.append("Enter a valid security code.") }
        
        return errors
    }
    
    func validationErrors() -> [String] {
        shippingValidationErrors() + paymentValidationErrors()
    }
    
    private var isValidExpiration: Bool {
        let digits = expiration.filter(\.isNumber)
        guard digits.count == 4,
              let month = Int(digits.prefix(2)),
              let year = Int(digits.suffix(2)),
              (1...12).contains(month) else {
            return false
        }
        
        let calendar = Calendar.current
        let currentYear = calendar.component(.year, from: Date()) % 100
        let currentMonth = calendar.component(.month, from: Date())
        
        return year > currentYear || (year == currentYear && month >= currentMonth)
    }
}

struct ShopOrderSummary {
    let itemCount: Int
    let subtotal: Double
    let shipping: Double
    let tax: Double
    let total: Double
    
    var totals: ShopOrderTotals {
        ShopOrderTotals(
            subtotal: subtotal,
            shipping: shipping,
            tax: tax,
            total: total
        )
    }
}

// MARK: - Order Storage
protocol ShoppingOrderStore {
    func loadOrders() -> [ShopOrder]
    func saveOrders(_ orders: [ShopOrder])
}

struct UserDefaultsShoppingOrderStore: ShoppingOrderStore {
    private let userDefaults: UserDefaults
    private let storageKey: String
    
    init(userDefaults: UserDefaults = .standard, storageKey: String = "SamsonShopOrders") {
        self.userDefaults = userDefaults
        self.storageKey = storageKey
    }
    
    func loadOrders() -> [ShopOrder] {
        guard let data = userDefaults.data(forKey: storageKey),
              let decoded = try? JSONDecoder().decode([ShopOrder].self, from: data) else {
            return []
        }
        
        return decoded
    }
    
    func saveOrders(_ orders: [ShopOrder]) {
        if let encoded = try? JSONEncoder().encode(orders) {
            userDefaults.set(encoded, forKey: storageKey)
        }
    }
}

// MARK: - Payment Gateway
protocol ShoppingPaymentGateway {
    func authorize(_ request: PaymentAuthorizationRequest) async throws -> PaymentAuthorization
}

struct MockBankPaymentGateway: ShoppingPaymentGateway {
    func authorize(_ request: PaymentAuthorizationRequest) async throws -> PaymentAuthorization {
        try await Task.sleep(nanoseconds: 1_000_000_000)
        
        guard request.amount > 0 else {
            throw ShopCheckoutError.payment("The amount could not be authorized.")
        }
        
        return PaymentAuthorization(
            id: UUID().uuidString,
            bankReference: "BANK-SANDBOX-\(Int.random(in: 100000...999999))",
            approvedAt: Date()
        )
    }
}

struct PaymentAuthorizationRequest {
    let amount: Double
    let currency: String
    let orderReference: String
    let customerEmail: String
    let cardLastFour: String
}

struct PaymentAuthorization {
    let id: String
    let bankReference: String
    let approvedAt: Date
}

enum ShopCheckoutError: LocalizedError {
    case emptyCart
    case validation([String])
    case payment(String)
    
    var errorDescription: String? {
        switch self {
        case .emptyCart:
            return "Your cart is empty."
        case .validation(let errors):
            return errors.first ?? "Review the checkout details."
        case .payment(let message):
            return message
        }
    }
}

// MARK: - Data Models
struct ShopProduct: Identifiable, Codable, Equatable {
    let id: UUID
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
    
    init(
        id: UUID = UUID(),
        name: String,
        description: String,
        category: ProductCategory,
        originalPrice: Double,
        currentPrice: Double,
        discountPercentage: Double,
        rating: Double,
        imageURL: String,
        isNew: Bool,
        inStock: Bool,
        specifications: [String: String]
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.category = category
        self.originalPrice = originalPrice
        self.currentPrice = currentPrice
        self.discountPercentage = discountPercentage
        self.rating = rating
        self.imageURL = imageURL
        self.isNew = isNew
        self.inStock = inStock
        self.specifications = specifications
    }
    
    var isDiscounted: Bool {
        discountPercentage > 0
    }
}

struct CartItem: Identifiable, Codable, Equatable {
    let id: UUID
    let product: ShopProduct
    var quantity: Int
    
    init(id: UUID = UUID(), product: ShopProduct, quantity: Int) {
        self.id = id
        self.product = product
        self.quantity = quantity
    }
    
    var lineTotal: Double {
        product.currentPrice * Double(quantity)
    }
}

struct ShippingAddress: Codable, Equatable {
    let line1: String
    let line2: String
    let city: String
    let region: String
    let postalCode: String
    let country: String
    
    var displayLines: [String] {
        [
            line1,
            line2,
            "\(city), \(region) \(postalCode)",
            country
        ].filter { !$0.isEmpty }
    }
}

struct ShopOrder: Identifiable, Codable, Equatable {
    let id: UUID
    let orderNumber: String
    let createdAt: Date
    let estimatedDelivery: Date
    let items: [CartItem]
    let totals: ShopOrderTotals
    let customerName: String
    let customerEmail: String
    let customerPhone: String
    let shippingAddress: ShippingAddress
    let payment: PaymentSnapshot
    var status: ShopOrderStatus
    var timeline: [ShopOrderTimeline]
    var returnRequest: ReturnRequest?
    
    init(
        id: UUID = UUID(),
        orderNumber: String,
        createdAt: Date,
        estimatedDelivery: Date,
        items: [CartItem],
        totals: ShopOrderTotals,
        customerName: String,
        customerEmail: String,
        customerPhone: String,
        shippingAddress: ShippingAddress,
        payment: PaymentSnapshot,
        status: ShopOrderStatus,
        timeline: [ShopOrderTimeline],
        returnRequest: ReturnRequest? = nil
    ) {
        self.id = id
        self.orderNumber = orderNumber
        self.createdAt = createdAt
        self.estimatedDelivery = estimatedDelivery
        self.items = items
        self.totals = totals
        self.customerName = customerName
        self.customerEmail = customerEmail
        self.customerPhone = customerPhone
        self.shippingAddress = shippingAddress
        self.payment = payment
        self.status = status
        self.timeline = timeline
        self.returnRequest = returnRequest
    }
    
    var itemCount: Int {
        items.reduce(0) { $0 + $1.quantity }
    }
    
    mutating func advanceStatus() {
        guard let next = status.next else { return }
        status = next
        
        if let index = timeline.firstIndex(where: { $0.status == next }) {
            timeline[index].completedAt = Date()
        }
    }
}

struct ShopOrderTotals: Codable, Equatable {
    let subtotal: Double
    let shipping: Double
    let tax: Double
    let total: Double
}

struct PaymentSnapshot: Codable, Equatable {
    let method: PaymentMethod
    let maskedReference: String
    let authorizationID: String
    let bankReference: String
    let paidAt: Date
}

enum PaymentMethod: String, Codable {
    case card
    
    var displayName: String {
        switch self {
        case .card: return LanguageManager.localizedString("Card")
        }
    }
}

enum ShopOrderStatus: String, Codable, CaseIterable {
    case paid
    case preparing
    case shipped
    case delivered
    case cancelled
    
    var displayName: String {
        switch self {
        case .paid: return LanguageManager.localizedString("Paid")
        case .preparing: return LanguageManager.localizedString("Preparing")
        case .shipped: return LanguageManager.localizedString("Shipped")
        case .delivered: return LanguageManager.localizedString("Delivered")
        case .cancelled: return LanguageManager.localizedString("Cancelled")
        }
    }
    
    var icon: String {
        switch self {
        case .paid: return "checkmark.seal.fill"
        case .preparing: return "shippingbox.fill"
        case .shipped: return "truck.box.fill"
        case .delivered: return "house.fill"
        case .cancelled: return "xmark.circle.fill"
        }
    }
    
    var tint: Color {
        switch self {
        case .paid: return .green
        case .preparing: return .yellow
        case .shipped: return .blue
        case .delivered: return .green
        case .cancelled: return .red
        }
    }
    
    var next: ShopOrderStatus? {
        switch self {
        case .paid: return .preparing
        case .preparing: return .shipped
        case .shipped: return .delivered
        case .delivered, .cancelled: return nil
        }
    }
    
    var isClosed: Bool {
        self == .delivered || self == .cancelled
    }
}

struct ShopOrderTimeline: Identifiable, Codable, Equatable {
    let id: UUID
    let status: ShopOrderStatus
    let title: String
    var completedAt: Date?
    
    init(id: UUID = UUID(), status: ShopOrderStatus, title: String, completedAt: Date? = nil) {
        self.id = id
        self.status = status
        self.title = title
        self.completedAt = completedAt
    }
    
    static func defaultTimeline(createdAt: Date) -> [ShopOrderTimeline] {
        [
            ShopOrderTimeline(status: .paid, title: "Payment authorized", completedAt: createdAt),
            ShopOrderTimeline(status: .preparing, title: "Preparing order"),
            ShopOrderTimeline(status: .shipped, title: "On the way"),
            ShopOrderTimeline(status: .delivered, title: "Delivered")
        ]
    }
}

struct ReturnRequest: Codable, Equatable {
    let createdAt: Date
    let reason: String
    var status: ReturnRequestStatus
}

enum ReturnRequestStatus: String, Codable {
    case requested
    case approved
    case refunded
    
    var displayName: String {
        switch self {
        case .requested: return LanguageManager.localizedString("Requested")
        case .approved: return LanguageManager.localizedString("Approved")
        case .refunded: return LanguageManager.localizedString("Refunded")
        }
    }
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
        case .all: return LanguageManager.localizedString("All")
        case .supplements: return LanguageManager.localizedString("Supplements")
        case .equipment: return LanguageManager.localizedString("Equipment")
        case .clothing: return LanguageManager.localizedString("Clothing")
        case .accessories: return LanguageManager.localizedString("Accessories")
        case .nutrition: return LanguageManager.localizedString("Nutrition")
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

private extension String {
    var trimmed: String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

// MARK: - Sample Data
struct ProductData {
    static let sampleProducts: [ShopProduct] = [
        ShopProduct(
            name: "Samson Starter Kit",
            description: "Demo bundle with protein, shaker and recovery snacks to test the full shopping flow",
            category: .nutrition,
            originalPrice: 129.99,
            currentPrice: 99.99,
            discountPercentage: 0.23,
            rating: 4.9,
            imageURL: "https://images.unsplash.com/photo-1593095948071-474c5cc2989d?w=400",
            isNew: true,
            inStock: true,
            specifications: [
                "Bundle": "Protein + shaker + snacks",
                "Use": "Demo checkout product",
                "Shipping": "Standard"
            ]
        ),
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
    
    static func demoOrders(now: Date = Date()) -> [ShopOrder] {
        let starterKit = sampleProducts[0]
        let whey = sampleProducts[1]
        let smartwatch = sampleProducts[4]
        let yogaMat = sampleProducts[7]
        
        let activeCreatedAt = day(-3, from: now)
        let activeTotals = ShopOrderTotals(
            subtotal: starterKit.currentPrice + whey.currentPrice,
            shipping: 0,
            tax: (starterKit.currentPrice + whey.currentPrice) * 0.0825,
            total: starterKit.currentPrice + whey.currentPrice + ((starterKit.currentPrice + whey.currentPrice) * 0.0825)
        )
        let activeOrder = ShopOrder(
            orderNumber: "WNH-DEMO-TRACK",
            createdAt: activeCreatedAt,
            estimatedDelivery: day(2, from: now),
            items: [
                CartItem(product: starterKit, quantity: 1),
                CartItem(product: whey, quantity: 1)
            ],
            totals: activeTotals,
            customerName: "Demo Customer",
            customerEmail: "demo@samson.app",
            customerPhone: "+1 555 0100",
            shippingAddress: ShippingAddress(
                line1: "100 Fitness Ave",
                line2: "Apt 4B",
                city: "Miami",
                region: "FL",
                postalCode: "33101",
                country: "United States"
            ),
            payment: PaymentSnapshot(
                method: .card,
                maskedReference: "Card ending 4242",
                authorizationID: "DEMO-AUTH-TRACK",
                bankReference: "BANK-SANDBOX-100001",
                paidAt: activeCreatedAt
            ),
            status: .shipped,
            timeline: [
                ShopOrderTimeline(status: .paid, title: "Payment authorized", completedAt: activeCreatedAt),
                ShopOrderTimeline(status: .preparing, title: "Preparing order", completedAt: day(-2, from: now)),
                ShopOrderTimeline(status: .shipped, title: "On the way", completedAt: day(-1, from: now)),
                ShopOrderTimeline(status: .delivered, title: "Delivered")
            ]
        )
        
        let deliveredCreatedAt = day(-12, from: now)
        let deliveredSubtotal = smartwatch.currentPrice + yogaMat.currentPrice
        let deliveredTotals = ShopOrderTotals(
            subtotal: deliveredSubtotal,
            shipping: 0,
            tax: deliveredSubtotal * 0.0825,
            total: deliveredSubtotal + (deliveredSubtotal * 0.0825)
        )
        let deliveredOrder = ShopOrder(
            orderNumber: "WNH-DEMO-HISTORY",
            createdAt: deliveredCreatedAt,
            estimatedDelivery: day(-7, from: now),
            items: [
                CartItem(product: smartwatch, quantity: 1),
                CartItem(product: yogaMat, quantity: 1)
            ],
            totals: deliveredTotals,
            customerName: "Demo Customer",
            customerEmail: "demo@samson.app",
            customerPhone: "+1 555 0100",
            shippingAddress: ShippingAddress(
                line1: "100 Fitness Ave",
                line2: "Apt 4B",
                city: "Miami",
                region: "FL",
                postalCode: "33101",
                country: "United States"
            ),
            payment: PaymentSnapshot(
                method: .card,
                maskedReference: "Card ending 4242",
                authorizationID: "DEMO-AUTH-HISTORY",
                bankReference: "BANK-SANDBOX-100002",
                paidAt: deliveredCreatedAt
            ),
            status: .delivered,
            timeline: [
                ShopOrderTimeline(status: .paid, title: "Payment authorized", completedAt: deliveredCreatedAt),
                ShopOrderTimeline(status: .preparing, title: "Preparing order", completedAt: day(-11, from: now)),
                ShopOrderTimeline(status: .shipped, title: "On the way", completedAt: day(-9, from: now)),
                ShopOrderTimeline(status: .delivered, title: "Delivered", completedAt: day(-7, from: now))
            ],
            returnRequest: ReturnRequest(
                createdAt: day(-4, from: now),
                reason: "Demo return request",
                status: .requested
            )
        )
        
        return [activeOrder, deliveredOrder]
    }
    
    private static func day(_ value: Int, from date: Date) -> Date {
        Calendar.current.date(byAdding: .day, value: value, to: date) ?? date
    }
}
