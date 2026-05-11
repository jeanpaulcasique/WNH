import SwiftUI

struct ShoppingView: View {
    @StateObject private var viewModel = ShoppingViewModel()
    @State private var selectedOrderSection: OrderSection = .shop
    @State private var showingCart = false
    @State private var showingProductDetail: ShopProduct?
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [Color.black, Color.gray.opacity(0.28), Color.black],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    headerSection
                    searchAndFilterSection
                    mainContent
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

private extension ShoppingView {
    var headerSection: some View {
        ZStack {
            VStack(spacing: 6) {
                HStack(spacing: 12) {
                    Image(systemName: "cart.fill")
                        .font(.system(size: 30, weight: .bold))
                        .foregroundColor(.yellow)
                    
                    Text("Samson Shop")
                        .font(.system(size: 30, weight: .bold))
                        .foregroundColor(.white)
                }
                
                Text("Gear, nutrition and recovery")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            
            HStack {
                Spacer()
                
                Button(action: { showingCart = true }) {
                    ZStack(alignment: .topTrailing) {
                        Image(systemName: "bag.fill")
                            .font(.system(size: 25, weight: .semibold))
                            .foregroundColor(.yellow)
                            .frame(width: 48, height: 48)
                            .background(Color.white.opacity(0.08))
                            .clipShape(Circle())
                        
                        if viewModel.cartItemCount > 0 {
                            Text("\(viewModel.cartItemCount)")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.white)
                                .frame(width: 18, height: 18)
                                .background(Color.red)
                                .clipShape(Circle())
                                .offset(x: 2, y: -2)
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
        .padding(.bottom, 16)
    }
    
    var searchAndFilterSection: some View {
        VStack(spacing: 12) {
            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                
                TextField("Search products", text: $viewModel.searchText)
                    .textFieldStyle(PlainTextFieldStyle())
                    .foregroundColor(.white)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                
                if !viewModel.searchText.isEmpty {
                    Button(action: { viewModel.searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(.vertical, 11)
            .padding(.horizontal, 14)
            .background(Color.white.opacity(0.08))
            .cornerRadius(12)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(OrderSection.allCases, id: \.self) { section in
                        OrderSectionButton(
                            section: section,
                            isSelected: selectedOrderSection == section,
                            onTap: { selectedOrderSection = section }
                        )
                    }
                }
                .padding(.horizontal, 2)
            }
            
            if selectedOrderSection == .shop {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(ProductCategory.allCases, id: \.self) { category in
                            CategoryFilterButton(
                                category: category,
                                isSelected: viewModel.selectedCategory == category,
                                onTap: { viewModel.selectedCategory = category }
                            )
                        }
                    }
                    .padding(.horizontal, 2)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 16)
    }
    
    var mainContent: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: 24) {
                switch selectedOrderSection {
                case .shop:
                    shopContent
                case .myOrders:
                    ordersContent
                case .buyAgain:
                    buyAgainContent
                case .trackOrder:
                    trackingContent
                case .returns:
                    returnsContent
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 110)
        }
    }
    
    @ViewBuilder
    var shopContent: some View {
        if viewModel.isLoading {
            loadingView
        } else if viewModel.products.isEmpty {
            ShoppingEmptyState(
                icon: "bag",
                title: "No products found",
                subtitle: "Try again in a moment."
            )
        } else if !viewModel.searchText.isEmpty || viewModel.selectedCategory != .all {
            productGrid(title: "Results", products: viewModel.filteredProducts)
        } else {
            if !viewModel.recommendedProducts.isEmpty {
                productSection(
                    title: "Recommended for you",
                    subtitle: "Top rated picks",
                    products: viewModel.recommendedProducts
                )
            }
            
            if !viewModel.weightGainProducts.isEmpty {
                productSection(
                    title: "Weight Gain",
                    subtitle: "Supplements and nutrition",
                    products: viewModel.weightGainProducts
                )
            }
            
            if !viewModel.fitnessEquipment.isEmpty {
                productSection(
                    title: "Fitness Equipment",
                    subtitle: "Everything for your training",
                    products: viewModel.fitnessEquipment
                )
            }
            
            if !viewModel.nutritionProducts.isEmpty {
                productSection(
                    title: "Premium Nutrition",
                    subtitle: "Healthy foods",
                    products: viewModel.nutritionProducts
                )
            }
            
            if !viewModel.trendingProducts.isEmpty {
                productSection(
                    title: "Trending",
                    subtitle: "Popular products",
                    products: viewModel.trendingProducts
                )
            }
        }
    }
    
    @ViewBuilder
    var ordersContent: some View {
        if viewModel.orders.isEmpty {
            ShoppingEmptyState(
                icon: "shippingbox",
                title: "No orders yet",
                subtitle: "Your completed purchases will appear here."
            )
        } else {
            ForEach(viewModel.orders) { order in
                ShopOrderCard(
                    order: order,
                    onReorder: {
                        viewModel.reorder(order)
                        showingCart = true
                    },
                    onReturn: { viewModel.requestReturn(for: order) },
                    onAdvance: { viewModel.advanceTracking(for: order) }
                )
            }
        }
    }
    
    @ViewBuilder
    var buyAgainContent: some View {
        if viewModel.buyAgainProducts.isEmpty {
            ShoppingEmptyState(
                icon: "arrow.clockwise",
                title: "Nothing to buy again",
                subtitle: "After your first order, quick reorders will be ready here."
            )
        } else {
            productGrid(title: "Buy Again", products: viewModel.buyAgainProducts)
        }
    }
    
    @ViewBuilder
    var trackingContent: some View {
        if viewModel.activeOrders.isEmpty {
            ShoppingEmptyState(
                icon: "location",
                title: "No active deliveries",
                subtitle: "Tracking starts as soon as an order is paid."
            )
        } else {
            ForEach(viewModel.activeOrders) { order in
                TrackingOrderCard(
                    order: order,
                    onAdvance: { viewModel.advanceTracking(for: order) }
                )
            }
        }
    }
    
    @ViewBuilder
    var returnsContent: some View {
        if viewModel.orders.isEmpty {
            ShoppingEmptyState(
                icon: "arrow.uturn.backward",
                title: "No orders to return",
                subtitle: "Return requests will be linked to your orders."
            )
        } else {
            ForEach(viewModel.orders) { order in
                ReturnOrderCard(
                    order: order,
                    onRequestReturn: { viewModel.requestReturn(for: order) }
                )
            }
        }
    }
    
    private func productSection(title: String, subtitle: String, products: [ShopProduct]) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(LanguageManager.localizedString(title))
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text(LanguageManager.localizedString(subtitle))
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                NavigationLink(destination: ShopCategoryView(
                    title: title,
                    products: products,
                    shoppingViewModel: viewModel
                )) {
                    Label("See more", systemImage: "chevron.right")
                        .labelStyle(.titleAndIcon)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.yellow)
                }
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(products) { product in
                        HorizontalProductCard(
                            product: product,
                            onTap: { showingProductDetail = product },
                            onAddToCart: { viewModel.addToCart(product) }
                        )
                    }
                }
                .padding(.horizontal, 2)
            }
        }
    }
    
    private func productGrid(title: String, products: [ShopProduct]) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(LanguageManager.localizedString(title))
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.white)
            
            if products.isEmpty {
                ShoppingEmptyState(
                    icon: "magnifyingglass",
                    title: "No matches",
                    subtitle: "Try another search or category."
                )
            } else {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 160), spacing: 16)], spacing: 16) {
                    ForEach(products) { product in
                        HorizontalProductCard(
                            product: product,
                            onTap: { showingProductDetail = product },
                            onAddToCart: { viewModel.addToCart(product) }
                        )
                    }
                }
            }
        }
    }
    
    var loadingView: some View {
        VStack(spacing: 18) {
            ProgressView()
                .scaleEffect(1.4)
                .progressViewStyle(CircularProgressViewStyle(tint: .yellow))
            
            Text("Loading products...")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 60)
    }
}

// MARK: - Shared Shopping Components
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

struct ShoppingEmptyState: View {
    let icon: String
    let title: String
    let subtitle: String
    
    var body: some View {
        VStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 48, weight: .light))
                .foregroundColor(.gray)
            
            VStack(spacing: 6) {
                Text(LanguageManager.localizedString(title))
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
                
                Text(LanguageManager.localizedString(subtitle))
                    .font(.system(size: 15))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 44)
        .padding(.horizontal, 20)
        .background(Color.white.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

struct HorizontalProductCard: View {
    let product: ShopProduct
    let onTap: () -> Void
    let onAddToCart: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 0) {
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
                                    .font(.system(size: 24))
                                    .foregroundColor(.gray)
                            )
                    }
                    .frame(width: 160, height: 150)
                    .clipped()
                    .cornerRadius(12, corners: [.topLeft, .topRight])
                    
                    VStack(alignment: .trailing, spacing: 6) {
                        if product.discountPercentage > 0 {
                            Text("-\(Int(product.discountPercentage * 100))%")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 7)
                                .padding(.vertical, 3)
                                .background(Color.red)
                                .cornerRadius(6)
                        }
                        
                        if product.isNew {
                            Text("NEW")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.black)
                                .padding(.horizontal, 7)
                                .padding(.vertical, 3)
                                .background(Color.green)
                                .cornerRadius(6)
                        }
                    }
                    .padding(8)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(LanguageManager.localizedString(product.name))
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                        .lineLimit(2)
                        .frame(height: 36, alignment: .top)
                    
                    HStack(alignment: .bottom) {
                        VStack(alignment: .leading, spacing: 2) {
                            if product.discountPercentage > 0 {
                                Text(product.originalPrice.currencyText)
                                    .font(.system(size: 11))
                                    .foregroundColor(.gray)
                                    .strikethrough()
                            }
                            
                            Text(product.currentPrice.currencyText)
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.yellow)
                        }
                        
                        Spacer()
                        
                        HStack(spacing: 2) {
                            Image(systemName: "star.fill")
                                .font(.system(size: 10))
                                .foregroundColor(.yellow)
                            Text(String(format: "%.1f", product.rating))
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }
                    .frame(height: 34)
                    
                    Button(action: onAddToCart) {
                        Label("Add", systemImage: "bag.badge.plus")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .frame(height: 34)
                            .background(product.inStock ? Color.yellow : Color.gray)
                            .cornerRadius(8)
                    }
                    .disabled(!product.inStock)
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 12)
            }
        }
        .buttonStyle(PlainButtonStyle())
        .background(Color.white.opacity(0.07))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
        .frame(width: 160, height: 290)
    }
}

struct ShopOrderCard: View {
    let order: ShopOrder
    let onReorder: () -> Void
    let onReturn: () -> Void
    let onAdvance: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            OrderCardHeader(order: order)
            
            Text("\(order.itemCount) \(LanguageManager.localizedString("items")) · \(order.totals.total.currencyText)")
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.white)
            
            VStack(alignment: .leading, spacing: 6) {
                ForEach(order.items.prefix(3)) { item in
                    Text("\(item.quantity)x \(LanguageManager.localizedString(item.product.name))")
                        .font(.system(size: 13))
                        .foregroundColor(.gray)
                        .lineLimit(1)
                }
            }
            
            HStack(spacing: 10) {
                Button(action: onReorder) {
                    Label("Buy Again", systemImage: "arrow.clockwise")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 40)
                        .background(Color.yellow)
                        .cornerRadius(10)
                }
                
                Button(action: onReturn) {
                    Label(order.returnRequest == nil ? LanguageManager.localizedString("Return") : LanguageManager.localizedString("Return Sent"), systemImage: "arrow.uturn.backward")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(order.returnRequest == nil ? .white : .green)
                        .frame(maxWidth: .infinity)
                        .frame(height: 40)
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(10)
                }
                .disabled(order.returnRequest != nil)
            }
            
            if order.status.next != nil {
                Button(action: onAdvance) {
                    Label("Update tracking", systemImage: "location.fill")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.yellow)
                }
            }
        }
        .padding(18)
        .background(Color.white.opacity(0.07))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
    }
}

struct TrackingOrderCard: View {
    let order: ShopOrder
    let onAdvance: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            OrderCardHeader(order: order)
            
            VStack(alignment: .leading, spacing: 14) {
                ForEach(order.timeline) { event in
                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: event.completedAt == nil ? "circle" : "checkmark.circle.fill")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(event.completedAt == nil ? .gray : .green)
                        
                        VStack(alignment: .leading, spacing: 3) {
                            Text(LanguageManager.localizedString(event.title))
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.white)
                            
                            Text(event.completedAt?.shortDateText ?? LanguageManager.localizedString("Pending"))
                                .font(.system(size: 13))
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
            
            if order.status.next != nil {
                Button(action: onAdvance) {
                    Label("\(LanguageManager.localizedString("Move to")) \(order.status.next?.displayName ?? "")", systemImage: "arrow.right")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(Color.yellow)
                        .cornerRadius(10)
                }
            }
        }
        .padding(18)
        .background(Color.white.opacity(0.07))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

struct ReturnOrderCard: View {
    let order: ShopOrder
    let onRequestReturn: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            OrderCardHeader(order: order)
            
            if let request = order.returnRequest {
                HStack {
                    Label(request.status.displayName, systemImage: "checkmark.circle.fill")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.green)
                    
                    Spacer()
                    
                    Text(request.createdAt.shortDateText)
                        .font(.system(size: 13))
                        .foregroundColor(.gray)
                }
            } else {
                Text("\(LanguageManager.localizedString("Eligible items")): \(order.itemCount)")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.gray)
                
                Button(action: onRequestReturn) {
                    Label("Request Return", systemImage: "arrow.uturn.backward")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(Color.yellow)
                        .cornerRadius(10)
                }
            }
        }
        .padding(18)
        .background(Color.white.opacity(0.07))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

struct OrderCardHeader: View {
    let order: ShopOrder
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: order.status.icon)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(order.status.tint)
                .frame(width: 42, height: 42)
                .background(order.status.tint.opacity(0.15))
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 4) {
                Text(order.orderNumber)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                
                Text("\(LanguageManager.localizedString("Placed")) \(order.createdAt.shortDateText)")
                    .font(.system(size: 13))
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            OrderStatusBadge(status: order.status)
        }
    }
}

struct OrderStatusBadge: View {
    let status: ShopOrderStatus
    
    var body: some View {
        Text(status.displayName)
            .font(.system(size: 12, weight: .bold))
            .foregroundColor(status.tint)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(status.tint.opacity(0.15))
            .cornerRadius(8)
    }
}

struct OrderSectionButton: View {
    let section: OrderSection
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 6) {
                Image(systemName: section.icon)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(isSelected ? .black : .yellow)
                Text(section.displayName)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(isSelected ? .black : .white)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isSelected ? Color.yellow : Color.white.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        }
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}

struct CategoryFilterButton: View {
    let category: ProductCategory
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 6) {
                Image(systemName: category.icon)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(isSelected ? .black : .yellow)
                Text(category.displayName)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(isSelected ? .black : .white)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isSelected ? Color.yellow : Color.white.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
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
