import SwiftUI

struct ShopCategoryView: View {
    let title: String
    let products: [ShopProduct]
    @ObservedObject var shoppingViewModel: ShoppingViewModel
    @State private var showingProductDetail: ShopProduct?
    @State private var showingCart = false
    @Environment(\.dismiss) private var dismiss
    
    init(title: String, products: [ShopProduct], shoppingViewModel: ShoppingViewModel) {
        print("🛍️ ShopCategoryView init called with title: \(title), products: \(products.count)")
        print("📦 Products in init: \(products.map { $0.name })")
        self.title = title
        self.products = products
        self._shoppingViewModel = ObservedObject(wrappedValue: shoppingViewModel)
    }
    
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
                
                VStack(spacing: 0) {
                    HStack {
                        Button(action: { dismiss() }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 32))
                                .foregroundColor(.yellow)
                                .background(Color.black.opacity(0.4))
                                .clipShape(Circle())
                        }
                        .padding(.leading, 20)

                        Spacer()
                        
                        // Cart button (sincronizado con ShoppingView)
                        Button(action: { 
                            showingCart = true
                        }) {
                            ZStack {
                                Image(systemName: "bag.fill")
                                    .font(.system(size: 28))
                                    .foregroundColor(.yellow)
                                
                                if shoppingViewModel.cartItemCount > 0 {
                                    Text("\(shoppingViewModel.cartItemCount)")
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundColor(.white)
                                        .frame(width: 16, height: 16)
                                        .background(Color.red)
                                        .clipShape(Circle())
                                        .offset(x: 8, y: -8)
                                    }
                            }
                        }
                        .padding(.trailing, 20)
                    }
                    .padding(.top, 10)
                    
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text(title)
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("\(products.count) products available")
                            .font(.system(size: 16))
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    .padding(.bottom, 20)
                    
                    // Products grid
                    ScrollView(showsIndicators: false) {
                        LazyVGrid(columns: [
                            GridItem(.flexible(), spacing: 16),
                            GridItem(.flexible(), spacing: 16)
                        ], spacing: 16) {
                            ForEach(products) { product in
                                HorizontalProductCard(
                                    product: product,
                                    onTap: { showingProductDetail = product },
                                    onAddToCart: { shoppingViewModel.addToCart(product) }
                                )
                                .frame(width: UIScreen.main.bounds.width / 2 - 28, height: 300)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 120)
                    }
                }
            }
            .navigationBarHidden(true)
        }
        .sheet(item: $showingProductDetail) { product in
            ProductDetailView(product: product, viewModel: shoppingViewModel)
                .transition(.move(edge: .bottom))
        }
        .sheet(isPresented: $showingCart) {
            CartView(viewModel: shoppingViewModel)
        }
        .onAppear {
            print("🛍️ ShopCategoryView appeared")
            print("📦 Title: \(title)")
            print("📦 Products count: \(products.count)")
            print("📦 Products: \(products.map { $0.name })")
            print("✅ View ready with \(products.count) products")
        }
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
                            .aspectRatio(contentMode: .fit)
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
                            .fixedSize(horizontal: false, vertical: true)
                            .lineLimit(2)
                        
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
                        .fixedSize(horizontal: false, vertical: true)
                        .lineLimit(2)
                    
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
                                .padding(.top, 4)
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
                    Button(action: {
                        let generator = UIImpactFeedbackGenerator(style: .medium)
                        generator.impactOccurred()
                        withAnimation(.spring()) {
                            onAddToCart()
                        }
                    }) {
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
                .padding(18)
                .frame(height: 220) // Fixed total height for info section
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
