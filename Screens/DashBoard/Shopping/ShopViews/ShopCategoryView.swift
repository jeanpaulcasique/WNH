import SwiftUI

struct ShopCategoryView: View {
    @StateObject private var viewModel: ShopCategoryViewModel
    @Environment(\.dismiss) private var dismiss
    
    init(title: String, products: [ShopProduct], shoppingViewModel: ShoppingViewModel) {
        self._viewModel = StateObject(wrappedValue: ShopCategoryViewModel(
            title: title,
            products: products,
            viewModel: shoppingViewModel
        ))
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [Color.black, Color.gray.opacity(0.3), Color.black],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text(viewModel.title)
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text(viewModel.productsAvailableText)
                            .font(.system(size: 16))
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 16)
                    
                    // Products grid
                    ScrollView(showsIndicators: false) {
                        LazyVGrid(columns: [
                            GridItem(.flexible(), spacing: 16),
                            GridItem(.flexible(), spacing: 16)
                        ], spacing: 16) {
                            ForEach(viewModel.products) { product in
                                ProductCard(
                                    product: product,
                                    onTap: { viewModel.selectProduct(product) },
                                    onAddToCart: { viewModel.addToCart(product) }
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 100)
                    }
                }
            }
            .navigationBarHidden(true)
        }
        .sheet(item: $viewModel.showingProductDetail) { product in
            ProductDetailView(product: product, viewModel: viewModel.viewModel)
        }
        .overlay(
            // Close button
            VStack {
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 32))
                            .foregroundColor(.gray)
                            .background(Color.black.opacity(0.5))
                            .clipShape(Circle())
                    }
                    .padding(.top, 20)
                    .padding(.leading, 20)
                    
                    Spacer()
                }
                Spacer()
            }
        )
    }
}

// MARK: - Product Card for Category View
struct ProductCard: View {
    let product: ShopProduct
    let onTap: () -> Void
    let onAddToCart: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 0) {
                // Product image - Fixed size
                ZStack(alignment: .topTrailing) {
                    AsyncImage(url: URL(string: product.imageURL)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .overlay(
                                Image(systemName: "photo")
                                    .font(.system(size: 30))
                                    .foregroundColor(.gray)
                            )
                    }
                    .frame(height: 200)
                    .clipped()
                    .cornerRadius(20, corners: [.topLeft, .topRight])
                    
                    // Discount badge
                    if product.discountPercentage > 0 {
                        Text("-\(Int(product.discountPercentage * 100))%")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.red)
                            .cornerRadius(8)
                            .padding(12)
                    }
                }
                
                // Product info - Fixed height container
                VStack(alignment: .leading, spacing: 12) {
                    // Title and NEW badge - Fixed height
                    HStack {
                        Text(product.name)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .lineLimit(2)
                            .frame(height: 44, alignment: .top) // Fixed height for 2 lines
                        
                        Spacer()
                        
                        if product.isNew {
                            Text("NEW")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.green)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.green.opacity(0.2))
                                .cornerRadius(4)
                        }
                    }
                    
                    // Description - Fixed height
                    Text(product.description)
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                        .lineLimit(2)
                        .frame(height: 36, alignment: .top) // Fixed height for 2 lines
                    
                    // Price and rating - Fixed height
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            if product.discountPercentage > 0 {
                                Text("$\(String(format: "%.2f", product.originalPrice))")
                                    .font(.system(size: 14))
                                    .foregroundColor(.gray)
                                    .strikethrough()
                            }
                            
                            Text("$\(String(format: "%.2f", product.currentPrice))")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.yellow)
                        }
                        
                        Spacer()
                        
                        // Rating
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .font(.system(size: 12))
                                .foregroundColor(.yellow)
                            Text(String(format: "%.1f", product.rating))
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }
                    .frame(height: 40) // Fixed height
                    
                    // Add to cart button - Fixed height
                    Button(action: onAddToCart) {
                        HStack(spacing: 8) {
                            Image(systemName: "bag.badge.plus")
                                .font(.system(size: 16))
                            Text("Add to Cart")
                                .font(.system(size: 16, weight: .semibold))
                        }
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44) // Fixed height
                        .background(Color.yellow)
                        .cornerRadius(12)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(16)
                .frame(height: 200) // Fixed total height for info section
            }
        }
        .buttonStyle(PlainButtonStyle())
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [Color.yellow.opacity(0.6), Color.yellow.opacity(0.2), .clear],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.5
                )
        )
        .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 5)
        .frame(height: 400) // Fixed total card height
    }
}

// MARK: - Extensions
// cornerRadius and RoundedCorner extensions are defined in ShoppingView.swift

#if DEBUG
struct ShopCategoryView_Previews: PreviewProvider {
    static var previews: some View {
        ShopCategoryView(
            title: "Recommended for you",
            products: ShoppingViewModel().products,
            shoppingViewModel: ShoppingViewModel()
        )
        .preferredColorScheme(.dark)
    }
}
#endif
