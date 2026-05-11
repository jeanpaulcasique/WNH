import StoreKit
import Foundation
import Combine

enum PaymentResult {
    case success(String)
    case failure(Error)
    case cancelled
}

enum StoreKitError: LocalizedError {
    case networkError
    case userCancelled
    case paymentNotAllowed
    case productNotFound
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .networkError: return LanguageManager.localizedString("Network connection required")
        case .userCancelled: return LanguageManager.localizedString("Purchase cancelled by user")
        case .paymentNotAllowed: return LanguageManager.localizedString("Payments not allowed")
        case .productNotFound: return LanguageManager.localizedString("Product not found")
        case .unknown: return LanguageManager.localizedString("Unknown payment error")
        }
    }
}

@MainActor
class PaymentService: ObservableObject {
    static let shared = PaymentService()
    
    @Published private(set) var products: [Product] = []
    @Published private(set) var purchasedProductIDs: Set<String> = []
    
    private let productIDs: Set<String> = [
        "monthly", "three_months", "yearly"
    ]
    
    let purchaseCompletedPublisher = PassthroughSubject<PaymentResult, Never>()
    
    private init() {
        Task {
            await updatePurchasedProducts()
            for await result in Transaction.updates {
                if case .verified(let transaction) = result {
                    await transaction.finish()
                    await updatePurchasedProducts()
                }
            }
        }
    }
    
    func loadProducts() async throws {
        do {
            let storeProducts = try await Product.products(for: productIDs)
            products = storeProducts.sorted { $0.price < $1.price }
        } catch {
            throw StoreKitError.networkError
        }
    }
    
    func purchase(productId: String) async throws -> Bool {
        guard let product = products.first(where: { $0.id == productId }) else {
            throw StoreKitError.productNotFound
        }
        
        do {
            let result = try await product.purchase()
            
            switch result {
            case .success(let verification):
                if case .verified(let transaction) = verification {
                    await transaction.finish()
                    await updatePurchasedProducts()
                    purchaseCompletedPublisher.send(.success(productId))
                    return true
                }
                return false
                
            case .userCancelled:
                purchaseCompletedPublisher.send(.cancelled)
                return false
                
            case .pending:
                return false
                
            @unknown default:
                return false
            }
        } catch {
            let storeError: StoreKitError
            
            if let skError = error as? SKError {
                switch skError.code {
                case .paymentCancelled:
                    storeError = .userCancelled
                case .paymentNotAllowed:
                    storeError = .paymentNotAllowed
                case .cloudServiceNetworkConnectionFailed:
                    storeError = .networkError
                default:
                    storeError = .unknown
                }
            } else {
                storeError = .unknown
            }
            
            purchaseCompletedPublisher.send(.failure(storeError))
            throw storeError
        }
    }
    
    func restorePurchases() async throws -> Bool {
        do {
            try await AppStore.sync()
            await updatePurchasedProducts()
            return !purchasedProductIDs.isEmpty
        } catch {
            throw StoreKitError.networkError
        }
    }
    
    func getProduct(for id: String) -> Product? {
        return products.first { $0.id == id }
    }
    
    private func updatePurchasedProducts() async {
        var purchasedProducts: Set<String> = []
        
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result {
                purchasedProducts.insert(transaction.productID)
            }
        }
        
        purchasedProductIDs = purchasedProducts
    }
}
