import SwiftUI

struct ProductDetailView: View {
    let product: ShopProduct
    @ObservedObject var viewModel: ShoppingViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var selectedImageIndex = 0
    @State private var quantity = 1
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [Color.black, Color.gray.opacity(0.3), Color.black],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        headerSection
                        productImagesSection
                        productInfoSection
                        specificationsSection
                        addToCartSection
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .toolbar(.hidden, for: .navigationBar)
        }
    }
}

// MARK: - View Components
private extension ProductDetailView {
    var headerSection: some View {
        HStack {
            Button(action: { dismiss() }) {
                Image(systemName: "xmark")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.white)
            }
            
            Spacer()
            
            Text("Product Details")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .center)
            
            Spacer()
            
            Color.clear
                .frame(width: 40)
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
        .padding(.bottom, 20)
        .frame(maxWidth: .infinity)
    }
    
    var productImagesSection: some View {
        VStack(spacing: 16) {
            // Main product image
            GeometryReader { geometry in
                AsyncImage(url: URL(string: product.imageURL)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .overlay(
                            Image(systemName: "photo")
                                .font(.system(size: 40))
                                .foregroundColor(.gray)
                        )
                }
                .frame(width: geometry.size.width - 40, height: 300)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            LinearGradient(
                                colors: [Color.yellow.opacity(0.6), Color.yellow.opacity(0.2), .clear],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.5
                        )
                )
                .padding(.horizontal, 20)
            }
            .frame(height: 300)
            
            // Product badges
            HStack(spacing: 12) {
                if product.isNew {
                    BadgeView(text: "NEW", color: .green)
                }
                
                if product.discountPercentage > 0 {
                    BadgeView(text: "-\(Int(product.discountPercentage * 100))%", color: .red)
                }
                
                if product.inStock {
                    BadgeView(text: "IN STOCK", color: .blue)
                } else {
                    BadgeView(text: "OUT OF STOCK", color: .gray)
                }
                
                Spacer()
            }
            .padding(.horizontal, 20)
        }
        .frame(maxWidth: .infinity)
    }
    
    var productInfoSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Product name and category
            VStack(alignment: .leading, spacing: 8) {
                Text(LanguageManager.localizedString(product.name))
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                    .lineLimit(nil)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                HStack {
                    Image(systemName: product.category.icon)
                        .font(.system(size: 14))
                        .foregroundColor(.yellow)
                    
                    Text(product.category.displayName)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.gray)
                    
                    Spacer(minLength: 10)
                    
                    // Rating
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 14))
                            .foregroundColor(.yellow)
                        Text(String(format: "%.1f", product.rating))
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
                .frame(maxWidth: .infinity)
            }
            
            // Description
            Text(LanguageManager.localizedString(product.description))
                .font(.system(size: 16))
                .foregroundColor(.gray)
                .lineLimit(nil)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // Price section
            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .bottom, spacing: 12) {
                    VStack(alignment: .leading, spacing: 4) {
                        if product.discountPercentage > 0 {
                            Text(product.originalPrice.currencyText)
                                .font(.system(size: 18))
                                .foregroundColor(.gray)
                                .strikethrough()
                        }
                        
                        Text(product.currentPrice.currencyText)
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.yellow)
                    }
                    
                    if product.discountPercentage > 0 {
                        Text("\(LanguageManager.localizedString("Save")) \((product.originalPrice - product.currentPrice).currencyText)")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.green)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.green.opacity(0.2))
                            .cornerRadius(6)
                    }
                    
                    Spacer(minLength: 10)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    var specificationsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Specifications")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(spacing: 12) {
                ForEach(Array(product.specifications.keys.sorted()), id: \.self) { key in
                    HStack {
                        Text(LanguageManager.localizedString(key))
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                        
                        Spacer()
                        
                        Text(LanguageManager.localizedString(product.specifications[key] ?? ""))
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white)
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 16)
                    .background(Color.white.opacity(0.05))
                    .cornerRadius(8)
                    .frame(maxWidth: .infinity)
                }
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    var addToCartSection: some View {
        VStack(spacing: 16) {
            // Quantity selector
            HStack {
                Text("Quantity")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                
                Spacer(minLength: 10)
                
                HStack(spacing: 16) {
                    Button(action: { if quantity > 1 { quantity -= 1 } }) {
                        Image(systemName: "minus.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(quantity > 1 ? .yellow : .gray)
                    }
                    .disabled(quantity <= 1)
                    
                    Text("\(quantity)")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(minWidth: 30)
                    
                    Button(action: { quantity += 1 }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.yellow)
                    }
                }
            }
            .padding(.horizontal, 20)
            .frame(maxWidth: .infinity)
            
            // Add to cart button
            Button(action: addToCart) {
                HStack(spacing: 8) {
                    Image(systemName: "bag.badge.plus")
                        .font(.system(size: 20))
                    Text("\(LanguageManager.localizedString("Add to Cart")) - \((product.currentPrice * Double(quantity)).currencyText)")
                        .font(.system(size: 18, weight: .semibold))
                }
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.yellow)
                .cornerRadius(12)
            }
            .disabled(!product.inStock)
            .opacity(product.inStock ? 1.0 : 0.5)
            .padding(.horizontal, 20)
            .padding(.bottom, 40)
        }
        .padding(.top, 20)
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Badge View
struct BadgeView: View {
    let text: String
    let color: Color
    
    var body: some View {
        Text(LanguageManager.localizedString(text))
            .font(.system(size: 12, weight: .bold))
            .foregroundColor(color)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color.opacity(0.2))
            .cornerRadius(6)
    }
}

// MARK: - Helper Methods
private extension ProductDetailView {
    func addToCart() {
        viewModel.addToCart(product, quantity: quantity)
        
        // Haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
        
        // Dismiss after a short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            dismiss()
        }
    }
}

#if DEBUG
struct ProductDetailView_Previews: PreviewProvider {
    static var previews: some View {
        ProductDetailView(
            product: ProductData.sampleProducts[0],
            viewModel: ShoppingViewModel()
        )
        .preferredColorScheme(.dark)
    }
}
#endif 
