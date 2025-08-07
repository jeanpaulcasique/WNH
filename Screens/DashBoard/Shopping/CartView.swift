import SwiftUI

struct CartView: View {
    @ObservedObject var viewModel: ShoppingViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showingCheckout = false
    
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
                    
                    if viewModel.cart.isEmpty {
                        emptyCartView
                    } else {
                        cartContent
                    }
                }
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showingCheckout) {
            CheckoutView(viewModel: viewModel)
        }
    }
}

// MARK: - View Components
private extension CartView {
    var headerSection: some View {
        HStack {
            Button(action: { dismiss() }) {
                Image(systemName: "xmark")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.white)
            }
            
            Spacer()
            
            Text("Shopping Cart")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)
            
            Spacer()
            
            if !viewModel.cart.isEmpty {
                Button(action: { viewModel.clearCart() }) {
                    Text("Clear")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.red)
                }
            } else {
                Color.clear
                    .frame(width: 40)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
        .padding(.bottom, 20)
    }
    
    var emptyCartView: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image(systemName: "bag")
                .font(.system(size: 80))
                .foregroundColor(.gray)
            
            VStack(spacing: 12) {
                Text("Your cart is empty")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(.white)
                
                Text("Add some products to get started")
                    .font(.system(size: 16))
                    .foregroundColor(.gray)
            }
            
            Button(action: { dismiss() }) {
                Text("Continue Shopping")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.yellow)
                    .cornerRadius(12)
            }
            .padding(.horizontal, 40)
            
            Spacer()
        }
    }
    
    var cartContent: some View {
        VStack(spacing: 0) {
            // Cart items
            ScrollView(showsIndicators: false) {
                LazyVStack(spacing: 16) {
                    ForEach(viewModel.cart) { item in
                        CartItemCard(
                            item: item,
                            onUpdateQuantity: { quantity in
                                viewModel.updateQuantity(for: item.product, quantity: quantity)
                            },
                            onRemove: {
                                viewModel.removeFromCart(item.product)
                            }
                        )
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
            
            // Checkout section
            VStack(spacing: 16) {
                // Order summary
                VStack(spacing: 12) {
                    HStack {
                        Text("Subtotal")
                            .foregroundColor(.gray)
                        Spacer()
                        Text("$\(String(format: "%.2f", viewModel.cartTotal))")
                            .foregroundColor(.white)
                    }
                    
                    HStack {
                        Text("Shipping")
                            .foregroundColor(.gray)
                        Spacer()
                        Text("Free")
                            .foregroundColor(.green)
                    }
                    
                    Divider()
                        .background(Color.gray.opacity(0.3))
                    
                    HStack {
                        Text("Total")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                        Spacer()
                        Text("$\(String(format: "%.2f", viewModel.cartTotal))")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.yellow)
                    }
                }
                .padding(.horizontal, 20)
                
                // Checkout button
                Button(action: { showingCheckout = true }) {
                    HStack(spacing: 12) {
                        Image(systemName: "creditcard.fill")
                            .font(.system(size: 18))
                        Text("Proceed to Checkout")
                            .font(.system(size: 18, weight: .semibold))
                    }
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.yellow)
                    .cornerRadius(12)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
            .background(.ultraThinMaterial)
        }
    }
}

// MARK: - Cart Item Card
struct CartItemCard: View {
    let item: CartItem
    let onUpdateQuantity: (Int) -> Void
    let onRemove: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            // Product image
            AsyncImage(url: URL(string: item.product.imageURL)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .overlay(
                        Image(systemName: "photo")
                            .font(.system(size: 20))
                            .foregroundColor(.gray)
                    )
            }
            .frame(width: 80, height: 80)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            
            // Product info
            VStack(alignment: .leading, spacing: 8) {
                Text(item.product.name)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .lineLimit(2)
                
                Text("$\(String(format: "%.2f", item.product.currentPrice))")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.yellow)
                
                // Quantity controls
                HStack(spacing: 12) {
                    Button(action: { onUpdateQuantity(item.quantity - 1) }) {
                        Image(systemName: "minus.circle.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.gray)
                    }
                    
                    Text("\(item.quantity)")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(minWidth: 30)
                    
                    Button(action: { onUpdateQuantity(item.quantity + 1) }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.yellow)
                    }
                    
                    Spacer()
                    
                    Button(action: onRemove) {
                        Image(systemName: "trash")
                            .font(.system(size: 16))
                            .foregroundColor(.red)
                    }
                }
            }
            
            Spacer()
        }
        .padding(16)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [Color.yellow.opacity(0.6), Color.yellow.opacity(0.2), .clear],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.5
                )
        )
    }
}

// MARK: - Checkout View
struct CheckoutView: View {
    @ObservedObject var viewModel: ShoppingViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var isProcessing = false
    @State private var showingSuccess = false
    
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
                    
                    if showingSuccess {
                        successView
                    } else {
                        checkoutForm
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }
    
    private var headerSection: some View {
        HStack {
            Button(action: { dismiss() }) {
                Image(systemName: "xmark")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.white)
            }
            
            Spacer()
            
            Text("Checkout")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)
            
            Spacer()
            
            Color.clear
                .frame(width: 40)
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
        .padding(.bottom, 20)
    }
    
    private var checkoutForm: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Order summary
                VStack(alignment: .leading, spacing: 16) {
                    Text("Order Summary")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                    
                    ForEach(viewModel.cart) { item in
                        HStack {
                            Text(item.product.name)
                                .foregroundColor(.gray)
                            Spacer()
                            Text("x\(item.quantity)")
                                .foregroundColor(.white)
                            Text("$\(String(format: "%.2f", item.product.currentPrice * Double(item.quantity)))")
                                .foregroundColor(.yellow)
                        }
                    }
                    
                    Divider()
                        .background(Color.gray.opacity(0.3))
                    
                    HStack {
                        Text("Total")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                        Spacer()
                        Text("$\(String(format: "%.2f", viewModel.cartTotal))")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.yellow)
                    }
                }
                .padding(20)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                
                // Payment button
                Button(action: processPayment) {
                    HStack(spacing: 12) {
                        if isProcessing {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .black))
                                .scaleEffect(0.8)
                        } else {
                            Image(systemName: "creditcard.fill")
                                .font(.system(size: 18))
                        }
                        
                        Text(isProcessing ? "Processing..." : "Pay $\(String(format: "%.2f", viewModel.cartTotal))")
                            .font(.system(size: 18, weight: .semibold))
                    }
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.yellow)
                    .cornerRadius(12)
                    .disabled(isProcessing)
                }
                .padding(.horizontal, 20)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 40)
        }
    }
    
    private var successView: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.green)
            
            VStack(spacing: 12) {
                Text("Payment Successful!")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(.white)
                
                Text("Your order has been placed successfully")
                    .font(.system(size: 16))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
            }
            
            Button(action: { 
                viewModel.clearCart()
                dismiss()
            }) {
                Text("Continue Shopping")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.yellow)
                    .cornerRadius(12)
            }
            .padding(.horizontal, 40)
            
            Spacer()
        }
    }
    
    private func processPayment() {
        isProcessing = true
        
        // Simulate payment processing
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            isProcessing = false
            showingSuccess = true
            
            // Auto-dismiss after 3 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                viewModel.clearCart()
                dismiss()
            }
        }
    }
}

#if DEBUG
struct CartView_Previews: PreviewProvider {
    static var previews: some View {
        CartView(viewModel: ShoppingViewModel())
            .preferredColorScheme(.dark)
    }
}
#endif 