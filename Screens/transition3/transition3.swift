//
//  transition3.swift
//  WNH
//
//  Created by Jean Casique on 26/11/25.
//

import SwiftUI
import UIKit

// MARK: - CascadingAppearModifier (usado en otras partes de la app)
struct CascadingAppearModifier: ViewModifier {
    let index: Int
    let baseDelay: Double
    let offsetY: CGFloat
    let duration: Double
    @State private var isVisible = false
    @State private var hasAppeared = false
    
    func body(content: Content) -> some View {
        content
            .opacity(isVisible ? 1 : 0)
            .offset(y: isVisible ? 0 : offsetY)
            .animation(
                .easeOut(duration: duration).delay(baseDelay * Double(index)),
                value: isVisible
            )
            .onAppear {
                guard !hasAppeared else { return }
                hasAppeared = true
                DispatchQueue.main.asyncAfter(deadline: .now() + baseDelay * Double(index)) {
                    withAnimation {
                        isVisible = true
                    }
                }
            }
    }
}

extension View {
    /// Aplica animación de aparición en cascada (fade + slide) según el índice
    func cascadingAppear(index: Int, baseDelay: Double = 0.12, offsetY: CGFloat = 40, duration: Double = 0.5) -> some View {
        self.modifier(CascadingAppearModifier(index: index, baseDelay: baseDelay, offsetY: offsetY, duration: duration))
    }
}

// MARK: - Onboarding Transition Screens
struct OnboardingTransitionsView: View {
    @State private var currentPage = 0
    
    private func completeOnboardingTransitions() {
        // Marcar que ya se vieron las pantallas transicionales
        UserDefaults.standard.set(true, forKey: "hasSeenOnboardingTransitions")
        
        // Notificar que se completaron las transiciones
        NotificationCenter.default.post(name: NSNotification.Name("OnboardingTransitionsCompleted"), object: nil)
    }
    
    var body: some View {
        ZStack {
            // Fondo negro
            Color.black.ignoresSafeArea()
            
            TabView(selection: $currentPage) {
                // Pantalla 1: Meet your coach
                OnboardingPage1View()
                    .tag(0)
                
                // Pantalla 2: Action is the key
                OnboardingPage2View(currentPage: $currentPage, onComplete: completeOnboardingTransitions)
                    .tag(1)
                
                // Pantalla 3: Start your transformation
                OnboardingPage3View(currentPage: $currentPage, onComplete: completeOnboardingTransitions)
                    .tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .indexViewStyle(.page(backgroundDisplayMode: .always))
            
            // Indicadores de página personalizados
            VStack {
                Spacer()
                
                HStack(spacing: 8) {
                    ForEach(0..<3) { index in
                        Capsule()
                            .fill(index == currentPage ? Color.purple : Color.gray.opacity(0.4))
                            .frame(width: index == currentPage ? 24 : 8, height: 8)
                            .animation(.easeInOut(duration: 0.3), value: currentPage)
                    }
                }
                .padding(.bottom, currentPage == 2 ? 120 : 50)
            }
        }
    }
}

// MARK: - Pantalla 1: Meet your coach
struct OnboardingPage1View: View {
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Imagen de fondo - Hombre haciendo lunge
                    ZStack(alignment: .bottom) {
                        // Intenta cargar imagen real, si no existe usa placeholder
                        if let image = UIImage(named: "onboarding1") {
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(height: geometry.size.height * 0.65)
                                .clipped()
                        } else {
                            // Placeholder con gradiente
                            Rectangle()
                                .fill(
                                    LinearGradient(
                                        colors: [Color.gray.opacity(0.4), Color.black],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .frame(height: geometry.size.height * 0.65)
                                .overlay(
                                    Image(systemName: "figure.run")
                                        .font(.system(size: 100))
                                        .foregroundColor(.white.opacity(0.15))
                                )
                        }
                    }
                    
                    Spacer()
                    
                    // Texto motivacional
                    VStack(spacing: 8) {
                        Text("Meet your coach,")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("start your journey")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .padding(.bottom, 100)
                }
            }
        }
    }
}

// MARK: - Pantalla 2: Action is the key
struct OnboardingPage2View: View {
    @Binding var currentPage: Int
    let onComplete: () -> Void
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Imagen de fondo - Hombre musculoso con pesa
                    ZStack(alignment: .bottom) {
                        // Intenta cargar imagen real, si no existe usa placeholder
                        if let image = UIImage(named: "onboarding2") {
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(height: geometry.size.height * 0.6)
                                .clipped()
                        } else {
                            // Placeholder con gradiente
                            Rectangle()
                                .fill(
                                    LinearGradient(
                                        colors: [Color.gray.opacity(0.4), Color.black],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .frame(height: geometry.size.height * 0.6)
                                .overlay(
                                    Image(systemName: "dumbbell.fill")
                                        .font(.system(size: 100))
                                        .foregroundColor(.white.opacity(0.15))
                                )
                        }
                    }
                    
                    Spacer()
                    
                    // Texto motivacional
                    Text("Action is the key to all success")
                        .font(.system(size: 26, weight: .semibold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                        .padding(.bottom, 30)
                    
                    // Botón "Start Now" - aparece en esta pantalla también según la imagen
                    Button(action: {
                        onComplete()
                    }) {
                        HStack(spacing: 8) {
                            Text("Start Now")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                            
                            Image(systemName: "chevron.right")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal, 40)
                        .padding(.vertical, 16)
                        .background(Color.purple)
                        .cornerRadius(30)
                    }
                    .padding(.bottom, 50)
                }
            }
        }
    }
}

// MARK: - Pantalla 3: Start your transformation
struct OnboardingPage3View: View {
    @Binding var currentPage: Int
    let onComplete: () -> Void
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Imagen de fondo - Tercera imagen motivacional
                    ZStack(alignment: .bottom) {
                        // Intenta cargar imagen real, si no existe usa placeholder
                        if let image = UIImage(named: "onboarding3") {
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(height: geometry.size.height * 0.65)
                                .clipped()
                        } else {
                            // Placeholder con gradiente
                            Rectangle()
                                .fill(
                                    LinearGradient(
                                        colors: [Color.gray.opacity(0.4), Color.black],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .frame(height: geometry.size.height * 0.65)
                                .overlay(
                                    Image(systemName: "flame.fill")
                                        .font(.system(size: 100))
                                        .foregroundColor(.white.opacity(0.15))
                                )
                        }
                    }
                    
                    Spacer()
                    
                    // Texto motivacional
                    VStack(spacing: 8) {
                        Text("Transform your body,")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("transform your life")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .padding(.bottom, 30)
                    
                    // Botón "Start Now"
                    Button(action: {
                        onComplete()
                    }) {
                        HStack(spacing: 8) {
                            Text("Start Now")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                            
                            Image(systemName: "chevron.right")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal, 40)
                        .padding(.vertical, 16)
                        .background(Color.purple)
                        .cornerRadius(30)
                    }
                    .padding(.bottom, 50)
                }
            }
        }
    }
}

// MARK: - Preview
struct OnboardingTransitionsView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingTransitionsView()
    }
}

