import SwiftUI
import UIKit

// MARK: - Glovo Card View con Scroll Horizontal Automático
struct GlovoCardView: View {
    @State private var currentPage = 0
    @State private var showFloatingButtonText = true
    
    // Datos de las cards de Glovo
    private let glovoCards = [
        GlovoCardData(
            title: "Get groceries delivered",
            subtitle: "Order via Glovo in minutes",
            buttonText: "Order Now",
            icon: "GlovoV",
            backgroundColor: Color.yellow,
            textColor: Color.green
        ),
        GlovoCardData(
            title: "Fresh ingredients",
            subtitle: "Same day delivery available",
            buttonText: "Shop Now",
            icon: "GlovoV",
            backgroundColor: Color.green,
            textColor: Color.white
        ),
        GlovoCardData(
            title: "Special offers",
            subtitle: "Up to 30% off on groceries",
            buttonText: "View Deals",
            icon: "GlovoV",
            backgroundColor: Color.orange,
            textColor: Color.white
        )
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // Scroll horizontal automático
            ScrollViewReader { (proxy: ScrollViewProxy) in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(Array(glovoCards.enumerated()), id: \.offset) { index, card in
                            GlovoCard(cardData: card)
                                .frame(width: UIScreen.main.bounds.width - 32) // Ancho de pantalla menos padding
                                .id(index)
                        }
                    }
                    .padding(.horizontal, 16)
                }
                .onAppear {
                    startAutoScroll(proxy: proxy)
                }
            }
            
            // Page Indicator
            HStack(spacing: 8) {
                ForEach(0..<glovoCards.count, id: \.self) { index in
                    Circle()
                        .fill(currentPage == index ? Color.appYellow : Color.gray.opacity(0.3))
                        .frame(width: 8, height: 8)
                        .scaleEffect(currentPage == index ? 1.2 : 1.0)
                        .animation(.easeInOut(duration: 0.3), value: currentPage)
                }
            }
            .padding(.top, 12)
            .padding(.bottom, 8)
        }
    }
    
    // Función para scroll automático
    private func startAutoScroll(proxy: ScrollViewProxy) {
        Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 0.5)) {
                currentPage = (currentPage + 1) % glovoCards.count
                proxy.scrollTo(currentPage, anchor: .center)
            }
        }
    }
}

// MARK: - Glovo Card Data Model
struct GlovoCardData {
    let title: String
    let subtitle: String
    let buttonText: String
    let icon: String
    let backgroundColor: Color
    let textColor: Color
}

// MARK: - Individual Glovo Card
struct GlovoCard: View {
    let cardData: GlovoCardData
    
    var body: some View {
        HStack(spacing: 12) {
            // Icono
            ZStack {
                Circle()
                    .fill(cardData.backgroundColor)
                    .frame(width: 44, height: 44)
                
                if cardData.icon == "GlovoV" {
                    // Intentar cargar la imagen con manejo de errores
                    if let uiImage = UIImage(named: "GlovoV") {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 32, height: 32)
                    } else {
                        // Fallback si no se puede cargar
                        Image(systemName: "bag.fill")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(cardData.textColor)
                    }
                } else {
                    Image(systemName: cardData.icon)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(cardData.textColor)
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(cardData.title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(cardData.textColor)
                    .lineLimit(1)
                
                Text(cardData.subtitle)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(cardData.textColor.opacity(0.8))
                    .lineLimit(1)
                
                Button(action: {
                    openGlovoApp()
                }) {
                    Text(cardData.buttonText)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(cardData.backgroundColor)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(cardData.textColor)
                        .cornerRadius(16)
                }
            }
            
            Spacer()
        }
        .padding(12)
        .background(cardData.backgroundColor)
        .cornerRadius(20)
        .shadow(color: cardData.backgroundColor.opacity(0.3), radius: 10, x: 0, y: 5)
    }
    
    // MARK: - Glovo App Integration
    private func openGlovoApp() {
        // Intentar abrir Glovo app
        if let glovoURL = URL(string: "glovo://") {
            if UIApplication.shared.canOpenURL(glovoURL) {
                UIApplication.shared.open(glovoURL)
            } else {
                // Abrir App Store si no está instalado
                if let appStoreURL = URL(string: "https://apps.apple.com/app/glovo/id740189189") {
                    UIApplication.shared.open(appStoreURL)
                }
            }
        }
    }
}

// MARK: - Preview
struct GlovoCardView_Previews: PreviewProvider {
    static var previews: some View {
        GlovoCardView()
            .background(Color.black)
            .preferredColorScheme(.dark)
    }
}
