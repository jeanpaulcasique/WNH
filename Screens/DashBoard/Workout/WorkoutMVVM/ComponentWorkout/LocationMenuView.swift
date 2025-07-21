import SwiftUI

/// Componente del menú de selección de ubicación de workout - Versión mejorada
struct LocationMenuView: View {
    @Binding var isVisible: Bool
    @Binding var selectedLocation: WorkoutLocation
    @State private var animatingSelection: Bool = false
    @State private var selectedLocationOption: WorkoutLocation?
    @State private var showCheckmark: Bool = false
    
    // MARK: - Constants
    private enum Constants {
        static let menuWidth: CGFloat = 220
        static let menuTopOffset: CGFloat = 90 // Más cerca del botón
        static let cornerRadius: CGFloat = 16
        static let shadowRadius: CGFloat = 20
        static let iconSize: CGFloat = 20
        static let animationDuration: Double = 0.25
        static let selectionDelay: Double = 0.4
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Overlay de fondo oscuro y borroso
                Color.black.opacity(0.35)
                    .ignoresSafeArea()
                    .onTapGesture {
                        dismissMenu()
                    }
                // Card flotante centrada
                VStack(spacing: 0) {
                    // Botón de cerrar discreto
                    HStack {
                        Spacer()
                        Button(action: { dismissMenu() }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(.yellow.opacity(0.85))
                                .padding(8)
                        }
                    }
                    .padding(.trailing, 4)
                    // Header con icono grande y título centrado
                    VStack(spacing: 8) {
                        Image(systemName: "location.circle.fill")
                            .font(.system(size: 38, weight: .bold))
                            .foregroundColor(.yellow)
                            .padding(.top, 8)
                        Text("Workout Location")
                            .font(.title2.bold())
                            .foregroundColor(.yellow)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.bottom, 8)
                    // Opciones
                    menuOptions()
                }
                .background(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .fill(.ultraThinMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: 28, style: .continuous)
                                .stroke(Color.yellow.opacity(0.18), lineWidth: 2)
                        )
                )
                .shadow(color: .black.opacity(0.18), radius: 24, x: 0, y: 8)
                .frame(width: min(geometry.size.width - 32, 320))
                .padding(.vertical, 32)
                .padding(.horizontal, 16)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                .scaleEffect(isVisible ? 1 : 0.85)
                .opacity(isVisible ? 1 : 0)
                .animation(.spring(response: 0.45, dampingFraction: 0.85), value: isVisible)
                .transition(.scale.combined(with: .opacity))
            }
        }
    }
    
    // MARK: - Menu Header
    
    private func menuHeader() -> some View {
        HStack {
      
            
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            LinearGradient(
                colors: [Color.yellow.opacity(0.2), Color.clear],
                startPoint: .leading,
                endPoint: .trailing
            )
        )
    }
    
    // MARK: - Menu Options
    
    private func menuOptions() -> some View {
        VStack(spacing: 0) {
            ForEach(Array(WorkoutLocation.allCases.enumerated()), id: \.element.id) { index, location in
                locationOptionButton(location: location, index: index)
                    .transition(.slide.combined(with: .opacity))
                    .animation(
                        .spring(response: 0.3, dampingFraction: 0.7)
                        .delay(Double(index) * 0.05),
                        value: isVisible
                    )
                
                if location != WorkoutLocation.allCases.last {
                    menuDivider()
                }
            }
        }
        .padding(.bottom, 8)
    }
    
    // MARK: - Menu Background
    
    private var menuBackground: some View {
        ZStack {
            // Fondo base con gradiente sutil
            LinearGradient(
                colors: [
                    Color.black.opacity(0.95),
                    Color.gray.opacity(0.2),
                    Color.black.opacity(0.95)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // Efecto de vidrio
            Rectangle()
                .fill(.ultraThinMaterial)
                .opacity(0.1)
        }
    }
    
    // MARK: - Menu Divider
    
    private func menuDivider() -> some View {
        Rectangle()
            .fill(
                LinearGradient(
                    colors: [Color.clear, Color.gray.opacity(0.3), Color.clear],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .frame(height: 0.5)
            .padding(.horizontal, 20)
    }
    
    // MARK: - Location Option Button
    
    private func locationOptionButton(location: WorkoutLocation, index: Int) -> some View {
        let isSelected = selectedLocation == location
        let isAnimating = selectedLocationOption == location && animatingSelection
        return Button(action: {
            handleLocationSelection(location)
        }) {
            HStack(spacing: 16) {
                locationIcon(location: location, isAnimating: isAnimating)
                locationText(location: location, isAnimating: isAnimating)
                Spacer()
                if isSelected && showCheckmark {
                    selectionIndicator(isAnimating: isAnimating)
                }
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 18)
            .background(isSelected ? Color.yellow.opacity(0.13) : Color.clear)
            .cornerRadius(16)
            .font(isSelected ? .headline.bold() : .body)
            .foregroundColor(isSelected ? .yellow : .white)
            .scaleEffect(isAnimating ? 1.04 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isAnimating)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Location Icon
    
    private func locationIcon(location: WorkoutLocation, isAnimating: Bool) -> some View {
        ZStack {
            // Fondo del icono
            Circle()
                .fill(Color.yellow.opacity(0.15))
                .frame(width: 32, height: 32)
                .scaleEffect(isAnimating ? 1.2 : 1.0)
            
            // Icono
            Image(systemName: location.icon)
                .foregroundColor(.yellow)
                .font(.system(size: Constants.iconSize, weight: .semibold))
                .scaleEffect(isAnimating ? 1.3 : 1.0)
                .rotationEffect(.degrees(isAnimating ? 360 : 0))
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.6), value: isAnimating)
    }
    
    // MARK: - Location Text
    
    private func locationText(location: WorkoutLocation, isAnimating: Bool) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(location.displayName)
                .foregroundColor(.white)
                .fontWeight(.semibold)
                .font(.body)
                .scaleEffect(isAnimating ? 1.05 : 1.0, anchor: .leading)
            
            // Subtexto descriptivo opcional
            if let subtitle = location.subtitle {
                Text(subtitle)
                    .foregroundColor(.gray)
                    .font(.caption)
                    .opacity(0.8)
            }
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isAnimating)
    }
    
    // MARK: - Selection Indicator
    
    private func selectionIndicator(isAnimating: Bool) -> some View {
        ZStack {
            Circle()
                .fill(Color.yellow)
                .frame(width: 24, height: 24)
                .scaleEffect(isAnimating ? 1.2 : 1.0)
            
            Image(systemName: "checkmark")
                .foregroundColor(.black)
                .font(.system(size: 12, weight: .bold))
                .scaleEffect(isAnimating ? 1.3 : 1.0)
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isAnimating)
    }
    
    // MARK: - Methods
    
    private func handleLocationSelection(_ location: WorkoutLocation) {
        // Haptic feedback mejorado
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.prepare()
        impactFeedback.impactOccurred()
        
        // Animación de selección
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            selectedLocationOption = location
            animatingSelection = true
        }
        
        // Delay para mostrar la animación antes de cambiar la selección
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.easeInOut(duration: Constants.animationDuration)) {
                selectedLocation = location
                showCheckmark = true
            }
            
            // Delay adicional antes de cerrar el menú
            DispatchQueue.main.asyncAfter(deadline: .now() + Constants.selectionDelay) {
                dismissMenu()
            }
        }
    }
    
    private func dismissMenu() {
        withAnimation(.easeInOut(duration: Constants.animationDuration)) {
            isVisible = false
            animatingSelection = false
            selectedLocationOption = nil
            showCheckmark = false
        }
    }
}

// MARK: - Custom Button Style

struct LocationButtonStyle: ButtonStyle {
    let isSelected: Bool
    let isAnimating: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(
                        configuration.isPressed
                            ? Color.yellow.opacity(0.1)
                            : (isSelected ? Color.yellow.opacity(0.05) : Color.clear)
                    )
                    .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
                    .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
            )
            .scaleEffect(isAnimating ? 1.02 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isAnimating)
    }
}

// MARK: - WorkoutLocation Extension

extension WorkoutLocation {
    var subtitle: String? {
        switch self {
        case .atHome:
            return "Entrenar desde casa"
        case .atGym:
            return "Ir al gimnasio"
        case .outdoors:
            return "Entrenar al aire libre"
        }
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        
        LocationMenuView(
            isVisible: .constant(true),
            selectedLocation: .constant(WorkoutLocation.atHome)
        )
    }
    .preferredColorScheme(.dark)
}
