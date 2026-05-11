import SwiftUI

struct CartView: View {
    @ObservedObject var viewModel: ShoppingViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showingCheckout = false
    
    var body: some View {
        NavigationView {
            ZStack {
                shoppingBackground
                
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
            CheckoutView(viewModel: viewModel) {
                showingCheckout = false
                dismiss()
            }
        }
    }
}

private extension CartView {
    var shoppingBackground: some View {
        LinearGradient(
            colors: [Color.black, Color.gray.opacity(0.28), Color.black],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
    
    var headerSection: some View {
        HStack {
            Button(action: { dismiss() }) {
                Image(systemName: "xmark")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.white)
                    .frame(width: 40, height: 40)
                    .background(Color.white.opacity(0.08))
                    .clipShape(Circle())
            }
            
            Spacer()
            
            VStack(spacing: 2) {
                Text("Shopping Cart")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                
                Text("\(viewModel.cartItemCount) \(LanguageManager.localizedString("items"))")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            if !viewModel.cart.isEmpty {
                Button(action: { viewModel.clearCart() }) {
                    Image(systemName: "trash")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.red)
                        .frame(width: 40, height: 40)
                        .background(Color.red.opacity(0.12))
                        .clipShape(Circle())
                }
            } else {
                Color.clear.frame(width: 40, height: 40)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
        .padding(.bottom, 18)
    }
    
    var emptyCartView: some View {
        VStack(spacing: 22) {
            Spacer()
            
            Image(systemName: "bag")
                .font(.system(size: 72, weight: .light))
                .foregroundColor(.gray)
            
            VStack(spacing: 10) {
                Text("Your cart is empty")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(.white)
                
                Text("Add products from the shop to start an order.")
                    .font(.system(size: 16))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
            }
            
            Button(action: { dismiss() }) {
                Label("Continue Shopping", systemImage: "arrow.left")
                    .font(.system(size: 17, weight: .semibold))
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
            ScrollView(showsIndicators: false) {
                LazyVStack(spacing: 14) {
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
            
            CartCheckoutPanel(
                summary: viewModel.orderSummary,
                onCheckout: { showingCheckout = true }
            )
        }
    }
}

struct CartCheckoutPanel: View {
    let summary: ShopOrderSummary
    let onCheckout: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            OrderTotalsView(summary: summary, compact: true)
            
            Button(action: onCheckout) {
                HStack(spacing: 10) {
                    Image(systemName: "creditcard.fill")
                    Text("Checkout")
                        .font(.system(size: 18, weight: .semibold))
                    Spacer()
                    Text(summary.total.currencyText)
                        .font(.system(size: 18, weight: .bold))
                }
                .foregroundColor(.black)
                .padding(.horizontal, 18)
                .padding(.vertical, 16)
                .frame(maxWidth: .infinity)
                .background(Color.yellow)
                .cornerRadius(12)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, 22)
        .background(.ultraThinMaterial)
    }
}

struct CartItemCard: View {
    let item: CartItem
    let onUpdateQuantity: (Int) -> Void
    let onRemove: () -> Void
    
    var body: some View {
        HStack(spacing: 14) {
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
            .frame(width: 78, height: 78)
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            
            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .top) {
                    Text(LanguageManager.localizedString(item.product.name))
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .lineLimit(2)
                    
                    Spacer()
                    
                    Button(action: onRemove) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 18))
                            .foregroundColor(.white.opacity(0.45))
                    }
                }
                
                HStack(alignment: .center) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(item.product.currentPrice.currencyText)
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.gray)
                        
                        Text(item.lineTotal.currencyText)
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.yellow)
                    }
                    
                    Spacer()
                    
                    QuantityStepper(
                        quantity: item.quantity,
                        onDecrease: { onUpdateQuantity(item.quantity - 1) },
                        onIncrease: { onUpdateQuantity(item.quantity + 1) }
                    )
                }
            }
        }
        .padding(14)
        .background(Color.white.opacity(0.07))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
    }
}

struct QuantityStepper: View {
    let quantity: Int
    let onDecrease: () -> Void
    let onIncrease: () -> Void
    
    var body: some View {
        HStack(spacing: 10) {
            Button(action: onDecrease) {
                Image(systemName: "minus")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 28, height: 28)
                    .background(Color.white.opacity(0.12))
                    .clipShape(Circle())
            }
            
            Text("\(quantity)")
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(.white)
                .frame(width: 24)
            
            Button(action: onIncrease) {
                Image(systemName: "plus")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.black)
                    .frame(width: 28, height: 28)
                    .background(Color.yellow)
                    .clipShape(Circle())
            }
        }
    }
}

// MARK: - Checkout
struct CheckoutView: View {
    @ObservedObject var viewModel: ShoppingViewModel
    let onFinished: () -> Void
    
    @Environment(\.dismiss) private var dismiss
    @State private var checkout = CheckoutDetails()
    @State private var step: CheckoutStep = .shipping
    @State private var validationMessage: String?
    @State private var isProcessing = false
    @State private var completedOrder: ShopOrder?
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    colors: [Color.black, Color.gray.opacity(0.28), Color.black],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    checkoutHeader
                    
                    if step == .confirmation, let completedOrder {
                        ConfirmationView(order: completedOrder) {
                            dismiss()
                            onFinished()
                        }
                    } else {
                        checkoutBody
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }
    
    private var checkoutHeader: some View {
        VStack(spacing: 16) {
            HStack {
                Button(action: closeCheckout) {
                    Image(systemName: "xmark")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.white)
                        .frame(width: 40, height: 40)
                        .background(Color.white.opacity(0.08))
                        .clipShape(Circle())
                }
                .disabled(isProcessing)
                
                Spacer()
                
                Text(step.title)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                
                Spacer()
                
                Color.clear.frame(width: 40, height: 40)
            }
            
            CheckoutProgressView(step: step)
        }
        .padding(.horizontal, 20)
        .padding(.top, 18)
        .padding(.bottom, 16)
    }
    
    private var checkoutBody: some View {
        VStack(spacing: 0) {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 18) {
                    if let validationMessage {
                        ValidationBanner(message: validationMessage)
                    }
                    
                    switch step {
                    case .shipping:
                        ShippingForm(checkout: $checkout)
                    case .payment:
                        PaymentForm(checkout: $checkout)
                    case .review:
                        ReviewOrderView(viewModel: viewModel, checkout: checkout)
                    case .confirmation:
                        EmptyView()
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 120)
            }
            
            CheckoutFooter(
                step: step,
                total: viewModel.orderSummary.total,
                isProcessing: isProcessing,
                onBack: goBack,
                onNext: goNext
            )
        }
    }
    
    private func closeCheckout() {
        dismiss()
    }
    
    private func goBack() {
        validationMessage = nil
        
        switch step {
        case .shipping:
            dismiss()
        case .payment:
            step = .shipping
        case .review:
            step = .payment
        case .confirmation:
            break
        }
    }
    
    private func goNext() {
        validationMessage = nil
        
        switch step {
        case .shipping:
            let errors = checkout.shippingValidationErrors()
            if let first = errors.first {
                validationMessage = first
            } else {
                step = .payment
            }
        case .payment:
            let errors = checkout.paymentValidationErrors()
            if let first = errors.first {
                validationMessage = first
            } else {
                step = .review
            }
        case .review:
            processPayment()
        case .confirmation:
            break
        }
    }
    
    private func processPayment() {
        guard !isProcessing else { return }
        
        isProcessing = true
        validationMessage = nil
        
        Task {
            do {
                let order = try await viewModel.placeOrder(with: checkout)
                completedOrder = order
                step = .confirmation
            } catch {
                validationMessage = error.localizedDescription
            }
            
            isProcessing = false
        }
    }
}

enum CheckoutStep: Int, CaseIterable {
    case shipping
    case payment
    case review
    case confirmation
    
    var title: String {
        switch self {
        case .shipping: return LanguageManager.localizedString("Shipping")
        case .payment: return LanguageManager.localizedString("Payment")
        case .review: return LanguageManager.localizedString("Review")
        case .confirmation: return LanguageManager.localizedString("Confirmed")
        }
    }
    
    var icon: String {
        switch self {
        case .shipping: return "shippingbox.fill"
        case .payment: return "creditcard.fill"
        case .review: return "doc.text.magnifyingglass"
        case .confirmation: return "checkmark.seal.fill"
        }
    }
}

struct CheckoutProgressView: View {
    let step: CheckoutStep
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(CheckoutStep.allCases.filter { $0 != .confirmation }, id: \.self) { item in
                HStack(spacing: 8) {
                    Image(systemName: item.icon)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(item.rawValue <= step.rawValue ? .black : .white.opacity(0.55))
                        .frame(width: 30, height: 30)
                        .background(item.rawValue <= step.rawValue ? Color.yellow : Color.white.opacity(0.1))
                        .clipShape(Circle())
                    
                    if item != .review {
                        Rectangle()
                            .fill(item.rawValue < step.rawValue ? Color.yellow : Color.white.opacity(0.12))
                            .frame(height: 2)
                    }
                }
            }
        }
    }
}

struct ShippingForm: View {
    @Binding var checkout: CheckoutDetails
    
    var body: some View {
        CheckoutSection(title: "Delivery details", icon: "person.crop.circle.fill") {
            CheckoutTextField(title: "Full name", text: $checkout.fullName, contentType: .name)
            CheckoutTextField(title: "Email", text: $checkout.email, keyboard: .emailAddress, contentType: .emailAddress)
            CheckoutTextField(title: "Phone", text: $checkout.phone, keyboard: .phonePad, contentType: .telephoneNumber)
        }
        
        CheckoutSection(title: "Address", icon: "mappin.and.ellipse") {
            CheckoutTextField(title: "Street address", text: $checkout.addressLine1, contentType: .streetAddressLine1)
            CheckoutTextField(title: "Apt, suite, floor", text: $checkout.addressLine2, contentType: .streetAddressLine2)
            
            HStack(spacing: 10) {
                CheckoutTextField(title: "City", text: $checkout.city, contentType: .addressCity)
                CheckoutTextField(title: "State", text: $checkout.region, contentType: .addressState)
            }
            
            HStack(spacing: 10) {
                CheckoutTextField(title: "ZIP", text: $checkout.postalCode, keyboard: .numbersAndPunctuation, contentType: .postalCode)
                CheckoutTextField(title: "Country", text: $checkout.country, contentType: .countryName)
            }
        }
    }
}

struct PaymentForm: View {
    @Binding var checkout: CheckoutDetails
    
    var body: some View {
        CheckoutSection(title: "Card payment", icon: "creditcard.fill") {
            CheckoutTextField(title: "Cardholder name", text: $checkout.cardholderName, contentType: .name)
            CheckoutTextField(title: "Card number", text: $checkout.cardNumber, keyboard: .numberPad, contentType: .creditCardNumber)
            
            HStack(spacing: 10) {
                CheckoutTextField(title: "MM/YY", text: expirationDateBinding, keyboard: .numbersAndPunctuation)
                CheckoutTextField(title: "CVC", text: $checkout.securityCode, keyboard: .numberPad)
            }
            
            Toggle(isOn: $checkout.billingSameAsShipping) {
                Text("Billing same as shipping")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.white)
            }
            .tint(.yellow)
            .padding(.top, 4)
        }
        
        CheckoutSection(title: "Authorization", icon: "lock.shield.fill") {
            HStack(spacing: 12) {
                Image(systemName: "building.columns.fill")
                    .foregroundColor(.yellow)
                    .frame(width: 34, height: 34)
                    .background(Color.yellow.opacity(0.15))
                    .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 3) {
                    Text("Bank gateway")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Text("Sandbox authorization")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
            }
        }
    }
    
    private var expirationDateBinding: Binding<String> {
        Binding(
            get: { checkout.expiration },
            set: { checkout.expiration = Self.formattedExpirationDate($0) }
        )
    }
    
    private static func formattedExpirationDate(_ value: String) -> String {
        let digits = String(value.filter(\.isNumber).prefix(4))
        guard digits.count > 2 else { return digits }
        
        let month = digits.prefix(2)
        let year = digits.dropFirst(2)
        return "\(month)/\(year)"
    }
}

struct ReviewOrderView: View {
    @ObservedObject var viewModel: ShoppingViewModel
    let checkout: CheckoutDetails
    
    var body: some View {
        CheckoutSection(title: "Items", icon: "bag.fill") {
            VStack(spacing: 12) {
                ForEach(viewModel.cart) { item in
                    HStack(alignment: .top, spacing: 12) {
                        Text("\(item.quantity)x")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.yellow)
                            .frame(width: 34, alignment: .leading)
                        
                        VStack(alignment: .leading, spacing: 3) {
                            Text(LanguageManager.localizedString(item.product.name))
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.white)
                                .lineLimit(2)
                            
                            Text(item.product.category.displayName)
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                        
                        Text(item.lineTotal.currencyText)
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
            }
        }
        
        CheckoutSection(title: "Ship to", icon: "location.fill") {
            VStack(alignment: .leading, spacing: 6) {
                Text(checkout.fullName)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.white)
                
                ForEach(checkout.shippingAddress.displayLines, id: \.self) { line in
                    Text(line)
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        
        CheckoutSection(title: "Payment", icon: "creditcard.fill") {
            HStack {
                Text(LanguageManager.localizedString(checkout.maskedCardNumber))
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white)
                Spacer()
                Text("USD")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.yellow)
            }
        }
        
        CheckoutSection(title: "Total", icon: "receipt.fill") {
            OrderTotalsView(summary: viewModel.orderSummary, compact: false)
        }
    }
}

struct CheckoutFooter: View {
    let step: CheckoutStep
    let total: Double
    let isProcessing: Bool
    let onBack: () -> Void
    let onNext: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            Button(action: onBack) {
                Image(systemName: step == .shipping ? "xmark" : "chevron.left")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 52, height: 52)
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(12)
            }
            .disabled(isProcessing)
            
            Button(action: onNext) {
                HStack(spacing: 10) {
                    if isProcessing {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .black))
                    } else {
                        Image(systemName: step == .review ? "lock.fill" : "arrow.right")
                    }
                    
                    Text(buttonTitle)
                        .font(.system(size: 17, weight: .bold))
                    
                    if step == .review {
                        Text(total.currencyText)
                            .font(.system(size: 17, weight: .bold))
                    }
                }
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(Color.yellow)
                .cornerRadius(12)
            }
            .disabled(isProcessing)
        }
        .padding(.horizontal, 20)
        .padding(.top, 14)
        .padding(.bottom, 22)
        .background(.ultraThinMaterial)
    }
    
    private var buttonTitle: String {
        if isProcessing { return LanguageManager.localizedString("Authorizing") }
        
        switch step {
        case .shipping: return LanguageManager.localizedString("Continue")
        case .payment: return LanguageManager.localizedString("Review Order")
        case .review: return LanguageManager.localizedString("Pay")
        case .confirmation: return LanguageManager.localizedString("Done")
        }
    }
}

struct ConfirmationView: View {
    let order: ShopOrder
    let onDone: () -> Void
    
    var body: some View {
        VStack(spacing: 22) {
            Spacer()
            
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 82))
                .foregroundColor(.green)
            
            VStack(spacing: 8) {
                Text("Order Confirmed")
                    .font(.system(size: 27, weight: .bold))
                    .foregroundColor(.white)
                
                Text(order.orderNumber)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.yellow)
            }
            
            VStack(spacing: 12) {
                ConfirmationRow(title: "Total paid", value: order.totals.total.currencyText)
                ConfirmationRow(title: "Status", value: order.status.displayName)
                ConfirmationRow(title: "Bank reference", value: order.payment.bankReference)
                ConfirmationRow(title: "Estimated delivery", value: order.estimatedDelivery.shortDateText)
            }
            .padding(18)
            .background(Color.white.opacity(0.07))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .padding(.horizontal, 28)
            
            Button(action: onDone) {
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
}

struct ConfirmationRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack(alignment: .top) {
            Text(LanguageManager.localizedString(title))
                .font(.system(size: 14))
                .foregroundColor(.gray)
            Spacer()
            Text(LanguageManager.localizedString(value))
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)
                .multilineTextAlignment(.trailing)
        }
    }
}

struct CheckoutSection<Content: View>: View {
    let title: String
    let icon: String
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.yellow)
                
                Text(LanguageManager.localizedString(title))
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
            }
            
            content
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.07))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
    }
}

struct CheckoutTextField: View {
    let title: String
    @Binding var text: String
    var keyboard: UIKeyboardType = .default
    var contentType: UITextContentType?
    
    var body: some View {
        TextField(LanguageManager.localizedString(title), text: $text)
            .font(.system(size: 15, weight: .medium))
            .foregroundColor(.white)
            .keyboardType(keyboard)
            .textContentType(contentType)
            .textInputAutocapitalization(keyboard == .emailAddress ? .never : .words)
            .autocorrectionDisabled()
            .padding(.horizontal, 14)
            .frame(height: 48)
            .background(Color.black.opacity(0.26))
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.white.opacity(0.08), lineWidth: 1)
            )
    }
}

struct ValidationBanner: View {
    let message: String
    
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.orange)
            Text(LanguageManager.localizedString(message))
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white)
            Spacer()
        }
        .padding(14)
        .background(Color.orange.opacity(0.16))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

struct OrderTotalsView: View {
    let summary: ShopOrderSummary
    var compact: Bool
    
    var body: some View {
        VStack(spacing: compact ? 8 : 12) {
            TotalLine(title: "Subtotal", value: summary.subtotal.currencyText)
            TotalLine(title: "Shipping", value: summary.shipping == 0 ? LanguageManager.localizedString("Free") : summary.shipping.currencyText, valueColor: summary.shipping == 0 ? .green : .white)
            TotalLine(title: "Tax", value: summary.tax.currencyText)
            
            Divider()
                .background(Color.white.opacity(0.15))
            
            TotalLine(
                title: "Total",
                value: summary.total.currencyText,
                titleFont: .system(size: 18, weight: .bold),
                valueFont: .system(size: 20, weight: .bold),
                valueColor: .yellow
            )
        }
    }
}

struct TotalLine: View {
    let title: String
    let value: String
    var titleFont: Font = .system(size: 15, weight: .medium)
    var valueFont: Font = .system(size: 15, weight: .semibold)
    var valueColor: Color = .white
    
    var body: some View {
        HStack {
            Text(LanguageManager.localizedString(title))
                .font(titleFont)
                .foregroundColor(.gray)
            Spacer()
            Text(value)
                .font(valueFont)
                .foregroundColor(valueColor)
        }
    }
}

extension Double {
    var currencyText: String {
        String(format: "$%.2f", self)
    }
}

extension Date {
    var shortDateText: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: self)
    }
}

#if DEBUG
struct CartView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = ShoppingViewModel()
        viewModel.loadProducts()
        return CartView(viewModel: viewModel)
            .preferredColorScheme(.dark)
    }
}
#endif
