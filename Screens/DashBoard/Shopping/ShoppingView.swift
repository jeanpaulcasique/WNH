import SwiftUI

struct ShoppingView: View {
    @StateObject private var viewModel = ShoppingViewModel()
    @State private var searchText = ""
    @State private var selectedCategory: ProductCategory = .all
    @State private var showingCart = false
    @State private var showingProductDetail: ShopProduct?
    
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
                    headerSection
                    searchAndFilterSection
                    productsContent
                }
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showingCart) {
            CartView(viewModel: viewModel)
        }
        .sheet(item: $showingProductDetail) { product in
            ProductDetailView(product: product, viewModel: viewModel)
        }
        .onAppear {
            viewModel.loadProducts()
        }
    }
}

// MARK: - View Components
private extension ShoppingView {
    var headerSection: some View {
        VStack(spacing: 16) {
            HStack(spacing: 12) {
                Image(systemName: "cart.fill")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.yellow)
                
                Text("Samson Shop")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
            }
            
            Text("Premium products for your fitness journey")
                .font(.system(size: 16))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
        }
        .padding(.top, 20)
        .padding(.bottom, 16)
        .overlay(
            // TODO: MOVER ESTE BOTÓN DE LA CESTA A LA ESQUINA SUPERIOR DERECHA (20px del top, 20px de la derecha)
            // Cart button with badge - positioned in top right corner
            VStack {
                HStack {
                    Spacer()
                    Button(action: { showingCart = true }) {
                        ZStack {
                            Image(systemName: "bag.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.yellow)
                            
                            if viewModel.cartItemCount > 0 {
                                Text("\(viewModel.cartItemCount)")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.white)
                                    .frame(width: 20, height: 20)
                                    .background(Color.red)
                                    .clipShape(Circle())
                                    .offset(x: 12, y: -12)
                            }
                        }
                    }
                }
                Spacer()
            }
            .padding(.top, 25)
            .padding(.trailing, -20)
        )
    }
    
    var searchAndFilterSection: some View {
        VStack(spacing: 16) {
            // Search bar
            HStack(spacing: 12) {
                HStack(spacing: 8) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    TextField("Search products...", text: $searchText)
                        .textFieldStyle(PlainTextFieldStyle())
                        .foregroundColor(.white)
                }
                .padding(.vertical, 12)
                .padding(.horizontal, 16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.gray.opacity(0.2))
                )
            }
            
            // Category filters
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(ProductCategory.allCases, id: \.self) { category in
                        CategoryFilterButton(
                            category: category,
                            isSelected: selectedCategory == category,
                            onTap: { selectedCategory = category }
                        )
                    }
                }
                .padding(.horizontal, 2)
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
    }
    
    var productsContent: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: 20) {
                if viewModel.isLoading {
                    loadingView
                } else if viewModel.filteredProducts.isEmpty {
                    emptyStateView
                } else {
                    ForEach(viewModel.filteredProducts) { product in
                        ProductCard(
                            product: product,
                            onTap: { showingProductDetail = product },
                            onAddToCart: { viewModel.addToCart(product) }
                        )
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 100)
        }
    }
    
    var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
                .progressViewStyle(CircularProgressViewStyle(tint: .yellow))
            
            Text("Loading products...")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 60)
    }
    
    var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "bag")
                .font(.system(size: 64))
                .foregroundColor(.gray)
            
            Text("No products found")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.gray)
            
            Text("Try adjusting your search or filters")
                .font(.system(size: 16))
                .foregroundColor(.gray.opacity(0.7))
        }
        .padding(.top, 60)
    }
}

// MARK: - Product Card
struct ProductCard: View {
    let product: ShopProduct
    let onTap: () -> Void
    let onAddToCart: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 0) {
                // Product image
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
                
                // Product info
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(product.name)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
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
                    
                    Text(product.description)
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                        .lineLimit(2)
                    
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
                    
                    // Add to cart button
                    Button(action: onAddToCart) {
                        HStack(spacing: 8) {
                            Image(systemName: "bag.badge.plus")
                                .font(.system(size: 16))
                            Text("Add to Cart")
                                .font(.system(size: 16, weight: .semibold))
                        }
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.yellow)
                        .cornerRadius(12)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(16)
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

// MARK: - Category Filter Button
struct CategoryFilterButton: View {
    let category: ProductCategory
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 6) {
                Image(systemName: category.icon)
                    .font(.system(size: 12))
                    .foregroundColor(isSelected ? .black : .yellow)
                Text(category.displayName)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(isSelected ? .black : .white)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                isSelected ? Color.yellow : Color.white.opacity(0.08)
            )
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [Color.yellow.opacity(0.6), Color.yellow.opacity(0.2), .clear],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5
                    )
            )
            .shadow(color: Color.yellow.opacity(0.15), radius: 8, x: 0, y: 4)
        }
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}

#if DEBUG
struct ShoppingView_Previews: PreviewProvider {
    static var previews: some View {
        ShoppingView()
            .preferredColorScheme(.dark)
    }
}
#endif

